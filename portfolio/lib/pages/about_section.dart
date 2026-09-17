import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
// Importing the package's own brand.dart directly (rather than the
// icons_plus.dart barrel) skips its other icon families, several of which
// don't compile against current Flutter SDKs (they extend the now-`final`
// IconData class).
// ignore: implementation_imports
import 'package:icons_plus/src/brand.dart';

import '../widgets/golden_gate_background.dart';
import '../widgets/section_layout.dart';

import 'package:fade_animation_delayed/fade_animation_delayed.dart';
import 'package:particle_text/particle_text.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    // The animated backdrop paints the section, so the shell stays transparent
    // on top of it and the copy switches to the site's dark treatment.
    // SectionShell pins the whole section to exactly one screen height, so on
    // a short/cropped window the intro plus the marquee's three rows may not
    // fit. mainAxisAlignment.center (rather than an Expanded spacer) lets the
    // block sit centered when there's room to spare, and LayoutBuilder +
    // SingleChildScrollView let it scroll instead of overflowing when there
    // isn't — a flex spacer can't do that, since Expanded needs a bounded
    // height and a scroll view can't offer one.
    return const GoldenGateBackground(
      child: SectionShell(background: Colors.transparent, child: _AboutBody()),
    );
  }
}

class _AboutBody extends StatelessWidget {
  const _AboutBody();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _AboutIntro(),
              SizedBox(height: 32),
              Center(child: _LanguageMarquee()),
            ],
          ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 15),
        SizedBox(
          height: 80,
          child: FadeAnimationDelayed(
            delay: Duration(seconds: 1),
            child: ParticleText(
              text: "Hi, I'm Samuel",
              config: ParticleConfig(
                fontSize: 70,
                textAlign: TextAlign.left,
                particleColor: const Color.fromARGB(255, 255, 255, 255),
                displacedColor: const Color.fromARGB(255, 255, 255, 255),
                drawBackground: false,
                mouseRadius: 80,
                repelForce: 0.5,
                returnSpeed: 0.04,
              ),
            ),
          ),
        ),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Text(
              'A place to put the thing I am building right now. Swap this copy '
              'for the real story once there is a screenshot worth showing.',
              style: GoogleFonts.inter(
                fontSize: 16,
                height: 1.6,
                color: const Color.fromARGB(255, 255, 255, 255),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// One language/tool logo, paired with its label. Mock data — swap the list
/// in [_languages] for whatever you've actually learned.
class _Language {
  const _Language(this.name, this.icon);

  final String name;
  final String icon;
}

const _languages = [
  _Language('Dart', Brands.dart),
  _Language('Flutter', Brands.flutter),
  _Language('Python', Brands.python),
  _Language('JavaScript', Brands.javascript),
  _Language('TypeScript', Brands.typescript),
  _Language('Java', Brands.java),
  _Language('Kotlin', Brands.kotlin),
  _Language('Go', Brands.golang),
  _Language('Rust', Brands.rust_programming_language),
  _Language('Swift', Brands.swift_programming),
  _Language('C++', Brands.cpp),
  _Language('C#', Brands.c_sharp_logo),
  _Language('HTML5', Brands.html_5),
  _Language('CSS3', Brands.css3),
];

/// Three stacked [_LanguageMarqueeRow]s, each carrying its own slice of
/// [_languages] and scrolling at its own speed so the rows drift out of
/// phase with each other instead of ticking past in lockstep.
class _LanguageMarquee extends StatelessWidget {
  const _LanguageMarquee();

  static const List<double> _rowSpeeds = [36, 24, 44];

  @override
  Widget build(BuildContext context) {
    // Dealt round-robin across the rows so each one still cycles through a
    // mix of languages rather than three copies of the same strip.
    final rows = List.generate(
      _rowSpeeds.length,
      (i) => [
        for (var j = i; j < _languages.length; j += _rowSpeeds.length)
          _languages[j],
      ],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          _LanguageMarqueeRow(
            languages: rows[i],
            pixelsPerSecond: _rowSpeeds[i],
          ),
        ],
      ],
    );
  }
}

/// A row of language logos that scrolls itself sideways forever, fading out
/// at both edges so it reads as a strip rather than a hard-cropped list.
class _LanguageMarqueeRow extends StatefulWidget {
  const _LanguageMarqueeRow({
    required this.languages,
    required this.pixelsPerSecond,
  });

  final List<_Language> languages;
  final double pixelsPerSecond;

  @override
  State<_LanguageMarqueeRow> createState() => _LanguageMarqueeRowState();
}

class _LanguageMarqueeRowState extends State<_LanguageMarqueeRow>
    with SingleTickerProviderStateMixin {
  static const double _chipWidth = 172;

  // Driven by hand with a Transform rather than a ScrollController: jumpTo
  // on a controller still runs the platform's ballistic scroll physics
  // (bounce-back on macOS/iOS), which throws once the offset is reset to
  // loop the strip. A raw offset sidesteps scroll physics entirely.
  final _offset = ValueNotifier<double>(0);
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;
  bool _reduceMotion = false;

  double get _loopWidth => _chipWidth * widget.languages.length;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion) {
      _ticker.stop();
    } else if (!_ticker.isActive) {
      _lastElapsed = Duration.zero;
      _ticker.start();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _offset.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final dt =
        (elapsed - _lastElapsed).inMicroseconds /
        Duration.microsecondsPerSecond;
    _lastElapsed = elapsed;

    var next = _offset.value + widget.pixelsPerSecond * dt;
    if (next >= _loopWidth) next -= _loopWidth;
    _offset.value = next;
  }

  @override
  Widget build(BuildContext context) {
    // Repeated twice so the strip can scroll a full loop's width and jump
    // back to zero without ever showing a gap.
    final items = [...widget.languages, ...widget.languages];

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 640),
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (bounds) => const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.transparent,
            Colors.black,
            Colors.black,
            Colors.transparent,
          ],
          stops: [0.0, 0.1, 0.9, 1.0],
        ).createShader(bounds),
        child: SizedBox(
          height: 68,
          child: ClipRect(
            // The strip of chips is far wider than the viewport by design —
            // OverflowBox lets it lay out at its full natural width instead
            // of being clamped (and flagged as a RenderFlex overflow) to
            // whatever width this row is cropped to; the ClipRect above
            // still trims the paint to that width.
            child: OverflowBox(
              minWidth: 0,
              maxWidth: double.infinity,
              alignment: Alignment.centerLeft,
              child: ValueListenableBuilder<double>(
                valueListenable: _offset,
                builder: (context, offset, child) =>
                    Transform.translate(offset: Offset(-offset, 0), child: child),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final language in items)
                      SizedBox(
                        width: _chipWidth,
                        child: _LanguageChip(language),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageChip extends StatelessWidget {
  const _LanguageChip(this.language);

  final _Language language;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Brand(language.icon, size: 22),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              language.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
