/// Rus shashkasi qoidalari testlari — asl loyihadagi
/// `shashka_ai/test_engine.py` dan portlangan.
library;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:shashka/core/engine/position.dart';

const int wm = 1;
const int wk = 2;
const int bm = -1;
const int bk = -2;

/// `(row, col)` dan katak indeksi.
int sq(int r, int c) {
  final s = rcSq[r * 8 + c];
  expect(s, greaterThanOrEqualTo(0), reason: '($r,$c) qora katak emas');
  return s;
}

/// Bo'sh doskaga belgilangan shashkalarni joylab pozitsiya yasaydi.
/// [placements] elementlari: `(row, col, piece)`.
Position setup(List<(int, int, int)> placements, {int side = white}) {
  final pieces = List<int>.filled(numSquares, 0);
  for (final (r, c, p) in placements) {
    pieces[sq(r, c)] = p;
  }
  return Position.fromBoard(pieces, side);
}

/// Qonuniy yurishlarni `(from, to)` juftliklar to'plamiga aylantiradi.
Set<(int, int)> pairs(List<int> moves) =>
    moves.map((a) => (actionFrom(a), actionTo(a))).toSet();

int countPieces(Position p, {required bool forWhite}) =>
    _bitCount(forWhite ? p.whitePieces : p.blackPieces);

int _bitCount(int x) {
  var n = 0;
  var v = x;
  while (v != 0) {
    v &= v - 1;
    n++;
  }
  return n;
}

void main() {
  test('boshlang\'ich pozitsiya: 12+12 shashka, 7 yurish, oq yuradi', () {
    final p = Position.initial();
    expect(countPieces(p, forWhite: true), 12);
    expect(countPieces(p, forWhite: false), 12);
    expect(p.legalMoves().length, 7);
    expect(p.player, white);
    expect(p.kings, 0);
  });

  test('urish majburiy — tinch yurishlar chiqarib tashlanadi', () {
    final p = setup([(4, 3, wm), (3, 2, bm), (6, 1, wm)]);
    expect(pairs(p.legalMoves()), {(sq(4, 3), sq(2, 1))});
  });

  test('oddiy shashka orqaga ham uradi', () {
    final p = setup([(3, 2, bm), (2, 1, wm)], side: black);
    expect(pairs(p.legalMoves()), contains((sq(3, 2), sq(1, 0))));
  });

  test('zanjirli urish: urilganlar zanjir tugaguncha doskada qoladi', () {
    final p = setup([(5, 2, wm), (4, 1, bm), (2, 1, bm)]);
    expect(pairs(p.legalMoves()), {(sq(5, 2), sq(3, 0))});

    p.apply(actionEncode(sq(5, 2), sq(3, 0)));
    expect(p.player, white, reason: 'zanjirda navbat o\'zgarmaydi');
    expect(p.chainSq, sq(3, 0));
    expect(p.pieceAt(sq(4, 1)), bm, reason: 'urilgan hali olinmaydi');
    expect(pairs(p.legalMoves()), {(sq(3, 0), sq(1, 2))});

    p.apply(actionEncode(sq(3, 0), sq(1, 2)));
    expect(p.player, black);
    expect(p.chainSq, -1);
    expect(p.pieceAt(sq(4, 1)), 0);
    expect(p.pieceAt(sq(2, 1)), 0);
    expect(p.pieceAt(sq(1, 2)), wm);
  });

  test('damka (flying king) uzoq masofaga yuradi', () {
    final p = setup([(7, 0, wk), (0, 7, bm)]);
    expect(p.legalMoves().length, 6);
  });

  test('damka urishida tushish-cheklovi qo\'llanadi', () {
    final p = setup([(7, 0, wk), (4, 3, bm), (1, 4, bm)]);
    expect(pairs(p.legalMoves()), {(sq(7, 0), sq(2, 5))});

    p.apply(actionEncode(sq(7, 0), sq(2, 5)));
    expect(p.chainSq, sq(2, 5));
    expect(p.player, white);
    expect(pairs(p.legalMoves()), {(sq(2, 5), sq(0, 3))});

    p.apply(actionEncode(sq(2, 5), sq(0, 3)));
    expect(p.player, black);
    expect(countPieces(p, forWhite: false), 0);
  });

  test('turk zarbasi: urilgan shashka qayta urilmaydi', () {
    final p = setup([(4, 3, wk), (3, 2, bm)]);
    final segs = p.capturesFrom(
      sq(4, 3),
      true,
      true,
      1 << sq(3, 2),
    );
    expect(segs, isEmpty);
  });

  test('zanjir ichida damkaga aylanib, damka sifatida davom etadi', () {
    final p = setup([(2, 1, wm), (1, 2, bm), (2, 5, bm)]);
    expect(pairs(p.legalMoves()), {(sq(2, 1), sq(0, 3))});

    p.apply(actionEncode(sq(2, 1), sq(0, 3)));
    expect(p.pieceAt(sq(0, 3)), wk, reason: 'darhol damka');
    expect(p.chainSq, sq(0, 3));
    expect(p.player, white);
    expect(pairs(p.legalMoves()), {
      (sq(0, 3), sq(3, 6)),
      (sq(0, 3), sq(4, 7)),
    });

    p.apply(actionEncode(sq(0, 3), sq(3, 6)));
    expect(p.player, black);
    expect(countPieces(p, forWhite: false), 0);
    expect(p.pieceAt(sq(3, 6)), wk);
  });

  test('tinch yurishda oxirgi qatorga yetsa damka bo\'ladi', () {
    final p = setup([(1, 2, wm), (7, 6, bk)]);
    p.apply(actionEncode(sq(1, 2), sq(0, 1)));
    expect(p.pieceAt(sq(0, 1)), wk);
  });

  test('yura olmagan o\'yinchi yutqazadi', () {
    final p = setup([(1, 0, wm), (0, 1, bk)]);
    expect(p.status().winner, black);
  });

  test('3 marta takror — durang', () {
    final p = setup([(7, 0, wk), (0, 7, bk)]);
    const seq = [
      [7, 0, 6, 1],
      [0, 7, 1, 6],
      [6, 1, 7, 0],
      [1, 6, 0, 7],
    ];
    for (var round = 0; round < 2; round++) {
      for (final m in seq) {
        expect(p.status().winner, isNull);
        p.apply(actionEncode(sq(m[0], m[1]), sq(m[2], m[3])));
      }
    }
    expect(p.status().winner, 0);
  });

  test('ketma-ket bo\'lmagan 3-takror ham durang', () {
    final p = setup([(7, 0, wk), (4, 7, bk)]);
    const seq = [
      [7, 0, 6, 1],
      [4, 7, 5, 6],
      [6, 1, 7, 0],
      [5, 6, 4, 7],
      [7, 0, 6, 1],
      [4, 7, 3, 6],
      [6, 1, 7, 0],
      [3, 6, 4, 7],
    ];
    for (final m in seq) {
      expect(p.status().winner, isNull);
      p.apply(actionEncode(sq(m[0], m[1]), sq(m[2], m[3])));
    }
    expect(p.status().winner, 0);
  });

  test('damkaning tinch yurishi progress hisoblagichini oshiradi', () {
    final p = setup([(7, 0, wk), (4, 7, bk)]);
    p.apply(actionEncode(sq(7, 0), sq(6, 1)));
    expect(p.halfmove, 1);
    p.apply(actionEncode(sq(4, 7), sq(5, 6)));
    expect(p.halfmove, 2);
  });

  test('damka yonma-yon turgan ikki shashka ustidan sakramaydi', () {
    final p = setup([(7, 0, wk), (5, 2, bm), (4, 3, bm)]);
    expect(p.capturesFrom(sq(7, 0), true, true, 0), isEmpty);
    final targets = p
        .legalMoves()
        .where((a) => actionFrom(a) == sq(7, 0))
        .map(actionTo)
        .toSet();
    expect(targets, isNot(contains(sq(4, 3))));
    expect(targets, isNot(contains(sq(3, 4))));
  });

  test('encode: kanonik, 12 ta "mening shashkam"', () {
    final p = Position.initial();
    final x = Float32List(inputSize);
    p.encode(x);
    var mine = 0;
    for (var s = 0; s < numSquares; s++) {
      mine += x[s * 6].toInt();
    }
    expect(mine, 12);
    expect(x[192], 0);
    expect(x[193], 0);

    // Qora yursa ham o'z shashkalari 0-kanalda bo'ladi.
    final p2 = Position.initial();
    p2.apply(p2.legalMoves().first);
    p2.encode(x);
    mine = 0;
    for (var s = 0; s < numSquares; s++) {
      mine += x[s * 6].toInt();
    }
    expect(mine, 12);
  });

  test('canonAction ikki marta qo\'llansa o\'zgarmaydi', () {
    final p = Position.fromBoard(List<int>.filled(numSquares, 0), black);
    for (final a in [0, 5 * 32 + 7, 1023]) {
      expect(p.canonAction(p.canonAction(a)), a);
    }
  });

  test('clone mustaqil', () {
    final p = Position.initial();
    final c = p.clone();
    c.apply(c.legalMoves().first);
    expect(p.ply, 0);
    expect(c.ply, 1);
    expect(p.whitePieces == c.whitePieces, isFalse);
  });
}
