import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../i18n/app_language.dart';
import '../i18n/strings.dart';
import '../theme/palette.dart';
import '../theme/theme_controller.dart';
import 'section_layout.dart';

/// The sections of the page, in the order they are stacked — the nav renders
/// one item per value and [Home] anchors one section to each.
enum SiteSection { about, synapseOs, contact }

/// Width of the desktop side rail.
const double kRailWidth = 76;

/// The section's name in the HUD nav. They read the same in both languages
/// (terminal-style identifiers), so this takes no language.
String navLabel(SiteSection section) => switch (section) {
  SiteSection.about => 'MAINFRAME',
  SiteSection.synapseOs => 'SYNAPSE',
  SiteSection.contact => 'COMMS',
};

/// "00", "01"... — the section's index as shown in the nav.
String navNumber(SiteSection section) =>
    section.index.toString().padLeft(2, '0');

/// Desktop navigation: a black HUD rail down the left edge with the logo,
/// one numbered item per section and the language/theme toggles at the
/// bottom.
class SideRail extends StatelessWidget {
  const SideRail({super.key, required this.active, required this.onSelected});

  /// The section currently at the top of the viewport, highlighted in the nav.
  final ValueListenable<SiteSection> active;

  /// Called with the section the visitor asked to jump to.
  final ValueChanged<SiteSection> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    return Container(
      width: kRailWidth,
      decoration: BoxDecoration(
        color: palette.chrome,
        border: Border(right: BorderSide(color: palette.accentAlpha(0.6))),
      ),
      child: SafeArea(
        right: false,
        child: Column(
          children: [
            const SizedBox(height: 16),
            _Logo(onTap: () => onSelected(SiteSection.about)),
            const SizedBox(height: 20),
            ValueListenableBuilder<SiteSection>(
              valueListenable: active,
              builder: (context, current, _) => Column(
                children: [
                  for (final section in SiteSection.values)
                    _RailItem(
                      section,
                      selected: section == current,
                      onTap: () => onSelected(section),
                    ),
                ],
              ),
            ),
            const Spacer(),
            const _LanguageToggleButton(),
            const _ThemeToggleButton(),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _RailItem extends StatefulWidget {
  const _RailItem(this.section, {required this.selected, required this.onTap});

  final SiteSection section;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_RailItem> createState() => _RailItemState();
}

class _RailItemState extends State<_RailItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    final color = widget.selected
        ? palette.accent
        : palette.ink.withValues(alpha: _hovering ? 0.9 : 0.5);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: widget.selected ? palette.accentAlpha(0.08) : null,
            border: Border(
              left: BorderSide(
                width: 3,
                color: widget.selected ? palette.accent : Colors.transparent,
              ),
            ),
          ),
          child: Column(
            children: [
              Text(
                navNumber(widget.section),
                style: monoStyle(
                  size: 15,
                  color: color,
                  weight: widget.selected || _hovering
                      ? FontWeight.w800
                      : FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                navLabel(widget.section),
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.fade,
                style: monoStyle(size: 8, color: color, letterSpacing: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Phone navigation: a black bar across the top with the logo, toggles and a
/// menu button, and a sideways-scrolling jump bar of numbered section chips
/// underneath.
class PhoneHeader extends StatelessWidget {
  const PhoneHeader({
    super.key,
    required this.active,
    required this.onSelected,
  });

  final ValueListenable<SiteSection> active;
  final ValueChanged<SiteSection> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.chrome,
        border: Border(bottom: BorderSide(color: palette.accentAlpha(0.6))),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 56,
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 4),
                child: Row(
                  children: [
                    _Logo(onTap: () => onSelected(SiteSection.about)),
                    const SizedBox(width: 10),
                    // Takes whatever the toggles leave, so a large system
                    // font shortens the name instead of pushing the toggles
                    // off the edge.
                    Expanded(
                      child: Text(
                        'SR_NEURAL_OS',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: monoStyle(
                          size: 12,
                          color: palette.ink,
                          weight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const _LanguageToggleButton(),
                    const _ThemeToggleButton(),
                    const _MenuButton(),
                  ],
                ),
              ),
            ),
            _JumpBar(active: active, onSelected: onSelected),
          ],
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: palette.accent,
            borderRadius: BorderRadius.circular(kHudButtonRadius),
          ),
          child: Text(
            'SR',
            style: monoStyle(
              size: 14,
              color: palette.onAccent,
              weight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

/// Hamburger button shown on phone-sized screens. Opens the [NavDrawer]
/// registered on the enclosing [Scaffold] (see `Home`).
class _MenuButton extends StatelessWidget {
  const _MenuButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.menu, color: paletteOf(context).ink),
      tooltip: stringsOf(context).openNavigation,
      onPressed: () => Scaffold.of(context).openDrawer(),
    );
  }
}

/// Sun/moon switch — tapping it flips [ThemeController.isDark] for the whole
/// site. The icon shown is the mode a tap switches *to*, not the current one
/// (a sun while dark, a moon while light).
class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton();

  @override
  Widget build(BuildContext context) {
    final controller = AppTheme.of(context);
    final palette = paletteOf(context);
    final s = stringsOf(context);
    return IconButton(
      icon: Icon(
        controller.isDark
            ? Icons.light_mode_outlined
            : Icons.dark_mode_outlined,
        color: palette.ink.withValues(alpha: 0.8),
        size: 20,
      ),
      tooltip: controller.isDark ? s.switchToLightMode : s.switchToDarkMode,
      onPressed: controller.toggle,
    );
  }
}

/// EN/FR switch. Follows the same "shows the mode a tap switches *to*"
/// convention as the theme button: the label reads the language you'd get by
/// tapping, not the current one.
class _LanguageToggleButton extends StatelessWidget {
  const _LanguageToggleButton();

  @override
  Widget build(BuildContext context) {
    final controller = AppLocale.of(context);
    final palette = paletteOf(context);
    final s = stringsOf(context);
    final togglesToFrench = controller.language == AppLanguage.en;
    return IconButton(
      icon: Text(
        togglesToFrench ? 'FR' : 'EN',
        style: monoStyle(
          size: 12,
          color: palette.ink.withValues(alpha: 0.8),
          weight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
      tooltip: togglesToFrench ? s.switchToFrench : s.switchToEnglish,
      onPressed: controller.toggle,
    );
  }
}

/// Phone-only strip of numbered section chips under the top bar.
class _JumpBar extends StatelessWidget {
  const _JumpBar({required this.active, required this.onSelected});

  final ValueListenable<SiteSection> active;
  final ValueChanged<SiteSection> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: palette.surface(0.08))),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: ValueListenableBuilder<SiteSection>(
          valueListenable: active,
          builder: (context, current, _) => Row(
            children: [
              for (final section in SiteSection.values) ...[
                if (section.index > 0) const SizedBox(width: 8),
                _JumpChip(
                  section,
                  selected: section == current,
                  onTap: () => onSelected(section),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _JumpChip extends StatelessWidget {
  const _JumpChip(this.section, {required this.selected, required this.onTap});

  final SiteSection section;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    final style = monoStyle(
      size: 11,
      color: selected ? palette.onAccent : palette.ink,
      weight: selected ? FontWeight.w800 : FontWeight.w500,
      letterSpacing: 0.6,
    );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? palette.accent : null,
          borderRadius: BorderRadius.circular(kHudButtonRadius),
          border: selected ? null : Border.all(color: palette.surface(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${navNumber(section)} ', style: style),
            Text(navLabel(section), style: style),
          ],
        ),
      ),
    );
  }
}

/// Phone-size nav drawer: the same numbered sections as the rail, laid out as
/// a vertical list. Opened via the hamburger [_MenuButton] and registered as
/// `Scaffold.drawer` by `Home`.
class NavDrawer extends StatelessWidget {
  const NavDrawer({super.key, required this.onSelected});

  /// Called with the section the visitor tapped; the drawer is already
  /// closed by the time this fires.
  final ValueChanged<SiteSection> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    return Drawer(
      backgroundColor: palette.chrome,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 28),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: MonoLabel('NAV_HUD'),
            ),
            const SizedBox(height: 8),
            for (final section in SiteSection.values)
              ListTile(
                leading: Text(
                  navNumber(section),
                  style: monoStyle(
                    size: 14,
                    color: palette.accent,
                    weight: FontWeight.w800,
                  ),
                ),
                title: Text(
                  navLabel(section),
                  style: monoStyle(
                    size: 16,
                    color: palette.ink,
                    weight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  onSelected(section);
                },
              ),
          ],
        ),
      ),
    );
  }
}
