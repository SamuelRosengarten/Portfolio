import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/main.dart';

/// Widths from a small phone to a wide desktop. Layout overflow shows up as a
/// FlutterError, which the test binding records and [takeException] returns —
/// the whole page is laid out inside one scroll view, so a single pump covers
/// every section.
const _sizes = <String, Size>{
  'small phone': Size(360, 740),
  'phone': Size(390, 844),
  'large phone': Size(430, 932),
  'tablet portrait': Size(768, 1024),
  'laptop': Size(1024, 768),
  'desktop': Size(1440, 900),
  'wide desktop': Size(2200, 1200),
};

void main() {
  for (final entry in _sizes.entries) {
    for (final french in [false, true]) {
      testWidgets(
        '${entry.key} (${entry.value.width.toInt()}px, ${french ? 'FR' : 'EN'}): '
        'lays out without overflow in both themes',
        (tester) async {
          tester.view.physicalSize = entry.value;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);

          await tester.pumpWidget(const MyApp());
          await tester.pump();

          if (french) {
            await tester.tap(find.byTooltip('Passer au français'));
            await tester.pump();
          }
          expect(tester.takeException(), isNull, reason: 'dark mode');

          await tester.tap(
            find.byTooltip(
              french ? 'Passer au mode clair' : 'Switch to light mode',
            ),
          );
          await tester.pump();
          expect(tester.takeException(), isNull, reason: 'light mode');
        },
      );
    }
  }

  testWidgets('phone: the menu drawer scrolls to a section', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MyApp());
    await tester.pump();

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Contact').last);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text("Let's talk."), findsOneWidget);
  });
}
