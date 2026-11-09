library;

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shashka/core/ai/ai_service.dart';
import 'package:shashka/core/ai/model_loader.dart';
import 'package:shashka/core/engine/position.dart';

import 'ai_golden_data.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AiService ai;
  late Map<String, dynamic> golden;

  setUpAll(() async {
    ai = await AiService.start(await loadEncryptedModel());
    golden = jsonDecode(aiGoldenJson) as Map<String, dynamic>;
  });

  tearDownAll(() => ai.dispose());

  testWidgets('ilovadagi AI asl Python modeli bilan bir xil yuradi',
      (tester) async {
    final meta = golden['meta'] as Map<String, dynamic>;
    final cases = (golden['cases'] as List<dynamic>).cast<Map<String, dynamic>>();

    var matched = 0;
    var chained = 0;
    var maxConfidenceDelta = 0.0;
    var maxValueDelta = 0.0;
    final mismatches = <String>[];

    for (var i = 0; i < cases.length; i++) {
      final item = cases[i];
      final position = Position.initial();
      for (final action in (item['actions'] as List<dynamic>).cast<int>()) {
        position.apply(action);
      }

      expect(position.player, item['player'], reason: 'holat $i: navbat');
      expect(position.chainSq, item['chain'], reason: 'holat $i: zanjir');
      if (position.chainSq >= 0) chained++;

      final result = await ai.search(position);

      final expectedAction = item['action'] as int;
      final confidenceDelta =
          (result.confidence - (item['confidence'] as num)).abs();
      final valueDelta = (result.value - (item['value'] as num)).abs();
      if (confidenceDelta > maxConfidenceDelta) {
        maxConfidenceDelta = confidenceDelta;
      }
      if (valueDelta > maxValueDelta) maxValueDelta = valueDelta;

      if (result.action == expectedAction) {
        matched++;
      } else {
        mismatches.add(
          'holat $i: kutilgan ${actionName(expectedAction)}, '
          'olingan ${actionName(result.action)} '
          '(margin ${(item['margin'] as num).toStringAsFixed(5)})',
        );
      }

      expect(confidenceDelta, lessThan(0.02), reason: 'holat $i: ishonch');
      expect(valueDelta, lessThan(0.02), reason: 'holat $i: baho');
    }

    // ignore: avoid_print
    print('parity: ${cases.length} holat · mos=$matched '
        '(${(matched / cases.length * 100).toStringAsFixed(1)}%) · '
        'zanjirli=$chained · '
        'ishonch farqi <= ${maxConfidenceDelta.toStringAsExponential(2)} · '
        'baho farqi <= ${maxValueDelta.toStringAsExponential(2)} · '
        'manba ${meta['source']}');
    for (final line in mismatches) {
      // ignore: avoid_print
      print('  FARQ $line');
    }

    expect(mismatches, isEmpty,
        reason: 'ilova asl modeldan boshqa yurish tanladi');
  });
}
