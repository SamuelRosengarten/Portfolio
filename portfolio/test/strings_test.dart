import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/i18n/app_language.dart';
import 'package:portfolio/i18n/strings.dart';

/// Every translated string, read the same way the pages read it.
Map<String, String> _all(Strings s) => {
  'openNavigation': s.openNavigation,
  'switchToLightMode': s.switchToLightMode,
  'switchToDarkMode': s.switchToDarkMode,
  'switchToFrench': s.switchToFrench,
  'switchToEnglish': s.switchToEnglish,
  'pauseBackgroundAnimations': s.pauseBackgroundAnimations,
  'resumeBackgroundAnimations': s.resumeBackgroundAnimations,
  'heroGreeting': s.heroGreeting,
  'aboutBio': s.aboutBio,
  'openToInternships': s.openToInternships,
  'languagesAndTools': s.languagesAndTools,
  'projectEyebrow': s.projectEyebrow,
  'projectSubhead': s.projectSubhead,
  'projectDescription': s.projectDescription,
  'viewOnMarketplace': s.viewOnMarketplace,
  'sourceOnGitHub': s.sourceOnGitHub,
  'tagVsCodeExtension': s.tagVsCodeExtension,
  'tagPublished': s.tagPublished,
  'publishedOnMarketplace': s.publishedOnMarketplace,
  'demoCheck': s.demoCheck,
  'demoTryIt': s.demoTryIt,
  'demoStatsTab': s.demoStatsTab,
  'demoCodeCoach': s.demoCodeCoach,
  'demoYourWeek': s.demoYourWeek,
  'demoMistakesPerWeek': s.demoMistakesPerWeek,
  'demoWeeks': s.demoWeeks,
  'demoByKind': s.demoByKind,
  'demoMute': s.demoMute,
  'demoMuted': s.demoMuted,
  'demoSeen': s.demoSeen(7),
  'demoDisclaimer': s.demoDisclaimer,
  'contactHeadline': s.contactHeadline,
  'contactSubhead': s.contactSubhead,
  'locationLabel': s.locationLabel,
  'beyondTheCode': s.beyondTheCode,
  'goalLabel': s.goalLabel,
  'buildHeadline': s.buildHeadline,
  'buildParagraph': s.buildParagraph,
  'tutoringTitle': s.tutoringTitle,
  'tutoringParagraph': s.tutoringParagraph,
  'tagPatience': s.tagPatience,
  'tagEmpathy': s.tagEmpathy,
  'tagTeamPlayer': s.tagTeamPlayer,
  'hobbyLabel': s.hobbyLabel,
  'craftHeadline': s.craftHeadline,
  'craftParagraph': s.craftParagraph,
  'pastPiecesLabel': s.pastPiecesLabel,
};

/// Strings that are the same in both languages on purpose: proper nouns, the
/// stats tab, the product name, and words that happen to match.
const _sameInBoth = {
  'demoStatsTab',
  'demoCodeCoach',
  'tagPatience',
  'switchToFrench', // always written in French, so the French speaker finds it
  'switchToEnglish', // always written in English
};

void main() {
  const en = Strings(AppLanguage.en);
  const fr = Strings(AppLanguage.fr);

  test('every string exists and is non-empty in both languages', () {
    for (final entry in _all(en).entries) {
      expect(entry.value.trim(), isNotEmpty, reason: 'en ${entry.key}');
    }
    for (final entry in _all(fr).entries) {
      expect(entry.value.trim(), isNotEmpty, reason: 'fr ${entry.key}');
    }
  });

  test(
    'French is actually translated, except for the listed shared strings',
    () {
      final english = _all(en);
      final french = _all(fr);
      for (final key in english.keys) {
        if (_sameInBoth.contains(key)) continue;
        expect(french[key], isNot(english[key]), reason: '$key not translated');
      }
    },
  );

  test(
    'the language-switch labels name the other language, in that language',
    () {
      expect(en.switchToFrench, 'Passer au français');
      expect(fr.switchToFrench, 'Passer au français');
      expect(en.switchToEnglish, 'Switch to English');
      expect(fr.switchToEnglish, 'Switch to English');
    },
  );

  test('the demo lists have the same length in both languages', () {
    expect(fr.demoKinds.length, en.demoKinds.length);
    expect(fr.demoHints.length, en.demoHints.length);
    expect(en.demoKinds.length, en.demoHints.length);
  });

  test('the demo counter includes the number it was given', () {
    for (final s in [en, fr]) {
      expect(s.demoSeen(13), contains('13'));
      expect(s.demoSeen(0), contains('0'));
    }
  });

  test('the internship date agrees everywhere it is mentioned', () {
    final english = [
      en.aboutBio,
      en.openToInternships,
      en.contactSubhead,
      en.buildParagraph,
    ];
    final french = [
      fr.aboutBio,
      fr.openToInternships,
      fr.contactSubhead,
      fr.buildParagraph,
    ];
    for (final text in english) {
      expect(text, contains('March 2027'));
    }
    for (final text in french) {
      expect(text, contains('mars 2027'));
    }
  });

  test('no copy has doubled spaces, stray line breaks or edge whitespace', () {
    for (final s in [en, fr]) {
      for (final entry in _all(s).entries) {
        expect(entry.value, isNot(contains('  ')), reason: entry.key);
        expect(entry.value, isNot(contains('\n')), reason: entry.key);
        expect(entry.value, entry.value.trim(), reason: entry.key);
      }
    }
  });
}
