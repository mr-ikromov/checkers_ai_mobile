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
          child: CrownMark(size: size * 0.44, color: BoardColors.walnut),
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

class AppDialog extends StatelessWidget {
  const AppDialog({
    required this.title,
    required this.dismissLabel,
    required this.confirmLabel,
    super.key,
  });

  final String title;
  final String dismissLabel;
  final String confirmLabel;

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String dismissLabel,
    required String confirmLabel,
    bool barrierDismissible = true,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AppDialog(
        title: title,
        dismissLabel: dismissLabel,
        confirmLabel: confirmLabel,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Dialog(
      backgroundColor: palette.backgroundLift,
      surfaceTintColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.radiusLg,
        side: BorderSide(color: palette.panelBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppText.title.copyWith(fontSize: 21),
            ),
          ),
          SizedBox(
            height: 58,
            child: Row(
              children: [
                Expanded(
                  child: _DialogAction(
                    label: dismissLabel,
                    background: palette.dialogBlue,
                    foreground: Colors.white,
                    corner: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                    ),
                    onTap: () => Navigator.of(context).pop(false),
                  ),
                ),
                Container(width: 1, color: palette.panelBorder),
                Expanded(
                  child: _DialogAction(
                    label: confirmLabel,
                    background: palette.dialogRed,
                    foreground: Colors.white,
                    corner: const BorderRadius.only(
                      bottomRight: Radius.circular(20),
                    ),
                    onTap: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogAction extends StatelessWidget {
  const _DialogAction({
    required this.label,
    required this.background,
    required this.foreground,
    required this.corner,
    required this.onTap,
  });

  final String label;
  final Color background;
  final Color foreground;
  final BorderRadius corner;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      child: InkWell(
        onTap: onTap,
        customBorder: RoundedRectangleBorder(borderRadius: corner),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.button.copyWith(color: foreground),
            ),
          ),
        ),
      ),
    );
  }
}

class CrownMark extends StatelessWidget {
  const CrownMark({required this.size, required this.color, super.key});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * _CrownPainter.aspect,
      child: CustomPaint(painter: _CrownPainter(color)),
    );
  }
}

class _CrownPainter extends CustomPainter {
  _CrownPainter(this.color);

  static const double _left = 32.6;
  static const double _top = 34.3;
  static const double _width = 42.8;
  static const double _height = 34.9;
  static const double aspect = _height / _width;

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / _width;
    Offset p(double x, double y) =>
        Offset((x - _left) * scale, (y - _top) * scale);

    final paint = Paint()
      ..color = color
      ..isAntiAlias = true;

    final crown = Path()
      ..moveTo(p(38.5, 62.5).dx, p(38.5, 62.5).dy)
      ..lineTo(p(35.2, 43.8).dx, p(35.2, 43.8).dy)
      ..lineTo(p(45.4, 51.6).dx, p(45.4, 51.6).dy)
      ..lineTo(p(54.0, 39.5).dx, p(54.0, 39.5).dy)
      ..lineTo(p(62.6, 51.6).dx, p(62.6, 51.6).dy)
      ..lineTo(p(72.8, 43.8).dx, p(72.8, 43.8).dy)
      ..lineTo(p(69.5, 62.5).dx, p(69.5, 62.5).dy)
      ..close();
    canvas.drawPath(crown, paint);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(p(37.6, 64.4), p(70.4, 69.2)),
        Radius.circular(2.4 * scale),
      ),
      paint,
    );

    for (final jewel in const [
      [35.2, 42.2, 2.6],
      [72.8, 42.2, 2.6],
      [54.0, 37.4, 3.1],
    ]) {
      canvas.drawCircle(
        p(jewel[0], jewel[1]),
        jewel[2] * scale,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_CrownPainter oldDelegate) => oldDelegate.color != color;
}
