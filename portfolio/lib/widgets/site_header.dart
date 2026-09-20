import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const double kSiteHeaderHeight = 48;

/// Below this width the header switches from the centered row of nav links
/// to a single menu button that opens [NavDrawer].
const double kMobileNavBreakpoint = 600;

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
    final mobile = MediaQuery.sizeOf(context).width < kMobileNavBreakpoint;

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
          alignment: mobile ? Alignment.centerLeft : Alignment.center,
          child: mobile ? const _MenuButton() : _DesktopNav(onSelected: onSelected),
        ),
      ),
    );
  }
}

/// Hamburger button shown top-left on phone-sized screens. Opens the
/// [NavDrawer] registered on the enclosing [Scaffold] (see `Home`).
class _MenuButton extends StatelessWidget {
  const _MenuButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu, color: Colors.black87),
      tooltip: 'Open navigation',
      onPressed: () => Scaffold.of(context).openDrawer(),
    );
  }
}

/// The row of nav links shown across the top of the header on wider screens.
class _DesktopNav extends StatelessWidget {
  const _DesktopNav({required this.onSelected});

  final ValueChanged<SiteSection> onSelected;

  @override
  Widget build(BuildContext context) {
    // FittedBox + scaleDown is a safety net for narrow-ish screens just
    // above the mobile breakpoint: if the row of nav items would overflow
    // the header's width, this shrinks the whole row down to fit instead of
    // clipping it or throwing an overflow error.
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final section in SiteSection.values)
            _HeaderItem(section.label, onTap: () => onSelected(section)),
        ],
      ),
    );
  }
}

class _HeaderItem extends StatefulWidget {
  const _HeaderItem(this.label, {required this.onTap});

  final String label;
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
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 120),
            style: GoogleFonts.inter(
              fontSize: 13,
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

/// Phone-size nav drawer: the same section names as the desktop header, laid
/// out as a vertical list. Opened via the hamburger [_MenuButton] and
/// registered as `Scaffold.drawer` by `Home` so every section is reachable
/// no matter which one the visitor is currently scrolled to.
class NavDrawer extends StatelessWidget {
  const NavDrawer({super.key, required this.onSelected});

  /// Called with the section the visitor tapped; the drawer is already
  /// closed by the time this fires.
  final ValueChanged<SiteSection> onSelected;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'MENU',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.4,
                  color: Colors.black.withValues(alpha: 0.4),
                ),
              ),
            ),
            const SizedBox(height: 8),
            for (final section in SiteSection.values)
              ListTile(
                title: Text(
                  section.label,
                  style: GoogleFonts.inter(
                    fontSize: 19,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.2,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  onSelected(section);
                },
              ),
          ],
        ),
      ),
    );
  }
}
