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
  'openToInternships': s.openToInternships,
  'heroGreeting': s.heroGreeting,
  'heroTagline': s.heroTagline,
  'aboutBio': s.aboutBio,
  'seeMyWork': s.seeMyWork,
  'getInTouch': s.getInTouch,
  'languagesAndTools': s.languagesAndTools,
  'pathBefore': s.pathBefore,
  'pathNow': s.pathNow,
  'pathNext': s.pathNext,
  'pathAfter': s.pathAfter,
  'pathBeforeTitle': s.pathBeforeTitle,
  'pathBeforeBody': s.pathBeforeBody,
  'pathNowTitle': s.pathNowTitle,
  'pathNowBody': s.pathNowBody,
  'pathNowShort': s.pathNowShort,
  'pathNextTitle': s.pathNextTitle,
  'pathNextBody': s.pathNextBody,
  'pathAfterTitle': s.pathAfterTitle,
  'pathAfterBody': s.pathAfterBody,
  'projectEyebrow': s.projectEyebrow,
  'projectsHeadline': s.projectsHeadline,
  'projectsSubhead': s.projectsSubhead,
  'projectSubhead': s.projectSubhead,
  'projectDescription': s.projectDescription,
  'tagWebApp': s.tagWebApp,
  'tagBeta': s.tagBeta,
  'synapseDescription': s.synapseDescription,
  'featurePrivateAiTitle': s.featurePrivateAiTitle,
  'featurePrivateAiBody': s.featurePrivateAiBody,
  'featureApproveTitle': s.featureApproveTitle,
  'featureApproveBody': s.featureApproveBody,
  'featureTeamsTitle': s.featureTeamsTitle,
  'featureTeamsBody': s.featureTeamsBody,
  'tagVsCodeExtension': s.tagVsCodeExtension,
  'tagPublished': s.tagPublished,
  'featureHintsTitle': s.featureHintsTitle,
  'featureHintsBody': s.featureHintsBody,
  'featureDashboardTitle': s.featureDashboardTitle,
  'featureDashboardBody': s.featureDashboardBody,
  'featureReportsTitle': s.featureReportsTitle,
  'featureReportsBody': s.featureReportsBody,
  'contactHeadline': s.contactHeadline,
  'contactSubhead': s.contactSubhead,
  'locationLabel': s.locationLabel,
  'builtWithFlutter': s.builtWithFlutter,
  'beyondTheCode': s.beyondTheCode,
  'goalLabel': s.goalLabel,
  'buildHeadline': s.buildHeadline,
  'buildParagraph': s.buildParagraph,
  'goalConnectionsTitle': s.goalConnectionsTitle,
  'goalConnectionsBody': s.goalConnectionsBody,
  'goalJuniorTitle': s.goalJuniorTitle,
  'goalJuniorBody': s.goalJuniorBody,
  'goalHomeTitle': s.goalHomeTitle,
  'goalHomeBody': s.goalHomeBody,
  'tutoringTitle': s.tutoringTitle,
  'tutoringParagraph': s.tutoringParagraph,
  'tagPatience': s.tagPatience,
  'tagEmpathy': s.tagEmpathy,
  'tagTeamPlayer': s.tagTeamPlayer,
  'hobbyLabel': s.hobbyLabel,
  'craftHeadline': s.craftHeadline,
  'craftParagraph': s.craftParagraph,
  'pastPiecesLabel': s.pastPiecesLabel,
  'pastPiecesSwipeLabel': s.pastPiecesSwipeLabel,
  'addPhotoLabel': s.addPhotoLabel,
  'photoAtTheBench': s.photoAtTheBench,
  'photoPlaceholder': s.photoPlaceholder,
};

/// Strings that are the same in both languages on purpose: the language
/// switch labels (always written in the language they switch to) and words
/// that are spelled the same in English and French.
const _sameInBoth = {
  'switchToFrench',
  'switchToEnglish',
  'tagPatience',
  'photoPlaceholder',
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
}
