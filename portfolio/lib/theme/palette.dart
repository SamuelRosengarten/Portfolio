import 'package:flutter/material.dart';

import 'theme_controller.dart';

/// The Synapse OS design tokens, ported from the app's `src/styles/tokens.css`
/// so the portfolio and the app read as one product: quiet graphite surfaces,
/// hairline borders, lavender reserved for AI/links, and status colours that
/// only ever mean state. Dark is the default; light mirrors the app's light
/// theme. Change colours here, not in the sections.
class _Tokens {
  const _Tokens({
    required this.bg,
    required this.side,
    required this.panel,
    required this.raised,
    required this.hover,
    required this.line,
    required this.line2,
    required this.text,
    required this.text2,
    required this.muted,
    required this.faint,
    required this.dim,
    required this.canvasDot,
    required this.ai,
    required this.aiFg,
    required this.due,
    required this.ok,
    required this.bad,
    required this.info,
  });

  final Color bg;
  final Color side;
  final Color panel;
  final Color raised;
  final Color hover;
  final Color line;
  final Color line2;
  final Color text;
  final Color text2;
  final Color muted;
  final Color faint;
  final Color dim;
  final Color canvasDot;
  final Color ai;
  final Color aiFg;
  final Color due;
  final Color ok;
  final Color bad;
  final Color info;
}

const _dark = _Tokens(
  bg: Color(0xFF0A0C10),
  side: Color(0xFF0D1015),
  panel: Color(0xFF11151B),
  raised: Color(0xFF171C24),
  hover: Color(0xFF1D232D),
  line: Color(0xFF252C37),
  line2: Color(0xFF3A4352),
  text: Color(0xFFEEF0F4),
  text2: Color(0xFFDFE3EA),
  muted: Color(0xFFA6AFBD),
  faint: Color(0xFF8B95A6),
  dim: Color(0xFF6B7586),
  canvasDot: Color(0xFF181D26),
  ai: Color(0xFFB9A6FF),
  aiFg: Color(0xFF15102A),
  due: Color(0xFFF2C277),
  ok: Color(0xFF5DD3A9),
  bad: Color(0xFFFF9090),
  info: Color(0xFF86B4FF),
);

const _light = _Tokens(
  bg: Color(0xFFF7F8FA),
  side: Color(0xFFF1F3F6),
  panel: Color(0xFFFFFFFF),
  raised: Color(0xFFEEF0F4),
  hover: Color(0xFFE6E9EE),
  line: Color(0xFFDCE0E6),
  line2: Color(0xFFC4CAD3),
  text: Color(0xFF14171C),
  text2: Color(0xFF2B313A),
  muted: Color(0xFF4A5361),
  faint: Color(0xFF5F6978),
  dim: Color(0xFF7A8494),
  canvasDot: Color(0xFFD5DAE1),
  ai: Color(0xFF5B3BC4),
  aiFg: Color(0xFFFFFFFF),
  due: Color(0xFF7A5200),
  ok: Color(0xFF0D6444),
  bad: Color(0xFFAB2530),
  info: Color(0xFF2556BB),
);

/// Bundles the colours that flip between the site's light and dark modes, so
/// a section only has to ask "what's my background/ink/surface right now"
/// instead of branching on [ThemeController.isDark] itself.
class AppPalette {
  const AppPalette({required this.dark});

  final bool dark;

  _Tokens get _t => dark ? _dark : _light;

  /// Page background (`--bg`).
  Color get bg => _t.bg;

  /// The slightly offset band behind Projects and Contact (`--side`), so the
  /// flat sections read as separate bands on one continuous page.
  Color get altBg => _t.side;

  /// Card / panel fill (`--panel`).
  Color get card => _t.panel;
  Color get panel => _t.panel;
  Color get panelBg => _t.panel;

  /// A step above [card] (`--raised`): chips, badges, inset tiles.
  Color get raised => _t.raised;

  /// Hover fill (`--hover`).
  Color get hover => _t.hover;

  /// Hairline border (`--line`) and its stronger sibling (`--line2`).
  Color get line => _t.line;
  Color get lineStrong => _t.line2;

  /// Primary text (`--text`).
  Color get ink => _t.text;

  /// Slightly softer primary text (`--text2`).
  Color get ink2 => _t.text2;

  /// Body copy under a headline (`--muted`).
  Color get secondary => _t.muted;

  /// Small labels and captions (`--faint`).
  Color get tertiary => _t.faint;

  /// Decorative, lowest-emphasis text (`--dim`).
  Color get muted => _t.dim;

  /// The dot-grid colour behind the hero (`--canvas-dot`).
  Color get canvasDot => _t.canvasDot;

  /// Lavender: reserved for AI and links, exactly like the app (`--ai`).
  Color get accent => _t.ai;
  Color get ai => _t.ai;

  /// Text/icon colour that sits on a solid [accent] fill (`--ai-fg`).
  Color get onAccent => _t.aiFg;

  /// Tinted accent text, e.g. the status pill.
  Color get accentText => _t.ai;

  /// AI-card background / border / pill fill (`--ai-bg`, `--ai-line`).
  Color get aiBg => _t.ai.withValues(alpha: dark ? 0.12 : 0.10);
  Color get aiFaint => _t.ai.withValues(alpha: dark ? 0.05 : 0.04);
  Color get aiLine => _t.ai.withValues(alpha: dark ? 0.50 : 0.45);

  /// Status colours. They only ever mean state, never decoration.
  Color get ok => _t.ok;
  Color get due => _t.due;
  Color get bad => _t.bad;
  Color get info => _t.info;

  /// A translucent fill, white-on-dark or black-on-light.
  Color surface(double alpha) =>
      (dark ? Colors.white : Colors.black).withValues(alpha: alpha);
}

AppPalette paletteOf(BuildContext context) =>
    AppPalette(dark: isDarkOf(context));
