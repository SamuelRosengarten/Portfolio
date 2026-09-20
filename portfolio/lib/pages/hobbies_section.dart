import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/palette.dart';
import '../widgets/knowledge_graph_background.dart';
import '../widgets/leather_background.dart';

// The leather side's small accents borrow from the same warm, tanned family
// as its animated backdrop.
const Color _kLeatherTan = Color(0xFFC99A62);
const Color _kLeatherThread = Color(0xFFE7D3AE);

// =============================================================================
// Entry point — picks wide (diagonal) vs. narrow (stacked) layout.
// =============================================================================

/// This section breaks from the rest of the page on purpose: full bleed,
/// no side gutters, split diagonally down the middle instead of stacked
/// cards — a classroom on one side, a workbench on the other, stitched
/// together at the seam.
class HobbiesSection extends StatelessWidget {
  const HobbiesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;
          return wide ? const _DiagonalSplit() : const _StackedSplit();
        },
      ),
    );
  }
}

double _headlineSize(double width) {
  if (width >= 1300) return 88;
  if (width >= 900) return 68;
  return 52;
}

// =============================================================================
// Wide layout: the diagonal split.
// =============================================================================

/// Wide layout: one full-bleed field split by a diagonal, stitched seam.
///
/// The diagonal itself is defined by just two numbers: where it crosses the
/// top edge of the section ([_topFraction], as a fraction of the total
/// width) and where it crosses the bottom edge ([_bottomFraction]). Because
/// those two x-positions differ, the line connecting them is a diagonal
/// rather than a vertical line — see [_DiagonalClipper] below, which turns
/// those two fractions into the actual clipped shape.
class _DiagonalSplit extends StatelessWidget {
  const _DiagonalSplit();

  static const double _topFraction = 0.56;
  static const double _bottomFraction = 0.44;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final size = Size(width, constraints.maxHeight);
        // The diagonal leans, so its x-position is different at the top of
        // the section than at the bottom. That means the widest safe (i.e.
        // guaranteed not to be cut by the diagonal) column for the *ink*
        // side's text is bounded by wherever the diagonal is narrowest —
        // its bottom position — and likewise the leather side's safe
        // column has to start from wherever the diagonal is widest, its
        // top position. Get this backwards and the text would overlap the
        // diagonal cut at the top or bottom of the section.
        final leftSafeWidth = width * _bottomFraction;
        final rightSafeLeft = width * _topFraction;
        final dark = paletteOf(context).dark;

        return Stack(
          fit: StackFit.expand,
          children: [
            // Painted in back-to-front order: the leather background fills
            // the whole section first, then the ink background is clipped
            // to the diagonal wedge and painted on top of it — so the
            // "ink" half is really just "leather with an ink-coloured
            // shape covering part of it", not two separate halves.
            LeatherBackground(dark: dark),
            ClipPath(
              clipper: const _DiagonalClipper(
                topFraction: _topFraction,
                bottomFraction: _bottomFraction,
              ),
              child: KnowledgeGraphBackground(dark: dark),
            ),
            CustomPaint(
              painter: _SeamPainter(
                topFraction: _topFraction,
                bottomFraction: _bottomFraction,
                color: _kLeatherThread.withValues(alpha: 0.55),
              ),
              size: size,
            ),
            Positioned(
              top: 28,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'BEYOND THE CODE',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 3,
                    color: paletteOf(context).ink.withValues(alpha: 0.45),
                  ),
                ),
              ),
            ),
            // The ink content sits inside a box that starts 64px from the
            // left edge and is `leftSafeWidth - 96` wide — leaving 32px of
            // additional breathing room on the right, before the diagonal.
            // `math.max(..., 260)` is a floor so the text column never gets
            // squeezed narrower than 260px if the diagonal fractions above
            // were ever changed to something more extreme.
            Positioned(
              left: 64,
              top: 0,
              bottom: 0,
              width: math.max(leftSafeWidth - 96, 260),
              child: _HoverPop(
                child: _InkContent(headlineSize: _headlineSize(width)),
              ),
            ),
            // Mirror image of the block above: starts 40px past the
            // diagonal's widest point and runs to 64px from the right edge.
            Positioned(
              left: rightSafeLeft + 40,
              right: 64,
              top: 0,
              bottom: 0,
              child: _HoverPop(
                child: _LeatherContent(headlineSize: _headlineSize(width)),
              ),
            ),
          ],
        );
      },
    );
  }
}

// =============================================================================
// Narrow layout: the stacked split.
// =============================================================================

/// Narrow layout: the same two halves, stacked full-width instead of
/// diagonally split, joined by a horizontal stitched seam.
class _StackedSplit extends StatelessWidget {
  const _StackedSplit();

  @override
  Widget build(BuildContext context) {
    final dark = paletteOf(context).dark;
    return Column(
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              KnowledgeGraphBackground(dark: dark),
              const _HoverPop(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: _InkContent(headlineSize: 30),
              ),
            ],
          ),
        ),
        Container(
          height: 18,
          width: double.infinity,
          // The dashed seam only paints the dashes themselves, leaving gaps
          // between them — without an opaque fill behind it, those gaps show
          // whatever happens to be painted further back in the tree instead
          // of reading as a deliberate divider.
          color: paletteOf(context).bg,
          child: CustomPaint(
            painter: _HorizontalSeamPainter(
              color: _kLeatherThread.withValues(alpha: 0.55),
            ),
          ),
        ),
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              LeatherBackground(dark: dark),
              const _HoverPop(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: _LeatherContent(headlineSize: 30),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Shared hover-pop wrapper — used by both layouts above.
// =============================================================================

/// Wraps a half's content so it lifts and scales up slightly on hover —
/// the whole side reads as one interactive card, not just static text.
class _HoverPop extends StatefulWidget {
  const _HoverPop({required this.child, this.padding = EdgeInsets.zero});

  final Widget child;
  final EdgeInsets padding;

  @override
  State<_HoverPop> createState() => _HoverPopState();
}

class _HoverPopState extends State<_HoverPop> {
  bool _hovering = false;

  // The same MouseRegion + setState hover pattern used across the site (see
  // the comment in contact_section.dart's _ContactCardState) — here driving
  // two animated properties (scale and a slight upward slide) at once,
  // instead of just a colour or border.
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Center(
        // SingleChildScrollView is a safety net, not the primary intent:
        // this content is normally short enough to fit in the half it's
        // given, but on an unusually short/zoomed-in viewport it can
        // scroll instead of overflowing and throwing a render error.
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: widget.padding,
          child: AnimatedScale(
            scale: _hovering ? 1.045 : 1.0,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: AnimatedSlide(
              offset: _hovering ? const Offset(0, -0.015) : Offset.zero,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Geometry & painters for the diagonal/horizontal seam.
// =============================================================================

/// A jagged quadrilateral: wider at the top, narrower at the bottom — the
/// ink wedge cut into the leather field.
class _DiagonalClipper extends CustomClipper<Path> {
  const _DiagonalClipper({
    required this.topFraction,
    required this.bottomFraction,
  });

  final double topFraction;
  final double bottomFraction;

  @override
  Path getClip(Size size) {
    final topX = size.width * topFraction;
    final bottomX = size.width * bottomFraction;
    // Traces the shape's outline as four corners, clockwise from the
    // top-left: top-left corner -> across to the diagonal's top point ->
    // down to the diagonal's bottom point -> across to the bottom-left
    // corner -> `close()` draws the final edge back up to the start. The
    // result is everything to the left of the diagonal line.
    return Path()
      ..moveTo(0, 0)
      ..lineTo(topX, 0)
      ..lineTo(bottomX, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant _DiagonalClipper oldClipper) =>
      oldClipper.topFraction != topFraction ||
      oldClipper.bottomFraction != bottomFraction;
}

/// A dashed saddle-stitch running along the diagonal seam between the two
/// halves.
class _SeamPainter extends CustomPainter {
  const _SeamPainter({
    required this.topFraction,
    required this.bottomFraction,
    required this.color,
  });

  final double topFraction;
  final double bottomFraction;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final top = Offset(size.width * topFraction, 0);
    final bottom = Offset(size.width * bottomFraction, size.height);
    final length = (bottom - top).distance;
    final direction = (bottom - top) / length;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    const dash = 10.0, gap = 8.0;
    var travelled = 0.0;
    while (travelled < length) {
      final start = top + direction * travelled;
      final end = top + direction * math.min(travelled + dash, length);
      canvas.drawLine(start, end, paint);
      travelled += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _SeamPainter oldDelegate) =>
      oldDelegate.topFraction != topFraction ||
      oldDelegate.bottomFraction != bottomFraction ||
      oldDelegate.color != color;
}

/// The stacked layout's straight-across stitch, for narrow screens.
class _HorizontalSeamPainter extends CustomPainter {
  const _HorizontalSeamPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final y = size.height / 2;
    const dash = 10.0, gap = 8.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset(x + dash, y), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _HorizontalSeamPainter oldDelegate) =>
      oldDelegate.color != color;
}

// =============================================================================
// Ink half: content.
// =============================================================================

/// Left/ink half: the goal, and the tutoring already underway toward it.
class _InkContent extends StatelessWidget {
  const _InkContent({required this.headlineSize});

  final double headlineSize;

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'GOAL',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
            color: kBlue,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Teach.',
          style: GoogleFonts.inter(
            fontSize: headlineSize,
            fontWeight: FontWeight.w700,
            letterSpacing: -2,
            height: 1,
            color: palette.ink,
          ),
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Text(
            'The long-term plan is a university classroom, teaching '
            'computer science — the kind of place where an idea gets to '
            'be interesting instead of just correct.',
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.4,
              color: palette.ink.withValues(alpha: 0.68),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: palette.surface(0.06),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: palette.surface(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.groups_outlined,
                      size: 18,
                      color: kBlue.withValues(alpha: 0.9),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tutoring at school, right now',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: palette.ink,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Running peer tutoring sessions for computer science '
                  'students — the same instinct as the goal above, just '
                  'at a smaller scale: sit with someone until the '
                  'concept clicks.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    height: 1.4,
                    color: palette.ink.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 12),
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Tag('Algorithms', color: kBlue),
                    _Tag('Data Structures', color: kBlue),
                    _Tag('Intro to Programming', color: kBlue),
                    _Tag('OOP', color: kBlue),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Leather half: content, avatar placeholder, and the product carousel.
// =============================================================================

/// Right/leather half: the bench, a place for a photo, and a carousel of
/// past pieces.
class _LeatherContent extends StatelessWidget {
  const _LeatherContent({required this.headlineSize});

  final double headlineSize;

  @override
  Widget build(BuildContext context) {
    final ink = paletteOf(context).ink;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const _AvatarPlaceholder(),
            const SizedBox(width: 16),
            Text(
              'HOBBY',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
                color: _kLeatherTan,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Craft.',
          style: GoogleFonts.inter(
            fontSize: headlineSize,
            fontWeight: FontWeight.w700,
            letterSpacing: -2,
            height: 1,
            color: ink,
          ),
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Text(
            'Cutting, stitching, burnishing — pieces that take hours and '
            'get better with every one. The saddle stitch taught me more '
            'about patience than any deadline ever did.',
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.4,
              color: ink.withValues(alpha: 0.72),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'PAST PIECES',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            color: _kLeatherTan,
          ),
        ),
        const SizedBox(height: 10),
        // ConstrainedBox rather than a fixed-width SizedBox: on an iPhone-
        // width screen this half's available width is well under 380px, and
        // a fixed width there would push the carousel past the edge of the
        // screen instead of shrinking to fit it.
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 380),
          child: SizedBox(width: double.infinity, child: _LeatherCarousel()),
        ),
      ],
    );
  }
}

/// A small pill/chip. Used by [_InkContent] for the subject tags — kept
/// here rather than up near that class because it's a generic, reusable
/// piece rather than ink-specific content.
class _Tag extends StatelessWidget {
  const _Tag(this.label, {required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

/// A dashed ring standing in for a future photo of me at the bench.
class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: CustomPaint(
        painter: _DashedCirclePainter(
          color: _kLeatherTan.withValues(alpha: 0.6),
        ),
        child: Center(
          child: Icon(
            Icons.person_outline,
            size: 22,
            color: paletteOf(context).ink.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  const _DashedCirclePainter({required this.color});

  final Color color;
  static const int _dashCount = 20;
  static const double _dashFraction = 0.55;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    final rect = (Offset.zero & size).deflate(1.5);
    final segment = (2 * math.pi) / _dashCount;
    for (var i = 0; i < _dashCount; i++) {
      canvas.drawArc(rect, i * segment, segment * _dashFraction, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _LeatherProduct {
  const _LeatherProduct(this.title);

  final String title;
}

const _products = [
  _LeatherProduct('Card holder'),
  _LeatherProduct('Bifold wallet'),
  _LeatherProduct('Belt'),
  _LeatherProduct('Tote bag'),
  _LeatherProduct('Keychain'),
];

/// A peek-style, snapping carousel of past pieces. Each card is a
/// placeholder — swap `_products` for real pieces and drop a photo into
/// each [_ProductCard] once there is something to show.
class _LeatherCarousel extends StatefulWidget {
  const _LeatherCarousel();

  @override
  State<_LeatherCarousel> createState() => _LeatherCarouselState();
}

class _LeatherCarouselState extends State<_LeatherCarousel> {
  late final PageController _controller = PageController(
    viewportFraction: 0.42,
  );
  double _page = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _page = _controller.page ?? 0);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _controller.animateToPage(
      page.clamp(0, _products.length - 1),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 112,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ScrollConfiguration is needed here because Flutter's default
              // scroll behaviour only lets touch/stylus/trackpad *drag* to
              // scroll — a mouse can only turn a scroll wheel by default, so
              // without this override, clicking and dragging the carousel
              // with a mouse (the only option on desktop/web) does nothing.
              ScrollConfiguration(
                behavior: _MouseDragScrollBehavior(),
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: _ProductCard(product: _products[index]),
                    );
                  },
                ),
              ),
              // Arrow buttons give a guaranteed way to move the carousel
              // even where dragging is inconvenient (e.g. a trackpad-less
              // mouse), rather than relying on drag/swipe alone.
              Positioned(
                left: 0,
                child: _CarouselArrow(
                  icon: Icons.chevron_left,
                  onTap: () => _goToPage(_page.round() - 1),
                ),
              ),
              Positioned(
                right: 0,
                child: _CarouselArrow(
                  icon: Icons.chevron_right,
                  onTap: () => _goToPage(_page.round() + 1),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            for (var i = 0; i < _products.length; i++)
              GestureDetector(
                onTap: () => _goToPage(i),
                // The dot itself is only 6px tall — far too small to hit
                // reliably with a finger. behavior: opaque plus this padding
                // gives each one a ~36px tap zone without changing how big
                // the dots look.
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 4,
                  ),
                  child: _CarouselDot(active: (_page.round() == i)),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// The default [ScrollBehavior] only treats touch/stylus/trackpad input as a
/// drag gesture; this adds the mouse so the carousel can be click-dragged on
/// desktop and web too.
class _MouseDragScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    ...super.dragDevices,
    PointerDeviceKind.mouse,
  };
}

class _CarouselArrow extends StatelessWidget {
  const _CarouselArrow({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.35),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        // 44x44 keeps the tap target at Apple/Google's recommended minimum
        // for a finger — the icon itself stays the same visual size, just
        // centred in a roomier hit area than the old 4px padding gave it.
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: Icon(
              icon,
              size: 20,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ),
      ),
    );
  }
}

class _CarouselDot extends StatelessWidget {
  const _CarouselDot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 6),
      width: active ? 16 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: active ? _kLeatherTan : paletteOf(context).surface(0.25),
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }
}

class _ProductCard extends StatefulWidget {
  const _ProductCard({required this.product});

  final _LeatherProduct product;

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedScale(
        scale: _hovering ? 1.06 : 1.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: palette.surface(_hovering ? 0.1 : 0.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _kLeatherTan.withValues(alpha: _hovering ? 0.5 : 0.25),
            ),
            boxShadow: _hovering
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : const [],
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.image_outlined,
                  size: 24,
                  color: palette.ink.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.product.title,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: palette.ink.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Add photo',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: palette.ink.withValues(alpha: 0.35),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
