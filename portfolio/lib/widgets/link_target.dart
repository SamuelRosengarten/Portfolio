import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens [uri] outside the app. A top-level hook rather than a direct
/// `launchUrl` call so widget tests can replace it and check where a link
/// goes without needing a platform plugin.
Future<bool> Function(Uri uri) openUrl = (uri) => launchUrl(uri);

/// Makes [builder]'s content a link that works with a pointer, the keyboard
/// and screen readers.
///
/// A bare `GestureDetector` only answers taps: Tab skips it, Enter does
/// nothing, and a screen reader hears no more than the text inside it. This
/// adds all three: it takes keyboard focus, activates on Enter or Space,
/// reports itself to assistive technology as a link named [semanticLabel],
/// and tells [builder] whether the pointer is over it or it has focus so the
/// content can show a highlight for either.
class LinkTarget extends StatefulWidget {
  const LinkTarget({
    super.key,
    required this.uri,
    required this.semanticLabel,
    required this.builder,
  });

  final Uri uri;
  final String semanticLabel;

  /// Builds the visible content. [highlighted] is true while the pointer is
  /// over the link or it has keyboard focus.
  final Widget Function(BuildContext context, bool highlighted) builder;

  @override
  State<LinkTarget> createState() => _LinkTargetState();
}

class _LinkTargetState extends State<LinkTarget> {
  bool _hovering = false;
  bool _focused = false;

  void _activate() => openUrl(widget.uri);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      link: true,
      label: widget.semanticLabel,
      onTap: _activate,
      excludeSemantics: true,
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        onShowHoverHighlight: (v) => setState(() => _hovering = v),
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _activate();
              return null;
            },
          ),
        },
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _activate,
          child: widget.builder(context, _hovering || _focused),
        ),
      ),
    );
  }
}
