import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';

/// Animated "Golden Gate dark" backdrop: gradient orbs screened over near-black,
/// seen through dark frosted glass, dusted with grain, vignetted top and bottom,
/// and drifting with code snippets. Ported from the React/Motion `GoldenGateDark`
/// component — the orb and snippet tables below are the same data, and the mouse
/// parallax uses the same spring.
///
/// Sizes itself to [child], which paints on top of the animation. Honours the
/// platform's reduced-motion setting by holding the first frame still.
class GoldenGateBackground extends StatefulWidget {
  const GoldenGateBackground({
    super.key,
    this.animationSpeed = 8,
    required this.child,
  });

  /// Base orb drift period in seconds; each orb adds a little to it. The
  /// original exposed this as a 4–20 slider.
  final double animationSpeed;

  final Widget child;

  @override
  State<GoldenGateBackground> createState() => _GoldenGateBackgroundState();
}

class _GoldenGateBackgroundState extends State<GoldenGateBackground>
    with SingleTickerProviderStateMixin {
  /// Drives every layer from one clock, so the orbs and snippets share a frame.
  final ValueNotifier<_Field> _field = ValueNotifier(_Field.zero);

  late final Ticker _ticker = createTicker(_onTick);

  ui.Image? _grain;
  double _lastTick = 0;
  Offset _pointer = Offset.zero;
  Offset _pointerTarget = Offset.zero;
  Offset _pointerVelocity = Offset.zero;
  bool _stillFrame = false;

  @override
  void initState() {
    super.initState();
    _createGrain();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _stillFrame = MediaQuery.disableAnimationsOf(context);
    if (_stillFrame && _ticker.isActive) {
      _ticker.stop();
      _field.value = _Field.zero;
    } else if (!_stillFrame && !_ticker.isActive) {
      _lastTick = 0;
      _ticker.start();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _field.dispose();
    _grain?.dispose();
    super.dispose();
  }

  /// A tile of static noise, stamped out once and tiled for film grain.
  void _createGrain() {
    const side = 180;
    // The original's 0.06 layer opacity, baked into the tile. PixelFormat
    // .rgba8888 is premultiplied, so the colour channels have to be scaled by
    // the alpha — full-brightness channels at a low alpha are invalid and clamp
    // to white, which turns the grain into static.
    const alpha = 15; // 0.06 * 255
    final random = math.Random(1937);
    final pixels = Uint8List(side * side * 4);
    for (var i = 0; i < side * side; i++) {
      final value = random.nextInt(256) * alpha ~/ 255;
      final offset = i * 4;
      pixels[offset] = value;
      pixels[offset + 1] = value;
      pixels[offset + 2] = value;
      pixels[offset + 3] = alpha;
    }
    ui.decodeImageFromPixels(pixels, side, side, ui.PixelFormat.rgba8888, (
      image,
    ) {
      if (!mounted) {
        image.dispose();
        return;
      }
      setState(() => _grain = image);
    });
  }

  void _onTick(Duration elapsed) {
    final now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    // Clamped so a dropped frame cannot kick the spring across the screen.
    final dt = (now - _lastTick).clamp(0.0, 1 / 30);
    _lastTick = now;

    // Same spring as the original's useSpring(stiffness: 55, damping: 22).
    const stiffness = 55.0;
    const damping = 22.0;
    _pointerVelocity +=
        ((_pointer - _pointerTarget) * -stiffness -
            _pointerVelocity * damping) *
        dt;
    _pointer += _pointerVelocity * dt;

    _field.value = _Field(now, _pointer);
  }

  void _onHover(PointerHoverEvent event) {
    final size = context.size;
    if (size == null || size.isEmpty) return;
    // Normalised to [-1, 1] on both axes, like the React handler.
    _pointerTarget = Offset(
      (event.localPosition.dx / size.width) * 2 - 1,
      (event.localPosition.dy / size.height) * 2 - 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      opaque: false,
      onHover: _stillFrame ? null : _onHover,
      onExit: (_) => _pointerTarget = Offset.zero,
      child: ClipRect(
        child: Stack(
          children: [
            Positioned.fill(
              child: RepaintBoundary(
                child: ValueListenableBuilder<_Field>(
                  valueListenable: _field,
                  builder: (context, field, _) => CustomPaint(
                    painter: _OrbFieldPainter(
                      field: field,
                      grain: _grain,
                      animationSpeed: widget.animationSpeed,
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: ValueListenableBuilder<_Field>(
                    valueListenable: _field,
                    builder: (context, field, _) => _CodeLayer(field: field),
                  ),
                ),
              ),
            ),
            widget.child,
          ],
        ),
      ),
    );
  }
}

/// One frame of the animation: elapsed seconds and the spring-smoothed pointer.
@immutable
class _Field {
  const _Field(this.time, this.pointer);

  static const _Field zero = _Field(0, Offset.zero);

  final double time;
  final Offset pointer;
}

// ---------------------------------------------------------------------------
// Orbs
// ---------------------------------------------------------------------------

@immutable
class _Orb {
  const _Orb({
    required this.id,
    required this.colors,
    required this.midStop,
    required this.size,
    required this.x,
    required this.y,
    required this.parallaxStrength,
    required this.opacity,
  });

  /// [colors] and [midStop] are the original
  /// `radial-gradient(circle, a 0%, b midStop%, transparent 100%)`.
  final int id;
  final List<Color> colors;
  final double midStop;
  final double size;
  final double x; // percent of the section's width
  final double y; // percent of the section's height
  final double parallaxStrength;
  final double opacity;
}

const List<_Orb> _orbs = <_Orb>[
  _Orb(
    id: 1,
    colors: [Color(0xFFC94010), Color(0xFFFF5722)],
    midStop: 0.5,
    size: 600,
    x: 8,
    y: 3,
    parallaxStrength: 0.05,
    opacity: 0.65,
  ),
  _Orb(
    id: 2,
    colors: [Color(0xFFB8650A), Color(0xFFF4A020)],
    midStop: 0.5,
    size: 520,
    x: 70,
    y: 6,
    parallaxStrength: -0.06,
    opacity: 0.55,
  ),
  _Orb(
    id: 3,
    colors: [Color(0xFF0A2F6E), Color(0xFF1565C0)],
    midStop: 0.55,
    size: 500,
    x: 76,
    y: 56,
    parallaxStrength: 0.04,
    opacity: 0.6,
  ),
  _Orb(
    id: 4,
    colors: [Color(0xFF006272), Color(0xFF00ACC1)],
    midStop: 0.55,
    size: 440,
    x: 3,
    y: 58,
    parallaxStrength: -0.05,
    opacity: 0.5,
  ),
  _Orb(
    id: 5,
    colors: [Color(0xFFA83200), Color(0xFFFF6E40)],
    midStop: 0.55,
    size: 400,
    x: 40,
    y: 70,
    parallaxStrength: 0.07,
    opacity: 0.5,
  ),
  _Orb(
    id: 6,
    colors: [Color(0xFF7B1A00), Color(0xFFBF360C)],
    midStop: 0.55,
    size: 340,
    x: 26,
    y: 20,
    parallaxStrength: -0.04,
    opacity: 0.45,
  ),
  _Orb(
    id: 7,
    colors: [Color(0xFFA07800), Color(0xFFFFD54F)],
    midStop: 0.55,
    size: 380,
    x: 56,
    y: 28,
    parallaxStrength: 0.06,
    opacity: 0.4,
  ),
  _Orb(
    id: 8,
    colors: [Color(0xFF050F24), Color(0xFF0D2B55)],
    midStop: 0.55,
    size: 300,
    x: 16,
    y: 80,
    parallaxStrength: -0.03,
    opacity: 0.55,
  ),
];

/// `linear-gradient(145deg, …)` — near-black with a faint blue cast, so the
/// screened orbs read as light rather than paint.
const LinearGradient _baseGradient = LinearGradient(
  begin: Alignment(-0.57, -1),
  end: Alignment(0.57, 1),
  colors: [
    Color(0xFF080A10),
    Color(0xFF0C0E18),
    Color(0xFF0A0C14),
    Color(0xFF080A12),
  ],
  stops: [0, 0.35, 0.65, 1],
);

/// `saturate(1.6) brightness(0.9)` as a colour matrix, using the Rec. 709
/// luminance weights CSS filters are defined against.
const ColorFilter _glassTone = ColorFilter.matrix(<double>[
  1.3252, -0.3862, -0.0390, 0, 0, //
  -0.1148, 1.0538, -0.0390, 0, 0, //
  -0.1148, -0.3862, 1.4010, 0, 0, //
  0, 0, 0, 1, 0, //
]);

/// The frosted-glass pass: `backdrop-filter: blur(55px) saturate(1.6)
/// brightness(0.9)` applied to the orb field below it.
final ui.ImageFilter _glassFilter = ui.ImageFilter.compose(
  outer: _glassTone,
  inner: ui.ImageFilter.blur(sigmaX: 55, sigmaY: 55),
);

class _OrbFieldPainter extends CustomPainter {
  _OrbFieldPainter({
    required this.field,
    required this.grain,
    required this.animationSpeed,
  });

  final _Field field;
  final ui.Image? grain;
  final double animationSpeed;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Painting the ground and orbs through one blurred layer stands in for the
    // stacked CSS filters. The layer bleeds past the section so the blur does
    // not fade out along its own edges; the ClipRect trims the overhang.
    final bleed = rect.inflate(180);
    canvas.saveLayer(bleed, Paint()..imageFilter = _glassFilter);
    canvas.drawRect(bleed, Paint()..shader = _baseGradient.createShader(rect));
    for (final orb in _orbs) {
      _paintOrb(canvas, size, orb);
    }
    canvas.restore();

    // rgba(6,8,16,0.35) — the dark glass pane's own tint.
    canvas.drawRect(rect, Paint()..color = const Color(0x59060810));

    final grainImage = grain;
    if (grainImage != null) {
      canvas.drawRect(
        rect,
        Paint()
          ..shader = ImageShader(
            grainImage,
            TileMode.repeated,
            TileMode.repeated,
            Matrix4.identity().storage,
          ),
      );
    }

    _paintVignettes(canvas, size);
  }

  void _paintOrb(Canvas canvas, Size size, _Orb orb) {
    final drift = _phase(
      field.time,
      animationSpeed + orb.id * 1.3,
      orb.id * 0.5,
    );
    final scale = _keyframes(const [1, 1.06, 0.97, 1.03, 1], drift);
    final radius = orb.size / 2 * scale;

    final center =
        Offset(
          size.width * orb.x / 100 + orb.size / 2,
          size.height * orb.y / 100 + orb.size / 2,
        ) +
        // Keyframed drift…
        Offset(
          _keyframes(const [0, 12, -8, 7, 0], drift),
          _keyframes(const [0, -20, 10, -14, 0], drift),
        ) +
        // …plus the pointer parallax.
        Offset(
          field.pointer.dx * orb.parallaxStrength * 280,
          field.pointer.dy * orb.parallaxStrength * 180,
        );

    final stops = <Color>[
      orb.colors[0].withValues(alpha: orb.opacity),
      orb.colors[1].withValues(alpha: orb.opacity),
      orb.colors[1].withValues(alpha: 0),
    ];

    // A CSS circle gradient runs to the farthest corner of its square box, so
    // the visible disc only reaches ~71% along the ramp. `mix-blend-mode:
    // screen` is what keeps the orbs glowing where they overlap.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..blendMode = BlendMode.screen
        ..shader = RadialGradient(colors: stops, stops: [0, orb.midStop, 1])
            .createShader(
              Rect.fromCircle(center: center, radius: radius * math.sqrt2),
            )
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, orb.size * 0.1),
    );
  }

  /// The two `rgba(4,6,12,0.5) → transparent` vignettes over the top and bottom
  /// thirds, which seat the section against whatever sits above and below it.
  void _paintVignettes(Canvas canvas, Size size) {
    const shadow = Color(0x8004060C);
    const clear = Color(0x0004060C);
    final third = size.height / 3;
    if (third <= 0) return;

    final top = Rect.fromLTWH(0, 0, size.width, third);
    canvas.drawRect(
      top,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [shadow, clear],
        ).createShader(top),
    );

    final bottom = Rect.fromLTWH(0, size.height - third, size.width, third);
    canvas.drawRect(
      bottom,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [shadow, clear],
        ).createShader(bottom),
    );
  }

  @override
  bool shouldRepaint(_OrbFieldPainter oldDelegate) =>
      oldDelegate.field.time != field.time ||
      oldDelegate.field.pointer != field.pointer ||
      oldDelegate.grain != grain ||
      oldDelegate.animationSpeed != animationSpeed;
}

// ---------------------------------------------------------------------------
// Floating code snippets
// ---------------------------------------------------------------------------

@immutable
class _Snippet {
  const _Snippet({
    required this.text,
    required this.x,
    required this.y,
    required this.delay,
    required this.duration,
    required this.strength,
  });

  final String text;
  final double x; // percent of the section's width
  final double y; // percent of the section's height
  final double delay;
  final double duration;
  final double strength;
}

const List<_Snippet> _snippets = <_Snippet>[
  _Snippet(
    text: 'const bridge = new GoldenGate();',
    x: 3,
    y: 8,
    delay: 0,
    duration: 18,
    strength: 0.03,
  ),
  _Snippet(
    text: 'git commit -m "ship it 🌉"',
    x: 68,
    y: 12,
    delay: 1.5,
    duration: 22,
    strength: -0.04,
  ),
  _Snippet(
    text: 'npm run build --env=production',
    x: 5,
    y: 88,
    delay: 0.8,
    duration: 20,
    strength: 0.05,
  ),
  _Snippet(
    text: 'function span(city, code) {',
    x: 74,
    y: 82,
    delay: 2.2,
    duration: 16,
    strength: -0.03,
  ),
  _Snippet(
    text: '  return bridge.connect(city, code);',
    x: 76,
    y: 87,
    delay: 2.2,
    duration: 16,
    strength: -0.03,
  ),
  _Snippet(text: '}', x: 74, y: 92, delay: 2.2, duration: 16, strength: -0.03),
  _Snippet(
    text: '// TODO: paint it international orange',
    x: 2,
    y: 42,
    delay: 3,
    duration: 24,
    strength: 0.04,
  ),
  _Snippet(
    text: 'SELECT * FROM bay WHERE fog = true;',
    x: 60,
    y: 53,
    delay: 1.2,
    duration: 19,
    strength: 0.06,
  ),
  _Snippet(
    text: '<GoldenGate elevation={227} />',
    x: 4,
    y: 68,
    delay: 2.7,
    duration: 21,
    strength: -0.05,
  ),
  _Snippet(
    text: "import { courage } from 'san-francisco';",
    x: 55,
    y: 4,
    delay: 0.3,
    duration: 17,
    strength: 0.03,
  ),
  _Snippet(
    text: 'docker build -t golden-gate:latest .',
    x: 2,
    y: 22,
    delay: 1.8,
    duration: 23,
    strength: 0.04,
  ),
  _Snippet(
    text: "{ status: 200, span: '1.7 miles' }",
    x: 68,
    y: 68,
    delay: 0.6,
    duration: 20,
    strength: -0.04,
  ),
  _Snippet(
    text: 'while (true) { keep.building(); }',
    x: 30,
    y: 93,
    delay: 2.4,
    duration: 18,
    strength: 0.05,
  ),
  _Snippet(
    text: 'export default SanFrancisco;',
    x: 48,
    y: 18,
    delay: 1.1,
    duration: 25,
    strength: -0.03,
  ),
];

const Color _kCodeInk = Color(0xA6D2B99B); // rgba(210,185,155,0.65)
const Color _kCodeKeyword = Color(0xFFFF6D3A);
const Color _kCodeString = Color(0xFFFFB830);
const Color _kCodeComment = Color(0xB2B4823C); // rgba(180,130,60,0.7)

const List<String> _keywords = [
  'const',
  'function',
  'return',
  'import',
  'from',
  'export',
  'default',
  'while',
  'true',
  'new',
  'SELECT',
  'WHERE',
  'docker',
  'git',
  'npm',
];

/// Quoted strings first, then the keyword list — the order the original applies
/// its replacements in, so a quoted run stays golden throughout.
final RegExp _tokenPattern = RegExp(
  '"[^"]*"|\'[^\']*\'|\\b(${_keywords.join('|')})\\b',
);

class _CodeLayer extends StatelessWidget {
  const _CodeLayer({required this.field});

  final _Field field;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        if (!size.isFinite || size.isEmpty) return const SizedBox.shrink();

        return Stack(
          clipBehavior: Clip.none,
          children: [
            for (final snippet in _snippets) ..._buildSnippet(snippet, size),
          ],
        );
      },
    );
  }

  Iterable<Widget> _buildSnippet(_Snippet snippet, Size size) {
    final phase = _phase(field.time, snippet.duration, snippet.delay);
    final opacity = _keyframes(const [0, 0.7, 0.55, 0.7, 0], phase);
    if (opacity < 0.01) return const [];

    final drift = _keyframes(const [0, -8, 4, -6, 0], phase);

    return [
      Positioned(
        left:
            size.width * snippet.x / 100 +
            field.pointer.dx * snippet.strength * 220,
        top:
            size.height * snippet.y / 100 +
            drift +
            field.pointer.dy * snippet.strength * 160,
        child: Text.rich(
          TextSpan(children: _colorize(snippet.text, opacity)),
          softWrap: false,
          overflow: TextOverflow.visible,
          style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.2),
        ),
      ),
    ];
  }

  /// The original's tiny syntax highlighter: comments in muted amber, keywords
  /// in Golden Gate orange, quoted strings in gold, the rest in warm ink.
  List<InlineSpan> _colorize(String text, double opacity) {
    Color fade(Color color) => color.withValues(alpha: color.a * opacity);

    final commentStart = text.indexOf('//');
    final code = commentStart >= 0 ? text.substring(0, commentStart) : text;
    final comment = commentStart >= 0 ? text.substring(commentStart) : null;

    final spans = <InlineSpan>[];
    var cursor = 0;
    for (final match in _tokenPattern.allMatches(code)) {
      if (match.start > cursor) {
        spans.add(
          TextSpan(
            text: code.substring(cursor, match.start),
            style: TextStyle(color: fade(_kCodeInk)),
          ),
        );
      }
      final token = match[0]!;
      final quoted = token.startsWith('"') || token.startsWith("'");
      spans.add(
        TextSpan(
          text: token,
          style: TextStyle(color: fade(quoted ? _kCodeString : _kCodeKeyword)),
        ),
      );
      cursor = match.end;
    }
    if (cursor < code.length) {
      spans.add(
        TextSpan(
          text: code.substring(cursor),
          style: TextStyle(color: fade(_kCodeInk)),
        ),
      );
    }
    if (comment != null) {
      spans.add(
        TextSpan(
          text: comment,
          style: TextStyle(color: fade(_kCodeComment)),
        ),
      );
    }
    return spans;
  }
}

// ---------------------------------------------------------------------------
// Keyframe helpers
// ---------------------------------------------------------------------------

/// Position within a looping animation of [duration] seconds that only starts
/// after [delay], matching Motion's `repeat: Infinity` with a lead-in delay.
double _phase(double time, double duration, double delay) {
  final elapsed = time - delay;
  if (elapsed <= 0) return 0;
  return (elapsed % duration) / duration;
}

/// Evenly spaced keyframes with ease-in-out between each pair — how Motion
/// interpolates a `[a, b, c]` value list.
double _keyframes(List<double> values, double t) {
  final segments = values.length - 1;
  final scaled = t.clamp(0.0, 1.0) * segments;
  final index = math.min(scaled.floor(), segments - 1);
  final local = Curves.easeInOut.transform(scaled - index);
  return values[index] + (values[index + 1] - values[index]) * local;
}
