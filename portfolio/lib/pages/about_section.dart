import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import '../theme/palette.dart';
import '../widgets/section_layout.dart';
import '../widgets/site_header.dart';

/// Hero: greeting and calls to action beside the language/tools panel, with
/// the four-step career path underneath.
class AboutSection extends StatelessWidget {
  const AboutSection({super.key, required this.onSelected});

  /// Scrolls to another section — the hero's two buttons use it.
  final ValueChanged<SiteSection> onSelected;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return PageSection(
      topPadding: isPhone(context) ? 40 : (width * 0.09).clamp(56.0, 120.0),
      bottomPadding: isPhone(context) ? 48 : 56,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final intro = _Intro(onSelected: onSelected);
              const panel = _StackPanel();
              // Side by side once there is room for two ~440px columns.
              if (constraints.maxWidth >= 440 * 2 + 56) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: intro),
                    const SizedBox(width: 56),
                    const Expanded(child: panel),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  intro,
                  SizedBox(height: isPhone(context) ? 32 : 56),
                  panel,
                ],
              );
            },
          ),
          SizedBox(height: isPhone(context) ? 40 : 72),
          const _Path(),
        ],
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro({this.onSelected});

  final ValueChanged<SiteSection>? onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    final s = stringsOf(context);
    final phone = isPhone(context);
    final width = MediaQuery.sizeOf(context).width;
    final headline = phone ? 44.0 : (width * 0.064).clamp(44.0, 88.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: phone ? 12 : 14,
            vertical: phone ? 7 : 8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: palette.surface(0.14)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: palette.accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  s.openToInternships,
                  style: interStyle(
                    size: phone ? 12 : 13,
                    color: palette.ink.withValues(alpha: 0.82),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: phone ? 24 : 28),
        Text(
          '${s.heroGreeting}.',
          style: interStyle(
            size: headline,
            color: palette.ink,
            weight: FontWeight.w800,
            height: 1.02,
            letterSpacing: phone ? -1.6 : -2.4,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: phone ? 8 : 0),
          child: Text(
            s.heroTagline,
            style: interStyle(
              // Two-thirds of the greeting's size (44 -> 30 on a phone), so
              // the tagline reads as a subtitle rather than a third line of
              // the headline when the column is only ~500px wide.
              size: (headline * 0.68).roundToDouble(),
              color: palette.muted,
              weight: FontWeight.w800,
              height: 1.1,
              letterSpacing: phone ? -0.9 : -1.6,
            ),
          ),
        ),
        SizedBox(height: phone ? 24 : 28),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Text(
            s.aboutBio,
            style: interStyle(
              size: phone ? 16 : (width * 0.015).clamp(17.0, 20.0),
              color: palette.secondary,
              height: 1.55,
            ),
          ),
        ),
        SizedBox(height: phone ? 24 : 28),
        if (onSelected != null)
          if (phone)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PillButton(
                  label: s.seeMyWork,
                  filled: true,
                  expand: true,
                  onPressed: () => onSelected!(SiteSection.projects),
                ),
                const SizedBox(height: 10),
                PillButton(
                  label: s.getInTouch,
                  expand: true,
                  onPressed: () => onSelected!(SiteSection.contact),
                ),
              ],
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                PillButton(
                  label: s.seeMyWork,
                  filled: true,
                  icon: Icons.arrow_downward_rounded,
                  onPressed: () => onSelected!(SiteSection.projects),
                ),
                PillButton(
                  label: s.getInTouch,
                  onPressed: () => onSelected!(SiteSection.contact),
                ),
              ],
            ),
      ],
    );
  }
}

/// A language or tool: its full name and the short badge shown in its chip.
class _Tool {
  const _Tool(this.badge, this.name);

  final String badge;
  final String name;
}

const _tools = [
  _Tool('C#', 'C#'),
  _Tool('Da', 'Dart'),
  _Tool('Fl', 'Flutter'),
  _Tool('Kt', 'Kotlin'),
  _Tool('TS', 'TypeScript'),
  _Tool('JS', 'JavaScript'),
];

class _StackPanel extends StatelessWidget {
  const _StackPanel();

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    final s = stringsOf(context);
    final phone = isPhone(context);
    return Container(
      padding: EdgeInsets.all(phone ? 20 : 28),
      decoration: BoxDecoration(
        color: palette.panel,
        borderRadius: BorderRadius.circular(phone ? 20 : 24),
        border: Border.all(color: palette.surface(0.08)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  s.languagesAndTools,
                  style: monoStyle(
                    size: phone ? 11 : 12,
                    color: palette.tertiary,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              if (!phone)
                Text(
                  _tools.length.toString().padLeft(2, '0'),
                  style: monoStyle(size: 12, color: palette.muted),
                ),
            ],
          ),
          SizedBox(height: phone ? 16 : 20),
          AutoFitGrid(
            minItemWidth: phone ? 120 : 150,
            spacing: phone ? 8 : 10,
            children: [for (final tool in _tools) _ToolChip(tool: tool)],
          ),
        ],
      ),
    );
  }
}

class _ToolChip extends StatelessWidget {
  const _ToolChip({required this.tool});

  final _Tool tool;

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    final phone = isPhone(context);
    final badge = phone ? 30.0 : 36.0;
    return Container(
      padding: EdgeInsets.all(phone ? 10 : 14),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(phone ? 12 : 14),
        border: palette.dark ? null : Border.all(color: palette.surface(0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: badge,
            height: badge,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: palette.surface(0.06),
              borderRadius: BorderRadius.circular(phone ? 8 : 10),
            ),
            child: Text(
              tool.badge,
              style: monoStyle(size: phone ? 11 : 12, color: palette.accent),
            ),
          ),
          SizedBox(width: phone ? 10 : 12),
          Flexible(
            child: Text(
              tool.name,
              overflow: TextOverflow.ellipsis,
              style: interStyle(
                size: phone ? 14 : 15,
                color: palette.ink,
                weight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Before / now / next / after: a row of four on desktop, a vertical rail on
/// a phone.
class _Path extends StatelessWidget {
  const _Path();

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    final s = stringsOf(context);
    final phone = isPhone(context);

    final steps = [
      _PathStep(
        '01 · ${s.pathBefore}',
        s.pathBeforeTitle,
        s.pathBeforeBody,
        false,
      ),
      _PathStep(
        '02 · ${s.pathNow}',
        phone ? s.pathNowShort : s.pathNowTitle,
        phone ? null : s.pathNowBody,
        true,
      ),
      _PathStep('03 · ${s.pathNext}', s.pathNextTitle, s.pathNextBody, false),
      _PathStep(
        '04 · ${s.pathAfter}',
        s.pathAfterTitle,
        s.pathAfterBody,
        false,
      ),
    ];

    if (phone) {
      return Container(
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: palette.surface(0.14))),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < steps.length; i++) ...[
              if (i > 0) const SizedBox(height: 22),
              steps[i],
            ],
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.only(top: 32),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: palette.surface(0.1))),
      ),
      child: AutoFitGrid(minItemWidth: 220, spacing: 28, children: steps),
    );
  }
}

class _PathStep extends StatelessWidget {
  const _PathStep(this.label, this.title, this.body, this.current);

  final String label;
  final String title;
  final String? body;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    final phone = isPhone(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: monoStyle(
            size: phone ? 11 : 12,
            color: current ? palette.accent : palette.tertiary,
          ),
        ),
        SizedBox(height: phone ? 4 : 8),
        Text(
          title,
          style: interStyle(
            size: phone ? 16 : 17,
            color: palette.ink,
            weight: FontWeight.w600,
          ),
        ),
        if (body != null) ...[
          const SizedBox(height: 8),
          Text(
            body!,
            style: interStyle(size: 14, color: palette.tertiary, height: 1.5),
          ),
        ],
      ],
    );
  }
}
