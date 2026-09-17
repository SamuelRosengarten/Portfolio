import 'terminal_command.dart';

/// Registry of available terminal commands.
///
/// To add a new command later, add another entry here — nothing else
/// needs to change.
final Map<String, TerminalCommand> kTerminalCommands = {
  'help': TerminalCommand(
    name: 'help',
    description: 'List available commands',
    handler: (args, rt) => kTerminalCommands.values
        .map((c) => '${c.name.padRight(10)} ${c.description}')
        .toList(),
  ),
  'whoami': TerminalCommand(
    name: 'whoami',
    description: 'Print a short identity blurb',
    handler: (args, rt) => const ['Samuel Rosengarten — software engineer.'],
  ),
  'about': TerminalCommand(
    name: 'about',
    description: 'Learn more about me',
    handler: (args, rt) => const [
      "Hi, I'm Samuel — I build software and enjoy working across the stack.",
      'Type "help" to see what else this terminal can do.',
    ],
  ),
  'clear': TerminalCommand(
    name: 'clear',
    description: 'Clear the terminal screen',
    handler: (args, rt) {
      rt.clear();
      return const [];
    },
  ),
};
