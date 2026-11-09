library;

import 'dart:math';
import 'dart:typed_data';

import '../engine/position.dart';
import 'ai_config.dart';
import 'evaluator.dart';

class SearchResult {
  const SearchResult({
    required this.action,
    required this.confidence,
    required this.value,
    required this.sims,
    required this.elapsedMicros,
  });

  final int action;
  final double confidence;
  final double value;
  final int sims;
  final int elapsedMicros;

  int get elapsedMs => elapsedMicros ~/ 1000;
}

class _Node {
  _Node(this.prior);

  final double prior;

  int player = 0;
  int n = 0;
  double w = 0;
  int vloss = 0;
  bool expanded = false;
  double? terminal;
  bool pendingEval = false;

  List<int> childActions = const <int>[];
  List<_Node> children = const <_Node>[];
}

class Mcts {
  Mcts(this._evaluator, {this.cPuct = AiConfig.cPuct});

  final Evaluator _evaluator;
  final double cPuct;

  SearchResult search(Position root, {int sims = AiConfig.sims}) {
    final sw = Stopwatch()..start();
    final status = root.status();
    if (status.winner != null || status.moves.isEmpty) {
      throw StateError('Qonuniy harakat yo\'q');
    }
    if (status.moves.length == 1 || sims <= 0) {
      return _policyMove(root, status.moves, sw);
    }

    final rootNode = _Node(1.0);
    root.encode(_evaluator.input);
    _evaluator.run(1);
    _expandWithEval(rootNode, root, status.moves, 0);
    rootNode.n += 1;
    rootNode.w += _evaluator.values[0];

    final batchPaths = <List<_Node>>[];
    final batchLeaves = <_Node>[];
    final batchStates = <Position>[];
    var done = 0;

    while (done < sims) {
      batchPaths.clear();
      batchLeaves.clear();
      batchStates.clear();

      while (batchLeaves.length < _evaluator.maxBatch &&
          batchLeaves.length < AiConfig.leafBatch &&
          done + batchLeaves.length < sims) {
        final path = <_Node>[];
        final state = root.clone();
        final leaf = _collect(rootNode, state, path);

        if (leaf.terminal != null) {
          _backprop(path, leaf.player, leaf.terminal!);
          done++;
          continue;
        }

        final leafStatus = state.status();
        if (leafStatus.winner != null) {
          leaf.player = state.player;
          leaf.terminal = leafStatus.winner == 0
              ? 0.0
              : (leafStatus.winner == state.player ? 1.0 : -1.0);
          _backprop(path, leaf.player, leaf.terminal!);
          done++;
          continue;
        }

        if (leaf.pendingEval) {
          _revertVirtual(path);
          break;
        }

        leaf.pendingEval = true;
        leaf.childActions = leafStatus.moves;
        state.encode(_evaluator.input, batchLeaves.length * inputSize);
        batchPaths.add(path);
        batchLeaves.add(leaf);
        batchStates.add(state);
      }

      if (batchLeaves.isEmpty) break;

      _evaluator.run(batchLeaves.length);
      for (var i = 0; i < batchLeaves.length; i++) {
        final leaf = batchLeaves[i];
        leaf.pendingEval = false;
        _expandWithEval(leaf, batchStates[i], leaf.childActions, i);
        _backprop(batchPaths[i], leaf.player, _evaluator.values[i]);
        done++;
      }
    }

    var bestIndex = 0;
    var bestVisits = -1;
    var totalVisits = 0;
    for (var i = 0; i < rootNode.children.length; i++) {
      final visits = rootNode.children[i].n;
      totalVisits += visits;
      if (visits > bestVisits) {
        bestVisits = visits;
        bestIndex = i;
      }
    }

    sw.stop();
    return SearchResult(
      action: rootNode.childActions[bestIndex],
      confidence: totalVisits > 0 ? bestVisits / totalVisits : 0,
      value: rootNode.n > 0 ? rootNode.w / rootNode.n : 0,
      sims: done,
      elapsedMicros: sw.elapsedMicroseconds,
    );
  }

  SearchResult _policyMove(Position root, List<int> moves, Stopwatch sw) {
    root.encode(_evaluator.input);
    _evaluator.run(1);
    final value = _evaluator.values[0];

    var bestIndex = 0;
    var confidence = 1.0;
    if (moves.length > 1) {
      var mx = double.negativeInfinity;
      final exps = Float64List(moves.length);
      for (var i = 0; i < moves.length; i++) {
        final logit = _evaluator.policyLogits[root.canonAction(moves[i])];
        exps[i] = logit;
        if (logit > mx) mx = logit;
      }
      var sum = 0.0;
      for (var i = 0; i < moves.length; i++) {
        exps[i] = exp(exps[i] - mx);
        sum += exps[i];
      }
      var bestP = double.negativeInfinity;
      for (var i = 0; i < moves.length; i++) {
        if (exps[i] > bestP) {
          bestP = exps[i];
          bestIndex = i;
        }
      }
      confidence = sum > 0 ? bestP / sum : 0;
    }

    sw.stop();
    return SearchResult(
      action: moves[bestIndex],
      confidence: confidence,
      value: value,
      sims: 0,
      elapsedMicros: sw.elapsedMicroseconds,
    );
  }

  _Node _collect(_Node root, Position state, List<_Node> path) {
    var node = root;
    path.add(node);
    node.vloss++;
    while (node.expanded && node.terminal == null) {
      final index = _bestChildIndex(node);
      state.apply(node.childActions[index]);
      node = node.children[index];
      path.add(node);
      node.vloss++;
    }
    return node;
  }

  int _bestChildIndex(_Node node) {
    final sqrtN = sqrt(node.n + node.vloss + 1);
    var bestIndex = 0;
    var bestScore = double.negativeInfinity;
    final children = node.children;
    for (var i = 0; i < children.length; i++) {
      final child = children[i];
      final nv = child.n + child.vloss;
      double q;
      if (nv > 0) {
        final wSigned = child.player == node.player ? child.w : -child.w;
        q = (wSigned - child.vloss) / nv;
      } else {
        q = 0;
      }
      final score = q + cPuct * child.prior * sqrtN / (1 + nv);
      if (score > bestScore) {
        bestScore = score;
        bestIndex = i;
      }
    }
    return bestIndex;
  }

  void _expandWithEval(
    _Node leaf,
    Position state,
    List<int> moves,
    int batchIndex,
  ) {
    final count = moves.length;
    final policy = _evaluator.policyLogits;
    final base = batchIndex * actionSize;
    final priors = Float64List(count);
    var mx = double.negativeInfinity;
    for (var i = 0; i < count; i++) {
      final logit = policy[base + state.canonAction(moves[i])];
      priors[i] = logit;
      if (logit > mx) mx = logit;
    }
    var sum = 0.0;
    for (var i = 0; i < count; i++) {
      priors[i] = exp(priors[i] - mx);
      sum += priors[i];
    }
    leaf.children = List<_Node>.generate(
      count,
      (i) => _Node(sum > 0 ? priors[i] / sum : 1.0 / count),
      growable: false,
    );
    leaf.childActions = moves;
    leaf.expanded = true;
    leaf.player = state.player;
  }

  void _backprop(List<_Node> path, int leafPlayer, double value) {
    for (var i = 0; i < path.length; i++) {
      final node = path[i];
      node.vloss--;
      node.n++;
      node.w += node.player == leafPlayer ? value : -value;
    }
  }

  void _revertVirtual(List<_Node> path) {
    for (var i = 0; i < path.length; i++) {
      path[i].vloss--;
    }
  }
}
