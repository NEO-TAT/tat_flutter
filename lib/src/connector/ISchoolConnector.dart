import 'package:flutter_app/debug/log/Log.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';

import 'Connector.dart';
import 'NTUTConnector.dart';

enum ISchoolLoginStatus {
  LoginSuccess ,
  LoginFail ,
  ConnectTimeOutError ,
  NetworkError ,
  UnknownError
}

class ISchoolConnector {
  static bool _isLogin = false;
  static final String _postLoginISchoolUrl               =  "https://nportal.ntut.edu.tw/ssoIndex.do";
  static final String _iSchoolUrl                       = "https://ischool.ntut.edu.tw";
  static final String _iSchoolFileUrl                    = "https://ischool.ntut.edu.tw/learning/document/document.php";
  static final String _iSchoolCourseAnnouncementUrl     = "https://ischool.ntut.edu.tw/learning/announcements/announcements.php";
  static final String _iSchoolNewAnnouncementUrl       = "https://ischool.ntut.edu.tw/learning/messaging/messagebox.php";
  static final String _iSchoolAnnouncementDetailUrl      =  "https://ischool.ntut.edu.tw/learning/messaging/readmessage.php";
  static final String _iSchoolDownloadUrl               =  "https://ischool.ntut.edu.tw/learning/backends/download.php";
  static Future<ISchoolLoginStatus> login() async{
    try{
      Document document ;
      List<Element> nodes;
      if ( NTUTConnector.isLogin ){
        Map<String, String> data = {
          "apUrl": "https://ischool.ntut.edu.tw/learning/auth/login.php",
          "apOu": "ischool"
        };

        String result = await Connector.getDataByGet(_postLoginISchoolUrl , data );
        document  = parse(result);

        Log.d( result );
        nodes = document.getElementsByClassName("input");
        Log.d( nodes.length.toString() );
        data = Map();
        for ( Element node in nodes ){
          String name = node.attributes['name'];
          String value = node.attributes['value'];
          data[name] = value;
        }
        Log.d( data.toString() );
        return ISchoolLoginStatus.LoginSuccess;
      }else{
        Log.d( "NTUT is not Login" );
        return ISchoolLoginStatus.LoginFail;
      }
    } on Exception catch(e){
      Log.e(e.toString());
      return ISchoolLoginStatus.LoginFail;
    }
  }
}