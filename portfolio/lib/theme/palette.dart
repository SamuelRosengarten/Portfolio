import 'package:flutter/material.dart';

import 'theme_controller.dart';

/// The shared palette every section paints from.
///
/// Keeping these in one place (instead of each section hardcoding its own
/// hex values) is what makes the site look consistent: a light section uses
/// [kLightBg]/[kInk]/[kGray], a dark one uses [kDarkBg]/[kBlue], and both
/// share [kPanelBg] for card backgrounds. The hobbies section is the one
/// exception — it defines its own ink/leather colours locally because
/// nothing else on the site uses that palette.
const Color kLightBg = Color(0xFFFBFBFD);
const Color kDarkBg = Color(0xFF000000);
const Color kDarkPanelBg = Color(0xFF1C1C1E);
const Color kPanelBg = Color(0xFFF5F5F7);
const Color kInk = Color(0xFF1D1D1F);
const Color kGray = Color(0xFF86868B);
const Color kBlue = Color(0xFF2997FF);

/// Bundles the handful of colours that flip between the site's light and
/// dark modes, so a section only has to ask "what's my background/ink/
/// surface right now" instead of branching on [ThemeController.isDark]
/// everywhere itself.
class AppPalette {
  const AppPalette({required this.dark});

  final bool dark;

  /// The section-background colour for the flat (non-textured) sections —
  /// Projects and Contact. About, Hobbies and the header paint their own
  /// backgrounds but still read [ink]/[surface] from here.
  Color get bg => dark ? kDarkBg : kLightBg;

  Color get panelBg => dark ? kDarkPanelBg : kPanelBg;

  /// Primary text colour: white on a dark surface, near-black on a light one.
  Color get ink => dark ? Colors.white : kInk;

  Color get gray => kGray;

  Color get blue => kBlue;

  /// The slightly offset band behind Projects and Contact, so the flat
  /// sections read as separate bands on one continuous page.
  Color get altBg => dark ? const Color(0xFF0B0B0C) : kPanelBg;

  /// Raised card fill (project card, contact cards, stack chips).
  Color get card => dark ? kDarkPanelBg : Colors.white;

  /// The stack panel's fill — a step below [card] so chips sit on it.
  Color get panel => dark ? const Color(0xFF111113) : Colors.white;

  /// Body copy under a headline.
  Color get secondary =>
      dark ? const Color(0xFFA1A1A6) : const Color(0xFF515154);

  /// Small labels and captions.
  Color get tertiary =>
      dark ? const Color(0xFF98989D) : const Color(0xFF6E6E73);

  /// Decorative, lowest-emphasis text (the hero's second line, chevrons).
  Color get muted => dark ? const Color(0xFF6E6E73) : kGray;

  /// Brand accent. Light mode uses a deeper blue so white text on it passes.
  Color get accent => dark ? kBlue : const Color(0xFF0071E3);

  /// Text/icon colour that sits on top of [accent].
  Color get onAccent => dark ? Colors.black : Colors.white;

  /// Tinted accent text, e.g. the "Published" pill.
  Color get accentText =>
      dark ? const Color(0xFF7CC0FF) : const Color(0xFF0060C0);

  /// A translucent card/chip fill, white-on-dark or black-on-light at the
  /// same alpha the design already leans on for "frosted surface" panels.
  Color surface(double alpha) =>
      (dark ? Colors.white : Colors.black).withValues(alpha: alpha);
}

AppPalette paletteOf(BuildContext context) =>
    AppPalette(dark: isDarkOf(context));
