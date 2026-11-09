/// Differential test: Dart dvigateli asl Python etaloniga bit-darajada mos.
///
/// `test/golden/engine_golden.json` ni `tool/gen_engine_golden.py` yaratadi —
/// u `shashka_ai/checkers_engine.py` (10 000 o'yinlik fuzzing'dan o'tgan
/// etalon) bilan 60 ta determinik o'yin o'ynab, har yarim-yurishda to'liq
/// holatni yozadi. Bu test aynan shu harakatlarni Dart dvigatelida
/// takrorlab, har bir maydonni solishtiradi.
library;
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:shashka/core/engine/position.dart';

const Map<int, String> _symbols = {
  0: '.',
  1: 'w',
  2: 'W',
  -1: 'b',
  -2: 'B',
};

String boardString(Position p) {
  final sb = StringBuffer();
  for (var sq = 0; sq < numSquares; sq++) {
    sb.write(_symbols[p.pieceAt(sq)]);
  }
  return sb.toString();
}

List<int> capturedList(Position p) {
  final out = <int>[];
  for (var sq = 0; sq < numSquares; sq++) {
    if (p.captured & (1 << sq) != 0) out.add(sq);
  }
  return out;
}

/// Siyrak yozilgan `encode` ni to'liq vektorga ochadi.
Float32List expandEncode(List<dynamic> sparse) {
  final out = Float32List(inputSize);
  for (var i = 0; i < sparse.length; i += 2) {
    out[(sparse[i] as num).toInt()] = (sparse[i + 1] as num).toDouble();
  }
  return out;
}

void main() {
  final file = File('test/golden/engine_golden.json');
  final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final meta = data['meta'] as Map<String, dynamic>;
  final games = (data['games'] as List<dynamic>).cast<Map<String, dynamic>>();

  test('golden fayl kutilgan hajmda', () {
    expect(meta['num_squares'], numSquares);
    expect(games.length, greaterThanOrEqualTo(50));
    expect(meta['plies'], greaterThan(1000));
  });

  test('${games.length} o\'yin, ${meta['plies']} holat — Python etaloniga mos',
      () {
    final encoded = Float32List(inputSize);
    var checkedPlies = 0;

    for (final game in games) {
      final actions = (game['actions'] as List<dynamic>).cast<int>();
      final plies = (game['plies'] as List<dynamic>).cast<Map<String, dynamic>>();
      final seed = game['seed'];
      final pos = Position.initial();

      for (var i = 0; i < plies.length; i++) {
        final want = plies[i];
        final where = 'seed=$seed ply=$i';

        expect(boardString(pos), want['board'], reason: 'doska · $where');
        expect(pos.player, want['player'], reason: 'navbat · $where');
        expect(pos.chainSq, want['chain'], reason: 'zanjir · $where');
        expect(capturedList(pos), want['captured'],
            reason: 'urilganlar · $where');
        expect(pos.halfmove, want['halfmove'], reason: 'halfmove · $where');
        expect(pos.ply, want['ply'], reason: 'ply · $where');

        final status = pos.status();
        expect(status.winner, want['winner'], reason: 'natija · $where');
        expect(status.moves, (want['moves'] as List<dynamic>).cast<int>(),
            reason: 'yurishlar (tartibi ham) · $where');

        pos.encode(encoded);
        expect(encoded, expandEncode(want['encode'] as List<dynamic>),
            reason: 'encode · $where');

        checkedPlies++;
        if (i < actions.length) pos.apply(actions[i]);
      }
    }

    expect(checkedPlies, meta['plies']);
  });
}
