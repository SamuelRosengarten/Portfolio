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

  String get openNavigation =>
      _fr ? 'Ouvrir la navigation' : 'Open navigation';
  String get switchToLightMode =>
      _fr ? 'Passer au mode clair' : 'Switch to light mode';
  String get switchToDarkMode =>
      _fr ? 'Passer au mode sombre' : 'Switch to dark mode';
  String get switchToFrench => 'Passer au français';
  String get switchToEnglish => 'Switch to English';

  // About ------------------------------------------------------------------

  String get openToInternships => _fr
      ? 'Ouvert aux stages · mars 2027'
      : 'Open to internships · March 2027';

  String get heroGreeting => _fr ? "Salut, je suis Samuel." : "Hi, I'm Samuel.";
  String get heroTagline =>
      _fr ? 'De la torche au clavier.' : 'From the torch to the keyboard.';

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

  String get seeMyWork => _fr ? 'Voir mes projets' : 'See my work';
  String get getInTouch => _fr ? 'Me contacter' : 'Get in touch';

  String get languagesAndTools =>
      _fr ? 'LANGAGES & OUTILS' : 'LANGUAGES & TOOLS';

  String get pathBefore => _fr ? 'AVANT' : 'BEFORE';
  String get pathNow => _fr ? 'MAINTENANT' : 'NOW';
  String get pathNext => _fr ? 'ENSUITE' : 'NEXT';
  String get pathAfter => _fr ? 'APRÈS' : 'AFTER';

  String get pathBeforeTitle =>
      _fr ? 'Soudure et mécanique' : 'Welding & mechanics';
  String get pathBeforeBody =>
      _fr ? "Des années sur le plancher d'usine." : 'Years on the shop floor.';
  String get pathNowTitle =>
      _fr ? 'Diplôme en programmation' : 'Programming diploma';
  String get pathNowBody => _fr
      ? "Cégep Édouard-Montpetit, et tutorat auprès d'autres étudiants."
      : 'Cégep Édouard-Montpetit, and tutoring other students.';
  String get pathNowShort => _fr
      ? 'Diplôme en programmation + tutorat'
      : 'Programming diploma + tutoring';
  String get pathNextTitle =>
      _fr ? 'Stage, mars 2027' : 'Internship, March 2027';
  String get pathNextBody =>
      _fr ? 'Pour terminer le diplôme.' : 'To complete the diploma.';
  String get pathAfterTitle => _fr ? 'Développeur junior' : 'Junior developer';
  String get pathAfterBody => _fr
      ? "Lancer ma carrière dans l'industrie."
      : 'Starting my career in the industry.';

  // Projects -----------------------------------------------------------------

  String get projectEyebrow => _fr ? 'Projet' : 'Work';

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

  String get beyondTheCode => _fr ? 'AU-DELÀ DU CODE' : 'BEYOND THE CODE';

  String get goalLabel => _fr ? 'OBJECTIF' : 'GOAL';
  String get buildHeadline => _fr ? 'Construire.' : 'Build.';

  String get buildParagraph => _fr
      ? "Terminer l'école, puis me mettre au travail — et continuer à "
            "construire pour le plaisir."
      : 'Finish school, then get to work — and keep building for fun.';

  String get goalConnectionsTitle =>
      _fr ? 'Créer des contacts' : 'Make connections';
  String get goalConnectionsBody => _fr
      ? "Rencontrer des gens de l'industrie à la fin de mes études."
      : 'Meet people in the industry once school wraps up.';
  String get goalJuniorTitle =>
      _fr ? 'Commencer comme développeur junior' : 'Start as a junior developer';
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

  String get hobbyLabel => _fr ? 'PASSE-TEMPS' : 'HOBBY';
  String get craftHeadline => _fr ? 'Créer.' : 'Craft.';

  String get craftParagraph => _fr
      ? "Couper, coudre, polir — des pièces qui prennent des heures et "
            "s'améliorent à chaque fois. La couture sellier m'a appris "
            "plus sur la patience qu'aucune échéance ne l'a jamais fait."
      : 'Cutting, stitching, burnishing — pieces that take hours and '
            'get better with every one. The saddle stitch taught me more '
            'about patience than any deadline ever did.';

  String get pastPiecesLabel => _fr ? 'CRÉATIONS PASSÉES' : 'PAST PIECES';
  String get pastPiecesSwipeLabel =>
      _fr ? 'CRÉATIONS PASSÉES · GLISSER' : 'PAST PIECES · SWIPE';
  String get addPhotoLabel => _fr ? 'Ajouter une photo' : 'Add photo';
  String get photoAtTheBench =>
      _fr ? '[PHOTO À\nL\'ÉTABLI]' : '[PHOTO AT\nTHE BENCH]';
  String get photoPlaceholder => '[PHOTO]';
}

Strings stringsOf(BuildContext context) => Strings(languageOf(context));
