import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/palette.dart';
import '../widgets/section_layout.dart';

class ProjectSection extends StatelessWidget {
  const ProjectSection({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = paletteOf(context).dark;
    return SectionShell(
      background: paletteOf(context).bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionIntro(
            eyebrow: 'Work',
            headline: 'Something is coming.',
            subhead:
                'My first real project is still on the bench. The shape is '
                'there, the details are not — so here is the placeholder it '
                'deserves until it earns a screenshot.',
            dark: dark,
          ),
          const SizedBox(height: 24),
          const Expanded(child: _ProjectShowcase()),
        ],
      ),
    );
  }
}

/// The placeholder image is wrapped in Expanded rather than sized from an
/// aspect ratio, so it shrinks to whatever room is left under the copy
/// instead of pushing the section past one screen on wide, short viewports.
/// (Recall from section_layout.dart that [SectionShell] fixes the section to
/// exactly one screen's height — this is how content living inside that
/// fixed height stays flexible instead of overflowing.)
class _ProjectShowcase extends StatelessWidget {
  const _ProjectShowcase();

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
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
            // site_header.dart: the Expanded box above can be squeezed down
            // by a tall SectionIntro on a short/narrow viewport, and without
            // this, the icon-and-caption column's fixed intrinsic height
            // would overflow it instead of gracefully shrinking to fit.
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
                      'In development',
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
        const SizedBox(height: 20),
        Text(
          'Untitled project',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
            color: palette.ink,
          ),
        ),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Text(
            'A place to put the thing I am building right now. Swap this copy '
            'for the real story once there is a screenshot worth showing.',
            style: GoogleFonts.inter(fontSize: 16, height: 1.6, color: kGray),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _Tag('Flutter', palette: palette),
            _Tag('Dart', palette: palette),
            _Tag('In progress', palette: palette),
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
