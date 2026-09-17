import 'package:flutter/foundation.dart';

/// Handles a command invocation and returns the lines to print as output.
typedef CommandHandler = List<String> Function(
  List<String> args,
  TerminalRuntime runtime,
);

class TerminalCommand {
  const TerminalCommand({
    required this.name,
    required this.description,
    required this.handler,
  });

  final String name;
  final String description;
  final CommandHandler handler;
}

/// Small hook so commands (e.g. `clear`) can act on the terminal
/// without needing full access to its widget State.
class TerminalRuntime {
  const TerminalRuntime({required this.clear});

  final VoidCallback clear;
}
