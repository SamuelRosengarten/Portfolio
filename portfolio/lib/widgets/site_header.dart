import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../i18n/app_language.dart';
import '../i18n/strings.dart';
import '../theme/palette.dart';
import '../theme/theme_controller.dart';
import 'section_layout.dart';

/// The sections of the page, in the order they are stacked — the header renders
/// one item per value and [Home] anchors one section to each.
enum SiteSection { about, projects, hobbies, contact }

/// [SiteSection]'s label is small, closed data tied one-to-one to the enum
/// itself, so it lives next to it as a plain switch rather than in the
/// shared [Strings] class — putting it there would need [Strings] to import
/// this file right back.
String navLabel(AppLanguage lang, SiteSection section) {
  final fr = lang == AppLanguage.fr;
  return switch (section) {
    SiteSection.about => fr ? 'À propos' : 'About',
    SiteSection.projects => fr ? 'Projets' : 'Projects',
    SiteSection.hobbies => fr ? 'Loisirs' : 'Hobbies',
    SiteSection.contact => 'Contact',
  };
}

/// Pinned header. On desktop: logo, centred section links and the language and
/// theme toggles in one row. On a phone: logo, toggles and a menu button, with
/// a horizontally scrolling jump bar of section pills underneath.
class SiteHeader extends StatelessWidget {
  const SiteHeader({
    super.key,
    required this.active,
    required this.onSelected,
  });

  /// The section currently at the top of the viewport, highlighted in the nav.
  final ValueListenable<SiteSection> active;

  /// Called with the section the visitor asked to jump to.
  final ValueChanged<SiteSection> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    final phone = isPhone(context);
    final width = MediaQuery.sizeOf(context).width;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.bg.withValues(alpha: 0.94),
        border: Border(bottom: BorderSide(color: palette.surface(0.08))),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: phone ? 16 : pageGutter(width),
                    right: phone ? 8 : pageGutter(width),
                  ),
                  child: SizedBox(
                    height: phone ? 60 : 64,
                    child: Row(
                      children: [
                        _Logo(phone: phone, onTap: () => onSelected(SiteSection.about)),
                        if (phone)
                          const Spacer()
                        else
                          Expanded(
                            child: _DesktopNav(
                              active: active,
                              onSelected: onSelected,
                            ),
                          ),
                        const _LanguageToggleButton(),
                        const _ThemeToggleButton(),
                        if (phone) const _MenuButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (phone)
              _JumpBar(active: active, onSelected: onSelected),
          ],
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.phone, required this.onTap});

  final bool phone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: phone ? 30 : 32,
              height: phone ? 30 : 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: palette.accent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'SR',
                style: monoStyle(
                  size: phone ? 12 : 13,
                  color: palette.onAccent,
                  weight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              phone ? 'Samuel' : 'Samuel Rosengarten',
              style: interStyle(
                size: 15,
                color: palette.ink,
                weight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ],
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
      icon: Icon(Icons.menu, color: paletteOf(context).ink.withValues(alpha: 0.87)),
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
        controller.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
        color: palette.ink.withValues(alpha: 0.87),
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
        style: interStyle(
          size: 12,
          color: palette.ink.withValues(alpha: 0.87),
          weight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
      tooltip: togglesToFrench ? s.switchToFrench : s.switchToEnglish,
      onPressed: controller.toggle,
    );
  }
}

/// The row of nav links shown across the top of the header on wider screens.
class _DesktopNav extends StatelessWidget {
  const _DesktopNav({required this.active, required this.onSelected});

  final ValueListenable<SiteSection> active;
  final ValueChanged<SiteSection> onSelected;

  @override
  Widget build(BuildContext context) {
    final lang = languageOf(context);
    // FittedBox + scaleDown is a safety net for widths just above the phone
    // breakpoint: if the row would overflow, shrink it instead of clipping.
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: ValueListenableBuilder<SiteSection>(
        valueListenable: active,
        builder: (context, current, _) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final section in SiteSection.values)
              _HeaderItem(
                navLabel(lang, section),
                selected: section == current,
                onTap: () => onSelected(section),
              ),
          ],
        ),
      ),
    );
  }
}

class _HeaderItem extends StatefulWidget {
  const _HeaderItem(this.label, {required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_HeaderItem> createState() => _HeaderItemState();
}

class _HeaderItemState extends State<_HeaderItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final ink = paletteOf(context).ink;
    final emphasis = widget.selected ? 1.0 : (_hovering ? 0.9 : 0.65);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 120),
            style: interStyle(
              size: 14,
              color: ink.withValues(alpha: emphasis),
              weight: widget.selected ? FontWeight.w600 : FontWeight.w400,
            ),
            child: Text(widget.label),
          ),
        ),
      ),
    );
  }
}

/// Phone-only strip of section pills under the header; scrolls sideways if the
/// labels (French especially) don't fit.
class _JumpBar extends StatelessWidget {
  const _JumpBar({required this.active, required this.onSelected});

  final ValueListenable<SiteSection> active;
  final ValueChanged<SiteSection> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    final lang = languageOf(context);
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: palette.surface(0.06))),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: ValueListenableBuilder<SiteSection>(
          valueListenable: active,
          builder: (context, current, _) => Row(
            children: [
              for (final section in SiteSection.values) ...[
                if (section != SiteSection.about) const SizedBox(width: 8),
                _JumpPill(
                  navLabel(lang, section),
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

class _JumpPill extends StatelessWidget {
  const _JumpPill(this.label, {required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? palette.ink : palette.card,
          borderRadius: BorderRadius.circular(999),
          border: selected ? null : Border.all(color: palette.surface(0.06)),
        ),
        child: Text(
          label,
          style: interStyle(
            size: 13,
            color: selected ? palette.bg : palette.ink,
            weight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// Phone-size nav drawer: the same section names as the desktop header, laid
/// out as a vertical list. Opened via the hamburger [_MenuButton] and
/// registered as `Scaffold.drawer` by `Home`.
class NavDrawer extends StatelessWidget {
  const NavDrawer({super.key, required this.onSelected});

  /// Called with the section the visitor tapped; the drawer is already
  /// closed by the time this fires.
  final ValueChanged<SiteSection> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    final lang = languageOf(context);
    return Drawer(
      backgroundColor: palette.dark ? kDarkPanelBg : Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'MENU',
                style: interStyle(
                  size: 12,
                  color: palette.ink.withValues(alpha: 0.4),
                  weight: FontWeight.w600,
                  letterSpacing: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 8),
            for (final section in SiteSection.values)
              ListTile(
                title: Text(
                  navLabel(lang, section),
                  style: interStyle(
                    size: 19,
                    color: palette.ink,
                    weight: FontWeight.w500,
                    letterSpacing: -0.2,
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
