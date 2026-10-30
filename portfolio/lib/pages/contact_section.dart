import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import '../theme/palette.dart';
import '../widgets/link_target.dart';
import '../widgets/section_layout.dart';

class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    final s = stringsOf(context);
    final phone = isPhone(context);
    return PageSection(
      background: palette.altBg,
      bordered: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeading(
            module: 'MOD_02',
            eyebrow: s.commsKicker,
            headline: s.contactHeadline,
            subhead: s.contactSubhead,
          ),
          SizedBox(height: phone ? 24 : 40),
          _ContactCards(
            entries: [
              _Entry(
                icon: Icons.mail_outline_rounded,
                code: 'EMAIL_RELAY',
                label: 'Email',
                value: 'samrosengarten1@gmail.com',
                url: Uri(scheme: 'mailto', path: 'samrosengarten1@gmail.com'),
              ),
              _Entry(
                icon: Icons.code_rounded,
                code: 'GITHUB_UPLINK',
                label: 'GitHub',
                value: 'github.com/SamuelRosengarten',
                url: Uri.parse('https://github.com/SamuelRosengarten'),
                phoneValue: 'SamuelRosengarten',
              ),
              _Entry(
                icon: Icons.work_outline_rounded,
                code: 'LINKEDIN_NODE',
                label: 'LinkedIn',
                value: 'linkedin.com/in/samuel-rosengarten',
                url: Uri.parse('https://linkedin.com/in/samuel-rosengarten'),
                phoneValue: 'samuel-rosengarten',
              ),
              _Entry(
                icon: Icons.place_outlined,
                code: 'NODE_LOCATION',
                label: s.locationLabel,
                value: 'Longueuil, QC',
              ),
            ],
          ),
          SizedBox(height: phone ? 20 : 32),
          Container(
            padding: EdgeInsets.only(top: phone ? 16 : 24),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: palette.surface(0.08))),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 12,
              runSpacing: 12,
              children: [
                MonoLabel(
                  '© ${DateTime.now().year} SAMUEL ROSENGARTEN // SR_NEURAL_OS',
                  color: palette.tertiary,
                  size: phone ? 10.5 : 11,
                ),
                MonoLabel(
                  s.builtWithFlutter.toUpperCase(),
                  color: palette.tertiary,
                  size: phone ? 10.5 : 11,
                ),
              ],
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
    required this.code,
    required this.label,
    required this.value,
    this.url,
    this.phoneValue,
  });

  final IconData icon;

  /// The terminal-style name shown on the card ("GITHUB_UPLINK"); [label] is
  /// the plain name screen readers announce.
  final String code;
  final String label;
  final String value;

  /// Where tapping the card goes (`mailto:` or a profile link); null for
  /// informational cards (Location), which stay unclickable.
  final Uri? url;

  /// A shorter form of [value] for the narrow phone list.
  final String? phoneValue;
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

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.entry});

  final _Entry entry;

  @override
  Widget build(BuildContext context) {
    final url = entry.url;
    if (url == null) return _card(context, false);
    // Hovering and keyboard focus share one highlight, supplied by LinkTarget.
    return LinkTarget(
      uri: url,
      semanticLabel: '${entry.label}: ${entry.value}',
      builder: _card,
    );
  }

  Widget _card(BuildContext context, bool highlighted) {
    final palette = paletteOf(context);
    final info = entry.url == null;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      constraints: const BoxConstraints(minHeight: 120),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: highlighted ? palette.accentAlpha(0.06) : palette.card,
        borderRadius: BorderRadius.circular(kHudRadius),
        border: Border.all(
          color: info
              ? palette.surface(0.16)
              : palette.accentAlpha(highlighted ? 1 : 0.32),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                entry.icon,
                size: 22,
                color: info ? palette.tertiary : palette.accent,
              ),
              if (!info)
                Icon(
                  Icons.arrow_outward_rounded,
                  size: 16,
                  color: palette.muted,
                ),
            ],
          ),
          const SizedBox(height: 18),
          MonoLabel(
            entry.code,
            color: info ? palette.tertiary : palette.accent,
            size: 11,
            weight: FontWeight.w700,
          ),
          const SizedBox(height: 4),
          _value(palette),
        ],
      ),
    );
  }

  /// A value with no natural break point (the email) shrinks to one line
  /// rather than splitting mid-word; paths wrap at their slashes.
  Widget _value(AppPalette palette) {
    final text = Text(
      entry.value,
      style: monoStyle(size: 13.5, color: palette.ink, weight: FontWeight.w600),
    );
    if (entry.value.contains('/') || entry.value.contains(' ')) return text;
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: text,
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
      decoration: hudDecoration(palette),
      child: Column(
        children: [
          for (var i = 0; i < entries.length; i++)
            _PhoneRow(entry: entries[i], last: i == entries.length - 1),
        ],
      ),
    );
  }
}

class _PhoneRow extends StatelessWidget {
  const _PhoneRow({required this.entry, required this.last});

  final _Entry entry;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final url = entry.url;
    if (url == null) return _row(context, false);
    return LinkTarget(
      uri: url,
      semanticLabel: '${entry.label}: ${entry.value}',
      builder: _row,
    );
  }

  Widget _row(BuildContext context, bool highlighted) {
    final palette = paletteOf(context);
    final info = entry.url == null;
    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: highlighted ? palette.accentAlpha(0.06) : null,
        border: last
            ? null
            : Border(bottom: BorderSide(color: palette.surface(0.08))),
      ),
      child: Row(
        children: [
          Icon(
            entry.icon,
            size: 22,
            color: info ? palette.tertiary : palette.accent,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MonoLabel(
                  entry.code,
                  color: info ? palette.tertiary : palette.accent,
                  size: 10.5,
                  weight: FontWeight.w700,
                ),
                const SizedBox(height: 3),
                Text(
                  entry.phoneValue ?? entry.value,
                  style: monoStyle(
                    size: 13.5,
                    color: palette.ink,
                    weight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (!info)
            Icon(Icons.chevron_right_rounded, size: 18, color: palette.muted),
        ],
      ),
    );
  }
}
