import 'package:flutter/material.dart';
import 'package:portfolio/pages/home.dart';
import 'package:portfolio/theme/theme_controller.dart';

void main() {
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppTheme(
      controller: _controller,
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
    );
  }
}
