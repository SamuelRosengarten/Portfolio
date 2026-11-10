import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import '../theme/palette.dart';
import '../widgets/section_layout.dart';
import '../widgets/site_header.dart';

/// Hero: the "from the torch to the keyboard" headline over a temper bead,
/// the short bio and calls to action, beside the four-step path. A strip of
/// languages and tools closes it off.
class AboutSection extends StatelessWidget {
  const AboutSection({super.key, required this.onSelected});

  /// Scrolls to another section — the hero's two buttons use it.
  final ValueChanged<SiteSection> onSelected;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final phone = isPhone(context);
    return Column(
      children: [
        PageSection(
          topPadding: phone ? 40 : (width * 0.075).clamp(56.0, 104.0),
          bottomPadding: phone ? 48 : (width * 0.065).clamp(56.0, 96.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final intro = _Intro(onSelected: onSelected);
              // Side by side once the intro still gets ~520px next to the card.
              if (constraints.maxWidth >= 520 + 64 + 400) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: intro),
                    const SizedBox(width: 64),
                    const SizedBox(width: 400, child: _PathCard()),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  intro,
                  SizedBox(height: phone ? 40 : 56),
                  const _PathCard(),
                ],
              );
            },
          ),
        ),
        const _ToolsStrip(),
      ],
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro({required this.onSelected});

  final ValueChanged<SiteSection> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    final s = stringsOf(context);
    final phone = isPhone(context);
    final width = MediaQuery.sizeOf(context).width;

    final buttons = [
      PillButton(
        label: s.seeSynapse,
        filled: true,
        expand: phone,
        icon: phone ? null : Icons.arrow_downward_rounded,
        onPressed: () => onSelected(SiteSection.synapse),
      ),
      PillButton(
        label: s.getInTouch,
        expand: phone,
        onPressed: () => onSelected(SiteSection.contact),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // The headline is sized from the column it sits in, so its longest
        // line ("FROM THE TORCH") always fits on one line.
        final headline = phone ? 64.0 : 132.0;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Pill(
              s.openToInternships,
              background: palette.card,
              color: palette.ink2,
              borderColor: palette.line,
              dot: true,
              dotColor: palette.ok,
              size: phone ? 13 : 14,
              horizontal: 14,
              vertical: 7,
            ),
            SizedBox(height: phone ? 22 : 28),
            FitHeadline(s.heroTagline, size: headline, color: palette.ink),
            SizedBox(height: phone ? 22 : 30),
            TemperBead(
              width: phone
                  ? 200
                  : (constraints.maxWidth * 0.62).clamp(240.0, 560.0),
            ),
            SizedBox(height: phone ? 26 : 34),
            Text(
              s.heroGreeting,
              style: bodyStyle(
                size: phone ? 21 : 26,
                color: palette.ink,
                weight: FontWeight.w600,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Text(
                s.aboutBio,
                style: bodyStyle(
                  size: phone ? 16 : (width * 0.0125).clamp(16.0, 18.0),
                  color: palette.secondary,
                  height: 1.6,
                ),
              ),
            ),
            SizedBox(height: phone ? 26 : 32),
            if (phone)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [buttons[0], const SizedBox(height: 10), buttons[1]],
              )
            else
              Wrap(spacing: 12, runSpacing: 12, children: buttons),
          ],
        );
      },
    );
  }
}

/// Before / now / next / after, numbered because it is a real sequence.
class _PathCard extends StatelessWidget {
  const _PathCard();

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    final s = stringsOf(context);
    final phone = isPhone(context);
    final steps = [
      (s.pathBefore, s.pathBeforeTitle, s.pathBeforeBody),
      (s.pathNow, s.pathNowTitle, s.pathNowBody),
      (s.pathNext, s.pathNextTitle, s.pathNextBody),
      (s.pathAfter, s.pathAfterTitle, s.pathAfterBody),
    ];
    const current = 1;
    return Container(
      padding: EdgeInsets.fromLTRB(
        phone ? 20 : 28,
        phone ? 22 : 28,
        phone ? 20 : 28,
        10,
      ),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            s.pathTitle,
            style: bodyStyle(
              size: 15,
              color: palette.tertiary,
              weight: FontWeight.w600,
            ),
          ),
          for (var i = 0; i < steps.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                border: i == steps.length - 1
                    ? null
                    : Border(bottom: BorderSide(color: palette.line)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    child: Text(
                      '${i + 1}',
                      style: displayStyle(
                        size: 32,
                        weight: FontWeight.w700,
                        height: 1,
                        color: i == current
                            ? palette.accent
                            : (i < current ? palette.tertiary : palette.muted),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          steps[i].$1,
                          style: bodyStyle(
                            size: 13,
                            weight: FontWeight.w500,
                            color: i == current
                                ? palette.accent
                                : palette.tertiary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          steps[i].$2,
                          style: bodyStyle(
                            size: 17,
                            color: palette.ink,
                            weight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          steps[i].$3,
                          style: bodyStyle(
                            size: 14,
                            color: palette.secondary,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

const _tools = [
  'C#',
  'Dart & Flutter',
  'Swift & SwiftUI',
  'TypeScript',
  'Kotlin',
  'JavaScript',
  'SQL',
];

/// A full-width band naming the languages and tools, set in the display face
/// like stamped plates.
class _ToolsStrip extends StatelessWidget {
  const _ToolsStrip();

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    final s = stringsOf(context);
    final phone = isPhone(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: palette.altBg,
        border: Border(
          top: BorderSide(color: palette.line),
          bottom: BorderSide(color: palette.line),
        ),
      ),
      child: PageSection(
        topPadding: phone ? 20 : 24,
        bottomPadding: phone ? 20 : 24,
        child: Wrap(
          spacing: phone ? 18 : 30,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              s.languagesAndTools,
              style: bodyStyle(
                size: 14,
                color: palette.tertiary,
                weight: FontWeight.w500,
              ),
            ),
            for (final tool in _tools)
              Text(
                tool.toUpperCase(),
                style: displayStyle(
                  size: phone ? 21 : 25,
                  color: palette.ink2,
                  weight: FontWeight.w700,
                  height: 1.2,
                  letterSpacing: 0.6,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
