import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/pages/hobbies_section.dart';
import 'package:portfolio/pages/home.dart';
import 'package:portfolio/pages/project_section.dart';
import 'package:portfolio/widgets/site_header.dart';

void main() {
  testWidgets('header items scroll to their section', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: Home()));
    await tester.pumpAndSettle();

    final scrollable = find.byType(Scrollable).first;
    final controller = tester.widget<Scrollable>(scrollable).controller!;
    expect(controller.offset, 0);

    for (final probe in {
      'Projects': find.byType(ProjectSection),
      'Hobbies': find.byType(HobbiesSection),
    }.entries) {
      await tester.tap(find.text(probe.key).first);
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(probe.value).dy,
        moreOrLessEquals(kSiteHeaderHeight, epsilon: 1),
        reason: probe.key,
      );
    }

    // The last section clamps at the bottom of the scroll extent.
    await tester.tap(find.text('Contact').first);
    await tester.pumpAndSettle();
    expect(controller.offset, controller.position.maxScrollExtent);

    await tester.tap(find.text('About').first);
    await tester.pumpAndSettle();
    expect(controller.offset, 0);
  });
}
