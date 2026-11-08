import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/palette.dart';

/// Below this width the page switches to its phone layouts: the header gets a
/// menu button and a jump bar, grids collapse to one column, and the contact
/// cards become a single grouped list.
const double kPhoneBreakpoint = 720;

/// Widest the page content ever gets, so lines stay readable on a big monitor.
const double kMaxContentWidth = 1180;

bool isPhone(BuildContext context) =>
    MediaQuery.sizeOf(context).width < kPhoneBreakpoint;

/// Side padding that grows with the window, from 20px on a phone to 64px.
double pageGutter(double width) => (width * 0.05).clamp(20.0, 64.0);

TextStyle interStyle({
  required double size,
  required Color color,
  FontWeight weight = FontWeight.w400,
  double? height,
  double letterSpacing = 0,
}) => GoogleFonts.inter(
  fontSize: size,
  color: color,
  fontWeight: weight,
  height: height,
  letterSpacing: letterSpacing,
);

TextStyle monoStyle({
  required double size,
  required Color color,
  FontWeight weight = FontWeight.w400,
  double? height,
  double letterSpacing = 0,
}) => GoogleFonts.jetBrainsMono(
  fontSize: size,
  color: color,
  fontWeight: weight,
  height: height,
  letterSpacing: letterSpacing,
);

/// One full-width band of the page. Paints [background] edge to edge and
/// holds [child] in a column capped at [kMaxContentWidth] with responsive
/// side and vertical padding.
class PageSection extends StatelessWidget {
  const PageSection({
    super.key,
    required this.child,
    this.background,
    this.bordered = false,
    this.topPadding,
    this.bottomPadding,
  });

  final Widget child;
  final Color? background;

  /// Hairline above and below, for the alternate-background bands.
  final bool bordered;

  /// Overrides for the default vertical padding.
  final double? topPadding;
  final double? bottomPadding;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final vertical = (width * 0.08).clamp(64.0, 112.0);
    final hairline = paletteOf(context).line;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: background,
        border: bordered
            ? Border(
                top: BorderSide(color: hairline),
                bottom: BorderSide(color: hairline),
              )
            : null,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              pageGutter(width),
              topPadding ?? vertical,
              pageGutter(width),
              bottomPadding ?? vertical,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Small monospace caps label ("GOAL", "PAST PIECES"...).
class MonoLabel extends StatelessWidget {
  const MonoLabel(this.text, {super.key, this.color, this.size = 12});

  final String text;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: monoStyle(
      size: size,
      color: color ?? paletteOf(context).tertiary,
      weight: FontWeight.w500,
      letterSpacing: size * 0.08,
    ),
  );
}

/// The app's mono kicker: a small lavender square, then an uppercase label in
/// the faint text colour (`.eyebrow` on the Synapse site).
class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.size = 12});

  final String text;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: palette.accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 9),
        Flexible(child: MonoLabel(text.toUpperCase(), size: size)),
      ],
    );
  }
}

/// Eyebrow, headline and optional subhead — the opening beat of a section.
class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    required this.eyebrow,
    required this.headline,
    this.subhead,
  });

  final String eyebrow;
  final String headline;
  final String? subhead;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final palette = paletteOf(context);
    final phone = isPhone(context);
    // Align loosens the parent's (often tight, stretched) width so the 680px
    // cap actually applies instead of being overridden by it.
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Eyebrow(eyebrow, size: phone ? 11 : 12),
            SizedBox(height: phone ? 14 : 16),
            Text(
              headline,
              style: interStyle(
                size: (width * 0.036).clamp(32.0, 48.0),
                color: palette.ink,
                weight: FontWeight.w700,
                height: 1.08,
                letterSpacing: phone ? -1.0 : -1.5,
              ),
            ),
            if (subhead != null) ...[
              SizedBox(height: phone ? 12 : 14),
              Text(
                subhead!,
                style: interStyle(
                  size: (width * 0.013).clamp(16.0, 18.0),
                  color: palette.secondary,
                  height: 1.6,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A fully rounded mono status pill, like the app's `.pill`. [dot] adds the
/// small state dot the app puts in front of "done"/"iterating" pills.
class Pill extends StatelessWidget {
  const Pill(
    this.label, {
    super.key,
    required this.background,
    required this.color,
    this.borderColor,
    this.vertical = 5,
    this.horizontal = 11,
    this.dot = false,
  });

  final bool dot;

  final String label;
  final Color background;
  final Color color;
  final Color? borderColor;
  final double vertical;
  final double horizontal;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(999),
      border: borderColor == null ? null : Border.all(color: borderColor!),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (dot) ...[
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
        ],
        Flexible(
          child: Text(
            label,
            style: monoStyle(size: 11.5, color: color, weight: FontWeight.w500),
          ),
        ),
      ],
    ),
  );
}

/// Primary (inverted text colour) or ghost (hairline) button used by the hero,
/// matching the app's `.sb-btn-primary` / `.sb-btn-secondary`.
class PillButton extends StatefulWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.filled = false,
    this.icon,
    this.expand = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool filled;
  final IconData? icon;

  /// Fill the available width (the phone layout stacks buttons full width).
  final bool expand;

  @override
  State<PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<PillButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    // Primary inverts the page: ink fill, page-coloured text. Ghost is a
    // hairline outline with muted text that lifts on hover.
    final fg = widget.filled
        ? palette.bg
        : (_hovering ? palette.ink : palette.secondary);
    final bg = widget.filled
        ? palette.ink.withValues(alpha: _hovering ? 0.9 : 1)
        : (_hovering ? palette.hover : Colors.transparent);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Semantics(
        button: true,
        label: widget.label,
        excludeSemantics: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onPressed,
          child: Container(
            constraints: BoxConstraints(
              minHeight: 44,
              minWidth: widget.expand ? double.infinity : 0,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: widget.filled ? Colors.transparent : palette.line,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.label,
                  style: interStyle(
                    size: 14.5,
                    color: fg,
                    weight: widget.filled ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                if (widget.icon != null) ...[
                  const SizedBox(width: 8),
                  Icon(widget.icon, size: 16, color: fg),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A card with the app's dashed lavender "AI suggestion" border and faint
/// lavender fill: used wherever the site shows something the AI proposes.
class AiCard extends StatelessWidget {
  const AiCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.radius = 12,
    this.palette,
  });

  /// Overrides the surrounding theme, for mock-ups that stay dark in both
  /// site themes (the VS Code window).
  final AppPalette? palette;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final palette = this.palette ?? paletteOf(context);
    return CustomPaint(
      foregroundPainter: DashedRRectPainter(
        color: palette.aiLine,
        radius: radius,
        strokeWidth: 1,
      ),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: palette.aiFaint,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: child,
      ),
    );
  }
}

/// A dashed rounded rectangle just inside its box.
class DashedRRectPainter extends CustomPainter {
  const DashedRRectPainter({
    required this.color,
    required this.radius,
    this.strokeWidth = 1,
    this.dash = 5,
    this.gap = 4,
  });

  final Color color;
  final double radius;
  final double strokeWidth;
  final double dash;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(strokeWidth / 2);
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    for (final PathMetric metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = math.min(distance + dash, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(DashedRRectPainter old) =>
      old.color != color ||
      old.radius != radius ||
      old.strokeWidth != strokeWidth ||
      old.dash != dash ||
      old.gap != gap;
}

/// The app's graph canvas: a quiet dot grid that fades out away from the top
/// centre (the website hero's `radial-gradient` mask).
class DotGridPainter extends CustomPainter {
  const DotGridPainter({required this.color, this.step = 22});

  final Color color;
  final double step;

  @override
  void paint(Canvas canvas, Size size) {
    // Elliptical falloff: full strength near the top centre, gone by ~80%.
    final cx = size.width / 2;
    final rx = size.width * 0.8;
    final ry = size.height * 0.7 + 1;
    final paint = Paint();
    for (var y = step / 2; y < size.height; y += step) {
      for (var x = step / 2; x < size.width; x += step) {
        final dx = (x - cx) / rx;
        final dy = y / ry;
        final d = math.sqrt(dx * dx + dy * dy);
        final fade = d <= 0.2 ? 1.0 : (1 - (d - 0.2) / 0.6).clamp(0.0, 1.0);
        if (fade <= 0) continue;
        paint.color = color.withValues(alpha: color.a * fade);
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(DotGridPainter old) =>
      old.color != color || old.step != step;
}

/// The Synapse mark: three linked nodes on a deep-violet tile (the app's
/// `public/img/mark.svg`), drawn natively so it needs no asset.
class SynapseMark extends StatelessWidget {
  const SynapseMark({super.key, this.size = 32});

  final double size;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size.square(size),
    painter: const _MarkPainter(),
  );
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter();

  static const _tile = Color(0xFF1C1830);
  static const _stroke = Color(0xFFB9A6FF);

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 32;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(9 * k),
      ),
      Paint()..color = _tile,
    );
    final paint = Paint()
      ..color = _stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8 * k
      ..strokeCap = StrokeCap.round;
    Offset p(double x, double y) => Offset((x + 4) * k, (y + 4) * k);
    for (final c in [p(6, 7), p(18, 6), p(12, 18)]) {
      canvas.drawCircle(c, 2.5 * k, paint);
    }
    final links = Path()
      ..moveTo(p(7.4, 9.3).dx, p(7.4, 9.3).dy)
      ..lineTo(p(10.8, 15.7).dx, p(10.8, 15.7).dy)
      ..moveTo(p(16.8, 8.2).dx, p(16.8, 8.2).dy)
      ..lineTo(p(13.2, 15.7).dx, p(13.2, 15.7).dy)
      ..moveTo(p(8.5, 6.8).dx, p(8.5, 6.8).dy)
      ..lineTo(p(16, 6.8).dx, p(16, 6.8).dy);
    canvas.drawPath(links, paint);
  }

  @override
  bool shouldRepaint(_MarkPainter old) => false;
}

/// Lays children out in equal-width columns sized from the real available
/// width, with every card in a row sharing the tallest card's height — the
/// same behaviour as CSS `repeat(auto-fit, minmax(min-width, 1fr))`.
///
/// Children must not contain a `LayoutBuilder`: each row is wrapped in an
/// `IntrinsicHeight`, which can't measure one.
class AutoFitGrid extends StatelessWidget {
  const AutoFitGrid({
    super.key,
    required this.children,
    required this.minItemWidth,
    required this.spacing,
    this.runSpacing,
  });

  final List<Widget> children;
  final double minItemWidth;
  final double spacing;
  final double? runSpacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth;
        final columns = ((available + spacing) / (minItemWidth + spacing))
            .floor()
            .clamp(1, children.length);
        final itemWidth = (available - spacing * (columns - 1)) / columns;

        final rows = <List<Widget>>[
          for (var i = 0; i < children.length; i += columns)
            children.sublist(
              i,
              i + columns > children.length ? children.length : i + columns,
            ),
        ];

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var r = 0; r < rows.length; r++) ...[
              if (r > 0) SizedBox(height: runSpacing ?? spacing),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var c = 0; c < rows[r].length; c++) ...[
                      if (c > 0) SizedBox(width: spacing),
                      SizedBox(width: itemWidth, child: rows[r][c]),
                    ],
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
