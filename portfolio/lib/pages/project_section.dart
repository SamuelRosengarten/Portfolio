import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../i18n/strings.dart';
import '../theme/palette.dart';
import '../widgets/code_coach_demo.dart';
import '../widgets/link_target.dart';
import '../widgets/section_layout.dart';

class ProjectSection extends StatelessWidget {
  const ProjectSection({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = paletteOf(context).dark;
    final s = stringsOf(context);
    return SectionShell(
      background: paletteOf(context).band,
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
                ? 10
                : 24 * heightScale(context),
          ),
          const _ProjectShowcase(),
        ],
      ),
    );
  }
}

/// The demo sizes itself to its content rather than an Expanded box filling
/// whatever room is left: this showcase can end up inside SectionShell's
/// scrollable fallback on a short phone screen, where Expanded would crash
/// for lack of a bounded height.
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
        const CodeCoachDemo(),
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
              // This is the longest single piece of copy in the section —
              // on a phone, scale it down past a reasonable length the same
              // way SectionIntro's subhead does (see _subheadFontSize),
              // rather than let it alone decide whether the whole section
              // needs a scroll.
              fontSize: mobile
                  ? _descriptionFontSize(s.projectDescription)
                  : 16 * scale,
              height: mobile ? 1.4 : 1.6,
              color: palette.muted,
            ),
          ),
        ),
        // The tags repeat what the subhead already says on a phone, where
        // every line of height counts toward the one-screen budget.
        if (!mobile) ...[
          SizedBox(height: 18 * scale),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Tag(s.tagVsCodeExtension, palette: palette),
              _Tag(s.tagPublished, palette: palette, highlight: true),
            ],
          ),
        ],
        SizedBox(height: mobile ? 12 : 20 * scale),
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            _PillButton(
              label: s.viewOnMarketplace,
              address: 'marketplace.visualstudio.com/items?itemName=samuelrosengarten.code-coach-ai',
              primary: true,
            ),
            _PillButton(
              label: s.sourceOnGitHub,
              address: 'github.com/SamuelRosengarten/code-coach',
            ),
          ],
        ),
      ],
    );
  }
}

/// A description around 150 characters or shorter keeps its full 14px; each
/// character past that shaves the size down, floored at 11px.
double _descriptionFontSize(String description) {
  const referenceLength = 150;
  final scale = (referenceLength / description.length).clamp(0.78, 1.0);
  return 14 * scale;
}

class _Tag extends StatelessWidget {
  const _Tag(this.label, {required this.palette, this.highlight = false});

  final String label;
  final AppPalette palette;

  /// The "Published" tag borrows the accent blue; the rest stay neutral.
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: highlight
            ? kBlue.withValues(alpha: 0.16)
            : palette.surface(0.08),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: highlight
              ? (palette.dark
                    ? const Color(0xFF7CC0FF)
                    : const Color(0xFF0066CC))
              : palette.ink.withValues(alpha: 0.85),
        ),
      ),
    );
  }
}

/// A pill-shaped link that opens [address] (host and path, no scheme) in a
/// new tab: solid accent when [primary], outlined otherwise. Brightens on
/// hover with a pointer cursor.
class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.address,
    this.primary = false,
  });

  final String label;
  final String address;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return LinkTarget(
      uri: Uri.parse('https://$address'),
      semanticLabel: label,
      builder: _pill,
    );
  }

  Widget _pill(BuildContext context, bool hovering) {
    final palette = paletteOf(context);
    final fg = primary ? Colors.black : palette.ink;
    final mobile = MediaQuery.sizeOf(context).width < 600;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      constraints: BoxConstraints(minHeight: mobile ? 40 : 48),
      padding: EdgeInsets.symmetric(horizontal: mobile ? 16 : 22),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: primary
            ? (hovering ? const Color(0xFF5CB0FF) : kBlue)
            : (hovering ? palette.surface(0.08) : Colors.transparent),
        borderRadius: BorderRadius.circular(100),
        border: primary ? null : Border.all(color: palette.surface(0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: mobile ? 13 : 15,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ),
          if (primary) ...[
            const SizedBox(width: 6),
            Icon(Icons.arrow_outward_rounded, size: 16, color: fg),
          ],
        ],
      ),
    );
  }
}
