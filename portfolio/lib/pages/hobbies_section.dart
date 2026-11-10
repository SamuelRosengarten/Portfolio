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
          _CardsLayout(
            first: _Card(
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
            second: _Card(
              title: s.teachHeadline,
              children: [
                _Paragraph(s.tutoringTitle, s.tutoringParagraph),
                const SizedBox(height: 18),
                _Tags([s.tagPatience, s.tagEmpathy, s.tagTeamPlayer]),
              ],
            ),
            tall: _Card(
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
          ),
        ],
      ),
    );
  }
}

/// Build and Teach stacked in one column beside the taller Craft card (with
/// its four photos) on a wide screen, so the two columns end at about the
/// same height; one column of three cards on a narrow one.
class _CardsLayout extends StatelessWidget {
  const _CardsLayout({
    required this.first,
    required this.second,
    required this.tall,
  });

  /// The two short cards (stacked in the left column on a wide screen).
  final Widget first;
  final Widget second;

  /// The taller card, in the right column.
  final Widget tall;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 20.0;
        if (constraints.maxWidth >= 680) {
          // Not an AutoFitGrid: it is built on a LayoutBuilder-free
          // IntrinsicHeight row, which is all this needs too.
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: first),
                      const SizedBox(height: gap),
                      Expanded(child: second),
                    ],
                  ),
                ),
                const SizedBox(width: gap),
                Expanded(child: tall),
              ],
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            first,
            const SizedBox(height: gap),
            second,
            const SizedBox(height: gap),
            tall,
          ],
        );
      },
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

/// Past pieces, each with its photo in `assets/leather/`.
enum _Piece { cardHolder, bifoldWallet, flapWallet, embroideredSleeve }

String _pieceTitle(AppLanguage lang, _Piece piece) {
  final fr = lang == AppLanguage.fr;
  return switch (piece) {
    _Piece.cardHolder => fr ? 'Porte-cartes' : 'Card holder',
    _Piece.bifoldWallet => fr ? 'Portefeuille bifold' : 'Bifold wallet',
    _Piece.flapWallet => fr ? 'Portefeuille à rabat' : 'Flap wallet',
    _Piece.embroideredSleeve => fr ? 'Manchon brodé' : 'Embroidered sleeve',
  };
}

String _pieceAsset(_Piece piece) => switch (piece) {
  _Piece.cardHolder => 'assets/leather/card_holder.jpg',
  _Piece.bifoldWallet => 'assets/leather/bifold_wallet.jpg',
  _Piece.flapWallet => 'assets/leather/flap_wallet.jpg',
  _Piece.embroideredSleeve => 'assets/leather/embroidered_sleeve.jpg',
};

/// The four pieces as photos in a two-by-two grid, each captioned.
class _Pieces extends StatelessWidget {
  const _Pieces();

  @override
  Widget build(BuildContext context) {
    final lang = languageOf(context);
    // Not an AutoFitGrid: this sits inside the outer grid's IntrinsicHeight
    // row, which can't measure the LayoutBuilder an AutoFitGrid contains.
    Widget tile(_Piece piece) => Expanded(
      child: _PieceTile(piece: piece, lang: lang),
    );
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            tile(_Piece.cardHolder),
            const SizedBox(width: 12),
            tile(_Piece.bifoldWallet),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            tile(_Piece.flapWallet),
            const SizedBox(width: 12),
            tile(_Piece.embroideredSleeve),
          ],
        ),
      ],
    );
  }
}

class _PieceTile extends StatelessWidget {
  const _PieceTile({required this.piece, required this.lang});

  final _Piece piece;
  final AppLanguage lang;

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    final title = _pieceTitle(lang, piece);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          image: true,
          label: title,
          excludeSemantics: true,
          child: AspectRatio(
            aspectRatio: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: palette.line),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Image.asset(
                  _pieceAsset(piece),
                  fit: BoxFit.cover,
                  // The piece sits in the lower half of each photo.
                  alignment: const Alignment(0, 0.4),
                  filterQuality: FilterQuality.medium,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: bodyStyle(
            size: 13,
            color: palette.secondary,
            weight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
