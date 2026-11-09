library;

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/theme/app_theme.dart';
import '../../../ui/widgets/common.dart';
import '../game_controller.dart';

class StatsPanel extends StatelessWidget {
  const StatsPanel({required this.readout, super.key});

  final AiReadout? readout;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final data = readout;

    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionLabel(l10n.statEvaluation, align: TextAlign.center),
          const SizedBox(height: AppSpacing.xs),
          Text(
            data == null ? '—' : _formatEval(data.evaluation),
            textAlign: TextAlign.center,
            style: AppText.statValue.copyWith(fontSize: 22),
          ),
          const SizedBox(height: AppSpacing.sm),
          _EvalBar(value: data?.evaluation),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _Stat(
                  label: l10n.statConfidence,
                  value:
                      data == null ? '—' : '${(data.confidence * 100).round()}%',
                ),
              ),
              Expanded(
                child: _Stat(
                  label: l10n.thinkTime,
                  value: data == null ? '—' : _formatTime(l10n, data.elapsedMs),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatTime(L10n l10n, int elapsedMs) => elapsedMs < 1000
      ? l10n.milliseconds(elapsedMs)
      : l10n.seconds((elapsedMs / 1000).toStringAsFixed(1));

  static String _formatEval(double value) {
    final clamped = value.clamp(-1.0, 1.0);
    final text = clamped.abs().toStringAsFixed(2);

    if (text == '0.00') return text;
    return '${clamped >= 0 ? '+' : '−'}$text';
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionLabel(label, align: TextAlign.center),
        const SizedBox(height: AppSpacing.xs),
        Text(value, textAlign: TextAlign.center, style: AppText.statValue),
      ],
    );
  }
}

class _EvalBar extends StatelessWidget {
  const _EvalBar({required this.value});

  final double? value;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final fraction = ((value ?? 0).clamp(-1.0, 1.0) + 1) / 2;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return SizedBox(
          height: 14,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: const LinearGradient(
                    colors: [
                      BoardColors.charcoal,
                      Color(0xFF9A8B74),
                      BoardColors.ivory,
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                  border: Border.all(color: palette.panelBorder),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 420),
                curve: Curves.easeOutCubic,
                left: (width - 4) * fraction,
                child: Container(
                  width: 4,
                  height: 14,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: palette.gold,
                    boxShadow: [
                      BoxShadow(
                        color: palette.gold.withValues(alpha: 0.75),
                        blurRadius: 9,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
