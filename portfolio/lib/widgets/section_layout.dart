import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/palette.dart';

/// Below this width the page switches to its phone layouts: the header gets a
/// menu button and a jump bar, grids collapse to one column, and the contact
/// rows tighten up.
const double kPhoneBreakpoint = 720;

/// Widest the page content ever gets, so lines stay readable on a big monitor.
const double kMaxContentWidth = 1240;

bool isPhone(BuildContext context) =>
    MediaQuery.sizeOf(context).width < kPhoneBreakpoint;

/// Side padding that grows with the window, from 20px on a phone to 64px.
double pageGutter(double width) => (width * 0.05).clamp(20.0, 64.0);

/// Body copy and UI text: IBM Plex Sans.
TextStyle bodyStyle({
  required double size,
  required Color color,
  FontWeight weight = FontWeight.w400,
  double? height,
  double letterSpacing = 0,
}) => GoogleFonts.ibmPlexSans(
  fontSize: size,
  color: color,
  fontWeight: weight,
  height: height,
  letterSpacing: letterSpacing,
);

/// Headlines: Big Shoulders, the condensed industrial face that carries the
/// "torch to keyboard" story (Google Fonts now ships Big Shoulders Display as
/// this one family; the Figma file uses the Display cut). Always capitals.
TextStyle displayStyle({
  required double size,
  required Color color,
  FontWeight weight = FontWeight.w800,
  double height = 0.9,
  double letterSpacing = 0,
}) => GoogleFonts.bigShoulders(
  fontSize: size,
  color: color,
  fontWeight: weight,
  height: height,
  letterSpacing: letterSpacing,
);

/// Only for code, inside the editor mock-up.
TextStyle codeStyle({
  required double size,
  required Color color,
  FontWeight weight = FontWeight.w400,
  double? height,
}) => GoogleFonts.ibmPlexMono(
  fontSize: size,
  color: color,
  fontWeight: weight,
  height: height,
);

/// Makes [builder]'s output an external link: opens [url] (a new tab on the
/// web) on click, tap or Enter, shows the pointer, and tells [builder] when
/// it is hovered or keyboard-focused so it can show that.
class ExternalLink extends StatefulWidget {
  const ExternalLink({
    super.key,
    required this.url,
    required this.label,
    required this.builder,
  });

  final String url;

  /// What a screen reader announces for the link.
  final String label;
  final Widget Function(BuildContext context, bool active) builder;

  @override
  State<ExternalLink> createState() => _ExternalLinkState();
}

class _ExternalLinkState extends State<ExternalLink> {
  bool _hovering = false;
  bool _focused = false;

  void _open() => launchUrl(Uri.parse(widget.url), webOnlyWindowName: '_blank');

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      mouseCursor: SystemMouseCursors.click,
      onShowHoverHighlight: (v) => setState(() => _hovering = v),
      onShowFocusHighlight: (v) => setState(() => _focused = v),
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            _open();
            return null;
          },
        ),
      },
      child: Semantics(
        link: true,
        label: widget.label,
        onTap: _open,
        excludeSemantics: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _open,
          child: widget.builder(context, _hovering || _focused),
        ),
      ),
    );
  }
}

/// A display headline that never wraps mid-line: each line keeps its words,
/// and the block shrinks to fit when the column is narrower than [size]
/// allows (the web font's widths differ from the design tool's, and French
/// lines run longer).
class FitHeadline extends StatelessWidget {
  const FitHeadline(
    this.text, {
    super.key,
    required this.size,
    required this.color,
    this.height = 0.88,
  });

  final String text;
  final double size;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.scaleDown,
    alignment: Alignment.centerLeft,
    child: Text(
      text.toUpperCase(),
      softWrap: false,
      style: displayStyle(size: size, color: color, height: height),
    ),
  );
}

/// Display size for a section headline at this window width.
double sectionHeadlineSize(double width) => (width * 0.062).clamp(48.0, 88.0);

/// One full-width band of the page. Paints [background] edge to edge and
/// holds [child] in a column capped at [kMaxContentWidth] with responsive
/// side and vertical padding.
class PageSection extends StatelessWidget {
  const PageSection({
    super.key,
    required this.child,
    this.background,
    this.decoration,
    this.bordered = false,
    this.topPadding,
    this.bottomPadding,
  });

  final Widget child;
  final Color? background;

  /// Extra paint over [background] (the Synapse section's violet glow).
  final Gradient? decoration;

  /// Hairline along the top edge, between bands.
  final bool bordered;

  /// Overrides for the default vertical padding.
  final double? topPadding;
  final double? bottomPadding;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final vertical = (width * 0.08).clamp(64.0, 120.0);
    final hairline = paletteOf(context).line;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: background,
        border: bordered ? Border(top: BorderSide(color: hairline)) : null,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: decoration),
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
      ),
    );
  }
}

/// The temper bead: a short bar in the heat-tint gradient, drawn under the
/// two biggest headlines (hero and contact) and nowhere else.
class TemperBead extends StatelessWidget {
  const TemperBead({super.key, this.width = 320, this.height = 6});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      gradient: paletteOf(context).temperGradient,
      borderRadius: BorderRadius.circular(height / 2),
    ),
  );
}

/// Headline (display face, capitals) and optional subhead — the opening beat
/// of a section.
class SectionHeading extends StatelessWidget {
  const SectionHeading({super.key, required this.headline, this.subhead});

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
        constraints: const BoxConstraints(maxWidth: 760),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              headline.toUpperCase(),
              style: displayStyle(
                size: sectionHeadlineSize(width),
                color: palette.ink,
              ),
            ),
            if (subhead != null) ...[
              SizedBox(height: phone ? 12 : 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Text(
                  subhead!,
                  style: bodyStyle(
                    size: phone ? 16 : 18,
                    color: palette.secondary,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A fully rounded label pill. [dot] adds a small state dot in front.
class Pill extends StatelessWidget {
  const Pill(
    this.label, {
    super.key,
    required this.background,
    required this.color,
    this.borderColor,
    this.vertical = 6,
    this.horizontal = 12,
    this.dot = false,
    this.dotColor,
    this.size = 13,
  });

  final bool dot;

  /// The dot's colour when it means something other than the label colour.
  final Color? dotColor;

  final String label;
  final Color background;
  final Color color;
  final Color? borderColor;
  final double vertical;
  final double horizontal;
  final double size;

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
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: dotColor ?? color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
            style: bodyStyle(size: size, color: color, weight: FontWeight.w500),
          ),
        ),
      ],
    ),
  );
}

/// Primary (straw fill) or secondary (outline) button.
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
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    final fg = widget.filled ? palette.onAccent : palette.ink;
    final bg = widget.filled
        ? Color.lerp(palette.accent, palette.ink, _hovering ? 0.12 : 0)!
        : (_hovering ? palette.hover : Colors.transparent);
    return FocusableActionDetector(
      mouseCursor: SystemMouseCursors.click,
      onShowHoverHighlight: (v) => setState(() => _hovering = v),
      onShowFocusHighlight: (v) => setState(() => _focused = v),
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.onPressed();
            return null;
          },
        ),
      },
      child: Semantics(
        button: true,
        label: widget.label,
        onTap: widget.onPressed,
        excludeSemantics: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onPressed,
          child: Container(
            constraints: BoxConstraints(
              minHeight: 48,
              minWidth: widget.expand ? double.infinity : 0,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 22),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _focused
                    ? palette.ink
                    : (widget.filled ? Colors.transparent : palette.lineStrong),
                width: _focused ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.label,
                  style: bodyStyle(
                    size: 15,
                    color: fg,
                    weight: FontWeight.w600,
                  ),
                ),
                if (widget.icon != null) ...[
                  const SizedBox(width: 8),
                  Icon(widget.icon, size: 17, color: fg),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A card with a dashed border and faint fill: used for the one suggestion
/// the Code Coach mock-up shows.
class DashedCard extends StatelessWidget {
  const DashedCard({
    super.key,
    required this.child,
    required this.color,
    this.padding = const EdgeInsets.all(14),
    this.radius = 12,
  });

  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: DashedRRectPainter(
        color: color.withValues(alpha: 0.55),
        radius: radius,
      ),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
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

/// The site's mark: initials on a temper-gradient tile.
class InitialsMark extends StatelessWidget {
  const InitialsMark({super.key, this.size = 36});

  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: palette.temper,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.24),
      ),
      child: Text(
        'SR',
        style: displayStyle(
          size: size * 0.56,
          color: const Color(0xFF1A1205),
          height: 1,
        ),
      ),
    );
  }
}

/// The Synapse mark: three linked nodes on a deep-violet tile (the app's
/// `public/img/mark.svg`), drawn natively so it needs no asset.
class SynapseMark extends StatelessWidget {
  const SynapseMark({super.key, this.size = 32});

  final double size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: const _MarkPainter());
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
