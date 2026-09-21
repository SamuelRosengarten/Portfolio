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

  String get heroGreeting => _fr ? "Salut, je suis Samuel" : "Hi, I'm Samuel";

  String get aboutBio => _fr
      ? "Étudiant en programmation informatique au Cégep Édouard-Montpetit, "
            "à la recherche d'un stage en mars 2027, puis d'un baccalauréat "
            "en génie logiciel. Avant le code, c'était la soudure et la "
            "mécanique — j'ai troqué le chalumeau et la boîte à outils pour "
            "un clavier, à la recherche d'un métier plus stable à bâtir, en "
            "gardant la même exigence de bien faire le travail."
      : 'Computer programming student at Cégep Édouard-Montpetit, looking '
            'for an internship in March 2027 and a software engineering '
            'degree after that. Before code it was welding and mechanics — '
            'I traded the torch and the toolbox for a keyboard, chasing a '
            'more stable place to build a career, and kept the same '
            'insistence on doing the work properly.';

  String get languagesAndTools =>
      _fr ? 'LANGAGES & OUTILS' : 'LANGUAGES & TOOLS';

  // Projects -----------------------------------------------------------------

  String get projectEyebrow => _fr ? 'Projet' : 'Work';

  String get projectSubhead => _fr
      ? "Une extension VS Code encore à l'état de concept — née du tutorat "
            "que je fais auprès d'autres étudiants et de l'envie d'un outil "
            "qui repère vos erreurs à votre place."
      : 'A VS Code extension concept, still in design — born out of '
            'tutoring other students and wanting a tool that catches your '
            'mistakes for you.';

  String get projectDescription => _fr
      ? "Une extension VS Code qui transforme les erreurs que vous faites "
            "en codant en quelque chose d'utile : des indices contextuels "
            "juste à côté de l'erreur, un tableau de bord qui suit les "
            "tendances dans le temps, et des rapports de session "
            "exportables à apporter à un mentor ou un tuteur."
      : 'A VS Code extension that turns the mistakes you make while '
            'coding into something useful: contextual hints right next to '
            'the error, a dashboard tracking patterns over time, and '
            'exportable session reports to bring to a mentor or tutor.';

  String get tagVsCodeExtension =>
      _fr ? 'Extension VS Code' : 'VS Code Extension';
  String get tagDesignPhase => _fr ? 'Phase de conception' : 'Design phase';

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

  // Hobbies ------------------------------------------------------------------

  String get beyondTheCode => _fr ? 'AU-DELÀ DU CODE' : 'BEYOND THE CODE';

  String get goalLabel => _fr ? 'OBJECTIF' : 'GOAL';
  String get buildHeadline => _fr ? 'Construire.' : 'Build.';

  String get buildParagraph => _fr
      ? "Après quelques années sur le plancher d'usine comme soudeur et "
            "mécanicien, le plan à long terme est un baccalauréat en génie "
            "logiciel — troquer le chalumeau pour un clavier, et un stage "
            "en mars 2027 comme prochaine étape."
      : 'After a few years on the shop floor as a welder and mechanic, '
            'the long-term plan is a software engineering degree — trading '
            'the torch for a keyboard, and a stage in March 2027 for the '
            'next step toward it.';

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

  String get pastPiecesLabel =>
      _fr ? 'CRÉATIONS PASSÉES' : 'PAST PIECES';
  String get addPhotoLabel => _fr ? 'Ajouter une photo' : 'Add photo';
}

Strings stringsOf(BuildContext context) => Strings(languageOf(context));
