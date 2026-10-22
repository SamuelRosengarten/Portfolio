import 'package:flutter/material.dart';

import '../theme/palette.dart';
import '../widgets/section_layout.dart';
import '../widgets/site_header.dart';
import 'about_section.dart';
import 'contact_section.dart';
import 'hobbies_section.dart';
import 'project_section.dart';

/// The whole page: a pinned header above one continuously scrolling column of
/// sections. Picking a section in the header (or the drawer on a phone)
/// scrolls to it, and the header highlights whichever section is currently
/// at the top of the viewport.
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _scroll = ScrollController();
  final _viewportKey = GlobalKey();
  final _sectionKeys = {for (final s in SiteSection.values) s: GlobalKey()};
  final _active = ValueNotifier(SiteSection.about);

  /// How far below the top of the viewport a section's top edge may sit and
  /// still count as "the current section".
  static const _activeThreshold = 120.0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_updateActive);
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_updateActive)
      ..dispose();
    _active.dispose();
    super.dispose();
  }

  void _updateActive() {
    final viewport = _viewportKey.currentContext?.findRenderObject();
    if (viewport is! RenderBox || !viewport.attached || !_scroll.hasClients) {
      return;
    }
    // Short last sections can never reach the threshold; at the very bottom
    // the last one is the one being read.
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 8) {
      _active.value = SiteSection.values.last;
      return;
    }
    final viewportTop = viewport.localToGlobal(Offset.zero).dy;
    var current = SiteSection.about;
    for (final section in SiteSection.values) {
      final box = _sectionKeys[section]!.currentContext?.findRenderObject();
      if (box is! RenderBox || !box.attached) continue;
      if (box.localToGlobal(Offset.zero).dy - viewportTop <= _activeThreshold) {
        current = section;
      }
    }
    _active.value = current;
  }

  void _onSelected(SiteSection section) {
    final context = _sectionKeys[section]!.currentContext;
    if (context == null) return;
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(onSelected: _onSelected),
      backgroundColor: paletteOf(context).bg,
      body: Column(
        children: [
          SiteHeader(active: _active, onSelected: _onSelected),
          Expanded(
            // Every section is exactly this tall: the window below the header.
            child: LayoutBuilder(
              builder: (context, constraints) => ViewportHeight(
                height: constraints.maxHeight,
                child: SingleChildScrollView(
                  key: _viewportKey,
                  controller: _scroll,
                  child: Column(
                    children: [
                      KeyedSubtree(
                        key: _sectionKeys[SiteSection.about],
                        child: AboutSection(onSelected: _onSelected),
                      ),
                      KeyedSubtree(
                        key: _sectionKeys[SiteSection.projects],
                        child: const ProjectSection(),
                      ),
                      KeyedSubtree(
                        key: _sectionKeys[SiteSection.hobbies],
                        child: const HobbiesSection(),
                      ),
                      KeyedSubtree(
                        key: _sectionKeys[SiteSection.contact],
                        child: const ContactSection(),
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
