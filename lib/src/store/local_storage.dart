// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.10
import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_app/src/connector/core/dio_connector.dart';
import 'package:flutter_app/src/model/course/course_score_json.dart';
import 'package:flutter_app/src/model/coursetable/course_table_json.dart';
import 'package:flutter_app/src/model/setting/setting_json.dart';
import 'package:flutter_app/src/model/userdata/user_data_json.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tat_core/tat_core.dart';

import '../model/course/course_class_json.dart';

class LocalStorage {
  LocalStorage._();

  factory LocalStorage() => _instance;
  static final _instance = LocalStorage._();

  static LocalStorage get instance => _instance;

  static const courseNotice = "CourseNotice";
  static const appCheckUpdate = "AppCheckUpdate";

  final cacheManager = DefaultCacheManager();

  final _userDataJsonKey = "UserDataJsonKey";
  final _courseTableJsonKey = "CourseTableJsonListKey";
  final _courseSemesterJsonKey = "CourseSemesterListJson";
  final _scoreCreditJsonKey = "ScoreCreditJsonKey";
  final _settingJsonKey = "SettingJsonKey";
  final _zUserInfoKey = 'ZUserInfoKey';
  final _zLoginCredentialKey = 'ZLoginCredentialKey';
  final _firstRun = <String, bool>{};
  final _courseTableList = <CourseTableJson>[];

  final _httpClientInterceptors = <Interceptor>[];

  SharedPreferences _pref;
  UserDataJson _userData;
  List<SemesterJson> _courseSemesterList;
  CourseScoreCreditJson _courseScoreList;
  SettingJson _setting;

  bool get autoCheckAppUpdate => _setting.other.autoCheckAppUpdate;

  bool getFirstUse(String key, {int timeOut}) {
    if (timeOut != null) {
      final millsTimeOut = timeOut * 1000;
      final wKey = "firstUse$key";
      final now = DateTime.now().millisecondsSinceEpoch;
      final before = _readInt(wKey);

      if (before != null && before > now) {
        return false;
      }

      _writeInt(wKey, now + millsTimeOut);
    }

    if (!_firstRun.containsKey(key)) {
      _firstRun[key] = true;
    }

    return _firstRun[key];
  }

  void setAlreadyUse(String key) => _firstRun[key] = false;

  void _setFirstUse(String key, bool value) => _firstRun[key] = value;

  Future<void> saveUserData() => _save(_userDataJsonKey, _userData);

  Future<void> clearUserData() {
    _userData = UserDataJson();
    return saveUserData();
  }

  void _loadUserData() {
    final readJson = _readString(_userDataJsonKey);
    _userData = (readJson != null) ? UserDataJson.fromJson(json.decode(readJson)) : UserDataJson();
  }

  void setAccount(String account) => _userData.account = account;

  String getAccount() => _userData.account;

  void setPassword(String password) => _userData.password = password;

  String getPassword() => _userData.password;

  void setUserInfo(UserInfoJson value) => _userData.info = value;

  UserInfoJson getUserInfo() => _userData.info;

  UserDataJson getUserData() => _userData;

  Future<void> saveCourseTableList() => _save(_courseTableJsonKey, _courseTableList);

  Future<void> clearCourseTableList() {
    _courseTableList.clear();
    return saveCourseTableList();
  }

  void _loadCourseTableList() {
    final readJsonList = _readStringList(_courseTableJsonKey);
    _courseTableList.clear();
    if (readJsonList != null) {
      for (final readJson in readJsonList) {
        _courseTableList.add(CourseTableJson.fromJson(json.decode(readJson)));
      }
    }
  }

  String getCourseNameByCourseId(String courseId) {
    for (final courseDetail in _courseTableList) {
      final name = courseDetail.getCourseNameByCourseId(courseId);
      if (name != null) {
        return name;
      }
    }

    return null;
  }

  void removeCourseTable(CourseTableJson addCourseTable) {
    final tableList = _courseTableList;
    for (int i = 0; i < tableList.length; i++) {
      final table = tableList[i];
      if (table.courseSemester == addCourseTable.courseSemester && table.studentId == addCourseTable.studentId) {
        tableList.removeAt(i);
      }
    }
  }

  void addCourseTable(CourseTableJson addCourseTable) {
    final tableList = _courseTableList;
    removeCourseTable(addCourseTable);
    tableList.add(addCourseTable);
  }

  List<CourseTableJson> getCourseTableList() {
    _courseTableList.sort((a, b) {
      if (a.studentId == b.studentId) {
        return b.courseSemester.toString().compareTo(a.courseSemester.toString());
      }
      return a.studentId.compareTo(b.studentId);
    });
    return _courseTableList;
  }

  CourseTableJson getCourseTable(String studentId, SemesterJson courseSemester) {
    final tableList = _courseTableList;

    if (courseSemester == null || studentId.isEmpty) {
      return null;
    }

    for (int i = 0; i < tableList.length; i++) {
      final table = tableList[i];
      if (table.courseSemester == courseSemester && table.studentId == studentId) {
        return table;
      }
    }

    return null;
  }

  Future<void> _saveSetting() => _save(_settingJsonKey, _setting);

  void _loadSetting() {
    final readJson = _readString(_settingJsonKey);
    _setting = (readJson != null) ? SettingJson.fromJson(json.decode(readJson)) : SettingJson();
  }

  Future<void> saveCourseScoreCredit() => _save(_scoreCreditJsonKey, _courseScoreList);

  List<SemesterCourseScoreJson> getSemesterCourseScore() => _courseScoreList.semesterCourseScoreList;

  GraduationInformationJson getGraduationInformation() => _courseScoreList.graduationInformation;

  CourseScoreCreditJson getCourseScoreCredit() => _courseScoreList;

  Future<void> _clearCourseScoreCredit() {
    _courseScoreList = CourseScoreCreditJson();
    return saveCourseScoreCredit();
  }

  Future<void> setCourseScoreCredit(CourseScoreCreditJson value) {
    _courseScoreList = value;
    return saveCourseScoreCredit();
  }

  Future<void> setSemesterCourseScore(List<SemesterCourseScoreJson> value) {
    _courseScoreList.graduationInformation = GraduationInformationJson();
    _courseScoreList.semesterCourseScoreList = value;
    return saveCourseScoreCredit();
  }

  void _loadCourseScoreCredit() {
    final readJson = _readString(_scoreCreditJsonKey);
    _courseScoreList =
        (readJson != null) ? CourseScoreCreditJson.fromJson(json.decode(readJson)) : CourseScoreCreditJson();
  }

  Future<void> saveCourseSetting() => _saveSetting();

  Future<void> clearCourseSetting() {
    _setting.course = CourseSettingJson();
    return saveCourseSetting();
  }

  CourseSettingJson getCourseSetting() => _setting.course;

  Future<void> saveOtherSetting() => _saveSetting();

  void setOtherSetting(OtherSettingJson value) => _setting.other = value;

  OtherSettingJson getOtherSetting() => _setting.other;

  Future<void> _saveAnnouncementSetting() => _saveSetting();

  Future<void> _clearAnnouncementSetting() {
    _setting.announcement = AnnouncementSettingJson();
    return _saveAnnouncementSetting();
  }

  Future<void> saveZuvioLoginCredential(ZLoginCredential credential) =>
      _writeString(_zLoginCredentialKey, jsonEncode(credential.toJson()));

  Future<void> saveZuvioUserInfo(ZUserInfo userInfo) => _writeString(_zUserInfoKey, jsonEncode(userInfo.toJson()));

  ZLoginCredential getZuvioLoginCredential() {
    final savedData = _readString(_zLoginCredentialKey);
    return (savedData == null) ? null : ZLoginCredential.fromJson(jsonDecode(savedData) as Map<String, dynamic>);
  }

  ZUserInfo getZuvioUserInfo() {
    final savedData = _readString(_zUserInfoKey);
    return (savedData == null) ? null : ZUserInfo.fromJson(jsonDecode(savedData) as Map<String, dynamic>);
  }

  void clearSemesterJsonList() => _courseSemesterList.clear();

  void _loadSemesterJsonList() {
    final readJsonList = _readStringList(_courseSemesterJsonKey);
    _courseSemesterList.clear();

    if (readJsonList != null) {
      for (final readJson in readJsonList) {
        _courseSemesterList.add(SemesterJson.fromJson(json.decode(readJson)));
      }
    }
  }

  void setSemesterJsonList(List<SemesterJson> value) => _courseSemesterList = value;

  SemesterJson getSemesterJsonItem(int index) =>
      (_courseSemesterList.length > index) ? _courseSemesterList[index] : null;

  List<SemesterJson> getSemesterList() => _courseSemesterList;

  String getVersion() => _readString("version");

  Future<void> setVersion(String version) => _writeString("version", version);

  Future<void> init({List<Interceptor> httpClientInterceptors = const []}) async {
    _pref = await SharedPreferences.getInstance();
    await DioConnector.instance.init(interceptors: httpClientInterceptors);
    _httpClientInterceptors.addAll(httpClientInterceptors);
    _courseSemesterList = _courseSemesterList ?? [];
    _loadUserData();
    _loadCourseTableList();
    _loadSetting();
    _loadCourseScoreCredit();
    _loadSemesterJsonList();
  }

  Future<void> logout() async {
    await clearUserData();
    clearSemesterJsonList();
    await clearCourseTableList();
    await _clearCourseScoreCredit();
    await _clearAnnouncementSetting();
    await clearCourseSetting();
    DioConnector.instance.deleteCookies();
    await cacheManager.emptyCache(); //clears all data in cache.
    _setFirstUse(courseNotice, true);
    await init();
  }

  Future<void> _save(String key, dynamic saveObj) async {
    try {
      await _saveJsonList(key, saveObj);
    } catch (e) {
      await _saveJson(key, saveObj);
    }
  }

  Future<void> _saveJson(String key, dynamic saveObj) => _writeString(key, json.encode(saveObj));

  Future<void> _saveJsonList(String key, dynamic saveObj) async {
    final jsonList = <String>[];

    for (dynamic obj in saveObj) {
      jsonList.add(json.encode(obj));
    }

    await _writeStringList(key, jsonList);
  }

  Future<void> _writeString(String key, String value) => _pref.setString(key, value);

  Future<void> _writeInt(String key, int value) => _pref.setInt(key, value);

  int _readInt(String key) => _pref.getInt(key);

  Future<void> _writeStringList(String key, List<String> value) => _pref.setStringList(key, value);

  String _readString(String key) => _pref.getString(key);

  List<String> _readStringList(String key) => _pref.getStringList(key);
}
