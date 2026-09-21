import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../i18n/strings.dart';
import '../theme/palette.dart';
import '../widgets/section_layout.dart';

class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = paletteOf(context).dark;
    final s = stringsOf(context);
    return SectionShell(
      background: paletteOf(context).bg,
      child: Column(
        // .min, not the default .max: this sizes to its own content instead
        // of trying to fill the fixed section height, which would demand an
        // *infinite* height on a phone screen short enough to need
        // SectionShell's scroll fallback. SectionShell's own Center already
        // takes care of centering this block vertically when there's room
        // to spare (e.g. on a tall desktop window).
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionIntro(
            eyebrow: 'Contact',
            headline: s.contactHeadline,
            subhead: s.contactSubhead,
            dark: dark,
          ),
          SizedBox(height: isRoomyViewport(context) ? 48 : 32),
          const _ContactGrid(),
        ],
      ),
    );
  }
}

class _ContactGrid extends StatelessWidget {
  const _ContactGrid();

  @override
  Widget build(BuildContext context) {
    return CardGrid(
      spacing: 16,
      columnsFor: (width) {
        if (width >= 760) return 4;
        // Was 480 — but `width` here is the grid's own available width
        // (roughly device width minus the section's side padding), which
        // for almost every phone lands well under that, forcing four cards
        // into one tall stacked column and pushing the section's total
        // height well past what a phone screen can show without scrolling.
        // Two cards fit comfortably side by side much narrower than 480.
        if (width >= 300) return 2;
        return 1;
      },
      children: [
        const _ContactCard(
          icon: Icons.mail_outline_rounded,
          label: 'Email',
          value: 'samrosengarten2@pm.me',
        ),
        const _ContactCard(
          icon: Icons.code_rounded,
          label: 'GitHub',
          value: 'github.com/SamuelRosengarten',
        ),
        const _ContactCard(
          icon: Icons.work_outline_rounded,
          label: 'LinkedIn',
          value: 'linkedin.com/in/samuel-rosengarten-63b932404',
        ),
        _ContactCard(
          icon: Icons.place_outlined,
          label: stringsOf(context).locationLabel,
          value: 'Longueuil, QC',
        ),
      ],
    );
  }
}

class _ContactCard extends StatefulWidget {
  const _ContactCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  State<_ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends State<_ContactCard> {
  bool _hovering = false;

  // This MouseRegion + setState + AnimatedContainer trio is the site's
  // standard hover pattern, repeated with small variations in
  // site_header.dart, hobbies_section.dart and elsewhere: MouseRegion just
  // reports enter/exit, a bool in State tracks whether the pointer is
  // currently over the widget, and AnimatedContainer/AnimatedScale smoothly
  // tweens between the "resting" and "hovering" look whenever that bool
  // flips (rather than snapping instantly).
  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    final roomy = isRoomyViewport(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.all(roomy ? 32 : 24),
        decoration: BoxDecoration(
          color: palette.surface(_hovering ? 0.08 : 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: palette.surface(_hovering ? 0.2 : 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, size: roomy ? 28 : 22, color: kBlue),
            SizedBox(height: roomy ? 22 : 16),
            Text(
              widget.label,
              style: GoogleFonts.inter(
                fontSize: roomy ? 15 : 13,
                fontWeight: FontWeight.w500,
                color: kGray,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.value,
              style: GoogleFonts.inter(
                fontSize: roomy ? 18 : 15,
                fontWeight: FontWeight.w500,
                color: palette.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
