library;

import 'package:flutter_test/flutter_test.dart';
import 'package:shashka/core/ai/evaluator.dart';
import 'package:shashka/core/ai/mcts.dart';
import 'package:shashka/core/engine/position.dart';

const int wm = 1;
const int wk = 2;
const int bm = -1;
const int bk = -2;

int sq(int r, int c) => rcSq[r * 8 + c];

Position setup(List<(int, int, int)> placements, {int side = white}) {
  final pieces = List<int>.filled(numSquares, 0);
  for (final (r, c, p) in placements) {
    pieces[sq(r, c)] = p;
  }
  return Position.fromBoard(pieces, side);
}

void main() {
  group('policy rejimi (sims = 0)', () {
    test('qonuniy yurish qaytaradi, bitta baholash', () {
      final evaluator = UniformEvaluator();
      final result = Mcts(evaluator).search(Position.initial(), sims: 0);

      expect(Position.initial().legalMoves(), contains(result.action));
      expect(result.sims, 0);
      expect(evaluator.evaluations, 1);
      expect(result.confidence, inInclusiveRange(0.0, 1.0));
    });

    test('yagona yurishda ishonch 1.0', () {
      final pos = setup([(4, 3, wm), (3, 2, bm), (6, 1, wm)]);
      expect(pos.legalMoves().length, 1);
      final result = Mcts(UniformEvaluator()).search(pos, sims: 0);
      expect(result.action, pos.legalMoves().single);
      expect(result.confidence, 1.0);
    });

    test('pozitsiyani o\'zgartirmaydi', () {
      final pos = Position.initial();
      final before = pos.toSnapshot();
      Mcts(UniformEvaluator()).search(pos, sims: 0);
      expect(pos.toSnapshot(), before);
    });

    test('butun partiya davomida hech qachon noqonuniy yurish bermaydi', () {
      final mcts = Mcts(UniformEvaluator());
      final pos = Position.initial();
      var plies = 0;
      while (plies < 400) {
        final status = pos.status();
        if (status.winner != null) break;
        final result = mcts.search(pos, sims: 0);
        expect(status.moves, contains(result.action), reason: 'ply $plies');
        pos.apply(result.action);
        plies++;
      }
      expect(pos.status().winner, isNotNull);
    });
  });

  group('qidiruv rejimi (sims > 0)', () {
    test('sims bajariladi va yurish qonuniy', () {
      final pos = Position.initial();
      final result = Mcts(UniformEvaluator()).search(pos, sims: 120);
      expect(pos.legalMoves(), contains(result.action));
      expect(result.sims, 120);
    });

    test('teng priorlarda tashriflar tarqaladi', () {
      final result =
          Mcts(UniformEvaluator()).search(Position.initial(), sims: 400);
      expect(result.confidence, lessThan(0.6));
    });

    test('bir yurishlik g\'alabani topadi', () {
      final pos = setup([(4, 3, wk), (3, 2, bm), (7, 0, wm), (6, 5, wm)]);
      final result = Mcts(UniformEvaluator()).search(pos, sims: 200);
      final after = pos.clone()..apply(result.action);
      expect(after.blackPieces, 0);
    });

    test('zanjir o\'rtasida ishlaydi', () {
      final pos = setup([(5, 2, wm), (4, 1, bm), (2, 1, bm)]);
      pos.apply(pos.legalMoves().single);
      expect(pos.chainSq, greaterThanOrEqualTo(0));
      final result = Mcts(UniformEvaluator()).search(pos, sims: 100);
      expect(pos.legalMoves(), contains(result.action));
    });

    test('yolg\'iz bolalar zanjirida barg ikki marta kengaymaydi', () {
      final pos = setup([(7, 0, wk), (2, 5, bk), (0, 1, bm), (1, 0, wm)]);
      final result = Mcts(UniformEvaluator()).search(pos, sims: 250);
      expect(pos.legalMoves(), contains(result.action));
      expect(result.value, inInclusiveRange(-1.0, 1.0));
    });

    test('determinik', () {
      final pos = Position.initial();
      final a = Mcts(UniformEvaluator()).search(pos, sims: 300);
      final b = Mcts(UniformEvaluator()).search(pos, sims: 300);
      expect(b.action, a.action);
      expect(b.confidence, a.confidence);
    });

    test('ikki tomon ham qidiruv bilan o\'ynab, o\'yin tugaydi', () {
      final mcts = Mcts(UniformEvaluator());
      final pos = Position.initial();
      var plies = 0;
      while (plies < 400) {
        final status = pos.status();
        if (status.winner != null) break;
        final result = mcts.search(pos, sims: 24);
        expect(status.moves, contains(result.action));
        pos.apply(result.action);
        plies++;
      }
      expect(pos.status().winner, isNotNull);
    });
  });

  group('chekka holatlar', () {
    test('terminal pozitsiyada xato beradi', () {
      final pos = setup([(1, 0, wm), (0, 1, bk)]);
      expect(pos.status().winner, black);
      expect(() => Mcts(UniformEvaluator()).search(pos), throwsStateError);
      expect(
        () => Mcts(UniformEvaluator()).search(pos, sims: 50),
        throwsStateError,
      );
    });

    test('durang holatida ham xato beradi', () {
      final pos = setup([(7, 0, wk), (0, 7, bk)]);
      const seq = [
        [7, 0, 6, 1],
        [0, 7, 1, 6],
        [6, 1, 7, 0],
        [1, 6, 0, 7],
      ];
      for (var round = 0; round < 2; round++) {
        for (final m in seq) {
          pos.apply(actionEncode(sq(m[0], m[1]), sq(m[2], m[3])));
        }
      }
      expect(pos.status().winner, 0);
      expect(() => Mcts(UniformEvaluator()).search(pos), throwsStateError);
    });

    test('manfiy sims policy rejimiga tushadi', () {
      final result =
          Mcts(UniformEvaluator()).search(Position.initial(), sims: -5);
      expect(result.sims, 0);
    });
  });
}
