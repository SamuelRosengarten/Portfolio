import 'package:flutter/material.dart';

import 'app_language.dart';

/// All translated copy on the site, keyed by getter name rather than by a
/// lookup string — a typo in a key becomes a compile error instead of a
/// silent fallback. Strings that are identical in both languages (proper
/// nouns, URLs, "Contact") are left as literals at their call site instead
/// of being duplicated here.
class Strings {
  const Strings(this.lang);

  final AppLanguage lang;

  bool get _fr => lang == AppLanguage.fr;

  // Header ---------------------------------------------------------------

  String get openNavigation => _fr ? 'Ouvrir la navigation' : 'Open navigation';
  String get switchToLightMode =>
      _fr ? 'Passer au mode clair' : 'Switch to light mode';
  String get switchToDarkMode =>
      _fr ? 'Passer au mode sombre' : 'Switch to dark mode';
  String get switchToFrench => 'Passer au français';
  String get switchToEnglish => 'Switch to English';

  // About ------------------------------------------------------------------

  String get heroGreeting => _fr ? "Salut, je suis Samuel" : "Hi, I'm Samuel";

  String get aboutBio => _fr
      ? "Ingénieur logiciel axé sur les systèmes locaux (Local-First) et "
          "l'IA embarquée. Après avoir forgé mon exigence de précision et "
          "de durabilité dans la soudure et la mécanique, j'applique cette "
          "rigueur d'artisan au code : architectures SQL sans compromis, "
          "souveraineté des données et modèles d'IA sur l'appareil. "
          "Créateur de Synapse OS, ouvert aux stages pour mars 2027."
      : 'Software engineer focused on local-first systems and on-device AI. '
          'Having forged my discipline for precision and durability in '
          'welding and mechanics, I bring that same craftsman\'s rigor to '
          'code: uncompromised SQL architectures, complete data '
          'sovereignty, and private on-device intelligence. Creator of '
          'Synapse OS, open to internships for March 2027.';

  String get openToInternships => _fr
      ? 'Disponible · Stage mars 2027'
      : 'Available · Internship March 2027';

  String get languagesAndTools =>
      _fr ? 'LANGAGES & OUTILS' : 'LANGUAGES & TOOLS';

  // Synapse OS Section & Deep Dive -----------------------------------------

  String get projectEyebrow =>
      _fr ? 'SYSTÈME D\'EXPLOITATION LOCAL-FIRST' : 'LOCAL-FIRST PERSONAL OS';

  String get projectHeadline => 'Synapse OS.';

  String get projectSubhead => _fr
      ? "Un système d'exploitation de connaissances souverain — zéro télémétrie cloud, SQL pur et IA embarquée avec Ollama."
      : 'A local-first sovereign knowledge operating system — zero cloud telemetry, plain SQL, and on-device AI with Ollama.';

  String get projectDescription => _fr
      ? "Votre esprit, votre machine. Jamais dans le cloud. Une plateforme open source conçue pour gérer coffres Markdown, wikilinks bidirectionnels, tâches et idées avec des performances natives instantanées (SQLite WAL), une recherche FTS5 sous la milliseconde et une IA locale privée sans abonnement."
      : 'Your Mind, Your Machine. Never the Cloud. An open-source local-first OS designed to manage Markdown vaults, bi-directional wikilinks, tasks, and ideas with native instant performance (SQLite WAL), sub-millisecond FTS5 search, and private on-device AI without recurring subscriptions.';

  String get viewWebsite =>
      _fr ? 'Explorer synapse-os.ca' : 'Explore synapse-os.ca';
  String get viewOnMarketplace => viewWebsite;
  String get sourceOnGitHub =>
      _fr ? 'Code source sur GitHub' : 'Source on GitHub';

  String get tagLocalFirstOs =>
      _fr ? 'Système Local-First' : 'Local-First OS';
  String get tagZeroCloudAi => _fr ? 'IA Zéro-Cloud' : 'Zero-Cloud AI';
  String get tagNextJsSqlite =>
      _fr ? 'Next.js 15 · SQLite WAL' : 'Next.js 15 · SQLite WAL';

  String get tagVsCodeExtension => tagLocalFirstOs;
  String get tagPublished => tagZeroCloudAi;
  String get publishedOnMarketplace =>
      _fr ? 'Déployé sur synapse-os.ca' : 'Deployed on synapse-os.ca';

  // Workstation Demo strings
  String get demoTabEditor => _fr ? 'Éditeur Vault' : 'Vault Editor';
  String get demoTabGraph => _fr ? 'Graphe de Savoir' : 'Knowledge Graph';
  String get demoTabSearch => _fr ? 'Recherche FTS5' : 'FTS5 Search';
  String get demoTabAi => _fr ? 'IA Locale (Ollama)' : 'Local AI (Ollama)';

  String get demoStatusLocalhost => '127.0.0.1';
  String get demoStatusWal => 'SQLite WAL';
  String get demoStatusZeroCloud => _fr ? '0 octet sortant' : '0B Outbound';
  String get demoStatusTests => _fr ? '400+ tests validés' : '400+ Passing Tests';

  String get demoEditorOpenFile => _fr ? 'FICHIERS DU COFFRE' : 'VAULT FILES';
  String get demoEditorWordCount => _fr ? 'mots' : 'words';
  String get demoEditorLocalDisk => _fr ? 'Disque local' : 'Local disk';

  String get demoGraphTitle =>
      _fr ? 'Graphe de Connaissances Bidirectionnel' : 'Bi-directional Knowledge Graph';
  String get demoGraphSub => _fr
      ? 'Survolez ou cliquez sur un nœud pour inspecter les wikilinks'
      : 'Hover or click a node to inspect connected wikilinks';
  String get demoGraphNodesCount =>
      _fr ? '4 notes · 8 liens bidirectionnels' : '4 notes · 8 bi-directional links';

  String get demoSearchPlaceholder => _fr
      ? 'Rechercher dans le coffre (ex. sqlite, rag, vault)...'
      : 'Search vault (e.g. sqlite, rag, vault)...';
  String get demoResultsLabel =>
      _fr ? 'résultats · SQLite FTS5' : 'results · SQLite FTS5';
  String get demoSearchLatency =>
      _fr ? '0.4ms · better-sqlite3 WAL' : '0.4ms · better-sqlite3 WAL';

  String get demoAiModel => 'Ollama · Llama 3 (127.0.0.1)';
  String get demoAiCloudZero => _fr ? '0 appel cloud' : '0 Cloud Calls';

  // Authentic Synapse OS UI strings
  String get demoTabToday => _fr ? "Aujourd'hui" : 'Today';
  String get demoTabPlan => _fr ? 'Planifier' : 'Plan';
  String get demoTabNotes => _fr ? 'Notes du coffre' : 'Vault Notes';
  String get demoTabAsk => _fr ? "Demander à l'IA" : 'Ask AI';
  String get demoNewCapture => _fr ? 'Nouvelle capture' : 'New capture';
  String get demoSearchJump => _fr ? 'Rechercher ou aller à…' : 'Search or jump to…';
  String get demoQuickCapturePlaceholder => _fr
      ? 'Une pensée, une tâche, un lien. Sauvegardé dès que vous cliquez.'
      : 'A thought, a task, a link. It is saved the moment you press Save.';
  String get demoQuickCaptureHint => _fr
      ? 'Enregistré directement dans votre Inbox pour révision'
      : 'Saved directly to your Inbox for review';
  String get demoSaveCapture => _fr ? 'Sauvegarder' : 'Save';
  String get demoFocusTitle => _fr ? 'Priorités' : 'Focus';
  String get demoPlanWeek => _fr ? 'Planifier la semaine →' : 'Plan the week →';
  String get demoManageTasks => _fr ? 'Gérer les tâches →' : 'Manage all tasks →';
  String get demoRecentlyTouched => _fr ? 'Récemment modifiés' : 'Recently touched';
  String get demoAllNotes => _fr ? 'Toutes les notes →' : 'All notes →';
  String get demoReviewTitle => _fr ? 'En attente de révision' : 'Waiting for your review';
  String get demoReviewSub => _fr
      ? 'Captures de l’inbox et suggestions IA. Rien ne change sans votre accord.'
      : 'Captures in your inbox and AI suggestions. Nothing changes until you accept it.';
  String get demoMeetingsTitle => _fr ? 'Réunions du jour' : 'Meetings today';
  String get demoCalendar => _fr ? 'Calendrier →' : 'Calendar →';
  String get demoJoinMeeting => _fr ? 'Rejoindre' : 'Join';
  String get demoThisWeekTitle => _fr ? 'Cette semaine' : 'This week';
  String get demoTasksCount => _fr ? 'tâches' : 'tasks';
  String get demoTurnIntoTask => _fr ? 'En tâche' : 'To task';
  String get demoAccept => _fr ? 'Accepter' : 'Accept';
  String get demoDismiss => _fr ? 'Ignorer' : 'Dismiss';
  String get demoLocalModelStatus => _fr ? 'Llama 3 configuré' : 'Llama 3 configured';
  String get demoLocalPrivacyNotice =>
      _fr ? '100% local · rien ne quitte ce PC' : 'Local only · nothing leaves this PC';
  String get demoPlanWorkflow => _fr ? 'Flux hebdomadaire' : 'Week Workflow';
  String get demoPlanGraph => _fr ? 'Graphe de dépendances' : 'Dependency Graph';

  // Deep-Dive Architecture Strings
  String get archSectionEyebrow =>
      _fr ? 'ARCHITECTURE TECHNIQUE' : 'TECHNICAL ARCHITECTURE';
  String get archSectionHeadline => _fr
      ? 'Bâti pour la vitesse locale et la souveraineté absolue.'
      : 'Built for Local Speed & Absolute Sovereignty.';
  String get archSectionSubhead => _fr
      ? "Zéro dépendance distante. Bindings C natifs en mode WAL et indexation atomique du système de fichiers."
      : 'Zero remote dependencies. Native C bindings with WAL mode and atomic filesystem indexing.';

  String get archCardSqliteTitle =>
      _fr ? 'Moteur de Stockage SQLite WAL' : 'SQLite WAL Storage Engine';
  String get archCardSqliteBody => _fr
      ? "Exécution directe via better-sqlite3. Le mode WAL permet des lectures concurrentes sans bloquer les écritures, offrant un accès sous la milliseconde."
      : 'Direct in-process execution via better-sqlite3. WAL mode enables concurrent reads without locking write operations, delivering sub-millisecond access.';

  String get archCardFts5Title =>
      _fr ? 'Moteur de Recherche FTS5 Instantané' : 'Instant SQLite FTS5 Engine';
  String get archCardFts5Body => _fr
      ? "Recherche plein texte avec score BM25 exécutée nativement sur des milliers de fichiers Markdown avec zéro latence réseau."
      : 'Full-text search with BM25 relevance ranking executed natively across thousands of Markdown documents with zero network latency.';

  String get archCardWatcherTitle =>
      _fr ? 'Surveillance Atomique du Disque' : 'Atomic Filesystem Watcher';
  String get archCardWatcherBody => _fr
      ? "Des observateurs natifs détectent les modifications externes (Obsidian, Neovim) et synchronisent instantanément les [[wikilinks]] et le frontmatter YAML."
      : 'Native file watchers detect external modifications from Obsidian or Neovim, continuously parsing [[wikilinks]] and YAML frontmatter into relational tables.';

  // Benchmark Matrix Strings
  String get benchTitle => _fr
      ? 'Analyse comparative de performance & souveraineté'
      : 'Performance & Sovereignty Benchmark';
  String get benchColMetric =>
      _fr ? 'Critère architectural' : 'Architecture Metric';
  String get benchColSynapse => 'Synapse OS (Local)';
  String get benchColCloud => 'Notion / Cloud SaaS';
  String get benchColPlugins => 'Obsidian Plugins';

  String get benchRowSearchLatency =>
      _fr ? 'Recherche plein texte' : 'Full-text search query';
  String get benchValSynapseLatency =>
      _fr ? '< 1ms (SQLite WAL)' : '< 1ms (SQLite WAL)';
  String get benchValCloudLatency =>
      _fr ? '180–350ms (Réseau)' : '180–350ms (Network)';
  String get benchValPluginLatency =>
      _fr ? '30–80ms (surcharge Electron)' : '30–80ms (JS Electron)';

  String get benchRowDataPrivacy =>
      _fr ? 'Télémétrie des données' : 'Data telemetry';
  String get benchValSynapsePrivacy =>
      _fr ? '0 octet (100% hors-ligne)' : '0 bytes (Strictly offline)';
  String get benchValCloudPrivacy =>
      _fr ? 'Serveurs distants & traçage' : 'Remote servers & tracking';
  String get benchValPluginPrivacy =>
      _fr ? 'Dépend des extensions tierces' : 'Depends on 3rd-party plugins';

  String get benchRowOfflineReady =>
      _fr ? 'Fonctionnement hors-ligne' : 'Offline resilience';
  String get benchValSynapseOffline =>
      _fr ? '100% Natif & autonome' : '100% Native & autonomous';
  String get benchValCloudOffline =>
      _fr ? 'Dégradé ou inaccessible' : 'Degraded or inaccessible';
  String get benchValPluginOffline =>
      _fr ? 'Fichiers locaux seuls' : 'Local files only';

  String get benchRowVendorLockin =>
      _fr ? 'Verrou propriétaire' : 'Vendor lock-in';
  String get benchValSynapseLockin =>
      _fr ? '0% (Markdown + SQL ouvert)' : '0% (Plain Markdown + SQL)';
  String get benchValCloudLockin =>
      _fr ? 'Élevé (Blocs propriétaires)' : 'High (Proprietary blocks)';
  String get benchValPluginLockin =>
      _fr ? 'Faible (Markdown brut)' : 'Low (Plain Markdown)';

  // Craftsmanship & Philosophy Strings
  String get craftSectionEyebrow =>
      _fr ? 'ARTISANAT LOGICIEL' : 'SOFTWARE CRAFTSMANSHIP';
  String get craftSectionHeadline => _fr
      ? 'Votre esprit, votre machine. Jamais dans le cloud.'
      : 'Your Mind, Your Machine. Never the Cloud.';
  String get craftSectionBody => _fr
      ? "Forgé avec la même rigueur sans compromis développée durant des années en soudure et mécanique : des soudures structurelles nettes, des matériaux durables et zéro fragilité cachée. Synapse OS est conçu pour durer, redonnant à chacun la souveraineté totale sur ses idées."
      : 'Forged with the same uncompromising discipline developed over years of welding and mechanical fabrication: clean structural welds, durable materials, and zero hidden fragilities. Synapse OS is crafted for durability, giving users complete sovereignty over their thoughts.';

  // Legacy demo compat getters for tests -----------------------------------
  String get demoCheck => _fr ? 'Exécuter requête' : 'Run query';
  String get demoTryIt =>
      _fr ? 'Essayez : recherche instantanée' : 'Try it: instant search';
  String get demoStatsTab => 'Stats';
  String get demoCodeCoach => 'SYNAPSE OS';
  String get demoYourWeek => _fr ? 'Télémétrie locale' : 'Local telemetry';
  String get demoMistakesPerWeek =>
      _fr ? 'Requêtes locales / sec' : 'Local queries / sec';
  String get demoWeeks => _fr ? '400+ tests réussis' : '400+ tests passing';
  String get demoByKind =>
      _fr ? 'INDEX FTS5 · WAL MODE' : 'FTS5 INDEX · WAL MODE';
  String get demoMute => _fr ? 'HORS-LIGNE' : 'OFFLINE';
  String get demoMuted => _fr ? 'DÉCONNECTÉ' : 'DISCONNECTED';
  String demoSeen(int n) =>
      _fr ? '$n ms latence locale' : '$n ms local latency';
  List<String> get demoKinds => _fr
      ? const [
          'Index SQLite WAL',
          'Parseur de Coffre Markdown',
          'IA Embarquée Ollama',
        ]
      : const [
          'SQLite WAL Index',
          'Markdown Vault Parser',
          'Ollama On-Device AI',
        ];
  List<String> get demoHints => _fr
      ? const [
          "Exécution directe via better-sqlite3 sans blocage réseau.",
          "Extraction automatique des wikilinks [[Note]] et métadonnées frontmatter.",
          "Inférence locale stricte sur 127.0.0.1 avec zéro fuite de données.",
        ]
      : const [
          'Direct in-process execution via better-sqlite3 with zero network hops.',
          'Automatic extraction of [[Note]] wikilinks and frontmatter metadata.',
          'Strict local inference on 127.0.0.1 with zero data leakage.',
        ];
  String get demoDisclaimer => _fr
      ? 'Recréation interactive de Synapse OS — Explorez sur synapse-os.ca'
      : 'Interactive recreation of Synapse OS — Explore live at synapse-os.ca';

  // Contact ------------------------------------------------------------------

  String get contactHeadline => _fr ? 'Discutons.' : "Let's talk.";

  String get contactSubhead => _fr
      ? "À la recherche d'un stage en mars 2027 — aussi ouvert aux "
          "collaborations et discussions sur les architectures logicielles "
          "et l'IA locale."
      : 'Looking for an internship in March 2027 — also open to '
          'collaborations and discussions about software architectures '
          'and local AI.';

  String get locationLabel => _fr ? 'Localisation' : 'Location';

  // Hobbies ------------------------------------------------------------------

  String get beyondTheCode => _fr ? 'AU-DELÀ DU CODE' : 'BEYOND THE CODE';

  String get goalLabel => _fr ? 'OBJECTIF' : 'GOAL';
  String get buildHeadline => _fr ? 'Construire.' : 'Build.';

  String get buildParagraph => _fr
      ? "Après des années sur le plancher d'usine comme soudeur et "
          "mécanicien, l'objectif est de bâtir des logiciels souverains et "
          "durables — troquer le chalumeau pour le clavier, avec un stage "
          "en mars 2027 comme tremplin."
      : 'After years on the shop floor as a welder and mechanic, '
          'the focus is on building sovereign, enduring software — '
          'trading the torch for the keyboard, with an internship in '
          'March 2027 as the next milestone.';

  String get tutoringTitle =>
      _fr ? "Mentorat & Partage technique" : 'Mentoring & Technical Sharing';

  String get tutoringParagraph => _fr
      ? "Accompagnement d'autres étudiants en programmation au "
          "Cégep Édouard-Montpetit, en vulgarisant les structures de "
          "données complexes et les bonnes pratiques de conception."
      : 'Mentoring fellow programming students at '
          "Cégep Édouard-Montpetit, demystifying complex data "
          "structures and clean architectural patterns.";

  String get tagPatience => _fr ? 'Patience' : 'Patience';
  String get tagEmpathy => _fr ? 'Rigueur' : 'Rigor';
  String get tagTeamPlayer =>
      _fr ? 'Architecture logicielle' : 'Software architecture';

  String get hobbyLabel => _fr ? 'PASSE-TEMPS' : 'HOBBY';
  String get craftHeadline => _fr ? 'Créer.' : 'Craft.';

  String get craftParagraph => _fr
      ? "Couper, coudre, polir — des pièces qui prennent des heures et "
          "s'améliorent à chaque fois. La maroquinerie et la couture "
          "sellier m'ont appris l'exigence de la précision et le refus "
          "des raccourcis."
      : 'Cutting, stitching, burnishing — pieces that take hours and '
          'get better with every one. Leatherworking and the saddle stitch '
          'taught me uncompromised precision and the refusal of shortcuts.';

  String get pastPiecesLabel => _fr ? 'CRÉATIONS PASSÉES' : 'PAST PIECES';

  // Redesign copy -------------------------------------------------------------

  String get heroTagline => _fr
      ? 'Du chalumeau aux systèmes souverains.'
      : 'From the torch to sovereign systems.';

  String get seeMyWork => _fr ? 'Voir mes projets' : 'See my work';

  String get getInTouch => _fr ? 'Me contacter' : 'Get in touch';

  String get pathBefore => _fr ? 'AVANT' : 'BEFORE';

  String get pathNow => _fr ? 'MAINTENANT' : 'NOW';

  String get pathNext => _fr ? 'ENSUITE' : 'NEXT';

  String get pathAfter => _fr ? 'APRÈS' : 'AFTER';

  String get pathBeforeTitle =>
      _fr ? 'Soudure et mécanique' : 'Welding & mechanics';

  String get pathBeforeBody => _fr
      ? "Des années sur le plancher d'usine — l'exigence de la précision."
      : 'Years on the shop floor — the discipline of precision.';

  String get pathNowTitle => _fr
      ? 'Systèmes & Ingénierie Logicielle'
      : 'Systems & Software Engineering';

  String get pathNowBody => _fr
      ? "Diplôme Cégep, conception de Synapse OS et mentorat technique."
      : 'Cégep diploma, architecting Synapse OS, and technical mentoring.';

  String get pathNowShort => _fr
      ? 'Systèmes logiciels + Synapse OS'
      : 'Software systems + Synapse OS';

  String get pathNextTitle =>
      _fr ? 'Stage, mars 2027' : 'Internship, March 2027';

  String get pathNextBody => _fr
      ? "Rejoindre une équipe bâtissant des systèmes à fort impact."
      : 'Joining an engineering team building high-impact systems.';

  String get pathAfterTitle => _fr
      ? 'Ingénieur Logiciel (Systèmes & IA)'
      : 'Software Engineer (Systems & AI)';

  String get pathAfterBody => _fr
      ? "Concevoir des architectures fiables, souveraines et performantes."
      : 'Architecting resilient, sovereign, high-performance software.';

  String get featureHintsTitle =>
      _fr ? 'IA Privée & Sur Machine' : 'Private On-Device AI';

  String get featureHintsBody => _fr
      ? "Intégration native Ollama (127.0.0.1) : requêtes contextuelles avec zéro octet envoyé au cloud."
      : 'Native Ollama integration (127.0.0.1): contextual vault queries with zero bytes sent to the cloud.';

  String get featureDashboardTitle =>
      _fr ? 'Coffres Markdown & Wikilinks' : 'Markdown Vaults & Wikilinks';

  String get featureDashboardBody => _fr
      ? "Notes en texte brut durables, liens bidirectionnels [[Note]] et synchronisation sans verrou propriétaire."
      : 'Future-proof plain text notes, bi-directional [[wikilinks]], and graph sync without vendor lock-in.';

  String get featureReportsTitle =>
      _fr ? 'Moteur SQLite FTS5 Instantané' : 'Instant SQLite FTS5 Engine';

  String get featureReportsBody => _fr
      ? "Recherche plein texte sous la milliseconde via better-sqlite3 en mode WAL, validée par 400+ tests."
      : 'Sub-millisecond full-text search via better-sqlite3 in WAL mode, verified by 400+ passing tests.';

  String get builtWithFlutter =>
      _fr ? 'Conçu avec Flutter' : 'Built with Flutter';

  String get goalConnectionsTitle =>
      _fr ? 'Architectures souveraines' : 'Sovereign architectures';

  String get goalConnectionsBody => _fr
      ? "Bâtir des outils qui redonnent le contrôle complet de leurs données aux utilisateurs."
      : 'Build tools that give users complete ownership of their data and thoughts.';

  String get goalJuniorTitle =>
      _fr ? 'Ingénierie haute performance' : 'High-performance engineering';

  String get goalJuniorBody => _fr
      ? "Approfondir les moteurs SQL locaux, le mode WAL et l'inférence d'IA locale à faible latence."
      : 'Deepen expertise in embedded SQL engines, WAL mode, and low-latency on-device AI inference.';

  String get goalHomeTitle =>
      _fr ? 'Artisanat logiciel' : 'Software craftsmanship';

  String get goalHomeBody => _fr
      ? "Créer des systèmes durables avec la même minutie qu'un artisan à l'établi."
      : 'Craft resilient, long-lasting systems with the same care as an artisan at the bench.';

  String get pastPiecesSwipeLabel =>
      _fr ? 'CRÉATIONS PASSÉES · GLISSER' : 'PAST PIECES · SWIPE';

  String get addPhotoLabel => _fr ? 'Ajouter une photo' : 'Add photo';

  String get photoAtTheBench =>
      _fr ? '[PHOTO À\nL\'ÉTABLI]' : '[PHOTO AT\nTHE BENCH]';

  String get photoPlaceholder => '[PHOTO]';
}

Strings stringsOf(BuildContext context) => Strings(languageOf(context));
