import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/palette.dart';

double _headlineSize(double width) {
  if (width < 600) return 34;
  if (width < 900) return 44;
  return 56;
}

/// Full-bleed band of colour holding one section's content, centred and capped
/// so the copy never runs wider than it reads well.
class SectionShell extends StatelessWidget {
  const SectionShell({
    super.key,
    required this.background,
    required this.child,
  });

  final Color background;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Container(
      width: double.infinity,
      color: background,
      constraints: BoxConstraints(minHeight: size.height),
      padding: EdgeInsets.symmetric(
        vertical: size.width < 600 ? 80 : 120,
        horizontal: 24,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: child,
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
class CardGrid extends StatelessWidget {
  const CardGrid({
    super.key,
    required this.children,
    required this.columnsFor,
    required this.spacing,
  });

  final List<Widget> children;
  final int Function(double width) columnsFor;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = columnsFor(constraints.maxWidth);
        final cardWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        final rows = <List<Widget>>[];
        for (var i = 0; i < children.length; i += columns) {
          final end = i + columns;
          rows.add(
            children.sublist(i, end > children.length ? children.length : end),
          );
        }

        return Column(
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
