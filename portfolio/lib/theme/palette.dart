import 'package:flutter/material.dart';

import 'theme_controller.dart';

/// The "Tempered steel" design tokens. They mirror the `Tempered steel`
/// variable collection in the Figma file
/// (https://www.figma.com/design/OGWIDIf19lEsgXTltUo4sq), which has one Dark
/// and one Light mode: blued-steel darks, a brushed-steel light mode, a straw
/// accent taken from the first temper colour, and Synapse lavender kept only
/// for the Synapse OS showcase. Change colours here, not in the sections.
class _Tokens {
  const _Tokens({
    required this.bg,
    required this.band,
    required this.card,
    required this.raised,
    required this.hover,
    required this.line,
    required this.lineStrong,
    required this.ink,
    required this.ink2,
    required this.secondary,
    required this.tertiary,
    required this.muted,
    required this.accent,
    required this.onAccent,
    required this.ai,
    required this.ok,
    required this.temper,
  });

  final Color bg;
  final Color band;
  final Color card;
  final Color raised;
  final Color hover;
  final Color line;
  final Color lineStrong;
  final Color ink;
  final Color ink2;
  final Color secondary;
  final Color tertiary;
  final Color muted;
  final Color accent;
  final Color onAccent;
  final Color ai;
  final Color ok;

  /// The heat tint of tempered steel, straw to blue: the site's one
  /// signature element (the bead under the headlines, the logo tile).
  final List<Color> temper;
}

const _dark = _Tokens(
  bg: Color(0xFF0D131C),
  band: Color(0xFF111925),
  card: Color(0xFF162130),
  raised: Color(0xFF1C2A3B),
  hover: Color(0xFF213246),
  line: Color(0xFF24344A),
  lineStrong: Color(0xFF3A4F68),
  ink: Color(0xFFEEF2F7),
  ink2: Color(0xFFD7DEE8),
  secondary: Color(0xFFA3B0C2),
  tertiary: Color(0xFF8494A9),
  muted: Color(0xFF66768C),
  accent: Color(0xFFF0B657),
  onAccent: Color(0xFF1A1205),
  ai: Color(0xFFB9A6FF),
  ok: Color(0xFF5DD3A9),
  temper: [
    Color(0xFFF2C46B),
    Color(0xFFD9853B),
    Color(0xFFA85BC4),
    Color(0xFF6B7FF0),
  ],
);

const _light = _Tokens(
  bg: Color(0xFFEEF1F5),
  band: Color(0xFFE4E9EF),
  card: Color(0xFFFFFFFF),
  raised: Color(0xFFE8EDF3),
  hover: Color(0xFFDDE4EC),
  line: Color(0xFFD2DAE4),
  lineStrong: Color(0xFFB7C3D1),
  ink: Color(0xFF0D131C),
  ink2: Color(0xFF1F2A38),
  secondary: Color(0xFF435064),
  tertiary: Color(0xFF566378),
  muted: Color(0xFF738096),
  accent: Color(0xFF94560A),
  onAccent: Color(0xFFFFFFFF),
  ai: Color(0xFF5B3BC4),
  ok: Color(0xFF0D6444),
  temper: [
    Color(0xFFD9A441),
    Color(0xFFC06A26),
    Color(0xFF8E45AE),
    Color(0xFF4C62D8),
  ],
);

/// Bundles the colours that flip between the site's light and dark modes, so
/// a section only has to ask "what's my background/ink/surface right now"
/// instead of branching on [ThemeController.isDark] itself.
class AppPalette {
  const AppPalette({required this.dark});

  final bool dark;

  _Tokens get _t => dark ? _dark : _light;

  /// Page background.
  Color get bg => _t.bg;

  /// The slightly offset band behind the tools strip, Work and Contact, so the
  /// sections read as separate bands on one continuous page.
  Color get altBg => _t.band;

  /// Card / panel fill.
  Color get card => _t.card;
  Color get panel => _t.card;

  /// A step above [card]: chips, badges, inset tiles.
  Color get raised => _t.raised;

  /// Hover fill.
  Color get hover => _t.hover;

  /// Hairline border and its stronger sibling.
  Color get line => _t.line;
  Color get lineStrong => _t.lineStrong;

  /// Primary text, and a slightly softer version of it.
  Color get ink => _t.ink;
  Color get ink2 => _t.ink2;

  /// Body copy under a headline.
  Color get secondary => _t.secondary;

  /// Small labels and captions.
  Color get tertiary => _t.tertiary;

  /// Decorative, lowest-emphasis marks (future steps on the path).
  Color get muted => _t.muted;

  /// Straw: links, the primary button and the current step.
  Color get accent => _t.accent;

  /// Text/icon colour that sits on a solid [accent] fill.
  Color get onAccent => _t.onAccent;

  /// Synapse lavender, only inside the Synapse OS showcase and for AI hints,
  /// so the product keeps its own colour.
  Color get ai => _t.ai;
  Color get aiFaint => _t.ai.withValues(alpha: dark ? 0.06 : 0.05);
  Color get aiTint => _t.ai.withValues(alpha: dark ? 0.12 : 0.10);
  Color get aiLine => _t.ai.withValues(alpha: dark ? 0.50 : 0.45);

  /// "Open", "Published": state, never decoration.
  Color get ok => _t.ok;

  /// The temper colours, straw to blue.
  List<Color> get temper => _t.temper;

  LinearGradient get temperGradient =>
      LinearGradient(colors: _t.temper, stops: const [0, 0.36, 0.7, 1]);
}

AppPalette paletteOf(BuildContext context) =>
    AppPalette(dark: isDarkOf(context));
