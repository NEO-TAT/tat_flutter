// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars

class S {
  S();
  
  static S current;
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name); 
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      S.current = S();
      
      return S.current;
    });
  } 

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `NTUT Course Assistant`
  String get app_name {
    return Intl.message(
      'NTUT Course Assistant',
      name: 'app_name',
      desc: '',
      args: [],
    );
  }

  /// `註解`
  String get ___________________loginUi___________________ {
    return Intl.message(
      '註解',
      name: '___________________loginUi___________________',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get login {
    return Intl.message(
      'Login',
      name: 'login',
      desc: '',
      args: [],
    );
  }

  /// `Account password has been saved`
  String get loginSave {
    return Intl.message(
      'Account password has been saved',
      name: 'loginSave',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your account`
  String get accountNull {
    return Intl.message(
      'Please enter your account',
      name: 'accountNull',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the password`
  String get passwordNull {
    return Intl.message(
      'Please enter the password',
      name: 'passwordNull',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message(
      'Password',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  /// `Account`
  String get account {
    return Intl.message(
      'Account',
      name: 'account',
      desc: '',
      args: [],
    );
  }

  /// `Warning`
  String get warning {
    return Intl.message(
      'Warning',
      name: 'warning',
      desc: '',
      args: [],
    );
  }

  /// `Sure`
  String get sure {
    return Intl.message(
      'Sure',
      name: 'sure',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Update`
  String get update {
    return Intl.message(
      'Update',
      name: 'update',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get setting {
    return Intl.message(
      'Settings',
      name: 'setting',
      desc: '',
      args: [],
    );
  }

  /// `Restart`
  String get restart {
    return Intl.message(
      'Restart',
      name: 'restart',
      desc: '',
      args: [],
    );
  }

  /// `Calendar`
  String get calendar {
    return Intl.message(
      'Calendar',
      name: 'calendar',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred`
  String get alertError {
    return Intl.message(
      'An error occurred',
      name: 'alertError',
      desc: '',
      args: [],
    );
  }

  /// ` Download error`
  String get downloadError {
    return Intl.message(
      ' Download error',
      name: 'downloadError',
      desc: '',
      args: [],
    );
  }

  /// `Is a link`
  String get isALink {
    return Intl.message(
      'Is a link',
      name: 'isALink',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure to open?`
  String get AreYouSureToOpen {
    return Intl.message(
      'Are you sure to open?',
      name: 'AreYouSureToOpen',
      desc: '',
      args: [],
    );
  }

  /// `Download...`
  String get downloading {
    return Intl.message(
      'Download...',
      name: 'downloading',
      desc: '',
      args: [],
    );
  }

  /// `Download complete`
  String get downloadComplete {
    return Intl.message(
      'Download complete',
      name: 'downloadComplete',
      desc: '',
      args: [],
    );
  }

  /// `Prepare download...`
  String get prepareDownload {
    return Intl.message(
      'Prepare download...',
      name: 'prepareDownload',
      desc: '',
      args: [],
    );
  }

  /// `註解`
  String get ___________________task___________________ {
    return Intl.message(
      '註解',
      name: '___________________task___________________',
      desc: '',
      args: [],
    );
  }

  /// `Login to the NTUT...`
  String get loginNTUT {
    return Intl.message(
      'Login to the NTUT...',
      name: 'loginNTUT',
      desc: '',
      args: [],
    );
  }

  /// `Account password incorrect`
  String get accountPasswordError {
    return Intl.message(
      'Account password incorrect',
      name: 'accountPasswordError',
      desc: '',
      args: [],
    );
  }

  /// `Connection timed out`
  String get connectTimeOut {
    return Intl.message(
      'Connection timed out',
      name: 'connectTimeOut',
      desc: '',
      args: [],
    );
  }

  /// `Verification code error`
  String get authCodeFail {
    return Intl.message(
      'Verification code error',
      name: 'authCodeFail',
      desc: '',
      args: [],
    );
  }

  /// `Account is locked`
  String get accountLock {
    return Intl.message(
      'Account is locked',
      name: 'accountLock',
      desc: '',
      args: [],
    );
  }

  /// `Network error`
  String get networkError {
    return Intl.message(
      'Network error',
      name: 'networkError',
      desc: '',
      args: [],
    );
  }

  /// `An unknown error occurred`
  String get unknownError {
    return Intl.message(
      'An unknown error occurred',
      name: 'unknownError',
      desc: '',
      args: [],
    );
  }

  /// `Password is about to expire, please update password as soon as possible`
  String get passwordExpiredWarning {
    return Intl.message(
      'Password is about to expire, please update password as soon as possible',
      name: 'passwordExpiredWarning',
      desc: '',
      args: [],
    );
  }

  /// `Check login...`
  String get checkLogin {
    return Intl.message(
      'Check login...',
      name: 'checkLogin',
      desc: '',
      args: [],
    );
  }

  /// `Login to Score...`
  String get loginScore {
    return Intl.message(
      'Login to Score...',
      name: 'loginScore',
      desc: '',
      args: [],
    );
  }

  /// `Login to Score Error`
  String get loginScoreError {
    return Intl.message(
      'Login to Score Error',
      name: 'loginScoreError',
      desc: '',
      args: [],
    );
  }

  /// `Login to ISchool Plus...`
  String get loginISchoolPlus {
    return Intl.message(
      'Login to ISchool Plus...',
      name: 'loginISchoolPlus',
      desc: '',
      args: [],
    );
  }

  /// `Login to ISchool Plus error`
  String get loginISchoolPlusError {
    return Intl.message(
      'Login to ISchool Plus error',
      name: 'loginISchoolPlusError',
      desc: '',
      args: [],
    );
  }

  /// `Get schedule...`
  String get getCourse {
    return Intl.message(
      'Get schedule...',
      name: 'getCourse',
      desc: '',
      args: [],
    );
  }

  /// `Getting schedule error`
  String get getCourseError {
    return Intl.message(
      'Getting schedule error',
      name: 'getCourseError',
      desc: '',
      args: [],
    );
  }

  /// `Login course system...`
  String get loginCourse {
    return Intl.message(
      'Login course system...',
      name: 'loginCourse',
      desc: '',
      args: [],
    );
  }

  /// `Login course system error`
  String get loginCourseError {
    return Intl.message(
      'Login course system error',
      name: 'loginCourseError',
      desc: '',
      args: [],
    );
  }

  /// `Get semester list...`
  String get getCourseSemester {
    return Intl.message(
      'Get semester list...',
      name: 'getCourseSemester',
      desc: '',
      args: [],
    );
  }

  /// `Getting semester list error`
  String get getCourseSemesterError {
    return Intl.message(
      'Getting semester list error',
      name: 'getCourseSemesterError',
      desc: '',
      args: [],
    );
  }

  /// `Reading course materials...`
  String get getCourseDetail {
    return Intl.message(
      'Reading course materials...',
      name: 'getCourseDetail',
      desc: '',
      args: [],
    );
  }

  /// `Course data reading error`
  String get getCourseDetailError {
    return Intl.message(
      'Course data reading error',
      name: 'getCourseDetailError',
      desc: '',
      args: [],
    );
  }

  /// `Get course announcement...`
  String get getISchoolCourseAnnouncement {
    return Intl.message(
      'Get course announcement...',
      name: 'getISchoolCourseAnnouncement',
      desc: '',
      args: [],
    );
  }

  /// `Get course announcement error`
  String get getISchoolCourseAnnouncementError {
    return Intl.message(
      'Get course announcement error',
      name: 'getISchoolCourseAnnouncementError',
      desc: '',
      args: [],
    );
  }

  /// `Get course files`
  String get getISchoolCourseFile {
    return Intl.message(
      'Get course files',
      name: 'getISchoolCourseFile',
      desc: '',
      args: [],
    );
  }

  /// `Get course files error`
  String get getISchoolCourseFileError {
    return Intl.message(
      'Get course files error',
      name: 'getISchoolCourseFileError',
      desc: '',
      args: [],
    );
  }

  /// `Get course files`
  String get getISchoolPlusCourseFile {
    return Intl.message(
      'Get course files',
      name: 'getISchoolPlusCourseFile',
      desc: '',
      args: [],
    );
  }

  /// `Get course files error`
  String get getISchoolPlusCourseFileError {
    return Intl.message(
      'Get course files error',
      name: 'getISchoolPlusCourseFileError',
      desc: '',
      args: [],
    );
  }

  /// `Get course announcement...`
  String get getISchoolPlusCourseAnnouncement {
    return Intl.message(
      'Get course announcement...',
      name: 'getISchoolPlusCourseAnnouncement',
      desc: '',
      args: [],
    );
  }

  /// `Get course announcement error`
  String get getISchoolPlusCourseAnnouncementError {
    return Intl.message(
      'Get course announcement error',
      name: 'getISchoolPlusCourseAnnouncementError',
      desc: '',
      args: [],
    );
  }

  /// `Get course announcement detail...`
  String get getISchoolPlusCourseAnnouncementDetail {
    return Intl.message(
      'Get course announcement detail...',
      name: 'getISchoolPlusCourseAnnouncementDetail',
      desc: '',
      args: [],
    );
  }

  /// `Get course announcement detail error`
  String get getISchoolPlusCourseAnnouncementDetailError {
    return Intl.message(
      'Get course announcement detail error',
      name: 'getISchoolPlusCourseAnnouncementDetailError',
      desc: '',
      args: [],
    );
  }

  /// `Getting grade...`
  String get getScoreRank {
    return Intl.message(
      'Getting grade...',
      name: 'getScoreRank',
      desc: '',
      args: [],
    );
  }

  /// `Getting grade error`
  String get getScoreRankError {
    return Intl.message(
      'Getting grade error',
      name: 'getScoreRankError',
      desc: '',
      args: [],
    );
  }

  /// `Getting calendar...`
  String get getCalendar {
    return Intl.message(
      'Getting calendar...',
      name: 'getCalendar',
      desc: '',
      args: [],
    );
  }

  /// `Getting calendar error`
  String get getCalendarError {
    return Intl.message(
      'Getting calendar error',
      name: 'getCalendarError',
      desc: '',
      args: [],
    );
  }

  /// `Deleting message...`
  String get deleteMessage {
    return Intl.message(
      'Deleting message...',
      name: 'deleteMessage',
      desc: '',
      args: [],
    );
  }

  /// `Delete error`
  String get deleteMessageError {
    return Intl.message(
      'Delete error',
      name: 'deleteMessageError',
      desc: '',
      args: [],
    );
  }

  /// `Login to the NTUTApp...`
  String get loginNTUTApp {
    return Intl.message(
      'Login to the NTUTApp...',
      name: 'loginNTUTApp',
      desc: '',
      args: [],
    );
  }

  /// `Login to the NTUTApp Error`
  String get loginNTUTAppError {
    return Intl.message(
      'Login to the NTUTApp Error',
      name: 'loginNTUTAppError',
      desc: '',
      args: [],
    );
  }

  /// `註解`
  String get ___________________CourseTableUi___________________ {
    return Intl.message(
      '註解',
      name: '___________________CourseTableUi___________________',
      desc: '',
      args: [],
    );
  }

  /// `MON`
  String get Monday {
    return Intl.message(
      'MON',
      name: 'Monday',
      desc: '',
      args: [],
    );
  }

  /// `TUE`
  String get Tuesday {
    return Intl.message(
      'TUE',
      name: 'Tuesday',
      desc: '',
      args: [],
    );
  }

  /// `WED`
  String get Wednesday {
    return Intl.message(
      'WED',
      name: 'Wednesday',
      desc: '',
      args: [],
    );
  }

  /// `THU`
  String get Thursday {
    return Intl.message(
      'THU',
      name: 'Thursday',
      desc: '',
      args: [],
    );
  }

  /// `FRI`
  String get Friday {
    return Intl.message(
      'FRI',
      name: 'Friday',
      desc: '',
      args: [],
    );
  }

  /// `SAT`
  String get Saturday {
    return Intl.message(
      'SAT',
      name: 'Saturday',
      desc: '',
      args: [],
    );
  }

  /// `SUN`
  String get Sunday {
    return Intl.message(
      'SUN',
      name: 'Sunday',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get UnKnown {
    return Intl.message(
      '',
      name: 'UnKnown',
      desc: '',
      args: [],
    );
  }

  /// `Course`
  String get titleCourse {
    return Intl.message(
      'Course',
      name: 'titleCourse',
      desc: '',
      args: [],
    );
  }

  /// `Refresh`
  String get refresh {
    return Intl.message(
      'Refresh',
      name: 'refresh',
      desc: '',
      args: [],
    );
  }

  /// `Please enter student number`
  String get pleaseEnterStudentId {
    return Intl.message(
      'Please enter student number',
      name: 'pleaseEnterStudentId',
      desc: '',
      args: [],
    );
  }

  /// `Course number`
  String get courseId {
    return Intl.message(
      'Course number',
      name: 'courseId',
      desc: '',
      args: [],
    );
  }

  /// `Time`
  String get time {
    return Intl.message(
      'Time',
      name: 'time',
      desc: '',
      args: [],
    );
  }

  /// `Instructor`
  String get instructor {
    return Intl.message(
      'Instructor',
      name: 'instructor',
      desc: '',
      args: [],
    );
  }

  /// `Location`
  String get location {
    return Intl.message(
      'Location',
      name: 'location',
      desc: '',
      args: [],
    );
  }

  /// `Details`
  String get details {
    return Intl.message(
      'Details',
      name: 'details',
      desc: '',
      args: [],
    );
  }

  /// ` not support`
  String get noSupport {
    return Intl.message(
      ' not support',
      name: 'noSupport',
      desc: '',
      args: [],
    );
  }

  /// `No any favorite`
  String get noAnyFavorite {
    return Intl.message(
      'No any favorite',
      name: 'noAnyFavorite',
      desc: '',
      args: [],
    );
  }

  /// `Setting complete`
  String get settingComplete {
    return Intl.message(
      'Setting complete',
      name: 'settingComplete',
      desc: '',
      args: [],
    );
  }

  /// `Setup is complete, please add the weight again`
  String get settingCompleteWithError {
    return Intl.message(
      'Setup is complete, please add the weight again',
      name: 'settingCompleteWithError',
      desc: '',
      args: [],
    );
  }

  /// `Find I Plus new message`
  String get findNewMessage {
    return Intl.message(
      'Find I Plus new message',
      name: 'findNewMessage',
      desc: '',
      args: [],
    );
  }

  /// `Search credit`
  String get searchCredit {
    return Intl.message(
      'Search credit',
      name: 'searchCredit',
      desc: '',
      args: [],
    );
  }

  /// `Search credit...`
  String get searchingCredit {
    return Intl.message(
      'Search credit...',
      name: 'searchingCredit',
      desc: '',
      args: [],
    );
  }

  /// `There are currently no results, please log in to the academic performance query area to view the problem`
  String get searchCreditIsNullWarning {
    return Intl.message(
      'There are currently no results, please log in to the academic performance query area to view the problem',
      name: 'searchCreditIsNullWarning',
      desc: '',
      args: [],
    );
  }

  /// `Load favorite`
  String get loadFavorite {
    return Intl.message(
      'Load favorite',
      name: 'loadFavorite',
      desc: '',
      args: [],
    );
  }

  /// `Set as android weight`
  String get setAsAndroidWeight {
    return Intl.message(
      'Set as android weight',
      name: 'setAsAndroidWeight',
      desc: '',
      args: [],
    );
  }

  /// `註解`
  String get ___________________FileViewerPage___________________ {
    return Intl.message(
      '註解',
      name: '___________________FileViewerPage___________________',
      desc: '',
      args: [],
    );
  }

  /// `Sort by`
  String get sortBy {
    return Intl.message(
      'Sort by',
      name: 'sortBy',
      desc: '',
      args: [],
    );
  }

  /// `There's nothing here`
  String get nothingHere {
    return Intl.message(
      'There\'s nothing here',
      name: 'nothingHere',
      desc: '',
      args: [],
    );
  }

  /// `Cannot write to this Storage device!`
  String get cannotWrite {
    return Intl.message(
      'Cannot write to this Storage device!',
      name: 'cannotWrite',
      desc: '',
      args: [],
    );
  }

  /// `A Folder with that name already exists!`
  String get folderNameAlreadyExists {
    return Intl.message(
      'A Folder with that name already exists!',
      name: 'folderNameAlreadyExists',
      desc: '',
      args: [],
    );
  }

  /// `A File with that name already exists!`
  String get fileNameAlreadyExists {
    return Intl.message(
      'A File with that name already exists!',
      name: 'fileNameAlreadyExists',
      desc: '',
      args: [],
    );
  }

  /// `Rename item`
  String get renameItem {
    return Intl.message(
      'Rename item',
      name: 'renameItem',
      desc: '',
      args: [],
    );
  }

  /// `Rename`
  String get rename {
    return Intl.message(
      'Rename',
      name: 'rename',
      desc: '',
      args: [],
    );
  }

  /// `註解`
  String get ___________________NotificationPage___________________ {
    return Intl.message(
      '註解',
      name: '___________________NotificationPage___________________',
      desc: '',
      args: [],
    );
  }

  /// `Notification`
  String get titleNotification {
    return Intl.message(
      'Notification',
      name: 'titleNotification',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `download`
  String get download {
    return Intl.message(
      'download',
      name: 'download',
      desc: '',
      args: [],
    );
  }

  /// `Download ready to start`
  String get downloadWillStart {
    return Intl.message(
      'Download ready to start',
      name: 'downloadWillStart',
      desc: '',
      args: [],
    );
  }

  /// `File attachment detected`
  String get fileAttachmentDetected {
    return Intl.message(
      'File attachment detected',
      name: 'fileAttachmentDetected',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to download the file`
  String get areYouSureToDownload {
    return Intl.message(
      'Are you sure you want to download the file',
      name: 'areYouSureToDownload',
      desc: '',
      args: [],
    );
  }

  /// `註解`
  String get ___________________OtherUi___________________ {
    return Intl.message(
      '註解',
      name: '___________________OtherUi___________________',
      desc: '',
      args: [],
    );
  }

  /// `Score query`
  String get scoreSearch {
    return Intl.message(
      'Score query',
      name: 'scoreSearch',
      desc: '',
      args: [],
    );
  }

  /// `Download file`
  String get downloadFile {
    return Intl.message(
      'Download file',
      name: 'downloadFile',
      desc: '',
      args: [],
    );
  }

  /// `Downloads`
  String get fileViewer {
    return Intl.message(
      'Downloads',
      name: 'fileViewer',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get languageSetting {
    return Intl.message(
      'Language',
      name: 'languageSetting',
      desc: '',
      args: [],
    );
  }

  /// `Other`
  String get titleOther {
    return Intl.message(
      'Other',
      name: 'titleOther',
      desc: '',
      args: [],
    );
  }

  /// `Credit Viewer`
  String get creditViewer {
    return Intl.message(
      'Credit Viewer',
      name: 'creditViewer',
      desc: '',
      args: [],
    );
  }

  /// `Credit search...`
  String get creditSearch {
    return Intl.message(
      'Credit search...',
      name: 'creditSearch',
      desc: '',
      args: [],
    );
  }

  /// `Please Login`
  String get pleaseLogin {
    return Intl.message(
      'Please Login',
      name: 'pleaseLogin',
      desc: '',
      args: [],
    );
  }

  /// `No function`
  String get noFunction {
    return Intl.message(
      'No function',
      name: 'noFunction',
      desc: '',
      args: [],
    );
  }

  /// `Change the password`
  String get changePassword {
    return Intl.message(
      'Change the password',
      name: 'changePassword',
      desc: '',
      args: [],
    );
  }

  /// `Sign out`
  String get logout {
    return Intl.message(
      'Sign out',
      name: 'logout',
      desc: '',
      args: [],
    );
  }

  /// `Feedback`
  String get feedback {
    return Intl.message(
      'Feedback',
      name: 'feedback',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get about {
    return Intl.message(
      'About',
      name: 'about',
      desc: '',
      args: [],
    );
  }

  /// `This is an app about National Taipei University of Technology`
  String get aboutDialogString {
    return Intl.message(
      'This is an app about National Taipei University of Technology',
      name: 'aboutDialogString',
      desc: '',
      args: [],
    );
  }

  /// `Press again to close`
  String get closeOnce {
    return Intl.message(
      'Press again to close',
      name: 'closeOnce',
      desc: '',
      args: [],
    );
  }

  /// `Dark mode`
  String get darkMode {
    return Intl.message(
      'Dark mode',
      name: 'darkMode',
      desc: '',
      args: [],
    );
  }

  /// `Download path`
  String get downloadPath {
    return Intl.message(
      'Download path',
      name: 'downloadPath',
      desc: '',
      args: [],
    );
  }

  /// `Patch version`
  String get patchVersion {
    return Intl.message(
      'Patch version',
      name: 'patchVersion',
      desc: '',
      args: [],
    );
  }

  /// `Downloading patch...`
  String get downloadingPatch {
    return Intl.message(
      'Downloading patch...',
      name: 'downloadingPatch',
      desc: '',
      args: [],
    );
  }

  /// `Find the new patch version`
  String get findPatchNewVersion {
    return Intl.message(
      'Find the new patch version',
      name: 'findPatchNewVersion',
      desc: '',
      args: [],
    );
  }

  /// `After the download is complete, the APP will automatically restart to complete the update, wait about 10 seconds, please do not open it manually`
  String get patchUpdateDown {
    return Intl.message(
      'After the download is complete, the APP will automatically restart to complete the update, wait about 10 seconds, please do not open it manually',
      name: 'patchUpdateDown',
      desc: '',
      args: [],
    );
  }

  /// `Patch delete , Restart the application and apply`
  String get patchDelete {
    return Intl.message(
      'Patch delete , Restart the application and apply',
      name: 'patchDelete',
      desc: '',
      args: [],
    );
  }

  /// `Delete patch`
  String get deletePatch {
    return Intl.message(
      'Delete patch',
      name: 'deletePatch',
      desc: '',
      args: [],
    );
  }

  /// `Exit dev mode`
  String get exitDevMode {
    return Intl.message(
      'Exit dev mode',
      name: 'exitDevMode',
      desc: '',
      args: [],
    );
  }

  /// `Patch successfully upgraded version:`
  String get patchUpdateComplete {
    return Intl.message(
      'Patch successfully upgraded version:',
      name: 'patchUpdateComplete',
      desc: '',
      args: [],
    );
  }

  /// `Patch upgrade failed\nAutomatically downgraded to original version:`
  String get patchUpdateFail {
    return Intl.message(
      'Patch upgrade failed\nAutomatically downgraded to original version:',
      name: 'patchUpdateFail',
      desc: '',
      args: [],
    );
  }

  /// `Developer Mode`
  String get developerMode {
    return Intl.message(
      'Developer Mode',
      name: 'developerMode',
      desc: '',
      args: [],
    );
  }

  /// `Open with external video player`
  String get openExternalVideo {
    return Intl.message(
      'Open with external video player',
      name: 'openExternalVideo',
      desc: '',
      args: [],
    );
  }

  /// `Recommend use MX player`
  String get openExternalVideoHint {
    return Intl.message(
      'Recommend use MX player',
      name: 'openExternalVideoHint',
      desc: '',
      args: [],
    );
  }

  /// `Check IPlus new`
  String get checkIPlusNew {
    return Intl.message(
      'Check IPlus new',
      name: 'checkIPlusNew',
      desc: '',
      args: [],
    );
  }

  /// `註解`
  String get ___________________iSchoolUi___________________ {
    return Intl.message(
      '註解',
      name: '___________________iSchoolUi___________________',
      desc: '',
      args: [],
    );
  }

  /// `Course`
  String get course {
    return Intl.message(
      'Course',
      name: 'course',
      desc: '',
      args: [],
    );
  }

  /// `Announcement`
  String get announcement {
    return Intl.message(
      'Announcement',
      name: 'announcement',
      desc: '',
      args: [],
    );
  }

  /// `File`
  String get file {
    return Intl.message(
      'File',
      name: 'file',
      desc: '',
      args: [],
    );
  }

  /// `Without any announcement`
  String get noAnyAnnouncement {
    return Intl.message(
      'Without any announcement',
      name: 'noAnyAnnouncement',
      desc: '',
      args: [],
    );
  }

  /// `Please go directly to the download page`
  String get pleaseMoveToFilePage {
    return Intl.message(
      'Please go directly to the download page',
      name: 'pleaseMoveToFilePage',
      desc: '',
      args: [],
    );
  }

  /// `No files`
  String get noAnyFile {
    return Intl.message(
      'No files',
      name: 'noAnyFile',
      desc: '',
      args: [],
    );
  }

  /// `Course Title`
  String get courseName {
    return Intl.message(
      'Course Title',
      name: 'courseName',
      desc: '',
      args: [],
    );
  }

  /// `Credit`
  String get credit {
    return Intl.message(
      'Credit',
      name: 'credit',
      desc: '',
      args: [],
    );
  }

  /// `Category`
  String get category {
    return Intl.message(
      'Category',
      name: 'category',
      desc: '',
      args: [],
    );
  }

  /// `Syllabus`
  String get syllabus {
    return Intl.message(
      'Syllabus',
      name: 'syllabus',
      desc: '',
      args: [],
    );
  }

  /// `Start class`
  String get startClass {
    return Intl.message(
      'Start class',
      name: 'startClass',
      desc: '',
      args: [],
    );
  }

  /// `Classroom`
  String get classroom {
    return Intl.message(
      'Classroom',
      name: 'classroom',
      desc: '',
      args: [],
    );
  }

  /// `classroomUse`
  String get classroomUse {
    return Intl.message(
      'classroomUse',
      name: 'classroomUse',
      desc: '',
      args: [],
    );
  }

  /// `Number of students`
  String get numberOfStudent {
    return Intl.message(
      'Number of students',
      name: 'numberOfStudent',
      desc: '',
      args: [],
    );
  }

  /// `Number of withdraw`
  String get numberOfWithdraw {
    return Intl.message(
      'Number of withdraw',
      name: 'numberOfWithdraw',
      desc: '',
      args: [],
    );
  }

  /// `Course Information`
  String get courseData {
    return Intl.message(
      'Course Information',
      name: 'courseData',
      desc: '',
      args: [],
    );
  }

  /// `Student list`
  String get studentList {
    return Intl.message(
      'Student list',
      name: 'studentList',
      desc: '',
      args: [],
    );
  }

  /// `Use English interface`
  String get languageSwitch {
    return Intl.message(
      'Use English interface',
      name: 'languageSwitch',
      desc: '',
      args: [],
    );
  }

  /// `Will restart automatically`
  String get willRestart {
    return Intl.message(
      'Will restart automatically',
      name: 'willRestart',
      desc: '',
      args: [],
    );
  }

  /// `Not support`
  String get notSupport {
    return Intl.message(
      'Not support',
      name: 'notSupport',
      desc: '',
      args: [],
    );
  }

  /// `Force re-login`
  String get forceReLogin {
    return Intl.message(
      'Force re-login',
      name: 'forceReLogin',
      desc: '',
      args: [],
    );
  }

  /// `When it is judged that the logged-in mechanism is invalid, the check can be solved, but it will slow down the data acquisition speed`
  String get forceLoginResult {
    return Intl.message(
      'When it is judged that the logged-in mechanism is invalid, the check can be solved, but it will slow down the data acquisition speed',
      name: 'forceLoginResult',
      desc: '',
      args: [],
    );
  }

  /// `Is a video`
  String get isVideo {
    return Intl.message(
      'Is a video',
      name: 'isVideo',
      desc: '',
      args: [],
    );
  }

  /// `class video`
  String get classVideo {
    return Intl.message(
      'class video',
      name: 'classVideo',
      desc: '',
      args: [],
    );
  }

  /// `Search subscribe...`
  String get searchSubscribe {
    return Intl.message(
      'Search subscribe...',
      name: 'searchSubscribe',
      desc: '',
      args: [],
    );
  }

  /// `Open subscribe`
  String get openSubscribe {
    return Intl.message(
      'Open subscribe',
      name: 'openSubscribe',
      desc: '',
      args: [],
    );
  }

  /// `Close subscribe`
  String get closeSubscribe {
    return Intl.message(
      'Close subscribe',
      name: 'closeSubscribe',
      desc: '',
      args: [],
    );
  }

  /// `Subscribe`
  String get subscribe {
    return Intl.message(
      'Subscribe',
      name: 'subscribe',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get search {
    return Intl.message(
      'Search',
      name: 'search',
      desc: '',
      args: [],
    );
  }

  /// `Not find support external video player`
  String get noSupportExternalVideoPlayer {
    return Intl.message(
      'Not find support external video player',
      name: 'noSupportExternalVideoPlayer',
      desc: '',
      args: [],
    );
  }

  /// `Identify links`
  String get identifyLinks {
    return Intl.message(
      'Identify links',
      name: 'identifyLinks',
      desc: '',
      args: [],
    );
  }

  /// `註解`
  String get ___________________FileStore___________________ {
    return Intl.message(
      '註解',
      name: '___________________FileStore___________________',
      desc: '',
      args: [],
    );
  }

  /// `Permission denied`
  String get noPermission {
    return Intl.message(
      'Permission denied',
      name: 'noPermission',
      desc: '',
      args: [],
    );
  }

  /// `註解`
  String get ___________________AboutPage___________________ {
    return Intl.message(
      '註解',
      name: '___________________AboutPage___________________',
      desc: '',
      args: [],
    );
  }

  /// `Find new version`
  String get findNewVersion {
    return Intl.message(
      'Find new version',
      name: 'findNewVersion',
      desc: '',
      args: [],
    );
  }

  /// `Check version`
  String get checkVersion {
    return Intl.message(
      'Check version',
      name: 'checkVersion',
      desc: '',
      args: [],
    );
  }

  /// `Checking version...`
  String get checkingVersion {
    return Intl.message(
      'Checking version...',
      name: 'checkingVersion',
      desc: '',
      args: [],
    );
  }

  /// `Contribution`
  String get Contribution {
    return Intl.message(
      'Contribution',
      name: 'Contribution',
      desc: '',
      args: [],
    );
  }

  /// `Version info`
  String get versionInfo {
    return Intl.message(
      'Version info',
      name: 'versionInfo',
      desc: '',
      args: [],
    );
  }

  /// `Already the latest version`
  String get isNewVersion {
    return Intl.message(
      'Already the latest version',
      name: 'isNewVersion',
      desc: '',
      args: [],
    );
  }

  /// `Auto App Check`
  String get autoAppCheck {
    return Intl.message(
      'Auto App Check',
      name: 'autoAppCheck',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to log out? \nAll data will be cleared`
  String get logoutWarning {
    return Intl.message(
      'Are you sure you want to log out? \nAll data will be cleared',
      name: 'logoutWarning',
      desc: '',
      args: [],
    );
  }

  /// `註解`
  String get ___________________ScoreUI___________________ {
    return Intl.message(
      '註解',
      name: '___________________ScoreUI___________________',
      desc: '',
      args: [],
    );
  }

  /// `Score`
  String get titleScore {
    return Intl.message(
      'Score',
      name: 'titleScore',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get error {
    return Intl.message(
      'Error',
      name: 'error',
      desc: '',
      args: [],
    );
  }

  /// `Search score`
  String get searchScore {
    return Intl.message(
      'Search score',
      name: 'searchScore',
      desc: '',
      args: [],
    );
  }

  /// `Calculation credit`
  String get calculationCredit {
    return Intl.message(
      'Calculation credit',
      name: 'calculationCredit',
      desc: '',
      args: [],
    );
  }

  /// `Credit Summary`
  String get creditSummary {
    return Intl.message(
      'Credit Summary',
      name: 'creditSummary',
      desc: '',
      args: [],
    );
  }

  /// `Compulsory Compulsory`
  String get compulsoryCompulsory {
    return Intl.message(
      'Compulsory Compulsory',
      name: 'compulsoryCompulsory',
      desc: '',
      args: [],
    );
  }

  /// `Revised Common Compulsory`
  String get revisedCommonCompulsory {
    return Intl.message(
      'Revised Common Compulsory',
      name: 'revisedCommonCompulsory',
      desc: '',
      args: [],
    );
  }

  /// `Joint elective`
  String get jointElective {
    return Intl.message(
      'Joint elective',
      name: 'jointElective',
      desc: '',
      args: [],
    );
  }

  /// `Compulsory professional`
  String get compulsoryProfessional {
    return Intl.message(
      'Compulsory professional',
      name: 'compulsoryProfessional',
      desc: '',
      args: [],
    );
  }

  /// `Compulsory major revision`
  String get compulsoryMajorRevision {
    return Intl.message(
      'Compulsory major revision',
      name: 'compulsoryMajorRevision',
      desc: '',
      args: [],
    );
  }

  /// `Professional Electives`
  String get professionalElectives {
    return Intl.message(
      'Professional Electives',
      name: 'professionalElectives',
      desc: '',
      args: [],
    );
  }

  /// `General lesson summary`
  String get generalLessonSummary {
    return Intl.message(
      'General lesson summary',
      name: 'generalLessonSummary',
      desc: '',
      args: [],
    );
  }

  /// `Take core`
  String get takeCore {
    return Intl.message(
      'Take core',
      name: 'takeCore',
      desc: '',
      args: [],
    );
  }

  /// `Take select`
  String get takeSelect {
    return Intl.message(
      'Take select',
      name: 'takeSelect',
      desc: '',
      args: [],
    );
  }

  /// `Foreign Department Credits`
  String get takeForeignDepartmentCredits {
    return Intl.message(
      'Foreign Department Credits',
      name: 'takeForeignDepartmentCredits',
      desc: '',
      args: [],
    );
  }

  /// `Credit limit`
  String get takeForeignDepartmentCreditsLimit {
    return Intl.message(
      'Credit limit',
      name: 'takeForeignDepartmentCreditsLimit',
      desc: '',
      args: [],
    );
  }

  /// `This calculation is for reference only. Actually, please focus on the school.`
  String get scoreCalculationWarring {
    return Intl.message(
      'This calculation is for reference only. Actually, please focus on the school.',
      name: 'scoreCalculationWarring',
      desc: '',
      args: [],
    );
  }

  /// `Results of various subjects`
  String get resultsOfVariousSubjects {
    return Intl.message(
      'Results of various subjects',
      name: 'resultsOfVariousSubjects',
      desc: '',
      args: [],
    );
  }

  /// `Semester grades`
  String get semesterGrades {
    return Intl.message(
      'Semester grades',
      name: 'semesterGrades',
      desc: '',
      args: [],
    );
  }

  /// `Total average`
  String get totalAverage {
    return Intl.message(
      'Total average',
      name: 'totalAverage',
      desc: '',
      args: [],
    );
  }

  /// `Performance scores`
  String get performanceScores {
    return Intl.message(
      'Performance scores',
      name: 'performanceScores',
      desc: '',
      args: [],
    );
  }

  /// `Practice credit`
  String get practiceCredit {
    return Intl.message(
      'Practice credit',
      name: 'practiceCredit',
      desc: '',
      args: [],
    );
  }

  /// `Credits earned`
  String get creditsEarned {
    return Intl.message(
      'Credits earned',
      name: 'creditsEarned',
      desc: '',
      args: [],
    );
  }

  /// `No rank information`
  String get noRankInfo {
    return Intl.message(
      'No rank information',
      name: 'noRankInfo',
      desc: '',
      args: [],
    );
  }

  /// `Semester ranking`
  String get semesterRanking {
    return Intl.message(
      'Semester ranking',
      name: 'semesterRanking',
      desc: '',
      args: [],
    );
  }

  /// `Previous rankings`
  String get previousRankings {
    return Intl.message(
      'Previous rankings',
      name: 'previousRankings',
      desc: '',
      args: [],
    );
  }

  /// `Rank`
  String get rank {
    return Intl.message(
      'Rank',
      name: 'rank',
      desc: '',
      args: [],
    );
  }

  /// `Total people`
  String get totalPeople {
    return Intl.message(
      'Total people',
      name: 'totalPeople',
      desc: '',
      args: [],
    );
  }

  /// `Percentage`
  String get percentage {
    return Intl.message(
      'Percentage',
      name: 'percentage',
      desc: '',
      args: [],
    );
  }

  /// `Cultural dimension`
  String get culturalDimension {
    return Intl.message(
      'Cultural dimension',
      name: 'culturalDimension',
      desc: '',
      args: [],
    );
  }

  /// `Historical dimension`
  String get historicalDimension {
    return Intl.message(
      'Historical dimension',
      name: 'historicalDimension',
      desc: '',
      args: [],
    );
  }

  /// `Philosophical dimension`
  String get philosophicalDimension {
    return Intl.message(
      'Philosophical dimension',
      name: 'philosophicalDimension',
      desc: '',
      args: [],
    );
  }

  /// `Rule of law`
  String get ruleDimension {
    return Intl.message(
      'Rule of law',
      name: 'ruleDimension',
      desc: '',
      args: [],
    );
  }

  /// `Social dimension`
  String get socialDimension {
    return Intl.message(
      'Social dimension',
      name: 'socialDimension',
      desc: '',
      args: [],
    );
  }

  /// `Natural dimension`
  String get naturalDimension {
    return Intl.message(
      'Natural dimension',
      name: 'naturalDimension',
      desc: '',
      args: [],
    );
  }

  /// `Sociological Dimension`
  String get sociologicalDimension {
    return Intl.message(
      'Sociological Dimension',
      name: 'sociologicalDimension',
      desc: '',
      args: [],
    );
  }

  /// `Creative direction`
  String get creativeDirection {
    return Intl.message(
      'Creative direction',
      name: 'creativeDirection',
      desc: '',
      args: [],
    );
  }

  /// `Aesthetic dimension`
  String get aestheticDimension {
    return Intl.message(
      'Aesthetic dimension',
      name: 'aestheticDimension',
      desc: '',
      args: [],
    );
  }

  /// `Cultural and Historical dimension`
  String get culturalHistoricalDimension {
    return Intl.message(
      'Cultural and Historical dimension',
      name: 'culturalHistoricalDimension',
      desc: '',
      args: [],
    );
  }

  /// `Credit info`
  String get creditInfo {
    return Intl.message(
      'Credit info',
      name: 'creditInfo',
      desc: '',
      args: [],
    );
  }

  /// `註解`
  String get ___________________DirectoryPicker___________________ {
    return Intl.message(
      '註解',
      name: '___________________DirectoryPicker___________________',
      desc: '',
      args: [],
    );
  }

  /// `Directory is empty!`
  String get directoryIsEmpty {
    return Intl.message(
      'Directory is empty!',
      name: 'directoryIsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Selected directory`
  String get selectedDirectory {
    return Intl.message(
      'Selected directory',
      name: 'selectedDirectory',
      desc: '',
      args: [],
    );
  }

  /// `Enter a valid folder name`
  String get EnterValidFolderName {
    return Intl.message(
      'Enter a valid folder name',
      name: 'EnterValidFolderName',
      desc: '',
      args: [],
    );
  }

  /// `Failed to create folder`
  String get failedCreateFolder {
    return Intl.message(
      'Failed to create folder',
      name: 'failedCreateFolder',
      desc: '',
      args: [],
    );
  }

  /// `Create Folder`
  String get createFolder {
    return Intl.message(
      'Create Folder',
      name: 'createFolder',
      desc: '',
      args: [],
    );
  }

  /// `Create New folder`
  String get createNewFolder {
    return Intl.message(
      'Create New folder',
      name: 'createNewFolder',
      desc: '',
      args: [],
    );
  }

  /// `Grant permission`
  String get grantPermission {
    return Intl.message(
      'Grant permission',
      name: 'grantPermission',
      desc: '',
      args: [],
    );
  }

  /// `Checking permission`
  String get checkingPermission {
    return Intl.message(
      'Checking permission',
      name: 'checkingPermission',
      desc: '',
      args: [],
    );
  }

  /// `註解`
  String get ___________________GraduationPicker___________________ {
    return Intl.message(
      '註解',
      name: '___________________GraduationPicker___________________',
      desc: '',
      args: [],
    );
  }

  /// `Searching`
  String get searching {
    return Intl.message(
      'Searching',
      name: 'searching',
      desc: '',
      args: [],
    );
  }

  /// `Searching year`
  String get searchingYear {
    return Intl.message(
      'Searching year',
      name: 'searchingYear',
      desc: '',
      args: [],
    );
  }

  /// `Searching division`
  String get searchingDivision {
    return Intl.message(
      'Searching division',
      name: 'searchingDivision',
      desc: '',
      args: [],
    );
  }

  /// `Searching department`
  String get searchingDepartment {
    return Intl.message(
      'Searching department',
      name: 'searchingDepartment',
      desc: '',
      args: [],
    );
  }

  /// `Searching credit`
  String get searchingCreditInfo {
    return Intl.message(
      'Searching credit',
      name: 'searchingCreditInfo',
      desc: '',
      args: [],
    );
  }

  /// `Graduation credit standard setting`
  String get graduationSetting {
    return Intl.message(
      'Graduation credit standard setting',
      name: 'graduationSetting',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  /// `Loading...`
  String get loading {
    return Intl.message(
      'Loading...',
      name: 'loading',
      desc: '',
      args: [],
    );
  }

  /// `Please connect to network`
  String get pleaseConnectToNetwork {
    return Intl.message(
      'Please connect to network',
      name: 'pleaseConnectToNetwork',
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