library;

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shashka/core/ai/ai_service.dart';
import 'package:shashka/core/ai/mcts.dart';
import 'package:shashka/core/engine/position.dart';
import 'package:shashka/data/settings_store.dart';
import 'package:shashka/features/game/game_controller.dart';

SearchResult _result(int action) => SearchResult(
      action: action,
      confidence: 0.5,
      value: 0.1,
      sims: 0,
      elapsedMicros: 1000,
    );

Future<SettingsStore> _store() async {
  SharedPreferences.setMockInitialValues(<String, Object>{
    'animations': false,
    'haptics': false,
    'human_side': white,
  });
  return SettingsStore.load();
}

Future<SearchResult> _firstLegal(Position position) async =>
    _result(position.legalMoves().first);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('yangi o\'yin: 24 tosh, oq yuradi, navbat odamda', () async {
    final controller = GameController(
      searchMove: _firstLegal,
      settings: await _store(),
    );
    await controller.newGame();

    expect(controller.sprites.length, 24);
    expect(controller.humanSide, white);
    expect(controller.isHumanTurn, isTrue);
    expect(controller.winner, isNull);
    expect(controller.movableSquares, isNotEmpty);
    controller.dispose();
  });

  test('qora tanlansa AI birinchi yuradi', () async {
    final controller = GameController(
      searchMove: _firstLegal,
      settings: await _store(),
    );
    await controller.newGame(humanSide: black);

    expect(controller.humanSide, black);
    expect(controller.flipped, isTrue);
    expect(controller.ply, 1);
    expect(controller.isHumanTurn, isTrue);
    controller.dispose();
  });

  test('tanlash va yurish', () async {
    final controller = GameController(
      searchMove: _firstLegal,
      settings: await _store(),
    );
    await controller.newGame();

    final from = controller.movableSquares.first;
    await controller.tapSquare(from);
    expect(controller.selected, from);

    final to = controller.selectedTargets.first;
    await controller.tapSquare(to);

    expect(controller.lastFrom, isNotNull);
    expect(controller.ply, greaterThanOrEqualTo(2));
    expect(controller.readout, isNotNull);
    controller.dispose();
  });

  test('bo\'sh katakka bosilsa tanlov bekor qilinadi', () async {
    final controller = GameController(
      searchMove: _firstLegal,
      settings: await _store(),
    );
    await controller.newGame();

    final from = controller.movableSquares.first;
    await controller.tapSquare(from);
    expect(controller.selected, from);

    final empty = List<int>.generate(numSquares, (i) => i).firstWhere(
      (s) => !controller.movableSquares.contains(s),
    );
    await controller.tapSquare(empty);
    expect(controller.selected, isNull);
    controller.dispose();
  });

  test('AI noqonuniy yurish qaytarsa holat buzilmaydi', () async {
    var asked = 0;
    final controller = GameController(
      searchMove: (position) async {
        asked++;
        return _result(actionEncode(0, 31));
      },
      settings: await _store(),
    );
    await controller.newGame();
    final plyBefore = controller.ply;

    final from = controller.movableSquares.first;
    await controller.tapSquare(from);
    await controller.tapSquare(controller.selectedTargets.first);

    expect(asked, 1);
    expect(controller.error, isNotNull);
    expect(controller.ply, plyBefore + 1);
    expect(controller.phase, GamePhase.humanTurn);
    expect(controller.sprites.length, 24);
    controller.dispose();
  });

  test('AI xato tashlasa ilova yiqilmaydi', () async {
    final controller = GameController(
      searchMove: (position) async => throw const AiException('sinov xatosi'),
      settings: await _store(),
    );
    await controller.newGame();

    await controller.tapSquare(controller.movableSquares.first);
    await controller.tapSquare(controller.selectedTargets.first);

    expect(controller.error, 'sinov xatosi');
    expect(controller.phase, GamePhase.humanTurn);
    controller.dispose();
  });

  test('AI o\'ylayotganda yangi o\'yin boshlansa eski natija tashlanadi',
      () async {
    final gate = Completer<void>();
    var staleAction = 0;
    final controller = GameController(
      searchMove: (position) async {
        staleAction = position.legalMoves().first;
        await gate.future;
        return _result(staleAction);
      },
      settings: await _store(),
    );
    await controller.newGame();

    await controller.tapSquare(controller.movableSquares.first);
    final pending = controller.tapSquare(controller.selectedTargets.first);

    await controller.newGame();
    expect(controller.ply, 0);

    gate.complete();
    await pending;

    expect(controller.ply, 0, reason: 'eski AI yurishi qo\'llanmasligi kerak');
    expect(controller.sprites.length, 24);
    controller.dispose();
  });

  test('AI o\'ylayotganda dispose qilinsa xato chiqmaydi', () async {
    final gate = Completer<void>();
    final controller = GameController(
      searchMove: (position) async {
        await gate.future;
        return _result(position.legalMoves().first);
      },
      settings: await _store(),
    );
    await controller.newGame();

    await controller.tapSquare(controller.movableSquares.first);
    final pending = controller.tapSquare(controller.selectedTargets.first);

    controller.dispose();
    gate.complete();
    await expectLater(pending, completes);
  });

  test('AI navbatida bosish e\'tiborsiz qoldiriladi', () async {
    final gate = Completer<void>();
    final controller = GameController(
      searchMove: (position) async {
        await gate.future;
        return _result(position.legalMoves().first);
      },
      settings: await _store(),
    );
    await controller.newGame();

    await controller.tapSquare(controller.movableSquares.first);
    final pending = controller.tapSquare(controller.selectedTargets.first);

    for (var sq = 0; sq < numSquares; sq++) {
      await controller.tapSquare(sq);
    }
    expect(controller.selected, isNull);

    gate.complete();
    await pending;
    controller.dispose();
  });

  test('tez-tez bosish holatni buzmaydi', () async {
    final controller = GameController(
      searchMove: _firstLegal,
      settings: await _store(),
    );
    await controller.newGame();

    for (var round = 0; round < 40; round++) {
      for (var sq = 0; sq < numSquares; sq++) {
        await controller.tapSquare(sq);
      }
      if (controller.winner != null) break;
      final squares = controller.sprites.map((s) => s.square).toList();
      expect(squares.toSet().length, squares.length,
          reason: 'ikki tosh bitta katakda');
    }
    controller.dispose();
  });

  test('o\'yin tugaganda natija bir marta yoziladi', () async {
    final settings = await _store();
    final controller = GameController(
      searchMove: _firstLegal,
      settings: settings,
    );
    await controller.newGame();

    var guard = 0;
    while (controller.winner == null && guard++ < 400) {
      if (!controller.isHumanTurn || controller.movableSquares.isEmpty) break;
      await controller.tapSquare(controller.movableSquares.first);
      final targets = controller.selectedTargets;
      if (targets.isEmpty) break;
      await controller.tapSquare(targets.first);
    }

    expect(controller.winner, isNotNull);
    expect(controller.phase, GamePhase.finished);
    expect(settings.gamesPlayed, 1);
    expect(controller.hasUnseenResult, isTrue);

    controller.acknowledgeResult();
    expect(controller.hasUnseenResult, isFalse);
    expect(settings.gamesPlayed, 1, reason: 'natija takror yozilmasin');
    controller.dispose();
  });

  test('tugagan o\'yinda bosish hech narsa qilmaydi', () async {
    final controller = GameController(
      searchMove: _firstLegal,
      settings: await _store(),
    );
    await controller.newGame();
    var guard = 0;
    while (controller.winner == null && guard++ < 400) {
      if (!controller.isHumanTurn || controller.movableSquares.isEmpty) break;
      await controller.tapSquare(controller.movableSquares.first);
      final targets = controller.selectedTargets;
      if (targets.isEmpty) break;
      await controller.tapSquare(targets.first);
    }
    final plyAtEnd = controller.ply;
    for (var sq = 0; sq < numSquares; sq++) {
      await controller.tapSquare(sq);
    }
    expect(controller.ply, plyAtEnd);
    controller.dispose();
  });

  test('ketma-ket o\'yinlar statistikani to\'g\'ri sanaydi', () async {
    final settings = await _store();
    final controller = GameController(
      searchMove: _firstLegal,
      settings: settings,
    );

    for (var game = 0; game < 3; game++) {
      await controller.newGame();
      var guard = 0;
      while (controller.winner == null && guard++ < 400) {
        if (!controller.isHumanTurn || controller.movableSquares.isEmpty) break;
        await controller.tapSquare(controller.movableSquares.first);
        final targets = controller.selectedTargets;
        if (targets.isEmpty) break;
        await controller.tapSquare(targets.first);
      }
      expect(controller.winner, isNotNull, reason: 'o\'yin $game');
    }

    expect(settings.gamesPlayed, 3);
    controller.dispose();
  });
}
