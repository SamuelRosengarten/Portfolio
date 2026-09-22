import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';

import '../i18n/app_language.dart';

/// Animated backdrop for the teaching/goals half of the hobbies section: a
/// slowly breathing knowledge graph — nodes wandering gently, connected by
/// edges that occasionally send a pulse of "signal" from one to the next —
/// dusted with chalk grain and scanned by a soft light that follows the
/// pointer, like a professor's laser dot crossing a blackboard.
///
/// Deliberately a different technique from [GoldenGateBackground]: no
/// screen-blended orbs or backdrop blur, just thin lines, small glows and
/// handwritten chalk phrases. Sizes itself to fill its parent and honours
/// the platform's reduced-motion setting by holding the first frame still.
class KnowledgeGraphBackground extends StatefulWidget {
  const KnowledgeGraphBackground({
    super.key,
    required this.dark,
    required this.lang,
  });

  /// Picks between the near-black "blackboard" this was designed around and
  /// a light "whiteboard" take for the site's light mode — see
  /// [_GraphPalette].
  final bool dark;

  /// Which language the one natural-language chalk phrase ([_phrases])
  /// renders in — the math and code phrases stay as-is in both.
  final AppLanguage lang;

  @override
  State<KnowledgeGraphBackground> createState() =>
      _KnowledgeGraphBackgroundState();
}

class _KnowledgeGraphBackgroundState extends State<KnowledgeGraphBackground>
    with SingleTickerProviderStateMixin {
  // The animation's "clock": a Ticker fires _onTick on every display frame
  // (~60 times a second), which computes the current time + pointer
  // position and stores them in this ValueNotifier. Everything that needs
  // to animate (the CustomPainter below, the floating text layer) listens
  // to `_field` via ValueListenableBuilder rather than calling setState
  // directly — that's what keeps a full-screen repaint from also rebuilding
  // the whole widget tree every frame.
  final ValueNotifier<_Field> _field = ValueNotifier(_Field.zero);

  // SingleTickerProviderStateMixin (on the class above) is what lets this
  // State create a Ticker at all — it's the thing that hooks the ticker into
  // Flutter's frame scheduler and pauses it automatically when this widget
  // isn't visible (e.g. scrolled off-screen).
  late final Ticker _ticker = createTicker(_onTick);

  ui.Image? _dust;
  double _lastTick = 0;
  Offset _pointer = Offset.zero;
  Offset _pointerTarget = Offset.zero;
  Offset _pointerVelocity = Offset.zero;
  bool _stillFrame = false;

  @override
  void initState() {
    super.initState();
    _createDust();
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
    _dust?.dispose();
    super.dispose();
  }

  /// A tile of faint static, stamped out once and tiled for chalk dust —
  /// much lower contrast than film grain, so it reads as texture on the
  /// board rather than noise on a lens.
  void _createDust() {
    const side = 140;
    const alpha = 9; // ~0.035 * 255
    final random = math.Random(4021);
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
      setState(() => _dust = image);
    });
  }

  void _onTick(Duration elapsed) {
    final now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    // How much real time passed since the last frame — clamped so a stutter
    // (e.g. the tab losing focus for a second) can't make the spotlight
    // suddenly leap across the screen when frames resume.
    final dt = (now - _lastTick).clamp(0.0, 1 / 30);
    _lastTick = now;

    // A tiny physics simulation: _pointerTarget is where the mouse actually
    // is (set in _onHover below); _pointer is where the spotlight is drawn.
    // Instead of jumping straight to the target, a spring pulls it there —
    // `stiffness` is how hard it pulls, `damping` is the friction that keeps
    // it from overshooting and oscillating forever. This is what makes the
    // spotlight trail the cursor with a little lag instead of teleporting.
    // A softer, slower spring than the golden gate backdrop's — the
    // spotlight should trail like it's being dragged across a board, not
    // snap to the pointer.
    const stiffness = 42.0;
    const damping = 19.0;
    _pointerVelocity +=
        ((_pointer - _pointerTarget) * -stiffness -
            _pointerVelocity * damping) *
        dt;
    _pointer += _pointerVelocity * dt;

    _field.value = _Field(now, _pointer);
  }

  /// Converts the raw pixel position of the mouse into a [-1, 1] range on
  /// both axes (0,0 = centre of this widget) — that normalised form is what
  /// the painter and text layer both expect, so they don't need to know the
  /// widget's actual pixel size to react to the pointer.
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
    // opaque: false means this MouseRegion only *observes* the pointer —
    // it doesn't swallow hover/click events meant for whatever is drawn on
    // top of this background (the section's text, the tutoring card, etc).
    return MouseRegion(
      opaque: false,
      onHover: _stillFrame ? null : _onHover,
      onExit: (_) => _pointerTarget = Offset.zero,
      child: ClipRect(
        child: Stack(
          children: [
            // Layer 1: the CustomPainter that draws the gradient, the graph
            // of nodes/edges, the dust texture, the spotlight and the
            // vignette — see _GraphPainter below.
            Positioned.fill(
              child: RepaintBoundary(
                child: ValueListenableBuilder<_Field>(
                  valueListenable: _field,
                  builder: (context, field, _) => CustomPaint(
                    painter: _GraphPainter(
                      field,
                      _dust,
                      _GraphPalette.of(widget.dark),
                    ),
                  ),
                ),
              ),
            ),
            // Layer 2: the floating chalk-phrase text, kept as a separate
            // widget layer (rather than drawn on the canvas above) because
            // Flutter's Text widgets get proper font rendering/antialiasing
            // for free that way. IgnorePointer means this decorative layer
            // never intercepts mouse events either.
            Positioned.fill(
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: ValueListenableBuilder<_Field>(
                    valueListenable: _field,
                    builder: (context, field, _) => _ChalkLayer(
                      field: field,
                      palette: _GraphPalette.of(widget.dark),
                      lang: widget.lang,
                    ),
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

/// One frame of the animation: elapsed seconds and the spring-smoothed
/// pointer, normalised to [-1, 1] on both axes.
@immutable
class _Field {
  const _Field(this.time, this.pointer);

  static const _Field zero = _Field(0, Offset.zero);

  final double time;
  final Offset pointer;
}

// ---------------------------------------------------------------------------
// The graph
// ---------------------------------------------------------------------------

@immutable
class _Node {
  const _Node({
    required this.id,
    required this.x,
    required this.y,
    required this.radius,
    required this.color,
    this.parallax = 1.0,
  });

  final int id;
  final double x; // percent of width
  final double y; // percent of height
  final double radius;
  final Color color;
  final double parallax;
}

const Color _kNodeBlue = Color(0xFF2997FF);
const Color _kNodeCyan = Color(0xFF7DD3FF);
const Color _kNodeSpark = Color(0xFFFFFFFF);

/// Loosely arranged like a syllabus mind-map: one big hub near the centre,
/// smaller ideas branching off it.
const List<_Node> _nodes = [
  _Node(id: 1, x: 14, y: 12, radius: 4.5, color: _kNodeBlue, parallax: 0.6),
  _Node(id: 2, x: 36, y: 8, radius: 3.5, color: _kNodeCyan, parallax: -0.5),
  _Node(id: 3, x: 54, y: 18, radius: 6, color: _kNodeBlue, parallax: 0.4),
  _Node(id: 4, x: 20, y: 30, radius: 4, color: _kNodeBlue, parallax: -0.4),
  _Node(id: 5, x: 47, y: 34, radius: 2.6, color: _kNodeSpark, parallax: 0.7),
  _Node(id: 6, x: 9, y: 48, radius: 4.5, color: _kNodeCyan, parallax: 0.5),
  _Node(id: 7, x: 30, y: 53, radius: 7.5, color: _kNodeBlue, parallax: 0.3),
  _Node(id: 8, x: 55, y: 47, radius: 4, color: _kNodeBlue, parallax: -0.6),
  _Node(id: 9, x: 15, y: 67, radius: 4, color: _kNodeCyan, parallax: -0.4),
  _Node(id: 10, x: 39, y: 71, radius: 5, color: _kNodeBlue, parallax: 0.5),
  _Node(id: 11, x: 58, y: 65, radius: 2.6, color: _kNodeSpark, parallax: -0.7),
  _Node(id: 12, x: 23, y: 85, radius: 4, color: _kNodeBlue, parallax: 0.4),
  _Node(id: 13, x: 46, y: 89, radius: 4.5, color: _kNodeCyan, parallax: -0.5),
  _Node(id: 14, x: 7, y: 90, radius: 3, color: _kNodeBlue, parallax: 0.6),
];

@immutable
class _Edge {
  const _Edge(this.fromId, this.toId, this.duration, this.delay);

  final int fromId;
  final int toId;
  final double duration;
  final double delay;
}

const List<_Edge> _edges = [
  _Edge(1, 3, 3.4, 0.0),
  _Edge(2, 3, 4.1, 0.6),
  _Edge(3, 5, 2.6, 1.4),
  _Edge(3, 8, 3.8, 0.3),
  _Edge(4, 7, 3.0, 1.1),
  _Edge(1, 4, 4.6, 2.0),
  _Edge(6, 7, 3.3, 0.8),
  _Edge(7, 10, 2.8, 1.6),
  _Edge(7, 9, 4.4, 0.2),
  _Edge(5, 8, 3.6, 2.4),
  _Edge(8, 11, 3.1, 0.9),
  _Edge(9, 12, 4.0, 1.8),
  _Edge(10, 13, 2.9, 0.4),
  _Edge(11, 13, 3.7, 1.2),
  _Edge(12, 14, 4.3, 0.7),
  _Edge(6, 9, 3.5, 2.1),
  _Edge(2, 5, 4.8, 1.5),
];

/// The ink field's own dark gradient — same family as the section's navy,
/// pushed out into a few more stops for depth. [_boardGradientLight] is the
/// same shape lifted into a pale "whiteboard" for light mode.
const LinearGradient _boardGradientDark = LinearGradient(
  begin: Alignment(-0.6, -1),
  end: Alignment(0.6, 1),
  colors: [
    Color(0xFF0A0D13),
    Color(0xFF10141D),
    Color(0xFF0C0F16),
    Color(0xFF0A0C11),
  ],
  stops: [0, 0.4, 0.7, 1],
);

const LinearGradient _boardGradientLight = LinearGradient(
  begin: Alignment(-0.6, -1),
  end: Alignment(0.6, 1),
  colors: [
    Color(0xFFFBFBFD),
    Color(0xFFF2F4F8),
    Color(0xFFEDF0F5),
    Color(0xFFE7EBF2),
  ],
  stops: [0, 0.4, 0.7, 1],
);

/// Everything about the graph, spotlight and chalk text that differs
/// between the site's light and dark modes, picked once per paint via [of].
@immutable
class _GraphPalette {
  const _GraphPalette({
    required this.boardGradient,
    required this.edgeColor,
    required this.sparkColor,
    required this.spotlightBlendMode,
    required this.spotlightColor,
    required this.vignetteShadow,
    required this.vignetteClear,
    required this.chalkScript,
    required this.chalkMono,
  });

  final LinearGradient boardGradient;
  final Color edgeColor;

  /// [_kNodeSpark] is a stand-in "this node is a flash of light, not a
  /// coloured idea" marker in the node table below — white reads as that on
  /// a dark board, but would vanish on a light one, so this is what it
  /// actually gets painted as.
  final Color sparkColor;

  final BlendMode spotlightBlendMode;
  final Color spotlightColor;

  final Color vignetteShadow;
  final Color vignetteClear;

  final Color chalkScript;
  final Color chalkMono;

  static _GraphPalette get _dark => _GraphPalette(
    boardGradient: _boardGradientDark,
    edgeColor: _kNodeBlue.withValues(alpha: 0.16),
    sparkColor: _kNodeSpark,
    spotlightBlendMode: BlendMode.screen,
    spotlightColor: _kNodeCyan,
    vignetteShadow: const Color(0x99060810),
    vignetteClear: const Color(0x00060810),
    chalkScript: const Color(0xB3E7EEF7), // rgba(231,238,247,0.7)
    chalkMono: const Color(0x99A8C7E6), // rgba(168,199,230,0.6)
  );

  static _GraphPalette get _light => _GraphPalette(
    boardGradient: _boardGradientLight,
    edgeColor: _kNodeBlue.withValues(alpha: 0.28),
    sparkColor: const Color(0xFF1D2733),
    // Screening a light colour over an already-light board barely shows up,
    // so light mode paints the spotlight normally instead, like a soft
    // highlighter wash rather than a glowing beam.
    spotlightBlendMode: BlendMode.srcOver,
    spotlightColor: _kNodeBlue,
    vignetteShadow: const Color(0x2A141B26),
    vignetteClear: const Color(0x00141B26),
    chalkScript: const Color(0xB32E3D4E),
    chalkMono: const Color(0x99425A73),
  );

  static _GraphPalette of(bool dark) => dark ? _dark : _light;
}

class _GraphPainter extends CustomPainter {
  _GraphPainter(this.field, this.dust, this.palette);

  final _Field field;
  final ui.Image? dust;
  final _GraphPalette palette;

  // Canvas painting is just stacking shapes on top of each other in order,
  // like layers in an image editor — so the order below matters: background
  // gradient first, then edges (so nodes sit on top of the lines connecting
  // them), then nodes, then the dust/spotlight/vignette effects that wash
  // over everything already drawn.
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()..shader = palette.boardGradient.createShader(rect),
    );

    // Each node's current (animated) position is computed once up front and
    // shared between the edge-drawing and node-drawing passes below, so an
    // edge always connects to exactly where its node is actually drawn.
    final positions = <int, Offset>{
      for (final node in _nodes) node.id: _nodePosition(node, size),
    };

    for (final edge in _edges) {
      _paintEdge(canvas, edge, positions);
    }
    for (final node in _nodes) {
      _paintNode(canvas, node, positions[node.id]!);
    }

    final dustImage = dust;
    if (dustImage != null) {
      canvas.drawRect(
        rect,
        Paint()
          ..shader = ImageShader(
            dustImage,
            TileMode.repeated,
            TileMode.repeated,
            Matrix4.identity().storage,
          ),
      );
    }

    _paintSpotlight(canvas, size);
    _paintVignettes(canvas, size);
  }

  Offset _nodePosition(_Node node, Size size) {
    final drift = _phase(field.time, 9 + node.id * 0.7, node.id * 0.4);
    final wander =
        Offset(
          _keyframes(const [0, 5, -4, 3, 0], drift),
          _keyframes(const [0, -6, 4, -3, 0], (drift + 0.25) % 1),
        ) *
        (node.radius / 4).clamp(0.6, 1.6);

    return Offset(
          size.width * node.x / 100,
          size.height * node.y / 100,
        ) +
        wander +
        Offset(
          field.pointer.dx * node.parallax * 10,
          field.pointer.dy * node.parallax * 8,
        );
  }

  void _paintEdge(Canvas canvas, _Edge edge, Map<int, Offset> positions) {
    final from = positions[edge.fromId];
    final to = positions[edge.toId];
    if (from == null || to == null) return;

    canvas.drawLine(from, to, Paint()..color = palette.edgeColor..strokeWidth = 1);

    // A small bright pulse travels the line, as if a signal just fired
    // between the two ideas.
    final phase = _phase(field.time, edge.duration, edge.delay);
    final travel = _keyframes(const [0, 0, 1, 1], phase);
    final fade = _keyframes(const [0, 1, 1, 0], phase);
    if (fade <= 0.01) return;

    final pulse = Offset.lerp(from, to, travel)!;
    canvas.drawCircle(
      pulse,
      3,
      Paint()
        ..color = palette.sparkColor.withValues(alpha: 0.85 * fade)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
  }

  /// [_kNodeSpark] in the node table is a sentinel for "this one's a flash
  /// of light, not a coloured idea" — [_GraphPalette.sparkColor] is what
  /// that sentinel actually paints as in the current mode.
  Color _fillFor(_Node node) =>
      node.color == _kNodeSpark ? palette.sparkColor : node.color;

  void _paintNode(Canvas canvas, _Node node, Offset center) {
    final pulse = _phase(field.time, 4 + node.id * 0.3, node.id * 0.6);
    final scale = _keyframes(const [1, 1.18, 0.95, 1.08, 1], pulse);
    final glowAlpha = _keyframes(const [0.35, 0.6, 0.3, 0.5, 0.35], pulse);
    final fill = _fillFor(node);

    // Every glow in this file (node halos, the edge pulse, the spotlight)
    // is the same trick: draw a solid, plain circle, then blur it with a
    // MaskFilter. That's cheaper than a real radial-gradient-plus-blur and
    // still reads as a soft light source. Drawing it *larger and fainter*
    // (2.6x the node's own radius, low alpha) behind a small solid circle
    // is what gives the node a glow around a crisp centre, rather than
    // being uniformly blurry.
    canvas.drawCircle(
      center,
      node.radius * scale * 2.6,
      Paint()
        ..color = fill.withValues(alpha: glowAlpha * 0.35)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, node.radius),
    );
    canvas.drawCircle(
      center,
      node.radius * scale,
      Paint()..color = fill.withValues(alpha: 0.9),
    );
  }

  /// A soft light that trails the pointer — the section's stand-in for a
  /// professor's pointer sweeping across the board.
  void _paintSpotlight(Canvas canvas, Size size) {
    final center =
        Offset(size.width, size.height) / 2 +
        Offset(
          field.pointer.dx * size.width / 2,
          field.pointer.dy * size.height / 2,
        );
    final radius = size.shortestSide * 0.4;
    if (radius <= 0) return;

    // BlendMode.screen is how every "glowing light" effect in dark mode
    // avoids looking like a flat, opaque smudge painted over the graph: it
    // makes light colours *add* to what's already drawn (like two flashlight
    // beams overlapping) rather than covering it, so the spotlight brightens
    // the nodes/edges underneath it instead of hiding them. Screening a
    // light colour over an already-light board barely shows up, so light
    // mode paints normally instead (see [_GraphPalette.spotlightBlendMode]).
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..blendMode = palette.spotlightBlendMode
        ..shader =
            RadialGradient(
              colors: [
                palette.spotlightColor.withValues(alpha: 0.10),
                palette.spotlightColor.withValues(alpha: 0),
              ],
            ).createShader(
              Rect.fromCircle(center: center, radius: radius),
            ),
    );
  }

  void _paintVignettes(Canvas canvas, Size size) {
    final shadow = palette.vignetteShadow;
    final clear = palette.vignetteClear;
    final third = size.height / 3;
    if (third <= 0) return;

    final top = Rect.fromLTWH(0, 0, size.width, third);
    canvas.drawRect(
      top,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [shadow, clear],
        ).createShader(top),
    );

    final bottom = Rect.fromLTWH(0, size.height - third, size.width, third);
    canvas.drawRect(
      bottom,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [shadow, clear],
        ).createShader(bottom),
    );
  }

  @override
  bool shouldRepaint(covariant _GraphPainter oldDelegate) =>
      oldDelegate.field.time != field.time ||
      oldDelegate.field.pointer != field.pointer ||
      oldDelegate.dust != dust ||
      oldDelegate.palette != palette;
}

// ---------------------------------------------------------------------------
// Floating chalk phrases
// ---------------------------------------------------------------------------

@immutable
class _ChalkPhrase {
  const _ChalkPhrase({
    required this.text,
    required this.x,
    required this.y,
    required this.delay,
    required this.duration,
    required this.strength,
    this.handwritten = true,
  });

  final String text;
  final double x;
  final double y;
  final double delay;
  final double duration;
  final double strength;

  /// True for the chalk-script phrases, false for the handful set in a
  /// monospace face — the same "teacher's notes vs. code on the board" mix
  /// the section's copy is going for.
  final bool handwritten;
}

const List<_ChalkPhrase> _phrases = [
  _ChalkPhrase(
    text: '∀x ∈ X, P(x)',
    x: 4,
    y: 6,
    delay: 0,
    duration: 20,
    strength: 0.02,
  ),
  _ChalkPhrase(
    text: 'O(n log n)',
    x: 66,
    y: 10,
    delay: 1.4,
    duration: 17,
    strength: -0.03,
    handwritten: false,
  ),
  _ChalkPhrase(
    text: 'while (curious) { learn(); }',
    x: 60,
    y: 27,
    delay: 2.1,
    duration: 22,
    strength: 0.03,
    handwritten: false,
  ),
  _ChalkPhrase(
    text: 'y = mx + b',
    x: 3,
    y: 38,
    delay: 0.7,
    duration: 18,
    strength: -0.02,
  ),
  _ChalkPhrase(
    text: 'P ≠ NP ?',
    x: 66,
    y: 42,
    delay: 3,
    duration: 24,
    strength: 0.04,
  ),
  _ChalkPhrase(
    text: 'for (student : class)',
    x: 3,
    y: 58,
    delay: 1.9,
    duration: 19,
    strength: 0.03,
    handwritten: false,
  ),
  _ChalkPhrase(
    text: '∑ from i = 1 to n',
    x: 62,
    y: 76,
    delay: 0.4,
    duration: 21,
    strength: -0.04,
  ),
  _ChalkPhrase(
    text: 'return explain(topic);',
    x: 4,
    y: 78,
    delay: 2.6,
    duration: 16,
    strength: 0.02,
    handwritten: false,
  ),
  _ChalkPhrase(
    text: 'the proof is left as an exercise',
    x: 30,
    y: 95,
    delay: 1.2,
    duration: 25,
    strength: 0.03,
  ),
];

/// Only one of [_phrases] is actual English prose — the rest is math
/// notation and code syntax, which conventionally stays as-is regardless of
/// language (a French programmer still writes `while`/`for`/`return`).
const Map<String, String> _phraseTranslationsFr = {
  'the proof is left as an exercise': 'la preuve est laissée en exercice',
};

String _phraseText(AppLanguage lang, String text) =>
    lang == AppLanguage.fr ? (_phraseTranslationsFr[text] ?? text) : text;

class _ChalkLayer extends StatelessWidget {
  const _ChalkLayer({required this.field, required this.palette, required this.lang});

  final _Field field;
  final _GraphPalette palette;
  final AppLanguage lang;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        if (!size.isFinite || size.isEmpty) return const SizedBox.shrink();

        return Stack(
          clipBehavior: Clip.none,
          children: [
            for (final phrase in _phrases) _buildPhrase(phrase, size),
          ],
        );
      },
    );
  }

  Widget _buildPhrase(_ChalkPhrase phrase, Size size) {
    final phase = _phase(field.time, phrase.duration, phrase.delay);
    final opacity = _keyframes(const [0, 0.75, 0.6, 0.75, 0], phase);
    final drift = _keyframes(const [0, -6, 3, -4, 0], phase);

    final style = phrase.handwritten
        ? GoogleFonts.caveat(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: palette.chalkScript.withValues(
              alpha: palette.chalkScript.a * opacity,
            ),
          )
        : GoogleFonts.jetBrainsMono(
            fontSize: 11,
            color: palette.chalkMono.withValues(
              alpha: palette.chalkMono.a * opacity,
            ),
          );

    return Positioned(
      left: size.width * phrase.x / 100 + field.pointer.dx * phrase.strength * 140,
      top:
          size.height * phrase.y / 100 +
          drift +
          field.pointer.dy * phrase.strength * 100,
      child: opacity < 0.01
          ? const SizedBox.shrink()
          : Text(_phraseText(lang, phrase.text), softWrap: false, style: style),
    );
  }
}

// ---------------------------------------------------------------------------
// Keyframe helpers
// ---------------------------------------------------------------------------
//
// Together these two functions are a tiny hand-rolled animation system,
// used everywhere above instead of Flutter's AnimationController — because
// everything here is driven by one shared clock (_Field.time) rather than
// each shape owning its own controller.
//
// _phase turns "how many seconds have passed" into "where in this looping
// animation are we right now", as a value from 0 to 1 that repeats forever
// (optionally after an initial delay, so different shapes don't all animate
// in lockstep). _keyframes then turns that 0-1 position into an actual
// value by interpolating through a list of stops — e.g. keyframes([0, 10,
// -5, 0], t) moves from 0 up to 10, back down to -5, and up to 0 again as t
// sweeps 0 -> 1, easing in and out of each stop rather than moving linearly.

/// Where in a `duration`-second loop (that only starts after `delay`
/// seconds) the animation currently is, as a fraction from 0 to 1.
double _phase(double time, double duration, double delay) {
  final elapsed = time - delay;
  if (elapsed <= 0) return 0;
  return (elapsed % duration) / duration;
}

/// Interpolates through an evenly-spaced list of `values` as `t` sweeps from
/// 0 to 1, easing in and out of each one — e.g. with 3 values, t=0..0.5
/// blends the first pair and t=0.5..1 blends the second.
double _keyframes(List<double> values, double t) {
  final segments = values.length - 1;
  final scaled = t.clamp(0.0, 1.0) * segments;
  final index = math.min(scaled.floor(), segments - 1);
  final local = Curves.easeInOut.transform(scaled - index);
  return values[index] + (values[index + 1] - values[index]) * local;
}
