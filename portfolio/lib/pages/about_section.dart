import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
// Importing the package's own brand.dart directly (rather than the
// icons_plus.dart barrel) skips its other icon families, several of which
// don't compile against current Flutter SDKs (they extend the now-`final`
// IconData class).
// ignore: implementation_imports
import 'package:icons_plus/src/brand.dart';

import '../i18n/strings.dart';
import '../theme/palette.dart';
import '../widgets/golden_gate_background.dart';
import '../widgets/section_layout.dart';

import 'package:fade_animation_delayed/fade_animation_delayed.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:particle_text/particle_text.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    // The animated backdrop paints the section, so the shell stays
    // transparent on top of it. SectionShell pins the whole section to
    // exactly one screen height, so on a short/cropped window the intro plus
    // the marquee's three rows may not fit. mainAxisAlignment.center (rather
    // than an Expanded spacer) lets the block sit centered when there's room
    // to spare, and LayoutBuilder + SingleChildScrollView let it scroll
    // instead of overflowing when there isn't — a flex spacer can't do that,
    // since Expanded needs a bounded height and a scroll view can't offer one.
    return GoldenGateBackground(
      dark: paletteOf(context).dark,
      child: const SectionShell(
        background: Colors.transparent,
        scrollable: false,
        child: _AboutBody(),
      ),
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
              SizedBox(height: 48),
              Center(child: _LanguagePanel()),
            ],
          ),
        ),
      ),
    );
  }
}

/// Responsive font size for the particle "Hi, I'm Samuel" headline. Unlike
/// [SectionIntro]'s plain [Text] headlines, `ParticleText` samples its shape
/// from a fixed-height offscreen canvas rather than reflowing like normal
/// text — so at the old fixed 70px size, the headline ran wider than an
/// iPhone's screen and got sampled straight past the edge of that canvas
/// instead of wrapping or shrinking to fit.
double _particleHeadlineSize(double width) {
  if (width < 400) return 32;
  if (width < 600) return 40;
  if (width < 900) return 56;
  return 70;
}

/// Measures how wide [text] renders at [fontSize], using the same style
/// `ParticleText`'s own internal `TextPainter` uses to sample glyphs
/// (`FontWeight.bold`, the default font family) — see [_AboutIntro.build]
/// for why this needs to match.
double _measureParticleHeadlineWidth(String text, double fontSize) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  return painter.width;
}

/// This section's own take on [SectionIntro]: same eyebrow-and-subhead frame,
/// but the headline is rendered as interactive particles instead of text.
class _AboutIntro extends StatelessWidget {
  const _AboutIntro();

  @override
  Widget build(BuildContext context) {
    final headlineSize = _particleHeadlineSize(MediaQuery.sizeOf(context).width);
    final ink = paletteOf(context).ink;
    final s = stringsOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 14),
        SizedBox(
          height: headlineSize + 12,
          // ParticleText always centers its sampled glyphs within whatever
          // width it's given, ignoring its own `textAlign: left` config
          // (that only affects wrapping alignment, not placement) — left
          // unconstrained, it fills the whole ~900px content column and the
          // greeting ends up floating near the middle of the section while
          // the bio paragraph right below it sits flush left, an obvious
          // mismatch. Narrowing the box to the greeting's own measured
          // width (plus a little slack for the particles' hover spread)
          // makes "centered in the box" and "flush left in the column"
          // come out the same place.
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: _measureParticleHeadlineWidth(s.heroGreeting, headlineSize) + 48,
              child: FadeAnimationDelayed(
                delay: const Duration(seconds: 1),
                child: _ParticleHeadline(fontSize: headlineSize, text: s.heroGreeting),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Text(
            s.aboutBio,
            style: GoogleFonts.inter(
              fontSize: 17,
              height: 1.6,
              letterSpacing: -0.2,
              color: ink.withValues(alpha: 0.75),
            ),
          ),
        ),
      ],
    );
  }
}

/// Wraps [ParticleText] with a one-shot, self-healing retry.
///
/// `ParticleText` samples its headline by rasterizing it to an offscreen
/// [dart:ui.Image] and reading the pixels back (`Picture.toImage` then
/// `Image.toByteData`), the moment it first mounts — which, since
/// `AboutSection` is the very first thing on the page, is also the app's
/// very first frame. On Flutter Web that GPU readback can race the
/// browser's renderer starting up: if it resolves before anything has
/// actually been rasterized, it silently gets back a blank image, so no
/// particles ever sample from the text and the headline just never
/// appears — with no error and nothing to trigger a retry. Chromium and
/// Firefox's WASM/engine startup is scheduled differently from Safari's,
/// which is why this shows up as "works in Safari, not the others" rather
/// than failing everywhere.
///
/// Changing `ParticleText`'s key forces Flutter to dispose the old one and
/// mount a fresh instance, which re-runs that sampling step from scratch.
/// Doing that once, a beat after the first frame, gives the retry a
/// rasterizer that has definitely finished starting up, so it can't lose
/// the same race twice.
class _ParticleHeadline extends StatefulWidget {
  const _ParticleHeadline({required this.fontSize, required this.text});

  final double fontSize;
  final String text;

  @override
  State<_ParticleHeadline> createState() => _ParticleHeadlineState();
}

class _ParticleHeadlineState extends State<_ParticleHeadline> {
  int _attempt = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _attempt++);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Solid ink, not the translucent `palette.ink` used elsewhere — the
    // particle sampler needs a fully opaque source image to read a clean
    // shape from.
    final particleColor = paletteOf(context).dark
        ? const Color.fromARGB(255, 255, 255, 255)
        : const Color.fromARGB(255, 40, 28, 20);
    return ParticleText(
      // Keying on the text too (not just _attempt) forces the same
      // dispose-and-remount-from-scratch path the startup retry above
      // uses whenever the language toggle changes this headline's text —
      // ParticleText only ever samples its shape once, on mount.
      key: ValueKey('$_attempt-${widget.text}'),
      text: widget.text,
      config: ParticleConfig(
        fontSize: widget.fontSize,
        textAlign: TextAlign.left,
        particleColor: particleColor,
        displacedColor: particleColor,
        drawBackground: false,
        mouseRadius: 80,
        repelForce: 0.5,
        returnSpeed: 0.04,
      ),
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
  _Language('C#', Brands.c_sharp_logo),
  _Language('Dart', Brands.dart),
  _Language('Flutter', Brands.flutter),
  _Language('Kotlin', Brands.kotlin),
  _Language('TypeScript', Brands.typescript),
  _Language('JavaScript', Brands.javascript),
  _Language('HTML5', Brands.html_5),
  _Language('CSS3', Brands.css3),
];

/// Kicks off every language logo's SVG fetch up front, instead of leaving
/// each one to `_LanguageChip`'s own `Brand` (an `SvgPicture.asset`) to
/// request for the first time whenever it happens to build.
///
/// `Brand` isn't a font glyph — every logo is its own `.svg` asset file
/// fetched over the network the first time it's drawn, and `AboutSection`
/// (and its marquee) is the very first thing on the page. Left alone, all
/// eight requests only start once that first frame has already built, so on
/// anything slower than localhost the marquee is visibly missing logos —
/// each one popping in on its own as its fetch resolves — right as the
/// visitor lands on the site. Calling this from `main()`, before `runApp`
/// even hands control to the widget tree, overlaps those fetches with the
/// engine's own startup instead. flutter_svg caches by asset (see
/// `SvgAssetLoader.loadBytes`), so the chips' own `Brand` widgets later hit
/// this same warm cache rather than re-fetching.
void precacheLanguageIcons() {
  for (final language in _languages) {
    SvgAssetLoader(language.icon, packageName: 'icons_plus').loadBytes(null);
  }
}

/// The frosted card that frames the marquee: a small eyebrow label sitting
/// over the three scrolling rows, echoing the glass-panel language the rest
/// of the site uses over this animated backdrop.
class _LanguagePanel extends StatelessWidget {
  const _LanguagePanel();

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 820),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 8),
        decoration: BoxDecoration(
          color: palette.surface(0.035),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: palette.surface(0.08)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              stringsOf(context).languagesAndTools,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.4,
                color: kBlue,
              ),
            ),
            const SizedBox(height: 20),
            const _LanguageMarquee(),
          ],
        ),
      ),
    );
  }
}

/// Three stacked [_LanguageMarqueeRow]s, each carrying its own slice of
/// [_languages] and scrolling at its own speed so the rows drift out of
/// phase with each other instead of ticking past in lockstep.
class _LanguageMarquee extends StatelessWidget {
  const _LanguageMarquee();

  static const List<double> _rowSpeeds = [30, 20, 38];

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
          if (i > 0) const SizedBox(height: 18),
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
      constraints: const BoxConstraints(maxWidth: 780),
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
                builder: (context, offset, child) => Transform.translate(
                  offset: Offset(-offset, 0),
                  child: child,
                ),
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
    final palette = paletteOf(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.surface(0.07), palette.surface(0.03)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.surface(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Brand(language.icon, size: 20),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              language.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.1,
                color: palette.ink.withValues(alpha: 0.88),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
