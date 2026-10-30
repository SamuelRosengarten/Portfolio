import 'package:flutter/material.dart';

import 'theme_controller.dart';

/// The shared palette every section paints from: a black terminal/HUD look
/// with one hazard-yellow accent, plus a green "online" and an orange
/// "highlight" for status readouts.
///
/// Keeping these in one place (instead of each section hardcoding its own
/// hex values) is what lets the light theme — an off-white printout of the
/// same HUD — reuse every widget unchanged. The Synapse OS demo is the one
/// exception: it recreates that app's own UI, so it keeps its own colours.
const Color kHudBlack = Color(0xFF1A1A1A);
const Color kHudPanel = Color(0xFF111111);
const Color kHudYellow = Color(0xFFFFFF00);
const Color kHudOrange = Color(0xFFFF6700);
const Color kHudGreen = Color(0xFF00FF00);
const Color kHudPaper = Color(0xFFF2F0E9);

/// Pre-HUD colours, still used by the (currently unused) Code Coach demo.
const Color kBlue = Color(0xFF2997FF);
const Color kGray = Color(0xFF86868B);

/// Bundles the handful of colours that flip between the site's light and
/// dark modes, so a section only has to ask "what's my background/ink/
/// surface right now" instead of branching on [ThemeController.isDark]
/// everywhere itself.
class AppPalette {
  const AppPalette({required this.dark});

  final bool dark;

  /// Page background, under the grid backdrop.
  Color get bg => dark ? kHudBlack : kHudPaper;

  /// The side rail, top bar, drawer and CLI bar: pure black when dark.
  Color get chrome => dark ? Colors.black : Colors.white;

  /// Primary text colour.
  Color get ink => dark ? Colors.white : const Color(0xFF0A0A0A);

  /// Sections no longer paint their own bands — the grid runs behind the
  /// whole page — so the "alternate" background is see-through.
  Color get altBg => Colors.transparent;

  /// Raised card fill (cards, contact cards, tool chips).
  Color get card => dark ? kHudPanel : Colors.white;

  /// Panel fill — the same as [card] in the HUD look.
  Color get panel => card;

  /// Body copy under a headline.
  Color get secondary =>
      dark ? const Color(0xFFB3B3B3) : const Color(0xFF3D3D3D);

  /// Small labels and captions.
  Color get tertiary =>
      dark ? const Color(0xFF8A8A8A) : const Color(0xFF5E5E5E);

  /// Decorative, lowest-emphasis text.
  Color get muted => dark ? const Color(0xFF6E6E6E) : const Color(0xFF8A8A8A);

  /// The hazard accent. On paper pure yellow has no contrast, so the light
  /// theme uses a dark amber for text, borders and fills.
  Color get accent => dark ? kHudYellow : const Color(0xFF7A6300);

  /// Text/icon colour that sits on top of [accent].
  Color get onAccent => dark ? Colors.black : Colors.white;

  /// Tinted accent text, e.g. a highlighted pill.
  Color get accentText => accent;

  /// Kept for older call sites that tinted pills "blue"; now the accent.
  Color get blue => accent;

  /// "ONLINE" / healthy status.
  Color get ok => dark ? kHudGreen : const Color(0xFF0F8A3A);

  /// Secondary highlight ("OPERATOR", in-progress statuses).
  Color get highlight => dark ? kHudOrange : const Color(0xFFB34700);

  /// The accent at a given alpha, for panel borders and glows.
  Color accentAlpha(double alpha) => accent.withValues(alpha: alpha);

  /// A translucent fill/hairline, white-on-dark or black-on-light.
  Color surface(double alpha) =>
      (dark ? Colors.white : Colors.black).withValues(alpha: alpha);
}

AppPalette paletteOf(BuildContext context) =>
    AppPalette(dark: isDarkOf(context));
