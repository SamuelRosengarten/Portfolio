import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import '../theme/palette.dart';
import '../widgets/section_layout.dart';

class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    final s = stringsOf(context);
    final phone = isPhone(context);
    final width = MediaQuery.sizeOf(context).width;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: palette.altBg,
        border: Border(top: BorderSide(color: palette.surface(0.06))),
      ),
      child: Column(
        children: [
          PageSection(
            topPadding: phone ? 56 : null,
            bottomPadding: phone ? 32 : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionHeading(
                  eyebrow: 'Contact',
                  headline: s.contactHeadline,
                  subhead: s.contactSubhead,
                ),
                SizedBox(height: phone ? 24 : 40),
                _ContactCards(
                  entries: [
                    _Entry(
                      icon: Icons.mail_outline_rounded,
                      label: 'Email',
                      value: 'samrosengarten2@pm.me',
                    ),
                    const _Entry(
                      icon: Icons.code_rounded,
                      label: 'GitHub',
                      value: 'github.com/SamuelRosengarten',
                      phoneValue: 'SamuelRosengarten',
                    ),
                    const _Entry(
                      icon: Icons.work_outline_rounded,
                      label: 'LinkedIn',
                      value: 'linkedin.com/in/samuel-rosengarten',
                      phoneValue: 'samuel-rosengarten',
                    ),
                    _Entry(
                      icon: Icons.place_outlined,
                      label: s.locationLabel,
                      value: 'Longueuil, QC',
                      outlined: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Footer rule and line.
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  pageGutter(width),
                  0,
                  pageGutter(width),
                  phone ? 32 : 40,
                ),
                child: Container(
                  padding: EdgeInsets.only(top: phone ? 20 : 28),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: palette.surface(0.08))),
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      Text(
                        '© 2026 Samuel Rosengarten',
                        style: interStyle(
                          size: phone ? 12 : 13,
                          color: palette.tertiary,
                        ),
                      ),
                      Text(
                        s.builtWithFlutter,
                        style: monoStyle(
                          size: phone ? 12 : 13,
                          color: palette.tertiary,
                        ),
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

class _Entry {
  const _Entry({
    required this.icon,
    required this.label,
    required this.value,
    this.phoneValue,
    this.outlined = false,
  });

  final IconData icon;
  final String label;
  final String value;

  /// A shorter form of [value] for the narrow phone list.
  final String? phoneValue;

  /// Dashed, transparent card for info that isn't a link (the location).
  final bool outlined;
}

class _ContactCards extends StatelessWidget {
  const _ContactCards({required this.entries});

  final List<_Entry> entries;

  @override
  Widget build(BuildContext context) {
    if (isPhone(context)) {
      return _PhoneList(entries: entries);
    }
    return AutoFitGrid(
      minItemWidth: 250,
      spacing: 14,
      children: [for (final e in entries) _ContactCard(entry: e)],
    );
  }
}

class _ContactCard extends StatefulWidget {
  const _ContactCard({required this.entry});

  final _Entry entry;

  @override
  State<_ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends State<_ContactCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    final entry = widget.entry;
    final outlined = entry.outlined;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        constraints: const BoxConstraints(minHeight: 120),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : palette.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: palette.surface(
              outlined ? 0.16 : (_hovering ? 0.28 : 0.08),
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              entry.icon,
              size: 22,
              color: outlined ? palette.tertiary : palette.accent,
            ),
            const SizedBox(height: 18),
            Text(
              entry.label,
              style: interStyle(size: 13, color: palette.tertiary),
            ),
            const SizedBox(height: 4),
            Text(
              entry.value,
              style: interStyle(
                size: 15,
                color: palette.ink,
                weight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Phone: one rounded container holding a row per contact method.
class _PhoneList extends StatelessWidget {
  const _PhoneList({required this.entries});

  final List<_Entry> entries;

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.surface(0.08)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < entries.length; i++)
            Container(
              constraints: const BoxConstraints(minHeight: 64),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: i == entries.length - 1
                    ? null
                    : Border(bottom: BorderSide(color: palette.surface(0.08))),
              ),
              child: Row(
                children: [
                  Icon(
                    entries[i].icon,
                    size: 22,
                    color: entries[i].outlined ? palette.tertiary : palette.accent,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entries[i].label,
                          style: interStyle(size: 12, color: palette.tertiary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          entries[i].phoneValue ?? entries[i].value,
                          style: interStyle(
                            size: 15,
                            color: palette.ink,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
