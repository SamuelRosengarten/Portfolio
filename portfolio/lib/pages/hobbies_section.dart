import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/palette.dart';
import '../widgets/section_layout.dart';

class HobbiesSection extends StatelessWidget {
  const HobbiesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionShell(
      background: kLightBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionIntro(
            eyebrow: 'Beyond the code',
            headline: 'Made by hand.',
            subhead:
                'Craft off the screen keeps the work on it honest. Patience, '
                'repetition, and the willingness to cut a piece again.',
          ),
          SizedBox(height: 32),
          Expanded(child: Center(child: _FeatureTiles())),
        ],
      ),
    );
  }
}

class _FeatureTiles extends StatelessWidget {
  const _FeatureTiles();

  @override
  Widget build(BuildContext context) {
    return CardGrid(
      spacing: 20,
      columnsFor: (width) => width >= 700 ? 2 : 1,
      children: const [
        _FeatureTile(
          icon: Icons.content_cut_rounded,
          eyebrow: 'Hobby',
          title: 'Leathercraft',
          body:
              'Cutting, stitching, burnishing — pieces that take hours and '
              'get better with every one. The saddle stitch taught me more '
              'about patience than any deadline ever did.',
        ),
        _FeatureTile(
          icon: Icons.school_outlined,
          eyebrow: 'Goal',
          title: 'Teaching',
          body:
              'The long-term plan is the classroom. Explaining something '
              'until it clicks for someone else is the part of the work I '
              'keep coming back to.',
        ),
      ],
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String eyebrow;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(34),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 30, color: kInk),
          const SizedBox(height: 22),
          Text(
            eyebrow.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: kGray,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
              color: kInk,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: GoogleFonts.inter(fontSize: 16, height: 1.6, color: kGray),
          ),
        ],
      ),
    );
  }
}
