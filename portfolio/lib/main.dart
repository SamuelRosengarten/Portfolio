import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portfolio/i18n/app_language.dart';
import 'package:portfolio/pages/home.dart';
import 'package:portfolio/theme/palette.dart';
import 'package:portfolio/theme/theme_controller.dart';

void main() => runApp(const MyApp());

/// The app's single entry point: a `MaterialApp` wrapping [Home], which is
/// where the actual page (header + scrolling sections) lives.
///
/// [_controller] is the single source of truth for light vs. dark mode —
/// every section reads it through `AppTheme.of(context)` /
/// `lib/theme/palette.dart`'s `paletteOf(context)` rather than pulling
/// colours from `MaterialApp`'s own `ColorScheme`, which stays mostly
/// vestigial (only `ThemeData.brightness` below is real; it just keeps
/// default Material widgets like the mobile nav `Drawer` in step with the
/// site's own toggle).
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _controller = ThemeController();
  final _localeController = LocaleController();

  @override
  void dispose() {
    _controller.dispose();
    _localeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppTheme(
      controller: _controller,
      child: AppLocale(
        controller: _localeController,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Samuel Rosengarten',
            theme: _themeFor(AppPalette(dark: _controller.isDark)),
            home: const Home(),
          ),
        ),
      ),
    );
  }
}

/// Material theme derived from the Tempered steel tokens in `palette.dart`, so the
/// stock widgets (the nav drawer, tooltips, ripples) match the rest of the
/// site instead of showing Material's default purple.
ThemeData _themeFor(AppPalette p) {
  final brightness = p.dark ? Brightness.dark : Brightness.light;
  return ThemeData(
    brightness: brightness,
    useMaterial3: true,
    scaffoldBackgroundColor: p.bg,
    canvasColor: p.altBg,
    dividerColor: p.line,
    hoverColor: p.hover,
    splashFactory: NoSplash.splashFactory,
    textTheme: GoogleFonts.ibmPlexSansTextTheme(
      ThemeData(brightness: brightness).textTheme,
    ),
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: p.accent,
          brightness: brightness,
        ).copyWith(
          primary: p.accent,
          onPrimary: p.onAccent,
          surface: p.card,
          onSurface: p.ink,
        ),
  );
}
