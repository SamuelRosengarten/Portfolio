import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/main.dart';
import 'package:portfolio/pages/about_section.dart';
import 'package:portfolio/pages/contact_section.dart';
import 'package:portfolio/pages/hobbies_section.dart';
import 'package:portfolio/pages/project_section.dart';

double _pageOffset(WidgetTester tester) => tester
    .state<ScrollableState>(find.byType(Scrollable).first)
    .position
    .pixels;

void main() {
  testWidgets('every section is on one continuously scrolling page', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.byType(AboutSection), findsOneWidget);
    expect(find.byType(ProjectSection), findsOneWidget);
    expect(find.byType(HobbiesSection), findsOneWidget);
    expect(find.byType(ContactSection), findsOneWidget);
    expect(find.text("Hi, I'm Samuel."), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('header links scroll to their section', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MyApp());
    await tester.pump();
    expect(_pageOffset(tester), 0);

    var previous = 0.0;
    for (final label in ['Projects', 'Hobbies', 'Contact']) {
      await tester.tap(find.text(label).first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: label);
      expect(_pageOffset(tester), greaterThan(previous), reason: label);
      previous = _pageOffset(tester);
    }

    await tester.tap(find.text('About').first);
    await tester.pumpAndSettle();
    expect(_pageOffset(tester), 0);
  });

  testWidgets('theme and language toggles rebuild the page', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MyApp());
    await tester.pump();

    await tester.tap(find.byTooltip('Switch to light mode'));
    await tester.pump();
    expect(find.byTooltip('Switch to dark mode'), findsOneWidget);

    await tester.tap(find.byTooltip('Passer au français'));
    await tester.pump();
    expect(find.text('Salut, je suis Samuel.'), findsOneWidget);
    expect(find.text('À propos'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
