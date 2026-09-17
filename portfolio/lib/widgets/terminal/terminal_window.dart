import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'terminal_view.dart';

class TerminalWindow extends StatelessWidget {
  const TerminalWindow({
    super.key,
    this.width,
    this.height,
    this.autofocus = false,
  });

  /// Explicit size; when null the window sizes itself from the screen.
  final double? width;
  final double? height;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final resolvedWidth =
        width ??
        (screen.width < 700 ? screen.width * 0.92 : 680.0).clamp(280.0, 680.0);
    final resolvedHeight =
        height ??
        (screen.height < 700 ? screen.height * 0.70 : 460.0).clamp(
          320.0,
          520.0,
        );

    return SizedBox(
      width: resolvedWidth,
      height: resolvedHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              children: [
                const _TitleBar(),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0x14FFFFFF),
                ),
                Expanded(child: TerminalView(autofocus: autofocus)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TitleBar extends StatelessWidget {
  const _TitleBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 12,
            child: Row(
              children: const [
                _TrafficLight(color: Color(0xFFFF5F56), glyph: '×'),
                SizedBox(width: 8),
                _TrafficLight(color: Color(0xFFFFBD2E), glyph: '−'),
                SizedBox(width: 8),
                _TrafficLight(color: Color(0xFF27C93F), glyph: '+'),
              ],
            ),
          ),
          Text(
            '~/portfolio',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrafficLight extends StatefulWidget {
  const _TrafficLight({required this.color, required this.glyph});

  final Color color;
  final String glyph;

  @override
  State<_TrafficLight> createState() => _TrafficLightState();
}

class _TrafficLightState extends State<_TrafficLight> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(-0.3, -0.35),
            radius: 1.1,
            colors: [
              Color.lerp(widget.color, Colors.white, 0.35)!,
              widget.color,
            ],
          ),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.15),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 1,
              offset: const Offset(0, 0.5),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: AnimatedOpacity(
          opacity: _hovering ? 1 : 0,
          duration: const Duration(milliseconds: 120),
          child: Text(
            widget.glyph,
            style: const TextStyle(
              fontSize: 9,
              height: 1,
              color: Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
