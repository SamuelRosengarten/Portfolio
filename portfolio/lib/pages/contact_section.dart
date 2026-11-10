import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import '../theme/palette.dart';
import '../widgets/link_target.dart';
import '../widgets/section_layout.dart';

/// "Let's talk." over the second temper bead, beside a ruled list of the ways
/// to reach me, then the footer line.
class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    final s = stringsOf(context);
    final phone = isPhone(context);
    final width = MediaQuery.sizeOf(context).width;

    final entries = [
      (
        'Email',
        'samrosengarten1@gmail.com',
        Icons.mail_outline_rounded,
        Uri(scheme: 'mailto', path: 'samrosengarten1@gmail.com'),
      ),
      (
        'GitHub',
        'github.com/SamuelRosengarten',
        Icons.code_rounded,
        Uri.parse('https://github.com/SamuelRosengarten'),
      ),
      (
        'LinkedIn',
        'linkedin.com/in/samuel-rosengarten',
        Icons.work_outline_rounded,
        Uri.parse('https://linkedin.com/in/samuel-rosengarten'),
      ),
      (s.locationLabel, 'Longueuil, QC', Icons.place_outlined, null),
    ];

    final intro = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FitHeadline(
          s.contactHeadline,
          size: (width * 0.09).clamp(64.0, 132.0),
          color: palette.ink,
        ),
        SizedBox(height: phone ? 20 : 26),
        TemperBead(width: phone ? 180 : 320),
        SizedBox(height: phone ? 22 : 28),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Text(
            s.contactSubhead,
            style: bodyStyle(
              size: phone ? 16 : 18,
              color: palette.secondary,
              height: 1.6,
            ),
          ),
        ),
      ],
    );

    final list = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (label, value, icon, url) in entries)
          _ContactRow(label: label, value: value, icon: icon, url: url),
      ],
    );

    return Container(
      width: double.infinity,
      color: palette.altBg,
      child: Column(
        children: [
          PageSection(
            bordered: true,
            topPadding: phone ? 64 : null,
            bottomPadding: phone ? 40 : 64,
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= 980) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(child: intro),
                      const SizedBox(width: 64),
                      SizedBox(width: 540, child: list),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    intro,
                    SizedBox(height: phone ? 32 : 48),
                    list,
                  ],
                );
              },
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  pageGutter(width),
                  0,
                  pageGutter(width),
                  phone ? 28 : 40,
                ),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(top: phone ? 18 : 22),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: palette.line)),
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      Text(
                        '© 2026 Samuel Rosengarten',
                        style: bodyStyle(size: 13.5, color: palette.tertiary),
                      ),
                      Text(
                        s.builtWithFlutter,
                        style: bodyStyle(size: 13.5, color: palette.tertiary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One contact method. Rows with a [url] are links: the value turns straw and
/// underlines on hover or keyboard focus, with an arrow at the end.
class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.label,
    required this.value,
    required this.icon,
    this.url,
  });

  final String label;
  final String value;
  final IconData icon;
  final Uri? url;

  @override
  Widget build(BuildContext context) {
    final url = this.url;
    if (url == null) return _row(context, active: false);
    return LinkTarget(
      uri: url,
      semanticLabel: '$label: $value',
      builder: (context, active) => _row(context, active: active),
    );
  }

  Widget _row(BuildContext context, {required bool active}) {
    final palette = paletteOf(context);
    final phone = isPhone(context);
    return Container(
      padding: EdgeInsets.symmetric(vertical: phone ? 16 : 20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: palette.line)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: palette.accent),
          const SizedBox(width: 14),
          SizedBox(
            width: phone ? 76 : 92,
            child: Text(
              label,
              style: bodyStyle(
                size: 14,
                color: palette.tertiary,
                weight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style:
                  bodyStyle(
                    size: phone ? 15 : 18,
                    color: active ? palette.accent : palette.ink,
                    weight: FontWeight.w600,
                  ).copyWith(
                    decoration: active ? TextDecoration.underline : null,
                    decorationColor: palette.accent,
                  ),
            ),
          ),
          if (url != null) ...[
            const SizedBox(width: 12),
            Icon(
              Icons.north_east_rounded,
              size: 18,
              color: active ? palette.accent : palette.tertiary,
            ),
          ],
        ],
      ),
    );
  }
}
