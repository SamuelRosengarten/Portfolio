import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../i18n/strings.dart';
import '../theme/palette.dart';
import '../theme/theme_controller.dart';
import 'section_layout.dart';

// =============================================================================
// SYNAPSE OS THEME TOKENS (Matching Synapse OS src/app/globals.css exactly)
// =============================================================================

class _SynapseTheme {
  const _SynapseTheme({
    required this.bg,
    required this.side,
    required this.panel,
    required this.raised,
    required this.hover,
    required this.line,
    required this.line2,
    required this.text,
    required this.text2,
    required this.muted,
    required this.faint,
    required this.ai,
    required this.aiBg,
    required this.aiLine,
    required this.due,
    required this.ok,
    required this.bad,
    required this.info,
    required this.projectColors,
    required this.isDark,
  });

  final Color bg;
  final Color side;
  final Color panel;
  final Color raised;
  final Color hover;
  final Color line;
  final Color line2;
  final Color text;
  final Color text2;
  final Color muted;
  final Color faint;
  final Color ai;
  final Color aiBg;
  final Color aiLine;
  final Color due;
  final Color ok;
  final Color bad;
  final Color info;
  final List<Color> projectColors;
  final bool isDark;

  static const dark = _SynapseTheme(
    bg: Color(0xFF0A0C10),
    side: Color(0xFF0D1015),
    panel: Color(0xFF11151B),
    raised: Color(0xFF171C24),
    hover: Color(0xFF1D232D),
    line: Color(0xFF252C37),
    line2: Color(0xFF3A4352),
    text: Color(0xFFEEF0F4),
    text2: Color(0xFFDFE3EA),
    muted: Color(0xFFA6AFBD),
    faint: Color(0xFF8B95A6),
    ai: Color(0xFFB9A6FF),
    aiBg: Color(0x1FB9A6FF),
    aiLine: Color(0x80B9A6FF),
    due: Color(0xFFF2C277),
    ok: Color(0xFF5DD3A9),
    bad: Color(0xFFFF9090),
    info: Color(0xFF86B4FF),
    projectColors: [
      Color(0xFF86B4FF),
      Color(0xFF5DD3A9),
      Color(0xFFFF9FC6),
      Color(0xFF7FD6E8),
      Color(0xFFD9A77A),
      Color(0xFFC4CE7A),
      Color(0xFFB9A6FF),
      Color(0xFFCFD5E3),
    ],
    isDark: true,
  );

  static const light = _SynapseTheme(
    bg: Color(0xFFF7F8FA),
    side: Color(0xFFF1F3F6),
    panel: Color(0xFFFFFFFF),
    raised: Color(0xFFEEF0F4),
    hover: Color(0xFFE6E9EE),
    line: Color(0xFFDCE0E6),
    line2: Color(0xFFC4CAD3),
    text: Color(0xFF14171C),
    text2: Color(0xFF2B313A),
    muted: Color(0xFF4A5361),
    faint: Color(0xFF5F6978),
    ai: Color(0xFF5B3BC4),
    aiBg: Color(0x1A5B3BC4),
    aiLine: Color(0x735B3BC4),
    due: Color(0xFF7A5200),
    ok: Color(0xFF0D6444),
    bad: Color(0xFFAB2530),
    info: Color(0xFF2556BB),
    projectColors: [
      Color(0xFF1F6FD6),
      Color(0xFF0F8A5E),
      Color(0xFFD03A78),
      Color(0xFF0B7F94),
      Color(0xFF9A5F2B),
      Color(0xFF6B7A1A),
      Color(0xFF5B3BC4),
      Color(0xFF5B6475),
    ],
    isDark: false,
  );
}

// =============================================================================
// DATA STRUCTURES
// =============================================================================

class _ProjectData {
  const _ProjectData({
    required this.id,
    required this.name,
    required this.colorIndex,
    required this.openCount,
  });

  final String id;
  final String name;
  final int colorIndex;
  final int openCount;
}

enum _UrgencyLevel { overdue, dueToday, dueSoon, onTrack }

class _TaskData {
  _TaskData({
    required this.id,
    required this.title,
    required this.projectId,
    required this.dueDate,
    required this.urgency,
    this.isDone = false,
    this.dependsOn,
    this.linkedNoteId,
  });

  final String id;
  final String title;
  final String projectId;
  final String dueDate;
  final _UrgencyLevel urgency;
  bool isDone;
  final String? dependsOn;
  final String? linkedNoteId;
}

enum _ReviewKind { capture, dependency, pr }

enum _ReviewStatus { pending, accepted, dismissed }

class _ReviewItem {
  _ReviewItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    this.status = _ReviewStatus.pending,
  });

  final String id;
  final _ReviewKind kind;
  final String title;
  final String subtitle;
  final String actionLabel;
  _ReviewStatus status;
}

class _VaultNote {
  const _VaultNote({
    required this.id,
    required this.fileName,
    required this.title,
    required this.tags,
    required this.frontmatter,
    required this.contentLines,
    required this.connectedNoteIds,
    required this.wordCount,
  });

  final String id;
  final String fileName;
  final String title;
  final List<String> tags;
  final Map<String, String> frontmatter;
  final List<String> contentLines;
  final List<String> connectedNoteIds;
  final int wordCount;
}

class _AiExchange {
  const _AiExchange({
    required this.question,
    required this.answer,
    required this.citation,
    required this.metric,
  });

  final String question;
  final String answer;
  final String citation;
  final String metric;
}

// =============================================================================
// AUTHENTIC DEFAULT SEED DATA
// =============================================================================

const _defaultProjects = [
  _ProjectData(id: 'core', name: 'Synapse Core', colorIndex: 0, openCount: 2),
  _ProjectData(
    id: 'intern',
    name: 'Internship Search',
    colorIndex: 1,
    openCount: 1,
  ),
  _ProjectData(id: 'rag', name: 'Local AI RAG', colorIndex: 6, openCount: 1),
  _ProjectData(id: 'cal', name: 'CalDAV Sync', colorIndex: 3, openCount: 1),
];

const _vaultNotes = <_VaultNote>[
  _VaultNote(
    id: 'architecture-wal',
    fileName: 'architecture-wal.md',
    title: 'Zero-Cloud SQLite WAL Storage Engine',
    tags: ['sqlite', 'wal', 'local-first', 'c-bindings'],
    frontmatter: {
      'engine': 'better-sqlite3',
      'mode': 'WAL (Write-Ahead Logging)',
      'concurrency': '1-writer / n-readers',
      'query_latency': '0.6ms',
      'storage_format': 'Standard SQLite3 on-disk',
    },
    contentLines: [
      '# SQLite WAL Storage Architecture',
      '',
      'Synapse OS relies on direct C-level bindings (`better-sqlite3`) executing in-process.',
      'By running in Write-Ahead Logging (`WAL`) mode, reading operations never block write',
      'transactions, eliminating locking contention across local notes and queries.',
      '',
      '## Key Integrations',
      '- Full-text token indexing powered by [[fts5-bm25]].',
      '- On-device vector embeddings and local LLM context via [[on-device-rag]].',
      '- Strict data sovereignty model documented in [[data-sovereignty]].',
    ],
    connectedNoteIds: ['fts5-bm25', 'on-device-rag', 'data-sovereignty'],
    wordCount: 340,
  ),
  _VaultNote(
    id: 'fts5-bm25',
    fileName: 'fts5-bm25.md',
    title: 'Sub-Millisecond Full-Text Search (FTS5)',
    tags: ['fts5', 'bm25', 'indexing', 'zero-latency'],
    frontmatter: {
      'algorithm': 'BM25 ranking + Porter stemmer',
      'index_type': 'Inverted SQLite virtual table',
      'reindex_trigger': 'Atomic filesystem watcher',
      'search_speed': '< 1.0ms across 10k docs',
    },
    contentLines: [
      '# Sub-Millisecond FTS5 Search Engine',
      '',
      'Every Markdown document in the local vault is parsed into tokens and synced',
      'to an SQLite `fts5` virtual table with BM25 relevance ranking.',
      '',
      '## Performance Attributes',
      '- Zero network round-trips: queries resolve in ~0.6ms locally.',
      '- Linked to relational database schema defined in [[architecture-wal]].',
      '- Zero proprietary data structures: 100% standard SQL and Markdown.',
    ],
    connectedNoteIds: ['architecture-wal', 'data-sovereignty'],
    wordCount: 285,
  ),
  _VaultNote(
    id: 'on-device-rag',
    fileName: 'on-device-rag.md',
    title: 'On-Device Ollama AI & RAG Grounding',
    tags: ['ollama', 'llama3', 'rag', 'zero-telemetry'],
    frontmatter: {
      'model': 'Llama 3 (8B quantized)',
      'endpoint': 'http://127.0.0.1:11434',
      'cloud_outbound': '0 bytes (100% private)',
      'grounding_source': 'Local Markdown vault snippets',
    },
    contentLines: [
      '# On-Device Ollama AI Intelligence',
      '',
      'Context queries are retrieved via SQLite FTS5 vector snippets and sent directly',
      'to the local Ollama daemon at `127.0.0.1`. The LLM generates responses with',
      'exact file and line citations without ever touching an external cloud API.',
      '',
      '## Reference Architecture',
      '- Grounded in local storage engine: [[architecture-wal]].',
      '- Guarantees uncompromised privacy as defined in [[data-sovereignty]].',
    ],
    connectedNoteIds: ['architecture-wal', 'data-sovereignty'],
    wordCount: 310,
  ),
  _VaultNote(
    id: 'data-sovereignty',
    fileName: 'data-sovereignty.md',
    title: 'Data Sovereignty & Zero-Telemetry Manifesto',
    tags: ['sovereignty', 'offline-first', 'privacy', 'open-standards'],
    frontmatter: {
      'philosophy': 'Your Mind, Your Machine. Never the Cloud.',
      'cloud_sync': 'Optional user-owned rsync / git',
      'tracking': '0 trackers, 0 cookies, 0 telemetry',
      'format': 'Plain .md text files on local disk',
    },
    contentLines: [
      '# Data Sovereignty & Zero Telemetry',
      '',
      'Your thoughts, knowledge, and notes belong strictly to you.',
      'Synapse OS enforces zero subscriptions, zero cloud analytics, and zero lock-in.',
      'Files remain plain Markdown files readable by Neovim, Obsidian, or cat.',
      '',
      '## Connected Modules',
      '- Storage: [[architecture-wal]]',
      '- Fast retrieval: [[fts5-bm25]]',
      '- Private Intelligence: [[on-device-rag]]',
    ],
    connectedNoteIds: ['architecture-wal', 'fts5-bm25', 'on-device-rag'],
    wordCount: 295,
  ),
];

const _aiConversations = <_AiExchange>[
  _AiExchange(
    question: 'Is my data ever sent to external cloud servers?',
    answer: 'Never. Synapse OS operates 100% on your physical hardware. Notes are standard Markdown files on disk, SQLite runs locally in WAL mode, and Ollama runs strictly on 127.0.0.1. Zero cloud telemetry, zero remote tracking, zero subscriptions.',
    citation: 'docs/storage-architecture.md#L42',
    metric: '0 bytes outbound · 100% Local Disk',
  ),
  _AiExchange(
    question: 'How does Synapse OS achieve sub-millisecond search?',
    answer: 'Search runs over native C SQLite bindings (better-sqlite3) with FTS5 and Write-Ahead Logging (WAL) enabled. With zero round-trip network hops, full-text queries across 1,000+ notes execute in under 1ms.',
    citation: 'engine/fts5-indexer.ts#L88',
    metric: '0.6ms query latency · WAL Mode',
  ),
  _AiExchange(
    question: 'How does the Internship Scout agent work?',
    answer: 'The background scout agent scans curated job postings, parses requirements using local Llama 3 against your local CV markdown note, computes a 1-5 fit score, and drafts tailored mailto applications without touching external AI APIs.',
    citation: 'scout/jobs-agent.ts#L64',
    metric: 'Local evaluation · Zero telemetry',
  ),
];

// =============================================================================
// MAIN INTERACTIVE DEMO WIDGET
// =============================================================================

class SynapseOsDemo extends StatefulWidget {
  const SynapseOsDemo({super.key, this.compact, this.onSelectNote});

  final bool? compact;
  final ValueChanged<String>? onSelectNote;

  @override
  State<SynapseOsDemo> createState() => _SynapseOsDemoState();
}

class _SynapseOsDemoState extends State<SynapseOsDemo> {
  int _activeViewIndex = 0; // 0: Today, 1: Plan, 2: Notes, 3: Ask AI
  int _planSubMode = 0; // 0: Week Workflow, 1: Dependency Graph
  String _selectedNoteId = 'architecture-wal';
  String? _selectedKanbanTaskId = 't1';

  final TextEditingController _captureTextController = TextEditingController();
  final TextEditingController _captureTagController = TextEditingController();
  final TextEditingController _aiCustomPromptController =
      TextEditingController();

  bool _justSavedCapture = false;
  Timer? _savedNotificationTimer;

  late List<_TaskData> _tasks;
  late List<_ReviewItem> _reviewItems;
  late List<_AiExchange> _conversation;

  @override
  void initState() {
    super.initState();
    _tasks = [
      _TaskData(
        id: 't1',
        title: 'Implement PR suggestion review flow',
        projectId: 'core',
        dueDate: 'Overdue · 2026-10-24',
        urgency: _UrgencyLevel.overdue,
        linkedNoteId: 'architecture-wal',
      ),
      _TaskData(
        id: 't2',
        title: 'Submit summer 2027 internship application',
        projectId: 'intern',
        dueDate: 'Today',
        urgency: _UrgencyLevel.dueToday,
        dependsOn: 'Update CV markdown',
      ),
      _TaskData(
        id: 't3',
        title: 'Benchmark SQLite WAL read latency under load',
        projectId: 'core',
        dueDate: 'Oct 28',
        urgency: _UrgencyLevel.dueSoon,
        linkedNoteId: 'fts5-bm25',
      ),
      _TaskData(
        id: 't4',
        title: 'CalDAV two-way event synchronization test',
        projectId: 'cal',
        dueDate: 'Oct 30',
        urgency: _UrgencyLevel.dueSoon,
      ),
      _TaskData(
        id: 't5',
        title: 'Quantize Llama-3 8B model for Apple Silicon & RTX',
        projectId: 'rag',
        dueDate: 'Nov 04',
        urgency: _UrgencyLevel.onTrack,
        linkedNoteId: 'on-device-rag',
      ),
    ];

    _reviewItems = [
      _ReviewItem(
        id: 'r1',
        kind: _ReviewKind.capture,
        title: 'Draft proposal for internship watcher agent',
        subtitle: 'Inbox capture · turn into task',
        actionLabel: 'Turn into task',
      ),
      _ReviewItem(
        id: 'r2',
        kind: _ReviewKind.dependency,
        title: 'Submit internship waits for Update CV',
        subtitle: 'Dependency suggestion · Missing resume attachment',
        actionLabel: 'Accept dependency',
      ),
      _ReviewItem(
        id: 'r3',
        kind: _ReviewKind.pr,
        title: 'PR #42: SQLite WAL migration',
        subtitle: 'Mark “Implement PR suggestion review flow” done?',
        actionLabel: 'Accept & Mark done',
      ),
    ];

    _conversation = List.from(_aiConversations);
  }

  @override
  void dispose() {
    _savedNotificationTimer?.cancel();
    _captureTextController.dispose();
    _captureTagController.dispose();
    _aiCustomPromptController.dispose();
    super.dispose();
  }

  _SynapseTheme _getTheme(BuildContext context) {
    try {
      final isDark = isDarkOf(context);
      return isDark ? _SynapseTheme.dark : _SynapseTheme.light;
    } catch (_) {
      final brightness = Theme.of(context).brightness;
      return brightness == Brightness.dark
          ? _SynapseTheme.dark
          : _SynapseTheme.light;
    }
  }

  _VaultNote get _currentNote => _vaultNotes.firstWhere(
    (n) => n.id == _selectedNoteId,
    orElse: () => _vaultNotes.first,
  );

  int get _inboxCount =>
      _reviewItems.where((r) => r.status == _ReviewStatus.pending).length;

  int get _openTasksCount => _tasks.where((t) => !t.isDone).length;
  int get _overdueTasksCount => _tasks
      .where((t) => !t.isDone && t.urgency == _UrgencyLevel.overdue)
      .length;
  int get _dueTodayTasksCount => _tasks
      .where((t) => !t.isDone && t.urgency == _UrgencyLevel.dueToday)
      .length;

  void _openNote(String id) {
    setState(() {
      _selectedNoteId = id;
      _activeViewIndex = 2; // Jump to Notes
    });
    widget.onSelectNote?.call(id);
  }

  void _toggleTask(String id) {
    setState(() {
      final t = _tasks.firstWhere((item) => item.id == id);
      t.isDone = !t.isDone;
    });
  }

  void _acceptReview(_ReviewItem item) {
    setState(() {
      item.status = _ReviewStatus.accepted;
      if (item.kind == _ReviewKind.pr) {
        final t = _tasks.firstWhere((task) => task.id == 't1');
        t.isDone = true;
      } else if (item.kind == _ReviewKind.capture) {
        _tasks.insert(
          0,
          _TaskData(
            id: 't_new_${DateTime.now().millisecondsSinceEpoch}',
            title: item.title,
            projectId: 'intern',
            dueDate: 'Today',
            urgency: _UrgencyLevel.dueToday,
          ),
        );
      }
    });
  }

  void _dismissReview(_ReviewItem item) {
    setState(() {
      item.status = _ReviewStatus.dismissed;
    });
  }

  void _saveQuickCapture() {
    final text = _captureTextController.text.trim();
    if (text.isEmpty) return;

    final tags = _captureTagController.text.trim();
    final subtitle = tags.isNotEmpty
        ? 'Tags: $tags · Inbox review'
        : 'Inbox capture · review';

    setState(() {
      _reviewItems.insert(
        0,
        _ReviewItem(
          id: 'cap_${DateTime.now().millisecondsSinceEpoch}',
          kind: _ReviewKind.capture,
          title: text,
          subtitle: subtitle,
          actionLabel: 'Turn into task',
        ),
      );
      _captureTextController.clear();
      _captureTagController.clear();
      _justSavedCapture = true;
    });

    _savedNotificationTimer?.cancel();
    _savedNotificationTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _justSavedCapture = false);
    });
  }

  void _submitAiPrompt(String query) {
    if (query.trim().isEmpty) return;
    setState(() {
      _conversation.add(
        _AiExchange(
          question: query.trim(),
          answer: 'Grounded in your local SQLite vault: Synapse OS executes on-device without telemetry. Verified locally against your active Markdown files and SQLite WAL index.',
          citation: 'local-vault/system.md#L1',
          metric: '0.4ms query · 0 bytes outbound',
        ),
      );
      _aiCustomPromptController.clear();
    });
  }

  // ===========================================================================
  // BUILD METHOD
  // ===========================================================================
  @override
  Widget build(BuildContext context) {
    final theme = _getTheme(context);
    final s = stringsOf(context);
    final phone = widget.compact ?? isPhone(context);

    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: theme.bg,
          borderRadius: BorderRadius.circular(phone ? 16 : 20),
          border: Border.all(color: theme.line),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: theme.isDark ? 0.55 : 0.12),
              blurRadius: 36,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildWindowChrome(theme, phone, s),
            Expanded(
              child: phone
                  ? _buildPhoneLayout(theme, s)
                  : _buildDesktopLayout(theme, s),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // WINDOW CHROME
  // ===========================================================================
  Widget _buildWindowChrome(_SynapseTheme theme, bool phone, Strings s) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: phone ? 12 : 16,
        vertical: phone ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: theme.side,
        border: Border(bottom: BorderSide(color: theme.line)),
      ),
      child: Row(
        children: [
          // macOS window traffic dots
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TrafficDot(Color(0xFFFF5F56)),
              SizedBox(width: 6),
              _TrafficDot(Color(0xFFFFBD2E)),
              SizedBox(width: 6),
              _TrafficDot(Color(0xFF27C93F)),
            ],
          ),
          const SizedBox(width: 12),
          _SynapseLogoBadge(theme: theme),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Synapse',
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.text,
                letterSpacing: -0.2,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 127.0.0.1 Ollama localhost indicator badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
            decoration: BoxDecoration(
              color: theme.ok.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: theme.ok.withValues(alpha: 0.35)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: theme.ok,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  phone ? '127.0.0.1' : '127.0.0.1 · SQLite WAL',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: theme.ok,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // DESKTOP LAYOUT (Authentic 210px Sidebar + Main Content)
  // ===========================================================================
  Widget _buildDesktopLayout(_SynapseTheme theme, Strings s) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left Authentic Sidebar
        _buildSidebar(theme, s),
        // Main Dynamic View
        Expanded(
          child: Container(
            color: theme.bg,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: switch (_activeViewIndex) {
                0 => _buildTodayView(theme, false, s),
                1 => _buildPlanView(theme, false, s),
                2 => _buildNotesView(theme, false, s),
                3 => _buildAskView(theme, false, s),
                _ => _buildTodayView(theme, false, s),
              },
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // MOBILE LAYOUT (Top tab bar + Stacked cards)
  // ===========================================================================
  Widget _buildPhoneLayout(_SynapseTheme theme, Strings s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Mobile Mode Navigation Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: theme.side,
            border: Border(bottom: BorderSide(color: theme.line)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildMobileTabItem(
                  theme: theme,
                  icon: Icons.wb_sunny_outlined,
                  label: s.demoTabToday,
                  index: 0,
                  badge: _inboxCount > 0 ? '$_inboxCount' : null,
                ),
                const SizedBox(width: 6),
                _buildMobileTabItem(
                  theme: theme,
                  icon: Icons.calendar_view_week_outlined,
                  label: s.demoTabPlan,
                  index: 1,
                ),
                const SizedBox(width: 6),
                _buildMobileTabItem(
                  theme: theme,
                  icon: Icons.description_outlined,
                  label: s.demoTabNotes,
                  index: 2,
                ),
                const SizedBox(width: 6),
                _buildMobileTabItem(
                  theme: theme,
                  icon: Icons.auto_awesome_outlined,
                  label: s.demoTabAsk,
                  index: 3,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: switch (_activeViewIndex) {
              0 => _buildTodayView(theme, true, s),
              1 => _buildPlanView(theme, true, s),
              2 => _buildNotesView(theme, true, s),
              3 => _buildAskView(theme, true, s),
              _ => _buildTodayView(theme, true, s),
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMobileTabItem({
    required _SynapseTheme theme,
    required IconData icon,
    required String label,
    required int index,
    String? badge,
  }) {
    final active = _activeViewIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _activeViewIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? theme.hover : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: active ? Border.all(color: theme.line2) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: active ? theme.text : theme.muted),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color: active ? theme.text : theme.muted,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: theme.aiBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badge,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: theme.ai,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // SIDEBAR (Authentic Synapse Sidebar with ScrollView to prevent overflow)
  // ===========================================================================
  Widget _buildSidebar(_SynapseTheme theme, Strings s) {
    return Container(
      width: 216,
      decoration: BoxDecoration(
        color: theme.side,
        border: Border(right: BorderSide(color: theme.line)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Action 1: New capture button
            GestureDetector(
              onTap: () {
                setState(() => _activeViewIndex = 0);
              },
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  color: theme.text,
                  borderRadius: BorderRadius.circular(9),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Icon(Icons.add_rounded, size: 16, color: theme.bg),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        s.demoNewCapture,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: theme.bg,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: theme.bg.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'N',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: theme.bg,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 7),
            // Action 2: Search or jump to bar
            Container(
              height: 32,
              decoration: BoxDecoration(
                color: theme.panel,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.line),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 9),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, size: 14, color: theme.faint),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      s.demoSearchJump,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: theme.faint,
                      ),
                    ),
                  ),
                  Text(
                    'Ctrl K',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 9.5,
                      color: theme.faint,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Navigation items
            _buildSidebarNavItem(
              theme: theme,
              icon: Icons.wb_sunny_outlined,
              label: s.demoTabToday,
              isActive: _activeViewIndex == 0,
              onTap: () => setState(() => _activeViewIndex = 0),
            ),
            _buildSidebarNavItem(
              theme: theme,
              icon: Icons.inbox_outlined,
              label: 'Inbox',
              badge: _inboxCount > 0 ? '$_inboxCount' : null,
              badgeColor: theme.ai,
              badgeBg: theme.aiBg,
              isActive: false,
              onTap: () => setState(() => _activeViewIndex = 0),
            ),
            _buildSidebarNavItem(
              theme: theme,
              icon: Icons.calendar_view_week_outlined,
              label: s.demoTabPlan,
              isActive: _activeViewIndex == 1,
              onTap: () => setState(() => _activeViewIndex = 1),
            ),
            _buildSidebarNavItem(
              theme: theme,
              icon: Icons.description_outlined,
              label: 'Notes',
              isActive: _activeViewIndex == 2,
              onTap: () => setState(() => _activeViewIndex = 2),
            ),
            _buildSidebarNavItem(
              theme: theme,
              icon: Icons.auto_awesome_outlined,
              label: s.demoTabAsk,
              isActive: _activeViewIndex == 3,
              onTap: () => setState(() => _activeViewIndex = 3),
            ),
            const SizedBox(height: 8),
            // AI Suggestions dashed card
            GestureDetector(
              onTap: () => setState(() => _activeViewIndex = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
                decoration: BoxDecoration(
                  color: theme.aiBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.aiLine),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_awesome_outlined,
                      size: 13,
                      color: theme.ai,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'AI suggestions',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: theme.ai,
                        ),
                      ),
                    ),
                    Text(
                      '$_inboxCount waiting',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9.5,
                        color: theme.ai,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Projects List Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'PROJECTS',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: theme.faint,
                      ),
                    ),
                  ),
                  Text(
                    'Edit',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 9.5,
                      color: theme.faint,
                    ),
                  ),
                ],
              ),
            ),
            // Projects list
            for (final proj in _defaultProjects)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 1.5),
                child: Container(
                  height: 26,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color:
                              theme.projectColors[proj.colorIndex %
                                  theme.projectColors.length],
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          proj.name,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            color: theme.muted,
                          ),
                        ),
                      ),
                      Text(
                        '${proj.openCount}',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          color: theme.faint,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 14),
            // Bottom Local AI status widget
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: theme.panel,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: theme.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: theme.ok,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          s.demoLocalModelStatus,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: theme.text,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    s.demoLocalPrivacyNotice,
                    style: GoogleFonts.inter(fontSize: 9.5, color: theme.faint),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarNavItem({
    required _SynapseTheme theme,
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    String? badge,
    Color? badgeColor,
    Color? badgeBg,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isActive ? theme.hover : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          children: [
            Icon(icon, size: 15, color: isActive ? theme.text : theme.muted),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? theme.text : theme.muted,
                ),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: badgeBg ?? theme.hover,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badge,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: badgeColor ?? theme.muted,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // VIEW 0: TODAY DASHBOARD
  // ===========================================================================
  Widget _buildTodayView(_SynapseTheme theme, bool phone, Strings s) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 640;

        return SingleChildScrollView(
          key: const ValueKey('today_view'),
          padding: EdgeInsets.all(phone ? 12 : 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header: Date & Greeting
              _buildTodayHeader(theme, phone, s),
              const SizedBox(height: 16),
              // Quick Capture Card
              _buildQuickCaptureCard(theme, phone, s),
              const SizedBox(height: 18),
              // Two-column or Single-column layout based on available space
              if (wide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildFocusSection(theme, phone, s),
                          const SizedBox(height: 18),
                          _buildRecentlyTouchedSection(theme, phone, s),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildReviewSection(theme, phone, s),
                          const SizedBox(height: 16),
                          _buildMeetingsSection(theme, phone, s),
                          const SizedBox(height: 16),
                          _buildThisWeekChart(theme, phone, s),
                        ],
                      ),
                    ),
                  ],
                )
              else ...[
                _buildFocusSection(theme, phone, s),
                const SizedBox(height: 16),
                _buildReviewSection(theme, phone, s),
                const SizedBox(height: 16),
                _buildRecentlyTouchedSection(theme, phone, s),
                const SizedBox(height: 16),
                _buildMeetingsSection(theme, phone, s),
                const SizedBox(height: 16),
                _buildThisWeekChart(theme, phone, s),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTodayHeader(_SynapseTheme theme, bool phone, Strings s) {
    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 12
        ? 'Good morning.'
        : hour < 18
        ? 'Good afternoon.'
        : 'Good evening.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MON 26 OCT · WEEK 43',
          style: GoogleFonts.jetBrainsMono(
            fontSize: phone ? 10.5 : 11.5,
            fontWeight: FontWeight.w600,
            color: theme.faint,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          greeting,
          style: GoogleFonts.inter(
            fontSize: phone ? 22 : 28,
            fontWeight: FontWeight.w700,
            color: theme.text,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$_dueTodayTasksCount ${_dueTodayTasksCount == 1 ? "task is" : "tasks are"} due today and $_overdueTasksCount ${_overdueTasksCount == 1 ? "is" : "are"} overdue. $_inboxCount ${_inboxCount == 1 ? "item is" : "items are"} waiting for your review.',
          style: GoogleFonts.inter(
            fontSize: phone ? 12 : 13.5,
            color: theme.muted,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickCaptureCard(_SynapseTheme theme, bool phone, Strings s) {
    return Container(
      padding: EdgeInsets.all(phone ? 12 : 14),
      decoration: BoxDecoration(
        color: theme.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'CAPTURE',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: theme.faint,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              if (_justSavedCapture)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded, size: 12, color: theme.ok),
                    const SizedBox(width: 4),
                    Text(
                      'Saved to Inbox!',
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: theme.ok,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _captureTextController,
            style: GoogleFonts.inter(
              fontSize: phone ? 13 : 14,
              color: theme.text,
            ),
            maxLines: 2,
            minLines: 1,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              hintText: s.demoQuickCapturePlaceholder,
              hintStyle: GoogleFonts.inter(
                fontSize: phone ? 12.5 : 13.5,
                color: theme.faint,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 30,
                  child: TextField(
                    controller: _captureTagController,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      color: theme.text,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 7,
                      ),
                      filled: true,
                      fillColor: theme.bg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: theme.line),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: theme.line),
                      ),
                      hintText: '#tags (comma-separated)',
                      hintStyle: GoogleFonts.jetBrainsMono(
                        fontSize: 10.5,
                        color: theme.faint,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _saveQuickCapture,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.text,
                  foregroundColor: theme.bg,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                child: Text(
                  s.demoSaveCapture,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFocusSection(_SynapseTheme theme, bool phone, Strings s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      s.demoFocusTitle,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: theme.text,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$_openTasksCount open',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      color: theme.faint,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: GestureDetector(
                onTap: () => setState(() => _activeViewIndex = 1),
                child: Text(
                  s.demoPlanWeek,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: theme.muted,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: theme.panel,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: theme.line),
          ),
          child: Column(
            children: [
              for (var i = 0; i < _tasks.length; i++) ...[
                if (i > 0) Divider(height: 1, thickness: 1, color: theme.line),
                _buildTaskRow(_tasks[i], theme, phone),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTaskRow(_TaskData task, _SynapseTheme theme, bool phone) {
    final proj = _defaultProjects.firstWhere(
      (p) => p.id == task.projectId,
      orElse: () => _defaultProjects.first,
    );
    final dotColor =
        theme.projectColors[proj.colorIndex % theme.projectColors.length];

    Color dueColor = theme.faint;
    if (task.urgency == _UrgencyLevel.overdue) {
      dueColor = theme.bad;
    } else if (task.urgency == _UrgencyLevel.dueToday) {
      dueColor = theme.due;
    } else if (task.urgency == _UrgencyLevel.dueSoon) {
      dueColor = theme.info;
    }

    return InkWell(
      onTap: () => _toggleTask(task.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Checkbox Circle
            Container(
              width: 17,
              height: 17,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: task.isDone ? theme.ok : theme.line2,
                  width: 1.5,
                ),
                color: task.isDone ? theme.ok : Colors.transparent,
              ),
              child: task.isDone
                  ? Icon(Icons.check, size: 11, color: theme.bg)
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                task.title,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: task.isDone ? theme.faint : theme.text,
                  decoration: task.isDone ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            const SizedBox(width: 6),
            // Project badge
            if (!phone) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: dotColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  proj.name,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 11, color: theme.muted),
                ),
              ),
              const SizedBox(width: 8),
            ],
            // Due date badge
            Text(
              task.dueDate,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: dueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentlyTouchedSection(
    _SynapseTheme theme,
    bool phone,
    Strings s,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                s.demoRecentlyTouched,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: theme.text,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => setState(() => _activeViewIndex = 2),
              child: Text(
                s.demoAllNotes,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: theme.muted,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final note in _vaultNotes.take(3))
              GestureDetector(
                onTap: () => _openNote(note.id),
                child: Container(
                  width: phone ? double.infinity : 170,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.panel,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: theme.line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.fileName,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: theme.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        note.tags.map((t) => '#$t').join(' '),
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          color: theme.muted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Updated today',
                        style: GoogleFonts.inter(
                          fontSize: 9.5,
                          color: theme.faint,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewSection(_SynapseTheme theme, bool phone, Strings s) {
    final pendingReviews = _reviewItems
        .where((r) => r.status == _ReviewStatus.pending)
        .toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.aiBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.aiLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_outlined, size: 15, color: theme.ai),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  s.demoReviewTitle,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.text,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.ai.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${pendingReviews.length}',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: theme.ai,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            s.demoReviewSub,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: theme.muted,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          if (pendingReviews.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Inbox zero! All suggestions and captures reviewed.',
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  color: theme.ok,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            for (final item in pendingReviews.take(2))
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.panel,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      item.title,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        color: theme.faint,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        ElevatedButton(
                          onPressed: () => _acceptReview(item),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.aiBg,
                            foregroundColor: theme.ai,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            minimumSize: const Size(0, 26),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                              side: BorderSide(color: theme.aiLine),
                            ),
                          ),
                          child: Text(
                            s.demoAccept,
                            style: GoogleFonts.inter(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => _dismissReview(item),
                          style: TextButton.styleFrom(
                            foregroundColor: theme.faint,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            minimumSize: const Size(0, 26),
                          ),
                          child: Text(
                            s.demoDismiss,
                            style: GoogleFonts.inter(fontSize: 10.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildMeetingsSection(_SynapseTheme theme, bool phone, Strings s) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.panel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  s.demoMeetingsTitle,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.text,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                s.demoCalendar,
                style: GoogleFonts.inter(fontSize: 11, color: theme.muted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.raised,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(
                  '14:00',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: theme.text,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Architecture Sync',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: theme.text,
                        ),
                      ),
                      Text(
                        'Alice, Bob · CalDAV Google Sync',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: theme.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.text,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    s.demoJoinMeeting,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: theme.bg,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThisWeekChart(_SynapseTheme theme, bool phone, Strings s) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    const counts = [1, 2, 1, 3, 2, 0, 1];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.panel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  s.demoThisWeekTitle,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.text,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '10 ${s.demoTasksCount}',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  color: theme.faint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < 7; i++) ...[
                Column(
                  children: [
                    Container(
                      width: 14,
                      height: 10.0 + counts[i] * 9.0,
                      decoration: BoxDecoration(
                        color: i == 3 ? theme.due : theme.line2,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      days[i],
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9.5,
                        fontWeight: i == 3 ? FontWeight.w700 : FontWeight.w400,
                        color: i == 3 ? theme.text : theme.faint,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // VIEW 1: PLAN (Hybrid Week Kanban + Knowledge Graph)
  // ===========================================================================
  Widget _buildPlanView(_SynapseTheme theme, bool phone, Strings s) {
    return Container(
      key: const ValueKey('plan_view'),
      color: theme.bg,
      padding: EdgeInsets.all(phone ? 12 : 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sub-navigation: Workflow Kanban vs Graph
          Row(
            children: [
              _buildPlanSubTab(
                theme: theme,
                title: s.demoPlanWorkflow,
                active: _planSubMode == 0,
                onTap: () => setState(() => _planSubMode = 0),
              ),
              const SizedBox(width: 8),
              _buildPlanSubTab(
                theme: theme,
                title: s.demoPlanGraph,
                active: _planSubMode == 1,
                onTap: () => setState(() => _planSubMode = 1),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: _planSubMode == 0
                ? _buildKanbanWorkflow(theme, phone)
                : _buildDependencyGraph(theme, phone, s),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanSubTab({
    required _SynapseTheme theme,
    required String title,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? theme.panel : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: active ? theme.line2 : theme.line),
        ),
        child: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 11.5,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            color: active ? theme.text : theme.muted,
          ),
        ),
      ),
    );
  }

  Widget _buildKanbanWorkflow(_SynapseTheme theme, bool phone) {
    final columns = [
      (
        title: 'OVERDUE',
        badgeColor: theme.bad,
        tasks: _tasks.where((t) => t.urgency == _UrgencyLevel.overdue).toList(),
      ),
      (
        title: 'TODAY',
        badgeColor: theme.due,
        tasks: _tasks
            .where((t) => t.urgency == _UrgencyLevel.dueToday)
            .toList(),
      ),
      (
        title: 'THIS WEEK',
        badgeColor: theme.info,
        tasks: _tasks.where((t) => t.urgency == _UrgencyLevel.dueSoon).toList(),
      ),
      (
        title: 'LATER',
        badgeColor: theme.muted,
        tasks: _tasks.where((t) => t.urgency == _UrgencyLevel.onTrack).toList(),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final col in columns) ...[
                  Container(
                    width: phone ? 220 : 250,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.panel,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: theme.line),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: col.badgeColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                col.title,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: col.badgeColor,
                                ),
                              ),
                            ),
                            Text(
                              '${col.tasks.length}',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                color: theme.faint,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        for (final t in col.tasks)
                          GestureDetector(
                            onTap: () =>
                                setState(() => _selectedKanbanTaskId = t.id),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _selectedKanbanTaskId == t.id
                                    ? theme.hover
                                    : theme.bg,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _selectedKanbanTaskId == t.id
                                      ? theme.info
                                      : theme.line,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.title,
                                    style: GoogleFonts.inter(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: theme.text,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Text(
                                        t.dueDate,
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 9.5,
                                          color: col.badgeColor,
                                        ),
                                      ),
                                      if (t.dependsOn != null) ...[
                                        const Spacer(),
                                        Icon(
                                          Icons.link,
                                          size: 12,
                                          color: theme.ok,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          'Waits',
                                          style: GoogleFonts.jetBrainsMono(
                                            fontSize: 9,
                                            color: theme.ok,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        // Selected Task Inspector Bar
        if (_selectedKanbanTaskId != null) ...[
          const SizedBox(height: 10),
          _buildKanbanInspector(theme),
        ],
      ],
    );
  }

  Widget _buildKanbanInspector(_SynapseTheme theme) {
    final t = _tasks.firstWhere(
      (task) => task.id == _selectedKanbanTaskId,
      orElse: () => _tasks.first,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.line2),
      ),
      child: Row(
        children: [
          Icon(Icons.tune_rounded, size: 15, color: theme.info),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t.title,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.text,
                  ),
                ),
                Text(
                  t.dependsOn != null
                      ? 'Dependency: waits for [[${t.dependsOn}]]'
                      : 'No blocking dependencies · Ready to execute',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    color: t.dependsOn != null ? theme.ok : theme.faint,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () => _toggleTask(t.id),
            style: ElevatedButton.styleFrom(
              backgroundColor: t.isDone ? theme.line : theme.ok,
              foregroundColor: t.isDone ? theme.text : theme.bg,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: const Size(0, 28),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(
              t.isDone ? 'Mark Unfinished' : 'Mark Done',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDependencyGraph(_SynapseTheme theme, bool phone, Strings s) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _KnowledgeGraphPainter(
                selectedId: _selectedNoteId,
                notes: _vaultNotes,
                theme: theme,
              ),
            ),
            for (var i = 0; i < _vaultNotes.length; i++)
              _buildGraphNodeWidget(
                _vaultNotes[i],
                i,
                _vaultNotes.length,
                constraints.maxWidth,
                constraints.maxHeight,
                phone,
                theme,
              ),
          ],
        );
      },
    );
  }

  Widget _buildGraphNodeWidget(
    _VaultNote note,
    int index,
    int total,
    double width,
    double height,
    bool phone,
    _SynapseTheme theme,
  ) {
    final center = Offset(width / 2, height / 2);
    final radius = math.min(width, height) * 0.35;
    final angle = (index * 2 * math.pi / total) - (math.pi / 2);
    final x = center.dx + radius * math.cos(angle);
    final y = center.dy + radius * math.sin(angle);
    final isSelected = note.id == _selectedNoteId;

    return Positioned(
      left: x - (phone ? 55 : 65),
      top: y - 20,
      child: GestureDetector(
        onTap: () => setState(() => _selectedNoteId = note.id),
        child: Container(
          width: phone ? 110 : 130,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? theme.hover : theme.panel,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? theme.ai : theme.line,
              width: isSelected ? 1.6 : 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isSelected ? theme.ai : theme.muted,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  note.fileName,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? theme.text : theme.muted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // VIEW 2: NOTES (Vault Editor & Wikilinks)
  // ===========================================================================
  Widget _buildNotesView(_SynapseTheme theme, bool phone, Strings s) {
    final note = _currentNote;

    return Row(
      key: const ValueKey('notes_view'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!phone)
          Container(
            width: 200,
            decoration: BoxDecoration(
              color: theme.side,
              border: Border(right: BorderSide(color: theme.line)),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _vaultNotes.length,
              itemBuilder: (context, idx) {
                final item = _vaultNotes[idx];
                final isSelected = item.id == _selectedNoteId;
                return GestureDetector(
                  onTap: () => setState(() => _selectedNoteId = item.id),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 3),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? theme.hover : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 13,
                          color: isSelected ? theme.text : theme.faint,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.fileName,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10.5,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected ? theme.text : theme.muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        Expanded(
          child: Container(
            color: theme.bg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.panel,
                    border: Border(bottom: BorderSide(color: theme.line)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.edit_note_rounded, size: 14, color: theme.ai),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '~/vault/${note.fileName}',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: theme.text,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${note.wordCount} words · UTF-8',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          color: theme.faint,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(phone ? 12 : 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // YAML Frontmatter block
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.side,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: theme.line),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '---',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 10,
                                  color: theme.faint,
                                ),
                              ),
                              for (final entry in note.frontmatter.entries)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 1,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${entry.key}: ',
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 10,
                                          color: theme.ai,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          entry.value,
                                          style: GoogleFonts.jetBrainsMono(
                                            fontSize: 10,
                                            color: theme.ok,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              Text(
                                '---',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 10,
                                  color: theme.faint,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          note.title,
                          style: GoogleFonts.inter(
                            fontSize: phone ? 16 : 20,
                            fontWeight: FontWeight.w700,
                            color: theme.text,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        for (final line in note.contentLines)
                          _buildContentLine(line, theme, phone),
                        const SizedBox(height: 18),
                        // Wikilinks bar
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.panel,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: theme.line),
                          ),
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'WIKILINKS:',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: theme.ai,
                                ),
                              ),
                              for (final linkId in note.connectedNoteIds)
                                GestureDetector(
                                  onTap: () => _openNote(linkId),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.aiBg,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(color: theme.aiLine),
                                    ),
                                    child: Text(
                                      '[[$linkId]]',
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: theme.ai,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentLine(String line, _SynapseTheme theme, bool phone) {
    if (line.isEmpty) return const SizedBox(height: 6);

    if (line.startsWith('# ')) {
      return Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Text(
          line.substring(2),
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: theme.text,
          ),
        ),
      );
    }

    if (line.startsWith('## ')) {
      return Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Text(
          line.substring(3),
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: theme.ai,
          ),
        ),
      );
    }

    final wikiMatch = RegExp(r'\[\[(.*?)\]\]').firstMatch(line);
    if (wikiMatch != null) {
      final before = line.substring(0, wikiMatch.start);
      final target = wikiMatch.group(1)!;
      final after = line.substring(wikiMatch.end);

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              before,
              style: GoogleFonts.inter(fontSize: 12, color: theme.muted),
            ),
            GestureDetector(
              onTap: () => _openNote(target),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 1.5,
                ),
                decoration: BoxDecoration(
                  color: theme.aiBg,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: theme.aiLine),
                ),
                child: Text(
                  '[[$target]]',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: theme.ai,
                  ),
                ),
              ),
            ),
            Text(
              after,
              style: GoogleFonts.inter(fontSize: 12, color: theme.muted),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        line,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: theme.muted,
          height: 1.45,
        ),
      ),
    );
  }

  // ===========================================================================
  // VIEW 3: ASK AI (Local Ollama Grounded Assistant)
  // ===========================================================================
  Widget _buildAskView(_SynapseTheme theme, bool phone, Strings s) {
    return Container(
      key: const ValueKey('ask_view'),
      color: theme.bg,
      padding: EdgeInsets.all(phone ? 12 : 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Local Model Indicator banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: theme.panel,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.line),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome_outlined, size: 14, color: theme.ai),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    s.demoAiModel,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: theme.text,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.ok.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    s.demoAiCloudZero,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: theme.ok,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Suggested prompts chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final item in _aiConversations)
                  GestureDetector(
                    onTap: () => _submitAiPrompt(item.question),
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: theme.panel,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: theme.line),
                      ),
                      child: Text(
                        item.question,
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          color: theme.muted,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Conversation messages list
          Expanded(
            child: ListView.builder(
              itemCount: _conversation.length,
              itemBuilder: (context, idx) {
                final ex = _conversation[idx];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // User message
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: theme.hover,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: theme.line2),
                          ),
                          child: Text(
                            ex.question,
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: theme.text,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Assistant response
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.panel,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: theme.line),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: theme.ok,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'Synapse Grounded AI',
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      color: theme.ok,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  ex.metric,
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 9.5,
                                    color: theme.faint,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              ex.answer,
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                color: theme.text,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.bookmark_outline,
                                  size: 12,
                                  color: theme.ai,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  ex.citation,
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 9.5,
                                    color: theme.ai,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Input bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: theme.panel,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.line),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _aiCustomPromptController,
                    style: GoogleFonts.inter(fontSize: 12, color: theme.text),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      hintText:
                          'Ask Ollama about notes, tasks or architecture…',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: theme.faint,
                      ),
                    ),
                    onSubmitted: _submitAiPrompt,
                  ),
                ),
                GestureDetector(
                  onTap: () => _submitAiPrompt(_aiCustomPromptController.text),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: theme.text,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.arrow_upward_rounded,
                      size: 14,
                      color: theme.bg,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// HELPER COMPONENTS & PAINTERS
// =============================================================================

class _TrafficDot extends StatelessWidget {
  const _TrafficDot(this.color);
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _SynapseLogoBadge extends StatelessWidget {
  const _SynapseLogoBadge({required this.theme});
  final _SynapseTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: theme.text,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Center(child: Icon(Icons.hub_rounded, size: 12, color: theme.bg)),
    );
  }
}

class _KnowledgeGraphPainter extends CustomPainter {
  _KnowledgeGraphPainter({
    required this.selectedId,
    required this.notes,
    required this.theme,
  });

  final String selectedId;
  final List<_VaultNote> notes;
  final _SynapseTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.35;

    final positions = <String, Offset>{};
    for (var i = 0; i < notes.length; i++) {
      final angle = (i * 2 * math.pi / notes.length) - (math.pi / 2);
      positions[notes[i].id] = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
    }

    final edgePaint = Paint()
      ..color = theme.line2
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final activeEdgePaint = Paint()
      ..color = theme.ai
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    for (final note in notes) {
      final p1 = positions[note.id];
      if (p1 == null) continue;

      for (final targetId in note.connectedNoteIds) {
        final p2 = positions[targetId];
        if (p2 == null) continue;

        final isConnectedToSelected =
            note.id == selectedId || targetId == selectedId;

        canvas.drawLine(
          p1,
          p2,
          isConnectedToSelected ? activeEdgePaint : edgePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _KnowledgeGraphPainter oldDelegate) {
    return oldDelegate.selectedId != selectedId ||
        oldDelegate.theme.isDark != theme.isDark;
  }
}
