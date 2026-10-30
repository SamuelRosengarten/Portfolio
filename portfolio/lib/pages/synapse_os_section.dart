import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import '../theme/palette.dart';
import '../widgets/link_target.dart';
import '../widgets/section_layout.dart';
import '../widgets/synapse_os_demo.dart';

/// The expanded, comprehensive Synapse OS section spanning 2–3 screen sizes:
/// - Screen 1: Full-window interactive workstation demo with 4 live switchable views.
/// - Screen 2: System Architecture deep dive & comparative benchmark matrix.
/// - Screen 3: Core feature pillars, software craftsmanship philosophy & action links.
class SynapseOsSection extends StatelessWidget {
  const SynapseOsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    final phone = isPhone(context);

    return PageSection(
      background: palette.altBg,
      bordered: true,
      fitToScreen: false, // Allows natural continuous scrolling across 2-3 screen heights
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // SCREEN 1: Full-window interactive workstation demo stage
          const _WorkstationHeroScreen(),
          SizedBox(height: phone ? 48 : 80),

          // SCREEN 2: Technical Architecture & Comparative Benchmark Matrix
          const _ArchitectureAndBenchmarkScreen(),
          SizedBox(height: phone ? 48 : 80),

          // SCREEN 3: Core Feature Pillars, Craftsmanship Philosophy & Action CTA
          const _PhilosophyAndFeaturesScreen(),
        ],
      ),
    );
  }
}

// =============================================================================
// SCREEN 1: FULL-WINDOW WORKSTATION DEMO STAGE
// =============================================================================
class _WorkstationHeroScreen extends StatelessWidget {
  const _WorkstationHeroScreen();

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    final s = stringsOf(context);
    final phone = isPhone(context);
    final viewportHeight = ViewportHeight.maybeOf(context) ?? 780.0;

    // Sized so that on desktop the section opening + demo comfortably fills
    // the window height below the header.
    final targetDemoHeight = phone
        ? 520.0
        : math.max(540.0, viewportHeight - (phone ? 180.0 : 210.0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeading(
          module: 'MOD_01',
          eyebrow: s.projectEyebrow,
          headline: s.projectHeadline,
          subhead: s.projectSubhead,
        ),
        SizedBox(height: phone ? 16 : 24),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Pill(
              s.tagLocalFirstOs,
              background: palette.surface(0.08),
              color: palette.ink,
            ),
            Pill(
              s.tagZeroCloudAi,
              background: palette.accentAlpha(0.1),
              color: palette.accent,
            ),
            Pill(
              s.tagNextJsSqlite,
              background: palette.surface(0.08),
              color: palette.tertiary,
            ),
            Pill(
              s.demoStatusTests,
              background: palette.ok.withValues(alpha: 0.1),
              color: palette.ok,
            ),
          ],
        ),
        SizedBox(height: phone ? 20 : 28),
        SizedBox(
          height: targetDemoHeight,
          child: const SynapseOsDemo(),
        ),
      ],
    );
  }
}

// =============================================================================
// SCREEN 2: TECHNICAL ARCHITECTURE & BENCHMARK MATRIX
// =============================================================================
class _ArchitectureAndBenchmarkScreen extends StatelessWidget {
  const _ArchitectureAndBenchmarkScreen();

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    final s = stringsOf(context);
    final phone = isPhone(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeading(
          eyebrow: s.archSectionEyebrow,
          headline: s.archSectionHeadline,
          subhead: s.archSectionSubhead,
        ),
        SizedBox(height: phone ? 24 : 36),
        // 3 Architecture Pillars Grid
        AutoFitGrid(
          minItemWidth: 340,
          spacing: 18,
          children: [
            _ArchCard(
              icon: Icons.storage_rounded,
              accentColor: palette.accent,
              title: s.archCardSqliteTitle,
              body: s.archCardSqliteBody,
              codeSnippet: 'better-sqlite3 · PRAGMA journal_mode = WAL;',
            ),
            _ArchCard(
              icon: Icons.bolt_rounded,
              accentColor: palette.ok,
              title: s.archCardFts5Title,
              body: s.archCardFts5Body,
              codeSnippet: 'CREATE VIRTUAL TABLE notes_fts USING fts5(content, tokenize="porter");',
            ),
            _ArchCard(
              icon: Icons.sync_rounded,
              accentColor: palette.highlight,
              title: s.archCardWatcherTitle,
              body: s.archCardWatcherBody,
              codeSnippet: 'fs.watch(vaultDir, { recursive: true }, onAtomicChange);',
            ),
          ],
        ),
        SizedBox(height: phone ? 32 : 48),
        // Comparative Benchmark Matrix
        const _BenchmarkMatrixCard(),
      ],
    );
  }
}

class _ArchCard extends StatelessWidget {
  const _ArchCard({
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.body,
    required this.codeSnippet,
  });

  final IconData icon;
  final Color accentColor;
  final String title;
  final String body;
  final String codeSnippet;

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    final phone = isPhone(context);

    return Container(
      padding: EdgeInsets.all(phone ? 18 : 22),
      decoration: hudDecoration(palette),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: accentColor),
            ),
            child: Icon(icon, size: 20, color: accentColor),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: monoStyle(
              size: phone ? 14.5 : 15.5,
              color: palette.ink,
              weight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: interStyle(
              size: 14,
              color: palette.secondary,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: palette.surface(0.04),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: palette.surface(0.1)),
            ),
            child: Text(
              codeSnippet,
              style: monoStyle(
                size: 11,
                color: palette.tertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BenchmarkMatrixCard extends StatelessWidget {
  const _BenchmarkMatrixCard();

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    final s = stringsOf(context);
    final phone = isPhone(context);

    final rows = [
      (
        s.benchRowSearchLatency,
        s.benchValSynapseLatency,
        s.benchValCloudLatency,
        s.benchValPluginLatency,
      ),
      (
        s.benchRowDataPrivacy,
        s.benchValSynapsePrivacy,
        s.benchValCloudPrivacy,
        s.benchValPluginPrivacy,
      ),
      (
        s.benchRowOfflineReady,
        s.benchValSynapseOffline,
        s.benchValCloudOffline,
        s.benchValPluginOffline,
      ),
      (
        s.benchRowVendorLockin,
        s.benchValSynapseLockin,
        s.benchValCloudLockin,
        s.benchValPluginLockin,
      ),
    ];

    return Container(
      decoration: hudDecoration(palette),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: phone ? 16 : 24,
              vertical: phone ? 14 : 18,
            ),
            decoration: BoxDecoration(
              color: palette.surface(0.04),
              border: Border(bottom: BorderSide(color: palette.surface(0.08))),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.compare_arrows_rounded,
                  size: 18,
                  color: palette.accent,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    s.benchTitle,
                    style: monoStyle(
                      size: phone ? 13.5 : 14.5,
                      color: palette.ink,
                      weight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: phone ? 620 : 800,
              ),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(2.0),
                  1: FlexColumnWidth(2.3),
                  2: FlexColumnWidth(2.2),
                  3: FlexColumnWidth(2.2),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      color: palette.surface(0.02),
                      border: Border(bottom: BorderSide(color: palette.surface(0.08))),
                    ),
                    children: [
                      _TableCellHeader(s.benchColMetric),
                      _TableCellHeader(s.benchColSynapse, isHighlight: true),
                      _TableCellHeader(s.benchColCloud),
                      _TableCellHeader(s.benchColPlugins),
                    ],
                  ),
                  for (final row in rows)
                    TableRow(
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: palette.surface(0.06))),
                      ),
                      children: [
                        _TableCellText(row.$1, isLabel: true),
                        _TableCellText(row.$2, isHighlight: true),
                        _TableCellText(row.$3),
                        _TableCellText(row.$4),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableCellHeader extends StatelessWidget {
  const _TableCellHeader(this.text, {this.isHighlight = false});
  final String text;
  final bool isHighlight;

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        text,
        style: monoStyle(
          size: 12,
          weight: FontWeight.w700,
          color: isHighlight ? palette.accent : palette.ink,
        ),
      ),
    );
  }
}

class _TableCellText extends StatelessWidget {
  const _TableCellText(
    this.text, {
    this.isLabel = false,
    this.isHighlight = false,
  });

  final String text;
  final bool isLabel;
  final bool isHighlight;

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Text(
        text,
        style: isLabel
            ? interStyle(size: 13.5, color: palette.ink, weight: FontWeight.w600)
            : monoStyle(
                size: 12,
                weight: isHighlight ? FontWeight.w600 : FontWeight.w400,
                color: isHighlight ? palette.ok : palette.tertiary,
              ),
      ),
    );
  }
}

// =============================================================================
// SCREEN 3: CORE FEATURES, CRAFTSMANSHIP & ACTION CALL
// =============================================================================
class _PhilosophyAndFeaturesScreen extends StatelessWidget {
  const _PhilosophyAndFeaturesScreen();

  @override
  Widget build(BuildContext context) {
    final palette = paletteOf(context);
    final s = stringsOf(context);
    final phone = isPhone(context);

    final features = [
      (
        icon: Icons.psychology_outlined,
        color: palette.accent,
        title: s.featureHintsTitle,
        body: s.featureHintsBody,
      ),
      (
        icon: Icons.hub_outlined,
        color: palette.highlight,
        title: s.featureDashboardTitle,
        body: s.featureDashboardBody,
      ),
      (
        icon: Icons.search_rounded,
        color: palette.ok,
        title: s.featureReportsTitle,
        body: s.featureReportsBody,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 3 Core Feature Cards
        AutoFitGrid(
          minItemWidth: 320,
          spacing: 18,
          children: [
            for (final f in features)
              Container(
                padding: EdgeInsets.all(phone ? 20 : 24),
                decoration: hudDecoration(palette),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: f.color),
                      ),
                      child: Icon(f.icon, size: 20, color: f.color),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      f.title,
                      style: monoStyle(
                        size: phone ? 14.5 : 15.5,
                        color: palette.ink,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      f.body,
                      style: interStyle(
                        size: 14,
                        color: palette.secondary,
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        SizedBox(height: phone ? 32 : 48),

        // Craftsmanship & Sovereignty Banner
        Container(
          padding: EdgeInsets.all(phone ? 22 : 36),
          decoration: hudDecoration(palette, highlighted: true),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MonoLabel(s.craftSectionEyebrow, size: phone ? 11 : 12),
              SizedBox(height: phone ? 12 : 16),
              Text(
                s.craftSectionHeadline,
                style: monoStyle(
                  size: phone ? 22 : 30,
                  color: palette.ink,
                  weight: FontWeight.w800,
                  letterSpacing: -0.8,
                ),
              ),
              SizedBox(height: phone ? 12 : 16),
              Text(
                s.craftSectionBody,
                style: interStyle(
                  size: phone ? 14.5 : 16,
                  color: palette.secondary,
                  height: 1.6,
                ),
              ),
              SizedBox(height: phone ? 22 : 32),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _LinkButton(
                    label: s.viewWebsite,
                    uri: Uri.parse('https://synapse-os.ca'),
                    primary: true,
                  ),
                  _LinkButton(
                    label: s.sourceOnGitHub,
                    uri: Uri.parse('https://github.com/SamuelRosengarten/Synapse-OS'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A HUD link button that opens [uri]: solid yellow when [primary], yellow
/// outline otherwise. Reachable by keyboard and announced as a link.
class _LinkButton extends StatelessWidget {
  const _LinkButton({
    required this.label,
    required this.uri,
    this.primary = false,
  });

  final String label;
  final Uri uri;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return LinkTarget(
      uri: uri,
      semanticLabel: label,
      builder: (context, highlighted) {
        final palette = paletteOf(context);
        final fg = primary
            ? palette.onAccent
            : (highlighted ? palette.accent : palette.ink);
        final phone = isPhone(context);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          constraints: BoxConstraints(minHeight: phone ? 44 : 48),
          padding: EdgeInsets.symmetric(horizontal: phone ? 18 : 22),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: primary
                ? (highlighted
                      ? Color.lerp(palette.accent, Colors.white, 0.25)
                      : palette.accent)
                : (highlighted ? palette.accentAlpha(0.08) : Colors.transparent),
            borderRadius: BorderRadius.circular(kHudButtonRadius),
            border: primary ? null : Border.all(color: palette.accent),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label.toUpperCase(),
                  overflow: TextOverflow.ellipsis,
                  style: monoStyle(
                    size: phone ? 12 : 13,
                    color: fg,
                    weight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
              if (primary) ...[
                const SizedBox(width: 6),
                Icon(Icons.arrow_outward_rounded, size: 16, color: fg),
              ],
            ],
          ),
        );
      },
    );
  }
}
