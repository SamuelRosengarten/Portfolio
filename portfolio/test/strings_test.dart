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
  'heroGreeting': s.heroGreeting,
  'aboutBio': s.aboutBio,
  'openToInternships': s.openToInternships,
  'languagesAndTools': s.languagesAndTools,
  'projectEyebrow': s.projectEyebrow,
  'projectHeadline': s.projectHeadline,
  'projectSubhead': s.projectSubhead,
  'projectDescription': s.projectDescription,
  'viewOnMarketplace': s.viewOnMarketplace,
  'sourceOnGitHub': s.sourceOnGitHub,
  'tagVsCodeExtension': s.tagVsCodeExtension,
  'tagPublished': s.tagPublished,
  'publishedOnMarketplace': s.publishedOnMarketplace,
  'demoTabEditor': s.demoTabEditor,
  'demoTabGraph': s.demoTabGraph,
  'demoTabSearch': s.demoTabSearch,
  'demoTabAi': s.demoTabAi,
  'demoStatusLocalhost': s.demoStatusLocalhost,
  'demoStatusWal': s.demoStatusWal,
  'demoStatusZeroCloud': s.demoStatusZeroCloud,
  'demoStatusTests': s.demoStatusTests,
  'demoEditorOpenFile': s.demoEditorOpenFile,
  'demoEditorWordCount': s.demoEditorWordCount,
  'demoEditorLocalDisk': s.demoEditorLocalDisk,
  'demoGraphTitle': s.demoGraphTitle,
  'demoGraphSub': s.demoGraphSub,
  'demoGraphNodesCount': s.demoGraphNodesCount,
  'demoSearchPlaceholder': s.demoSearchPlaceholder,
  'demoResultsLabel': s.demoResultsLabel,
  'demoSearchLatency': s.demoSearchLatency,
  'demoAiModel': s.demoAiModel,
  'demoAiCloudZero': s.demoAiCloudZero,
  'demoTabToday': s.demoTabToday,
  'demoTabPlan': s.demoTabPlan,
  'demoTabNotes': s.demoTabNotes,
  'demoTabAsk': s.demoTabAsk,
  'demoNewCapture': s.demoNewCapture,
  'demoSearchJump': s.demoSearchJump,
  'demoQuickCapturePlaceholder': s.demoQuickCapturePlaceholder,
  'demoQuickCaptureHint': s.demoQuickCaptureHint,
  'demoSaveCapture': s.demoSaveCapture,
  'demoFocusTitle': s.demoFocusTitle,
  'demoPlanWeek': s.demoPlanWeek,
  'demoManageTasks': s.demoManageTasks,
  'demoRecentlyTouched': s.demoRecentlyTouched,
  'demoAllNotes': s.demoAllNotes,
  'demoReviewTitle': s.demoReviewTitle,
  'demoReviewSub': s.demoReviewSub,
  'demoMeetingsTitle': s.demoMeetingsTitle,
  'demoCalendar': s.demoCalendar,
  'demoJoinMeeting': s.demoJoinMeeting,
  'demoThisWeekTitle': s.demoThisWeekTitle,
  'demoTasksCount': s.demoTasksCount,
  'demoTurnIntoTask': s.demoTurnIntoTask,
  'demoAccept': s.demoAccept,
  'demoDismiss': s.demoDismiss,
  'demoLocalModelStatus': s.demoLocalModelStatus,
  'demoLocalPrivacyNotice': s.demoLocalPrivacyNotice,
  'demoPlanWorkflow': s.demoPlanWorkflow,
  'demoPlanGraph': s.demoPlanGraph,
  'archSectionEyebrow': s.archSectionEyebrow,
  'archSectionHeadline': s.archSectionHeadline,
  'archSectionSubhead': s.archSectionSubhead,
  'archCardSqliteTitle': s.archCardSqliteTitle,
  'archCardSqliteBody': s.archCardSqliteBody,
  'archCardFts5Title': s.archCardFts5Title,
  'archCardFts5Body': s.archCardFts5Body,
  'archCardWatcherTitle': s.archCardWatcherTitle,
  'archCardWatcherBody': s.archCardWatcherBody,
  'benchTitle': s.benchTitle,
  'benchColMetric': s.benchColMetric,
  'benchColSynapse': s.benchColSynapse,
  'benchColCloud': s.benchColCloud,
  'benchColPlugins': s.benchColPlugins,
  'benchRowSearchLatency': s.benchRowSearchLatency,
  'benchValSynapseLatency': s.benchValSynapseLatency,
  'benchValCloudLatency': s.benchValCloudLatency,
  'benchValPluginLatency': s.benchValPluginLatency,
  'benchRowDataPrivacy': s.benchRowDataPrivacy,
  'benchValSynapsePrivacy': s.benchValSynapsePrivacy,
  'benchValCloudPrivacy': s.benchValCloudPrivacy,
  'benchValPluginPrivacy': s.benchValPluginPrivacy,
  'benchRowOfflineReady': s.benchRowOfflineReady,
  'benchValSynapseOffline': s.benchValSynapseOffline,
  'benchValCloudOffline': s.benchValCloudOffline,
  'benchValPluginOffline': s.benchValPluginOffline,
  'benchRowVendorLockin': s.benchRowVendorLockin,
  'benchValSynapseLockin': s.benchValSynapseLockin,
  'benchValCloudLockin': s.benchValCloudLockin,
  'benchValPluginLockin': s.benchValPluginLockin,
  'craftSectionEyebrow': s.craftSectionEyebrow,
  'craftSectionHeadline': s.craftSectionHeadline,
  'craftSectionBody': s.craftSectionBody,
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
  'heroTagline': s.heroTagline,
  'seeMyWork': s.seeMyWork,
  'getInTouch': s.getInTouch,
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
  'featureHintsTitle': s.featureHintsTitle,
  'featureHintsBody': s.featureHintsBody,
  'featureDashboardTitle': s.featureDashboardTitle,
  'featureDashboardBody': s.featureDashboardBody,
  'featureReportsTitle': s.featureReportsTitle,
  'featureReportsBody': s.featureReportsBody,
  'builtWithFlutter': s.builtWithFlutter,
  'goalConnectionsTitle': s.goalConnectionsTitle,
  'goalConnectionsBody': s.goalConnectionsBody,
  'goalJuniorTitle': s.goalJuniorTitle,
  'goalJuniorBody': s.goalJuniorBody,
  'goalHomeTitle': s.goalHomeTitle,
  'goalHomeBody': s.goalHomeBody,
  'pastPiecesSwipeLabel': s.pastPiecesSwipeLabel,
};

/// Strings that are the same in both languages on purpose: proper nouns, the
/// stats tab, the product name, and words that happen to match.
const _sameInBoth = {
  'demoStatsTab',
  'demoCodeCoach',
  'tagPatience',
  'switchToFrench', // always written in French, so the French speaker finds it
  'switchToEnglish', // always written in English
  'projectHeadline',
  'demoStatusLocalhost',
  'demoStatusWal',
  'demoSearchLatency',
  'demoAiModel',
  'benchColSynapse',
  'benchColCloud',
  'benchColPlugins',
  'benchValSynapseLatency',
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
}
