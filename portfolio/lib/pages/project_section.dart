import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../i18n/strings.dart';
import '../theme/palette.dart';
import '../widgets/section_layout.dart';

class ProjectSection extends StatelessWidget {
  const ProjectSection({super.key});

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
            eyebrow: s.projectEyebrow,
            headline: 'Code Coach.',
            subhead: s.projectSubhead,
            dark: dark,
          ),
          SizedBox(height: MediaQuery.sizeOf(context).width < 600 ? 16 : 24),
          const _ProjectShowcase(),
        ],
      ),
    );
  }
}

/// The placeholder image is a fixed aspect ratio rather than an Expanded box
/// filling whatever room is left: this whole showcase can end up inside
/// SectionShell's scrollable fallback on a short phone screen, and Expanded
/// needs a bounded height to fill — which a scroll view's child never has —
/// so it would crash there instead of gracefully sizing itself.
class _ProjectShowcase extends StatelessWidget {
  const _ProjectShowcase();

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    final mobile = MediaQuery.sizeOf(context).width < 600;
    final s = stringsOf(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          // Flatter on phones: gives height back on a screen short enough
          // to need it. The preview image itself is 16:9 — BoxFit.cover
          // crops its sides rather than distorting it on the wider 21:9
          // phone box.
          aspectRatio: mobile ? 21 / 9 : 16 / 9,
          child: Container(
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: palette.surface(0.08)),
            ),
            // A screenshot of the interactive design prototype for Code
            // Coach's coaching hint + weekly progress panel — the actual
            // UI this project is designed around, not a generic mockup.
            child: Image.asset(
              'assets/images/code_coach_preview.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
        SizedBox(height: mobile ? 14 : 20),
        Text(
          'Code Coach',
          style: GoogleFonts.inter(
            fontSize: mobile ? 20 : 24,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
            color: palette.ink,
          ),
        ),
        SizedBox(height: mobile ? 6 : 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Text(
            s.projectDescription,
            style: GoogleFonts.inter(
              fontSize: mobile ? 14 : 16,
              height: mobile ? 1.4 : 1.6,
              color: kGray,
            ),
          ),
        ),
        SizedBox(height: mobile ? 6 : 8),
        Text(
          'github.com/SamuelRosengarten/code-coach',
          style: GoogleFonts.inter(
            fontSize: mobile ? 12 : 13,
            fontWeight: FontWeight.w500,
            color: kBlue,
          ),
        ),
        SizedBox(height: mobile ? 14 : 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _Tag(s.tagVsCodeExtension, palette: palette),
            _Tag(s.tagDesignPhase, palette: palette),
          ],
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label, {required this.palette});

  final String label;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: palette.surface(0.08),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: palette.surface(0.12)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: palette.ink.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}
