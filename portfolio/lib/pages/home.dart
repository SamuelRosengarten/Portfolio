import 'package:flutter/material.dart';

import '../theme/palette.dart';
import '../widgets/cli_bar.dart';
import '../widgets/section_layout.dart';
import '../widgets/site_header.dart';
import 'about_section.dart';
import 'contact_section.dart';
import 'synapse_os_section.dart';

/// The whole page, laid out like a HUD: a nav rail down the left (a top bar on
/// a phone), one continuously scrolling column of sections over a grid
/// backdrop, the CLI bar along the bottom and a hazard stripe down the right
/// edge. Picking a section in the nav scrolls to it, and the nav highlights
/// whichever section is currently at the top of the viewport.
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
    final phone = isPhone(context);
    final page = Stack(
      children: [
        const Positioned.fill(child: GridBackdrop()),
        LayoutBuilder(
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
                    key: _sectionKeys[SiteSection.synapseOs],
                    child: const SynapseOsSection(),
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
      ],
    );

    return Scaffold(
      drawer: phone ? NavDrawer(onSelected: _onSelected) : null,
      backgroundColor: paletteOf(context).bg,
      body: phone
          ? Column(
              children: [
                PhoneHeader(active: _active, onSelected: _onSelected),
                Expanded(child: page),
                const CliBar(),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SideRail(active: _active, onSelected: _onSelected),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(child: page),
                      const CliBar(),
                    ],
                  ),
                ),
                const SizedBox(width: 10, child: HazardStripes()),
              ],
            ),
    );
  }
}
