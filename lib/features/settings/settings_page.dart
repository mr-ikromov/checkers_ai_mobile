library;

import 'package:flutter/material.dart';

import '../../data/settings_store.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/common.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({required this.settings, super.key});

  final SettingsStore settings;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Future<void> _resetRecord() async {
    final l10n = L10n.of(context);
    final confirmed = await AppDialog.show(
      context,
      title: l10n.statsReset,
      dismissLabel: l10n.cancel,
      confirmLabel: l10n.reset,
    );
    if (confirmed && mounted) {
      await widget.settings.resetRecord();
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final settings = widget.settings;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(l10n.menuSettings),
          systemOverlayStyle: systemOverlayFor(context.palette),
        ),
        body: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              SectionLabel(l10n.settingsLanguage),
              const SizedBox(height: AppSpacing.sm),
              AppPanel(
                padding: const EdgeInsets.all(AppSpacing.xs),
                child: RadioGroup<String>(
                  groupValue: settings.languageCode ?? 'en',
                  onChanged: (value) async {
                    if (value == null) return;
                    await settings.setLanguage(value);
                    if (mounted) setState(() {});
                  },
                  child: Column(
                    children: [
                      for (final entry in const [
                        ('en', 'English'),
                        ('ru', 'Русский'),
                        ('uz', 'O‘zbekcha'),
                      ])
                        RadioListTile<String>(
                          value: entry.$1,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                          ),
                          title: Text(entry.$2, style: AppText.body),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionLabel(l10n.settingsAppearance),
              const SizedBox(height: AppSpacing.sm),
              AppPanel(
                padding: const EdgeInsets.all(AppSpacing.xs),
                child: RadioGroup<ThemeMode>(
                  groupValue: settings.themeMode,
                  onChanged: (value) async {
                    if (value == null) return;
                    await settings.setThemeMode(value);
                    if (mounted) setState(() {});
                  },
                  child: Column(
                    children: [
                      for (final entry in [
                        (ThemeMode.system, l10n.themeSystem,
                            Icons.brightness_auto_rounded),
                        (ThemeMode.light, l10n.themeLight,
                            Icons.light_mode_rounded),
                        (ThemeMode.dark, l10n.themeDark,
                            Icons.dark_mode_rounded),
                      ])
                        RadioListTile<ThemeMode>(
                          value: entry.$1,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                          ),
                          title: Row(
                            children: [
                              Icon(
                                entry.$3,
                                size: 19,
                                color: context.palette.textDim,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(entry.$2, style: AppText.body),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppPanel(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Column(
                  children: [
                    _Toggle(
                      title: l10n.settingsHaptics,
                      subtitle: l10n.settingsHapticsHint,
                      value: settings.haptics,
                      onChanged: (v) async {
                        await settings.setHaptics(v);
                        if (mounted) setState(() {});
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionLabel(l10n.statsTitle),
              const SizedBox(height: AppSpacing.sm),
              AppPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _Mini(
                            label: l10n.statsWins,
                            value: settings.wins,
                          ),
                        ),
                        Expanded(
                          child: _Mini(
                            label: l10n.statsDraws,
                            value: settings.draws,
                          ),
                        ),
                        Expanded(
                          child: _Mini(
                            label: l10n.statsLosses,
                            value: settings.losses,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppSecondaryButton(
                      label: l10n.statsReset,
                      icon: Icons.delete_outline_rounded,
                      onPressed: settings.gamesPlayed == 0 ? null : _resetRecord,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      title: Text(title, style: AppText.body),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: AppText.bodyDim
                  .copyWith(fontSize: 12, color: context.palette.textDim),
            ),
    );
  }
}

class _Mini extends StatelessWidget {
  const _Mini({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$value', textAlign: TextAlign.center, style: AppText.statValue),
        const SizedBox(height: 2),
        SectionLabel(label, align: TextAlign.center),
      ],
    );
  }
}
