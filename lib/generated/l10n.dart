// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

class S {
  S();
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name); 
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      return S();
    });
  } 

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  String get app_name {
    return Intl.message(
      'NTUT Course Assistant',
      name: 'app_name',
      desc: '',
      args: [],
    );
  }

  String get ___________________loginUi___________________ {
    return Intl.message(
      '註解',
      name: '___________________loginUi___________________',
      desc: '',
      args: [],
    );
  }

  String get login {
    return Intl.message(
      'Login',
      name: 'login',
      desc: '',
      args: [],
    );
  }

  String get loginSave {
    return Intl.message(
      'Account password has been saved',
      name: 'loginSave',
      desc: '',
      args: [],
    );
  }

  String get accountNull {
    return Intl.message(
      'Please enter your account',
      name: 'accountNull',
      desc: '',
      args: [],
    );
  }

  String get passwordNull {
    return Intl.message(
      'Please enter the password',
      name: 'passwordNull',
      desc: '',
      args: [],
    );
  }

  String get password {
    return Intl.message(
      'Password',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  String get account {
    return Intl.message(
      'Account',
      name: 'account',
      desc: '',
      args: [],
    );
  }

  String get warning {
    return Intl.message(
      'Warning',
      name: 'warning',
      desc: '',
      args: [],
    );
  }

  String get sure {
    return Intl.message(
      'Sure',
      name: 'sure',
      desc: '',
      args: [],
    );
  }

  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  String get update {
    return Intl.message(
      'Update',
      name: 'update',
      desc: '',
      args: [],
    );
  }

  String get setting {
    return Intl.message(
      'Settings',
      name: 'setting',
      desc: '',
      args: [],
    );
  }

  String get restart {
    return Intl.message(
      'Restart',
      name: 'restart',
      desc: '',
      args: [],
    );
  }

  String get calendar {
    return Intl.message(
      'Calendar',
      name: 'calendar',
      desc: '',
      args: [],
    );
  }

  String get alertError {
    return Intl.message(
      'An error occurred',
      name: 'alertError',
      desc: '',
      args: [],
    );
  }

  String get downloadError {
    return Intl.message(
      ' Download error',
      name: 'downloadError',
      desc: '',
      args: [],
    );
  }

  String get isALink {
    return Intl.message(
      'Is a link',
      name: 'isALink',
      desc: '',
      args: [],
    );
  }

  String get AreYouSureToOpen {
    return Intl.message(
      'Are you sure to open?',
      name: 'AreYouSureToOpen',
      desc: '',
      args: [],
    );
  }

  String get downloading {
    return Intl.message(
      'Download...',
      name: 'downloading',
      desc: '',
      args: [],
    );
  }

  String get downloadComplete {
    return Intl.message(
      'Download complete',
      name: 'downloadComplete',
      desc: '',
      args: [],
    );
  }

  String get prepareDownload {
    return Intl.message(
      'Prepare download...',
      name: 'prepareDownload',
      desc: '',
      args: [],
    );
  }

  String get ___________________task___________________ {
    return Intl.message(
      '註解',
      name: '___________________task___________________',
      desc: '',
      args: [],
    );
  }

  String get loginNTUT {
    return Intl.message(
      'Login to the NTUT...',
      name: 'loginNTUT',
      desc: '',
      args: [],
    );
  }

  String get accountPasswordError {
    return Intl.message(
      'Account password incorrect',
      name: 'accountPasswordError',
      desc: '',
      args: [],
    );
  }

  String get connectTimeOut {
    return Intl.message(
      'Connection timed out',
      name: 'connectTimeOut',
      desc: '',
      args: [],
    );
  }

  String get authCodeFail {
    return Intl.message(
      'Verification code error',
      name: 'authCodeFail',
      desc: '',
      args: [],
    );
  }

  String get accountLock {
    return Intl.message(
      'Account is locked',
      name: 'accountLock',
      desc: '',
      args: [],
    );
  }

  String get networkError {
    return Intl.message(
      'Network error',
      name: 'networkError',
      desc: '',
      args: [],
    );
  }

  String get unknownError {
    return Intl.message(
      'An unknown error occurred',
      name: 'unknownError',
      desc: '',
      args: [],
    );
  }

  String get passwordExpiredWarning {
    return Intl.message(
      'Password is about to expire, please update password as soon as possible',
      name: 'passwordExpiredWarning',
      desc: '',
      args: [],
    );
  }

  String get checkLogin {
    return Intl.message(
      'Check login...',
      name: 'checkLogin',
      desc: '',
      args: [],
    );
  }

  String get loginISchool {
    return Intl.message(
      'Login to ISchool...',
      name: 'loginISchool',
      desc: '',
      args: [],
    );
  }

  String get loginISchoolError {
    return Intl.message(
      'Login to ISchool Error',
      name: 'loginISchoolError',
      desc: '',
      args: [],
    );
  }

  String get loginISchoolPlus {
    return Intl.message(
      'Login to ISchool Plus...',
      name: 'loginISchoolPlus',
      desc: '',
      args: [],
    );
  }

  String get loginScore {
    return Intl.message(
      'Login to Score...',
      name: 'loginScore',
      desc: '',
      args: [],
    );
  }

  String get loginScoreError {
    return Intl.message(
      'Login to Score Error',
      name: 'loginScoreError',
      desc: '',
      args: [],
    );
  }

  String get loginISchoolPlusError {
    return Intl.message(
      'Login to ISchool Plus error',
      name: 'loginISchoolPlusError',
      desc: '',
      args: [],
    );
  }

  String get getISchoolNewAnnouncement {
    return Intl.message(
      'Get the latest announcement...',
      name: 'getISchoolNewAnnouncement',
      desc: '',
      args: [],
    );
  }

  String get getISchoolNewAnnouncementError {
    return Intl.message(
      'Get latest announcement error',
      name: 'getISchoolNewAnnouncementError',
      desc: '',
      args: [],
    );
  }

  String get getISchoolNewAnnouncementDetail {
    return Intl.message(
      'Get announcement information...',
      name: 'getISchoolNewAnnouncementDetail',
      desc: '',
      args: [],
    );
  }

  String get getISchoolNewAnnouncementDetailError {
    return Intl.message(
      'Getting announcement information error',
      name: 'getISchoolNewAnnouncementDetailError',
      desc: '',
      args: [],
    );
  }

  String get getISchoolNewAnnouncementPage {
    return Intl.message(
      'Get announcement pages...',
      name: 'getISchoolNewAnnouncementPage',
      desc: '',
      args: [],
    );
  }

  String get getISchoolNewAnnouncementPageError {
    return Intl.message(
      'Error getting page number of announcement',
      name: 'getISchoolNewAnnouncementPageError',
      desc: '',
      args: [],
    );
  }

  String get getCourse {
    return Intl.message(
      'Get schedule...',
      name: 'getCourse',
      desc: '',
      args: [],
    );
  }

  String get getCourseError {
    return Intl.message(
      'Getting schedule error',
      name: 'getCourseError',
      desc: '',
      args: [],
    );
  }

  String get loginCourse {
    return Intl.message(
      'Login course system...',
      name: 'loginCourse',
      desc: '',
      args: [],
    );
  }

  String get loginCourseError {
    return Intl.message(
      'Login course system error',
      name: 'loginCourseError',
      desc: '',
      args: [],
    );
  }

  String get getCourseSemester {
    return Intl.message(
      'Get semester list...',
      name: 'getCourseSemester',
      desc: '',
      args: [],
    );
  }

  String get getCourseSemesterError {
    return Intl.message(
      'Getting semester list error',
      name: 'getCourseSemesterError',
      desc: '',
      args: [],
    );
  }

  String get getCourseDetail {
    return Intl.message(
      'Reading course materials...',
      name: 'getCourseDetail',
      desc: '',
      args: [],
    );
  }

  String get getCourseDetailError {
    return Intl.message(
      'Course data reading error',
      name: 'getCourseDetailError',
      desc: '',
      args: [],
    );
  }

  String get getISchoolCourseAnnouncement {
    return Intl.message(
      'Get course announcement...',
      name: 'getISchoolCourseAnnouncement',
      desc: '',
      args: [],
    );
  }

  String get getISchoolCourseAnnouncementError {
    return Intl.message(
      'Get course announcement error',
      name: 'getISchoolCourseAnnouncementError',
      desc: '',
      args: [],
    );
  }

  String get getISchoolCourseFile {
    return Intl.message(
      'Get course files',
      name: 'getISchoolCourseFile',
      desc: '',
      args: [],
    );
  }

  String get getISchoolCourseFileError {
    return Intl.message(
      'Get course files error',
      name: 'getISchoolCourseFileError',
      desc: '',
      args: [],
    );
  }

  String get getISchoolPlusCourseFile {
    return Intl.message(
      'Get course files',
      name: 'getISchoolPlusCourseFile',
      desc: '',
      args: [],
    );
  }

  String get getISchoolPlusCourseFileError {
    return Intl.message(
      'Get course files error',
      name: 'getISchoolPlusCourseFileError',
      desc: '',
      args: [],
    );
  }

  String get getISchoolPlusCourseAnnouncement {
    return Intl.message(
      'Get course announcement...',
      name: 'getISchoolPlusCourseAnnouncement',
      desc: '',
      args: [],
    );
  }

  String get getISchoolPlusCourseAnnouncementError {
    return Intl.message(
      'Get course announcement error',
      name: 'getISchoolPlusCourseAnnouncementError',
      desc: '',
      args: [],
    );
  }

  String get getISchoolPlusCourseAnnouncementDetail {
    return Intl.message(
      'Get course announcement detail...',
      name: 'getISchoolPlusCourseAnnouncementDetail',
      desc: '',
      args: [],
    );
  }

  String get getISchoolPlusCourseAnnouncementDetailError {
    return Intl.message(
      'Get course announcement detail error',
      name: 'getISchoolPlusCourseAnnouncementDetailError',
      desc: '',
      args: [],
    );
  }

  String get getScoreRank {
    return Intl.message(
      'Getting grade...',
      name: 'getScoreRank',
      desc: '',
      args: [],
    );
  }

  String get getScoreRankError {
    return Intl.message(
      'Getting grade error',
      name: 'getScoreRankError',
      desc: '',
      args: [],
    );
  }

  String get getCalendar {
    return Intl.message(
      'Getting calendar...',
      name: 'getCalendar',
      desc: '',
      args: [],
    );
  }

  String get getCalendarError {
    return Intl.message(
      'Getting calendar error',
      name: 'getCalendarError',
      desc: '',
      args: [],
    );
  }

  String get deleteMessage {
    return Intl.message(
      'Deleting message...',
      name: 'deleteMessage',
      desc: '',
      args: [],
    );
  }

  String get deleteMessageError {
    return Intl.message(
      'Delete error',
      name: 'deleteMessageError',
      desc: '',
      args: [],
    );
  }

  String get loginNTUTApp {
    return Intl.message(
      'Login to the NTUTApp...',
      name: 'loginNTUTApp',
      desc: '',
      args: [],
    );
  }

  String get loginNTUTAppError {
    return Intl.message(
      'Login to the NTUTApp Error',
      name: 'loginNTUTAppError',
      desc: '',
      args: [],
    );
  }

  String get ___________________CourseTableUi___________________ {
    return Intl.message(
      '註解',
      name: '___________________CourseTableUi___________________',
      desc: '',
      args: [],
    );
  }

  String get Monday {
    return Intl.message(
      'MON',
      name: 'Monday',
      desc: '',
      args: [],
    );
  }

  String get Tuesday {
    return Intl.message(
      'TUE',
      name: 'Tuesday',
      desc: '',
      args: [],
    );
  }

  String get Wednesday {
    return Intl.message(
      'WED',
      name: 'Wednesday',
      desc: '',
      args: [],
    );
  }

  String get Thursday {
    return Intl.message(
      'THU',
      name: 'Thursday',
      desc: '',
      args: [],
    );
  }

  String get Friday {
    return Intl.message(
      'FRI',
      name: 'Friday',
      desc: '',
      args: [],
    );
  }

  String get Saturday {
    return Intl.message(
      'SAT',
      name: 'Saturday',
      desc: '',
      args: [],
    );
  }

  String get Sunday {
    return Intl.message(
      'SUN',
      name: 'Sunday',
      desc: '',
      args: [],
    );
  }

  String get UnKnown {
    return Intl.message(
      '',
      name: 'UnKnown',
      desc: '',
      args: [],
    );
  }

  String get titleCourse {
    return Intl.message(
      'Course',
      name: 'titleCourse',
      desc: '',
      args: [],
    );
  }

  String get refresh {
    return Intl.message(
      'Refresh',
      name: 'refresh',
      desc: '',
      args: [],
    );
  }

  String get pleaseEnterStudentId {
    return Intl.message(
      'Please enter student number',
      name: 'pleaseEnterStudentId',
      desc: '',
      args: [],
    );
  }

  String get courseId {
    return Intl.message(
      'Course number',
      name: 'courseId',
      desc: '',
      args: [],
    );
  }

  String get time {
    return Intl.message(
      'Time',
      name: 'time',
      desc: '',
      args: [],
    );
  }

  String get instructor {
    return Intl.message(
      'Instructor',
      name: 'instructor',
      desc: '',
      args: [],
    );
  }

  String get location {
    return Intl.message(
      'Location',
      name: 'location',
      desc: '',
      args: [],
    );
  }

  String get details {
    return Intl.message(
      'Details',
      name: 'details',
      desc: '',
      args: [],
    );
  }

  String get noSupport {
    return Intl.message(
      ' not support',
      name: 'noSupport',
      desc: '',
      args: [],
    );
  }

  String get noAnyFavorite {
    return Intl.message(
      'No any favorite',
      name: 'noAnyFavorite',
      desc: '',
      args: [],
    );
  }

  String get settingComplete {
    return Intl.message(
      'Setting complete',
      name: 'settingComplete',
      desc: '',
      args: [],
    );
  }

  String get settingCompleteWithError {
    return Intl.message(
      'Setup is complete, please add the weight again',
      name: 'settingCompleteWithError',
      desc: '',
      args: [],
    );
  }

  String get findNewMessage {
    return Intl.message(
      'Find I Plus new message',
      name: 'findNewMessage',
      desc: '',
      args: [],
    );
  }

  String get searchCredit {
    return Intl.message(
      'Search credit',
      name: 'searchCredit',
      desc: '',
      args: [],
    );
  }

  String get loadFavorite {
    return Intl.message(
      'Load favorite',
      name: 'loadFavorite',
      desc: '',
      args: [],
    );
  }

  String get setAsAndroidWeight {
    return Intl.message(
      'Set as android weight',
      name: 'setAsAndroidWeight',
      desc: '',
      args: [],
    );
  }

  String get ___________________FileViewerPage___________________ {
    return Intl.message(
      '註解',
      name: '___________________FileViewerPage___________________',
      desc: '',
      args: [],
    );
  }

  String get sortBy {
    return Intl.message(
      'Sort by',
      name: 'sortBy',
      desc: '',
      args: [],
    );
  }

  String get nothingHere {
    return Intl.message(
      'There\'s nothing here',
      name: 'nothingHere',
      desc: '',
      args: [],
    );
  }

  String get cannotWrite {
    return Intl.message(
      'Cannot write to this Storage device!',
      name: 'cannotWrite',
      desc: '',
      args: [],
    );
  }

  String get folderNameAlreadyExists {
    return Intl.message(
      'A Folder with that name already exists!',
      name: 'folderNameAlreadyExists',
      desc: '',
      args: [],
    );
  }

  String get fileNameAlreadyExists {
    return Intl.message(
      'A File with that name already exists!',
      name: 'fileNameAlreadyExists',
      desc: '',
      args: [],
    );
  }

  String get renameItem {
    return Intl.message(
      'Rename item',
      name: 'renameItem',
      desc: '',
      args: [],
    );
  }

  String get rename {
    return Intl.message(
      'Rename',
      name: 'rename',
      desc: '',
      args: [],
    );
  }

  String get ___________________NotificationPage___________________ {
    return Intl.message(
      '註解',
      name: '___________________NotificationPage___________________',
      desc: '',
      args: [],
    );
  }

  String get pullUpLoad {
    return Intl.message(
      'Pull up load',
      name: 'pullUpLoad',
      desc: '',
      args: [],
    );
  }

  String get loadFailed {
    return Intl.message(
      'Load Failed! Click retry!',
      name: 'loadFailed',
      desc: '',
      args: [],
    );
  }

  String get ReleaseLoadMore {
    return Intl.message(
      'release to load more',
      name: 'ReleaseLoadMore',
      desc: '',
      args: [],
    );
  }

  String get pullAgainToUpdate {
    return Intl.message(
      'Pull again to update',
      name: 'pullAgainToUpdate',
      desc: '',
      args: [],
    );
  }

  String get noMoreData {
    return Intl.message(
      'No more data',
      name: 'noMoreData',
      desc: '',
      args: [],
    );
  }

  String get clearAndRefresh {
    return Intl.message(
      'Clear and refresh',
      name: 'clearAndRefresh',
      desc: '',
      args: [],
    );
  }

  String get titleNotification {
    return Intl.message(
      'Notification',
      name: 'titleNotification',
      desc: '',
      args: [],
    );
  }

  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  String get areYouSureDeleteMessage {
    return Intl.message(
      'Are you sure you want to delete the message?',
      name: 'areYouSureDeleteMessage',
      desc: '',
      args: [],
    );
  }

  String get download {
    return Intl.message(
      'download',
      name: 'download',
      desc: '',
      args: [],
    );
  }

  String get downloadWillStart {
    return Intl.message(
      'Download ready to start',
      name: 'downloadWillStart',
      desc: '',
      args: [],
    );
  }

  String get fileAttachmentDetected {
    return Intl.message(
      'File attachment detected',
      name: 'fileAttachmentDetected',
      desc: '',
      args: [],
    );
  }

  String get areYouSureToDownload {
    return Intl.message(
      'Are you sure you want to download the file',
      name: 'areYouSureToDownload',
      desc: '',
      args: [],
    );
  }

  String get ___________________OtherUi___________________ {
    return Intl.message(
      '註解',
      name: '___________________OtherUi___________________',
      desc: '',
      args: [],
    );
  }

  String get scoreSearch {
    return Intl.message(
      'Score query',
      name: 'scoreSearch',
      desc: '',
      args: [],
    );
  }

  String get downloadFile {
    return Intl.message(
      'Download file',
      name: 'downloadFile',
      desc: '',
      args: [],
    );
  }

  String get fileViewer {
    return Intl.message(
      'Downloads',
      name: 'fileViewer',
      desc: '',
      args: [],
    );
  }

  String get languageSetting {
    return Intl.message(
      'Language',
      name: 'languageSetting',
      desc: '',
      args: [],
    );
  }

  String get titleOther {
    return Intl.message(
      'Other',
      name: 'titleOther',
      desc: '',
      args: [],
    );
  }

  String get creditViewer {
    return Intl.message(
      'Credit Viewer',
      name: 'creditViewer',
      desc: '',
      args: [],
    );
  }

  String get creditSearch {
    return Intl.message(
      'Credit search...',
      name: 'creditSearch',
      desc: '',
      args: [],
    );
  }

  String get pleaseLogin {
    return Intl.message(
      'Please Login',
      name: 'pleaseLogin',
      desc: '',
      args: [],
    );
  }

  String get noFunction {
    return Intl.message(
      'No function',
      name: 'noFunction',
      desc: '',
      args: [],
    );
  }

  String get changePassword {
    return Intl.message(
      'Change the password',
      name: 'changePassword',
      desc: '',
      args: [],
    );
  }

  String get logout {
    return Intl.message(
      'Sign out',
      name: 'logout',
      desc: '',
      args: [],
    );
  }

  String get feedback {
    return Intl.message(
      'Feedback',
      name: 'feedback',
      desc: '',
      args: [],
    );
  }

  String get about {
    return Intl.message(
      'About',
      name: 'about',
      desc: '',
      args: [],
    );
  }

  String get aboutDialogString {
    return Intl.message(
      'This is an app about National Taipei University of Technology',
      name: 'aboutDialogString',
      desc: '',
      args: [],
    );
  }

  String get closeOnce {
    return Intl.message(
      'Press again to close',
      name: 'closeOnce',
      desc: '',
      args: [],
    );
  }

  String get darkMode {
    return Intl.message(
      'Dark mode',
      name: 'darkMode',
      desc: '',
      args: [],
    );
  }

  String get downloadPath {
    return Intl.message(
      'Download path',
      name: 'downloadPath',
      desc: '',
      args: [],
    );
  }

  String get patchVersion {
    return Intl.message(
      'Patch version',
      name: 'patchVersion',
      desc: '',
      args: [],
    );
  }

  String get downloadingPatch {
    return Intl.message(
      'Downloading patch...',
      name: 'downloadingPatch',
      desc: '',
      args: [],
    );
  }

  String get findPatchNewVersion {
    return Intl.message(
      'Find the new patch version',
      name: 'findPatchNewVersion',
      desc: '',
      args: [],
    );
  }

  String get patchUpdateDown {
    return Intl.message(
      'After the download is complete, the APP will automatically restart to complete the update, wait about 10 seconds, please do not open it manually',
      name: 'patchUpdateDown',
      desc: '',
      args: [],
    );
  }

  String get patchDelete {
    return Intl.message(
      'Patch delete , Restart the application and apply',
      name: 'patchDelete',
      desc: '',
      args: [],
    );
  }

  String get deletePatch {
    return Intl.message(
      'Delete patch',
      name: 'deletePatch',
      desc: '',
      args: [],
    );
  }

  String get exitDevMode {
    return Intl.message(
      'Exit dev mode',
      name: 'exitDevMode',
      desc: '',
      args: [],
    );
  }

  String get patchUpdateComplete {
    return Intl.message(
      'Patch successfully upgraded version:',
      name: 'patchUpdateComplete',
      desc: '',
      args: [],
    );
  }

  String get patchUpdateFail {
    return Intl.message(
      'Patch upgrade failed\nAutomatically downgraded to original version:',
      name: 'patchUpdateFail',
      desc: '',
      args: [],
    );
  }

  String get developerMode {
    return Intl.message(
      'Developer Mode',
      name: 'developerMode',
      desc: '',
      args: [],
    );
  }

  String get openExternalVideo {
    return Intl.message(
      'Open with external video player',
      name: 'openExternalVideo',
      desc: '',
      args: [],
    );
  }

  String get openExternalVideoHint {
    return Intl.message(
      'Recommend use MX player',
      name: 'openExternalVideoHint',
      desc: '',
      args: [],
    );
  }

  String get checkIPlusNew {
    return Intl.message(
      'Check IPlus new',
      name: 'checkIPlusNew',
      desc: '',
      args: [],
    );
  }

  String get ___________________iSchoolUi___________________ {
    return Intl.message(
      '註解',
      name: '___________________iSchoolUi___________________',
      desc: '',
      args: [],
    );
  }

  String get course {
    return Intl.message(
      'Course',
      name: 'course',
      desc: '',
      args: [],
    );
  }

  String get announcement {
    return Intl.message(
      'Announcement',
      name: 'announcement',
      desc: '',
      args: [],
    );
  }

  String get file {
    return Intl.message(
      'File',
      name: 'file',
      desc: '',
      args: [],
    );
  }

  String get noAnyAnnouncement {
    return Intl.message(
      'Without any announcement',
      name: 'noAnyAnnouncement',
      desc: '',
      args: [],
    );
  }

  String get pleaseMoveToFilePage {
    return Intl.message(
      'Please go directly to the download page',
      name: 'pleaseMoveToFilePage',
      desc: '',
      args: [],
    );
  }

  String get noAnyFile {
    return Intl.message(
      'No files',
      name: 'noAnyFile',
      desc: '',
      args: [],
    );
  }

  String get courseName {
    return Intl.message(
      'Course Title',
      name: 'courseName',
      desc: '',
      args: [],
    );
  }

  String get credit {
    return Intl.message(
      'Credit',
      name: 'credit',
      desc: '',
      args: [],
    );
  }

  String get category {
    return Intl.message(
      'Category',
      name: 'category',
      desc: '',
      args: [],
    );
  }

  String get syllabus {
    return Intl.message(
      'Syllabus',
      name: 'syllabus',
      desc: '',
      args: [],
    );
  }

  String get startClass {
    return Intl.message(
      'Start class',
      name: 'startClass',
      desc: '',
      args: [],
    );
  }

  String get classroom {
    return Intl.message(
      'Classroom',
      name: 'classroom',
      desc: '',
      args: [],
    );
  }

  String get classroomUse {
    return Intl.message(
      'classroomUse',
      name: 'classroomUse',
      desc: '',
      args: [],
    );
  }

  String get numberOfStudent {
    return Intl.message(
      'Number of students',
      name: 'numberOfStudent',
      desc: '',
      args: [],
    );
  }

  String get numberOfWithdraw {
    return Intl.message(
      'Number of withdraw',
      name: 'numberOfWithdraw',
      desc: '',
      args: [],
    );
  }

  String get courseData {
    return Intl.message(
      'Course Information',
      name: 'courseData',
      desc: '',
      args: [],
    );
  }

  String get studentList {
    return Intl.message(
      'Student list',
      name: 'studentList',
      desc: '',
      args: [],
    );
  }

  String get languageSwitch {
    return Intl.message(
      'Use English interface',
      name: 'languageSwitch',
      desc: '',
      args: [],
    );
  }

  String get willRestart {
    return Intl.message(
      'Will restart automatically',
      name: 'willRestart',
      desc: '',
      args: [],
    );
  }

  String get notSupport {
    return Intl.message(
      'Not support',
      name: 'notSupport',
      desc: '',
      args: [],
    );
  }

  String get forceReLogin {
    return Intl.message(
      'Force re-login',
      name: 'forceReLogin',
      desc: '',
      args: [],
    );
  }

  String get forceLoginResult {
    return Intl.message(
      'When it is judged that the logged-in mechanism is invalid, the check can be solved, but it will slow down the data acquisition speed',
      name: 'forceLoginResult',
      desc: '',
      args: [],
    );
  }

  String get isVideo {
    return Intl.message(
      'Is a video',
      name: 'isVideo',
      desc: '',
      args: [],
    );
  }

  String get classVideo {
    return Intl.message(
      'class video',
      name: 'classVideo',
      desc: '',
      args: [],
    );
  }

  String get searchSubscribe {
    return Intl.message(
      'Search subscribe...',
      name: 'searchSubscribe',
      desc: '',
      args: [],
    );
  }

  String get openSubscribe {
    return Intl.message(
      'Open subscribe',
      name: 'openSubscribe',
      desc: '',
      args: [],
    );
  }

  String get closeSubscribe {
    return Intl.message(
      'Close subscribe',
      name: 'closeSubscribe',
      desc: '',
      args: [],
    );
  }

  String get subscribe {
    return Intl.message(
      'Subscribe',
      name: 'subscribe',
      desc: '',
      args: [],
    );
  }

  String get search {
    return Intl.message(
      'Search',
      name: 'search',
      desc: '',
      args: [],
    );
  }

  String get noSupportExternalVideoPlayer {
    return Intl.message(
      'Not find support external video player',
      name: 'noSupportExternalVideoPlayer',
      desc: '',
      args: [],
    );
  }

  String get identifyLinks {
    return Intl.message(
      'Identify links',
      name: 'identifyLinks',
      desc: '',
      args: [],
    );
  }

  String get ___________________FileStore___________________ {
    return Intl.message(
      '註解',
      name: '___________________FileStore___________________',
      desc: '',
      args: [],
    );
  }

  String get noPermission {
    return Intl.message(
      'Permission denied',
      name: 'noPermission',
      desc: '',
      args: [],
    );
  }

  String get ___________________AboutPage___________________ {
    return Intl.message(
      '註解',
      name: '___________________AboutPage___________________',
      desc: '',
      args: [],
    );
  }

  String get findNewVersion {
    return Intl.message(
      'Find new version',
      name: 'findNewVersion',
      desc: '',
      args: [],
    );
  }

  String get checkVersion {
    return Intl.message(
      'Check version',
      name: 'checkVersion',
      desc: '',
      args: [],
    );
  }

  String get checkingVersion {
    return Intl.message(
      'Checking version...',
      name: 'checkingVersion',
      desc: '',
      args: [],
    );
  }

  String get Contribution {
    return Intl.message(
      'Contribution',
      name: 'Contribution',
      desc: '',
      args: [],
    );
  }

  String get versionInfo {
    return Intl.message(
      'Version info',
      name: 'versionInfo',
      desc: '',
      args: [],
    );
  }

  String get isNewVersion {
    return Intl.message(
      'Already the latest version',
      name: 'isNewVersion',
      desc: '',
      args: [],
    );
  }

  String get autoAppCheck {
    return Intl.message(
      'Auto App Check',
      name: 'autoAppCheck',
      desc: '',
      args: [],
    );
  }

  String get logoutWarning {
    return Intl.message(
      'Are you sure you want to log out? \nAll data will be cleared',
      name: 'logoutWarning',
      desc: '',
      args: [],
    );
  }

  String get ___________________ScoreUI___________________ {
    return Intl.message(
      '註解',
      name: '___________________ScoreUI___________________',
      desc: '',
      args: [],
    );
  }

  String get titleScore {
    return Intl.message(
      'Score',
      name: 'titleScore',
      desc: '',
      args: [],
    );
  }

  String get error {
    return Intl.message(
      'Error',
      name: 'error',
      desc: '',
      args: [],
    );
  }

  String get searchScore {
    return Intl.message(
      'Search score',
      name: 'searchScore',
      desc: '',
      args: [],
    );
  }

  String get calculationCredit {
    return Intl.message(
      'Calculation credit',
      name: 'calculationCredit',
      desc: '',
      args: [],
    );
  }

  String get creditSummary {
    return Intl.message(
      'Credit Summary',
      name: 'creditSummary',
      desc: '',
      args: [],
    );
  }

  String get compulsoryCompulsory {
    return Intl.message(
      'Compulsory Compulsory',
      name: 'compulsoryCompulsory',
      desc: '',
      args: [],
    );
  }

  String get revisedCommonCompulsory {
    return Intl.message(
      'Revised Common Compulsory',
      name: 'revisedCommonCompulsory',
      desc: '',
      args: [],
    );
  }

  String get jointElective {
    return Intl.message(
      'Joint elective',
      name: 'jointElective',
      desc: '',
      args: [],
    );
  }

  String get compulsoryProfessional {
    return Intl.message(
      'Compulsory professional',
      name: 'compulsoryProfessional',
      desc: '',
      args: [],
    );
  }

  String get compulsoryMajorRevision {
    return Intl.message(
      'Compulsory major revision',
      name: 'compulsoryMajorRevision',
      desc: '',
      args: [],
    );
  }

  String get professionalElectives {
    return Intl.message(
      'Professional Electives',
      name: 'professionalElectives',
      desc: '',
      args: [],
    );
  }

  String get generalLessonSummary {
    return Intl.message(
      'General lesson summary',
      name: 'generalLessonSummary',
      desc: '',
      args: [],
    );
  }

  String get takeCore {
    return Intl.message(
      'Take core',
      name: 'takeCore',
      desc: '',
      args: [],
    );
  }

  String get takeSelect {
    return Intl.message(
      'Take select',
      name: 'takeSelect',
      desc: '',
      args: [],
    );
  }

  String get takeForeignDepartmentCredits {
    return Intl.message(
      'Foreign Department Credits',
      name: 'takeForeignDepartmentCredits',
      desc: '',
      args: [],
    );
  }

  String get scoreCalculationWarring {
    return Intl.message(
      'This calculation is for reference only. Actually, please focus on the school.',
      name: 'scoreCalculationWarring',
      desc: '',
      args: [],
    );
  }

  String get resultsOfVariousSubjects {
    return Intl.message(
      'Results of various subjects',
      name: 'resultsOfVariousSubjects',
      desc: '',
      args: [],
    );
  }

  String get semesterGrades {
    return Intl.message(
      'Semester grades',
      name: 'semesterGrades',
      desc: '',
      args: [],
    );
  }

  String get totalAverage {
    return Intl.message(
      'Total average',
      name: 'totalAverage',
      desc: '',
      args: [],
    );
  }

  String get performanceScores {
    return Intl.message(
      'Performance scores',
      name: 'performanceScores',
      desc: '',
      args: [],
    );
  }

  String get practiceCredit {
    return Intl.message(
      'Practice credit',
      name: 'practiceCredit',
      desc: '',
      args: [],
    );
  }

  String get creditsEarned {
    return Intl.message(
      'Credits earned',
      name: 'creditsEarned',
      desc: '',
      args: [],
    );
  }

  String get noRankInfo {
    return Intl.message(
      'No rank information',
      name: 'noRankInfo',
      desc: '',
      args: [],
    );
  }

  String get semesterRanking {
    return Intl.message(
      'Semester ranking',
      name: 'semesterRanking',
      desc: '',
      args: [],
    );
  }

  String get previousRankings {
    return Intl.message(
      'Previous rankings',
      name: 'previousRankings',
      desc: '',
      args: [],
    );
  }

  String get rank {
    return Intl.message(
      'Rank',
      name: 'rank',
      desc: '',
      args: [],
    );
  }

  String get totalPeople {
    return Intl.message(
      'Total people',
      name: 'totalPeople',
      desc: '',
      args: [],
    );
  }

  String get percentage {
    return Intl.message(
      'Percentage',
      name: 'percentage',
      desc: '',
      args: [],
    );
  }

  String get culturalDimension {
    return Intl.message(
      'Cultural dimension',
      name: 'culturalDimension',
      desc: '',
      args: [],
    );
  }

  String get historicalDimension {
    return Intl.message(
      'Historical dimension',
      name: 'historicalDimension',
      desc: '',
      args: [],
    );
  }

  String get philosophicalDimension {
    return Intl.message(
      'Philosophical dimension',
      name: 'philosophicalDimension',
      desc: '',
      args: [],
    );
  }

  String get ruleDimension {
    return Intl.message(
      'Rule of law',
      name: 'ruleDimension',
      desc: '',
      args: [],
    );
  }

  String get socialDimension {
    return Intl.message(
      'Social dimension',
      name: 'socialDimension',
      desc: '',
      args: [],
    );
  }

  String get naturalDimension {
    return Intl.message(
      'Natural dimension',
      name: 'naturalDimension',
      desc: '',
      args: [],
    );
  }

  String get sociologicalDimension {
    return Intl.message(
      'Sociological Dimension',
      name: 'sociologicalDimension',
      desc: '',
      args: [],
    );
  }

  String get creativeDirection {
    return Intl.message(
      'Creative direction',
      name: 'creativeDirection',
      desc: '',
      args: [],
    );
  }

  String get aestheticDimension {
    return Intl.message(
      'Aesthetic dimension',
      name: 'aestheticDimension',
      desc: '',
      args: [],
    );
  }

  String get culturalHistoricalDimension {
    return Intl.message(
      'Cultural and Historical dimension',
      name: 'culturalHistoricalDimension',
      desc: '',
      args: [],
    );
  }

  String get ___________________DirectoryPicker___________________ {
    return Intl.message(
      '註解',
      name: '___________________DirectoryPicker___________________',
      desc: '',
      args: [],
    );
  }

  String get directoryIsEmpty {
    return Intl.message(
      'Directory is empty!',
      name: 'directoryIsEmpty',
      desc: '',
      args: [],
    );
  }

  String get selectedDirectory {
    return Intl.message(
      'Selected directory',
      name: 'selectedDirectory',
      desc: '',
      args: [],
    );
  }

  String get EnterValidFolderName {
    return Intl.message(
      'Enter a valid folder name',
      name: 'EnterValidFolderName',
      desc: '',
      args: [],
    );
  }

  String get failedCreateFolder {
    return Intl.message(
      'Failed to create folder',
      name: 'failedCreateFolder',
      desc: '',
      args: [],
    );
  }

  String get createFolder {
    return Intl.message(
      'Create Folder',
      name: 'createFolder',
      desc: '',
      args: [],
    );
  }

  String get createNewFolder {
    return Intl.message(
      'Create New folder',
      name: 'createNewFolder',
      desc: '',
      args: [],
    );
  }

  String get grantPermission {
    return Intl.message(
      'Grant permission',
      name: 'grantPermission',
      desc: '',
      args: [],
    );
  }

  String get checkingPermission {
    return Intl.message(
      'Checking permission',
      name: 'checkingPermission',
      desc: '',
      args: [],
    );
  }

  String get ___________________GraduationPicker___________________ {
    return Intl.message(
      '註解',
      name: '___________________GraduationPicker___________________',
      desc: '',
      args: [],
    );
  }

  String get searching {
    return Intl.message(
      'Searching',
      name: 'searching',
      desc: '',
      args: [],
    );
  }

  String get searchingYear {
    return Intl.message(
      'Searching year',
      name: 'searchingYear',
      desc: '',
      args: [],
    );
  }

  String get searchingDivision {
    return Intl.message(
      'Searching division',
      name: 'searchingDivision',
      desc: '',
      args: [],
    );
  }

  String get searchingDepartment {
    return Intl.message(
      'Searching department',
      name: 'searchingDepartment',
      desc: '',
      args: [],
    );
  }

  String get searchingCreditInfo {
    return Intl.message(
      'Searching credit',
      name: 'searchingCreditInfo',
      desc: '',
      args: [],
    );
  }

  String get graduationSetting {
    return Intl.message(
      'Graduation credit standard setting',
      name: 'graduationSetting',
      desc: '',
      args: [],
    );
  }

  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'TW'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    if (locale != null) {
      for (var supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}