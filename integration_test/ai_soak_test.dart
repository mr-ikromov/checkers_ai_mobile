library;

import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shashka/core/ai/ai_service.dart';
import 'package:shashka/core/ai/model_loader.dart';
import 'package:shashka/core/engine/position.dart';

const int _games = 120;
const int _maxPlies = 400;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AiService ai;

  setUpAll(() async {
    ai = await AiService.start(await loadEncryptedModel());
  });

  tearDownAll(() => ai.dispose());

  testWidgets('shifrlangan model ochiladi va sessiya ishlaydi',
      (tester) async {
    final result = await ai.search(Position.initial());
    expect(Position.initial().legalMoves(), contains(result.action));
    expect(result.confidence, inInclusiveRange(0.0, 1.0));
    expect(result.value, inInclusiveRange(-1.0, 1.0));
  });

  testWidgets('buzilgan paket ochilmaydi', (tester) async {
    final packed = await loadEncryptedModel();

    final shortened = packed.sublist(0, 20);
    expect(() => decryptModel(shortened), throwsA(isA<ModelLoadException>()));

    final badMagic = Uint8List.fromList(packed)..[0] = 0x00;
    expect(() => decryptModel(badMagic), throwsA(isA<ModelLoadException>()));

    final tampered = Uint8List.fromList(packed);
    tampered[tampered.length - 1] ^= 0xFF;
    expect(() => decryptModel(tampered), throwsA(isA<ModelLoadException>()));
  });

  testWidgets('$_games xilma-xil o\'yin: AI noqonuniy yurish bermaydi',
      (tester) async {
    final rng = Random(31337111);
    final results = <int, int>{1: 0, -1: 0, 0: 0};
    final lengths = <int>{};
    var totalPlies = 0;
    var totalMicros = 0;
    var slowest = 0;
    var chainSegments = 0;
    var promotions = 0;
    var aiPlies = 0;

    for (var game = 0; game < _games; game++) {
      final position = Position.initial();

      final opening = 2 + rng.nextInt(9);
      for (var i = 0; i < opening; i++) {
        final status = position.status();
        if (status.winner != null) break;
        position.apply(status.moves[rng.nextInt(status.moves.length)]);
      }

      var plies = 0;
      var kingsSeen = _countKings(position);

      while (plies < _maxPlies) {
        final status = position.status();
        if (status.winner != null) {
          results[status.winner!] = results[status.winner!]! + 1;
          break;
        }

        if (position.chainSq >= 0) chainSegments++;

        final before = position.toSnapshot();
        final result = await ai.search(position);

        expect(
          status.moves,
          contains(result.action),
          reason: 'o\'yin $game, ply $plies: noqonuniy yurish '
              '${actionName(result.action)}',
        );
        expect(result.confidence, inInclusiveRange(0.0, 1.0));
        expect(result.value, inInclusiveRange(-1.0, 1.0));
        expect(result.value.isNaN, isFalse);
        expect(position.toSnapshot(), before,
            reason: 'qidiruv pozitsiyani o\'zgartirdi');

        totalMicros += result.elapsedMicros;
        aiPlies++;
        if (result.elapsedMicros > slowest) slowest = result.elapsedMicros;

        position.apply(result.action);
        plies++;
        totalPlies++;

        final kings = _countKings(position);
        if (kings > kingsSeen) {
          promotions += kings - kingsSeen;
          kingsSeen = kings;
        }
      }

      expect(plies, lessThan(_maxPlies), reason: 'o\'yin $game tugamadi');
      expect(position.chainSq, -1, reason: 'o\'yin zanjir o\'rtasida tugadi');
      lengths.add(position.ply);
    }

    print('soak: $_games o\'yin, $totalPlies AI yurishi · '
        'oq=${results[1]} qora=${results[-1]} durang=${results[0]} · '
        'turli uzunliklar=${lengths.length} · '
        'zanjir=$chainSegments damka=$promotions · '
        'o\'rtacha ${(totalMicros / aiPlies / 1000).toStringAsFixed(1)} ms, '
        'eng sekin ${(slowest / 1000).toStringAsFixed(1)} ms');

    expect(totalPlies, greaterThan(_games * 5));
    expect(chainSegments, greaterThan(0), reason: 'zanjir sinalmadi');
    expect(promotions, greaterThan(0), reason: 'damka sinalmadi');
    expect(slowest / 1000, lessThan(2000), reason: 'yurish juda sekin');
    expect(lengths.length, greaterThan(_games ~/ 3),
        reason: 'o\'yinlar bir-birini takrorlayapti — qamrov yetarli emas');
    expect(results.values.where((v) => v > 0).length, greaterThan(1),
        reason: 'barcha o\'yinlar bir xil natija bilan tugadi');
  });

  testWidgets('bir xil pozitsiya — bir xil yurish', (tester) async {
    final position = Position.initial();
    final first = await ai.search(position);
    for (var i = 0; i < 10; i++) {
      final again = await ai.search(position);
      expect(again.action, first.action);
      expect(again.confidence, closeTo(first.confidence, 1e-6));
      expect(again.value, closeTo(first.value, 1e-6));
    }
  });

  testWidgets('bir vaqtda yuborilgan so\'rovlar aralashmaydi', (tester) async {
    final a = Position.initial();
    final b = Position.initial()..apply(Position.initial().legalMoves().first);

    final expectedA = await ai.search(a);
    final expectedB = await ai.search(b);

    for (var round = 0; round < 5; round++) {
      final results = await Future.wait([
        ai.search(a),
        ai.search(b),
        ai.search(a),
        ai.search(b),
      ]);
      expect(results[0].action, expectedA.action);
      expect(results[1].action, expectedB.action);
      expect(results[2].action, expectedA.action);
      expect(results[3].action, expectedB.action);
    }
  });

  testWidgets('tugagan pozitsiyada xato qaytaradi, sessiya tirik qoladi',
      (tester) async {
    final finished = Position.fromBoard(
      List<int>.filled(numSquares, 0)
        ..[rcSq[1 * 8 + 0]] = 1
        ..[rcSq[0 * 8 + 1]] = -2,
      white,
    );
    expect(finished.status().winner, black);

    await expectLater(
      ai.search(finished),
      throwsA(isA<AiException>()),
    );

    final healthy = await ai.search(Position.initial());
    expect(Position.initial().legalMoves(), contains(healthy.action));
  });

  testWidgets('sessiyani qayta ishga tushirish', (tester) async {
    final second = await AiService.start(await loadEncryptedModel());
    final result = await second.search(Position.initial());
    expect(Position.initial().legalMoves(), contains(result.action));
    second.dispose();

    expect(
      () => second.search(Position.initial()),
      throwsStateError,
    );

    final still = await ai.search(Position.initial());
    expect(Position.initial().legalMoves(), contains(still.action));
  });

  testWidgets('zanjirli pozitsiyalarda ham qonuniy yuradi', (tester) async {
    final board = List<int>.filled(numSquares, 0)
      ..[rcSq[5 * 8 + 2]] = 1
      ..[rcSq[4 * 8 + 1]] = -1
      ..[rcSq[2 * 8 + 1]] = -1
      ..[rcSq[7 * 8 + 6]] = -2;
    final position = Position.fromBoard(board, white);

    var guard = 0;
    while (position.status().winner == null && guard++ < 200) {
      final moves = position.status().moves;
      final result = await ai.search(position);
      expect(moves, contains(result.action), reason: 'qadam $guard');
      position.apply(result.action);
    }
    expect(position.status().winner, isNotNull);
  });
}

int _countKings(Position position) {
  var kings = 0;
  for (var sq = 0; sq < numSquares; sq++) {
    if (position.pieceAt(sq).abs() == 2) kings++;
  }
  return kings;
}
