library;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../core/ai/ai_config.dart';
import '../../core/ai/ai_service.dart';
import '../../core/ai/mcts.dart';
import '../../core/engine/position.dart';
import '../../data/settings_store.dart';

typedef SearchMove = Future<SearchResult> Function(Position position);

enum GamePhase { humanTurn, applying, aiThinking, finished }

class PieceSprite {
  PieceSprite({required this.id, required this.square, required this.kind});

  final int id;
  int square;
  int kind;
  bool captured = false;
}

class AiReadout {
  const AiReadout({
    required this.evaluation,
    required this.confidence,
    required this.elapsedMs,
  });

  final double evaluation;
  final double confidence;
  final int elapsedMs;
}

class GameController extends ChangeNotifier {
  GameController({
    required this.searchMove,
    required this.settings,
    this.animationDuration = const Duration(milliseconds: 280),
  }) : _position = Position.initial() {
    _humanSide = settings.humanSide;
    _resetSprites();
    _refreshLegal();
  }

  final SearchMove searchMove;
  final SettingsStore settings;
  final Duration animationDuration;

  Position _position;
  late int _humanSide;
  int _nextSpriteId = 0;
  int _generation = 0;
  bool _disposed = false;

  final List<PieceSprite> _sprites = [];
  List<int> _legal = const [];
  final Map<int, List<int>> _targetsBySource = {};

  int? _selected;
  int? _lastFrom;
  int? _lastTo;
  GamePhase _phase = GamePhase.humanTurn;
  int? _winner;
  bool _resultAcknowledged = true;
  AiReadout? _readout;
  String? _error;

  List<PieceSprite> get sprites => List.unmodifiable(_sprites);

  int get humanSide => _humanSide;

  bool get flipped => _humanSide == black;

  GamePhase get phase => _phase;
  int? get winner => _winner;
  int? get selected => _selected;
  int? get lastFrom => _lastFrom;
  int? get lastTo => _lastTo;
  AiReadout? get readout => _readout;
  String? get error => _error;
  int get ply => _position.ply;

  int? get chainSquare => _position.chainSq >= 0 ? _position.chainSq : null;

  bool get isHumanTurn =>
      _phase == GamePhase.humanTurn && _position.player == _humanSide;

  bool get hasUnseenResult => _winner != null && !_resultAcknowledged;

  List<int> get selectedTargets =>
      _selected == null ? const [] : (_targetsBySource[_selected] ?? const []);

  Iterable<int> get movableSquares => _targetsBySource.keys;

  Future<void> newGame({int? humanSide}) async {
    _generation++;
    _humanSide = humanSide ?? settings.humanSide;
    _position = Position.initial();
    _nextSpriteId = 0;
    _resetSprites();
    _selected = null;
    _lastFrom = null;
    _lastTo = null;
    _winner = null;
    _resultAcknowledged = true;
    _readout = null;
    _error = null;
    _phase = GamePhase.humanTurn;
    _refreshLegal();
    _notify();
    await _maybeRunAi(_generation);
  }

  Future<void> tapSquare(int square) async {
    if (!isHumanTurn || _winner != null) return;

    final chain = chainSquare;
    if (chain != null) _selected = chain;

    final current = _selected;
    if (current != null) {
      final targets = _targetsBySource[current] ?? const <int>[];
      if (targets.contains(square)) {
        await _playHumanMove(current, square);
        return;
      }
    }

    if (_targetsBySource.containsKey(square)) {
      _selected = square;
      _haptic(_Haptic.select);
    } else {
      _selected = null;
    }
    _notify();
  }

  void acknowledgeResult() {
    _resultAcknowledged = true;
    _notify();
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    _notify();
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    super.dispose();
  }

  Future<void> _playHumanMove(int from, int to) async {
    final action = actionEncode(from, to);
    if (!_legal.contains(action)) {
      _error = 'illegal';
      _notify();
      return;
    }
    final generation = _generation;
    _phase = GamePhase.applying;
    _selected = null;
    await _applyAction(action);
    if (_stale(generation)) return;

    if (_winner != null) {
      _phase = GamePhase.finished;
      _notify();
      return;
    }

    _phase = GamePhase.humanTurn;
    if (_position.player == _humanSide) {
      _selected = chainSquare;
      _notify();
      return;
    }
    _notify();
    await _maybeRunAi(generation);
  }

  Future<void> _maybeRunAi(int generation) async {
    if (_winner != null || _position.player == _humanSide) return;

    _phase = GamePhase.aiThinking;
    _notify();

    try {
      for (var segment = 0; segment < AiConfig.maxChainSegments; segment++) {
        if (_stale(generation)) return;
        if (_winner != null || _position.player == _humanSide) break;

        final result = await searchMove(_position);
        if (_stale(generation)) return;

        if (!_legal.contains(result.action)) {
          throw const AiException('model qonuniy bo\'lmagan yurish qaytardi');
        }

        _readout = AiReadout(
          evaluation: -result.value,
          confidence: result.confidence,
          elapsedMs: result.elapsedMs,
        );
        await _applyAction(result.action);
        if (_stale(generation)) return;
      }
    } on AiException catch (e) {
      if (_stale(generation)) return;
      _error = e.message;
    } catch (e) {
      if (_stale(generation)) return;
      _error = '$e';
    }

    if (_stale(generation)) return;
    _phase = _winner != null ? GamePhase.finished : GamePhase.humanTurn;
    if (_position.player == _humanSide) _selected = chainSquare;
    _notify();
  }

  Future<void> _applyAction(int action) async {
    final from = actionFrom(action);
    final to = actionTo(action);
    final generation = _generation;

    final moving = _liveSpriteAt(from);
    _position.apply(action);
    if (moving != null) moving.square = to;

    var anyCaptured = false;
    for (final sprite in _sprites) {
      if (sprite.captured) continue;
      final piece = _position.pieceAt(sprite.square);
      if (piece == 0) {
        sprite.captured = true;
        anyCaptured = true;
      } else {
        sprite.kind = piece;
      }
    }

    _lastFrom = from;
    _lastTo = to;
    _refreshLegal();
    _haptic(anyCaptured ? _Haptic.capture : _Haptic.move);
    _notify();

    final duration = animationDuration;
    if (duration > Duration.zero) {
      await Future<void>.delayed(duration);
      if (_stale(generation)) return;
    }
    if (_sprites.any((s) => s.captured)) {
      _sprites.removeWhere((s) => s.captured);
      _notify();
    }
  }

  bool _stale(int generation) => _disposed || generation != _generation;

  PieceSprite? _liveSpriteAt(int square) {
    for (final sprite in _sprites) {
      if (!sprite.captured && sprite.square == square) return sprite;
    }
    return null;
  }

  void _resetSprites() {
    _sprites.clear();
    for (var sq = 0; sq < numSquares; sq++) {
      final piece = _position.pieceAt(sq);
      if (piece != 0) {
        _sprites.add(PieceSprite(id: _nextSpriteId++, square: sq, kind: piece));
      }
    }
  }

  void _refreshLegal() {
    final status = _position.status();
    _legal = status.moves;
    _targetsBySource.clear();
    if (_position.player == _humanSide && status.winner == null) {
      for (final action in _legal) {
        _targetsBySource
            .putIfAbsent(actionFrom(action), () => <int>[])
            .add(actionTo(action));
      }
    }
    if (status.winner != null && _winner == null) {
      _winner = status.winner;
      _resultAcknowledged = false;
      _selected = null;
      settings.recordResult(winner: status.winner!, humanSide: _humanSide);
    }
  }

  void _haptic(_Haptic kind) {
    if (!settings.haptics) return;
    switch (kind) {
      case _Haptic.select:
        HapticFeedback.selectionClick();
      case _Haptic.move:
        HapticFeedback.lightImpact();
      case _Haptic.capture:
        HapticFeedback.mediumImpact();
    }
  }

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }
}

enum _Haptic { select, move, capture }
