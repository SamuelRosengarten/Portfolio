import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../i18n/strings.dart';
import '../theme/palette.dart';
import '../widgets/code_coach_demo.dart';
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
              color: kGray,
            ),
          ),
        ),
        SizedBox(height: mobile ? 6 : 8 * scale),
        // Both links keep one line and truncate: neither URL has a break
        // point that fits a phone width (on the repo link the owner's name
        // used to wrap across two lines).
        _LinkText(
          'marketplace.visualstudio.com/items?itemName=samuelrosengarten.code-coach-ai',
          style: GoogleFonts.inter(
            fontSize: mobile ? 12 : 13 * scale,
            fontWeight: FontWeight.w500,
            color: kBlue,
          ),
        ),
        SizedBox(height: mobile ? 2 : 4 * scale),
        _LinkText(
          'github.com/SamuelRosengarten/code-coach',
          style: GoogleFonts.inter(
            fontSize: mobile ? 12 : 13 * scale,
            fontWeight: FontWeight.w500,
            color: kGray,
          ),
        ),
        SizedBox(height: mobile ? 14 : 20 * scale),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _Tag(s.tagVsCodeExtension, palette: palette),
            _Tag(s.tagPublished, palette: palette),
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

/// A URL shown without its scheme that opens in a new tab when tapped — with
/// a pointer cursor and an underline on hover so it reads as a link.
class _LinkText extends StatefulWidget {
  const _LinkText(this.address, {required this.style});

  /// Host and path, e.g. `github.com/SamuelRosengarten/code-coach`.
  final String address;
  final TextStyle style;

  @override
  State<_LinkText> createState() => _LinkTextState();
}

class _LinkTextState extends State<_LinkText> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      link: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => launchUrl(Uri.parse('https://${widget.address}')),
          child: Text(
            widget.address,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: widget.style.copyWith(
              decoration: _hovering ? TextDecoration.underline : null,
              decorationColor: widget.style.color,
            ),
          ),
        ),
      ),
    );
  }
}
