import 'package:flutter/material.dart';

import '../theme/palette.dart';
import '../widgets/site_header.dart';
import 'about_section.dart';
import 'contact_section.dart';
import 'hobbies_section.dart';
import 'project_section.dart';

/// The whole page: a pinned header on top of exactly one section at a time,
/// filling the rest of the screen — on phone and desktop alike. Picking a
/// section (the header's nav row on desktop, the drawer everywhere) swaps
/// which one is built; the others aren't reachable by scrolling past it,
/// only by picking them from the nav again.
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  SiteSection _section = SiteSection.about;

  void _onSelected(SiteSection section) => setState(() => _section = section);

  Widget _sectionFor(SiteSection section) {
    return switch (section) {
      SiteSection.about => const AboutSection(),
      SiteSection.projects => const ProjectSection(),
      SiteSection.hobbies => const HobbiesSection(),
      SiteSection.contact => const ContactSection(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(onSelected: _onSelected),
      body: Container(
        // A plain fill in the site's own background colour, not the
        // Material seed colour's gradient: sections that don't paint an
        // opaque background edge-to-edge (e.g. the dashed-seam gap between
        // Hobbies' two halves) used to let that seed colour show through as
        // a stray tint. The site's own palette has no such surprise colour.
        color: paletteOf(context).bg,
        child: Column(
          children: [
            SiteHeader(onSelected: _onSelected),
            Expanded(child: _sectionFor(_section)),
          ],
        ),
      ),
    );
  }
}
