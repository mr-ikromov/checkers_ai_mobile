library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shashka/features/game/game_controller.dart';
import 'package:shashka/features/game/widgets/stats_panel.dart';
import 'package:shashka/l10n/app_localizations.dart';
import 'package:shashka/ui/theme/app_theme.dart';

Future<void> _pumpPanel(WidgetTester tester, AiReadout? readout) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: buildAppTheme(Brightness.dark),
      localizationsDelegates: L10n.localizationsDelegates,
      supportedLocales: L10n.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(body: StatsPanel(readout: readout)),
    ),
  );
  await tester.pumpAndSettle();
}

AiReadout _readout({
  double evaluation = 0,
  double confidence = 0.5,
  int elapsedMs = 12,
}) =>
    AiReadout(
      evaluation: evaluation,
      confidence: confidence,
      elapsedMs: elapsedMs,
    );

void main() {
  testWidgets('yurish bo\'lmaganda ikkala ko\'rsatkich ham chiziqcha',
      (tester) async {
    await _pumpPanel(tester, null);

    expect(find.text('EVALUATION'), findsOneWidget);
    expect(find.text('CONFIDENCE'), findsOneWidget);
    expect(find.text('—'), findsNWidgets(2));
  });

  testWidgets('vaqt ko\'rsatkichi umuman yo\'q', (tester) async {
    await _pumpPanel(tester, _readout(elapsedMs: 1234));

    expect(find.textContaining('ms'), findsNothing);
    expect(find.textContaining('TIME'), findsNothing);
    expect(find.textContaining('1234'), findsNothing);
  });

  testWidgets('musbat baho ortiqcha belgisi bilan', (tester) async {
    await _pumpPanel(tester, _readout(evaluation: 0.734));
    expect(find.text('+0.73'), findsOneWidget);
  });

  testWidgets('manfiy baho minus belgisi bilan', (tester) async {
    await _pumpPanel(tester, _readout(evaluation: -0.885));
    expect(find.text('−0.89'), findsOneWidget);
  });

  testWidgets('nol bahoda belgi qo\'yilmaydi', (tester) async {
    await _pumpPanel(tester, _readout(evaluation: 0));
    expect(find.text('0.00'), findsOneWidget);
    expect(find.text('+0.00'), findsNothing);
    expect(find.text('−0.00'), findsNothing);
  });

  testWidgets('juda kichik manfiy qiymat ham "0.00" bo\'ladi', (tester) async {
    await _pumpPanel(tester, _readout(evaluation: -0.0001));
    expect(find.text('0.00'), findsOneWidget);
  });

  testWidgets('chegaradan tashqari qiymatlar qisiladi', (tester) async {
    await _pumpPanel(tester, _readout(evaluation: 7.5));
    expect(find.text('+1.00'), findsOneWidget);

    await _pumpPanel(tester, _readout(evaluation: -7.5));
    expect(find.text('−1.00'), findsOneWidget);
  });

  testWidgets('ishonch foizga aylanadi', (tester) async {
    await _pumpPanel(tester, _readout(confidence: 0.564));
    expect(find.text('56%'), findsOneWidget);

    await _pumpPanel(tester, _readout(confidence: 1));
    expect(find.text('100%'), findsOneWidget);

    await _pumpPanel(tester, _readout(confidence: 0));
    expect(find.text('0%'), findsOneWidget);
  });

  testWidgets('yorug\' rejimda ham yiqilmaydi', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.light),
        localizationsDelegates: L10n.localizationsDelegates,
        supportedLocales: L10n.supportedLocales,
        locale: const Locale('ru'),
        home: Scaffold(body: StatsPanel(readout: _readout(evaluation: 0.5))),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('+0.50'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('katta tizim shriftida ham panel o\'lchami nazoratda',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final heights = <double, double>{};

    for (final scale in [1.0, 1.3, 1.6, 2.0]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(Brightness.dark),
          localizationsDelegates: L10n.localizationsDelegates,
          supportedLocales: L10n.supportedLocales,
          locale: const Locale('ru'),
          builder: (context, child) => MediaQuery.withClampedTextScaling(
            minScaleFactor: scale,
            maxScaleFactor: scale,
            child: child!,
          ),
          home: Scaffold(
            body: Column(
              children: [
                const Expanded(child: SizedBox.shrink()),
                StatsPanel(readout: _readout(evaluation: -0.89)),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull, reason: 'shrift x$scale');
      heights[scale] = tester.getSize(find.byType(StatsPanel)).height;
    }

    expect(heights[1.0], lessThan(130));
    expect(heights[2.0], lessThan(260),
        reason: 'ikki baravar shriftda ham panel ekranni bosib ketmasin');
    expect(heights[2.0]! > heights[1.0]!, isTrue);
  });

  testWidgets('juda tor ekranda ham yiqilmaydi', (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await _pumpPanel(tester, _readout(evaluation: -0.89, confidence: 0.56));

    expect(tester.takeException(), isNull);
    expect(find.text('−0.89'), findsOneWidget);
    expect(find.text('56%'), findsOneWidget);
  });
}
