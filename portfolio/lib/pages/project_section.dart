import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import '../theme/palette.dart';
import '../widgets/link_target.dart';
import '../widgets/section_layout.dart';

/// Two projects, each a card with a product mock-up on one side and the
/// details on the other: Code Coach (a published VS Code extension) and
/// Synapse OS (the team workspace this site's design comes from).
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
            headline: s.projectsHeadline,
            subhead: s.projectsSubhead,
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
                  borderColor: palette.line,
                ),
                Pill(
                  s.tagPublished,
                  background: palette.ok.withValues(alpha: 0.10),
                  color: palette.ok,
                  dot: true,
                ),
              ],
              description: s.projectDescription,
              extra: s.projectSubhead,
              features: [
                (s.featureHintsTitle, s.featureHintsBody),
                (s.featureDashboardTitle, s.featureDashboardBody),
                (s.featureReportsTitle, s.featureReportsBody),
              ],
            ),
          ),
          SizedBox(height: phone ? 20 : 28),
          _ProjectCard(
            previewFirst: false,
            preview: const _AppPane(),
            details: _Details(
              name: 'Synapse OS',
              pills: [
                Pill(
                  s.tagWebApp,
                  background: palette.raised,
                  color: palette.secondary,
                  borderColor: palette.line,
                ),
                Pill(
                  s.tagBeta,
                  background: palette.due.withValues(alpha: 0.10),
                  color: palette.due,
                  dot: true,
                ),
              ],
              description: s.synapseDescription,
              features: [
                (s.featurePrivateAiTitle, s.featurePrivateAiBody),
                (s.featureApproveTitle, s.featureApproveBody),
                (s.featureTeamsTitle, s.featureTeamsBody),
              ],
              footer: 'synapse-os.ca',
              footerUri: Uri.parse('https://synapse-os.ca'),
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
  const _ProjectCard({
    required this.preview,
    required this.details,
    this.previewFirst = true,
  });

  final Widget preview;
  final Widget details;

  /// Which side the mock-up sits on in the wide layout, so the two cards
  /// alternate down the page.
  final bool previewFirst;

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: palette.line),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 460 * 2) {
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: previewFirst ? preview : details),
                    Expanded(child: previewFirst ? details : preview),
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
// themes. Its colours are the app's dark tokens.
const _kDark = AppPalette(dark: true);
const _kEditorBg = Color(0xFF090B0F);
const _kEditorWindow = Color(0xFF11151B);
const _kEditorText = Color(0xFFDFE3EA);
const _kEditorMuted = Color(0xFF8B95A6);
const _kEditorLineNo = Color(0xFF5A6474);
const _kEditorKeyword = Color(0xFFF2C277);
const _kEditorType = Color(0xFF86B4FF);
const _kEditorError = Color(0xFFFF9090);
const _kEditorBorder = Color(0xFF252C37);

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

/// Code Coach's inline hint, drawn like one of the app's AI suggestion cards:
/// dashed lavender border, a mono tag, then the suggestion.
class _HintBox extends StatelessWidget {
  const _HintBox();

  @override
  Widget build(BuildContext context) {
    final phone = isPhone(context);
    final size = phone ? 12.5 : 13.0;
    final body = interStyle(size: size, color: _kEditorText, height: 1.5);
    final mono = monoStyle(size: size, color: _kEditorText, height: 1.5);
    return Padding(
      padding: EdgeInsets.fromLTRB(phone ? 12 : 48, 6, phone ? 12 : 16, 6),
      child: AiCard(
        palette: _kDark,
        radius: 10,
        padding: EdgeInsets.symmetric(
          horizontal: phone ? 12 : 14,
          vertical: phone ? 10 : 12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'HINT · OFF-BY-ONE',
              style: monoStyle(
                size: 11,
                color: _kDark.accent,
                letterSpacing: 0.7,
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

/// Synapse OS's mock-up: a miniature of the app's own Today screen, a nav
/// sidebar, a short task list and one AI suggestion waiting for approval.
/// It follows the site theme, because the app does too.
class _AppPane extends StatelessWidget {
  const _AppPane();

  static const _nav = ['Today', 'Inbox', 'Notes', 'Plan', 'Ask'];

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    final phone = isPhone(context);
    final width = MediaQuery.sizeOf(context).width;

    final main = Padding(
      padding: EdgeInsets.all(phone ? 14 : 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Today',
            style: interStyle(
              size: phone ? 17 : 19,
              color: palette.ink,
              weight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
          SizedBox(height: phone ? 12 : 14),
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: palette.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: palette.line),
            ),
            child: Column(
              children: [
                _TaskRow('Review the pull request', 'today', palette.due, first: true),
                _TaskRow('Write sprint notes', 'Fri', palette.info),
                _TaskRow('Send beta invites', 'Mon', palette.info),
              ],
            ),
          ),
          SizedBox(height: phone ? 12 : 14),
          AiCard(
            padding: EdgeInsets.all(phone ? 12 : 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NOVA · SUGGESTION',
                  style: monoStyle(
                    size: 11,
                    color: palette.accent,
                    letterSpacing: 0.7,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add 3 action items from “Sprint planning”.',
                  style: interStyle(
                    size: phone ? 12.5 : 13.5,
                    color: palette.ink2,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Nothing is added until you accept.',
                  style: interStyle(
                    size: 12,
                    color: palette.tertiary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _MiniButton('Accept', filled: true),
                    const SizedBox(width: 8),
                    _MiniButton('Dismiss'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final sidebar = Container(
      width: 118,
      padding: const EdgeInsets.fromLTRB(10, 14, 10, 14),
      decoration: BoxDecoration(
        color: palette.altBg,
        border: Border(right: BorderSide(color: palette.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const SynapseMark(size: 20),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  'Synapse',
                  overflow: TextOverflow.ellipsis,
                  style: interStyle(
                    size: 12.5,
                    color: palette.ink,
                    weight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < _nav.length; i++)
            Container(
              margin: const EdgeInsets.only(bottom: 2),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: i == 0 ? palette.raised : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                _nav[i],
                style: interStyle(
                  size: 12,
                  color: i == 0 ? palette.ink : palette.secondary,
                  weight: i == 0 ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: palette.line),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: palette.ok,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Local only',
                    overflow: TextOverflow.ellipsis,
                    style: interStyle(
                      size: 11,
                      color: palette.secondary,
                      weight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Container(
      color: palette.bg,
      padding: EdgeInsets.all(phone ? 16 : (width * 0.03).clamp(20.0, 36.0)),
      alignment: Alignment.center,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: palette.bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: palette.line),
        ),
        child: phone
            ? main
            : IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [sidebar, Expanded(child: main)],
                ),
              ),
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow(this.title, this.due, this.dueColor, {this.first = false});

  final String title;
  final String due;
  final Color dueColor;
  final bool first;

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    final phone = isPhone(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: phone ? 10 : 11),
      decoration: BoxDecoration(
        border: first ? null : Border(top: BorderSide(color: palette.line)),
      ),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: palette.lineStrong, width: 1.5),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: interStyle(
                size: phone ? 12.5 : 13.5,
                color: palette.ink2,
                weight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(due, style: monoStyle(size: 11, color: dueColor)),
        ],
      ),
    );
  }
}

/// A non-interactive miniature of the app's Accept / Dismiss buttons.
class _MiniButton extends StatelessWidget {
  const _MiniButton(this.label, {this.filled = false});

  final String label;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    return Container(
      constraints: const BoxConstraints(minHeight: 28),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: filled ? palette.accent : Colors.transparent,
        borderRadius: BorderRadius.circular(7),
        border: filled ? null : Border.all(color: palette.line),
      ),
      child: Text(
        label,
        style: interStyle(
          size: 12,
          color: filled ? palette.onAccent : palette.secondary,
          weight: FontWeight.w600,
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
    this.extra,
    this.footer,
    this.footerUri,
  });

  final String name;
  final List<Widget> pills;
  final String description;

  /// A second paragraph shown on desktop only (Code Coach's origin story).
  final String? extra;
  final List<(String, String)> features;

  /// A mono line under the features, e.g. the project's address. It is a
  /// link to [footerUri] when that is given.
  final String? footer;
  final Uri? footerUri;

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
            name,
            style: interStyle(
              size: phone ? 24 : 28,
              color: palette.ink,
              weight: FontWeight.w700,
              height: 1.1,
              letterSpacing: -0.9,
            ),
          ),
          if (!phone) ...[
            const SizedBox(height: 14),
            Text(
              description,
              style: interStyle(size: 15.5, color: palette.secondary, height: 1.6),
            ),
            if (extra != null) ...[
              const SizedBox(height: 10),
              Text(
                extra!,
                style: interStyle(size: 14, color: palette.tertiary, height: 1.6),
              ),
            ],
          ],
          SizedBox(height: phone ? 18 : 22),
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: palette.line)),
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
          if (footer != null) ...[
            SizedBox(height: phone ? 14 : 18),
            Align(
              alignment: Alignment.centerLeft,
              child: footerUri == null
                  ? Text(
                      footer!,
                      style: monoStyle(size: 12.5, color: palette.accent),
                    )
                  : LinkTarget(
                      uri: footerUri!,
                      semanticLabel: footer!,
                      builder: (context, highlighted) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            footer!,
                            style: monoStyle(
                              size: 12.5,
                              color: palette.accent,
                            ).copyWith(
                              decoration: highlighted
                                  ? TextDecoration.underline
                                  : TextDecoration.none,
                              decorationColor: palette.accent,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.arrow_outward_rounded,
                            size: 14,
                            color: palette.accent,
                          ),
                        ],
                      ),
                    ),
            ),
          ],
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
      padding: EdgeInsets.symmetric(vertical: phone ? 13 : 15),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: palette.line)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              index.toString().padLeft(2, '0'),
              style: monoStyle(size: phone ? 11 : 12, color: palette.tertiary),
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
                    size: phone ? 15 : 15.5,
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
