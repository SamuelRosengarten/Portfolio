import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/main.dart';

/// People who raise their system font size must still be able to read every
/// section without anything painting outside its box. A section is allowed to
/// scroll (SectionShell falls back to that), but must not overflow.
void main() {
  for (final scale in [1.3, 1.6, 2.0]) {
    for (final size in [
      const Size(390, 844),
      const Size(768, 1024),
      const Size(1400, 1000),
    ]) {
      testWidgets(
        'no overflow at ${size.width.toInt()}x${size.height.toInt()} with text at ${scale}x',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

          await tester.pumpWidget(const MyApp());
          await tester.pump(const Duration(milliseconds: 700));
          expect(tester.takeException(), isNull, reason: 'About (initial)');

          final mobile = size.width < 600;
          for (final label in ['Projects', 'Hobbies', 'Contact', 'About']) {
            if (mobile) {
              await tester.tap(find.byIcon(Icons.menu));
              await tester.pump();
              await tester.pump(const Duration(milliseconds: 300));
            }
            await tester.tap(find.text(label).first);
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 700));
            expect(
              tester.takeException(),
              isNull,
              reason: '$label at ${scale}x',
            );
          }
          await tester.pump(const Duration(milliseconds: 700));
        },
      );
    }
  }
}
