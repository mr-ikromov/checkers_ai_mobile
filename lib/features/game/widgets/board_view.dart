library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/engine/position.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/theme/app_theme.dart';
import '../../../ui/widgets/common.dart';
import '../game_controller.dart';

class BoardView extends StatelessWidget {
  const BoardView({
    required this.controller,
    required this.showCoordinates,
    super.key,
  });

  final GameController controller;
  final bool showCoordinates;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight);
        final framePad = showCoordinates ? size * 0.062 : size * 0.028;
        final inner = size - framePad * 2;
        final cell = inner / 8;

        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(size * 0.045),
                    gradient: BoardColors.frameGradient,
                    boxShadow: [
                      BoxShadow(
                        color: context.palette.shadow,
                        blurRadius: 36,
                        offset: const Offset(0, 16),
                      ),
                    ],
                    border: Border.all(color: const Color(0x59000000)),
                  ),
                ),
              ),
              if (showCoordinates)
                Positioned.fill(
                  child: _Coordinates(
                    flipped: controller.flipped,
                    pad: framePad,
                    fontSize: math.max(8, size * 0.026),
                  ),
                ),
              Positioned(
                left: framePad,
                top: framePad,
                width: inner,
                height: inner,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(size * 0.012),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _SquaresPainter(
                            flipped: controller.flipped,
                            lastFrom: controller.lastFrom,
                            lastTo: controller.lastTo,
                          ),
                        ),
                      ),
                      ..._selection(cell),
                      ..._pieces(context, cell),
                      Positioned.fill(
                        child: _TapLayer(
                          cell: cell,
                          flipped: controller.flipped,
                          onTapSquare: controller.tapSquare,
                        ),
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

  Offset _origin(int square, double cell) {
    final row = sqRow[square];
    final col = sqCol[square];
    final dr = controller.flipped ? 7 - row : row;
    final dc = controller.flipped ? 7 - col : col;
    return Offset(dc * cell, dr * cell);
  }

  List<Widget> _selection(double cell) {
    final selected = controller.selected;
    if (selected == null) return const [];
    final at = _origin(selected, cell);
    return [
      Positioned(
        left: at.dx,
        top: at.dy,
        width: cell,
        height: cell,
        child: IgnorePointer(
          child: Padding(
            padding: EdgeInsets.all(cell * 0.055),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(cell * 0.18),
                border: Border.all(
                  color: BoardColors.accent,
                  width: math.max(2, cell * 0.055),
                ),
              ),
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> _pieces(BuildContext context, double cell) {
    final l10n = L10n.of(context);
    final duration = controller.animationDuration;
    return [
      for (final sprite in controller.sprites)
        AnimatedPositioned(
          key: ValueKey<int>(sprite.id),
          duration: duration,
          curve: Curves.easeInOutCubic,
          left: _origin(sprite.square, cell).dx,
          top: _origin(sprite.square, cell).dy,
          width: cell,
          height: cell,
          child: IgnorePointer(
            child: AnimatedScale(
              duration: duration,
              scale: sprite.captured ? 0.3 : 1.0,
              child: AnimatedOpacity(
                duration: duration,
                opacity: sprite.captured ? 0 : 1,
                child: Semantics(
                  label: l10n.boardSemanticsPiece(
                    squareName(sprite.square).toUpperCase(),
                    _pieceLabel(l10n, sprite.kind),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(cell * 0.11),
                    child: PieceView(kind: sprite.kind, size: cell * 0.78),
                  ),
                ),
              ),
            ),
          ),
        ),
    ];
  }

  String _pieceLabel(L10n l10n, int kind) => switch (kind) {
        1 => l10n.pieceWhiteMan,
        2 => l10n.pieceWhiteKing,
        -1 => l10n.pieceBlackMan,
        _ => l10n.pieceBlackKing,
      };
}

class PieceView extends StatelessWidget {
  const PieceView({required this.kind, required this.size, super.key});

  final int kind;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isWhite = kind > 0;
    final isKing = kind.abs() == 2;
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isWhite
              ? const RadialGradient(
                  center: Alignment(-0.24, -0.4),
                  radius: 0.95,
                  colors: [
                    Colors.white,
                    BoardColors.ivory,
                    Color(0xFFCCB98E),
                  ],
                  stops: [0.0, 0.46, 1.0],
                )
              : const RadialGradient(
                  center: Alignment(-0.24, -0.4),
                  radius: 0.95,
                  colors: [
                    Color(0xFF4C423A),
                    BoardColors.charcoal,
                    Color(0xFF0B0806),
                  ],
                  stops: [0.0, 0.52, 1.0],
                ),
          border: Border.all(
            color: isWhite ? BoardColors.ivoryEdge : BoardColors.charcoalEdge,
            width: math.max(1, size * 0.045),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(isWhite ? 0x73000000 : 0x8C000000),
              blurRadius: size * 0.16,
              offset: Offset(0, size * 0.06),
            ),
          ],
        ),
        child: Center(
          child: isKing
              ? CrownMark(
                  size: size * 0.46,
                  color:
                      isWhite ? BoardColors.walnut : BoardColors.accentBright,
                )
              : FractionallySizedBox(
                  widthFactor: 0.62,
                  heightFactor: 0.62,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isWhite
                            ? const Color(0x57785F37)
                            : const Color(0x2A000000),
                        width: math.max(1, size * 0.035),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _SquaresPainter extends CustomPainter {
  _SquaresPainter({
    required this.flipped,
    required this.lastFrom,
    required this.lastTo,
  });

  final bool flipped;
  final int? lastFrom;
  final int? lastTo;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / 8;
    final paint = Paint();

    for (var dr = 0; dr < 8; dr++) {
      for (var dc = 0; dc < 8; dc++) {
        final er = flipped ? 7 - dr : dr;
        final ec = flipped ? 7 - dc : dc;
        final isDark = (er + ec) % 2 == 1;
        final rect = Rect.fromLTWH(dc * cell, dr * cell, cell, cell);
        paint.shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [BoardColors.squareDark, BoardColors.squareDark2]
              : const [BoardColors.squareLight, BoardColors.squareLight2],
        ).createShader(rect);
        canvas.drawRect(rect, paint);
      }
    }

    paint.shader = null;
    paint.color = BoardColors.accent.withValues(alpha: 0.2);
    for (final square in [lastFrom, lastTo]) {
      if (square == null) continue;
      final row = sqRow[square];
      final col = sqCol[square];
      final dr = flipped ? 7 - row : row;
      final dc = flipped ? 7 - col : col;
      canvas.drawRect(Rect.fromLTWH(dc * cell, dr * cell, cell, cell), paint);
    }

    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0x73000000);
    canvas.drawRect(Offset.zero & size, border);
  }

  @override
  bool shouldRepaint(_SquaresPainter old) =>
      old.flipped != flipped ||
      old.lastFrom != lastFrom ||
      old.lastTo != lastTo;
}

class _Coordinates extends StatelessWidget {
  const _Coordinates({
    required this.flipped,
    required this.pad,
    required this.fontSize,
  });

  final bool flipped;
  final double pad;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    const files = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
    const ranks = ['8', '7', '6', '5', '4', '3', '2', '1'];
    final f = flipped ? files.reversed.toList() : files;
    final r = flipped ? ranks.reversed.toList() : ranks;
    final style = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
      color: const Color(0xFFBFA379),
    );

    Widget axis(List<String> labels, {required bool horizontal}) {
      final children = [
        for (final label in labels)
          Expanded(child: Center(child: Text(label, style: style))),
      ];
      return horizontal ? Row(children: children) : Column(children: children);
    }

    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            left: pad,
            right: pad,
            top: 0,
            height: pad,
            child: axis(f, horizontal: true),
          ),
          Positioned(
            left: pad,
            right: pad,
            bottom: 0,
            height: pad,
            child: axis(f, horizontal: true),
          ),
          Positioned(
            top: pad,
            bottom: pad,
            left: 0,
            width: pad,
            child: axis(r, horizontal: false),
          ),
          Positioned(
            top: pad,
            bottom: pad,
            right: 0,
            width: pad,
            child: axis(r, horizontal: false),
          ),
        ],
      ),
    );
  }
}

class _TapLayer extends StatelessWidget {
  const _TapLayer({
    required this.cell,
    required this.flipped,
    required this.onTapSquare,
  });

  final double cell;
  final bool flipped;
  final void Function(int square) onTapSquare;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (details) {
        final dc = (details.localPosition.dx / cell).floor().clamp(0, 7);
        final dr = (details.localPosition.dy / cell).floor().clamp(0, 7);
        final er = flipped ? 7 - dr : dr;
        final ec = flipped ? 7 - dc : dc;
        final square = rcSq[er * 8 + ec];
        if (square >= 0) onTapSquare(square);
      },
      child: const SizedBox.expand(),
    );
  }
}
