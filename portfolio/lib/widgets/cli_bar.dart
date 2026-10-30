import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import '../theme/palette.dart';
import 'link_target.dart';
import 'section_layout.dart';

/// The terminal strip pinned to the bottom of the page: a prompt with a
/// blinking cursor and two "preset commands" — email and LinkedIn.
class CliBar extends StatelessWidget {
  const CliBar({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    final s = stringsOf(context);
    final phone = isPhone(context);
    // Room for the full prompt and status text beside both buttons.
    final wide = MediaQuery.sizeOf(context).width >= 1100;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.chrome,
        border: Border(top: BorderSide(color: palette.accentAlpha(0.6))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: phone ? 12 : 20,
            vertical: 6,
          ),
          child: Row(
            children: [
              Text(
                wide ? 'root@quebec_dev_node:~#' : '~#',
                style: monoStyle(
                  size: 12,
                  color: palette.ok,
                  weight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 10),
              if (wide)
                Flexible(
                  child: Text(
                    s.cliReady,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: monoStyle(size: 12, color: palette.tertiary),
                  ),
                ),
              const _BlinkingCursor(),
              const SizedBox(width: 12),
              if (!phone) const Spacer(),
              // Flexible (loose) so a large system font shrinks the buttons
              // instead of pushing them off the edge.
              Flexible(
                child: _CliCommand(
                  label: phone ? 'RECRUIT_ME' : 'RUN RECRUIT_ME.SH',
                  semanticLabel: s.cliEmailLabel,
                  uri: Uri(
                    scheme: 'mailto',
                    path: 'samrosengarten1@gmail.com',
                    query: 'subject=Internship',
                  ),
                  primary: true,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: _CliCommand(
                  label: phone ? 'LINKEDIN' : 'PING LINKEDIN',
                  semanticLabel: s.cliLinkedInLabel,
                  uri: Uri.parse('https://linkedin.com/in/samuel-rosengarten'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One of the bar's two link buttons: filled yellow when [primary],
/// outlined otherwise.
class _CliCommand extends StatelessWidget {
  const _CliCommand({
    required this.label,
    required this.semanticLabel,
    required this.uri,
    this.primary = false,
  });

  final String label;
  final String semanticLabel;
  final Uri uri;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return LinkTarget(
      uri: uri,
      semanticLabel: semanticLabel,
      builder: (context, highlighted) {
        final palette = paletteOf(context);
        final fg = primary
            ? palette.onAccent
            : (highlighted ? palette.accent : palette.ink);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          constraints: const BoxConstraints(minHeight: 34),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: primary
                ? (highlighted
                      ? Color.lerp(palette.accent, Colors.white, 0.25)
                      : palette.accent)
                : (highlighted ? palette.accentAlpha(0.08) : null),
            borderRadius: BorderRadius.circular(kHudButtonRadius),
            border: primary
                ? null
                : Border.all(
                    color: highlighted ? palette.accent : palette.ink,
                  ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: monoStyle(
                    size: 11.5,
                    color: fg,
                    weight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
              if (primary) ...[
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 14, color: fg),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor();

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late final _blink = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void initState() {
    super.initState();
    // Only the web build (the one that ships) blinks: widget tests run on the
    // VM, where an endlessly repeating animation would keep `pumpAndSettle`
    // from ever settling.
    if (kIsWeb) _blink.repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) _blink.stop();
  }

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _blink,
        builder: (context, _) => Opacity(
          opacity: _blink.value < 0.5 ? 1 : 0,
          child: Container(width: 8, height: 14, color: palette.accent),
        ),
      ),
    );
  }
}
