import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

import '../i18n/app_language.dart';
import '../i18n/strings.dart';
import '../widgets/section_layout.dart';

// The two hobby cards are self-contained "objects" (a dot-grid notebook and a
// stitched leather patch), so they keep their own dark palettes in light mode
// too rather than flipping with the site theme.
const Color _kInkBg = Color(0xFF0A1020);
const Color _kInkAccent = Color(0xFF7CC0FF);
const Color _kInkBody = Color(0xFFB4BCCB);
const Color _kInkMuted = Color(0xFFA9B1C0);
const Color _kInkTagText = Color(0xFFA8D3FF);
const Color _kLeatherBg = Color(0xFF2A1B12);
const Color _kLeatherStitch = Color(0xFFD6A36E);
const Color _kLeatherAccent = Color(0xFFE0B07F);
const Color _kLeatherHeading = Color(0xFFFBEFE3);
const Color _kLeatherBody = Color(0xFFD9C3AE);
const Color _kLeatherTile = Color(0xFF3A271B);
const Color _kLeatherTileText = Color(0xFFB98E66);
const Color _kLeatherLabel = Color(0xFFF1DFCC);

class HobbiesSection extends StatelessWidget {
  const HobbiesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final s = stringsOf(context);
    final phone = isPhone(context);
    return PageSection(
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
    final padding = phone ? 22.0 : (width * 0.034).clamp(24.0, 44.0);
    final hairline = _kInkAccent.withValues(alpha: 0.16);

    final goals = [
      (s.goalConnectionsTitle, s.goalConnectionsBody),
      (s.goalJuniorTitle, s.goalJuniorBody),
      (s.goalHomeTitle, s.goalHomeBody),
    ];

    return Container(
      decoration: BoxDecoration(
        color: _kInkBg,
        borderRadius: BorderRadius.circular(phone ? 22 : 28),
        border: Border.all(color: hairline),
      ),
      clipBehavior: Clip.antiAlias,
      child: CustomPaint(
        painter: _DotGridPainter(
          color: _kInkAccent.withValues(alpha: 0.16),
          step: phone ? 20 : 22,
        ),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MonoLabel(s.goalLabel, color: _kInkAccent, size: phone ? 11 : 12),
              SizedBox(height: phone ? 16 : 22),
              Text(
                s.buildHeadline,
                style: interStyle(
                  size: phone ? 30 : 36,
                  color: Colors.white,
                  weight: FontWeight.w800,
                  letterSpacing: phone ? -0.8 : -1,
                ),
              ),
              SizedBox(height: phone ? 16 : 22),
              Text(
                s.buildParagraph,
                style: interStyle(
                  size: phone ? 15 : 16,
                  color: _kInkBody,
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
              style: monoStyle(size: phone ? 11 : 12, color: _kInkAccent),
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
                    color: Colors.white,
                    weight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: interStyle(size: 14, color: _kInkMuted, height: 1.5),
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
    return Container(
      padding: EdgeInsets.all(phone ? 18 : 22),
      decoration: BoxDecoration(
        color: _kInkBg.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(phone ? 16 : 18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            s.tutoringTitle,
            style: interStyle(
              size: phone ? 16 : 17,
              color: Colors.white,
              weight: FontWeight.w600,
            ),
          ),
          SizedBox(height: phone ? 10 : 12),
          Text(
            s.tutoringParagraph,
            style: interStyle(size: 14, color: _kInkMuted, height: 1.55),
          ),
          SizedBox(height: phone ? 10 : 12),
          Wrap(
            spacing: phone ? 6 : 8,
            runSpacing: phone ? 6 : 8,
            children: [
              for (final tag in [s.tagPatience, s.tagEmpathy, s.tagTeamPlayer])
                Pill(
                  tag,
                  background: Colors.transparent,
                  color: _kInkTagText,
                  borderColor: _kInkAccent.withValues(alpha: 0.35),
                  vertical: phone ? 5 : 6,
                  horizontal: phone ? 10 : 12,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Faint dot grid behind the goal card, like the page of a dot-grid notebook.
class _DotGridPainter extends CustomPainter {
  const _DotGridPainter({required this.color, required this.step});

  final Color color;
  final double step;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (var y = step / 2; y < size.height; y += step) {
      for (var x = step / 2; x < size.width; x += step) {
        canvas.drawCircle(Offset(x, y), 0.6, paint);
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
    final phone = isPhone(context);
    final width = MediaQuery.sizeOf(context).width;
    final padding = phone ? 18.0 : (width * 0.03).clamp(18.0, 34.0);
    return Container(
      padding: EdgeInsets.all(phone ? 8 : 10),
      decoration: BoxDecoration(
        color: _kLeatherBg,
        borderRadius: BorderRadius.circular(phone ? 22 : 28),
      ),
      child: CustomPaint(
        // The stitched seam, drawn just inside the patch's edge.
        painter: _DashedRRectPainter(
          color: _kLeatherStitch.withValues(alpha: 0.55),
          radius: phone ? 16 : 22,
        ),
        child: Padding(
          padding: EdgeInsets.all(padding),
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
                        MonoLabel(
                          s.hobbyLabel,
                          color: _kLeatherAccent,
                          size: phone ? 11 : 12,
                        ),
                        SizedBox(height: phone ? 16 : 22),
                        Text(
                          s.craftHeadline,
                          style: interStyle(
                            size: phone ? 30 : 36,
                            color: _kLeatherHeading,
                            weight: FontWeight.w800,
                            letterSpacing: phone ? -0.8 : -1,
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
                  color: _kLeatherBody,
                  height: phone ? 1.55 : 1.6,
                ),
              ),
              SizedBox(height: phone ? 16 : 22),
              MonoLabel(
                phone ? s.pastPiecesSwipeLabel : s.pastPiecesLabel,
                color: _kLeatherAccent,
                size: phone ? 11 : 12,
              ),
              SizedBox(height: phone ? 16 : 22),
              phone ? const _PiecesStrip() : const _PiecesGrid(),
            ],
          ),
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
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DashedCirclePainter(
          color: _kLeatherAccent.withValues(alpha: 0.6),
        ),
        child: Center(
          child: Text(
            phone
                ? stringsOf(context).photoPlaceholder
                : stringsOf(context).photoAtTheBench,
            textAlign: TextAlign.center,
            style: interStyle(
              size: phone ? 10 : 11,
              color: _kLeatherAccent,
              height: 1.3,
            ),
          ),
        ),
      ),
    );
  }
}

/// Past pieces, each with its photo and where to aim the crop: the photos are
/// tall portraits, so each is focused on the piece rather than the centre.
enum _Piece {
  cardHolder('assets/leather/card_holder.jpg', Alignment(0, 0.5)),
  flapWallet('assets/leather/flap_wallet.jpg', Alignment(0, 0.8)),
  bifoldWallet('assets/leather/bifold_wallet.jpg', Alignment(0, 0.45)),
  embroideredSleeve('assets/leather/embroidered_sleeve.jpg', Alignment(0, 0));

  const _Piece(this.asset, this.focus);

  final String asset;
  final Alignment focus;
}

String _pieceTitle(AppLanguage lang, _Piece piece) {
  final fr = lang == AppLanguage.fr;
  return switch (piece) {
    _Piece.cardHolder => fr ? 'Porte-cartes' : 'Card holder',
    _Piece.flapWallet => fr ? 'Portefeuille à rabat' : 'Flap wallet',
    _Piece.bifoldWallet => fr ? 'Portefeuille bifold' : 'Bifold wallet',
    _Piece.embroideredSleeve => fr ? 'Étui brodé' : 'Embroidered sleeve',
  };
}

/// A piece's photo and name. Tapping the photo opens it full size.
class _PieceTile extends StatelessWidget {
  const _PieceTile({required this.piece, this.height});

  final _Piece piece;

  /// Fixed photo height, or null for the square the grid uses.
  final double? height;

  void _openFull(BuildContext context, String title) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: InteractiveViewer(
                maxScale: 4,
                child: Image.asset(
                  piece.asset,
                  fit: BoxFit.contain,
                  semanticLabel: title,
                ),
              ),
            ),
            IconButton(
              tooltip: MaterialLocalizations.of(dialogContext).closeButtonLabel,
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: IconButton.styleFrom(backgroundColor: Colors.black54),
              icon: const Icon(Icons.close, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _pieceTitle(languageOf(context), piece);
    final photo = ClipRRect(
      borderRadius: BorderRadius.circular(height == null ? 14 : 12),
      child: Image.asset(
        piece.asset,
        fit: BoxFit.cover,
        alignment: piece.focus,
        excludeFromSemantics: true,
        errorBuilder: (_, _, _) => ColoredBox(
          color: _kLeatherTile,
          child: Center(
            child: Text(
              stringsOf(context).photoPlaceholder,
              style: monoStyle(size: 11, color: _kLeatherTileText),
            ),
          ),
        ),
      ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          label: title,
          excludeSemantics: true,
          onTap: () => _openFull(context, title),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _openFull(context, title),
              child: height == null
                  ? AspectRatio(aspectRatio: 1, child: photo)
                  : SizedBox(height: height, child: photo),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: interStyle(
            size: 13,
            color: _kLeatherLabel,
            weight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Desktop: the pieces two across.
class _PiecesGrid extends StatelessWidget {
  const _PiecesGrid();

  @override
  Widget build(BuildContext context) {
    // Not an AutoFitGrid: this sits inside the outer grid's IntrinsicHeight
    // row, which can't measure the LayoutBuilder an AutoFitGrid contains.
    const pieces = _Piece.values;
    return Column(
      children: [
        for (var i = 0; i < pieces.length; i += 2) ...[
          if (i > 0) const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _PieceTile(piece: pieces[i])),
              const SizedBox(width: 10),
              Expanded(
                child: i + 1 < pieces.length
                    ? _PieceTile(piece: pieces[i + 1])
                    : const SizedBox.shrink(),
              ),
            ],
          ),
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

/// A dashed rounded rectangle just inside its box — the stitched seam.
class _DashedRRectPainter extends CustomPainter {
  const _DashedRRectPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(1);
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
    _drawDashed(canvas, path, color);
  }

  @override
  bool shouldRepaint(_DashedRRectPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
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
  const dash = 6.0;
  const gap = 4.0;
  final paint = Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;
  for (final PathMetric metric in path.computeMetrics()) {
    var distance = 0.0;
    while (distance < metric.length) {
      final end = (distance + dash).clamp(0.0, metric.length);
      canvas.drawPath(metric.extractPath(distance, end), paint);
      distance += dash + gap;
    }
  }
}
