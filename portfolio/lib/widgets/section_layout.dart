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

/// The height of the area sections are shown in (the window minus the pinned
/// header). `Home` provides it so every [PageSection] can be exactly one
/// screen tall.
class ViewportHeight extends InheritedWidget {
  const ViewportHeight({super.key, required this.height, required super.child});

  final double height;

  static double? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ViewportHeight>()?.height;

  @override
  bool updateShouldNotify(ViewportHeight oldWidget) =>
      oldWidget.height != height;
}

/// One full-width band of the page, never taller than the window.
///
/// The band is exactly one screen tall (the height `Home` gives it through
/// [ViewportHeight]); [child] is centred in it, held to [kMaxContentWidth],
/// and scaled down uniformly, text included, if it would otherwise be taller
/// than the screen. A section short enough to fit is left at its natural size.
class PageSection extends StatelessWidget {
  const PageSection({
    super.key,
    required this.child,
    this.background,
    this.bordered = false,
  });

  final Widget child;
  final Color? background;

  /// Hairline above and below, for the alternate-background bands.
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = ViewportHeight.maybeOf(context);
    final vertical = isPhone(context) ? 20.0 : 40.0;
    final hairline = paletteOf(context).surface(0.08);
    return Container(
      width: double.infinity,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        border: bordered
            ? Border(
                top: BorderSide(color: hairline),
                bottom: BorderSide(color: hairline),
              )
            : null,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: pageGutter(width),
            vertical: vertical,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) => FittedBox(
              // Scales down only: a section that already fits is untouched.
              fit: BoxFit.scaleDown,
              child: SizedBox(width: constraints.maxWidth, child: child),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small monospace caps label ("WORK", "GOAL"...).
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
      color: color ?? paletteOf(context).accent,
      letterSpacing: 1.2,
    ),
  );
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
            MonoLabel(eyebrow.toUpperCase(), size: phone ? 11 : 12),
            SizedBox(height: phone ? 12 : 14),
            Text(
              headline,
              style: interStyle(
                size: (width * 0.046).clamp(36.0, 60.0),
                color: palette.ink,
                weight: FontWeight.w800,
                height: 1.05,
                letterSpacing: phone ? -1.2 : -1.6,
              ),
            ),
            if (subhead != null) ...[
              SizedBox(height: phone ? 12 : 14),
              Text(
                subhead!,
                style: interStyle(
                  size: (width * 0.014).clamp(16.0, 19.0),
                  color: palette.secondary,
                  height: 1.55,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A rounded pill label.
class Pill extends StatelessWidget {
  const Pill(
    this.label, {
    super.key,
    required this.background,
    required this.color,
    this.borderColor,
    this.vertical = 6,
    this.horizontal = 12,
  });

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
    child: Text(
      label,
      style: interStyle(size: 12, color: color, weight: FontWeight.w600),
    ),
  );
}

/// Filled (accent) or outlined pill-shaped button used by the hero.
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
    final fg = widget.filled ? palette.onAccent : palette.ink;
    final bg = widget.filled
        ? palette.accent
        : (_hovering ? palette.surface(0.08) : Colors.transparent);
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
              minHeight: 48,
              minWidth: widget.expand ? double.infinity : 0,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(999),
              border: widget.filled
                  ? null
                  : Border.all(color: palette.surface(0.22)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Flexible so a large system font wraps the label instead of
                // pushing it past the button's edge.
                Flexible(
                  child: Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    style: interStyle(
                      size: 15,
                      color: fg,
                      weight: FontWeight.w600,
                    ),
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
