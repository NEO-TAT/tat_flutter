import 'dart:async';
import 'dart:convert';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tat/src/connector/core/dio_connector.dart';
import 'package:tat/src/model/course/course_score_json.dart';
import 'package:tat/src/model/course_table/course_table_json.dart';
import 'package:tat/src/model/setting/setting_json.dart';
import 'package:tat/src/model/userdata/user_data_json.dart';

import '../model/course/course_class_json.dart';

class Model {
  Model._privateConstructor();

  static final Model instance = Model._privateConstructor();
  late final SharedPreferences pref;

  static const String userDataJsonKey = "UserDataJsonKey";
  static const String courseTableJsonKey = "CourseTableJsonListKey";
  static const String courseSemesterJsonKey = "CourseSemesterListJson";
  static const String scoreCreditJsonKey = "ScoreCreditJsonKey";
  static const String newAnnouncementJsonKey = "newAnnouncementJson";
  static const String settingJsonKey = "SettingJsonKey";
  static const String courseNotice = "CourseNotice";
  static const String appCheckUpdate = "AppCheckUpdate";

  late UserDataJson _userData;
  late CourseScoreCreditJson _courseScoreList;
  late SettingJson _setting;
  late final List<CourseTableJson> _courseTableList;
  late final List<SemesterJson>? _courseSemesterList;
  final Map<String, bool> _firstRun = Map();
  final DefaultCacheManager cacheManager = new DefaultCacheManager();

  bool get autoCheckAppUpdate => _setting.other.autoCheckAppUpdate;

  // timeOut seconds
  bool getFirstUse(String key, {int? timeOut}) {
    if (timeOut != null) {
      final millsTimeOut = timeOut * 1000;
      final wKey = "firstUse$key";
      final now = DateTime.now().millisecondsSinceEpoch;
      final before = _readInt(wKey);

      if (before != null && before > now) {
        //Already Use
        return false;
      } else {
        _writeInt(wKey, now + millsTimeOut);
      }
    }
    if (!_firstRun.containsKey(key)) {
      _firstRun[key] = true;
    }
    return _firstRun[key]!;
  }

  void setAlreadyUse(String key) => _firstRun[key] = false;

  void setFirstUse(String key, bool value) {
    final wKey = "firstUse$key";
    _writeInt(wKey, 0);
    _firstRun[key] = value;
  }

  // --------------------UserDataJson-------------------- //
  Future<void> saveUserData() async => await _save(userDataJsonKey, _userData);

  Future<void> clearUserData() async {
    _userData = UserDataJson();
    await saveUserData();
  }

  Future<void> loadUserData() async {
    final String? readJson = await _readString(userDataJsonKey);
    _userData = (readJson != null)
        ? UserDataJson.fromJson(json.decode(readJson))
        : UserDataJson();
  }

  void setAccount(String account) => _userData.account = account;

  String getAccount() => _userData.account;

  void setPassword(String password) => _userData.password = password;

  String getPassword() => _userData.password;

  void setUserInfo(UserInfoJson value) => _userData.info = value;

  UserInfoJson getUserInfo() => _userData.info;

  UserDataJson getUserData() => _userData;

  // --------------------List<CourseTableJson>-------------------- //
  Future<void> saveCourseTableList() async =>
      await _save(courseTableJsonKey, _courseTableList);

  Future<void> clearCourseTableList() async {
    _courseTableList = [];
    await saveCourseTableList();
  }

  Future<void> loadCourseTableList() async {
    final List<String>? readJsonList =
        await _readStringList(courseTableJsonKey);
    _courseTableList = [];
    if (readJsonList != null) {
      for (final readJson in readJsonList) {
        _courseTableList.add(CourseTableJson.fromJson(json.decode(readJson)));
      }
    }
  }

  // get course info by its id
  String? getCourseNameByCourseId(String courseId) {
    for (final courseDetail in _courseTableList) {
      final String? name = courseDetail.getCourseNameByCourseId(courseId);
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
      if (table.courseSemester == addCourseTable.courseSemester &&
          table.studentId == addCourseTable.studentId) {
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
        return b.courseSemester
            .toString()
            .compareTo(a.courseSemester.toString());
      }
      return a.studentId.compareTo(b.studentId);
    });
    return _courseTableList;
  }

  CourseTableJson? getCourseTable(
    String studentId,
    SemesterJson? courseSemester,
  ) {
    final tableList = _courseTableList;
    if (courseSemester == null || studentId.isEmpty) {
      return null;
    }
    for (int i = 0; i < tableList.length; i++) {
      final table = tableList[i];
      if (table.courseSemester == courseSemester &&
          table.studentId == studentId) {
        return table;
      }
    }
    return null;
  }

  // --------------------SettingJson-------------------- //
  Future<void> saveSetting() async => await _save(settingJsonKey, _setting);

  Future<void> clearSetting() async {
    _setting = SettingJson();
    await saveSetting();
  }

  Future<void> loadSetting() async {
    final String? readJson = await _readString(settingJsonKey);
    _setting = (readJson != null)
        ? SettingJson.fromJson(json.decode(readJson))
        : SettingJson();
  }

  // --------------------CourseScoreCreditJson-------------------- //
  Future<void> saveCourseScoreCredit() async =>
      await _save(scoreCreditJsonKey, _courseScoreList);

  List<SemesterCourseScoreJson> getSemesterCourseScore() =>
      _courseScoreList.semesterCourseScoreList!;

  GraduationInformationJson getGraduationInformation() =>
      _courseScoreList.graduationInformation!;

  CourseScoreCreditJson getCourseScoreCredit() => _courseScoreList;

  Future<void> clearCourseScoreCredit() async {
    _courseScoreList = CourseScoreCreditJson();
    await saveCourseScoreCredit();
  }

  Future<void> setCourseScoreCredit(CourseScoreCreditJson value) async {
    _courseScoreList = value;
    await saveCourseScoreCredit();
  }

  Future<void> setSemesterCourseScore(
    List<SemesterCourseScoreJson> value,
  ) async {
    _courseScoreList.graduationInformation = GraduationInformationJson();
    _courseScoreList.semesterCourseScoreList = value;
    await saveCourseScoreCredit();
  }

  Future<void> loadCourseScoreCredit() async {
    final String? readJson = await _readString(scoreCreditJsonKey);
    _courseScoreList = (readJson != null)
        ? CourseScoreCreditJson.fromJson(json.decode(readJson))
        : CourseScoreCreditJson();
  }

  // --------------------CourseSettingJson-------------------- //
  Future<void> saveCourseSetting() async => await saveSetting();

  Future<void> clearCourseSetting() async {
    _setting.course = CourseSettingJson();
    await saveCourseSetting();
  }

  void setCourseSetting(CourseSettingJson value) => _setting.course = value;

  CourseSettingJson getCourseSetting() => _setting.course;

  // --------------------OtherSettingJson-------------------- //
  Future<void> saveOtherSetting() async => await saveSetting();

  Future<void> clearOtherSetting() async {
    _setting.other = OtherSettingJson();
    await saveOtherSetting();
  }

  void setOtherSetting(OtherSettingJson value) => _setting.other = value;

  OtherSettingJson getOtherSetting() => _setting.other;

  // --------------------AnnouncementSettingJson-------------------- //
  Future<void> saveAnnouncementSetting() async => await saveSetting();

  Future<void> clearAnnouncementSetting() async {
    _setting.announcement = AnnouncementSettingJson();
    await saveAnnouncementSetting();
  }

  void setAnnouncementSetting(AnnouncementSettingJson value) =>
      _setting.announcement = value;

  AnnouncementSettingJson getAnnouncementSetting() => _setting.announcement;

  // --------------------List<SemesterJson>-------------------- //
  Future<void> clearSemesterJsonList() async => _courseSemesterList = [];

  Future<void> saveSemesterJsonList() async =>
      await _save(courseSemesterJsonKey, _courseSemesterList);

  Future<void> loadSemesterJsonList() async {
    final List<String>? readJsonList =
        await _readStringList(courseSemesterJsonKey);
    _courseSemesterList = [];
    if (readJsonList != null) {
      for (final readJson in readJsonList) {
        _courseSemesterList!.add(SemesterJson.fromJson(json.decode(readJson)));
      }
    }
  }

  void setSemesterJsonList(List<SemesterJson> value) =>
      _courseSemesterList = value;

  SemesterJson? getSemesterJsonItem(int index) {
    if (_courseSemesterList!.length > index) {
      return _courseSemesterList![index];
    } else {
      return null;
    }
  }

  List<SemesterJson> getSemesterList() => _courseSemesterList!;

  List<String> getSemesterListString() {
    final List<String> stringList = [];
    if (_courseSemesterList != null) {
      for (final value in _courseSemesterList!) {
        stringList.add(value.year + "-" + value.semester);
      }
    }
    return stringList;
  }

  Future<String?> getVersion() async => await _readString("version");

  Future<void> setVersion(String version) async =>
      await _writeString("version", version);

  Future<void> getInstance() async {
    pref = await SharedPreferences.getInstance();
    await DioConnector.dioInstance.init();
    _courseSemesterList ??= [];
    await loadUserData();
    await loadCourseTableList();
    await loadSetting();
    await loadCourseScoreCredit();
    await loadSemesterJsonList();
  }

  Future<void> logout() async {
    await clearUserData();
    await clearSemesterJsonList();
    await clearCourseTableList();
    await clearCourseScoreCredit();
    await clearAnnouncementSetting();
    await clearCourseSetting();
    DioConnector.dioInstance.deleteCookies();
    await cacheManager.emptyCache(); //clears all data in cache.
    setFirstUse(courseNotice, true);
    await getInstance();
  }

  Future<void> _save(String key, dynamic saveObj) async {
    try {
      await _saveJsonList(key, saveObj);
    } catch (e) {
      await _saveJson(key, saveObj);
    }
  }

  Future<void> _saveJson(String key, dynamic saveObj) async {
    await _writeString(key, json.encode(saveObj));
  }

  Future<void> _saveJsonList(String key, dynamic saveObj) async {
    final List<String> jsonList = [];
    for (dynamic obj in saveObj) {
      jsonList.add(json.encode(obj));
    }
    await _writeStringList(key, jsonList);
  }

  Future<void> _clear(String key) async => await _clearSetting(key);

  Future<void> _writeString(String key, String value) async =>
      await pref.setString(key, value);

  Future<void> _writeInt(String key, int value) async =>
      await pref.setInt(key, value);

  int? _readInt(String key) => pref.getInt(key);

  Future<void> _writeStringList(String key, List<String> value) async =>
      await pref.setStringList(key, value);

  Future<String?> _readString(String key) async => pref.getString(key);

  Future<List<String>?> _readStringList(String key) async =>
      pref.getStringList(key);

  Future<void> _clearSetting(String key) async => await pref.remove(key);
}
