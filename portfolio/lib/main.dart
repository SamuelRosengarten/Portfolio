import 'package:flutter/material.dart';
import 'package:portfolio/i18n/app_language.dart';
import 'package:portfolio/pages/about_section.dart';
import 'package:portfolio/pages/home.dart';
import 'package:portfolio/theme/motion_controller.dart';
import 'package:portfolio/theme/theme_controller.dart';

void main() {
  // Needed before precacheLanguageIcons can touch the asset bundle — runApp
  // below would call this too, but not soon enough for that to help here.
  WidgetsFlutterBinding.ensureInitialized();
  // Fired before the widget tree even exists, so these fetches overlap
  // with the engine's own startup instead of only starting once the first
  // frame (About's language marquee included) has already built — see
  // precacheLanguageIcons's own doc comment for why that ordering matters.
  precacheLanguageIcons();
  runApp(const MyApp());
}

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
  final _motionController = MotionController();

  @override
  void dispose() {
    _controller.dispose();
    _localeController.dispose();
    _motionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppTheme(
      controller: _controller,
      child: AppLocale(
        controller: _localeController,
        child: AppMotion(
          controller: _motionController,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Samuel Rosengarten',
              theme: ThemeData(
                brightness: _controller.isDark ? Brightness.dark : Brightness.light,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.deepPurple,
                  brightness: _controller.isDark ? Brightness.dark : Brightness.light,
                ),
              ),
              home: const Home(),
            ),
          ),
        ),
      ),
    );
  }
}
