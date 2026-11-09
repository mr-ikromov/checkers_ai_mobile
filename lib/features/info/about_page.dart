library;

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/common.dart';
import 'rules_page.dart' show InfoSection;

const int _modelLayers = 6;

const String appVersion = '1.0.0';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final palette = context.palette;
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(l10n.menuAbout),
          systemOverlayStyle: systemOverlayFor(palette),
        ),
        body: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Center(
                child: Column(
                  children: [
                    const BrandMark(size: 64),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l10n.appTitle,
                      textAlign: TextAlign.center,
                      style: AppText.title,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.aboutVersion(appVersion),
                      textAlign: TextAlign.center,
                      style: AppText.bodyDim
                          .copyWith(fontSize: 12.5, color: palette.textDim),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              InfoSection(
                icon: Icons.psychology_outlined,
                title: l10n.aboutHowItPlays,
                body: l10n.aboutHowItPlaysBody,
              ),
              const SizedBox(height: AppSpacing.sm),
              InfoSection(
                icon: Icons.speed_rounded,
                title: l10n.aboutStrength,
                body: l10n.aboutStrengthBody,
              ),
              const SizedBox(height: AppSpacing.sm),
              InfoSection(
                icon: Icons.wifi_off_rounded,
                title: l10n.aboutOffline,
                body: l10n.aboutOfflineBody,
              ),
              const SizedBox(height: AppSpacing.sm),
              InfoSection(
                icon: Icons.memory_rounded,
                title: l10n.aboutArchitecture,
                body: l10n.aboutArchitectureBody(_modelLayers),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
