//  Model.dart
//  北科課程助手
//  用於儲存資料與得取資料
//  Created by morris13579 on 2020/02/12.
//  Copyright © 2020 morris13579 All rights reserved.
//
import 'dart:async';
import 'dart:convert';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/connector/core/DioConnector.dart';
import 'package:flutter_app/src/store/json/CourseScoreJson.dart';
import 'package:flutter_app/src/store/json/SettingJson.dart';
import 'package:flutter_app/src/taskcontrol/TaskHandler.dart';
import 'package:flutter_app/src/version/hotfix/AppHotFix.dart';
import 'package:flutter_app/src/version/update/AppUpdate.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'json/CourseClassJson.dart';
import 'json/CourseTableJson.dart';
import 'json/UserDataJson.dart';

//flutter packages pub run build_runner build 創建Json
//flutter packages pub run build_runner build --delete-conflicting-outputs
class Model {
  Model._privateConstructor();

  static final Model instance = Model._privateConstructor();
  SharedPreferences pref;
  static String userDataJsonKey = "UserDataJsonKey";

  //----------List----------//
  static String courseTableJsonKey = "CourseTableJsonListKey";
  static String courseSemesterJsonKey = "CourseSemesterListJson";

  //----------Object----------//
  static String scoreCreditJsonKey = "ScoreCreditJsonKey";
  static String newAnnouncementJsonKey = "newAnnouncementJson";
  static String settingJsonKey = "SettingJsonKey";
  UserDataJson _userData;
  List<CourseTableJson> _courseTableList;
  List<SemesterJson> _courseSemesterList;
  CourseScoreCreditJson _courseScoreList;
  SettingJson _setting;
  Map<String, bool> _firstRun = Map();
  static String courseNotice = "CourseNotice";
  static String appCheckUpdate = "AppCheckUpdate";
  Map<String, dynamic> _tempData;
  DefaultCacheManager cacheManager = new DefaultCacheManager();

  bool get autoCheckAppUpdate {
    return _setting.other.autoCheckAppUpdate;
  }

  bool getFirstUse(String key) {
    if (!_firstRun.containsKey(key)) {
      _firstRun[key] = true;
    }
    return _firstRun[key];
  }

  void setAlreadyUse(String key) {
    _firstRun[key] = false;
  }

  void setFirstUse(String key, bool value) {
    _firstRun[key] = value;
  }

  //--------------------UserDataJson--------------------//
  Future<void> saveUserData() async {
    await _save(userDataJsonKey, _userData);
  }

  Future<void> clearUserData() async {
    _userData = UserDataJson();
    await saveUserData();
  }

  Future<void> loadUserData() async {
    String readJson;
    readJson = await _readString(userDataJsonKey);
    _userData = (readJson != null)
        ? UserDataJson.fromJson(json.decode(readJson))
        : UserDataJson();
  }

  void setAccount(String account) {
    _userData.account = account;
  }

  String getAccount() {
    return _userData.account;
  }

  void setPassword(String password) {
    _userData.password = password;
  }

  String getPassword() {
    return _userData.password;
  }

  void setUserInfo(UserInfoJson value) {
    _userData.info = value;
  }

  UserInfoJson getUserInfo() {
    return _userData.info;
  }

  UserDataJson getUserData() {
    return _userData;
  }

  //--------------------List<CourseTableJson>--------------------//
  Future<void> saveCourseTableList() async {
    await _save(courseTableJsonKey, _courseTableList);
  }

  Future<void> clearCourseTableList() async {
    _courseTableList = List();
    await saveCourseTableList();
  }

  Future<void> loadCourseTableList() async {
    List<String> readJsonList = List();
    readJsonList = await _readStringList(courseTableJsonKey);
    _courseTableList = List();
    if (readJsonList != null) {
      for (String readJson in readJsonList) {
        _courseTableList.add(CourseTableJson.fromJson(json.decode(readJson)));
      }
    }
  }

  String getCourseNameByCourseId(String courseId) {
    //利用課程id取得課程資訊
    String name;
    for (CourseTableJson courseDetail in _courseTableList) {
      name = courseDetail.getCourseNameByCourseId(courseId);
      if (name != null) {
        return name;
      }
    }
    return null;
  }

  void removeCourseTable(CourseTableJson addCourseTable) {
    List<CourseTableJson> tableList = _courseTableList;
    for (int i = 0; i < tableList.length; i++) {
      CourseTableJson table = tableList[i];
      if (table.courseSemester == addCourseTable.courseSemester &&
          table.studentId == addCourseTable.studentId) {
        tableList.removeAt(i);
      }
    }
  }

  void addCourseTable(CourseTableJson addCourseTable) {
    List<CourseTableJson> tableList = _courseTableList;
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

  CourseTableJson getCourseTable(
      String studentId, SemesterJson courseSemester) {
    List<CourseTableJson> tableList = _courseTableList;
    if (courseSemester == null || studentId.isEmpty) {
      return null;
    }
    for (int i = 0; i < tableList.length; i++) {
      CourseTableJson table = tableList[i];
      if (table.courseSemester == courseSemester &&
          table.studentId == studentId) {
        return table;
      }
    }
    return null;
  }

  //--------------------SettingJson--------------------//
  Future<void> saveSetting() async {
    await _save(settingJsonKey, _setting);
  }

  Future<void> clearSetting() async {
    _setting = SettingJson();
    await saveSetting();
  }

  Future<void> loadSetting() async {
    String readJson;
    readJson = await _readString(settingJsonKey);
    _setting = (readJson != null)
        ? SettingJson.fromJson(json.decode(readJson))
        : SettingJson();
  }

  //--------------------CourseScoreCreditJson--------------------//
  Future<void> saveCourseScoreCredit() async {
    await _save(scoreCreditJsonKey, _courseScoreList);
  }

  List<SemesterCourseScoreJson> getSemesterCourseScore() {
    return _courseScoreList.semesterCourseScoreList;
  }

  GraduationInformationJson getGraduationInformation() {
    return _courseScoreList.graduationInformation;
  }

  CourseScoreCreditJson getCourseScoreCredit() {
    return _courseScoreList;
  }

  Future<void> clearCourseScoreCredit() async {
    _courseScoreList = CourseScoreCreditJson();
    await saveCourseScoreCredit();
  }

  Future<void> setCourseScoreCredit(CourseScoreCreditJson value) async {
    _courseScoreList = value;
    await saveCourseScoreCredit();
  }

  Future<void> setSemesterCourseScore(
      List<SemesterCourseScoreJson> value) async {
    _courseScoreList.graduationInformation = GraduationInformationJson();
    _courseScoreList.semesterCourseScoreList = value;
    await saveCourseScoreCredit();
  }

  Future<void> loadCourseScoreCredit() async {
    String readJson;
    readJson = await _readString(scoreCreditJsonKey);
    _courseScoreList = (readJson != null)
        ? CourseScoreCreditJson.fromJson(json.decode(readJson))
        : CourseScoreCreditJson();
  }

  //--------------------CourseSettingJson--------------------//
  Future<void> saveCourseSetting() async {
    await saveSetting();
  }

  Future<void> clearCourseSetting() async {
    _setting.course = CourseSettingJson();
    await saveCourseSetting();
  }

  void setCourseSetting(CourseSettingJson value) {
    _setting.course = value;
  }

  CourseSettingJson getCourseSetting() {
    return _setting.course;
  }

  //--------------------OtherSettingJson--------------------//
  Future<void> saveOtherSetting() async {
    await saveSetting();
  }

  Future<void> clearOtherSetting() async {
    _setting.other = OtherSettingJson();
    await saveOtherSetting();
  }

  void setOtherSetting(OtherSettingJson value) {
    _setting.other = value;
  }

  OtherSettingJson getOtherSetting() {
    return _setting.other;
  }

  //--------------------AnnouncementSettingJson--------------------//
  Future<void> saveAnnouncementSetting() async {
    await saveSetting();
  }

  Future<void> clearAnnouncementSetting() async {
    _setting.announcement = AnnouncementSettingJson();
    await saveAnnouncementSetting();
  }

  void setAnnouncementSetting(AnnouncementSettingJson value) {
    _setting.announcement = value;
  }

  AnnouncementSettingJson getAnnouncementSetting() {
    return _setting.announcement;
  }

  //--------------------List<SemesterJson>--------------------//
  Future<void> clearSemesterJsonList() async {
    _courseSemesterList = List();
  }

  Future<void> saveSemesterJsonList() async {
    _save(courseSemesterJsonKey, _courseSemesterList);
  }

  Future<void> loadSemesterJsonList() async {
    List<String> readJsonList = List();
    readJsonList = await _readStringList(courseSemesterJsonKey);
    _courseSemesterList = List();
    if (readJsonList != null) {
      for (String readJson in readJsonList) {
        _courseSemesterList.add(SemesterJson.fromJson(json.decode(readJson)));
      }
    }
  }

  void setSemesterJsonList(List<SemesterJson> value) {
    _courseSemesterList = value;
  }

  SemesterJson getSemesterJsonItem(int index) {
    if (_courseSemesterList.length > index) {
      return _courseSemesterList[index];
    } else {
      return null;
    }
  }

  List<SemesterJson> getSemesterList() {
    return _courseSemesterList;
  }

  List<String> getSemesterListString() {
    List<String> stringList = List();
    if (_courseSemesterList != null) {
      for (SemesterJson value in _courseSemesterList) {
        stringList.add(value.year + "-" + value.semester);
      }
    }
    return stringList;
  }

  //--------------------TempData--------------------//
  void setTempData(String key, dynamic value) {
    _tempData[key] = value;
  }

  dynamic getTempData(String key) {
    dynamic value;
    if (_tempData.containsKey(key)) {
      value = _tempData[key];
      _tempData.remove(key);
    }
    return value;
  }

  Future<void> getInstance() async {
    pref = await SharedPreferences.getInstance();
    await DioConnector.instance.init();
    _tempData = Map();
    _courseSemesterList = _courseSemesterList ?? List();
    await loadUserData();
    await loadCourseTableList();
    await loadSetting();
    await loadCourseScoreCredit();
    await loadSemesterJsonList();
    String version = await AppUpdate.getAppVersion();
    String preVersion = await _readString("version");
    Log.d(" preVersion: $preVersion \n version: $version");
    if (preVersion != version) {
      await AppHotFix.getInstance();
      AppHotFix.setDevMode(false); //更新APP版本後退出測模式
      _writeString("version", version); //寫入目前版本
      _setting.other.autoCheckAppUpdate = true; //開啟更新檢查
      saveOtherSetting();
    }
    //DioConnector.instance.deleteCookies();
  }

  Future<void> logout() async {
    await clearUserData();
    await clearSemesterJsonList();
    await clearCourseTableList();
    await clearCourseScoreCredit();
    await clearAnnouncementSetting();
    await clearCourseSetting();
    DioConnector.instance.deleteCookies();
    await cacheManager.emptyCache(); //clears all data in cache.
    TaskHandler.alreadyCheckSystem = ""; //全部登入重新檢查
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
    List<String> jsonList = List();
    for (dynamic obj in saveObj) {
      jsonList.add(json.encode(obj));
    }
    await _writeStringList(key, jsonList);
  }

  Future<void> _clear(String key) async {
    await _clearSetting(key);
  }

  //基本讀寫

  Future<void> _writeString(String key, String value) async {
    await pref.setString(key, value);
  }

  Future<void> _writeStringList(String key, List<String> value) async {
    await pref.setStringList(key, value);
  }

  Future<String> _readString(String key) async {
    return pref.getString(key);
  }

  Future<List<String>> _readStringList(String key) async {
    return pref.getStringList(key);
  }

  Future<void> _clearSetting(String key) async {
    await pref.remove(key);
  }
}
