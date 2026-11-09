library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/common.dart';

enum BootStage {

  preparing,

  loadingModel,

  ready,
}

class BootPage extends StatefulWidget {
  const BootPage({required this.stage, this.error, this.onRetry, super.key});

  final BootStage stage;
  final String? error;
  final VoidCallback? onRetry;

  @override
  State<BootPage> createState() => _BootPageState();
}

class _BootPageState extends State<BootPage> with TickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat();

  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..forward();

  @override
  void dispose() {
    _spin.dispose();
    _enter.dispose();
    super.dispose();
  }

  Animation<double> _staggered(double begin, double end) => CurvedAnimation(
        parent: _enter,
        curve: Interval(begin, end, curve: Curves.easeOutCubic),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final palette = context.palette;
    final failed = widget.error != null;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    _FadeSlide(
                      animation: _staggered(0.0, 0.55),
                      child: SizedBox(
                        width: 160,
                        height: 160,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (!failed)
                              AnimatedBuilder(
                                animation: _spin,
                                builder: (context, child) => Transform.rotate(
                                  angle: _spin.value * 2 * math.pi,
                                  child: child,
                                ),
                                child: _OrbitArc(color: palette.gold),
                              ),
                            BrandMark(size: failed ? 86 : 96),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _FadeSlide(
                      animation: _staggered(0.18, 0.72),
                      child: Text(
                        l10n.appTitle,
                        textAlign: TextAlign.center,
                        style: AppText.brand,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm + 2),
                    _FadeSlide(
                      animation: _staggered(0.3, 0.85),
                      child: Text(
                        l10n.appTagline,
                        textAlign: TextAlign.center,
                        style: AppText.bodyDim.copyWith(
                          fontSize: 13.5,
                          color: palette.textDim,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (failed)
                      _FadeSlide(
                        animation: _staggered(0.4, 1.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              color: palette.danger,
                              size: 28,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              l10n.loadingFailed,
                              textAlign: TextAlign.center,
                              style: AppText.body,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              widget.error!,
                              textAlign: TextAlign.center,
                              style: AppText.bodyDim.copyWith(
                                fontSize: 12,
                                color: palette.textDim,
                              ),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            if (widget.onRetry != null)
                              AppPrimaryButton(
                                label: l10n.retry,
                                icon: Icons.refresh_rounded,
                                onPressed: widget.onRetry,
                              ),
                          ],
                        ),
                      )
                    else
                      _FadeSlide(
                        animation: _staggered(0.42, 1.0),
                        child: Column(
                          children: [
                            _ProgressLine(
                              animation: _spin,
                              color: palette.gold,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              switch (widget.stage) {
                                BootStage.preparing => l10n.loadingPreparing,
                                BootStage.loadingModel => l10n.loadingModel,
                                BootStage.ready => l10n.loadingReady,
                              },
                              textAlign: TextAlign.center,
                              style: AppText.label.copyWith(
                                fontSize: 11.5,
                                color: palette.textDim,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: AppSpacing.xl),
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

class _OrbitArc extends StatelessWidget {
  const _OrbitArc({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 150,
      child: CustomPaint(painter: _ArcPainter(color)),
    );
  }
}

class _ArcPainter extends CustomPainter {
  _ArcPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [
          color.withValues(alpha: 0),
          color.withValues(alpha: 0.4),
          color,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(rect);
    canvas.drawArc(rect.deflate(2), -math.pi / 2, math.pi * 1.35, false, paint);
  }

  @override
  bool shouldRepaint(_ArcPainter oldDelegate) => oldDelegate.color != color;
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine({required this.animation, required this.color});

  final Animation<double> animation;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Stack(
          children: [
            Positioned.fill(
              child: ColoredBox(color: color.withValues(alpha: 0.16)),
            ),
            AnimatedBuilder(
              animation: animation,
              builder: (context, _) {
                final t = animation.value;
                final travel = t < 0.5 ? t * 2 : (1 - t) * 2;
                return Align(
                  alignment: Alignment(travel * 2 - 1, 0),
                  child: FractionallySizedBox(
                    widthFactor: 0.4,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        gradient: LinearGradient(
                          colors: [
                            color.withValues(alpha: 0),
                            color,
                            color.withValues(alpha: 0),
                          ],
                        ),
                      ),
                      child: const SizedBox(height: 3),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FadeSlide extends StatelessWidget {
  const _FadeSlide({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => Opacity(
        opacity: animation.value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, (1 - animation.value) * 16),
          child: child,
        ),
      ),
    );
  }
}
