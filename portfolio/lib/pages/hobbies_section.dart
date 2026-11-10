import 'package:flutter/material.dart';

import '../i18n/app_language.dart';
import '../i18n/strings.dart';
import '../theme/palette.dart';
import '../widgets/section_layout.dart';

/// Beyond the code: three cards side by side on a wide screen — what's next
/// (Build.), the tutoring (Teach.) and the leatherwork (Craft.).
class HobbiesSection extends StatelessWidget {
  const HobbiesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final s = stringsOf(context);
    final phone = isPhone(context);
    return PageSection(
      bordered: true,
      topPadding: phone ? 56 : null,
      bottomPadding: phone ? 56 : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeading(headline: s.beyondTheCode, subhead: s.buildParagraph),
          SizedBox(height: phone ? 28 : 44),
          AutoFitGrid(
            minItemWidth: 330,
            spacing: 20,
            children: [
              _Card(
                title: s.buildHeadline,
                children: [
                  for (final (title, body) in [
                    (s.goalConnectionsTitle, s.goalConnectionsBody),
                    (s.goalJuniorTitle, s.goalJuniorBody),
                    (s.goalHomeTitle, s.goalHomeBody),
                  ])
                    _GoalRow(title: title, body: body),
                ],
              ),
              _Card(
                title: s.teachHeadline,
                children: [
                  _Paragraph(s.tutoringTitle, s.tutoringParagraph),
                  const SizedBox(height: 18),
                  _Tags([s.tagPatience, s.tagEmpathy, s.tagTeamPlayer]),
                ],
              ),
              _Card(
                title: s.craftHeadline,
                children: [
                  _Paragraph(null, s.craftParagraph),
                  const SizedBox(height: 20),
                  Text(
                    s.pastPiecesLabel,
                    style: bodyStyle(
                      size: 14,
                      color: paletteOf(context).tertiary,
                      weight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const _Pieces(),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    final phone = isPhone(context);
    return Container(
      padding: EdgeInsets.all(phone ? 22 : 30),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title.toUpperCase(),
            style: displayStyle(
              size: phone ? 36 : 42,
              color: palette.ink,
              weight: FontWeight.w700,
            ),
          ),
          SizedBox(height: phone ? 14 : 18),
          ...children,
        ],
      ),
    );
  }
}

class _Paragraph extends StatelessWidget {
  const _Paragraph(this.title, this.body);

  final String? title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: bodyStyle(
              size: 16,
              color: palette.ink,
              weight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Text(
          body,
          style: bodyStyle(size: 15.5, color: palette.secondary, height: 1.6),
        ),
      ],
    );
  }
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: palette.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: bodyStyle(
              size: 16,
              color: palette.ink,
              weight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: bodyStyle(size: 14.5, color: palette.secondary, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _Tags extends StatelessWidget {
  const _Tags(this.tags);

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final tag in tags)
          Pill(
            tag,
            background: Colors.transparent,
            color: palette.ink2,
            borderColor: palette.lineStrong,
          ),
      ],
    );
  }
}

/// Past pieces: [_Piece] in order.
enum _Piece { cardHolder, bifoldWallet, belt }

String _pieceTitle(AppLanguage lang, _Piece piece) {
  final fr = lang == AppLanguage.fr;
  return switch (piece) {
    _Piece.cardHolder => fr ? 'Porte-cartes' : 'Card holder',
    _Piece.bifoldWallet => fr ? 'Portefeuille' : 'Bifold wallet',
    _Piece.belt => fr ? 'Ceinture' : 'Belt',
  };
}

/// Three photo slots, waiting for pictures of the pieces.
class _Pieces extends StatelessWidget {
  const _Pieces();

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    final lang = languageOf(context);
    // Not an AutoFitGrid: this sits inside the outer grid's IntrinsicHeight
    // row, which can't measure the LayoutBuilder an AutoFitGrid contains.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < _Piece.values.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: CustomPaint(
                    foregroundPainter: DashedRRectPainter(
                      color: palette.lineStrong,
                      radius: 10,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: palette.raised,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _pieceTitle(lang, _Piece.values[i]),
                  style: bodyStyle(
                    size: 13,
                    color: palette.secondary,
                    weight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
