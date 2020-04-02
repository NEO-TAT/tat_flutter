// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

class S {
  S(this.localeName);
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final String name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      return S(localeName);
    });
  } 

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  final String localeName;

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
      'password',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  String get account {
    return Intl.message(
      'account',
      name: 'account',
      desc: '',
      args: [],
    );
  }

  String get warning {
    return Intl.message(
      'warning',
      name: 'warning',
      desc: '',
      args: [],
    );
  }

  String get sure {
    return Intl.message(
      'sure',
      name: 'sure',
      desc: '',
      args: [],
    );
  }

  String get cancel {
    return Intl.message(
      'cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  String get update {
    return Intl.message(
      'update',
      name: 'update',
      desc: '',
      args: [],
    );
  }

  String get setting {
    return Intl.message(
      'Setting',
      name: 'setting',
      desc: '',
      args: [],
    );
  }

  String get restart {
    return Intl.message(
      'restart',
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
      ' Download Error',
      name: 'downloadError',
      desc: '',
      args: [],
    );
  }

  String get isALink {
    return Intl.message(
      'is a Link',
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
      'Login to ISchool Plus Error',
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
      'Login Course System...',
      name: 'loginCourse',
      desc: '',
      args: [],
    );
  }

  String get loginCourseError {
    return Intl.message(
      'Login Course System Error',
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
      'Getting Calendar...',
      name: 'getCalendar',
      desc: '',
      args: [],
    );
  }

  String get getCalendarError {
    return Intl.message(
      'Getting Calendar Error',
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

  String get ___________________courseUi___________________ {
    return Intl.message(
      '註解',
      name: '___________________courseUi___________________',
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
      'refresh',
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

  String get noAnyFavorite {
    return Intl.message(
      'no any favorite',
      name: 'noAnyFavorite',
      desc: '',
      args: [],
    );
  }

  String get ___________________CreditUI___________________ {
    return Intl.message(
      '註解',
      name: '___________________CreditUI___________________',
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
      'Credit Search...',
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
      'Language switch',
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
      'not Support',
      name: 'notSupport',
      desc: '',
      args: [],
    );
  }

  String get focusLogin {
    return Intl.message(
      'focusLogin',
      name: 'focusLogin',
      desc: '',
      args: [],
    );
  }

  String get focusLoginResult {
    return Intl.message(
      '',
      name: 'focusLoginResult',
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
      'Check Version',
      name: 'checkVersion',
      desc: '',
      args: [],
    );
  }

  String get checkingVersion {
    return Intl.message(
      'Checking Version...',
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
      'Version Info',
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

  String get ___________________CreditUi___________________ {
    return Intl.message(
      '註解',
      name: '___________________CreditUi___________________',
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
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'), Locale.fromSubtags(languageCode: 'zh'),
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
      for (Locale supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}