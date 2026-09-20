import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:portfolio/main.dart';

void main() {
  testWidgets('mobile: every section renders alone, full-screen, without overflow', (tester) async {
    tester.view.physicalSize = const Size(390, 844); // iPhone 16 Pro-ish
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.textContaining("Let's talk."), findsNothing);
    expect(find.textContaining('Something is coming.'), findsNothing);
    expect(find.textContaining('Teach.'), findsNothing);
    expect(tester.takeException(), isNull, reason: 'About section (initial)');

    for (final label in ['Projects', 'Hobbies', 'Contact', 'About']) {
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text(label));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull, reason: '$label section on mobile');
    }

    // About's particle headline schedules a one-shot 600ms retry timer (see
    // about_section.dart) — let it fire before the test ends instead of
    // leaving it pending.
    await tester.pump(const Duration(milliseconds: 700));
  });

  testWidgets('desktop: toggling theme and jump-scrolling between sections works', (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.byType(SingleChildScrollView), findsWidgets);

    await tester.tap(find.text('Contact'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    expect(tester.takeException(), isNull, reason: 'desktop scroll-to-Contact');

    await tester.tap(find.byTooltip('Switch to light mode'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull, reason: 'desktop theme toggle');
    expect(find.byTooltip('Switch to dark mode'), findsOneWidget);
  });
}
