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
    // on top of it and the copy switches to the site's dark treatment. The
    // language marquee is wrapped in Expanded so it absorbs whatever room is
    // left under the intro instead of pushing the section past one screen.
    return const GoldenGateBackground(
      child: SectionShell(
        background: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AboutIntro(),
            SizedBox(height: 32),
            Expanded(child: Center(child: _LanguageMarquee())),
          ],
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

/// A row of language logos that scrolls itself sideways forever, fading out
/// at both edges so it reads as a strip rather than a hard-cropped list.
class _LanguageMarquee extends StatefulWidget {
  const _LanguageMarquee();

  @override
  State<_LanguageMarquee> createState() => _LanguageMarqueeState();
}

class _LanguageMarqueeState extends State<_LanguageMarquee>
    with SingleTickerProviderStateMixin {
  static const double _chipWidth = 172;
  static const double _pixelsPerSecond = 36;

  final _scrollController = ScrollController();
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;
  bool _reduceMotion = false;

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
    _scrollController.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (!_scrollController.hasClients) return;
    final dt =
        (elapsed - _lastElapsed).inMicroseconds /
        Duration.microsecondsPerSecond;
    _lastElapsed = elapsed;

    final loopWidth = _chipWidth * _languages.length;
    var next = _scrollController.offset + _pixelsPerSecond * dt;
    if (next >= loopWidth) next -= loopWidth;
    _scrollController.jumpTo(next);
  }

  @override
  Widget build(BuildContext context) {
    // Repeated twice so the strip can scroll a full loop's width and jump
    // back to zero without ever showing a gap.
    final items = [..._languages, ..._languages];

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
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, i) =>
                SizedBox(width: _chipWidth, child: _LanguageChip(items[i])),
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
