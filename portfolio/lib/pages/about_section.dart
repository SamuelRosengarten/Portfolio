import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/palette.dart';
import '../widgets/golden_gate_background.dart';
import '../widgets/section_layout.dart';

import 'package:particle_text/particle_text.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    // The animated backdrop paints the section, so the shell stays transparent
    // on top of it and the copy switches to the site's dark treatment.
    return const GoldenGateBackground(
      child: SectionShell(
        background: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_AboutIntro(), _TraitGrid()],
        ),
      ),
    );
  }
}

/// This section's own take on [SectionIntro]: same eyebrow-and-subhead frame,
/// but the headline is rendered as interactive particles instead of text.
class _AboutIntro extends StatelessWidget {
  const _AboutIntro();

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        SizedBox(
          height: compact ? 130 : 160,
          child: ParticleText(
            text: "Hi, I'm Samuel",
            config: ParticleConfig(
              fontSize: compact ? 48 : 72,
              textAlign: TextAlign.left,
              particleColor: const Color(0xFF8CAADE),
              displacedColor: const Color(0xFFDCE5FF),
              drawBackground: false,
              mouseRadius: 80,
              repelForce: 8.0,
              returnSpeed: 0.04,
            ),
          ),
        ),
      ],
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
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 26, color: kBlue),
          const SizedBox(height: 18),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 19,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
              color: Colors.white,
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
