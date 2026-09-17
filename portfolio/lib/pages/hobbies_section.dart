import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/palette.dart';

// Two halves, two palettes. The ink side borrows the site's own blue accent
// so it still reads as "this site"; the leather side gets its own warm,
// tanned tones that would look wrong anywhere else on the page.
const Color _kInkBg = Color(0xFF10141C);
const Color _kLeatherDark = Color(0xFF3B2416);
const Color _kLeatherMid = Color(0xFF5E3A22);
const Color _kLeatherTan = Color(0xFFC99A62);
const Color _kLeatherThread = Color(0xFFE7D3AE);

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

/// Wide layout: one full-bleed field split by a diagonal, stitched seam.
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
        final leftSafeWidth = width * _bottomFraction;
        final rightSafeLeft = width * _topFraction;

        return Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_kLeatherMid, _kLeatherDark],
                ),
              ),
            ),
            ClipPath(
              clipper: const _DiagonalClipper(
                topFraction: _topFraction,
                bottomFraction: _bottomFraction,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const ColoredBox(color: _kInkBg),
                  CustomPaint(painter: _DotGridPainter(), size: size),
                ],
              ),
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
                    color: Colors.white.withValues(alpha: 0.45),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 64,
              top: 0,
              bottom: 0,
              width: math.max(leftSafeWidth - 96, 260),
              child: Center(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: _InkContent(headlineSize: _headlineSize(width)),
                ),
              ),
            ),
            Positioned(
              left: rightSafeLeft + 40,
              right: 64,
              top: 0,
              bottom: 0,
              child: Center(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: _LeatherContent(headlineSize: _headlineSize(width)),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Narrow layout: the same two halves, stacked full-width instead of
/// diagonally split, joined by a horizontal stitched seam.
class _StackedSplit extends StatelessWidget {
  const _StackedSplit();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            color: _kInkBg,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(painter: _DotGridPainter()),
                Center(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 24,
                    ),
                    child: const _InkContent(headlineSize: 44),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 18,
          width: double.infinity,
          child: CustomPaint(
            painter: _HorizontalSeamPainter(
              color: _kLeatherThread.withValues(alpha: 0.55),
            ),
          ),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_kLeatherMid, _kLeatherDark],
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 24,
                ),
                child: const _LeatherContent(headlineSize: 44),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

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

/// A faint dot grid over the ink half — a nod to grid paper and binary,
/// without spelling either out.
class _DotGridPainter extends CustomPainter {
  const _DotGridPainter();

  static const double _spacing = 34;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.045);
    for (var y = _spacing / 2; y < size.height; y += _spacing) {
      for (var x = _spacing / 2; x < size.width; x += _spacing) {
        canvas.drawCircle(Offset(x, y), 1.3, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter oldDelegate) => false;
}

/// Left/ink half: the goal, and the tutoring already underway toward it.
class _InkContent extends StatelessWidget {
  const _InkContent({required this.headlineSize});

  final double headlineSize;

  @override
  Widget build(BuildContext context) {
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
        const SizedBox(height: 10),
        Text(
          'Teach.',
          style: GoogleFonts.inter(
            fontSize: headlineSize,
            fontWeight: FontWeight.w700,
            letterSpacing: -2,
            height: 1,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 18),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Text(
            'The long-term plan is a university classroom, teaching '
            'computer science — the kind of place where an idea gets to '
            'be interesting instead of just correct.',
            style: GoogleFonts.inter(
              fontSize: 16,
              height: 1.6,
              color: Colors.white.withValues(alpha: 0.68),
            ),
          ),
        ),
        const SizedBox(height: 26),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.groups_outlined,
                      size: 20,
                      color: kBlue.withValues(alpha: 0.9),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tutoring at school, right now',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Running peer tutoring sessions for computer science '
                  'students — the same instinct as the goal above, just '
                  'at a smaller scale: sit with someone until the '
                  'concept clicks.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.55,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 16),
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

/// Right/leather half: the bench, a place for a photo, and a carousel of
/// past pieces.
class _LeatherContent extends StatelessWidget {
  const _LeatherContent({required this.headlineSize});

  final double headlineSize;

  @override
  Widget build(BuildContext context) {
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
        const SizedBox(height: 14),
        Text(
          'Craft.',
          style: GoogleFonts.inter(
            fontSize: headlineSize,
            fontWeight: FontWeight.w700,
            letterSpacing: -2,
            height: 1,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 18),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Text(
            'Cutting, stitching, burnishing — pieces that take hours and '
            'get better with every one. The saddle stitch taught me more '
            'about patience than any deadline ever did.',
            style: GoogleFonts.inter(
              fontSize: 16,
              height: 1.6,
              color: Colors.white.withValues(alpha: 0.72),
            ),
          ),
        ),
        const SizedBox(height: 26),
        Text(
          'PAST PIECES',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            color: _kLeatherTan,
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(width: 380, child: const _LeatherCarousel()),
      ],
    );
  }
}

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
            color: Colors.white.withValues(alpha: 0.5),
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 140,
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
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            for (var i = 0; i < _products.length; i++)
              _CarouselDot(active: (_page.round() == i)),
          ],
        ),
      ],
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
        color: active ? _kLeatherTan : Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final _LeatherProduct product;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kLeatherTan.withValues(alpha: 0.25)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_outlined,
              size: 24,
              color: Colors.white.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 8),
            Text(
              product.title,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Add photo',
              style: GoogleFonts.inter(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
