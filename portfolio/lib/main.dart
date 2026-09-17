import 'package:flutter/material.dart';
import 'package:portfolio/pages/home.dart';

void main() {
  runApp(const MyApp());
}

/// The app's single entry point: a `MaterialApp` wrapping [Home], which is
/// where the actual page (header + scrolling sections) lives.
///
/// Note: the `theme` below is Flutter's default starter-project theme and
/// is mostly vestigial — every section paints itself with an explicit
/// colour from `lib/theme/palette.dart` (kLightBg, kDarkBg, kBlue, ...)
/// rather than pulling colours from this `ColorScheme`. The one exception
/// is `Home`'s outer gradient, which does read `Theme.of(context).colorScheme`
/// — but since every section is opaque and covers the full screen height,
/// that gradient is never actually visible. Safe to change or remove.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const Home(),
    );
  }
}
