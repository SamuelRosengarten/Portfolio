import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/main.dart';
import 'package:portfolio/widgets/link_target.dart';

/// The link the keyboard focus is currently inside, if any.
Uri? _focusedLink() {
  final context = FocusManager.instance.primaryFocus?.context;
  if (context == null) return null;
  Uri? found;
  context.visitAncestorElements((element) {
    final widget = element.widget;
    if (widget is LinkTarget) {
      found = widget.uri;
      return false;
    }
    return true;
  });
  return found;
}

Future<void> _openSection(WidgetTester tester, String label) async {
  tester.view.physicalSize = const Size(1400, 1000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const MyApp());
  await tester.pump(const Duration(milliseconds: 700));
  await tester.tap(find.text(label));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 700));
}

/// Tabs through the page and returns every distinct link that got focus.
Future<List<Uri>> _tabThroughLinks(WidgetTester tester) async {
  final seen = <Uri>[];
  for (var i = 0; i < 40; i++) {
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    final link = _focusedLink();
    if (link != null && !seen.contains(link)) seen.add(link);
  }
  return seen;
}

void main() {
  late List<Uri> opened;
  late Future<bool> Function(Uri) original;

  setUp(() {
    opened = [];
    original = openUrl;
    openUrl = (uri) async {
      opened.add(uri);
      return true;
    };
  });
  tearDown(() => openUrl = original);

  testWidgets('contact cards can be reached with Tab and opened with Enter', (
    tester,
  ) async {
    await _openSection(tester, 'Contact');

    // The whole page is one scroll, so the project buttons come first in tab
    // order; the contact cards are the mailto link and the two profiles.
    final contactLinks = {
      Uri(scheme: 'mailto', path: 'samrosengarten2@pm.me'),
      Uri.parse('https://github.com/SamuelRosengarten'),
      Uri.parse('https://linkedin.com/in/samuel-rosengarten'),
    };
    final links = (await _tabThroughLinks(tester))
        .where(contactLinks.contains)
        .toList();
    expect(links, contactLinks.toList());

    // Tabbing ended on or past the last card; walk back to the first one and
    // open it from the keyboard.
    for (var i = 0; i < 40 && _focusedLink() != links.first; i++) {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();
    }
    expect(_focusedLink(), links.first);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(opened, [links.first]);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(opened, [links.first, links.first]);
  });

  testWidgets('tapping a contact card opens its link', (tester) async {
    await _openSection(tester, 'Contact');
    await tester.tap(find.text('github.com/SamuelRosengarten'));
    await tester.pump();
    expect(opened, [Uri.parse('https://github.com/SamuelRosengarten')]);
  });

  testWidgets('contact cards are announced as links with their value', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _openSection(tester, 'Contact');
    for (final label in [
      'Email: samrosengarten2@pm.me',
      'GitHub: github.com/SamuelRosengarten',
      'LinkedIn: linkedin.com/in/samuel-rosengarten',
    ]) {
      final node = tester.getSemantics(find.bySemanticsLabel(label));
      expect(
        node,
        isSemantics(label: label, isLink: true, hasTapAction: true),
        reason: label,
      );
    }
    // Location is information, not a link.
    expect(
      find.bySemanticsLabel(RegExp('^Email|^GitHub|^LinkedIn')),
      findsNWidgets(3),
    );
    handle.dispose();
  });

  testWidgets('the project buttons are keyboard links too', (tester) async {
    await _openSection(tester, 'Projects');
    final links = await _tabThroughLinks(tester);
    expect(
      links,
      containsAll([
        Uri.parse(
          'https://marketplace.visualstudio.com/items?itemName=samuelrosengarten.code-coach-ai',
        ),
        Uri.parse('https://github.com/SamuelRosengarten/code-coach'),
      ]),
    );
  });
}
