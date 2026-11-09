library;

import 'package:flutter/material.dart';

import '../../core/ai/ai_service.dart';
import '../../core/engine/position.dart';
import '../../data/settings_store.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/common.dart';
import '../game/game_page.dart';
import '../game/widgets/board_view.dart';
import '../info/about_page.dart';
import '../info/rules_page.dart';
import '../settings/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({required this.ai, required this.settings, super.key});

  final AiService ai;
  final SettingsStore settings;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _side = widget.settings.humanSide;

  Future<void> _play() async {
    await widget.settings.setHumanSide(_side);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => GamePage(
          ai: widget.ai,
          settings: widget.settings,
          humanSide: _side,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  void _open(Widget page) {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (context) => page))
        .then((_) {
      if (mounted) setState(() {});
    });
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
              constraints: const BoxConstraints(maxWidth: 460),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    const Center(child: BrandMark(size: 64)),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l10n.appTitle,
                      textAlign: TextAlign.center,
                      style: AppText.brand.copyWith(
                        fontSize: 22,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.appTagline,
                      textAlign: TextAlign.center,
                      style: AppText.bodyDim
                          .copyWith(fontSize: 12.5, color: palette.textDim),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    SectionLabel(l10n.chooseSide, align: TextAlign.center),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: _SideCard(
                            label: l10n.sideWhite,
                            kind: 1,
                            selected: _side == white,
                            onTap: () => setState(() => _side = white),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _SideCard(
                            label: l10n.sideBlack,
                            kind: -1,
                            selected: _side == black,
                            onTap: () => setState(() => _side = black),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      l10n.chooseSideHint,
                      textAlign: TextAlign.center,
                      style: AppText.bodyDim
                          .copyWith(fontSize: 12, color: palette.textDim),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppPrimaryButton(
                      label: l10n.play,
                      icon: Icons.play_arrow_rounded,
                      onPressed: _play,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _RecordPanel(settings: widget.settings),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: _MenuTile(
                            icon: Icons.menu_book_outlined,
                            label: l10n.menuRules,
                            onTap: () => _open(const RulesPage()),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _MenuTile(
                            icon: Icons.tune_rounded,
                            label: l10n.menuSettings,
                            onTap: () =>
                                _open(SettingsPage(settings: widget.settings)),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _MenuTile(
                            icon: Icons.info_outline_rounded,
                            label: l10n.menuAbout,
                            onTap: () => _open(const AboutPage()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
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

class _SideCard extends StatelessWidget {
  const _SideCard({
    required this.label,
    required this.kind,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int kind;
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
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: AppSpacing.radiusMd,
            border: Border.all(
              color: selected ? palette.gold : palette.panelBorder,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Column(
            children: [
              PieceView(kind: kind, size: 46),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppText.body.copyWith(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? palette.gold : palette.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecordPanel extends StatelessWidget {
  const _RecordPanel({required this.settings});

  final SettingsStore settings;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final palette = context.palette;
    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionLabel(l10n.statsTitle, align: TextAlign.center),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.statsGames(settings.gamesPlayed),
            textAlign: TextAlign.center,
            style: AppText.bodyDim
                .copyWith(fontSize: 12, color: palette.textDim),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _RecordCell(
                  label: l10n.statsWins,
                  value: settings.wins,
                  color: palette.gold,
                ),
              ),
              Expanded(
                child: _RecordCell(
                  label: l10n.statsDraws,
                  value: settings.draws,
                  color: palette.textDim,
                ),
              ),
              Expanded(
                child: _RecordCell(
                  label: l10n.statsLosses,
                  value: settings.losses,
                  color: palette.danger,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecordCell extends StatelessWidget {
  const _RecordCell({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionLabel(label, align: TextAlign.center),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '$value',
          textAlign: TextAlign.center,
          style: AppText.statValue.copyWith(color: color),
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: palette.panelFill,
      borderRadius: AppSpacing.radiusMd,
      child: InkWell(
        borderRadius: AppSpacing.radiusMd,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: AppSpacing.radiusMd,
            border: Border.all(color: palette.panelBorder),
          ),
          child: Column(
            children: [
              Icon(icon, color: palette.textDim, size: 22),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppText.bodyDim
                    .copyWith(fontSize: 12, color: palette.textDim),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
