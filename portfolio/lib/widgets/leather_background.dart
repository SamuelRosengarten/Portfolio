import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';

/// Animated backdrop for the craft half of the hobbies section: a few warm
/// embers glowing over dark hide, two hand-stitched seams wandering across
/// it with a needle-pull of light travelling along each, and leathercraft
/// notes drifting past like labels pinned to a workbench. Warmed over from
/// a mouse-lit bump map that read as muddy at small sizes — this uses the
/// same engine as [GoldenGateBackground] and `KnowledgeGraphBackground`
/// (a shared clock driving glowing shapes, drifting text, grain and a
/// pointer-trailing glow) so all three backdrops read as one family, each
/// in its own palette.
class LeatherBackground extends StatefulWidget {
  const LeatherBackground({super.key});

  @override
  State<LeatherBackground> createState() => _LeatherBackgroundState();
}

// This State follows exactly the same shape as
// _KnowledgeGraphBackgroundState in knowledge_graph_background.dart — see
// that file for a fuller line-by-line explanation of the Ticker/
// ValueNotifier/spring-physics plumbing shared by all three animated
// backgrounds in this project. The comments below only call out what's
// different about the leather version.
class _LeatherBackgroundState extends State<LeatherBackground>
    with SingleTickerProviderStateMixin {
  // Every animated shape below reads its clock from here rather than from
  // setState, so the section repaints every frame without rebuilding widgets.
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

  void _createGrain() {
    const side = 150;
    const alpha = 11; // ~0.043 * 255, warmer/lighter than the ink side's dust
    final random = math.Random(7331);
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
    final dt = (now - _lastTick).clamp(0.0, 1 / 30);
    _lastTick = now;

    // Spring physics pulling the drawn pointer position (_pointer) toward
    // the real one (_pointerTarget) — see the matching comment in
    // knowledge_graph_background.dart's _onTick for the full explanation.
    const stiffness = 48.0;
    const damping = 20.0;
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
                  builder: (context, field, _) =>
                      CustomPaint(painter: _HideFieldPainter(field, _grain)),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: ValueListenableBuilder<_Field>(
                    valueListenable: _field,
                    builder: (context, field, _) =>
                        _LabelLayer(field: field),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

@immutable
class _Field {
  const _Field(this.time, this.pointer);

  static const _Field zero = _Field(0, Offset.zero);

  final double time;
  final Offset pointer;
}

// ---------------------------------------------------------------------------
// Embers
// ---------------------------------------------------------------------------

@immutable
class _Ember {
  const _Ember({
    required this.id,
    required this.colors,
    required this.size,
    required this.x,
    required this.y,
    required this.parallax,
    required this.opacity,
  });

  final int id;
  final List<Color> colors;
  final double size;
  final double x;
  final double y;
  final double parallax;
  final double opacity;
}

const Color _kEmberRust = Color(0xFFB8451C);
const Color _kEmberOrange = Color(0xFFE8763A);
const Color _kEmberGold = Color(0xFFE3A23D);

const List<_Ember> _embers = [
  _Ember(
    id: 1,
    colors: [_kEmberRust, _kEmberOrange],
    size: 260,
    x: 12,
    y: 14,
    parallax: 0.05,
    opacity: 0.55,
  ),
  _Ember(
    id: 2,
    colors: [_kEmberGold, _kEmberOrange],
    size: 220,
    x: 72,
    y: 8,
    parallax: -0.06,
    opacity: 0.45,
  ),
  _Ember(
    id: 3,
    colors: [_kEmberRust, _kEmberGold],
    size: 300,
    x: 54,
    y: 42,
    parallax: 0.04,
    opacity: 0.5,
  ),
  _Ember(
    id: 4,
    colors: [_kEmberOrange, _kEmberGold],
    size: 200,
    x: 18,
    y: 58,
    parallax: -0.05,
    opacity: 0.4,
  ),
  _Ember(
    id: 5,
    colors: [_kEmberRust, _kEmberOrange],
    size: 260,
    x: 82,
    y: 62,
    parallax: 0.06,
    opacity: 0.45,
  ),
  _Ember(
    id: 6,
    colors: [_kEmberGold, _kEmberRust],
    size: 220,
    x: 38,
    y: 84,
    parallax: -0.04,
    opacity: 0.4,
  ),
];

const LinearGradient _hideGradient = LinearGradient(
  begin: Alignment(-0.6, -1),
  end: Alignment(0.6, 1),
  colors: [
    Color(0xFF2B160B),
    Color(0xFF3A2010),
    Color(0xFF24120A),
    Color(0xFF1C0E07),
  ],
  stops: [0, 0.4, 0.7, 1],
);

// ---------------------------------------------------------------------------
// Stitched seams — two wandering polylines with a needle-pull of light.
// ---------------------------------------------------------------------------

@immutable
class _StitchSeam {
  const _StitchSeam({
    required this.points,
    required this.duration,
    required this.delay,
  });

  /// Percent-of-size coordinates the seam runs through.
  final List<Offset> points;
  final double duration;
  final double delay;
}

const List<_StitchSeam> _seams = [
  _StitchSeam(
    points: [
      Offset(6, 20),
      Offset(28, 32),
      Offset(18, 50),
      Offset(42, 58),
      Offset(34, 78),
      Offset(58, 84),
    ],
    duration: 6,
    delay: 0.4,
  ),
  _StitchSeam(
    points: [
      Offset(62, 14),
      Offset(78, 26),
      Offset(70, 46),
      Offset(88, 54),
      Offset(80, 74),
    ],
    duration: 7,
    delay: 2.2,
  ),
];

const Color _kStitchThread = Color(0xFFE7C27A);

/// A point a given fraction of the way along a multi-segment polyline —
/// this is what makes the "needle-pull" glow in [_HideFieldPainter._paintSeam]
/// able to travel smoothly through every bend in a seam, not just a single
/// straight line.
///
/// `t` is 0 (the very start of the seam) to 1 (the very end). Since each
/// segment of the seam can be a different length, this can't just multiply
/// `t` by the point list's length — a seam with one long segment and one
/// short one needs the glow to spend proportionally longer on the long one.
/// So the approach is: measure every segment's real length, add them up for
/// the seam's total length, then walk segment by segment subtracting each
/// one's length from how far we still need to travel until we land inside
/// the right segment — at which point `segT` is how far through *that*
/// segment we are, and `Offset.lerp` finds the exact point.
Offset _pointAtFraction(List<Offset> points, double t) {
  if (points.length < 2) return points.first;
  final lengths = <double>[];
  var total = 0.0;
  for (var i = 0; i < points.length - 1; i++) {
    final segment = (points[i + 1] - points[i]).distance;
    lengths.add(segment);
    total += segment;
  }
  if (total <= 0) return points.first;

  var travelled = t.clamp(0.0, 1.0) * total;
  for (var i = 0; i < lengths.length; i++) {
    if (travelled <= lengths[i] || i == lengths.length - 1) {
      final segT = lengths[i] == 0 ? 0.0 : (travelled / lengths[i]).clamp(0.0, 1.0);
      return Offset.lerp(points[i], points[i + 1], segT)!;
    }
    travelled -= lengths[i];
  }
  return points.last;
}

// ---------------------------------------------------------------------------
// Painter
// ---------------------------------------------------------------------------

class _HideFieldPainter extends CustomPainter {
  _HideFieldPainter(this.field, this.grain);

  final _Field field;
  final ui.Image? grain;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = _hideGradient.createShader(rect));

    for (final ember in _embers) {
      _paintEmber(canvas, size, ember);
    }
    for (final seam in _seams) {
      _paintSeam(canvas, size, seam);
    }

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

    _paintSpotlight(canvas, size);
    _paintVignettes(canvas, size);
  }

  void _paintEmber(Canvas canvas, Size size, _Ember ember) {
    final drift = _phase(field.time, 10 + ember.id * 1.6, ember.id * 0.6);
    final scale = _keyframes(const [1, 1.08, 0.95, 1.05, 1], drift);
    final radius = ember.size / 2 * scale;

    final center =
        Offset(
          size.width * ember.x / 100,
          size.height * ember.y / 100,
        ) +
        Offset(
          _keyframes(const [0, 10, -6, 8, 0], drift),
          _keyframes(const [0, -14, 8, -10, 0], (drift + 0.3) % 1),
        ) +
        Offset(
          field.pointer.dx * ember.parallax * 280,
          field.pointer.dy * ember.parallax * 180,
        );

    final stops = [
      ember.colors[0].withValues(alpha: ember.opacity),
      ember.colors[1].withValues(alpha: ember.opacity * 0.7),
      ember.colors[1].withValues(alpha: 0),
    ];

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..blendMode = BlendMode.screen
        ..shader = RadialGradient(colors: stops, stops: const [0, 0.55, 1])
            .createShader(Rect.fromCircle(center: center, radius: radius))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, ember.size * 0.12),
    );
  }

  void _paintSeam(Canvas canvas, Size size, _StitchSeam seam) {
    final pts = seam.points
        .map((p) => Offset(size.width * p.dx / 100, size.height * p.dy / 100))
        .toList();

    final paint = Paint()
      ..color = _kStitchThread.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    // Build one continuous Path through every point in the seam...
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].dx, pts[i].dy);
    }

    // ...then fake a dashed stroke by walking its length in fixed
    // dash/gap steps and drawing only the "dash" pieces. Flutter's Canvas
    // has no built-in dashed-line support, so this manual
    // computeMetrics/extractPath approach — measure the path, then cut out
    // and draw only the segments we want — is the standard way to do it,
    // and the same technique used for every dashed line in this project
    // (the seam between the two halves in hobbies_section.dart, the dashed
    // avatar ring, etc).
    const dash = 7.0, gap = 6.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = math.min(distance + dash, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + gap;
      }
    }

    // The needle-pull: a small bright glow travelling the seam.
    final phase = _phase(field.time, seam.duration, seam.delay);
    final travel = _keyframes(const [0, 0, 1, 1], phase);
    final fade = _keyframes(const [0, 1, 1, 0], phase);
    if (fade <= 0.01) return;

    final pulse = _pointAtFraction(pts, travel);
    canvas.drawCircle(
      pulse,
      3.4,
      Paint()
        ..color = _kStitchThread.withValues(alpha: 0.9 * fade)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5),
    );
  }

  void _paintSpotlight(Canvas canvas, Size size) {
    final center =
        Offset(size.width, size.height) / 2 +
        Offset(
          field.pointer.dx * size.width / 2,
          field.pointer.dy * size.height / 2,
        );
    final radius = size.shortestSide * 0.42;
    if (radius <= 0) return;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..blendMode = BlendMode.screen
        ..shader = RadialGradient(
          colors: [
            _kEmberGold.withValues(alpha: 0.12),
            _kEmberGold.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  void _paintVignettes(Canvas canvas, Size size) {
    const shadow = Color(0x991A0D06);
    const clear = Color(0x001A0D06);
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
  bool shouldRepaint(covariant _HideFieldPainter oldDelegate) =>
      oldDelegate.field.time != field.time ||
      oldDelegate.field.pointer != field.pointer ||
      oldDelegate.grain != grain;
}

// ---------------------------------------------------------------------------
// Floating leathercraft notes
// ---------------------------------------------------------------------------

@immutable
class _Label {
  const _Label({
    required this.text,
    required this.x,
    required this.y,
    required this.delay,
    required this.duration,
    required this.strength,
    this.mono = false,
  });

  final String text;
  final double x;
  final double y;
  final double delay;
  final double duration;
  final double strength;
  final bool mono;
}

const List<_Label> _labels = [
  _Label(text: 'saddle stitch', x: 5, y: 8, delay: 0, duration: 19, strength: 0.02),
  _Label(
    text: '8 stitches / inch',
    x: 64,
    y: 12,
    delay: 1.6,
    duration: 21,
    strength: -0.03,
    mono: true,
  ),
  _Label(
    text: 'vegetable-tanned',
    x: 4,
    y: 36,
    delay: 0.9,
    duration: 18,
    strength: 0.02,
  ),
  _Label(
    text: 'skive to 2mm',
    x: 62,
    y: 34,
    delay: 2.6,
    duration: 20,
    strength: -0.04,
    mono: true,
  ),
  _Label(
    text: 'edge, bevel, burnish',
    x: 3,
    y: 62,
    delay: 1.3,
    duration: 23,
    strength: 0.03,
  ),
  _Label(
    text: 'waxed thread',
    x: 66,
    y: 78,
    delay: 0.5,
    duration: 17,
    strength: -0.02,
  ),
  _Label(
    text: 'awl · pricking iron',
    x: 4,
    y: 88,
    delay: 2.1,
    duration: 22,
    strength: 0.03,
    mono: true,
  ),
  _Label(text: 'oil, then wax', x: 30, y: 96, delay: 1.9, duration: 24, strength: 0.02),
];

const Color _kLabelScript = Color(0xB3F1E2C9); // rgba(241,226,201,0.7)
const Color _kLabelMono = Color(0x99E8B98A); // rgba(232,185,138,0.6)

class _LabelLayer extends StatelessWidget {
  const _LabelLayer({required this.field});

  final _Field field;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        if (!size.isFinite || size.isEmpty) return const SizedBox.shrink();

        return Stack(
          clipBehavior: Clip.none,
          children: [for (final label in _labels) _buildLabel(label, size)],
        );
      },
    );
  }

  Widget _buildLabel(_Label label, Size size) {
    final phase = _phase(field.time, label.duration, label.delay);
    final opacity = _keyframes(const [0, 0.75, 0.6, 0.75, 0], phase);
    final drift = _keyframes(const [0, -6, 3, -4, 0], phase);

    final style = label.mono
        ? GoogleFonts.jetBrainsMono(
            fontSize: 11,
            color: _kLabelMono.withValues(alpha: _kLabelMono.a * opacity),
          )
        : GoogleFonts.caveat(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: _kLabelScript.withValues(alpha: _kLabelScript.a * opacity),
          );

    return Positioned(
      left:
          size.width * label.x / 100 +
          field.pointer.dx * label.strength * 140,
      top:
          size.height * label.y / 100 +
          drift +
          field.pointer.dy * label.strength * 100,
      child: opacity < 0.01
          ? const SizedBox.shrink()
          : Text(label.text, softWrap: false, style: style),
    );
  }
}

// ---------------------------------------------------------------------------
// Keyframe helpers — see the matching, more heavily commented copy in
// knowledge_graph_background.dart for the full explanation of how these two
// functions work together as a tiny hand-rolled animation system.
// ---------------------------------------------------------------------------

double _phase(double time, double duration, double delay) {
  final elapsed = time - delay;
  if (elapsed <= 0) return 0;
  return (elapsed % duration) / duration;
}

double _keyframes(List<double> values, double t) {
  final segments = values.length - 1;
  final scaled = t.clamp(0.0, 1.0) * segments;
  final index = math.min(scaled.floor(), segments - 1);
  final local = Curves.easeInOut.transform(scaled - index);
  return values[index] + (values[index + 1] - values[index]) * local;
}
