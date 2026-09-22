import 'package:flutter/material.dart';

/// Site-wide switch for the decorative background animations (the golden
/// gate/knowledge graph/leather backdrops and the tech-stack marquee) — the
/// same one-flag-everyone-listens shape as [ThemeController]. Defaults to on
/// regardless of the browser's `prefers-reduced-motion` setting (that OS-wide
/// signal used to freeze every animation on the site at once, which read as
/// "broken" rather than as a deliberate accessibility choice); this toggle
/// gives a visitor who actually wants motion off an explicit way to ask for
/// it instead.
class MotionController extends ValueNotifier<bool> {
  MotionController({bool animationsEnabled = true}) : super(animationsEnabled);

  bool get animationsEnabled => value;

  void toggle() => value = !value;
}

/// Exposes the [MotionController] to the whole tree, the same way [AppTheme]
/// exposes the theme controller — reading it via [of] subscribes that widget
/// to rebuild whenever the setting flips.
class AppMotion extends InheritedNotifier<MotionController> {
  const AppMotion({super.key, required MotionController controller, required super.child})
    : super(notifier: controller);

  static MotionController of(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<AppMotion>();
    assert(widget != null, 'No AppMotion found in context');
    return widget!.notifier!;
  }
}

/// Shorthand for the common case of just needing the current bool.
bool motionEnabledOf(BuildContext context) => AppMotion.of(context).animationsEnabled;
