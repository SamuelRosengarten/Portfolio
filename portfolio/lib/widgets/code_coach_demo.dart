import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../i18n/strings.dart';
import '../theme/palette.dart';

// Colours taken from the real extension: a light VS Code window with a warm
// cream "Your week" sidebar and a gold accent.
const _windowBg = Color(0xFFFFFFFF);
const _chromeBg = Color(0xFFF3F3F3);
const _sidebarBg = Color(0xFFF8F4EA);
const _ink = Color(0xFF2B2A28);
const _softInk = Color(0xFF8A857B);
const _gold = Color(0xFFA9773B);
const _errorRed = Color(0xFFE51400);
const _kindColors = [Color(0xFF4A6F9C), Color(0xFF7B5EA0), Color(0xFF5E8A5E)];

const _codeText = Color(0xFF1F1F1F);
const _keyword = Color(0xFFB4441E);
const _type = Color(0xFF267F99);
const _function = Color(0xFF795E26);
const _number = Color(0xFF098658);

/// One coloured token of a code line; [kind] marks it as the spot the
/// analyzer complains about (index into the demo's three mistake kinds).
class _Tok {
  const _Tok(this.text, {this.color, this.kind});

  final String text;
  final Color? color;
  final int? kind;
}

const _lines = <List<_Tok>>[
  [
    _Tok('String ', color: _type),
    _Tok('greet', color: _function),
    _Tok('('),
    _Tok('String ', color: _type),
    _Tok('name) {'),
  ],
  [
    _Tok('  '),
    _Tok('return ', color: _keyword),
    _Tok('2', color: _number, kind: 0),
    _Tok(';'),
  ],
  [_Tok('}')],
  [
    _Tok('String ', color: _type),
    _Tok('patate', kind: 1),
    _Tok(' = '),
    _Tok('1', color: _number),
    _Tok(';'),
  ],
  [
    _Tok('final ', color: _keyword),
    _Tok('msg = '),
    _Tok('greet()', color: _function, kind: 2),
    _Tok(';'),
  ],
];

int? _kindOfLine(int i) {
  for (final t in _lines[i]) {
    if (t.kind != null) return t.kind;
  }
  return null;
}

/// A small scripted recreation of the Code Coach extension: check some buggy
/// Dart, get inline hints next to each error, and watch the "Your week" stats
/// sidebar tally them (with a working MUTE). Nothing here calls an AI — the
/// hints are the real extension's wording, canned.
class CodeCoachDemo extends StatefulWidget {
  const CodeCoachDemo({super.key});

  @override
  State<CodeCoachDemo> createState() => _CodeCoachDemoState();
}

class _CodeCoachDemoState extends State<CodeCoachDemo> {
  static const _baseCounts = [3, 2, 3];
  static const _pastWeeks = [1, 2, 1, 3, 2];

  bool _checked = false;
  int _checks = 0;
  int _tab = 0; // phone only: 0 editor, 1 stats
  final Set<int> _muted = {};

  void _check() => setState(() {
    _checked = true;
    _checks++;
    _tab = 0;
  });

  void _toggleMute(int kind) => setState(() {
    if (!_muted.remove(kind)) _muted.add(kind);
  });

  @override
  Widget build(BuildContext context) {
    final s = stringsOf(context);
    final mobile = MediaQuery.sizeOf(context).width < 600;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: _windowBg,
              border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: mobile ? _mobileBody(s) : _desktopBody(s),
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

  Widget _desktopBody(Strings s) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 2, child: _stats(s, compact: false)),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _titleStrip(s),
                Expanded(child: _code(s, compact: false)),
                _statusBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// A phone can't fit the sidebar and editor side by side (each section has
  /// to fit one screen), so on a phone they become two tabs.
  Widget _mobileBody(Strings s) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: _chromeBg,
          padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
          child: Row(
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      _Tab(
                        'greeter.dart',
                        selected: _tab == 0,
                        onTap: () => setState(() => _tab = 0),
                      ),
                      const SizedBox(width: 4),
                      _Tab(
                        s.demoStatsTab,
                        selected: _tab == 1,
                        onTap: () => setState(() => _tab = 1),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _CheckButton(label: s.demoCheck, onTap: _check),
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topCenter,
          child: _tab == 0 ? _code(s, compact: true) : _stats(s, compact: true),
        ),
      ],
    );
  }

  Widget _titleStrip(Strings s) {
    return Container(
      color: _chromeBg,
      padding: const EdgeInsets.fromLTRB(14, 8, 12, 8),
      child: Row(
        children: [
          Text(
            'greeter.dart',
            style: GoogleFonts.inter(fontSize: 12.5, color: _ink),
          ),
          if (_checked) ...[
            const SizedBox(width: 6),
            Text('3', style: GoogleFonts.inter(fontSize: 12, color: _errorRed)),
          ],
          const Spacer(),
          _CheckButton(label: s.demoCheck, onTap: _check),
        ],
      ),
    );
  }

  Widget _statusBar() {
    const style = TextStyle(fontSize: 11, color: Color(0xFF616161));
    return Container(
      color: _chromeBg,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: Row(
        children: [
          const Icon(Icons.cancel_outlined, size: 12, color: Color(0xFF616161)),
          const SizedBox(width: 3),
          Text(_checked ? '3' : '0', style: style),
          const SizedBox(width: 8),
          const Icon(
            Icons.warning_amber_rounded,
            size: 12,
            color: Color(0xFF616161),
          ),
          const SizedBox(width: 3),
          const Text('0', style: style),
          const Spacer(),
          const Text('Dart', style: style),
        ],
      ),
    );
  }

  Widget _code(Strings s, {required bool compact}) {
    final mono = GoogleFonts.jetBrainsMono(
      fontSize: compact ? 11 : 12.5,
      height: 1.5,
      color: _codeText,
    );
    final hints = s.demoHints;

    TextSpan spanFor(_Tok t) => TextSpan(
      text: t.text,
      style: TextStyle(
        color: t.color,
        decoration: _checked && t.kind != null
            ? TextDecoration.underline
            : null,
        decorationStyle: TextDecorationStyle.wavy,
        decorationColor: _errorRed,
      ),
    );

    Widget hintRow(int kind) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              Icons.lightbulb_outline_rounded,
              size: compact ? 12 : 14,
              color: _gold,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              hints[kind],
              maxLines: compact ? null : 1,
              overflow: TextOverflow.ellipsis,
              style: mono.copyWith(
                fontStyle: FontStyle.italic,
                color: _softInk,
              ),
            ),
          ),
        ],
      );
    }

    Widget line(int i) {
      final kind = _kindOfLine(i);
      final showHint = _checked && kind != null && !_muted.contains(kind);
      final code = Text.rich(
        TextSpan(
          style: mono,
          children: [for (final t in _lines[i]) spanFor(t)],
        ),
        softWrap: false,
      );
      final gutter = SizedBox(
        width: 26,
        child: Text(
          '${i + 1}',
          style: mono.copyWith(color: _softInk.withValues(alpha: 0.7)),
        ),
      );
      final tint = _checked && kind != null
          ? _errorRed.withValues(alpha: 0.06)
          : Colors.transparent;
      if (compact) {
        return Container(
          color: tint,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  gutter,
                  Expanded(child: code),
                ],
              ),
              if (showHint)
                Padding(
                  padding: const EdgeInsets.only(left: 26, bottom: 3),
                  child: hintRow(kind),
                ),
            ],
          ),
        );
      }
      return Container(
        color: tint,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            gutter,
            code,
            if (showHint) ...[
              const SizedBox(width: 10),
              Expanded(child: hintRow(kind)),
            ] else
              const Spacer(),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(compact ? 8 : 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < _lines.length; i++) line(i),
          if (!_checked && !compact) ...[
            const SizedBox(height: 10),
            Text(
              s.demoTryIt,
              style: GoogleFonts.inter(fontSize: 12.5, color: kBlue),
            ),
          ],
        ],
      ),
    );
  }

  Widget _stats(Strings s, {required bool compact}) {
    final kinds = s.demoKinds;
    final counts = [for (final b in _baseCounts) b + _checks];
    final total = counts.reduce((a, b) => a + b);
    final serif = GoogleFonts.newsreader;
    final labelStyle = GoogleFonts.inter(
      fontSize: 10,
      letterSpacing: 1,
      color: _softInk,
    );
    return Container(
      color: _sidebarBg,
      padding: EdgeInsets.all(compact ? 12 : 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.demoCodeCoach, style: labelStyle),
          const SizedBox(height: 4),
          Text(s.demoYourWeek, style: serif(fontSize: 22, color: _ink)),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                s.demoMistakesPerWeek,
                style: serif(fontSize: 13, color: _ink),
              ),
              const Spacer(),
              Text(s.demoWeeks, style: labelStyle.copyWith(letterSpacing: 0)),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: compact ? 44 : 60,
            width: double.infinity,
            child: CustomPaint(painter: _LinePainter([..._pastWeeks, total])),
          ),
          const SizedBox(height: 14),
          Text(s.demoByKind, style: labelStyle),
          const SizedBox(height: 6),
          for (var k = 0; k < kinds.length; k++)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(width: 8, height: 8, color: _kindColors[k]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          kinds[k],
                          overflow: TextOverflow.ellipsis,
                          style: serif(fontSize: 14, color: _ink),
                        ),
                      ),
                      Text(
                        '${counts[k]}',
                        style: serif(fontSize: 14, color: _ink),
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: () => _toggleMute(k),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            _muted.contains(k) ? s.demoMuted : s.demoMute,
                            style: labelStyle.copyWith(
                              letterSpacing: 0.5,
                              color: _muted.contains(k) ? _gold : _softInk,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: (_checks / 20).clamp(0.0, 1.0),
                      minHeight: 3,
                      color: _gold,
                      backgroundColor: Colors.black.withValues(alpha: 0.08),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      s.demoSeen(_checks),
                      style: GoogleFonts.inter(fontSize: 10, color: _softInk),
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

class _LinePainter extends CustomPainter {
  _LinePainter(this.values);

  final List<int> values;

  @override
  void paint(Canvas canvas, Size size) {
    final max = values.reduce(math.max).toDouble();
    final dx = size.width / (values.length - 1);
    Offset point(int i) =>
        Offset(i * dx, size.height - (values[i] / max) * (size.height - 8) - 4);

    final path = Path()..moveTo(point(0).dx, point(0).dy);
    for (var i = 1; i < values.length; i++) {
      path.lineTo(point(i).dx, point(i).dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = _gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeJoin = StrokeJoin.round,
    );
    final last = point(values.length - 1);
    canvas.drawCircle(last, 3.2, Paint()..color = _sidebarBg);
    canvas.drawCircle(
      last,
      3.2,
      Paint()
        ..color = _gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
  }

  @override
  bool shouldRepaint(_LinePainter old) => !listEquals(values, old.values);
}

class _CheckButton extends StatelessWidget {
  const _CheckButton({required this.label, required this.onTap});

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
              ? Colors.black.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: selected ? _ink : _softInk,
          ),
        ),
      ),
    );
  }
}
