import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/i18n/app_language.dart';
import 'package:portfolio/pages/about_section.dart';
import 'package:portfolio/pages/contact_section.dart';
import 'package:portfolio/pages/hobbies_section.dart';
import 'package:portfolio/pages/home.dart';
import 'package:portfolio/pages/project_section.dart';
import 'package:portfolio/theme/theme_controller.dart';

void main() {
  testWidgets('header items swap which section is shown, one at a time', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    // Home reads the site's light/dark palette and language via
    // AppTheme.of(context) / AppLocale.of(context), so both need an ancestor
    // even in isolation — main.dart provides them for real; here they stand
    // in for that.
    await tester.pumpWidget(
      AppTheme(
        controller: ThemeController(),
        child: AppLocale(
          controller: LocaleController(),
          child: const MaterialApp(home: Home()),
        ),
      ),
    );
    // The about section's animated backdrop never stops ticking, so settle by
    // pumping past each scroll animation instead of waiting for an idle frame.
    await tester.pump();
    // About's particle headline schedules a one-shot 600ms retry timer (see
    // about_section.dart) — let it fire before poking at anything else.
    await tester.pump(const Duration(milliseconds: 700));

    // Only About is on screen at first — the other three sections aren't
    // reachable until picked from the nav.
    expect(find.byType(AboutSection), findsOneWidget);
    expect(find.byType(ProjectSection), findsNothing);
    expect(find.byType(HobbiesSection), findsNothing);
    expect(find.byType(ContactSection), findsNothing);

    for (final probe in {
      'Projects': find.byType(ProjectSection),
      'Hobbies': find.byType(HobbiesSection),
      'Contact': find.byType(ContactSection),
    }.entries) {
      await tester.tap(find.text(probe.key).first);
      await tester.pump();
      expect(tester.takeException(), isNull, reason: probe.key);

      // Picking a section swaps it in and takes every other one off screen
      // — there's no continuous scroll to accidentally land back on one.
      expect(probe.value, findsOneWidget, reason: probe.key);
      expect(find.byType(AboutSection), findsNothing, reason: probe.key);
    }

    await tester.tap(find.text('About').first);
    await tester.pump();
    expect(find.byType(AboutSection), findsOneWidget);
    expect(find.byType(ContactSection), findsNothing);

    // About's particle headline schedules its own one-shot 600ms retry timer
    // on mount (see about_section.dart) — let it fire before the test ends
    // instead of leaving it pending.
    await tester.pump(const Duration(milliseconds: 700));
  });
}
