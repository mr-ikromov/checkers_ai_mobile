library;
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:shashka/core/engine/position.dart';

int piecesBetween(Position p, int from, int to) {
  final fr = sqRow[from];
  final fc = sqCol[from];
  final tr = sqRow[to];
  final tc = sqCol[to];
  final dr = tr.compareTo(fr);
  final dc = tc.compareTo(fc);
  var r = fr + dr;
  var c = fc + dc;
  var count = 0;
  while (r != tr || c != tc) {
    if (p.pieceAt(rcSq[r * 8 + c]) != 0) count++;
    r += dr;
    c += dc;
  }
  return count;
}

int totalPieces(Position p) {
  var n = 0;
  var occ = p.occupied;
  while (occ != 0) {
    occ &= occ - 1;
    n++;
  }
  return n;
}

void main() {
  test('500 tasodifiy o\'yin: invariantlar buzilmaydi va o\'yin tugaydi', () {
    const games = 500;
    final rng = Random(20260610);
    final results = <int, int>{1: 0, -1: 0, 0: 0};
    var totalPlies = 0;

    for (var g = 0; g < games; g++) {
      final pos = Position.initial();
      var prevTotal = 24;
      var guard = 0;

      while (true) {
        final status = pos.status();
        if (status.winner != null) {
          results[status.winner!] = results[status.winner!]! + 1;
          expect(pos.chainSq, -1,
              reason: 'o\'yin zanjir o\'rtasida tugamasligi kerak');
          break;
        }
        final moves = status.moves;
        expect(moves, isNotEmpty);

        final captureFlags =
            moves.map((a) => piecesBetween(pos, actionFrom(a), actionTo(a)) > 0);
        expect(
          captureFlags.every((x) => x) || captureFlags.every((x) => !x),
          isTrue,
          reason: 'urish va tinch yurishlar aralashdi (majburiylik buzildi)',
        );

        if (pos.chainSq >= 0) {
          expect(moves.every((a) => actionFrom(a) == pos.chainSq), isTrue,
              reason: 'zanjirda faqat zanjir katagidan yuriladi');
          expect(captureFlags.every((x) => x), isTrue,
              reason: 'zanjirda faqat urish bo\'ladi');
        }

        for (final a in moves) {
          expect(piecesBetween(pos, actionFrom(a), actionTo(a)),
              lessThanOrEqualTo(1),
              reason: 'bitta segmentda 2+ shashka urilmoqda: ${actionName(a)}');
        }

        pos.apply(moves[rng.nextInt(moves.length)]);
        totalPlies++;

        final total = totalPieces(pos);
        expect(total, lessThanOrEqualTo(prevTotal),
            reason: 'shashka soni oshib ketdi');
        if (pos.chainSq < 0) prevTotal = total;

        guard++;
        expect(guard, lessThan(2000), reason: 'o\'yin tugamadi');
      }
    }

    expect(results.values.reduce((a, b) => a + b), games);
    expect(totalPlies, greaterThan(games * 10));

    print('  fuzzing ($games o\'yin, $totalPlies yarim-yurish): '
        'oq=${results[1]} qora=${results[-1]} durang=${results[0]}');
  });
}
