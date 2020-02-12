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
import 'package:flutter_app/src/store/json/SettingJson.dart';
import 'package:flutter_app/src/taskcontrol/TaskHandler.dart';
import 'package:flutter_app/src/taskcontrol/task/CheckCookiesTask.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'json/CourseClassJson.dart';
import 'json/CourseTableJson.dart';
import 'json/NewAnnouncementJson.dart';
import 'json/UserDataJson.dart';

//flutter packages pub run build_runner build 創建Json

class Model {
  Model._privateConstructor();
  static final Model instance = Model._privateConstructor();
  SharedPreferences pref;
  static String userDataJsonKey         = "UserDataJsonKey";
  static String courseTableJsonKey       = "CourseTableJsonListKey";
  static String courseSemesterJsonKey    = "CourseSemesterListJson";
  static String newAnnouncementJsonKey = "newAnnouncementJson";
  static String settingJsonKey           = "SettingJsonKey";
  UserDataJson userData;
  NewAnnouncementJsonList newAnnouncementList;
  List<CourseTableJson> courseTableList;
  List<SemesterJson> courseSemesterList;
  SettingJson setting;
  Map<String,dynamic> tempData;


  String getCourseNameByCourseId( String courseId){
    String name;
    for( CourseTableJson courseDetail in courseTableList){
      name = courseDetail.getCourseNameByCourseId(courseId);
      if( name != null ){
        return name;
      }
    }
    return null;
  }

  Future<void> clearNewAnnouncement() async{
    newAnnouncementList = NewAnnouncementJsonList();
    setting.announcement = AnnouncementSettingJson();
    await save(newAnnouncementJsonKey);
    await save(settingJsonKey);
  }


  List<String> getSemesterListString(){
    List<String> stringList = List();
    if( courseSemesterList != null ){
      for( SemesterJson value in courseSemesterList){
        stringList.add( value.year + "-" + value.semester );
      }
    }
    return stringList;
  }



  Future<void> init() async {
    pref = await SharedPreferences.getInstance();
    await DioConnector.instance.init();
    tempData = Map();
    //_clearSetting( userDataJsonKey );
    //_clearSetting( courseTableJsonKey );
    //_clearSetting( newAnnouncementJsonKey );
    //_clearSetting( settingJsonKey );
    //DioConnector.instance.deleteCookies();

    courseSemesterList = courseSemesterList ?? List();

    String readJson;
    List<String> readJsonList;
    readJson = await _readString(userDataJsonKey);
    userData = ( readJson != null ) ? UserDataJson.fromJson( json.decode(readJson) ) : UserDataJson();

    readJsonList = await _readStringList(courseTableJsonKey);
    courseTableList = List();
    if( readJsonList != null ){
      for( String readJson in readJsonList){
        courseTableList.add( CourseTableJson.fromJson( json.decode(readJson) ) );
      }
    }

    readJson = await _readString( newAnnouncementJsonKey );
    newAnnouncementList = ( readJson != null ) ? NewAnnouncementJsonList.fromJson( json.decode(readJson) ) : NewAnnouncementJsonList();

    readJson = await _readString( settingJsonKey );
    setting = ( readJson != null ) ? SettingJson.fromJson( json.decode(readJson) ) : SettingJson();

  }


  Future<void> logout() async{
    List<String> clearKey = [userDataJsonKey ,courseTableJsonKey , courseSemesterJsonKey,newAnnouncementJsonKey , settingJsonKey ];
    for( String key in clearKey){
      _clearSetting(key);
    }
    DioConnector.instance.deleteCookies();
    await init();
  }

  Future<void> save(String key) async {
    List<String> saveKey = [userDataJsonKey ,courseTableJsonKey , courseSemesterJsonKey,newAnnouncementJsonKey , settingJsonKey ];
    List saveObj = [userData ,courseTableList , courseSemesterList,newAnnouncementList , setting];
    if( saveKey.contains(key) ){
      int index = saveKey.indexOf(key);
      if( key.contains("List") ){
        List<String> jsonList = List();
        for( dynamic obj in saveObj[index] ){
          jsonList.add( json.encode(obj) );
        }
        await _writeStringList(key, jsonList );
      }else{
        await _writeString(key, json.encode( saveObj[index] ) );
      }
    }
  }


  Future<void> clear(String key) async {
    List<String> saveKey = [userDataJsonKey ,courseTableJsonKey , courseSemesterJsonKey,newAnnouncementJsonKey , settingJsonKey ];
    if( saveKey.contains(key) ){
      await _clearSetting(key);
    }
  }


  void addCourseTable(CourseTableJson addCourseTable) {
    if( addCourseTable.studentId != userData.account ){  //只儲存自己的課表
      Log.d( "is not the same studentId");
      return;
    }
    List<CourseTableJson> tableList = courseTableList;
    for( int i = 0 ; i < tableList.length ; i++ ){
      CourseTableJson table = tableList[i];
      if ( table.courseSemester == addCourseTable.courseSemester ){
        tableList.removeAt(i);
      }
    }
    //Log.d( addCourseTable.toString());
    tableList.add(addCourseTable);
  }

  CourseTableJson getCourseTable(String studentId , SemesterJson courseSemester) {
    List<CourseTableJson> tableList = courseTableList;
    if(courseSemester == null || studentId.isEmpty ){
      return null;
    }
    for( int i = 0 ; i < tableList.length ; i++ ){
      CourseTableJson table = tableList[i];
      if ( table.courseSemester == courseSemester && table.studentId == studentId ){
        return table;
      }
    }
    return null;
  }

  
  Future<void> _writeString(String key , String value) async{
    await pref.setString(key, value);
  }

  Future<void> _writeStringList(String key , List<String> value) async{
    await pref.setStringList(key, value);
  }

  Future<String> _readString(String key) async{
    return pref.getString(key);
  }

  Future<List<String>> _readStringList(String key) async{
    return pref.getStringList(key);
  }

  Future<void> _clearSetting(String key) async{
    await pref.remove(key);
  }

}