import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../widgets/site_header.dart';
import 'about_section.dart';
import 'contact_section.dart';
import 'hobbies_section.dart';
import 'project_section.dart';

/// The whole page: one scrollable column of sections with a header that
/// stays pinned on top of it and can jump-scroll to any section.
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _scrollController = ScrollController();

  // One GlobalKey per section, created up front. A GlobalKey lets us look up
  // *where a specific widget ended up on screen* later (via its
  // `currentContext`), which is exactly what we need to scroll to a section
  // by name rather than by a hardcoded pixel offset.
  final _sectionKeys = {
    for (final section in SiteSection.values) section: GlobalKey(),
  };

  // Each section's animated backdrop keeps its own Ticker running for as
  // long as the section widget is mounted — which, since every section sits
  // in one plain Column rather than a lazily-built list, is the whole time
  // the page is open, regardless of scroll position. With four continuously
  // animating canvas backdrops (plus the About marquee) all ticking at once,
  // that's real main-thread paint work competing with touch/scroll handling,
  // especially on a phone. TickerMode(enabled: false) is what actually
  // pauses a subtree's Tickers, so each section below is wrapped in one,
  // flipped by how close that section currently is to the viewport.
  late final _sectionVisible = {
    for (final section in SiteSection.values) section: ValueNotifier<bool>(true),
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateSectionVisibility);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _updateSectionVisibility(),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for (final notifier in _sectionVisible.values) {
      notifier.dispose();
    }
    super.dispose();
  }

  /// Compares each section's current on-screen position against the
  /// viewport, with a margin of one extra screen height above and below so
  /// a section's backdrop is already animating by the time it scrolls into
  /// view rather than visibly waking up mid-scroll.
  void _updateSectionVisibility() {
    if (!mounted) return;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final margin = screenHeight;
    for (final entry in _sectionKeys.entries) {
      final box = entry.value.currentContext?.findRenderObject();
      if (box is! RenderBox || !box.attached) continue;
      final top = box.localToGlobal(Offset.zero).dy;
      final bottom = top + box.size.height;
      final visible = bottom > -margin && top < screenHeight + margin;
      _sectionVisible[entry.key]!.value = visible;
    }
  }

  /// Scrolls the section's top edge just below the pinned header.
  void _scrollTo(SiteSection section) {
    final context = _sectionKeys[section]?.currentContext;
    final box = context?.findRenderObject();
    if (box == null || !_scrollController.hasClients) return;

    // getOffsetToReveal answers "how far would the scroll view need to move
    // for this render object's top edge (alignment 0) to reach the top of
    // the viewport?" — that's the piece a GlobalKey makes possible: we don't
    // have to know the section's height or position ahead of time.
    final position = _scrollController.position;
    final target =
        RenderAbstractViewport.of(box).getOffsetToReveal(box, 0).offset -
        kSiteHeaderHeight;

    _scrollController.animateTo(
      // Clamped so a section near the very top/bottom of the page (which
      // can't scroll a full header-height further) doesn't ask for an
      // out-of-range offset.
      target.clamp(position.minScrollExtent, position.maxScrollExtent),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  Widget _sectionTickerMode(SiteSection section, Widget child) {
    return ValueListenableBuilder<bool>(
      valueListenable: _sectionVisible[section]!,
      builder: (context, visible, child) =>
          TickerMode(enabled: visible, child: child!),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [scheme.primaryContainer, scheme.surface],
          ),
        ),
        // Stack, not Column: the scroll view and the header occupy the same
        // space, with the header painted on top (and pinned there, since it
        // sits outside the SingleChildScrollView) instead of scrolling away.
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              // Pushes the whole page down by one header's height so the
              // very first section isn't hidden underneath the pinned
              // header on load.
              padding: const EdgeInsets.only(top: kSiteHeaderHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Each section gets the GlobalKey matching its SiteSection
                  // value — that's the link _scrollTo (and
                  // _updateSectionVisibility) uses to find it — wrapped in a
                  // TickerMode that pauses its backdrop animation once it's
                  // scrolled well out of view.
                  _sectionTickerMode(
                    SiteSection.about,
                    AboutSection(key: _sectionKeys[SiteSection.about]),
                  ),
                  _sectionTickerMode(
                    SiteSection.projects,
                    ProjectSection(key: _sectionKeys[SiteSection.projects]),
                  ),
                  _sectionTickerMode(
                    SiteSection.hobbies,
                    HobbiesSection(key: _sectionKeys[SiteSection.hobbies]),
                  ),
                  _sectionTickerMode(
                    SiteSection.contact,
                    ContactSection(key: _sectionKeys[SiteSection.contact]),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SiteHeader(onSelected: _scrollTo),
            ),
          ],
        ),
      ),
    );
  }
}
