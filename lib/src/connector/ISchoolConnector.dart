//
//  ISchoolConnector.dart
//  北科課程助手
//
//  Created by morris13579 on 2020/02/12.
//  Copyright © 2020 morris13579 All rights reserved.
//

import 'package:dio/dio.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/connector/core/ConnectorParameter.dart';
import 'package:flutter_app/src/connector/CourseConnector.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/store/object/CourseAnnouncementJson.dart';
import 'package:flutter_app/src/store/object/CourseFileJson.dart';
import 'package:flutter_app/src/store/json/CourseMainExtraJson.dart';
import 'package:flutter_app/src/store/json/NewAnnouncementJson.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'core/Connector.dart';

enum ISchoolConnectorStatus {
  LoginSuccess,
  LoginFail,
  ConnectTimeOutError,
  NetworkError,
  UnknownError
}

class ISchoolConnector {
  static bool _isLogin = false;
  static String loginStudentId;
  static final String _getLoginISchoolUrl =
      "https://nportal.ntut.edu.tw/ssoIndex.do";

  static final String _iSchoolUrl = "https://ischool.ntut.edu.tw/";
  static final String _postLoginISchoolUrl =
      _iSchoolUrl + "learning/auth/login.php";
  static final String _iSchoolFileUrl =
      _iSchoolUrl + "learning/document/document.php";
  static final String _iSchoolCourseAnnouncementUrl =
      _iSchoolUrl + "learning/announcements/announcements.php";
  static final String _iSchoolNewAnnouncementUrl =
      _iSchoolUrl + "learning/messaging/messagebox.php";
  static final String _iSchoolAnnouncementDetailUrl =
      _iSchoolUrl + "learning/messaging/readmessage.php";
  static final String _iSchoolDownloadUrl =
      _iSchoolUrl + "learning/backends/download.php";
  static final String _iSchooldeleteMessage =
      _iSchoolUrl + "learning/messaging/readmessage.php";

  //https://ischool.ntut.edu.tw/learning/messaging/messagebox.php?box=inbox&SelectorReadStatus=all&page=1&cmd=exDeleteMessage&messageId=5109

  static Future<ISchoolConnectorStatus> login({String studentId}) async {
    String result;
    try {
      ConnectorParameter parameter;
      Document tagNode;
      List<Element> nodes;
      Map<String, String> data = {
        "apUrl": "https://ischool.ntut.edu.tw/learning/auth/login.php",
        "apOu": "ischool",
        "sso": "true",
        "datetime1": DateTime.now().millisecondsSinceEpoch.toString()
      };
      parameter = ConnectorParameter(_getLoginISchoolUrl);
      parameter.data = data;
      result = await Connector.getDataByGet(parameter);
      tagNode = parse(result);
      nodes = tagNode.getElementsByTagName("input");
      data = Map();
      for (Element node in nodes) {
        String name = node.attributes['name'];
        String value = node.attributes['value'];
        data[name] = value;
      }
      if (studentId != null) {
        data["login"] = studentId;
        loginStudentId = studentId;
      } else {
        loginStudentId = data["login"];
      }
      String jumpUrl =
          tagNode.getElementsByTagName("form")[0].attributes["action"];
      parameter = ConnectorParameter(jumpUrl);
      parameter.data = data;
      await Connector.getDataByPostResponse(parameter);
      _isLogin = true;
      return ISchoolConnectorStatus.LoginSuccess;
    } catch (e) {
      Log.e(e.toString());
      return ISchoolConnectorStatus.LoginFail;
    }
  }

  static Future<bool> deleteNewAnnouncement(String messageId) async {
    ConnectorParameter parameter;
    try {
      Map<String, String> data = {
        "cmd": "exDelete",
        "messageId": messageId,
        "type": "received",
        "userId": Model.instance.getAccount(),
      };
      parameter = ConnectorParameter(_iSchooldeleteMessage);
      parameter.data = data;
      Response response = await Connector.getDataByGetResponse(parameter);
      bool isDelete = false;
      String location = response.redirects[0].location.toString();
      if (location.contains("messagebox.php")) {
        //確定刪除成功
        isDelete = true;
      }
      return isDelete;
    } catch (e) {
      Log.e(e.toString());
      return null;
    }
  }

  static Future<int> getNewAnnouncementPage() async {
    ConnectorParameter parameter;
    String result;
    Document tagNode;
    Element node;
    try {
      Map<String, String> data = {
        "box": "inbox",
        "SelectorReadStatus": "all",
        "page": "1",
      };
      parameter = ConnectorParameter(_iSchoolNewAnnouncementUrl);
      parameter.data = data;
      result = await Connector.getDataByGet(parameter);
      tagNode = parse(result);
      node = tagNode.getElementById("im_paging");
      return node.getElementsByTagName("a").length + 1;
    } catch (e) {
      Log.e(e.toString());
      return null;
    }
  }

  static Future<NewAnnouncementJsonList> getNewAnnouncement(int page) async {
    ConnectorParameter parameter;
    int i, j;
    String result;
    Document tagNode;
    List<Element> nodes, nodesItem;
    NewAnnouncementJsonList newAnnouncementJsonList = NewAnnouncementJsonList();
    try {
      Map<String, String> data = {
        "box": "inbox",
        "SelectorReadStatus": "all",
        "page": page.toString(),
      };
      parameter = ConnectorParameter(_iSchoolNewAnnouncementUrl);
      parameter.data = data;
      result = await Connector.getDataByGet(parameter);
      tagNode = parse(result);

      nodes = tagNode.getElementsByTagName("tbody"); // 取得兩個取第二個
      nodes = nodes[1].getElementsByTagName("tr");
      for (i = 0; i < nodes.length; i++) {
        //郵件是否已讀
        bool isRead = !nodes[i].classes.toString().contains("un");

        String title, postTime, sender, messageId, courseId;

        nodesItem = nodes[i].getElementsByTagName("td"); //三個 -> 課號 訊息 寄件者
        for (j = 0; j < nodesItem.length; j++) {
          switch (j) {
            case 0:
              String href =
                  nodesItem[j].getElementsByTagName("a")[1].attributes["href"];
              courseId = nodesItem[j]
                  .getElementsByClassName("im_context")[0]
                  .innerHtml;
              courseId = courseId.replaceAll(" ", "");
              courseId = courseId.replaceAll("[", "");
              courseId = courseId.replaceAll("]", "");
              courseId = courseId.split("-")[0];
              href = href.replaceAll("amp;", ""); //修正&後出現amp;問題
              messageId = Uri.parse(href).queryParameters["messageId"];
              title = nodesItem[j].getElementsByTagName("a")[1].innerHtml;
              title = title.replaceAll("amp;", ""); //修正&後出現amp;問題
              break;
            case 1:
              sender = nodesItem[j].getElementsByTagName("a")[0].innerHtml;
              break;
            case 2:
              postTime = nodesItem[j].innerHtml; //2019/10/09, PM 03:11
              break;
          }
        }

        int year = int.parse(postTime.split("/")[0]);
        int month = int.parse(postTime.split("/")[1]);
        int day = int.parse(postTime.split("/")[2].split(",")[0]);
        int hour =
            int.parse(postTime.split(",")[1].split(" ")[2].split(":")[0]);
        if (postTime.contains("PM")) {
          hour += 12;
        }
        int minute =
            int.parse(postTime.split(",")[1].split(" ")[2].split(":")[1]);
        String courseName;
        courseName = Model.instance.getCourseNameByCourseId(courseId);
        if (courseName == null) {
          Log.d("Not find the courseName");
          int time = 0;
          do {
            try {
              CourseExtraInfoJson courseMainInfo =
                  await CourseConnector.getCourseExtraInfo(courseId);
              courseName = courseMainInfo.course.name;
              break;
            } catch (e) {
              Log.d("course : $courseId can't find the courseName");
              time++;
            }
          } while (time <= 3);
        }

        NewAnnouncementJson newAnnouncement = NewAnnouncementJson(
            title: title,
            sender: sender,
            isRead: isRead,
            messageId: messageId,
            courseId: courseId,
            courseName: courseName,
            time: DateTime(year, month, day, hour, minute));
        newAnnouncementJsonList.newAnnouncementList.add(newAnnouncement);
      }
      return newAnnouncementJsonList;
    } catch (e) {
      Log.e(e.toString());
      return null;
    }
  }

  static Future<String> getNewAnnouncementDetail(String messageId) async {
    ConnectorParameter parameter;
    String result;
    Document tagNode;
    try {
      String detail;
      Map<String, String> data = {
        "messageId": messageId,
        "userId": Model.instance.getAccount(),
        "type": "received",
      };
      parameter = ConnectorParameter(_iSchoolAnnouncementDetailUrl);
      parameter.data = data;
      result = await Connector.getDataByGet(parameter);
      tagNode = parse(result);
      detail = tagNode.getElementsByClassName("imContent")[0].innerHtml;
      return detail;
    } catch (e) {
      Log.e(e.toString());
      return null;
    }
  }

  static Future<List<CourseAnnouncementJson>> getCourseAnnouncement(
      String courseId) async {
    ConnectorParameter parameter;
    String result;
    Document tagNode;
    Element node;
    List<Element> nodes, linkNodes;
    try {
      Map<String, String> data = {
        "cidReset": "true",
        "cidReq": courseId,
      };
      List<CourseAnnouncementJson> courseAnnouncementList = List();
      parameter = ConnectorParameter(_iSchoolCourseAnnouncementUrl);
      parameter.data = data;
      result = await Connector.getDataByGet(parameter);
      tagNode = parse(result);
      node = tagNode.getElementById("courseRightContent");
      nodes = node.getElementsByClassName("item");
      for (int i = 0; i < nodes.length; i++) {
        node = nodes[i];
        CourseAnnouncementJson courseAnnouncement = CourseAnnouncementJson();
        linkNodes = node.getElementsByClassName("lnk_link_list"); //處理下載連接
        for (Element linkNode in linkNodes) {
          if (linkNode.getElementsByTagName("a").length > 0) {
            String href =
                linkNode.getElementsByTagName("a")[0].attributes["href"];
            href = _iSchoolUrl + href;
            linkNode.getElementsByTagName("a")[0].attributes["href"] = href;
          }
        }
        courseAnnouncement.detail = node.innerHtml;
        Log.d(node.innerHtml);
        courseAnnouncementList.add(courseAnnouncement);
      }
      return courseAnnouncementList;
    } catch (e) {
      Log.e(e.toString());
      return null;
    }
  }

  static Future<List<CourseFileJson>> getCourseFile(String courseId) async {
    ConnectorParameter parameter;
    String result;
    Document tagNode;
    Element node;
    List<Element> courseFileNodes, nodes, itemNodes;
    try {
      Map<String, String> data = {
        "cidReset": "true",
        "cidReq": courseId,
      };
      List<CourseFileJson> courseFileList = List();
      parameter = ConnectorParameter(_iSchoolFileUrl);
      parameter.data = data;
      result = await Connector.getDataByGet(parameter);
      tagNode = parse(result);
      node = tagNode.getElementsByTagName("tbody")[1];

      courseFileNodes = node.getElementsByTagName("tr");
      if (courseFileNodes.length == 1) {
        nodes = courseFileNodes[0].getElementsByClassName("comment");
        if (nodes.length == 1) {
          if (nodes[0].innerHtml.contains("無")) {
            return courseFileList;
          }
        }
      }
      for (int i = 0; i < courseFileNodes.length; i++) {
        CourseFileJson courseFile = CourseFileJson();
        nodes = courseFileNodes[i].getElementsByTagName("td");
        //檔案名稱
        courseFile.name = nodes[0].text;
        //檔案上傳時間
        node = nodes[nodes.length - 1]; //時間
        List<String> splitString = node.text.split(".");
        int year = int.parse(splitString[0]);
        int month = int.parse(splitString[1]);
        int day = int.parse(splitString[2]);
        courseFile.time = DateTime(year, month, day);
        //檔案類型
        for (int j = 1; j < nodes.length - 1; j++) {
          itemNodes = nodes[j].getElementsByTagName("a");
          if (itemNodes.length > 0) {
            FileType fileType = FileType();
            String href = itemNodes[0].attributes["href"];
            href = href.replaceAll("amp;", "");
            fileType.href = _iSchoolUrl + href;
            fileType.type = CourseFileType.values[j - 1];
            courseFile.fileType.add(fileType);
          }
        }
        courseFileList.add(courseFile);
      }
      return courseFileList;
    } catch (e) {
      Log.e(e.toString());
      return null;
    }
  }

  static bool get isLogin {
    return _isLogin;
  }

  static void loginFalse() {
    _isLogin = false;
  }

  static Future<bool> checkLogin({String studentId}) async {
    Log.d("ISchool CheckLogin");
    ConnectorParameter parameter;
    _isLogin = false;
    studentId = studentId ?? Model.instance.getAccount();
    if (studentId != null) {
      if (studentId != loginStudentId) {
        return false;
      }
    }
    try {
      parameter = ConnectorParameter(_iSchoolUrl);
      Response response = await Connector.getDataByGetResponse(parameter);
      if (response.statusCode != 200) {
        return false;
      } else {
        Log.d("ISchool Is Readly Login");
        _isLogin = true;
        return true;
      }
    } catch (e) {
      //throw e;
      Log.e(e.toString());
      return false;
    }
  }
}
