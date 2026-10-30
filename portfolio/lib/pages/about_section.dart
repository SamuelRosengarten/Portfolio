import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../i18n/strings.dart';
import '../theme/palette.dart';
import '../widgets/section_layout.dart';
import '../widgets/site_header.dart';

/// Hero ("MAINFRAME"): the operator ID — status readouts, the stacked name,
/// role and calls to action — beside the language/tools spec panel, with the
/// four-step career path underneath.
class AboutSection extends StatelessWidget {
  const AboutSection({super.key, required this.onSelected});

  /// Scrolls to another section — the hero's two buttons use it.
  final ValueChanged<SiteSection> onSelected;

  @override
  Widget build(BuildContext context) {
    return PageSection(
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

    // Smaller on a phone: the section is shrunk to fit one screen, and a huge
    // name would shrink everything else with it.
    final nameSize = phone ? 40.0 : (width * 0.075).clamp(64.0, 116.0);
    TextStyle name(Color color) => monoStyle(
      size: nameSize,
      color: color,
      weight: FontWeight.w800,
      height: 0.92,
      letterSpacing: -nameSize * 0.02,
    );
    // GARTEN is drawn as an outline, like the design's third line.
    final outline = GoogleFonts.jetBrainsMono(
      fontSize: nameSize,
      fontWeight: FontWeight.w800,
      height: 0.92,
      letterSpacing: -nameSize * 0.02,
      foreground: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = phone ? 1.4 : 2
        ..color = palette.dark ? const Color(0xFFB8B8B8) : palette.tertiary,
    );

    final buttons = [
      PillButton(
        label: s.viewProcesses,
        caption: s.execute,
        filled: true,
        expand: phone,
        icon: Icons.arrow_forward,
        onPressed: () => onSelected!(SiteSection.synapseOs),
      ),
      PillButton(
        label: s.openComms,
        expand: phone,
        onPressed: () => onSelected!(SiteSection.contact),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MonoLabel(s.systemTitle, size: phone ? 10 : 11),
        const SizedBox(height: 10),
        Wrap(
          spacing: 18,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            StatusTag(s.openToInternships.toUpperCase(), color: palette.ok),
            MonoLabel(
              'QUEBEC_DEV_NODE // SESSION_${DateTime.now().year}',
              color: palette.tertiary,
              size: 11,
            ),
          ],
        ),
        SizedBox(height: phone ? 22 : 28),
        Semantics(
          header: true,
          label: 'Samuel Rosengarten',
          excludeSemantics: true,
          // scaleDown keeps the longest line inside a narrow column instead
          // of clipping it.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SAMUEL', style: name(palette.ink)),
                Text('ROSEN', style: name(palette.accent)),
                Text('GARTEN', style: outline),
              ],
            ),
          ),
        ),
        SizedBox(height: phone ? 20 : 26),
        Text(
          s.heroRole,
          style: monoStyle(
            size: phone ? 13 : 16,
            color: palette.ink,
            weight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        MonoLabel(s.heroFocus, size: phone ? 11 : 12),
        const SizedBox(height: 4),
        MonoLabel(
          'LONGUEUIL, QUÉBEC, CANADA',
          color: palette.tertiary,
          size: phone ? 11 : 12,
        ),
        SizedBox(height: phone ? 18 : 22),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Text(
            s.aboutBio,
            style: interStyle(
              size: phone ? 15 : (width * 0.013).clamp(15.0, 17.0),
              color: palette.secondary,
              height: 1.6,
            ),
          ),
        ),
        SizedBox(height: phone ? 22 : 28),
        if (onSelected != null)
          if (phone)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [buttons[0], const SizedBox(height: 10), buttons[1]],
            )
          else
            Wrap(spacing: 12, runSpacing: 12, children: buttons),
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
  _Tool('TS', 'TypeScript'),
  _Tool('Nx', 'Next.js'),
  _Tool('SQL', 'SQLite'),
  _Tool('AI', 'Ollama'),
  _Tool('Fl', 'Flutter'),
  _Tool('Da', 'Dart'),
  _Tool('C#', 'C#'),
  _Tool('Nd', 'Node.js'),
];

class _StackPanel extends StatelessWidget {
  const _StackPanel();

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    final s = stringsOf(context);
    final phone = isPhone(context);
    return Container(
      padding: EdgeInsets.all(phone ? 18 : 24),
      decoration: hudDecoration(palette, highlighted: true),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 12,
            runSpacing: 4,
            children: [
              MonoLabel(
                'SYS_SPECS::${s.languagesAndTools}',
                size: phone ? 11 : 12,
                weight: FontWeight.w700,
              ),
              MonoLabel(
                '${s.modulesLoaded}: ${_tools.length.toString().padLeft(2, '0')}',
                color: palette.ok,
                size: 10.5,
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
      padding: EdgeInsets.all(phone ? 10 : 12),
      decoration: BoxDecoration(
        color: palette.surface(0.03),
        borderRadius: BorderRadius.circular(kHudButtonRadius),
        border: Border.all(color: palette.surface(0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: badge,
            height: badge,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: palette.accent),
            ),
            child: Text(
              tool.badge,
              style: monoStyle(
                size: phone ? 11 : 12,
                color: palette.accent,
                weight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: phone ? 10 : 12),
          Flexible(
            child: Text(
              tool.name,
              overflow: TextOverflow.ellipsis,
              style: monoStyle(
                size: phone ? 13 : 14,
                color: palette.ink,
                weight: FontWeight.w600,
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
          style: monoStyle(
            size: phone ? 14 : 15,
            color: current ? palette.accent : palette.ink,
            weight: FontWeight.w700,
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
