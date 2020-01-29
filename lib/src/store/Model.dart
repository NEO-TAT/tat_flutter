import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprintf/sprintf.dart';

import '../connector/DioConnector.dart';
import 'json/CourseDetailJson.dart';
import 'json/CourseDetailJson.dart';
import 'json/UserDataJson.dart';

class Model {
  Model._privateConstructor();
  static final Model instance = Model._privateConstructor();
  SharedPreferences pref;
  static String userDataJsonKey = "UserDataJsonKey";
  static String courseDetailJsonKey = "CourseDetailListJson";
  static String courseSemesterJsonKey = "CourseSemesterListJson";

  UserDataJson userData;
  List<CourseDetailJson> courseDetail;
  List<CourseSemesterJson> courseSemester;

  Future<void> init() async {
    pref = await SharedPreferences.getInstance();
    await DioConnector.instance.init();

    String readJson = await _readString(userDataJsonKey);
    userData = UserDataJson.fromJson( json.decode(readJson) );
    Log.d( userData.toString() );
  }


  Future<void> logout() async{
    List<String> clearKey = [userDataJsonKey ,courseDetailJsonKey , courseSemesterJsonKey];
    for( String key in clearKey){
      _clearSetting(key);
    }
  }

  Future<void> save(String key) async {
    List<String> saveKey = [userDataJsonKey ,courseDetailJsonKey , courseSemesterJsonKey];
    List saveObj = [userDataJsonKey ,courseDetailJsonKey , courseSemesterJsonKey];
    if( saveKey.contains(key) ){
      int index = saveKey.indexOf(key);
      if( key.contains("List") ){
        List<String> jsonList = List();
        for( dynamic obj in saveObj[index] ){
          jsonList.add( json.decode(obj) );
        }
        await _writeStringList(key, jsonList );
      }else{
        await _writeString(key, json.decode( saveObj[index] ) );
      }
    }

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