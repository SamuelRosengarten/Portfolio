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
  'founderPill': s.founderPill,
  'seeSynapse': s.seeSynapse,
  'getInTouch': s.getInTouch,
  'languagesAndTools': s.languagesAndTools,
  'pathTitle': s.pathTitle,
  'pathBefore': s.pathBefore,
  'pathNow': s.pathNow,
  'pathNext': s.pathNext,
  'pathAfter': s.pathAfter,
  'pathBeforeTitle': s.pathBeforeTitle,
  'pathBeforeBody': s.pathBeforeBody,
  'pathNowTitle': s.pathNowTitle,
  'pathNowBody': s.pathNowBody,
  'pathNextTitle': s.pathNextTitle,
  'pathNextBody': s.pathNextBody,
  'pathAfterTitle': s.pathAfterTitle,
  'pathAfterBody': s.pathAfterBody,
  'projectsHeadline': s.projectsHeadline,
  'projectSubhead': s.projectSubhead,
  'projectDescription': s.projectDescription,
  'synapseBadge': s.synapseBadge,
  'synapseTagline': s.synapseTagline,
  'synapseLead': s.synapseLead,
  'platformIphone': s.platformIphone,
  'platformMac': s.platformMac,
  'platformWeb': s.platformWeb,
  'featurePrivateAiTitle': s.featurePrivateAiTitle,
  'featurePrivateAiBody': s.featurePrivateAiBody,
  'featureApproveTitle': s.featureApproveTitle,
  'featureApproveBody': s.featureApproveBody,
  'featureTeamsTitle': s.featureTeamsTitle,
  'featureTeamsBody': s.featureTeamsBody,
  'onIphone': s.onIphone,
  'onIphoneBody': s.onIphoneBody,
  'shotTodayTitle': s.shotTodayTitle,
  'shotTodayBody': s.shotTodayBody,
  'shotAskTitle': s.shotAskTitle,
  'shotAskBody': s.shotAskBody,
  'shotReviewTitle': s.shotReviewTitle,
  'shotReviewBody': s.shotReviewBody,
  'shotChatTitle': s.shotChatTitle,
  'shotChatBody': s.shotChatBody,
  'onMac': s.onMac,
  'onMacBody': s.onMacBody,
  'macShotLabel': s.macShotLabel,
  'iphoneShotLabel': s.iphoneShotLabel,
  'heroShotLabel': s.heroShotLabel,
  'businessTitle': s.businessTitle,
  'businessLead': s.businessLead,
  'businessModelTitle': s.businessModelTitle,
  'businessModelBody': s.businessModelBody,
  'businessPrivacyTitle': s.businessPrivacyTitle,
  'businessPrivacyBody': s.businessPrivacyBody,
  'businessLaunchTitle': s.businessLaunchTitle,
  'businessLaunchBody': s.businessLaunchBody,
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
  'buildHeadline': s.buildHeadline,
  'teachHeadline': s.teachHeadline,
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
  'craftHeadline': s.craftHeadline,
  'craftParagraph': s.craftParagraph,
  'pastPiecesLabel': s.pastPiecesLabel,
};

/// Strings that are the same in both languages on purpose: the language
/// switch labels (always written in the language they switch to) and words
/// that are spelled the same in English and French.
const _sameInBoth = {
  'switchToFrench',
  'switchToEnglish',
  'tagPatience',
  'platformIphone',
  'platformMac',
  'platformWeb',
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
