import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:portfolio/main.dart';

/// Taps through every section from the mobile nav drawer and asserts each
/// one fits a phone screen on its own — see the inline comment below for
/// what "fits" allows. Shared between the English and French versions of
/// this check: a translation running long enough to need extra scrolling is
/// exactly the kind of regression this is meant to catch, so both languages
/// have to hold to the same budget rather than the French run getting a
/// laxer one.
Future<void> _expectMobileSectionsFitOneScreen(WidgetTester tester, List<String> labels) async {
  for (final label in labels) {
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text(label));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull, reason: '$label section on mobile');

    // Each section should fit the screen on its own on a phone-size
    // device, not just "not crash" — a section whose content needs an
    // internal scroll to see all of it (e.g. Contact's cards running off
    // the bottom) defeats the point of "one section, one screen".
    // SectionShell's scroll fallback exists for genuinely short/unusual
    // viewports, not as something normal phone-size content routinely
    // leans on. Hobbies is the one deliberate exception: each half packs
    // in a bio block *and* either a tutoring card or a product carousel,
    // and shrinking that further would mean cutting visible content
    // (tags, card copy) rather than just tightening whitespace — so it
    // gets a generous but bounded allowance instead of zero.
    final allowedScroll = (label == 'Hobbies' || label == 'Loisirs') ? 260.0 : 0.0;
    for (final state in tester.stateList<ScrollableState>(find.byType(Scrollable))) {
      // The leather carousel's own horizontal paging isn't this kind of
      // overflow — it's supposed to scroll sideways.
      if (state.widget.axis == Axis.horizontal) continue;
      expect(
        state.position.maxScrollExtent,
        lessThanOrEqualTo(allowedScroll),
        reason: '$label section needed more internal scroll than expected on a phone-size screen',
      );
    }
  }
}

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

    await _expectMobileSectionsFitOneScreen(tester, ['Projects', 'Hobbies', 'Contact', 'About']);

    // About's particle headline schedules a one-shot 600ms retry timer (see
    // about_section.dart) — let it fire before the test ends instead of
    // leaving it pending.
    await tester.pump(const Duration(milliseconds: 700));
  });

  testWidgets(
    'mobile: every section still fits one screen in French, where copy runs longer',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MyApp());
      await tester.pump(const Duration(milliseconds: 700));

      // The language toggle sits in the persistent header, not the nav
      // drawer, so it's reachable without opening the drawer first.
      await tester.tap(find.byTooltip('Passer au français'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await _expectMobileSectionsFitOneScreen(tester, [
        'Projets',
        'Loisirs',
        'Contact',
        'À propos',
      ]);

      await tester.pump(const Duration(milliseconds: 700));
    },
  );

  testWidgets('desktop: toggling theme and switching sections from the nav works', (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 700));

    await tester.tap(find.text('Contact'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    expect(tester.takeException(), isNull, reason: 'desktop switch-to-Contact');
    expect(find.text("Let's talk."), findsOneWidget);

    await tester.tap(find.byTooltip('Switch to light mode'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull, reason: 'desktop theme toggle');
    expect(find.byTooltip('Switch to dark mode'), findsOneWidget);
  });
}
