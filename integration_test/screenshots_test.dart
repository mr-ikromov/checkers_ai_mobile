library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shashka/app.dart';
import 'package:shashka/features/game/game_controller.dart';
import 'package:shashka/features/game/widgets/board_view.dart';
import 'package:shashka/l10n/app_localizations.dart';

late IntegrationTestWidgetsFlutterBinding binding;

Future<void> _pumpUntil(
  WidgetTester tester,
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 90),
  String reason = 'shart bajarilmadi',
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 120));
    if (condition()) return;
  }
  fail('$reason (${timeout.inSeconds}s)');
}

GameController _controller(WidgetTester tester) =>
    tester.widget<BoardView>(find.byType(BoardView)).controller;

Future<void> _tapSquare(WidgetTester tester, int square) async {
  final boardFinder = find.byType(BoardView);
  final box = tester.renderObject<RenderBox>(boardFinder);
  final topLeft = box.localToGlobal(Offset.zero);
  final size = box.size.shortestSide;
  final controller = _controller(tester);
  final pad = size * 0.062;
  final cell = (size - pad * 2) / 8;
  final dr = controller.flipped ? 7 - sqRowOf(square) : sqRowOf(square);
  final dc = controller.flipped ? 7 - sqColOf(square) : sqColOf(square);
  await tester.tapAt(
    topLeft + Offset(pad + (dc + 0.5) * cell, pad + (dr + 0.5) * cell),
  );
  await tester.pump();
}

int sqRowOf(int square) => _rowCol(square).$1;
int sqColOf(int square) => _rowCol(square).$2;

(int, int) _rowCol(int square) {
  var n = 0;
  for (var r = 0; r < 8; r++) {
    for (var c = 0; c < 8; c++) {
      if ((r + c) % 2 == 1) {
        if (n == square) return (r, c);
        n++;
      }
    }
  }
  throw ArgumentError('katak $square');
}

Future<void> _goBack(WidgetTester tester) async {
  await tester.tap(find.byType(BackButton));
  await tester.pumpAndSettle();
}

Future<void> _shot(WidgetTester tester, String name) async {
  await tester.pumpAndSettle();
  await binding.takeScreenshot(name);
}

void main() {
  binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  for (final (language, theme) in const [
    ('uz', 'dark'),
    ('ru', 'dark'),
    ('en', 'dark'),
    ('uz', 'light'),
  ]) {
    final prefix = theme == 'light' ? '$language-light' : language;
    testWidgets('skrinshotlar · $prefix', (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'locale': language,
        'onboarded': true,
        'theme_mode': theme,
        'haptics': false,
        'wins': 7,
        'draws': 3,
        'losses': 5,
      });
      await binding.convertFlutterSurfaceToImage();
      await tester.pumpWidget(const ShashkaApp());

      final l10n = lookupL10n(Locale(language));

      await _pumpUntil(
        tester,
        () => find.text(l10n.play).evaluate().isNotEmpty,
        reason: 'asosiy ekran chiqmadi',
      );
      await _shot(tester, '$prefix/01-home');

      await tester.tap(find.text(l10n.menuRules));
      await tester.pumpAndSettle();
      await _shot(tester, '$prefix/04-rules');
      await _goBack(tester);

      await tester.tap(find.text(l10n.menuAbout));
      await tester.pumpAndSettle();
      await _shot(tester, '$prefix/05-about');
      await _goBack(tester);

      await tester.tap(find.text(l10n.menuSettings));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text(l10n.statsReset), 240);
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.statsReset));
      await tester.pumpAndSettle();
      await _shot(tester, '$prefix/06-dialog');
      await tester.tap(find.text(l10n.cancel));
      await tester.pumpAndSettle();
      await _goBack(tester);

      await tester.tap(find.text(l10n.play));
      await tester.pumpAndSettle();
      final controller = _controller(tester);
      await _pumpUntil(tester, () => controller.isHumanTurn);
      await _shot(tester, '$prefix/02-board-start');

      for (var i = 0; i < 6; i++) {
        await _pumpUntil(
          tester,
          () => controller.winner != null ||
              (controller.isHumanTurn && controller.movableSquares.isNotEmpty),
        );
        if (controller.winner != null) break;
        final from = controller.movableSquares.first;
        await _tapSquare(tester, from);
        await _tapSquare(tester, controller.selectedTargets.first);
        await _pumpUntil(
          tester,
          () => controller.isHumanTurn || controller.winner != null,
        );
      }

      if (controller.isHumanTurn && controller.movableSquares.isNotEmpty) {
        await _tapSquare(tester, controller.movableSquares.first);
      }
      await _shot(tester, '$prefix/03-board-play');
    });
  }
}
