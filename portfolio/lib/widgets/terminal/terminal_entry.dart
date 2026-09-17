enum TerminalEntryKind { input, output, error }

class TerminalEntry {
  const TerminalEntry._(this.kind, this.text);

  factory TerminalEntry.input(String text) =>
      TerminalEntry._(TerminalEntryKind.input, text);
  factory TerminalEntry.output(String text) =>
      TerminalEntry._(TerminalEntryKind.output, text);
  factory TerminalEntry.error(String text) =>
      TerminalEntry._(TerminalEntryKind.error, text);

  final TerminalEntryKind kind;
  final String text;
}
