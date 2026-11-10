import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/main.dart';
import 'package:portfolio/pages/about_section.dart';
import 'package:portfolio/pages/contact_section.dart';
import 'package:portfolio/pages/hobbies_section.dart';
import 'package:portfolio/pages/project_section.dart';
import 'package:portfolio/pages/synapse_section.dart';

double _pageOffset(WidgetTester tester) => tester
    .state<ScrollableState>(find.byType(Scrollable).first)
    .position
    .pixels;

String? _assetOf(Widget widget) {
  final image = widget is Image ? widget.image : null;
  return image is AssetImage ? image.assetName : null;
}

Iterable<String> _assets(WidgetTester tester) => tester
    .widgetList<Image>(find.byType(Image))
    .map(_assetOf)
    .whereType<String>();

void main() {
  testWidgets('every section is on one continuously scrolling page', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.byType(AboutSection), findsOneWidget);
    expect(find.byType(SynapseSection), findsOneWidget);
    expect(find.byType(ProjectSection), findsOneWidget);
    expect(find.byType(HobbiesSection), findsOneWidget);
    expect(find.byType(ContactSection), findsOneWidget);
    expect(find.text("Hi, I'm Samuel."), findsOneWidget);
    expect(find.text('Founder, Synapse OS'), findsOneWidget);
    expect(find.text('BUILT AS A BUSINESS'), findsOneWidget);
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
    for (final label in ['Synapse OS', 'Work', 'Beyond code', 'Contact']) {
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

  testWidgets('Synapse OS showcase frames the iPhone and Mac screens and '
      'follows the site theme', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(
      _assets(tester),
      containsAll(<String>[
        'assets/synapse/mac_today_dark.webp',
        'assets/synapse/ios_today_dark.webp',
        'assets/synapse/ios_ask_dark.webp',
        'assets/synapse/ios_review_dark.webp',
        'assets/synapse/ios_chat_dark.webp',
        'assets/synapse/mac_chat_dark.webp',
      ]),
    );
    expect(
      find.bySemanticsLabel('Synapse on iPhone: Ask Nova'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Synapse on Mac: team chat'), findsOneWidget);

    await tester.tap(find.byTooltip('Switch to light mode'));
    await tester.pump();
    expect(
      _assets(tester),
      containsAll(<String>[
        'assets/synapse/mac_today_light.webp',
        'assets/synapse/ios_today_light.webp',
      ]),
    );
    expect(
      _assets(tester),
      isNot(contains('assets/synapse/mac_today_dark.webp')),
    );
    expect(tester.takeException(), isNull);
  });
}
