import 'package:flutter/material.dart';

/// Device frames for the Synapse OS screenshots, drawn to match the
/// "Device / iPhone 16 Pro" and "Device / Mac window" components in the Figma
/// file (https://www.figma.com/design/OGWIDIf19lEsgXTltUo4sq, page "Synapse
/// OS — devices"). They are drawn here instead of exported as flat images so
/// the shadows stay transparent over both site themes and each frame stays
/// sharp at any width. The screens themselves are the 2x renders from the
/// app's own design file ("Synapse native apps — design pass").

/// An iPhone 16 Pro: dark bezel, rounded screen and a Dynamic Island. The
/// frame is [width] wide and 898/426 of that tall, like the Figma component.
class IPhoneFrame extends StatelessWidget {
  const IPhoneFrame({
    super.key,
    required this.asset,
    required this.width,
    required this.semanticLabel,
    this.shadow = true,
  });

  /// A 402×874 screen (at 2x) from `assets/synapse/`.
  final String asset;
  final double width;
  final String semanticLabel;
  final bool shadow;

  static const double aspect = 426 / 898;

  @override
  Widget build(BuildContext context) {
    final k = width / 426;
    return Semantics(
      image: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: Container(
        width: width,
        height: width / aspect,
        padding: EdgeInsets.all(12 * k),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1E24),
          borderRadius: BorderRadius.circular(70 * k),
          border: Border.all(color: const Color(0xFF3B414C), width: 2 * k),
          boxShadow: shadow
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.38),
                    offset: Offset(0, 36 * k),
                    blurRadius: 80 * k,
                    spreadRadius: -12 * k,
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(58 * k),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                asset,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: EdgeInsets.only(top: 11 * k),
                  width: 122 * k,
                  height: 36 * k,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(18 * k),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A macOS window: the screenshot already holds the traffic lights and the
/// sidebar, so the frame only rounds the corners, adds a hairline and lifts
/// it with a shadow.
class MacWindow extends StatelessWidget {
  const MacWindow({
    super.key,
    required this.asset,
    required this.width,
    required this.semanticLabel,
    this.aspect = 1280 / 800,
  });

  final String asset;
  final double width;
  final String semanticLabel;

  /// Width over height of the screenshot (1280×800 for Today, 1180×760 for
  /// team chat).
  final double aspect;

  @override
  Widget build(BuildContext context) {
    final k = width / 1280;
    final radius = (14 * k).clamp(6.0, 14.0);
    return Semantics(
      image: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: Container(
        width: width,
        height: width / aspect,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.42),
              offset: Offset(0, 44 * k),
              blurRadius: 110 * k,
              spreadRadius: -18 * k,
            ),
          ],
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Image.asset(
            asset,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
          ),
        ),
      ),
    );
  }
}

/// The hero shot from the Figma composite "Export / Synapse hero": the Mac
/// window at the back, an iPhone overlapping its bottom-right corner. The
/// whole group is laid out on the composite's 1520×1060 canvas and scaled to
/// [width].
class MacAndPhone extends StatelessWidget {
  const MacAndPhone({
    super.key,
    required this.width,
    required this.macAsset,
    required this.phoneAsset,
    required this.semanticLabel,
  });

  final double width;
  final String macAsset;
  final String phoneAsset;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final k = width / 1520;
    final phoneWidth = 426 * 0.84 * k;
    final phoneHeight = phoneWidth / IPhoneFrame.aspect;
    return Semantics(
      image: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: SizedBox(
        width: width,
        height: 1060 * k,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              top: 40 * k,
              child: MacWindow(
                asset: macAsset,
                width: 1280 * k,
                semanticLabel: '',
              ),
            ),
            Positioned(
              left: width - phoneWidth - 6 * k,
              top: 1060 * k - phoneHeight - 6 * k,
              child: IPhoneFrame(
                asset: phoneAsset,
                width: phoneWidth,
                semanticLabel: '',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
