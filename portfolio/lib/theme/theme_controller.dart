import 'package:flutter/material.dart';

/// Site-wide light/dark switch. A plain [ValueNotifier] rather than a state
/// management package: the whole app is small enough that "one flag,
/// everyone listens" is all this needs.
class ThemeController extends ValueNotifier<bool> {
  ThemeController({bool isDark = true}) : super(isDark);

  bool get isDark => value;

  void toggle() => value = !value;
}

/// Exposes the [ThemeController] to the whole tree. Reading it via [of]
/// (which every call site below does through [isDarkOf]) subscribes that
/// widget to rebuild whenever the mode flips, the same way `Theme.of` or
/// `MediaQuery.of` do.
class AppTheme extends InheritedNotifier<ThemeController> {
  const AppTheme({super.key, required ThemeController controller, required super.child})
    : super(notifier: controller);

  static ThemeController of(BuildContext context) {
    final widget = context
        .dependOnInheritedWidgetOfExactType<AppTheme>();
    assert(widget != null, 'No AppTheme found in context');
    return widget!.notifier!;
  }
}

/// Shorthand for the common case of just needing the current bool.
bool isDarkOf(BuildContext context) => AppTheme.of(context).isDark;
