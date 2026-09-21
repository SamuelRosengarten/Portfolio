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
          SizedBox(
            height: MediaQuery.sizeOf(context).width < 600
                ? 16
                : 24 * heightScale(context),
          ),
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
    final scale = heightScale(context);
    final s = stringsOf(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          // Flatter on phones (21:9, vs. the usual 16:9) — this box is pure
          // decoration (an empty placeholder), not content, so it's the
          // cheapest place to give height back on a screen short enough to
          // need it. The opposite move on a taller window: continuously
          // taller (toward 3:2 at max scale), which combines with
          // SectionShell's own wider cap there to give this placeholder
          // noticeably more height, not just more width.
          aspectRatio: mobile ? 21 / 9 : 16 / 9 + (3 / 2 - 16 / 9) * (scale - 1).clamp(0.0, 1.0),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: palette.dark
                    ? const [Color(0xFF1C1C1E), Color(0xFF2C2C2E)]
                    : const [Color(0xFFF0F0F3), Color(0xFFE4E4E9)],
              ),
              border: Border.all(color: palette.surface(0.08)),
            ),
            // FittedBox + scaleDown is the same overflow safety net used in
            // site_header.dart: the icon-and-caption column's fixed
            // intrinsic height could exceed the box's height on a very
            // short/narrow viewport, and without this that would overflow
            // it instead of gracefully shrinking to fit.
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.construction_outlined,
                      size: 40,
                      color: palette.ink.withValues(alpha: 0.35),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      s.inDevelopment,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: palette.ink.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: mobile ? 14 : 20 * scale),
        Text(
          'Code Coach',
          style: GoogleFonts.inter(
            fontSize: mobile ? 20 : 24 * scale,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
            color: palette.ink,
          ),
        ),
        SizedBox(height: mobile ? 6 : 10 * scale),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 620 * (mobile ? 1 : scale)),
          child: Text(
            s.projectDescription,
            style: GoogleFonts.inter(
              fontSize: mobile ? 14 : 16 * scale,
              height: mobile ? 1.4 : 1.6,
              color: kGray,
            ),
          ),
        ),
        SizedBox(height: mobile ? 6 : 8 * scale),
        Text(
          'github.com/SamuelRosengarten/code-coach',
          style: GoogleFonts.inter(
            fontSize: mobile ? 12 : 13 * scale,
            fontWeight: FontWeight.w500,
            color: kBlue,
          ),
        ),
        SizedBox(height: mobile ? 14 : 20 * scale),
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
