import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'commands.dart';
import 'terminal_command.dart';
import 'terminal_entry.dart';

const String _kPrompt = 'visitor@portfolio ~ % ';

class TerminalView extends StatefulWidget {
  const TerminalView({super.key});

  @override
  State<TerminalView> createState() => _TerminalViewState();
}

class _TerminalViewState extends State<TerminalView> {
  final List<TerminalEntry> _entries = [];
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _entries.add(TerminalEntry.output('Welcome to my portfolio terminal.'));
    _entries.add(TerminalEntry.output('Type "help" to see available commands.'));
  }

  @override
  void dispose() {
    _inputController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
      );
    });
  }

  void _handleSubmit(String raw) {
    final trimmed = raw.trim();
    _inputController.clear();
    if (trimmed.isEmpty) return;

    setState(() {
      _entries.add(TerminalEntry.input(trimmed));

      final parts = trimmed.split(RegExp(r'\s+'));
      final name = parts.first.toLowerCase();
      final args = parts.skip(1).toList();

      final command = kTerminalCommands[name];
      if (command == null) {
        _entries.add(
          TerminalEntry.error('command not found: $name — try "help"'),
        );
      } else {
        final runtime = TerminalRuntime(clear: () => _entries.clear());
        final output = command.handler(args, runtime);
        _entries.addAll(output.map(TerminalEntry.output));
      }
    });

    _scrollToBottom();
  }

  TextStyle _styleFor(TerminalEntryKind kind) {
    final base = GoogleFonts.jetBrainsMono(fontSize: 13, height: 1.5);
    switch (kind) {
      case TerminalEntryKind.input:
        return base.copyWith(color: const Color(0xFF27C93F));
      case TerminalEntryKind.output:
        return base.copyWith(color: Colors.white.withValues(alpha: 0.85));
      case TerminalEntryKind.error:
        return base.copyWith(color: const Color(0xFFFF5F56));
    }
  }

  Widget _buildInputRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(_kPrompt, style: _styleFor(TerminalEntryKind.input)),
          Expanded(
            child: TextField(
              controller: _inputController,
              focusNode: _focusNode,
              autofocus: true,
              autocorrect: false,
              enableSuggestions: false,
              cursorWidth: 8,
              cursorColor: Colors.white70,
              style: _styleFor(TerminalEntryKind.output),
              decoration: const InputDecoration.collapsed(hintText: ''),
              onSubmitted: _handleSubmit,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _focusNode.requestFocus(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _entries.length + 1,
          itemBuilder: (context, index) {
            if (index == _entries.length) {
              return _buildInputRow();
            }
            final entry = _entries[index];
            final text = entry.kind == TerminalEntryKind.input
                ? '$_kPrompt${entry.text}'
                : entry.text;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: Text(text, style: _styleFor(entry.kind)),
            );
          },
        ),
      ),
    );
  }
}
