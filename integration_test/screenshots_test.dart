/// Play Console uchun skrinshotlarni qurilmada avtomatik olish.
///
/// Ishga tushirish:
///   `flutter drive --profile --driver=test_driver/screenshots.dart \`
///   `  --target=integration_test/screenshots_test.dart -d <device-id>`
///
/// Natijalar: `docs/play/graphics/screenshots/<til>/NN-<nom>.png`
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
  final pad =
      tester.widget<BoardView>(boardFinder).showCoordinates
          ? size * 0.062
          : size * 0.028;
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

/// AppBar'dagi orqaga tugmasi. `pageBack()` ishlatilmaydi: u tooltip'ni
/// 'Back' deb qidiradi va boshqa tillarda topolmaydi.
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
        'animations': false,
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

      // Qoidalar.
      await tester.tap(find.text(l10n.menuRules));
      await tester.pumpAndSettle();
      await _shot(tester, '$prefix/04-rules');
      await _goBack(tester);

      // Ilova haqida.
      await tester.tap(find.text(l10n.menuAbout));
      await tester.pumpAndSettle();
      await _shot(tester, '$prefix/05-about');
      await _goBack(tester);

      // O'yin: bir necha yurish qilib, ko'rsatkichlar to'lgan holatni olamiz.
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
      // Tanlangan tosh va mumkin bo'lgan yurishlar ko'rinib tursin.
      if (controller.isHumanTurn && controller.movableSquares.isNotEmpty) {
        await _tapSquare(tester, controller.movableSquares.first);
      }
      await _shot(tester, '$prefix/03-board-play');
    });
  }
}
