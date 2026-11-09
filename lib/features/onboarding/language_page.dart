library;

import 'package:flutter/material.dart';

import '../../data/settings_store.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/common.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({required this.settings, required this.onDone, super.key});

  final SettingsStore settings;
  final VoidCallback onDone;

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  late String _selected = widget.settings.languageCode ?? _deviceDefault();

  String _deviceDefault() {
    final code = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    return supportedLanguageCodes.contains(code) ? code : 'en';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final palette = context.palette;
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    const Center(child: BrandMark(size: 72)),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      l10n.chooseLanguage,
                      textAlign: TextAlign.center,
                      style: AppText.title,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.chooseLanguageHint,
                      textAlign: TextAlign.center,
                      style: AppText.bodyDim
                          .copyWith(fontSize: 13, color: palette.textDim),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    for (final entry in const [
                      ('en', 'English', 'EN'),
                      ('ru', 'Русский', 'RU'),
                      ('uz', 'O‘zbekcha', 'UZ'),
                    ]) ...[
                      _LanguageTile(
                        label: entry.$2,
                        badge: entry.$3,
                        selected: _selected == entry.$1,
                        onTap: () => setState(() => _selected = entry.$1),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    AppPrimaryButton(
                      label: l10n.continueAction,
                      icon: Icons.arrow_forward_rounded,
                      onPressed: () async {
                        await widget.settings.setLanguage(_selected);
                        widget.onDone();
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.label,
    required this.badge,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String badge;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: selected ? palette.panelHighlight : palette.panelFill,
      borderRadius: AppSpacing.radiusMd,
      child: InkWell(
        borderRadius: AppSpacing.radiusMd,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 15,
          ),
          decoration: BoxDecoration(
            borderRadius: AppSpacing.radiusMd,
            border: Border.all(
              color: selected ? palette.gold : palette.panelBorder,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: AppSpacing.radiusSm,
                  color: selected
                      ? palette.gold.withValues(alpha: 0.22)
                      : palette.panelBorder.withValues(alpha: 0.35),
                ),
                child: Text(
                  badge,
                  style: AppText.label.copyWith(
                    color: selected ? palette.gold : palette.textDim,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: AppText.body.copyWith(
                    fontSize: 16,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: selected ? 1 : 0,
                child: Icon(
                  Icons.check_circle_rounded,
                  color: palette.gold,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
