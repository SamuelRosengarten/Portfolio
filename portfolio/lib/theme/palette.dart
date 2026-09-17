import 'package:flutter/material.dart';

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
const Color kPanelBg = Color(0xFFF5F5F7);
const Color kInk = Color(0xFF1D1D1F);
const Color kGray = Color(0xFF86868B);
const Color kBlue = Color(0xFF2997FF);
