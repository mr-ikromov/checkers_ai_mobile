library;

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/common.dart';

class RulesPage extends StatelessWidget {
  const RulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final sections = <(IconData, String, String)>[
      (Icons.grid_on_rounded, l10n.rulesBoard, l10n.rulesBoardBody),
      (Icons.open_with_rounded, l10n.rulesMoves, l10n.rulesMovesBody),
      (Icons.flash_on_rounded, l10n.rulesCaptures, l10n.rulesCapturesBody),
      (Icons.link_rounded, l10n.rulesChains, l10n.rulesChainsBody),
      (
        Icons.workspace_premium_outlined,
        l10n.rulesPromotion,
        l10n.rulesPromotionBody,
      ),
      (Icons.handshake_outlined, l10n.rulesDraws, l10n.rulesDrawsBody),
    ];

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(l10n.menuRules),
          systemOverlayStyle: systemOverlayFor(context.palette),
        ),
        body: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Text(
                l10n.rulesTitle,
                textAlign: TextAlign.center,
                style: AppText.title,
              ),
              const SizedBox(height: AppSpacing.lg),
              for (final (icon, title, body) in sections) ...[
                InfoSection(icon: icon, title: title, body: body),
                const SizedBox(height: AppSpacing.sm),
              ],
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoSection extends StatelessWidget {
  const InfoSection({
    required this.icon,
    required this.title,
    required this.body,
    super.key,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: AppSpacing.radiusSm,
                  color: palette.gold.withValues(alpha: 0.14),
                ),
                child: Icon(icon, size: 19, color: palette.gold),
              ),
              const SizedBox(width: AppSpacing.sm + 2),
              Expanded(child: Text(title, style: AppText.sectionTitle)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm + 2),
          Text(
            body,
            style: AppText.bodyDim.copyWith(color: palette.textDim),
          ),
        ],
      ),
    );
  }
}
