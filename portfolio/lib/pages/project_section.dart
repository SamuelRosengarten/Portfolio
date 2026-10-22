import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import '../theme/palette.dart';
import '../widgets/code_coach_demo.dart';
import '../widgets/link_target.dart';
import '../widgets/section_layout.dart';

class ProjectSection extends StatelessWidget {
  const ProjectSection({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    final s = stringsOf(context);
    final phone = isPhone(context);
    return PageSection(
      background: palette.altBg,
      bordered: true,
      topPadding: phone ? 56 : null,
      bottomPadding: phone ? 56 : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeading(
            eyebrow: s.projectEyebrow,
            headline: 'Code Coach.',
            subhead: s.projectSubhead,
          ),
          SizedBox(height: phone ? 28 : 48),
          const _ProjectCard(),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard();

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    final phone = isPhone(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(phone ? 22 : 28),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(phone ? 22 : 28),
          border: Border.all(color: palette.surface(0.1)),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Editor and details side by side once each gets ~460px.
            if (constraints.maxWidth >= 460 * 2) {
              return const IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: _DemoPane(compact: true)),
                    Expanded(child: _Details()),
                  ],
                ),
              );
            }
            // Stacked: the demo's wide layout needs ~720px of room, so below
            // that it gets the compact one even though the card is full width.
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DemoPane(compact: constraints.maxWidth < 820),
                const _Details(),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// The interactive Code Coach demo on a dark stage, left of the details.
class _DemoPane extends StatelessWidget {
  const _DemoPane({this.compact});

  /// Passed through to the demo; see [CodeCoachDemo.compact].
  final bool? compact;

  @override
  Widget build(BuildContext context) {
    final phone = isPhone(context);
    final width = MediaQuery.sizeOf(context).width;
    return Container(
      color: const Color(0xFF0F1115),
      padding: EdgeInsets.all(phone ? 16 : (width * 0.03).clamp(20.0, 36.0)),
      alignment: Alignment.center,
      child: CodeCoachDemo(compact: compact),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details();

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    final s = stringsOf(context);
    final phone = isPhone(context);
    final width = MediaQuery.sizeOf(context).width;

    final features = [
      (s.featureHintsTitle, s.featureHintsBody),
      (s.featureDashboardTitle, s.featureDashboardBody),
      (s.featureReportsTitle, s.featureReportsBody),
    ];

    return Padding(
      padding: EdgeInsets.all(phone ? 20 : (width * 0.034).clamp(24.0, 48.0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Pill(
                s.tagVsCodeExtension,
                background: palette.surface(0.08),
                color: palette.ink,
              ),
              Pill(
                s.tagPublished,
                background: palette.blue.withValues(alpha: 0.16),
                color: palette.accentText,
              ),
            ],
          ),
          if (!phone) ...[
            const SizedBox(height: 24),
            Text(
              s.projectDescription,
              style: interStyle(
                size: 16,
                color: palette.secondary,
                height: 1.6,
              ),
            ),
          ],
          SizedBox(height: phone ? 18 : 24),
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: palette.surface(0.08))),
            ),
            child: Column(
              children: [
                for (var i = 0; i < features.length; i++)
                  _Feature(
                    index: i + 1,
                    title: features[i].$1,
                    body: features[i].$2,
                  ),
              ],
            ),
          ),
          SizedBox(height: phone ? 18 : 24),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              _LinkButton(
                label: s.viewOnMarketplace,
                uri: Uri.parse(
                  'https://marketplace.visualstudio.com/items?itemName=samuelrosengarten.code-coach-ai',
                ),
                primary: true,
              ),
              _LinkButton(
                label: s.sourceOnGitHub,
                uri: Uri.parse(
                  'https://github.com/SamuelRosengarten/code-coach',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({
    required this.index,
    required this.title,
    required this.body,
  });

  final int index;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    final phone = isPhone(context);
    return Container(
      padding: EdgeInsets.symmetric(vertical: phone ? 14 : 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: palette.surface(0.08))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              index.toString().padLeft(2, '0'),
              style: monoStyle(size: phone ? 11 : 12, color: palette.accent),
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
                  style: interStyle(
                    size: 14,
                    color: palette.tertiary,
                    height: 1.5,
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

/// A pill-shaped link that opens [uri]: solid accent when [primary], outlined
/// otherwise. Reachable by keyboard and announced as a link.
class _LinkButton extends StatelessWidget {
  const _LinkButton({
    required this.label,
    required this.uri,
    this.primary = false,
  });

  final String label;
  final Uri uri;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return LinkTarget(
      uri: uri,
      semanticLabel: label,
      builder: (context, highlighted) {
        final palette = paletteOf(context);
        final fg = primary ? palette.onAccent : palette.ink;
        final phone = isPhone(context);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          constraints: BoxConstraints(minHeight: phone ? 44 : 48),
          padding: EdgeInsets.symmetric(horizontal: phone ? 18 : 22),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: primary
                ? (highlighted
                      ? Color.lerp(palette.accent, Colors.white, 0.18)
                      : palette.accent)
                : (highlighted ? palette.surface(0.08) : Colors.transparent),
            borderRadius: BorderRadius.circular(999),
            border: primary ? null : Border.all(color: palette.surface(0.22)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: interStyle(
                    size: phone ? 14 : 15,
                    color: fg,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
              if (primary) ...[
                const SizedBox(width: 6),
                Icon(Icons.arrow_outward_rounded, size: 16, color: fg),
              ],
            ],
          ),
        );
      },
    );
  }
}
