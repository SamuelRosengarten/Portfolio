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

  String get openToInternships =>
      _fr ? 'Ouvert aux stages, mars 2027' : 'Open to internships, March 2027';

  String get heroGreeting => _fr ? "Salut, je suis Samuel." : "Hi, I'm Samuel.";

  /// The hero headline, broken where it reads best on two lines.
  String get heroTagline =>
      _fr ? 'De la torche\nau clavier.' : 'From the torch\nto the keyboard.';

  String get aboutBio => _fr
      ? "Étudiant en programmation informatique au Cégep Édouard-Montpetit, "
            "à la recherche d'un stage en mars 2027 qui mènera à mon premier "
            "emploi de développeur junior. Avant le code, c'était la "
            "soudure et la mécanique — j'ai gardé la même exigence de bien "
            "faire le travail."
      : 'Computer programming student at Cégep Édouard-Montpetit, looking '
            'for an internship in March 2027 that leads to my first job as '
            'a junior developer. Before code it was welding and mechanics — '
            'I kept the same insistence on doing the work properly.';

  String get seeSynapse => _fr ? 'Voir Synapse OS' : 'See Synapse OS';
  String get getInTouch => _fr ? 'Me contacter' : 'Get in touch';

  String get languagesAndTools => _fr ? 'Ce que j\'utilise' : 'What I work in';

  String get pathTitle => _fr ? 'Le parcours jusqu\'ici' : 'The path so far';
  String get pathBefore => _fr ? 'Avant' : 'Before';
  String get pathNow => _fr ? 'Maintenant' : 'Now';
  String get pathNext => _fr ? 'Ensuite' : 'Next';
  String get pathAfter => _fr ? 'Après' : 'After';

  String get pathBeforeTitle =>
      _fr ? 'Soudure et mécanique' : 'Welding & mechanics';
  String get pathBeforeBody =>
      _fr ? "Des années sur le plancher d'usine." : 'Years on the shop floor.';
  String get pathNowTitle =>
      _fr ? 'Diplôme en programmation' : 'Programming diploma';
  String get pathNowBody => _fr
      ? "Cégep Édouard-Montpetit, et tutorat auprès d'autres étudiants."
      : 'Cégep Édouard-Montpetit, and tutoring other students.';
  String get pathNextTitle =>
      _fr ? 'Stage, mars 2027' : 'Internship, March 2027';
  String get pathNextBody =>
      _fr ? 'Pour terminer le diplôme.' : 'To complete the diploma.';
  String get pathAfterTitle => _fr ? 'Développeur junior' : 'Junior developer';
  String get pathAfterBody => _fr
      ? "Lancer ma carrière dans l'industrie."
      : 'Starting my career in the industry.';

  // Projects -----------------------------------------------------------------

  String get projectsHeadline => _fr ? 'Aussi publié' : 'Also shipped';

  String get projectSubhead => _fr
      ? "Une extension VS Code maintenant publiée sur le Marketplace — née "
            "du tutorat que je fais auprès d'autres étudiants et de l'envie "
            "d'un outil qui repère vos erreurs à votre place."
      : 'A VS Code extension, now published on the Marketplace — born out '
            'of tutoring other students and wanting a tool that catches '
            'your mistakes for you.';

  String get projectDescription => _fr
      ? "Transforme les erreurs que vous faites en codant en quelque chose "
            "d'utile."
      : 'Turns the mistakes you make while coding into something useful.';

  // Synapse OS -------------------------------------------------------------

  String get synapseBadge => _fr
      ? 'Mon projet principal, en bêta sur invitation'
      : 'My main project, in invite-only beta';
  String get synapseTagline =>
      _fr ? 'Votre esprit, votre machine.' : 'Your mind, your machine.';
  String get synapseLead => _fr
      ? "Un seul endroit calme pour les tâches, les notes, les réunions et "
            "la discussion d'une petite équipe — sur iPhone, iPad, Mac et le "
            "web — avec une IA qui tourne sur votre propre appareil plutôt "
            "que sur les serveurs de quelqu'un d'autre."
      : "One calm place for a small team's tasks, notes, meetings and chat "
            "— on iPhone, iPad, Mac and the web — with an AI that runs on "
            "your own device instead of someone else's servers.";
  String get platformIphone => 'iPhone & iPad';
  String get platformMac => 'Mac';
  String get platformWeb => 'Web';

  String get featurePrivateAiTitle =>
      _fr ? 'Une IA privée sur votre appareil' : 'A private AI on your device';
  String get featurePrivateAiBody => _fr
      ? "Posez des questions sur votre travail, sortez les actions d'une note "
            "de réunion et planifiez la journée avec un modèle qui tourne sur "
            "votre iPhone, votre Mac ou votre ordinateur. Aucune requête "
            "n'atteint un serveur."
      : 'Ask questions about your work, pull action items out of a meeting '
            'note and plan the day with a model that runs on your iPhone, '
            'Mac or own computer. Prompts never reach a server.';
  String get featureApproveTitle =>
      _fr ? 'Vous approuvez tout' : 'You approve everything';
  String get featureApproveBody => _fr
      ? "Les suggestions de l'IA attendent dans une file de révision. Rien "
            "n'est ajouté, modifié ou envoyé avant votre accord — et ce qui "
            "est supprimé passe d'abord par la corbeille."
      : 'AI suggestions wait in a review queue. Nothing is added, changed '
            'or sent until you accept it — and deleted work goes to the '
            'trash first.';
  String get featureTeamsTitle =>
      _fr ? 'Pensé pour les petites équipes' : 'Built for small teams';
  String get featureTeamsBody => _fr
      ? "Espaces de travail, rôles et discussion d'équipe, synchronisation "
            "en direct entre appareils, et conflits conservés pour être "
            "fusionnés plutôt qu'écrasés."
      : 'Workspaces, roles and team chat, live sync between devices, and '
            'edit conflicts that are kept for you to merge, not overwritten.';

  String get onIphone => _fr ? 'Sur iPhone' : 'On iPhone';
  String get onIphoneBody => _fr
      ? 'En SwiftUI, en clair et en sombre, avec VoiceOver et le texte '
            'agrandi partout.'
      : 'Built in SwiftUI, light and dark, with VoiceOver and large text '
            'throughout.';
  String get shotTodayTitle => _fr ? "Aujourd'hui" : 'Today';
  String get shotTodayBody => _fr
      ? "Ce qui est dû, vos réunions et la prochaine action, d'un coup d'œil."
      : 'What is due, your meetings and the next action, at a glance.';
  String get shotAskTitle => _fr ? 'Demander à Nova' : 'Ask Nova';
  String get shotAskBody => _fr
      ? 'Des questions sur vos propres notes et tâches, répondues sur le '
            'téléphone.'
      : 'Questions about your own notes and tasks, answered on the phone.';
  String get shotReviewTitle =>
      _fr ? 'Réviser avec l\'IA locale' : 'Review with local AI';
  String get shotReviewBody => _fr
      ? "Des modifications proposées pour une note, appliquées seulement "
            "quand vous le décidez."
      : 'Suggested edits to a note, applied only when you say so.';
  String get shotChatTitle => _fr ? "Discussion d'équipe" : 'Team chat';
  String get shotChatBody => _fr
      ? 'Canaux, messages privés et tâches liées directement dans le fil.'
      : 'Channels, direct messages and tasks linked right in the thread.';
  String get onMac => _fr ? 'Et sur Mac' : 'And on the Mac';
  String get onMacBody => _fr
      ? "Une vraie fenêtre native avec une barre latérale, des raccourcis "
            "clavier, les réunions dans la barre des menus et la même "
            "discussion d'équipe. Même compte, mêmes données, synchronisées "
            "en direct."
      : 'A native window with a sidebar, keyboard shortcuts, upcoming '
            'meetings in the menu bar and the same team chat. Same account, '
            'same data, synced live.';
  String get macShotLabel => _fr
      ? "Synapse sur Mac : la discussion d'équipe"
      : 'Synapse on Mac: team chat';
  String get iphoneShotLabel =>
      _fr ? 'Synapse sur iPhone : ' : 'Synapse on iPhone: ';
  String get heroShotLabel => _fr
      ? "Synapse sur Mac et sur iPhone : l'écran Aujourd'hui"
      : 'Synapse on Mac and iPhone: the Today screen';

  // Work ---------------------------------------------------------------------

  String get tagVsCodeExtension =>
      _fr ? 'Extension VS Code' : 'VS Code Extension';
  String get tagPublished => _fr ? 'Publiée' : 'Published';

  String get featureHintsTitle =>
      _fr ? 'Indices contextuels' : 'Contextual hints';
  String get featureHintsBody => _fr
      ? "Juste à côté de l'erreur, en langage clair."
      : 'Right next to the error, in plain language.';
  String get featureDashboardTitle =>
      _fr ? 'Tableau des tendances' : 'Pattern dashboard';
  String get featureDashboardBody => _fr
      ? 'Suit les erreurs qui reviennent, au fil du temps.'
      : 'Tracks which mistakes keep coming back, over time.';
  String get featureReportsTitle =>
      _fr ? 'Rapports de session' : 'Session reports';
  String get featureReportsBody => _fr
      ? 'Exportables, à apporter à un mentor ou un tuteur.'
      : 'Exportable, to bring to a mentor or tutor.';

  // Contact ------------------------------------------------------------------

  String get contactHeadline => _fr ? 'Discutons.' : "Let's talk.";

  String get contactSubhead => _fr
      ? "À la recherche d'un stage en mars 2027 — aussi ouvert aux "
            "collaborations, ou simplement à discuter de ce que vous "
            "construisez."
      : 'Looking for an internship in March 2027 — also open to '
            'collaborations, or a conversation about something you are '
            'building.';

  String get locationLabel => _fr ? 'Localisation' : 'Location';
  String get builtWithFlutter =>
      _fr ? 'Conçu avec Flutter' : 'Built with Flutter';

  // Hobbies ------------------------------------------------------------------

  String get beyondTheCode => _fr ? 'Au-delà du code' : 'Beyond the code';

  String get buildHeadline => _fr ? 'Construire.' : 'Build.';
  String get teachHeadline => _fr ? 'Enseigner.' : 'Teach.';

  String get buildParagraph => _fr
      ? "Terminer l'école, puis me mettre au travail — et continuer à "
            "construire pour le plaisir."
      : 'Finish school, then get to work — and keep building for fun.';

  String get goalConnectionsTitle =>
      _fr ? 'Créer des contacts' : 'Make connections';
  String get goalConnectionsBody => _fr
      ? "Rencontrer des gens de l'industrie à la fin de mes études."
      : 'Meet people in the industry once school wraps up.';
  String get goalJuniorTitle => _fr
      ? 'Commencer comme développeur junior'
      : 'Start as a junior developer';
  String get goalJuniorBody => _fr
      ? 'Lancer ma carrière en écrivant du code tous les jours.'
      : 'Begin my career writing code every day.';
  String get goalHomeTitle => _fr
      ? 'Réaliser des projets amusants à la maison'
      : 'Build fun projects at home';
  String get goalHomeBody => _fr
      ? 'Continuer à créer simplement par plaisir.'
      : 'Keep making things just because I enjoy it.';

  String get tutoringTitle =>
      _fr ? "Tutorat à l'école, en ce moment" : 'Tutoring at school, right now';

  String get tutoringParagraph => _fr
      ? "Je réponds aux questions d'autres étudiants en programmation au "
            "Cégep Édouard-Montpetit, en traduisant le jargon dans une "
            "langue qui parle vraiment à la personne que j'aide."
      : 'Answering questions from fellow programming students at '
            "Cégep Édouard-Montpetit, and translating the jargon into "
            "language that actually lands for whoever I'm helping.";

  String get tagPatience => _fr ? 'Patience' : 'Patience';
  String get tagEmpathy => _fr ? 'Empathie' : 'Empathy';
  String get tagTeamPlayer => _fr ? "Esprit d'équipe" : 'Team player';

  String get craftHeadline => _fr ? 'Créer.' : 'Craft.';

  String get craftParagraph => _fr
      ? "Couper, coudre, polir — des pièces qui prennent des heures et "
            "s'améliorent à chaque fois. La couture sellier m'a appris "
            "plus sur la patience qu'aucune échéance ne l'a jamais fait."
      : 'Cutting, stitching, burnishing — pieces that take hours and '
            'get better with every one. The saddle stitch taught me more '
            'about patience than any deadline ever did.';

  String get pastPiecesLabel => _fr ? 'Créations passées' : 'Past pieces';
}

Strings stringsOf(BuildContext context) => Strings(languageOf(context));
