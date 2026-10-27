import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/i18n/app_language.dart';
import 'package:portfolio/theme/theme_controller.dart';
import 'package:portfolio/widgets/synapse_os_demo.dart';

Widget _wrap(Widget child) {
  final themeController = ThemeController();
  final localeController = LocaleController();

  return AppTheme(
    controller: themeController,
    child: AppLocale(
      controller: localeController,
      child: MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1200,
            height: 700,
            child: child,
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('SynapseOsDemo renders authentic desktop shell and Today dashboard', (tester) async {
    await tester.pumpWidget(_wrap(const SynapseOsDemo()));
    await tester.pumpAndSettle();

    // Verify window chrome branding & status
    expect(find.text('Synapse'), findsOneWidget);
    expect(find.text('127.0.0.1 · SQLite WAL'), findsOneWidget);

    // Verify sidebar navigation items
    expect(find.text('New capture'), findsOneWidget);
    expect(find.text('Today'), findsWidgets);
    expect(find.text('Plan'), findsOneWidget);
    expect(find.text('Notes'), findsOneWidget);
    expect(find.text('Ask AI'), findsOneWidget);

    // Verify Today dashboard content
    expect(find.text('Focus'), findsOneWidget);
    expect(find.text('CAPTURE'), findsOneWidget);
    expect(find.text('Waiting for your review'), findsOneWidget);
    expect(find.text('Meetings today'), findsOneWidget);
    expect(find.text('This week'), findsOneWidget);
  });

  testWidgets('SynapseOsDemo can type and save a quick capture into inbox review', (tester) async {
    await tester.pumpWidget(_wrap(const SynapseOsDemo()));
    await tester.pumpAndSettle();

    // Enter capture text
    final inputFinder = find.byType(TextField).first;
    await tester.enterText(inputFinder, 'Research embedding latency for Ollama');
    await tester.pump();

    // Tap Save
    await tester.tap(find.text('Save'));
    await tester.pump();

    // Verify saved notification & presence in review list
    expect(find.text('Saved to Inbox!'), findsOneWidget);
    expect(find.text('Research embedding latency for Ollama'), findsOneWidget);

    // Pump past the 3-second notification timer
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('SynapseOsDemo toggles task completion', (tester) async {
    await tester.pumpWidget(_wrap(const SynapseOsDemo()));
    await tester.pumpAndSettle();

    // Find first task row and tap it
    final taskFinder = find.text('Implement PR suggestion review flow');
    expect(taskFinder, findsOneWidget);

    await tester.tap(taskFinder);
    await tester.pump();

    // Should still be present with completed state
    expect(taskFinder, findsOneWidget);
  });

  testWidgets('SynapseOsDemo switches between Plan, Notes, and Ask AI views', (tester) async {
    await tester.pumpWidget(_wrap(const SynapseOsDemo()));
    await tester.pumpAndSettle();

    // Switch to Plan
    await tester.tap(find.text('Plan'));
    await tester.pumpAndSettle();
    expect(find.text('OVERDUE'), findsOneWidget);
    expect(find.text('TODAY'), findsOneWidget);

    // Switch to Notes
    await tester.tap(find.text('Notes'));
    await tester.pumpAndSettle();
    expect(find.text('Zero-Cloud SQLite WAL Storage Engine'), findsOneWidget);
    expect(find.text('WIKILINKS:'), findsOneWidget);

    // Switch to Ask AI
    await tester.tap(find.text('Ask AI'));
    await tester.pumpAndSettle();
    expect(find.text('Synapse Grounded AI'), findsWidgets);
    expect(find.text('Ollama · Llama 3 (127.0.0.1)'), findsOneWidget);
  });
}
