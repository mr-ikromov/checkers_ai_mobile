library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/ai/ai_service.dart';
import 'core/ai/model_loader.dart';
import 'data/settings_store.dart';
import 'features/boot/boot_page.dart';
import 'features/home/home_page.dart';
import 'features/onboarding/language_page.dart';
import 'l10n/app_localizations.dart';
import 'ui/theme/app_theme.dart';

class ShashkaApp extends StatefulWidget {
  const ShashkaApp({super.key});

  @override
  State<ShashkaApp> createState() => _ShashkaAppState();
}

class _ShashkaAppState extends State<ShashkaApp> {
  SettingsStore? _settings;
  AiService? _ai;
  BootStage _stage = BootStage.preparing;
  String? _bootError;
  bool _languageChosen = false;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  @override
  void dispose() {
    _ai?.dispose();
    _settings?.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _boot() async {
    setState(() {
      _bootError = null;
      _stage = BootStage.preparing;
    });
    try {
      final settings = _settings ?? await SettingsStore.load();
      if (_settings == null) {
        settings.addListener(_onSettingsChanged);
      }
      if (!mounted) return;
      setState(() {
        _settings = settings;
        _languageChosen = settings.onboarded;
        _stage = BootStage.loadingModel;
      });

      final packed = await loadEncryptedModel();
      final ai = await AiService.start(packed);
      if (!mounted) {
        ai.dispose();
        return;
      }
      setState(() {
        _ai = ai;
        _stage = BootStage.ready;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _bootError = _shortError(e));
    }
  }

  static String _shortError(Object error) {
    final text = error is AiException ? error.message : error.toString();
    return text.length > 220 ? '${text.substring(0, 220)}…' : text;
  }

  @override
  Widget build(BuildContext context) {
    final settings = _settings;
    final code = settings?.languageCode;

    return MaterialApp(
      onGenerateTitle: (context) => L10n.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      themeMode: settings?.themeMode ?? ThemeMode.system,
      locale: code == null ? null : Locale(code),
      localizationsDelegates: const [
        L10n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: L10n.supportedLocales,
      builder: (context, child) => MediaQuery.withNoTextScaling(

        child: child ?? const SizedBox.shrink(),
      ),
      home: _home(settings),
    );
  }

  Widget _home(SettingsStore? settings) {
    if (_bootError != null) {
      return BootPage(stage: _stage, error: _bootError, onRetry: _boot);
    }
    final ai = _ai;
    if (settings == null || ai == null) {
      return BootPage(stage: _stage);
    }
    if (!_languageChosen) {
      return LanguagePage(
        settings: settings,
        onDone: () => setState(() => _languageChosen = true),
      );
    }
    return HomePage(ai: ai, settings: settings);
  }
}
