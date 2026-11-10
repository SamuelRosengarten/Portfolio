import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import '../theme/palette.dart';
import '../widgets/section_layout.dart';

/// "Also shipped": Code Coach, a published VS Code extension, as a card with
/// the editor mock-up on one side and the details on the other. (Synapse OS
/// has its own showcase section above.)
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
            headline: s.projectsHeadline,
            subhead: s.projectSubhead,
          ),
          SizedBox(height: phone ? 28 : 44),
          _ProjectCard(
            preview: const _EditorPane(),
            details: _Details(
              name: 'Code Coach',
              pills: [
                Pill(
                  s.tagVsCodeExtension,
                  background: palette.raised,
                  color: palette.secondary,
                ),
                Pill(
                  s.tagPublished,
                  background: palette.ok.withValues(alpha: 0.12),
                  color: palette.ok,
                  dot: true,
                ),
              ],
              description: s.projectDescription,
              features: [
                (s.featureHintsTitle, s.featureHintsBody),
                (s.featureDashboardTitle, s.featureDashboardBody),
                (s.featureReportsTitle, s.featureReportsBody),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The shared card shell: a mock-up pane and a details pane side by side once
/// each gets ~460px, stacked (mock-up on top) below that.
class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.preview, required this.details});

  final Widget preview;
  final Widget details;

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: palette.line),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 460 * 2) {
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: preview),
                    Expanded(child: details),
                  ],
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [preview, details],
            );
          },
        ),
      ),
    );
  }
}

// The VS Code mock-up depicts an editor, so it stays dark in both site
// themes. Its colours are the site's dark tokens.
const _kEditorBg = Color(0xFF090D13);
const _kEditorWindow = Color(0xFF111822);
const _kEditorText = Color(0xFFDFE3EA);
const _kEditorMuted = Color(0xFF8B95A6);
const _kEditorLineNo = Color(0xFF5A6474);
const _kEditorKeyword = Color(0xFFF2C277);
const _kEditorType = Color(0xFF86B4FF);
const _kEditorError = Color(0xFFFF9090);
const _kEditorBorder = Color(0xFF24344A);
const _kHint = Color(0xFFF0B657);

class _EditorPane extends StatelessWidget {
  const _EditorPane();

  @override
  Widget build(BuildContext context) {
    final phone = isPhone(context);
    final width = MediaQuery.sizeOf(context).width;
    final codeSize = phone ? 11.5 : 13.0;
    final code = codeStyle(size: codeSize, color: _kEditorText, height: 1.6);
    final lineNo = codeStyle(
      size: codeSize,
      color: _kEditorLineNo,
      height: 1.6,
    );

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
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kEditorBorder),
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
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: _kEditorBorder)),
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
                          color: Color(0xFF3A4352),
                          shape: BoxShape.circle,
                        ),
                      ),
                  Padding(
                    padding: EdgeInsets.only(left: phone ? 0 : 2),
                    child: Text(
                      'Grades.cs',
                      style: codeStyle(
                        size: phone ? 11 : 12,
                        color: _kEditorMuted,
                      ),
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

/// Code Coach's inline hint, drawn like one of the app's AI suggestion cards:
/// dashed lavender border, a mono tag, then the suggestion.
class _HintBox extends StatelessWidget {
  const _HintBox();

  @override
  Widget build(BuildContext context) {
    final phone = isPhone(context);
    final size = phone ? 12.5 : 13.0;
    final body = bodyStyle(size: size, color: _kEditorText, height: 1.5);
    final mono = codeStyle(size: size, color: _kEditorText, height: 1.5);
    return Padding(
      padding: EdgeInsets.fromLTRB(phone ? 12 : 48, 6, phone ? 12 : 16, 6),
      child: DashedCard(
        color: _kHint,
        radius: 10,
        padding: EdgeInsets.symmetric(
          horizontal: phone ? 12 : 14,
          vertical: phone ? 10 : 12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hint: off by one',
              style: codeStyle(
                size: 12,
                color: _kHint,
                weight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
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
      ),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({
    required this.name,
    required this.pills,
    required this.description,
    required this.features,
  });

  final String name;
  final List<Widget> pills;
  final String description;
  final List<(String, String)> features;

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    final phone = isPhone(context);
    final width = MediaQuery.sizeOf(context).width;

    return Padding(
      padding: EdgeInsets.all(phone ? 20 : (width * 0.03).clamp(24.0, 40.0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(spacing: 8, runSpacing: 8, children: pills),
          SizedBox(height: phone ? 14 : 18),
          Text(
            name.toUpperCase(),
            style: displayStyle(
              size: phone ? 40 : 52,
              color: palette.ink,
              height: 0.95,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: bodyStyle(
              size: phone ? 15.5 : 17,
              color: palette.secondary,
              height: 1.55,
            ),
          ),
          SizedBox(height: phone ? 18 : 22),
          for (final f in features) _Feature(title: f.$1, body: f.$2),
        ],
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    final phone = isPhone(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: phone ? 13 : 15),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: palette.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: bodyStyle(
              size: phone ? 15 : 16,
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
