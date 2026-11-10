import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../i18n/app_language.dart';
import '../i18n/strings.dart';
import '../theme/palette.dart';
import '../theme/theme_controller.dart';
import 'section_layout.dart';

/// The sections of the page, in the order they are stacked — the header renders
/// one item per value and [Home] anchors one section to each.
enum SiteSection { about, synapse, work, beyond, contact }

/// [SiteSection]'s label is small, closed data tied one-to-one to the enum
/// itself, so it lives next to it as a plain switch rather than in the
/// shared [Strings] class — putting it there would need [Strings] to import
/// this file right back.
String navLabel(AppLanguage lang, SiteSection section) {
  final fr = lang == AppLanguage.fr;
  return switch (section) {
    SiteSection.about => fr ? 'À propos' : 'About',
    SiteSection.synapse => 'Synapse OS',
    SiteSection.work => fr ? 'Projets' : 'Work',
    SiteSection.beyond => fr ? 'Hors du code' : 'Beyond code',
    SiteSection.contact => 'Contact',
  };
}

/// Pinned header. On desktop: logo, centred section links and the language and
/// theme toggles in one row. On a phone: logo, toggles and a menu button, with
/// a horizontally scrolling jump bar of section pills underneath.
class SiteHeader extends StatelessWidget {
  const SiteHeader({super.key, required this.active, required this.onSelected});

  /// The section currently at the top of the viewport, highlighted in the nav.
  final ValueListenable<SiteSection> active;

  /// Called with the section the visitor asked to jump to.
  final ValueChanged<SiteSection> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    final phone = useCompactHeader(context);
    final width = MediaQuery.sizeOf(context).width;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.bg.withValues(alpha: 0.96),
        border: Border(bottom: BorderSide(color: palette.line)),
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
                    height: phone ? 64 : 72,
                    child: Row(
                      children: [
                        if (phone)
                          // Takes whatever the three buttons leave, and the
                          // name shortens with an ellipsis at large text sizes
                          // instead of pushing the buttons off screen.
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: _Logo(
                                phone: phone,
                                onTap: () => onSelected(SiteSection.about),
                              ),
                            ),
                          )
                        else ...[
                          _Logo(
                            phone: phone,
                            onTap: () => onSelected(SiteSection.about),
                          ),
                          Expanded(
                            child: _DesktopNav(
                              active: active,
                              onSelected: onSelected,
                            ),
                          ),
                        ],
                        const _LanguageToggleButton(),
                        const SizedBox(width: 6),
                        const _ThemeToggleButton(),
                        if (phone) ...[
                          const SizedBox(width: 6),
                          const _MenuButton(),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (phone) _JumpBar(active: active, onSelected: onSelected),
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
            InitialsMark(size: phone ? 32 : 36),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                phone ? 'Samuel' : 'Samuel Rosengarten',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: bodyStyle(
                  size: 16,
                  color: palette.ink,
                  weight: FontWeight.w600,
                ),
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
    return _RoundButton(
      tooltip: stringsOf(context).openNavigation,
      onPressed: () => Scaffold.of(context).openDrawer(),
      child: Icon(Icons.menu, color: paletteOf(context).ink2, size: 20),
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
    return _RoundButton(
      tooltip: controller.isDark ? s.switchToLightMode : s.switchToDarkMode,
      onPressed: controller.toggle,
      child: Icon(
        controller.isDark
            ? Icons.light_mode_outlined
            : Icons.dark_mode_outlined,
        color: palette.ink2,
        size: 18,
      ),
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
    return _RoundButton(
      tooltip: togglesToFrench ? s.switchToFrench : s.switchToEnglish,
      onPressed: controller.toggle,
      child: Text(
        togglesToFrench ? 'FR' : 'EN',
        style: bodyStyle(
          size: 13,
          color: palette.ink2,
          weight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// The header's round, outlined icon button.
class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.tooltip,
    required this.onPressed,
    required this.child,
  });

  final String tooltip;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: child,
      style: IconButton.styleFrom(
        fixedSize: const Size(42, 42),
        minimumSize: const Size(42, 42),
        shape: CircleBorder(side: BorderSide(color: palette.line)),
        hoverColor: palette.hover,
      ),
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
    final palette = paletteOf(context);
    // Muted text that lifts on hover; the current section gets full-strength
    // text and a short straw rule underneath.
    final fg = widget.selected
        ? palette.ink
        : (_hovering ? palette.ink2 : palette.secondary);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: bodyStyle(
                  size: 15,
                  color: fg,
                  weight: widget.selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                height: 2,
                width: widget.selected ? 18 : 0,
                decoration: BoxDecoration(
                  color: palette.accent,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
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
        border: Border(top: BorderSide(color: palette.line)),
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
          color: selected ? palette.raised : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? palette.lineStrong : palette.line,
          ),
        ),
        child: Text(
          label,
          style: bodyStyle(
            size: 13.5,
            color: selected ? palette.ink : palette.secondary,
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
      backgroundColor: palette.altBg,
      child: SafeArea(
        // A list, not a column: at large text sizes the five links are taller
        // than a short screen, so the drawer has to scroll.
        child: ListView(
          children: [
            const SizedBox(height: 28),
            // Aligned, because a ListView gives its children the full width
            // and the mark would stretch to fill it.
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: InitialsMark(size: 36),
              ),
            ),
            const SizedBox(height: 16),
            for (final section in SiteSection.values)
              ListTile(
                title: Text(
                  navLabel(lang, section),
                  style: displayStyle(
                    size: 30,
                    color: palette.ink,
                    weight: FontWeight.w700,
                    height: 1.1,
                  ).copyWith(letterSpacing: 0.5),
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
