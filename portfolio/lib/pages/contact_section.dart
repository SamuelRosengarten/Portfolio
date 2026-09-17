import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/palette.dart';
import '../widgets/section_layout.dart';

class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionShell(
      background: kDarkBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionIntro(
            eyebrow: 'Contact',
            headline: "Let's talk.",
            subhead:
                'Open to internships, collaborations, or a conversation about '
                'something you are building.',
            dark: true,
          ),
          SizedBox(height: 48),
          _ContactGrid(),
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
        if (width >= 480) return 2;
        return 1;
      },
      children: const [
        _ContactCard(
          icon: Icons.mail_outline_rounded,
          label: 'Email',
          value: 'your.email@example.com',
        ),
        _ContactCard(
          icon: Icons.code_rounded,
          label: 'GitHub',
          value: 'github.com/yourhandle',
        ),
        _ContactCard(
          icon: Icons.work_outline_rounded,
          label: 'LinkedIn',
          value: 'linkedin.com/in/yourhandle',
        ),
        _ContactCard(
          icon: Icons.place_outlined,
          label: 'Location',
          value: 'Montréal, QC',
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

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: _hovering ? 0.08 : 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: _hovering ? 0.2 : 0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, size: 22, color: kBlue),
            const SizedBox(height: 16),
            Text(
              widget.label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: kGray,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.value,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
