import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../widgets/site_header.dart';
import 'about_section.dart';
import 'contact_section.dart';
import 'hobbies_section.dart';
import 'project_section.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _scrollController = ScrollController();
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

    final position = _scrollController.position;
    final target =
        RenderAbstractViewport.of(box).getOffsetToReveal(box, 0).offset -
        kSiteHeaderHeight;

    _scrollController.animateTo(
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
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.only(top: kSiteHeaderHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
