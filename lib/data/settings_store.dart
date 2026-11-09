library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/engine/position.dart';

const String _kLocale = 'locale';
const String _kSide = 'human_side';
const String _kOnboarded = 'onboarded';
const String _kThemeMode = 'theme_mode';
const String _kAnimations = 'animations';
const String _kHaptics = 'haptics';
const String _kCoordinates = 'coordinates';
const String _kWins = 'wins';
const String _kDraws = 'draws';
const String _kLosses = 'losses';

const List<String> supportedLanguageCodes = ['en', 'ru', 'uz'];

class SettingsStore extends ChangeNotifier {
  SettingsStore._(this._prefs);

  static Future<SettingsStore> load() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsStore._(prefs);
  }

  final SharedPreferences _prefs;

  String? get languageCode {
    final code = _prefs.getString(_kLocale);
    return supportedLanguageCodes.contains(code) ? code : null;
  }

  bool get onboarded => _prefs.getBool(_kOnboarded) ?? false;

  ThemeMode get themeMode => switch (_prefs.getString(_kThemeMode)) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  int get humanSide => _prefs.getInt(_kSide) == black ? black : white;

  bool get animations => _prefs.getBool(_kAnimations) ?? true;
  bool get haptics => _prefs.getBool(_kHaptics) ?? true;
  bool get coordinates => _prefs.getBool(_kCoordinates) ?? true;

  int get wins => _prefs.getInt(_kWins) ?? 0;
  int get draws => _prefs.getInt(_kDraws) ?? 0;
  int get losses => _prefs.getInt(_kLosses) ?? 0;
  int get gamesPlayed => wins + draws + losses;

  Future<void> setLanguage(String code) async {
    if (!supportedLanguageCodes.contains(code)) return;
    await _prefs.setString(_kLocale, code);
    await _prefs.setBool(_kOnboarded, true);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(_kThemeMode, switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    });
    notifyListeners();
  }

  Future<void> setHumanSide(int side) async {
    await _prefs.setInt(_kSide, side == black ? black : white);
    notifyListeners();
  }

  Future<void> setAnimations(bool value) => _setFlag(_kAnimations, value);
  Future<void> setHaptics(bool value) => _setFlag(_kHaptics, value);
  Future<void> setCoordinates(bool value) => _setFlag(_kCoordinates, value);

  Future<void> _setFlag(String key, bool value) async {
    await _prefs.setBool(key, value);
    notifyListeners();
  }

  Future<void> recordResult({
    required int winner,
    required int humanSide,
  }) async {
    final String key;
    if (winner == 0) {
      key = _kDraws;
    } else if (winner == humanSide) {
      key = _kWins;
    } else {
      key = _kLosses;
    }
    await _prefs.setInt(key, (_prefs.getInt(key) ?? 0) + 1);
    notifyListeners();
  }

  Future<void> resetRecord() async {
    await _prefs.remove(_kWins);
    await _prefs.remove(_kDraws);
    await _prefs.remove(_kLosses);
    notifyListeners();
  }
}
