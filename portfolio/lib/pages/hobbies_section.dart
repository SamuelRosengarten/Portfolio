import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

import '../i18n/app_language.dart';
import '../i18n/strings.dart';
import '../theme/palette.dart';
import '../widgets/section_layout.dart';

class HobbiesSection extends StatelessWidget {
  const HobbiesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final s = stringsOf(context);
    final phone = isPhone(context);
    return PageSection(
      topPadding: phone ? 56 : null,
      bottomPadding: phone ? 56 : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeading(
            eyebrow: s.beyondTheCode,
            headline: '${s.buildHeadline} ${s.craftHeadline}',
          ),
          SizedBox(height: phone ? 28 : 40),
          const AutoFitGrid(
            minItemWidth: 440,
            spacing: 20,
            children: [_InkCard(), _LeatherCard()],
          ),
        ],
      ),
    );
  }
}

// Goal / "Build." ------------------------------------------------------------

class _InkCard extends StatelessWidget {
  const _InkCard();

  @override
  Widget build(BuildContext context) {
    final s = stringsOf(context);
    final phone = isPhone(context);
    final width = MediaQuery.sizeOf(context).width;
    final palette = paletteOf(context);
    final padding = phone ? 20.0 : (width * 0.03).clamp(24.0, 40.0);
    final hairline = palette.line;

    final goals = [
      (s.goalConnectionsTitle, s.goalConnectionsBody),
      (s.goalJuniorTitle, s.goalJuniorBody),
      (s.goalHomeTitle, s.goalHomeBody),
    ];

    return Container(
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: hairline),
      ),
      clipBehavior: Clip.antiAlias,
      child: CustomPaint(
        painter: _DotGridPainter(color: palette.canvasDot, step: phone ? 20 : 22),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Eyebrow(s.goalLabel, size: phone ? 11 : 12),
              SizedBox(height: phone ? 16 : 22),
              Text(
                s.buildHeadline,
                style: interStyle(
                  size: phone ? 28 : 34,
                  color: palette.ink,
                  weight: FontWeight.w700,
                  letterSpacing: phone ? -0.9 : -1.2,
                ),
              ),
              SizedBox(height: phone ? 16 : 22),
              Text(
                s.buildParagraph,
                style: interStyle(
                  size: phone ? 15 : 16,
                  color: palette.secondary,
                  height: phone ? 1.55 : 1.6,
                ),
              ),
              SizedBox(height: phone ? 16 : 22),
              Container(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: hairline)),
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < goals.length; i++)
                      _GoalRow(
                        index: i + 1,
                        title: goals[i].$1,
                        body: goals[i].$2,
                        hairline: hairline,
                      ),
                  ],
                ),
              ),
              // Pins the tutoring panel to the bottom when the neighbouring
              // card is the taller one.
              const Spacer(),
              SizedBox(height: phone ? 16 : 22),
              const _TutoringPanel(),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({
    required this.index,
    required this.title,
    required this.body,
    required this.hairline,
  });

  final int index;
  final String title;
  final String body;
  final Color hairline;

  @override
  Widget build(BuildContext context) {
    final phone = isPhone(context);
    final palette = paletteOf(context);
    return Container(
      padding: EdgeInsets.symmetric(vertical: phone ? 12 : 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: hairline)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              index.toString().padLeft(2, '0'),
              style: monoStyle(size: phone ? 11 : 12, color: palette.tertiary),
            ),
          ),
          SizedBox(width: phone ? 14 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: interStyle(
                    size: phone ? 15 : 16,
                    color: palette.ink,
                    weight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: interStyle(size: 14, color: palette.tertiary, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TutoringPanel extends StatelessWidget {
  const _TutoringPanel();

  @override
  Widget build(BuildContext context) {
    final s = stringsOf(context);
    final phone = isPhone(context);
    final palette = paletteOf(context);
    return Container(
      padding: EdgeInsets.all(phone ? 16 : 20),
      decoration: BoxDecoration(
        color: palette.altBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: palette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            s.tutoringTitle,
            style: interStyle(
              size: phone ? 16 : 17,
              color: palette.ink,
              weight: FontWeight.w600,
            ),
          ),
          SizedBox(height: phone ? 10 : 12),
          Text(
            s.tutoringParagraph,
            style: interStyle(size: 14, color: palette.tertiary, height: 1.55),
          ),
          SizedBox(height: phone ? 10 : 12),
          Wrap(
            spacing: phone ? 6 : 8,
            runSpacing: phone ? 6 : 8,
            children: [
              for (final tag in [s.tagPatience, s.tagEmpathy, s.tagTeamPlayer])
                Pill(
                  tag,
                  background: palette.raised,
                  color: palette.secondary,
                  borderColor: palette.line,
                  vertical: phone ? 4 : 5,
                  horizontal: phone ? 10 : 11,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Faint dot grid behind the goal card: the same canvas the app's graph uses.
class _DotGridPainter extends CustomPainter {
  const _DotGridPainter({required this.color, required this.step});

  final Color color;
  final double step;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (var y = step / 2; y < size.height; y += step) {
      for (var x = step / 2; x < size.width; x += step) {
        canvas.drawCircle(Offset(x, y), 1.1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.step != step;
}

// Hobby / "Craft." -----------------------------------------------------------

class _LeatherCard extends StatelessWidget {
  const _LeatherCard();

  @override
  Widget build(BuildContext context) {
    final s = stringsOf(context);
    final palette = paletteOf(context);
    final phone = isPhone(context);
    final width = MediaQuery.sizeOf(context).width;
    final padding = phone ? 20.0 : (width * 0.03).clamp(24.0, 40.0);
    // Dashed lavender outline on a faint lavender fill: the app's "AI
    // suggestion" card, standing in for the old stitched-leather seam.
    return CustomPaint(
      foregroundPainter: DashedRRectPainter(
        color: palette.aiLine,
        radius: 12,
      ),
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: palette.aiFaint,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.hobbyLabel,
                        style: monoStyle(
                          size: phone ? 11 : 12,
                          color: palette.accent,
                          weight: FontWeight.w500,
                          letterSpacing: 0.9,
                        ),
                      ),
                      SizedBox(height: phone ? 16 : 22),
                      Text(
                        s.craftHeadline,
                        style: interStyle(
                          size: phone ? 28 : 34,
                          color: palette.ink,
                          weight: FontWeight.w700,
                          letterSpacing: phone ? -0.9 : -1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _BenchPhoto(size: phone ? 72 : 88),
              ],
            ),
            SizedBox(height: phone ? 16 : 22),
            Text(
              s.craftParagraph,
              style: interStyle(
                size: phone ? 15 : 16,
                color: palette.secondary,
                height: phone ? 1.55 : 1.6,
              ),
            ),
            SizedBox(height: phone ? 16 : 22),
            MonoLabel(
              phone ? s.pastPiecesSwipeLabel : s.pastPiecesLabel,
              size: phone ? 11 : 12,
            ),
            SizedBox(height: phone ? 16 : 22),
            phone ? const _PiecesStrip() : const _PiecesGrid(),
          ],
        ),
      ),
    );
  }
}

/// The empty circular photo slot beside the "Craft." heading.
class _BenchPhoto extends StatelessWidget {
  const _BenchPhoto({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final phone = size < 80;
    final palette = paletteOf(context);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DashedCirclePainter(
          color: palette.aiLine,
        ),
        child: Center(
          child: Text(
            phone ? stringsOf(context).photoPlaceholder : stringsOf(context).photoAtTheBench,
            textAlign: TextAlign.center,
            style: monoStyle(
              size: phone ? 10 : 11,
              color: palette.accent,
              height: 1.3,
            ),
          ),
        ),
      ),
    );
  }
}

/// Past pieces: [_pieces] in order.
enum _Piece { cardHolder, bifoldWallet, belt, toteBag, keychain }

String _pieceTitle(AppLanguage lang, _Piece piece) {
  final fr = lang == AppLanguage.fr;
  return switch (piece) {
    _Piece.cardHolder => fr ? 'Porte-cartes' : 'Card holder',
    _Piece.bifoldWallet => fr ? 'Portefeuille bifold' : 'Bifold wallet',
    _Piece.belt => fr ? 'Ceinture' : 'Belt',
    _Piece.toteBag => fr ? 'Sac fourre-tout' : 'Tote bag',
    _Piece.keychain => fr ? 'Porte-clés' : 'Keychain',
  };
}

class _PieceTile extends StatelessWidget {
  const _PieceTile({required this.piece, this.height});

  final _Piece piece;

  /// Fixed tile height, or null for the 4:5 ratio the grid uses.
  final double? height;

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    final label = Text(
      _pieceTitle(languageOf(context), piece),
      style: interStyle(
        size: 13,
        color: palette.ink2,
        weight: FontWeight.w500,
      ),
    );
    final tile = Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: palette.raised,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: palette.line),
      ),
      child: Text(
        stringsOf(context).photoPlaceholder,
        style: monoStyle(size: 11, color: palette.tertiary),
      ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        height == null
            ? AspectRatio(aspectRatio: 4 / 5, child: tile)
            : SizedBox(height: height, child: tile),
        const SizedBox(height: 8),
        label,
      ],
    );
  }
}

/// Desktop: the first three pieces in a grid.
class _PiecesGrid extends StatelessWidget {
  const _PiecesGrid();

  @override
  Widget build(BuildContext context) {
    // Not an AutoFitGrid: this sits inside the outer grid's IntrinsicHeight
    // row, which can't measure the LayoutBuilder an AutoFitGrid contains.
    const shown = [_Piece.cardHolder, _Piece.bifoldWallet, _Piece.belt];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < shown.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(child: _PieceTile(piece: shown[i])),
        ],
      ],
    );
  }
}

/// Phone: every piece in a sideways-scrolling strip.
class _PiecesStrip extends StatelessWidget {
  const _PiecesStrip();

  @override
  Widget build(BuildContext context) {
    // Sized by its content (not a fixed height) so a longer French label
    // can't overflow the tile.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < _Piece.values.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            SizedBox(
              width: 132,
              child: _PieceTile(piece: _Piece.values[i], height: 160),
            ),
          ],
        ],
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  const _DashedCirclePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()..addOval((Offset.zero & size).deflate(1));
    _drawDashed(canvas, path, color);
  }

  @override
  bool shouldRepaint(_DashedCirclePainter oldDelegate) =>
      oldDelegate.color != color;
}

void _drawDashed(Canvas canvas, Path path, Color color) {
  const dash = 5.0;
  const gap = 4.0;
  final paint = Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.2;
  for (final PathMetric metric in path.computeMetrics()) {
    var distance = 0.0;
    while (distance < metric.length) {
      final end = (distance + dash).clamp(0.0, metric.length);
      canvas.drawPath(metric.extractPath(distance, end), paint);
      distance += dash + gap;
    }
  }
}
