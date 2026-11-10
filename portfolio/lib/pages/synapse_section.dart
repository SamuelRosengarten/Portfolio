import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import '../theme/palette.dart';
import '../widgets/devices.dart';
import '../widgets/section_layout.dart';

/// The Synapse OS showcase: the product pitch, the Mac + iPhone hero shot (in
/// the site's current theme, since the apps follow light and dark too), the
/// three promises, an iPhone gallery and the Mac app. Designed in Figma
/// (https://www.figma.com/design/OGWIDIf19lEsgXTltUo4sq, "Synapse OS
/// showcase").
class SynapseSection extends StatelessWidget {
  const SynapseSection({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    final phone = isPhone(context);
    final s = stringsOf(context);
    final glow = palette.dark
        ? const Color(0xFF7928CA).withValues(alpha: 0.24)
        : const Color(0xFF7C5CF0).withValues(alpha: 0.12);
    return PageSection(
      background: palette.bg,
      bordered: true,
      decoration: RadialGradient(
        center: const Alignment(0.85, -0.95),
        radius: 0.9,
        colors: [glow, glow.withValues(alpha: 0)],
      ),
      topPadding: phone ? 64 : null,
      bottomPadding: phone ? 64 : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Intro(),
          SizedBox(height: phone ? 36 : 56),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth.clamp(0.0, 1200.0);
              final dark = palette.dark;
              return Center(
                child: MacAndPhone(
                  width: width,
                  macAsset:
                      'assets/synapse/mac_today_${dark ? 'dark' : 'light'}.webp',
                  phoneAsset:
                      'assets/synapse/ios_today_${dark ? 'dark' : 'light'}.webp',
                  semanticLabel: s.heroShotLabel,
                ),
              );
            },
          ),
          SizedBox(height: phone ? 40 : 64),
          AutoFitGrid(
            minItemWidth: 280,
            spacing: 28,
            runSpacing: 24,
            children: [
              _Promise(s.featurePrivateAiTitle, s.featurePrivateAiBody),
              _Promise(s.featureApproveTitle, s.featureApproveBody),
              _Promise(s.featureTeamsTitle, s.featureTeamsBody),
            ],
          ),
          SizedBox(height: phone ? 56 : 96),
          _SubHeading(s.onIphone, s.onIphoneBody),
          SizedBox(height: phone ? 24 : 36),
          const _IphoneGallery(),
          SizedBox(height: phone ? 56 : 96),
          const _MacBlock(),
        ],
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro();

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    final s = stringsOf(context);
    final phone = isPhone(context);
    final width = MediaQuery.sizeOf(context).width;
    final title = (width * 0.085).clamp(60.0, 120.0);

    final platforms = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final p in [s.platformIphone, s.platformMac, s.platformWeb])
          Pill(
            p,
            background: Colors.transparent,
            color: palette.ink2,
            borderColor: palette.lineStrong,
            size: 14,
            horizontal: 14,
            vertical: 8,
          ),
      ],
    );

    final left = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Pill(
          s.synapseBadge,
          background: palette.aiTint,
          color: palette.ai,
          borderColor: palette.aiLine,
          dot: true,
          size: 13,
        ),
        SizedBox(height: phone ? 20 : 24),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SynapseMark(size: title * 0.62),
            SizedBox(width: title * 0.18),
            Flexible(
              child: FitHeadline(
                'Synapse OS',
                size: title,
                color: palette.ink,
                height: 0.9,
              ),
            ),
          ],
        ),
        SizedBox(height: phone ? 14 : 18),
        Text(
          s.synapseTagline,
          style: bodyStyle(
            size: phone ? 22 : 30,
            color: palette.ink2,
            weight: FontWeight.w600,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 14),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Text(
            s.synapseLead,
            style: bodyStyle(
              size: phone ? 16 : 18,
              color: palette.secondary,
              height: 1.6,
            ),
          ),
        ),
      ],
    );

    final right = Column(
      crossAxisAlignment: phone
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        platforms,
        const SizedBox(height: 14),
        ExternalLink(
          url: 'https://synapse-os.ca',
          label: 'synapse-os.ca',
          builder: (context, active) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'synapse-os.ca',
                style:
                    bodyStyle(
                      size: 15,
                      color: palette.ai,
                      weight: FontWeight.w600,
                    ).copyWith(
                      decoration: active ? TextDecoration.underline : null,
                      decorationColor: palette.ai,
                    ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.north_east_rounded, size: 16, color: palette.ai),
            ],
          ),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 960) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: left),
              const SizedBox(width: 48),
              right,
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [left, const SizedBox(height: 24), right],
        );
      },
    );
  }
}

/// One of the three promises, under a lavender rule.
class _Promise extends StatelessWidget {
  const _Promise(this.title, this.body);

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    return Container(
      padding: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: palette.aiLine, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: bodyStyle(
              size: 19,
              color: palette.ink,
              weight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: bodyStyle(size: 15.5, color: palette.secondary, height: 1.6),
          ),
        ],
      ),
    );
  }
}

class _SubHeading extends StatelessWidget {
  const _SubHeading(this.title, this.body);

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    final phone = isPhone(context);
    return Wrap(
      spacing: 24,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        Text(
          title.toUpperCase(),
          style: displayStyle(
            size: phone ? 38 : 48,
            color: palette.ink,
            weight: FontWeight.w700,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            body,
            style: bodyStyle(size: 16, color: palette.tertiary, height: 1.5),
          ),
        ),
      ],
    );
  }
}

class _Shot {
  const _Shot(this.asset, this.title, this.body);

  final String asset;
  final String title;
  final String body;
}

/// Four framed iPhone screens: a row on wide screens, two by two on a
/// tablet, and a sideways-scrolling strip on a phone.
class _IphoneGallery extends StatelessWidget {
  const _IphoneGallery();

  @override
  Widget build(BuildContext context) {
    final s = stringsOf(context);
    final palette = paletteOf(context);
    final shots = [
      _Shot(
        'assets/synapse/ios_today_${palette.dark ? 'dark' : 'light'}.webp',
        s.shotTodayTitle,
        s.shotTodayBody,
      ),
      _Shot(
        'assets/synapse/ios_ask_${palette.dark ? 'dark' : 'light'}.webp',
        s.shotAskTitle,
        s.shotAskBody,
      ),
      _Shot(
        'assets/synapse/ios_review_dark.webp',
        s.shotReviewTitle,
        s.shotReviewBody,
      ),
      _Shot(
        'assets/synapse/ios_chat_dark.webp',
        s.shotChatTitle,
        s.shotChatBody,
      ),
    ];

    if (isPhone(context)) {
      // Bleed to the screen edge so the strip reads as scrollable.
      final gutter = pageGutter(MediaQuery.sizeOf(context).width);
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: EdgeInsets.only(right: gutter, bottom: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < shots.length; i++) ...[
              if (i > 0) const SizedBox(width: 18),
              _ShotTile(shot: shots[i], width: 232),
            ],
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 28.0;
        final columns = constraints.maxWidth >= 4 * 220 + 3 * spacing ? 4 : 2;
        final tile = (constraints.maxWidth - spacing * (columns - 1)) / columns;
        final phoneWidth = tile.clamp(0.0, 300.0);
        return Wrap(
          spacing: spacing,
          runSpacing: 48,
          children: [
            for (final shot in shots)
              SizedBox(
                width: tile,
                child: _ShotTile(shot: shot, width: phoneWidth),
              ),
          ],
        );
      },
    );
  }
}

class _ShotTile extends StatelessWidget {
  const _ShotTile({required this.shot, required this.width});

  final _Shot shot;
  final double width;

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    final s = stringsOf(context);
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IPhoneFrame(
            asset: shot.asset,
            width: width,
            semanticLabel: '${s.iphoneShotLabel}${shot.title}',
          ),
          const SizedBox(height: 22),
          Text(
            shot.title,
            style: bodyStyle(
              size: 17,
              color: palette.ink,
              weight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            shot.body,
            style: bodyStyle(size: 14.5, color: palette.secondary, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _MacBlock extends StatelessWidget {
  const _MacBlock();

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    final s = stringsOf(context);
    final phone = isPhone(context);
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          s.onMac.toUpperCase(),
          style: displayStyle(
            size: phone ? 38 : 48,
            color: palette.ink,
            weight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          s.onMacBody,
          style: bodyStyle(size: 16, color: palette.secondary, height: 1.6),
        ),
      ],
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 960) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 340, child: text),
              const SizedBox(width: 56),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, c) => MacWindow(
                    asset: 'assets/synapse/mac_chat_dark.webp',
                    width: c.maxWidth,
                    aspect: 1180 / 760,
                    semanticLabel: s.macShotLabel,
                  ),
                ),
              ),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            text,
            SizedBox(height: phone ? 28 : 36),
            MacWindow(
              asset: 'assets/synapse/mac_chat_dark.webp',
              width: constraints.maxWidth,
              aspect: 1180 / 760,
              semanticLabel: s.macShotLabel,
            ),
          ],
        );
      },
    );
  }
}
