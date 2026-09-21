import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/palette.dart';

/// True on genuinely large desktop viewports — wide *and* tall, not just
/// wide. `SectionShell` always sizes a section to the *entire* height it's
/// given (so its background fills the screen behind it), but content sized
/// only off width breakpoints stays exactly as large on a big external
/// monitor as it is on a normal laptop, even with hundreds of extra pixels
/// of vertical room — which is what reads as a large empty gap above and
/// below the (unchanged) content block. Call sites that already scale for
/// width check this too, to grow a size tier further when there's actually
/// room to spare vertically as well.
bool isRoomyViewport(BuildContext context) {
  final size = MediaQuery.sizeOf(context);
  return size.width >= 1300 && size.height >= 950;
}

/// Responsive font size for every [SectionIntro] headline: smaller on phones,
/// larger on desktop, larger still on a roomy monitor. `MediaQuery`'s width
/// (not a `LayoutBuilder` constraint) is what's passed in here — see
/// [SectionIntro.build] below.
double _headlineSize(double width, bool roomy) {
  if (width < 600) return 30;
  if (width < 900) return 44;
  return roomy ? 72 : 56;
}

/// Full-bleed band of colour holding one section's content, centred and capped
/// so the copy never runs wider than it reads well.
///
/// `Home` shows exactly one section at a time, filling the screen below the
/// pinned header — this shell fills exactly the height it's *given* by that
/// (via the `LayoutBuilder` below), which is what makes it occupy the whole
/// remaining screen regardless of how much content it has. Content inside
/// still has to fit that height on its own (usually via `Expanded` soaking
/// up the leftover space below the intro text); nothing here makes the
/// child scrollable if it's too tall.
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
    final width = MediaQuery.sizeOf(context).width;
    // Widened on a roomy monitor, not just capped: each section's own body
    // text already caps itself narrower than this for readability (see
    // SectionIntro's subhead and About's bio), so this outer cap mainly
    // bounds *wide* elements — Projects' showcase image (which grows taller
    // with it, via its aspect ratio) and Contact's card grid — which is
    // exactly what needs the extra room on a screen with plenty to spare.
    final maxContentWidth = isRoomyViewport(context) ? 1180.0 : 980.0;

    final content = Center(
      child: ConstrainedBox(
        // Caps the readable content width even on very wide monitors —
        // without this, body text on a 2000px-wide window would stretch
        // into unreadably long lines.
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        child: child,
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        // The height `Home`'s Expanded actually gave this section — using
        // that instead of the screen's full height is what used to leave
        // every section 48px (the header's height) short of the room its
        // own padding math assumed, which showed up as content needing more
        // internal scroll than expected on a phone-size screen.
        final height = constraints.maxHeight;

        return Container(
          width: double.infinity,
          color: background,
          constraints: BoxConstraints(minHeight: height, maxHeight: height),
          padding: EdgeInsets.symmetric(
            vertical: width < 600 ? 48 : 120,
            horizontal: 24,
          ),
          // A safety net, not the common case: most sections' content fits
          // the height above exactly, in which case ConstrainedBox's
          // minHeight makes this behave just like a plain Center. But a
          // phone-height screen combined with this section's own padding
          // can leave less room than its content actually needs (e.g.
          // Contact's four cards stacked in one column on a narrow phone) —
          // without this, that content would overflow instead of scrolling.
          child: !scrollable
              ? content
              : SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: height),
                    child: content,
                  ),
                ),
        );
      },
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
    final roomy = isRoomyViewport(context);

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
            fontSize: _headlineSize(width, roomy),
            fontWeight: FontWeight.w700,
            letterSpacing: -1.4,
            height: 1.08,
            color: dark ? Colors.white : kInk,
          ),
        ),
        SizedBox(height: width < 600 ? 14 : (roomy ? 28 : 20)),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: roomy ? 720 : 620),
          child: Text(
            subhead,
            style: GoogleFonts.inter(
              fontSize: width < 600 ? 15 : (roomy ? 23 : 20),
              height: width < 600 ? 1.45 : 1.55,
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
