import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/palette.dart';
import '../widgets/section_layout.dart';
import '../widgets/terminal/terminal_window.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionShell(
      background: kLightBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionIntro(
            eyebrow: 'About',
            headline: "Hi, I'm Samuel.",
            subhead:
                'A developer in training who likes building things that feel '
                'considered — clean interfaces, code that reads well, and '
                'details most people never notice but always feel.',
          ),
          SizedBox(height: 48),
          _TerminalPanel(),
          SizedBox(height: 56),
          _TraitGrid(),
        ],
      ),
    );
  }
}

/// The interactive terminal, framed in a dark panel so the glass window keeps
/// its contrast against the light section background.
class _TerminalPanel extends StatelessWidget {
  const _TerminalPanel();

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 700;

    return Container(
      padding: EdgeInsets.all(compact ? 16 : 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1C1C1E), Color(0xFF2C2C2E)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TerminalWindow(width: double.infinity, height: compact ? 320 : 400),
          const SizedBox(height: 18),
          Text(
            'Click the window and type "help" — it is a real shell, not a GIF.',
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.5,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _TraitGrid extends StatelessWidget {
  const _TraitGrid();

  @override
  Widget build(BuildContext context) {
    return CardGrid(
      spacing: 20,
      columnsFor: (width) => width >= 720 ? 3 : 1,
      children: const [
        _TraitCard(
          icon: Icons.terminal_rounded,
          title: 'Builder',
          body: 'I learn by making. Every idea ends up as something runnable.',
        ),
        _TraitCard(
          icon: Icons.design_services_outlined,
          title: 'Detail-driven',
          body: 'Spacing, timing, contrast — the small things carry the feel.',
        ),
        _TraitCard(
          icon: Icons.auto_stories_outlined,
          title: 'Always learning',
          body: 'New stack, new problem, new angle. Curiosity does the work.',
        ),
      ],
    );
  }
}

class _TraitCard extends StatelessWidget {
  const _TraitCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 26, color: kInk),
          const SizedBox(height: 18),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 19,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
              color: kInk,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: GoogleFonts.inter(fontSize: 15, height: 1.5, color: kGray),
          ),
        ],
      ),
    );
  }
}
