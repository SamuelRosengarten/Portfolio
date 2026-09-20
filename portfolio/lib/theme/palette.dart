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

  /// A translucent card/chip fill, white-on-dark or black-on-light at the
  /// same alpha the design already leans on for "frosted surface" panels.
  Color surface(double alpha) =>
      (dark ? Colors.white : Colors.black).withValues(alpha: alpha);
}

AppPalette paletteOf(BuildContext context) =>
    AppPalette(dark: isDarkOf(context));
