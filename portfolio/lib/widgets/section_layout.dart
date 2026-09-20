import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/palette.dart';

/// Responsive font size for every [SectionIntro] headline: smaller on phones,
/// larger on desktop. `MediaQuery`'s width (not a `LayoutBuilder` constraint)
/// is what's passed in here — see [SectionIntro.build] below.
double _headlineSize(double width) {
  if (width < 600) return 34;
  if (width < 900) return 44;
  return 56;
}

/// Full-bleed band of colour holding one section's content, centred and capped
/// so the copy never runs wider than it reads well.
///
/// Setting `minHeight` and `maxHeight` to the *same* value (the full screen
/// height) is what makes every section that uses this shell occupy exactly
/// one screen's worth of scrolling, regardless of how much content it has —
/// scrolling the page therefore advances roughly one section at a time.
/// Content inside still has to fit that fixed height on its own (usually via
/// `Expanded` soaking up the leftover space below the intro text); nothing
/// here makes the child scrollable if it's too tall.
///
/// The hobbies section intentionally does *not* use this shell — it wants a
/// full-bleed, edge-to-edge layout with no side padding or 980px cap, so it
/// builds its own sizing from scratch instead.
class SectionShell extends StatelessWidget {
  const SectionShell({
    super.key,
    required this.background,
    required this.child,
    this.scrollable = true,
  });

  final Color background;
  final Widget child;

  /// False for a section whose own `child` already handles overflow itself
  /// (About's body does its own LayoutBuilder + SingleChildScrollView) —
  /// wrapping an already-scrollable child in a second one gives the inner
  /// one an unbounded height to work with, which crashes rather than scrolls.
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    final content = Center(
      child: ConstrainedBox(
        // Caps the readable content width even on very wide monitors —
        // without this, body text on a 2000px-wide window would stretch
        // into unreadably long lines.
        constraints: const BoxConstraints(maxWidth: 980),
        child: child,
      ),
    );

    return Container(
      width: double.infinity,
      color: background,
      constraints: BoxConstraints(minHeight: size.height, maxHeight: size.height),
      padding: EdgeInsets.symmetric(
        vertical: size.width < 600 ? 80 : 120,
        horizontal: 24,
      ),
      // LayoutBuilder + SingleChildScrollView is a safety net, not the
      // common case: most sections' content fits the fixed height above
      // exactly, in which case ConstrainedBox's minHeight makes this behave
      // just like a plain Center. But a phone-height screen combined with
      // this section's own padding can leave less room than its content
      // actually needs (e.g. Contact's four cards stacked in one column on
      // a narrow phone) — without this, that content would overflow instead
      // of scrolling.
      child: !scrollable
          ? content
          : LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: content,
                ),
              ),
            ),
    );
  }
}

/// Eyebrow, headline and subhead — the opening beat of every section.
class SectionIntro extends StatelessWidget {
  const SectionIntro({
    super.key,
    required this.eyebrow,
    required this.headline,
    required this.subhead,
    this.dark = false,
  });

  final String eyebrow;
  final String headline;
  final String subhead;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: dark ? kBlue : kGray,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          headline,
          style: GoogleFonts.inter(
            fontSize: _headlineSize(width),
            fontWeight: FontWeight.w700,
            letterSpacing: -1.4,
            height: 1.08,
            color: dark ? Colors.white : kInk,
          ),
        ),
        const SizedBox(height: 20),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Text(
            subhead,
            style: GoogleFonts.inter(
              fontSize: width < 600 ? 17 : 20,
              height: 1.55,
              letterSpacing: -0.2,
              color: kGray,
            ),
          ),
        ),
      ],
    );
  }
}

/// Lays children out in equal-width columns sized from the real available
/// width, with every card in a row sharing the tallest card's height.
///
/// This exists instead of a plain [Wrap] or [GridView] because neither of
/// those stretches items in the same row to a shared height by default — a
/// short "About" card next to a tall "Contact" card would otherwise look
/// misaligned. The trick is `IntrinsicHeight` + `CrossAxisAlignment.stretch`:
/// `IntrinsicHeight` measures the row's children once to find the tallest
/// one, then `stretch` makes every child in that `Row` match it.
class CardGrid extends StatelessWidget {
  const CardGrid({
    super.key,
    required this.children,
    required this.columnsFor,
    required this.spacing,
  });

  final List<Widget> children;

  /// Given the grid's available width, returns how many columns to use —
  /// each call site defines its own breakpoints (see about/contact/hobbies
  /// sections for examples).
  final int Function(double width) columnsFor;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = columnsFor(constraints.maxWidth);
        // Divide the remaining width (total width minus the gaps between
        // columns) evenly, rather than giving each card a fixed width —
        // this is what lets the grid fill whatever space it's given instead
        // of leaving a gap or overflowing.
        final cardWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        // Chop the flat list of children into `columns`-sized rows, e.g.
        // 6 children over 4 columns -> [[0,1,2,3], [4,5]].
        final rows = <List<Widget>>[];
        for (var i = 0; i < children.length; i += columns) {
          final end = i + columns;
          rows.add(
            children.sublist(i, end > children.length ? children.length : end),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var r = 0; r < rows.length; r++) ...[
              if (r > 0) SizedBox(height: spacing),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var c = 0; c < rows[r].length; c++) ...[
                      if (c > 0) SizedBox(width: spacing),
                      SizedBox(width: cardWidth, child: rows[r][c]),
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
