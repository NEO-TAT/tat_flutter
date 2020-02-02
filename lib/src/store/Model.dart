import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/store/json/CourseInfoJson.dart';
import 'package:flutter_app/src/store/json/SettingJson.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprintf/sprintf.dart';

import '../connector/DioConnector.dart';
import 'json/CourseDetailJson.dart';
import 'json/CourseDetailJson.dart';
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



  Future<void> init() async {
    pref = await SharedPreferences.getInstance();
    await DioConnector.instance.init();

    //_clearSetting( courseTableJsonKey );
    //_clearSetting( newAnnouncementJsonKey );
    //_clearSetting( settingJsonKey );
    //DioConnector.instance.deleteCookies();

    String readJson;
    List<String> readJsonList;
    readJson = await _readString(userDataJsonKey);
    userData = ( readJson != null ) ? UserDataJson.fromJson( json.decode(readJson) ) : UserDataJson();
    Log.d( userData.toString() );

    readJsonList = await _readStringList(courseTableJsonKey);
    courseTableList = List();
    if( readJsonList != null ){
      for( String readJson in readJsonList){
        courseTableList.add( CourseTableJson.fromJson( json.decode(readJson) ) );
      }
    }

    readJson = await _readString( newAnnouncementJsonKey );
    newAnnouncementList = ( readJson != null ) ? NewAnnouncementJsonList.fromJson( json.decode(readJson) ) : NewAnnouncementJsonList();
    Log.d( newAnnouncementList.toString() );


    readJson = await _readString( settingJsonKey );
    setting = ( readJson != null ) ? SettingJson.fromJson( json.decode(readJson) ) : SettingJson();
    Log.d( setting.toString() );


    //Log.d( courseTableList.toString() );
  }


  Future<void> logout() async{
    List<String> clearKey = [userDataJsonKey ,courseTableJsonKey , courseSemesterJsonKey,newAnnouncementJsonKey , settingJsonKey ];
    for( String key in clearKey){
      _clearSetting(key);
    }
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

  void addCourseTable(CourseTableJson addCourseTable) {
    List<CourseTableJson> tableList = courseTableList;
    for( int i = 0 ; i < tableList.length ; i++ ){
      CourseTableJson table = tableList[i];
      if ( table.courseSemester == addCourseTable.courseSemester ){
        tableList.removeAt(i);
      }
    }
    Log.d(addCourseTable.toString());
    tableList.add(addCourseTable);
  }

  CourseTableJson getCourseTable(SemesterJson courseSemester) {
    List<CourseTableJson> tableList = courseTableList;
    if(courseSemester == null ){
      return null;
    }
    for( int i = 0 ; i < tableList.length ; i++ ){
      CourseTableJson table = tableList[i];
      if ( table.courseSemester == courseSemester ){
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