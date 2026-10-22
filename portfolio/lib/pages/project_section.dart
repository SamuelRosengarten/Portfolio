import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import '../theme/palette.dart';
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
                    Expanded(child: _EditorPane()),
                    Expanded(child: _Details()),
                  ],
                ),
              );
            }
            return const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [_EditorPane(), _Details()],
            );
          },
        ),
      ),
    );
  }
}

// The editor mock-up is an illustration of the extension, so it stays dark in
// both site themes, like the editor it depicts.
const _kEditorBg = Color(0xFF0F1115);
const _kEditorWindow = Color(0xFF16181D);
const _kEditorText = Color(0xFFD2D2D7);
const _kEditorMuted = Color(0xFF98989D);
const _kEditorLineNo = Color(0xFF48484A);
const _kEditorKeyword = Color(0xFFFF9F5A);
const _kEditorType = Color(0xFF64B5FF);
const _kEditorError = Color(0xFFFF6B5A);
const _kEditorHint = Color(0xFF2997FF);

class _EditorPane extends StatelessWidget {
  const _EditorPane();

  @override
  Widget build(BuildContext context) {
    final phone = isPhone(context);
    final width = MediaQuery.sizeOf(context).width;
    final codeSize = phone ? 11.5 : 13.0;
    final code = monoStyle(size: codeSize, color: _kEditorText, height: 1.6);
    final lineNo = monoStyle(size: codeSize, color: _kEditorLineNo, height: 1.6);

    Widget line(String number, List<InlineSpan> spans) => Padding(
      padding: EdgeInsets.symmetric(horizontal: phone ? 12 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!phone) ...[
            SizedBox(
              width: 16,
              child: Text(number, textAlign: TextAlign.right, style: lineNo),
            ),
            const SizedBox(width: 16),
          ],
          // Code never wraps: a clipped long line is how an editor behaves.
          Expanded(
            child: Text.rich(
              TextSpan(style: code, children: spans),
              maxLines: 1,
              overflow: TextOverflow.clip,
              softWrap: false,
            ),
          ),
        ],
      ),
    );

    return Container(
      color: _kEditorBg,
      padding: EdgeInsets.all(phone ? 16 : (width * 0.03).clamp(20.0, 36.0)),
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(
          color: _kEditorWindow,
          borderRadius: BorderRadius.circular(phone ? 12 : 14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: phone ? 12 : 14,
                vertical: phone ? 10 : 12,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
                ),
              ),
              child: Row(
                children: [
                  if (!phone)
                    for (var i = 0; i < 3; i++)
                      Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF3A3A3C),
                          shape: BoxShape.circle,
                        ),
                      ),
                  Padding(
                    padding: EdgeInsets.only(left: phone ? 0 : 2),
                    child: Text(
                      'Grades.cs',
                      style: monoStyle(size: phone ? 11 : 12, color: _kEditorMuted),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: phone ? 12 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  line('12', [
                    const TextSpan(
                      text: 'for',
                      style: TextStyle(color: _kEditorKeyword),
                    ),
                    const TextSpan(text: ' ('),
                    const TextSpan(
                      text: 'int',
                      style: TextStyle(color: _kEditorType),
                    ),
                    const TextSpan(text: ' i = 0; i '),
                    const TextSpan(
                      text: '<=',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        decorationStyle: TextDecorationStyle.wavy,
                        decorationColor: _kEditorError,
                      ),
                    ),
                    const TextSpan(text: ' notes.Length; i++)'),
                  ]),
                  if (!phone) line('13', const [TextSpan(text: '{')]),
                  const _HintBox(),
                  line('14', const [TextSpan(text: '    total += notes[i];')]),
                  if (!phone) line('15', const [TextSpan(text: '}')]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HintBox extends StatelessWidget {
  const _HintBox();

  @override
  Widget build(BuildContext context) {
    final phone = isPhone(context);
    final size = phone ? 12.5 : 13.0;
    final body = interStyle(size: size, color: _kEditorText, height: 1.5);
    final mono = monoStyle(size: size, color: _kEditorText, height: 1.5);
    return Container(
      margin: EdgeInsets.fromLTRB(phone ? 12 : 48, 6, phone ? 12 : 16, 6),
      padding: EdgeInsets.symmetric(horizontal: phone ? 12 : 14, vertical: phone ? 10 : 12),
      decoration: BoxDecoration(
        color: _kEditorHint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(phone ? 8 : 10),
        border: Border.all(color: _kEditorHint.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hint · off-by-one',
            style: interStyle(
              size: size,
              color: const Color(0xFFF5F5F7),
              weight: FontWeight.w600,
              height: 1.5,
            ),
          ),
          Text.rich(
            TextSpan(
              style: body,
              children: [
                const TextSpan(text: 'Arrays end at '),
                TextSpan(text: 'Length - 1', style: mono),
                const TextSpan(text: '. Try '),
                TextSpan(text: '<', style: mono),
                const TextSpan(text: ' instead of '),
                TextSpan(text: '<=', style: mono),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ],
      ),
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
              style: interStyle(size: 16, color: palette.secondary, height: 1.6),
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
        ],
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({required this.index, required this.title, required this.body});

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
