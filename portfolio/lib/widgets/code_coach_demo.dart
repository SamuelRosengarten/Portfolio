import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../i18n/strings.dart';
import '../theme/motion_controller.dart';
import '../theme/palette.dart';

const _editorBg = Color(0xFF1E1E1E);
const _panelBg = Color(0xFF252526);
const _lineText = Color(0xFFD4D4D4);
const _keyword = Color(0xFFC586C0);
const _function = Color(0xFFDCDCAA);
const _number = Color(0xFFB5CEA8);
const _builtin = Color(0xFF4EC9B0);
const _errorRed = Color(0xFFF14C4C);

/// A small scripted recreation of the Code Coach extension: run a buggy
/// snippet, get an error, then step through progressively stronger hints and
/// watch the mistake tally on the dashboard tab go up. Nothing here calls an
/// AI — the hints are canned, since the point is to show the interaction.
class CodeCoachDemo extends StatefulWidget {
  const CodeCoachDemo({super.key});

  @override
  State<CodeCoachDemo> createState() => _CodeCoachDemoState();
}

class _CodeCoachDemoState extends State<CodeCoachDemo> {
  static const _baseCounts = [3, 5, 2];

  bool _ran = false;
  int _hintLevel = 0;
  int _runs = 0;
  int _tab = 0; // 0 code (phone only), 1 hints, 2 dashboard

  void _run() => setState(() {
    _ran = true;
    _hintLevel = 0;
    _runs++;
    _tab = 1;
  });

  void _nextHint(int max) =>
      setState(() => _hintLevel = (_hintLevel + 1).clamp(0, max));

  @override
  Widget build(BuildContext context) {
    final s = stringsOf(context);
    final mobile = MediaQuery.sizeOf(context).width < 600;
    final editor = _Editor(ran: _ran, onRun: _run, s: s, compact: mobile);
    final side = _SidePanel(
      s: s,
      ran: _ran,
      hintLevel: _hintLevel,
      dashboard: _tab == 2,
      runs: _runs,
      baseCounts: _baseCounts,
      compact: mobile,
      onTab: (d) => setState(() => _tab = d ? 2 : 1),
      onNextHint: () => _nextHint(s.demoHints.length - 1),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: _editorBg,
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: mobile
                ? _mobileBody(s, editor, side)
                : IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(flex: 3, child: editor),
                        Expanded(flex: 2, child: side),
                      ],
                    ),
                  ),
          ),
        ),
        if (!mobile) ...[
          const SizedBox(height: 8),
          Text(
            s.demoDisclaimer,
            style: GoogleFonts.inter(fontSize: 12, color: kGray),
          ),
        ],
      ],
    );
  }

  /// A phone can't fit the editor and side panel stacked (each section has to
  /// fit one screen), so on a phone they become three tabs sharing one
  /// fixed-height pane.
  Widget _mobileBody(Strings s, Widget editor, Widget side) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 0),
          child: Row(
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      _Tab(
                        'average.py',
                        selected: _tab == 0,
                        onTap: () => setState(() => _tab = 0),
                      ),
                      const SizedBox(width: 4),
                      _Tab(
                        s.demoHintsTab,
                        selected: _tab == 1,
                        onTap: () => setState(() => _tab = 1),
                      ),
                      const SizedBox(width: 4),
                      _Tab(
                        s.demoDashboardTab,
                        selected: _tab == 2,
                        onTap: () => setState(() => _tab = 2),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _RunButton(label: s.demoRun, onTap: _run),
            ],
          ),
        ),
        SizedBox(height: 116, child: _tab == 0 ? editor : side),
      ],
    );
  }
}

class _Editor extends StatelessWidget {
  const _Editor({
    required this.ran,
    required this.onRun,
    required this.s,
    required this.compact,
  });

  final bool compact;

  final bool ran;
  final VoidCallback onRun;
  final Strings s;

  TextStyle get _mono => GoogleFonts.jetBrainsMono(
    fontSize: compact ? 11 : 12.5,
    height: compact ? 1.35 : 1.4,
    color: _lineText,
  );

  TextSpan _span(String t, [Color? c]) => TextSpan(
    text: t,
    style: c == null ? null : TextStyle(color: c),
  );

  List<List<TextSpan>> get _lines => [
    [_span('def ', _keyword), _span('average', _function), _span('(nums):')],
    [_span('    total = '), _span('0', _number)],
    [
      _span('    '),
      _span('for ', _keyword),
      _span('n '),
      _span('in ', _keyword),
      _span('nums:'),
    ],
    [_span('        total += n')],
    [
      _span('    '),
      _span('return ', _keyword),
      _span('total / '),
      _span('len', _builtin),
      _span('(nums)'),
    ],
    [_span('')],
    [_span('print', _builtin), _span('(average(['), _span('])'), _span(')')],
  ];

  @override
  Widget build(BuildContext context) {
    final lines = _lines;
    return Padding(
      padding: EdgeInsets.all(compact ? 12 : 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!compact) ...[
            Row(
              children: [
                for (final c in const [
                  Color(0xFFFF5F57),
                  Color(0xFFFEBC2E),
                  Color(0xFF28C840),
                ])
                  Container(
                    width: 11,
                    height: 11,
                    margin: const EdgeInsets.only(right: 7),
                    decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                  ),
                const SizedBox(width: 6),
                Text(
                  'average.py',
                  style: GoogleFonts.inter(fontSize: 12, color: kGray),
                ),
                const Spacer(),
                _RunButton(label: s.demoRun, onTap: onRun),
              ],
            ),
            const SizedBox(height: 14),
          ],
          for (var i = 0; i < lines.length; i++)
            if (!(compact && i == 5))
              Container(
                color: ran && i == 4
                    ? _errorRed.withValues(alpha: 0.14)
                    : Colors.transparent,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 26,
                      child: Text(
                        '${i + 1}',
                        style: _mono.copyWith(
                          color: kGray.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text.rich(
                        TextSpan(style: _mono, children: lines[i]),
                        softWrap: false,
                        overflow: TextOverflow.fade,
                      ),
                    ),
                  ],
                ),
              ),
          if (!compact) ...[
            const SizedBox(height: 10),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: ran
                  ? Text(
                      "✖ ${s.demoError}",
                      key: const ValueKey("err"),
                      style: _mono.copyWith(color: _errorRed, fontSize: 12),
                    )
                  : Text(
                      s.demoTryIt,
                      key: const ValueKey("try"),
                      style: GoogleFonts.inter(fontSize: 12.5, color: kBlue),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RunButton extends StatelessWidget {
  const _RunButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kBlue,
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.play_arrow_rounded,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 2),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidePanel extends StatelessWidget {
  const _SidePanel({
    required this.compact,
    required this.s,
    required this.ran,
    required this.hintLevel,
    required this.dashboard,
    required this.runs,
    required this.baseCounts,
    required this.onTab,
    required this.onNextHint,
  });

  final Strings s;
  final bool ran;
  final int hintLevel;
  final bool dashboard;
  final int runs;
  final List<int> baseCounts;
  final bool compact;
  final ValueChanged<bool> onTab;
  final VoidCallback onNextHint;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _panelBg,
      padding: EdgeInsets.all(compact ? 12 : 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!compact) ...[
            Row(
              children: [
                _Tab(
                  s.demoHintsTab,
                  selected: !dashboard,
                  onTap: () => onTab(false),
                ),
                const SizedBox(width: 8),
                _Tab(
                  s.demoDashboardTab,
                  selected: dashboard,
                  onTap: () => onTab(true),
                ),
              ],
            ),
            const SizedBox(height: 14),
          ],
          if (dashboard) _dashboardView() else _hintView(context),
        ],
      ),
    );
  }

  Widget _hintView(BuildContext context) {
    final hints = s.demoHints;
    if (!ran) {
      return Text(
        s.demoTryIt,
        style: GoogleFonts.inter(fontSize: 13, color: kGray, height: 1.5),
      );
    }
    final animate = motionEnabledOf(context);
    final text = hints[hintLevel];
    final nextButton = TextButton(
      onPressed: onNextHint,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size(0, compact ? 20 : 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: kBlue,
      ),
      child: Text(
        "${s.demoAnotherHint} →",
        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "${s.demoLevelLabel} ${hintLevel + 1}/${hints.length}",
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
                color: kBlue,
              ),
            ),
            const Spacer(),
            if (compact && hintLevel < hints.length - 1) nextButton,
          ],
        ),
        SizedBox(height: compact ? 4 : 8),
        // Keyed by run + level so each hint types itself out afresh; with
        // the site's motion toggle off it just appears complete.
        TweenAnimationBuilder<int>(
          key: ValueKey('$runs-$hintLevel'),
          tween: IntTween(begin: 0, end: text.length),
          duration: animate
              ? Duration(milliseconds: text.length * 18)
              : Duration.zero,
          builder: (_, n, _) => Stack(
            children: [
              // Invisible full text reserves the final height so the panel
              // doesn't grow line by line while typing.
              Opacity(opacity: 0, child: Text(text, style: _hintStyle)),
              Text(text.substring(0, n), style: _hintStyle),
            ],
          ),
        ),
        if (!compact) ...[
          const SizedBox(height: 14),
          if (hintLevel < hints.length - 1) nextButton,
        ],
      ],
    );
  }

  TextStyle get _hintStyle => GoogleFonts.inter(
    fontSize: compact ? 13 : 13.5,
    height: compact ? 1.4 : 1.5,
    color: Colors.white.withValues(alpha: 0.9),
  );

  Widget _dashboardView() {
    final labels = s.demoPatternLabels;
    final counts = [baseCounts[0] + runs, baseCounts[1], baseCounts[2]];
    final max = counts.reduce((a, b) => a > b ? a : b);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.demoPatterns,
          style: GoogleFonts.inter(fontSize: 12, color: kGray),
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < labels.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 96,
                  child: Text(
                    labels[i],
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ),
                Expanded(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: counts[i] / max),
                    duration: const Duration(milliseconds: 350),
                    builder: (_, v, _) => ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: v,
                        minHeight: 8,
                        color: kBlue,
                        backgroundColor: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${counts[i]}',
                  style: GoogleFonts.inter(fontSize: 12.5, color: kGray),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab(this.label, {required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : kGray,
          ),
        ),
      ),
    );
  }
}
