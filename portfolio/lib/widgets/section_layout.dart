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
  // Identifiers like `SYS_SPECS::LOADOUT` should read literally, not as
  // JetBrains Mono's code ligatures.
  fontFeatures: const [FontFeature.disable('calt')],
);

/// Corner radius of HUD panels and cards; buttons and chips use
/// [kHudButtonRadius].
const double kHudRadius = 8;
const double kHudButtonRadius = 5;

/// The HUD card look: dark fill and a thin yellow border, at full strength
/// (with a soft glow) when [highlighted].
BoxDecoration hudDecoration(AppPalette palette, {bool highlighted = false}) =>
    BoxDecoration(
      color: palette.card.withValues(alpha: palette.dark ? 0.92 : 0.95),
      borderRadius: BorderRadius.circular(kHudRadius),
      border: Border.all(
        color: palette.accentAlpha(highlighted ? 0.9 : 0.32),
      ),
      boxShadow: highlighted && palette.dark
          ? [BoxShadow(color: palette.accentAlpha(0.12), blurRadius: 28)]
          : null,
    );

/// The height of the area sections are shown in (the window minus the CLI
/// bar, and the top bar on a phone). `Home` provides it so every [PageSection] can be exactly one
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
    this.fitToScreen = true,
  });

  final Widget child;
  final Color? background;

  /// Hairline above and below, for the alternate-background bands.
  final bool bordered;

  /// When true (default), forces the section to match [ViewportHeight] and scales
  /// content down if it exceeds the window. When false, the section sizes naturally
  /// and scrolls smoothly.
  final bool fitToScreen;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = ViewportHeight.maybeOf(context);
    final vertical = isPhone(context) ? 20.0 : 40.0;
    final hairline = paletteOf(context).surface(0.08);
    return Container(
      width: double.infinity,
      height: fitToScreen ? height : null,
      constraints: fitToScreen
          ? null
          : BoxConstraints(minHeight: height ?? 0),
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
          child: fitToScreen
              ? LayoutBuilder(
                  builder: (context, constraints) => FittedBox(
                    // Scales down only: a section that already fits is untouched.
                    fit: BoxFit.scaleDown,
                    child: SizedBox(width: constraints.maxWidth, child: child),
                  ),
                )
              : child,
        ),
      ),
    );
  }
}

/// Small monospace caps label ("WORK", "GOAL"...).
class MonoLabel extends StatelessWidget {
  const MonoLabel(
    this.text, {
    super.key,
    this.color,
    this.size = 12,
    this.weight = FontWeight.w500,
  });

  final String text;
  final Color? color;
  final double size;
  final FontWeight weight;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: monoStyle(
      size: size,
      color: color ?? paletteOf(context).accent,
      weight: weight,
      letterSpacing: 1.2,
    ),
  );
}

/// A small glowing dot + caps label, e.g. "● ONLINE".
class StatusTag extends StatelessWidget {
  const StatusTag(this.label, {super.key, required this.color, this.size = 11});

  final String label;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 6),
          ],
        ),
      ),
      const SizedBox(width: 8),
      Flexible(
        child: MonoLabel(
          label,
          color: color,
          size: size,
          weight: FontWeight.w700,
        ),
      ),
    ],
  );
}

/// The opening beat of a section, HUD style: a yellow `MOD_0x` tag and the
/// eyebrow on one line, a big monospace headline, an optional subhead, and a
/// hairline underneath.
class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    required this.eyebrow,
    required this.headline,
    this.subhead,
    this.module,
  });

  final String eyebrow;
  final String headline;
  final String? subhead;

  /// The `MOD_01`-style tag in front of the eyebrow, if any.
  final String? module;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final palette = paletteOf(context);
    final phone = isPhone(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(bottom: phone ? 14 : 18),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: palette.surface(0.14))),
      ),
      // Align loosens the parent's (often tight, stretched) width so the 760px
      // cap actually applies instead of being overridden by it.
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (module != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: palette.accent,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: MonoLabel(
                        module!,
                        color: palette.onAccent,
                        size: phone ? 10 : 11,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Flexible(
                    child: MonoLabel(
                      eyebrow.toUpperCase(),
                      size: phone ? 11 : 12,
                    ),
                  ),
                ],
              ),
              SizedBox(height: phone ? 12 : 14),
              Text(
                headline,
                style: monoStyle(
                  size: (width * 0.04).clamp(30.0, 54.0),
                  color: palette.ink,
                  weight: FontWeight.w800,
                  height: 1.05,
                  letterSpacing: phone ? -1.0 : -1.6,
                ),
              ),
              if (subhead != null) ...[
                SizedBox(height: phone ? 12 : 14),
                Text(
                  subhead!,
                  style: interStyle(
                    size: (width * 0.014).clamp(15.0, 18.0),
                    color: palette.secondary,
                    height: 1.55,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A small square-cornered tag (tech stack, status).
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
      borderRadius: BorderRadius.circular(3),
      border: Border.all(color: borderColor ?? color.withValues(alpha: 0.35)),
    ),
    child: Text(
      label.toUpperCase(),
      style: monoStyle(
        size: 11,
        color: color,
        weight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    ),
  );
}

/// Filled (hazard yellow) or outlined (yellow border) HUD button. The filled
/// one can carry a small [caption] above its label ("EXECUTE" over "VIEW
/// PROCESSES").
class PillButton extends StatefulWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.filled = false,
    this.icon,
    this.expand = false,
    this.caption,
  });

  final String label;
  final VoidCallback onPressed;
  final bool filled;
  final IconData? icon;
  final String? caption;

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
    final fg = widget.filled
        ? palette.onAccent
        : (_hovering ? palette.accent : palette.ink);
    final bg = widget.filled
        ? (_hovering
              ? Color.lerp(palette.accent, Colors.white, 0.25)!
              : palette.accent)
        : (_hovering ? palette.accentAlpha(0.08) : Colors.transparent);
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            constraints: BoxConstraints(
              minHeight: 50,
              minWidth: widget.expand ? double.infinity : 0,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(kHudButtonRadius),
              border: widget.filled ? null : Border.all(color: palette.accent),
              boxShadow: widget.filled && _hovering
                  ? [BoxShadow(color: palette.accentAlpha(0.35), blurRadius: 18)]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Flexible so a large system font wraps the label instead of
                // pushing it past the button's edge.
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.caption != null)
                        Text(
                          widget.caption!,
                          style: monoStyle(
                            size: 9,
                            color: fg.withValues(alpha: 0.7),
                            letterSpacing: 1.4,
                          ),
                        ),
                      Text(
                        widget.label.toUpperCase(),
                        style: monoStyle(
                          size: 13,
                          color: fg,
                          weight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.icon != null) ...[
                  const SizedBox(width: 10),
                  Icon(widget.icon, size: 18, color: fg),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Diagonal yellow/black hazard stripes filling whatever box it is given.
class HazardStripes extends StatelessWidget {
  const HazardStripes({super.key});

  @override
  Widget build(BuildContext context) =>
      const CustomPaint(painter: _HazardPainter(), child: SizedBox.expand());
}

class _HazardPainter extends CustomPainter {
  const _HazardPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..clipRect(Offset.zero & size)
      ..drawRect(Offset.zero & size, Paint()..color = Colors.black);
    final p = Paint()..color = kHudYellow;
    const band = 10.0;
    for (var x = -size.height; x < size.width + size.height; x += band * 2) {
      canvas.drawPath(
        Path()
          ..moveTo(x, size.height)
          ..lineTo(x + band, size.height)
          ..lineTo(x + band + size.height, 0)
          ..lineTo(x + size.height, 0)
          ..close(),
        p,
      );
    }
  }

  @override
  bool shouldRepaint(_HazardPainter oldDelegate) => false;
}

/// The faint 20px grid, plus CRT scanlines in the dark theme, painted once
/// behind the whole page.
class GridBackdrop extends StatelessWidget {
  const GridBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    return CustomPaint(
      painter: _GridPainter(
        line: palette.surface(palette.dark ? 0.07 : 0.06),
        scan: palette.dark ? Colors.white.withValues(alpha: 0.018) : null,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.line, this.scan});

  final Color line;
  final Color? scan;

  @override
  void paint(Canvas canvas, Size size) {
    const cell = 20.0;
    final p = Paint()
      ..color = line
      ..strokeWidth = 1;
    for (var x = 0.0; x <= size.width; x += cell) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (var y = 0.0; y <= size.height; y += cell) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
    if (scan != null) {
      final s = Paint()..color = scan!;
      for (var y = 0.0; y <= size.height; y += 3) {
        canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), s);
      }
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) =>
      oldDelegate.line != line || oldDelegate.scan != scan;
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
