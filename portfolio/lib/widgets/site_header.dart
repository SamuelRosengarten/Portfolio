import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const double kSiteHeaderHeight = 48;

/// The sections of the page, in the order they are stacked — the header renders
/// one item per value and [Home] anchors one section to each.
enum SiteSection {
  about('About'),
  projects('Projects'),
  hobbies('Hobbies'),
  contact('Contact');

  const SiteSection(this.label);

  final String label;
}

class SiteHeader extends StatelessWidget {
  const SiteHeader({super.key, required this.onSelected});

  /// Called with the section the visitor asked to jump to.
  final ValueChanged<SiteSection> onSelected;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 600;

    // BackdropFilter blurs whatever is *behind* this widget (the scrolling
    // page content), which combined with the translucent white container
    // below is what gives the header its frosted-glass look as content
    // scrolls underneath it. ClipRect is required because BackdropFilter
    // blurs its entire layer, including past this widget's own bounds —
    // without it the blur would bleed outside the header.
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: kSiteHeaderHeight,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            border: Border(
              bottom: BorderSide(
                color: Colors.black.withValues(alpha: 0.08),
                width: 0.5,
              ),
            ),
          ),
          // FittedBox + scaleDown is a safety net for very narrow screens:
          // if the row of nav items would overflow the header's width, this
          // shrinks the whole row down to fit instead of clipping it or
          // throwing an overflow error. `compact` above already shrinks the
          // text/padding at <600px, so this rarely has to do much.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final section in SiteSection.values)
                  _HeaderItem(
                    section.label,
                    compact: compact,
                    onTap: () => onSelected(section),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderItem extends StatefulWidget {
  const _HeaderItem(this.label, {required this.compact, required this.onTap});

  final String label;
  final bool compact;
  final VoidCallback onTap;

  @override
  State<_HeaderItem> createState() => _HeaderItemState();
}

class _HeaderItemState extends State<_HeaderItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.compact ? 10 : 18),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 120),
            style: GoogleFonts.inter(
              fontSize: widget.compact ? 12 : 13,
              letterSpacing: -0.1,
              fontWeight: FontWeight.w400,
              color: Colors.black.withValues(alpha: _hovering ? 0.9 : 0.65),
            ),
            child: Text(widget.label),
          ),
        ),
      ),
    );
  }
}
