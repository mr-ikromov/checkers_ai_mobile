library;

import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shashka/core/engine/position.dart';
import 'package:shashka/data/settings_store.dart';

Future<SettingsStore> _store([Map<String, Object>? initial]) async {
  SharedPreferences.setMockInitialValues(initial ?? <String, Object>{});
  return SettingsStore.load();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bo\'sh xotirada oqilona standart qiymatlar', () async {
    final settings = await _store();

    expect(settings.languageCode, isNull);
    expect(settings.onboarded, isFalse);
    expect(settings.themeMode, ThemeMode.dark);
    expect(settings.humanSide, white);
    expect(settings.haptics, isTrue);
    expect(settings.wins, 0);
    expect(settings.draws, 0);
    expect(settings.losses, 0);
    expect(settings.gamesPlayed, 0);
  });

  test('eski "system" qiymati to\'q rejimga tushadi', () async {
    final settings = await _store({'theme_mode': 'system'});
    expect(settings.themeMode, ThemeMode.dark);
  });

  test('tanishsiz mavzu qiymati ham to\'q rejimga tushadi', () async {
    final settings = await _store({'theme_mode': 'neon'});
    expect(settings.themeMode, ThemeMode.dark);
  });

  test('mavzu saqlanadi va qayta o\'qiladi', () async {
    final settings = await _store();

    await settings.setThemeMode(ThemeMode.light);
    expect(settings.themeMode, ThemeMode.light);

    await settings.setThemeMode(ThemeMode.dark);
    expect(settings.themeMode, ThemeMode.dark);
  });

  test('qo\'llab-quvvatlanmaydigan til rad etiladi', () async {
    final settings = await _store();

    await settings.setLanguage('de');
    expect(settings.languageCode, isNull);
    expect(settings.onboarded, isFalse);

    await settings.setLanguage('uz');
    expect(settings.languageCode, 'uz');
    expect(settings.onboarded, isTrue);
  });

  test('buzilgan til kodi o\'qishda ham rad etiladi', () async {
    final settings = await _store({'locale': 'zz'});
    expect(settings.languageCode, isNull);
  });

  test('tomon: faqat oq yoki qora', () async {
    final settings = await _store();

    await settings.setHumanSide(black);
    expect(settings.humanSide, black);

    await settings.setHumanSide(42);
    expect(settings.humanSide, white);
  });

  test('buzilgan tomon qiymati oqqa tushadi', () async {
    final settings = await _store({'human_side': 99});
    expect(settings.humanSide, white);
  });

  test('tebranish saqlanadi', () async {
    final settings = await _store();

    await settings.setHaptics(false);
    expect(settings.haptics, isFalse);

    await settings.setHaptics(true);
    expect(settings.haptics, isTrue);
  });

  test('natijalar tomonga qarab to\'g\'ri sanaladi', () async {
    final settings = await _store();

    await settings.recordResult(winner: white, humanSide: white);
    await settings.recordResult(winner: black, humanSide: white);
    await settings.recordResult(winner: 0, humanSide: white);
    await settings.recordResult(winner: black, humanSide: black);

    expect(settings.wins, 2);
    expect(settings.losses, 1);
    expect(settings.draws, 1);
    expect(settings.gamesPlayed, 4);
  });

  test('tozalash faqat natijalarni o\'chiradi', () async {
    final settings = await _store();
    await settings.setLanguage('ru');
    await settings.setThemeMode(ThemeMode.light);
    await settings.setHaptics(false);
    await settings.recordResult(winner: white, humanSide: white);

    await settings.resetRecord();

    expect(settings.gamesPlayed, 0);
    expect(settings.languageCode, 'ru');
    expect(settings.themeMode, ThemeMode.light);
    expect(settings.haptics, isFalse);
  });

  test('har bir o\'zgarish kuzatuvchilarni xabardor qiladi', () async {
    final settings = await _store();
    var notifications = 0;
    settings.addListener(() => notifications++);

    await settings.setLanguage('en');
    await settings.setThemeMode(ThemeMode.light);
    await settings.setHumanSide(black);
    await settings.setHaptics(false);
    await settings.recordResult(winner: 0, humanSide: white);
    await settings.resetRecord();

    expect(notifications, 6);
  });
}
