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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
                  // value — that's the link _scrollTo uses to find it.
                  AboutSection(key: _sectionKeys[SiteSection.about]),
                  ProjectSection(key: _sectionKeys[SiteSection.projects]),
                  HobbiesSection(key: _sectionKeys[SiteSection.hobbies]),
                  ContactSection(key: _sectionKeys[SiteSection.contact]),
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
