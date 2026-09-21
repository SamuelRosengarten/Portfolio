import 'package:flutter/material.dart';

/// The two languages the site is written in.
enum AppLanguage { en, fr }

/// Site-wide language switch — the same one-flag-everyone-listens shape as
/// `ThemeController`, just holding [AppLanguage] instead of a dark/light bool.
class LocaleController extends ValueNotifier<AppLanguage> {
  LocaleController({AppLanguage language = AppLanguage.en}) : super(language);

  AppLanguage get language => value;

  void toggle() =>
      value = value == AppLanguage.en ? AppLanguage.fr : AppLanguage.en;
}

/// Exposes the [LocaleController] to the whole tree, the same way [AppTheme]
/// exposes the theme controller — reading it via [of] subscribes that widget
/// to rebuild whenever the language flips.
class AppLocale extends InheritedNotifier<LocaleController> {
  const AppLocale({
    super.key,
    required LocaleController controller,
    required super.child,
  }) : super(notifier: controller);

  static LocaleController of(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<AppLocale>();
    assert(widget != null, 'No AppLocale found in context');
    return widget!.notifier!;
  }
}

/// Shorthand for the common case of just needing the current language.
AppLanguage languageOf(BuildContext context) => AppLocale.of(context).language;
