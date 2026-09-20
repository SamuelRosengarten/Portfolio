import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../theme/palette.dart';
import '../widgets/site_header.dart';
import 'about_section.dart';
import 'contact_section.dart';
import 'hobbies_section.dart';
import 'project_section.dart';

/// The whole page.
///
/// On desktop this is one scrollable column of sections with a header that
/// stays pinned on top of it and can jump-scroll to any section. On phone-size
/// screens the sections are *not* stitched into one continuous scroll — each
/// one fills the screen on its own, and the only way between them is the nav
/// drawer, so a visitor can't accidentally scroll from the section they picked
/// into the next one.
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
  // by name rather than by a hardcoded pixel offset. Desktop-only — the
  // mobile layout switches sections by swapping which one is built instead.
  final _sectionKeys = {
    for (final section in SiteSection.values) section: GlobalKey(),
  };

  /// Which section is on screen in the phone-size single-section layout.
  SiteSection _mobileSection = SiteSection.about;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onSelected(SiteSection section) {
    final mobile = MediaQuery.sizeOf(context).width < kMobileNavBreakpoint;
    if (mobile) {
      setState(() => _mobileSection = section);
    } else {
      _scrollTo(section);
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
    final maxExtent = position.maxScrollExtent;
    final rawTarget =
        RenderAbstractViewport.of(box).getOffsetToReveal(box, 0).offset -
        kSiteHeaderHeight;

    // For every section but the last, there's more content below to fill
    // the header-height gap this leaves at the bottom of the viewport. The
    // last section has nothing below it to fill that gap with, which left
    // its own bottom edge — exactly one header's height of it — permanently
    // unreachable by scrolling. Detect that case (the gap between the naive
    // target and the true end of the page is no bigger than the header
    // itself, which only happens for the last section) and snap to the true
    // end instead, so the whole section actually comes into view.
    final target = (rawTarget < maxExtent && maxExtent - rawTarget <= kSiteHeaderHeight)
        ? maxExtent
        : rawTarget.clamp(position.minScrollExtent, maxExtent);

    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  Widget _sectionFor(SiteSection section) {
    return switch (section) {
      SiteSection.about => AboutSection(key: _sectionKeys[section]),
      SiteSection.projects => ProjectSection(key: _sectionKeys[section]),
      SiteSection.hobbies => HobbiesSection(key: _sectionKeys[section]),
      SiteSection.contact => ContactSection(key: _sectionKeys[section]),
    };
  }

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < kMobileNavBreakpoint;
    return Scaffold(
      drawer: NavDrawer(onSelected: _onSelected),
      body: Container(
        // A plain fill in the site's own background colour, not the
        // Material seed colour's gradient: sections that don't paint an
        // opaque background edge-to-edge (e.g. the dashed-seam gap between
        // Hobbies' two halves) used to let that seed colour show through as
        // a stray tint. The site's own palette has no such surprise colour.
        color: paletteOf(context).bg,
        child: mobile ? _buildMobile(context) : _buildDesktop(context),
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    // Stack, not Column: the scroll view and the header occupy the same
    // space, with the header painted on top (and pinned there, since it
    // sits outside the SingleChildScrollView) instead of scrolling away.
    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          // Pushes the whole page down by one header's height so the very
          // first section isn't hidden underneath the pinned header on load.
          padding: const EdgeInsets.only(top: kSiteHeaderHeight),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [for (final section in SiteSection.values) _sectionFor(section)],
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SiteHeader(onSelected: _onSelected),
        ),
      ],
    );
  }

  /// One section at a time, filling exactly the screen below the header —
  /// no scroll view, so there's nothing to accidentally scroll past into the
  /// next section. Switching sections is the drawer's job only.
  Widget _buildMobile(BuildContext context) {
    return Column(
      children: [
        SiteHeader(onSelected: _onSelected),
        Expanded(child: _sectionFor(_mobileSection)),
      ],
    );
  }
}
