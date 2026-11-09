library;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(gradient: context.palette.pageGradient),
      child: child,
    );
  }
}

class AppPanel extends StatelessWidget {
  const AppPanel({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.borderRadius = AppSpacing.radiusMd,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: palette.panelFill,
        border: Border.all(color: palette.panelBorder),
      ),
      child: child,
    );
  }
}

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final enabled = onPressed != null;
    final foreground =
        palette.isDark ? const Color(0xFF2A1C0A) : const Color(0xFFFFF8EA);
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: AppSpacing.radiusMd,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [palette.goldBright, palette.goldDeep],
          ),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: palette.gold.withValues(alpha: 0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: AppSpacing.radiusMd,
          child: InkWell(
            borderRadius: AppSpacing.radiusMd,
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: 15,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 19, color: foreground),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(
                    label,
                    style: AppText.button.copyWith(color: foreground),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppSecondaryButton extends StatelessWidget {
  const AppSecondaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: palette.panelFill,
      borderRadius: AppSpacing.radiusMd,
      child: InkWell(
        borderRadius: AppSpacing.radiusMd,
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppSpacing.radiusMd,
            border: Border.all(color: palette.panelBorder),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 14,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: palette.textDim),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(label, style: AppText.button.copyWith(color: palette.text)),
            ],
          ),
        ),
      ),
    );
  }
}

class BrandMark extends StatelessWidget {
  const BrandMark({this.size = 64, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            center: Alignment(-0.3, -0.42),
            radius: 1.0,
            colors: [Colors.white, BoardColors.ivory, Color(0xFFB9A87F)],
            stops: [0.0, 0.46, 1.0],
          ),
          border: Border.all(color: palette.gold, width: size * 0.07),
          boxShadow: [
            BoxShadow(
              color: palette.gold.withValues(alpha: 0.26),
              blurRadius: size * 0.42,
            ),
            BoxShadow(
              color: palette.shadow,
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Text(
            '♔',
            style: TextStyle(
              fontSize: size * 0.46,
              color: BoardColors.walnut,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {this.align = TextAlign.start, super.key});

  final String text;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      textAlign: align,
      style: AppText.label.copyWith(color: context.palette.textDim),
    );
  }
}
