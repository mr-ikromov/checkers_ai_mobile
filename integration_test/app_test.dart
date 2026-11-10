library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shashka/app.dart';
import 'package:shashka/core/engine/position.dart';
import 'package:shashka/features/game/game_controller.dart';
import 'package:shashka/features/game/widgets/board_view.dart';
import 'package:shashka/l10n/app_localizations.dart';
import 'package:shashka/ui/widgets/common.dart';

const Duration _bootTimeout = Duration(seconds: 120);
const Duration _aiTimeout = Duration(seconds: 120);

Future<void> _pumpUntil(
  WidgetTester tester,
  bool Function() condition, {
  required Duration timeout,
  String reason = 'shart bajarilmadi',
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (condition()) return;
  }
  fail('$reason (${timeout.inSeconds}s kutildi)');
}

GameController _controller(WidgetTester tester) =>
    tester.widget<BoardView>(find.byType(BoardView)).controller;

Future<void> _tapSquare(WidgetTester tester, int square) async {
  final finder = find.byType(BoardView);
  final box = tester.renderObject<RenderBox>(finder);
  final topLeft = box.localToGlobal(Offset.zero);
  final size = box.size.shortestSide;
  final controller = _controller(tester);
  final pad = size * 0.062;
  final cell = (size - pad * 2) / 8;
  final dr = controller.flipped ? 7 - sqRow[square] : sqRow[square];
  final dc = controller.flipped ? 7 - sqCol[square] : sqCol[square];
  await tester.tapAt(
    topLeft + Offset(pad + (dc + 0.5) * cell, pad + (dr + 0.5) * cell),
  );
  await tester.pump();
}

Future<void> _playOneHumanMove(WidgetTester tester) async {
  final controller = _controller(tester);
  await _pumpUntil(
    tester,
    () =>
        controller.winner != null ||
        (controller.isHumanTurn && controller.movableSquares.isNotEmpty),
    timeout: _aiTimeout,
    reason: 'navbat qaytmadi',
  );
  if (controller.winner != null) return;
  final from = controller.movableSquares.first;
  await _tapSquare(tester, from);
  final targets = controller.selectedTargets;
  expect(targets, isNotEmpty);
  await _tapSquare(tester, targets.first);
  await _pumpUntil(
    tester,
    () => controller.isHumanTurn || controller.winner != null,
    timeout: _aiTimeout,
    reason: 'AI yurishni tugatmadi',
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('yuklash → til → o\'yin → AI javobi', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(const ShashkaApp());

    await _pumpUntil(
      tester,
      () => find.text('O‘zbekcha').evaluate().isNotEmpty,
      timeout: _bootTimeout,
      reason: 'model yuklanmadi yoki til ekrani chiqmadi',
    );

    await tester.tap(find.text('O‘zbekcha'));
    await tester.pump();
    await tester.tap(find.byType(AppPrimaryButton));
    await tester.pumpAndSettle();
    final l10n = lookupL10n(const Locale('uz'));

    expect(find.text(l10n.play), findsOneWidget);
    await tester.tap(find.text(l10n.play));
    await tester.pumpAndSettle();

    final controller = _controller(tester);
    await _pumpUntil(
      tester,
      () => controller.isHumanTurn,
      timeout: const Duration(seconds: 20),
      reason: 'navbat boshlanmadi',
    );
    expect(controller.sprites.length, 24);
    expect(controller.humanSide, white);

    await _playOneHumanMove(tester);

    final readout = controller.readout!;
    expect(readout.confidence, inInclusiveRange(0.0, 1.0));
    expect(readout.evaluation, inInclusiveRange(-1.0, 1.0));
    expect(readout.elapsedMs, lessThan(2000),
        reason: 'yurish bir zumda bo\'lishi kerak');

    print('AI yurishi: ishonch=${(readout.confidence * 100).round()}% '
        'baho=${readout.evaluation.toStringAsFixed(3)} '
        'vaqt=${readout.elapsedMs}ms');

    expect(controller.ply, greaterThanOrEqualTo(2));
    for (var i = 0; i < 3; i++) {
      await _playOneHumanMove(tester);
    }
    final squares = controller.sprites.map((s) => s.square).toList();
    expect(squares.toSet().length, squares.length);
  });

  testWidgets('til almashtirish', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(const ShashkaApp());
    await _pumpUntil(
      tester,
      () => find.text('Русский').evaluate().isNotEmpty,
      timeout: _bootTimeout,
      reason: 'til ekrani chiqmadi',
    );

    await tester.tap(find.text('Русский'));
    await tester.pump();
    await tester.tap(find.byType(AppPrimaryButton));
    await tester.pumpAndSettle();
    final ru = lookupL10n(const Locale('ru'));

    expect(find.text(ru.play), findsOneWidget);
    expect(find.text(ru.menuRules), findsOneWidget);

    await tester.tap(find.text(ru.menuSettings));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    final en = lookupL10n(const Locale('en'));
    expect(find.text(en.menuSettings), findsWidgets);
  });

  testWidgets('mavzu almashtirish ishlaydi', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'locale': 'en',
      'onboarded': true,
    });
    await tester.pumpWidget(const ShashkaApp());
    final en = lookupL10n(const Locale('en'));
    await _pumpUntil(
      tester,
      () => find.text(en.play).evaluate().isNotEmpty,
      timeout: _bootTimeout,
      reason: 'asosiy ekran chiqmadi',
    );

    await tester.tap(find.text(en.menuSettings));
    await tester.pumpAndSettle();

    await tester.tap(find.text(en.themeLight));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.text(en.themeLight))).brightness,
      Brightness.light,
    );

    await tester.tap(find.text(en.themeDark));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.text(en.themeDark))).brightness,
      Brightness.dark,
    );
  });

  testWidgets('to\'liq o\'yin oxirigacha va natija yoziladi', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'locale': 'uz',
      'onboarded': true,
      'haptics': false,
    });
    await tester.pumpWidget(const ShashkaApp());
    final l10n = lookupL10n(const Locale('uz'));
    await _pumpUntil(
      tester,
      () => find.text(l10n.play).evaluate().isNotEmpty,
      timeout: _bootTimeout,
      reason: 'asosiy ekran chiqmadi',
    );
    await tester.tap(find.text(l10n.play));
    await tester.pumpAndSettle();

    final controller = _controller(tester);
    var moves = 0;
    final stopwatch = Stopwatch()..start();

    while (controller.winner == null && moves < 400) {
      await _playOneHumanMove(tester);
      moves++;
      final squares = controller.sprites.map((s) => s.square).toList();
      expect(squares.toSet().length, squares.length, reason: 'yurish $moves');
    }
    stopwatch.stop();

    expect(controller.winner, isNotNull);

    print('To\'liq o\'yin: ${controller.ply} yarim-yurish, '
        'natija=${controller.winner}, ${stopwatch.elapsedMilliseconds} ms');

    await _pumpUntil(
      tester,
      () => find.byType(AppDialog).evaluate().isNotEmpty,
      timeout: const Duration(seconds: 20),
      reason: 'natija dialogi chiqmadi',
    );
    await tester.tap(find.text(l10n.backToMenu));
    await tester.pumpAndSettle();
    expect(find.text(l10n.statsGames(0)), findsNothing);
  });

  testWidgets('o\'yin o\'rtasida orqaga qaytish va qayta kirish',
      (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'locale': 'en',
      'onboarded': true,
      'haptics': false,
    });
    await tester.pumpWidget(const ShashkaApp());
    final en = lookupL10n(const Locale('en'));
    await _pumpUntil(
      tester,
      () => find.text(en.play).evaluate().isNotEmpty,
      timeout: _bootTimeout,
      reason: 'asosiy ekran chiqmadi',
    );

    for (var round = 0; round < 3; round++) {
      await tester.tap(find.text(en.play));
      await tester.pumpAndSettle();
      await _playOneHumanMove(tester);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text(en.play), findsOneWidget, reason: 'aylanish $round');
    }
  });
}
