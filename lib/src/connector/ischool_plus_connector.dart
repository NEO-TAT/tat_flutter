// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.10
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_app/debug/log/log.dart';
import 'package:flutter_app/src/connector/core/connector.dart';
import 'package:flutter_app/src/model/ischoolplus/course_file_json.dart';
import 'package:flutter_app/src/model/ischoolplus/ischool_plus_announcement_json.dart';
import 'package:flutter_app/src/util/html_utils.dart';
import 'package:html/dom.dart' as html;
import 'package:html/parser.dart' as html;

import 'core/connector_parameter.dart';
import 'ntut_connector.dart';

enum ISchoolPlusConnectorStatus { loginSuccess, loginFail, unknownError }

enum IPlusReturnStatus { success, fail, noPermission }

class ReturnWithStatus<T> {
  IPlusReturnStatus status;
  T result;
}

class ISchoolPlusConnector {
  static const String _iSchoolPlusUrl = "https://istudy.ntut.edu.tw/";

  //static final String _getLoginISchoolUrl = _iSchoolPlusUrl + "mooc/login.php";
  //static final String _postLoginISchoolUrl = _iSchoolPlusUrl + "login.php";
  //static final String _iSchoolPlusIndexUrl = _iSchoolPlusUrl + "mooc/index.php";
  static const String _getCourseName = "${_iSchoolPlusUrl}learn/mooc_sysbar.php";
  static const _ssoLoginUrl = "${NTUTConnector.host}ssoIndex.do";

  static Future<ISchoolPlusConnectorStatus> login(String account) async {
    String result;
    try {
      ConnectorParameter parameter;
      html.Document tagNode;
      List<html.Element> nodes;
      final data = {
        "apUrl": "https://istudy.ntut.edu.tw/login.php",
        "apOu": "ischool_plus_",
        "sso": "true",
        "datetime1": DateTime.now().millisecondsSinceEpoch.toString()
      };
      parameter = ConnectorParameter(_ssoLoginUrl);
      parameter.data = data;
      result = (await Connector.getDataByGet(parameter));

      tagNode = html.parse(result.toString().trim());
      nodes = tagNode.getElementsByTagName("input");
      data.clear();
      for (final node in nodes) {
        final name = node.attributes['name'];
        final value = node.attributes['value'];
        data[name] = value;
      }
      final jumpUrl = tagNode.getElementsByTagName("form")[0].attributes["action"];
      parameter = ConnectorParameter(jumpUrl);
      parameter.data = data;

      Response<dynamic> jumpResult = (await Connector.getDataByPostResponse(parameter));
      // Perform retry for cryptic API errors (?).
      // If the string `connect lost` be found in the response, we will do the retry.
      int retryTimes = 3;
      do {
        if (jumpResult.data.toString().contains('connect lost')) {
          // Take a short delay to avoid being blocked.
          await Future.delayed(const Duration(milliseconds: 100));
          jumpResult = (await Connector.getDataByPostResponse(parameter));
        } else {
          break;
        }
      } while ((retryTimes--) > 0);

      await FirebaseAnalytics.instance.logLogin(
        loginMethod: 'ntut_iplus',
      );
      return ISchoolPlusConnectorStatus.loginSuccess;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return ISchoolPlusConnectorStatus.loginFail;
    }
  }

  static Future<ReturnWithStatus<List<CourseFileJson>>> getCourseFile(String courseId) async {
    ConnectorParameter parameter;
    String result;
    html.Document tagNode;
    html.Element node, itemNode, resourceNode;
    RegExp exp;
    RegExpMatch matches;
    List<html.Element> nodes, itemNodes, resourceNodes;
    var value = ReturnWithStatus<List<CourseFileJson>>();
    try {
      List<CourseFileJson> courseFileList = [];
      if (!await _selectCourse(courseId)) {
        value.status = IPlusReturnStatus.noPermission;
        return value;
      }

      parameter = ConnectorParameter("${_iSchoolPlusUrl}learn/path/launch.php");
      result = await Connector.getDataByGet(parameter);
      exp = RegExp(r"cid=(?<cid>[\w|-]+,)");
      matches = exp.firstMatch(result);
      String cid = matches.group(1);
      parameter = ConnectorParameter("${_iSchoolPlusUrl}learn/path/pathtree.php");
      parameter.data = {'cid': cid};

      result = await Connector.getDataByGet(parameter);
      tagNode = html.parse(result);
      node = tagNode.getElementById("fetchResourceForm");
      nodes = node.getElementsByTagName("input");

      Map<String, String> downloadPost = {
        'is_player': '',
        'href': '',
        'prev_href': '',
        'prev_node_id': '',
        'prev_node_title': '',
        'is_download': '',
        'begin_time': '',
        'course_id': '',
        'read_key': ''
      };

      for (html.Element node in nodes) {
        //將資料團入上方Map
        String key = node.attributes['name'];
        if (downloadPost.containsKey(key)) {
          downloadPost[key] = node.attributes['value'];
        }
      }
      parameter = ConnectorParameter("${_iSchoolPlusUrl}learn/path/SCORM_loadCA.php"); //取得下載檔案XML
      result = await Connector.getDataByGet(parameter);
      tagNode = html.parse(result);
      itemNodes = tagNode.getElementsByTagName("item");
      resourceNodes = tagNode.getElementsByTagName("resource");
      for (int i = 0; i < itemNodes.length; i++) {
        itemNode = itemNodes[i];
        if (!itemNode.attributes.containsKey("identifierref")) {
          //代表是目錄不是一個檔案
          continue;
        }
        final itemId = itemNode.attributes["identifierref"];
        for (int i = 0; i < resourceNodes.length; i++) {
          resourceNode = resourceNodes[i];
          if (resourceNode.attributes["identifier"] == itemId) {
            break;
          }
        }
        String base = resourceNode.attributes["xml:base"];
        String href = '${(base != null) ? base : ''}@${resourceNode.attributes["href"]}';

        CourseFileJson courseFile = CourseFileJson();
        courseFile.name = itemNodes[i].text.split("\t")[0].replaceAll(RegExp(r"[\s|\n| ]"), "");
        FileType fileType = FileType();
        downloadPost['href'] = href;
        fileType.postData = Map.of(downloadPost); //紀錄  需要使用Map.of不一個改全部都改
        fileType.type = CourseFileType.unknown;
        courseFile.fileType = [fileType];
        courseFileList.add(courseFile);
      }
      value.status = IPlusReturnStatus.success;
      value.result = courseFileList;
      return value;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      value.status = IPlusReturnStatus.fail;
      return value;
    }
  }

  //List[0] RealUrl , List[1] referer
  static Future<List<String>> getRealFileUrl(Map<String, String> postParameter) async {
    ConnectorParameter parameter;
    String url;
    String result;
    try {
      parameter = ConnectorParameter("${_iSchoolPlusUrl}learn/path/SCORM_fetchResource.php");
      parameter.data = postParameter;
      parameter.referer = "https://istudy.ntut.edu.tw/learn/path/pathtree.php?cid=${postParameter['course_id']}";
      Response response;
      response = await Connector.getDataByPostResponse(parameter);
      result = response.toString();
      RegExp exp;
      RegExpMatch matches;
      if (response.statusCode == HttpStatus.ok) {
        exp = RegExp("[\"'](?<url>https?://.+)[\"']");
        //檢測網址 "http://....." or 'https://.....' or "http://..." or 'http://...'
        matches = exp.firstMatch(result);
        bool pass = (matches?.groupCount == null)
            ? false
            : matches.group(1).toLowerCase().contains("http")
                ? true
                : false;
        if (pass) {
          url = matches.group(1);
          //已經是完整連結
          return [url, url];
        } else {
          exp = RegExp("\"(?<url>/.+)\""); //檢測/ 開頭網址
          matches = exp.firstMatch(result);
          bool pass = (matches?.groupCount == null) ? false : true;
          if (pass) {
            String realUrl = _iSchoolPlusUrl + matches.group(1);
            return [realUrl, realUrl]; //一般下載連結
          } else {
            exp = RegExp("\"(?<url>.+)\""); //檢測""內包含字
            matches = exp.firstMatch(result);
            url = "${_iSchoolPlusUrl}learn/path/${matches.group(1)}"; //是PDF預覽畫面
            parameter = ConnectorParameter(url); //去PDF預覽頁面取得真實下載網址
            result = await Connector.getDataByGet(parameter);
            exp = RegExp("DEFAULT_URL.+['|\"](?<url>.+)['|\"]"); //取的PDF真實下載位置
            matches = exp.firstMatch(result);
            String realUrl = "${_iSchoolPlusUrl}learn/path/${matches.group(1)}";
            return [realUrl, url]; //PDF需要有referer不然會無法下載
          }
        }
      } else if (response.isRedirect || result.isEmpty) {
        //發生跳轉 出現檔案下載預覽頁面
        url = response.headers[HttpHeaders.locationHeader][0];
        url = "${_iSchoolPlusUrl}learn/path/$url";
        url = url.replaceAll("download_preview", "download"); //下載預覽頁面換成真實下載網址
        return [url, url];
      }
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      Log.e(result);
      return null;
    }
    return null;
  }

  static String bid;

  static Future<ReturnWithStatus<List<ISchoolPlusAnnouncementJson>>> getCourseAnnouncement(String courseId) async {
    String result;
    var value = ReturnWithStatus<List<ISchoolPlusAnnouncementJson>>();
    try {
      if (!await _selectCourse(courseId)) {
        value.status = IPlusReturnStatus.noPermission;
        return value;
      }
      ConnectorParameter parameter;
      html.Document tagNode;
      List<html.Element> nodes;
      html.Element node;
      Map<String, String> data = {
        "cid": "",
        "bid": "",
        "nid": "",
      };
      List<ISchoolPlusAnnouncementJson> announcementList = [];

      parameter = ConnectorParameter("https://istudy.ntut.edu.tw/forum/m_node_list.php");
      parameter.data = data;
      result = await Connector.getDataByPost(parameter);
      tagNode = html.parse(result);
      bid = tagNode.getElementById("bid").attributes["value"];

      node = tagNode.getElementById("formSearch");
      nodes = node.getElementsByTagName("input");
      String selectPage = tagNode.getElementById("selectPage").attributes['value'];
      String inputPerPage = tagNode.getElementById("inputPerPage").attributes['value'];
      data = {
        "token": "",
        "bid": "",
        "curtab": "",
        "action": "getNews",
        "tpc": "1",
        "selectPage": selectPage,
        "inputPerPage": inputPerPage
      };
      for (html.Element node in nodes) {
        String name = node.attributes['name'];
        if (data.containsKey(name)) {
          data[name] = node.attributes['value'];
        }
      }
      parameter = ConnectorParameter("https://istudy.ntut.edu.tw/mooc/controllers/forum_ajax.php");
      parameter.data = data;
      result = await Connector.getDataByPost(parameter);
      //ISchoolPlusAnnouncementInfoJson iPlusJson = ISchoolPlusAnnouncementInfoJson.fromJson( json.decode(result) );
      Map<String, dynamic> jsonData = {};
      Map j = json.decode(result);
      if (j["code"] == 0) {
        jsonData = j['data'];
        int totalRows = int.parse(json.decode(result)['total_rows']);
        if (totalRows > 0) {
          for (String keyName in json.decode(result)['data'].keys.toList()) {
            ISchoolPlusAnnouncementJson courseInfo = ISchoolPlusAnnouncementJson.fromJson(jsonData[keyName]);
            courseInfo.subject = HtmlUtils.clean(courseInfo.subject); //處理HTM特殊字
            courseInfo.token = data['token'];
            courseInfo.bid = keyName.split("|").first;
            courseInfo.nid = keyName.split("|").last;
            announcementList.add(courseInfo);
          }
        }
      }
      value.status = IPlusReturnStatus.success;
      value.result = announcementList;
      return value;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      value.status = IPlusReturnStatus.fail;
      return value;
    }
  }

  static Future<Map> getCourseAnnouncementDetail(ISchoolPlusAnnouncementJson value) async {
    String result;
    try {
      ConnectorParameter parameter;
      html.Document tagNode;
      List<html.Element> nodes;
      html.Element node;
      Map<String, String> data = {
        'token': value.token,
        'cid': value.cid,
        'bid': value.bid,
        'nid': value.nid,
        'mnode': '',
        'subject': '',
        'content': '',
        'awppathre': '',
        'nowpage': '1'
      };
      parameter = ConnectorParameter("https://istudy.ntut.edu.tw/forum/m_node_chain.php");
      parameter.data = data;
      result = await Connector.getDataByPost(parameter);
      tagNode = html.parse(result);
      node = tagNode.getElementsByClassName("main node-info").first;
      Map detail = {};

      String title = node.attributes["data-title"];
      node = tagNode.getElementsByClassName("author-name").first;
      String sender = node.text;
      node = tagNode.getElementsByClassName("post-time").first;
      String postTime = node.text;
      node = tagNode.getElementsByClassName("bottom-tmp").first;
      node = node.getElementsByClassName("content").first;
      String body = node.innerHtml;
      node = tagNode.getElementsByClassName("bottom-tmp").first;
      nodes = node.getElementsByClassName("file");
      Map<String, String> fileMap = {}; // name , url
      if (nodes.isNotEmpty) {
        node = nodes.first;
        nodes = node.getElementsByTagName("a");
        for (html.Element node in nodes) {
          String href = node.attributes["href"];
          if (href[0] == '/') {
            href = href.substring(1, href.length);
          }
          fileMap[node.text] = _iSchoolPlusUrl + href;
        }
      }
      detail["title"] = title;
      detail["sender"] = sender;
      detail["postTime"] = postTime;
      detail["body"] = body;
      detail["file"] = fileMap;
      return detail;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return null;
    }
  }

  static Future<bool> courseSubscribe(String bid, bool subscribe) async {
    ConnectorParameter parameter;
    html.Document tagNode;
    String title;
    String result;
    try {
      parameter = ConnectorParameter("https://istudy.ntut.edu.tw/forum/subscribe.php");
      parameter.data = {"bid": bid};
      int time = 0;
      do {
        result = await Connector.getDataByPost(parameter);
        tagNode = html.parse(result);
        title = tagNode.getElementsByTagName("title").first.text;
        Log.d(title);
        time++;
      } while (title.contains("取消") == subscribe && time < 2);
      if (time >= 2) {
        return false;
      } else {
        return true;
      }
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return false;
    }
  }

  static Future<List<String>> getSubscribeNotice() async {
    ConnectorParameter parameter;
    html.Document tagNode;
    html.Element node;
    List<html.Element> nodes;
    String result;
    List<String> courseNameList = [];
    try {
      parameter = ConnectorParameter("https://istudy.ntut.edu.tw/learn/my_forum.php");
      result = await Connector.getDataByPost(parameter);
      tagNode = html.parse(result);
      nodes = tagNode.getElementsByTagName("tbody");
      if (nodes.length > 1) {
        node = nodes[1];
      } else {
        return null; //代表無公告
      }
      nodes = node.getElementsByTagName("tr");
      for (int i = 0; i < nodes.length; i++) {
        node = nodes[i];
        String courseName = node.getElementsByTagName("td")[1].text.split("_")[1];
        courseNameList.add(courseName);
      }
      return courseNameList;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return null;
    }
  }

  static Future<bool> getCourseSubscribe(String bid) async {
    ConnectorParameter parameter;
    html.Document tagNode;
    String title;
    String result;
    try {
      parameter = ConnectorParameter("https://istudy.ntut.edu.tw/forum/subscribe.php");
      parameter.data = {"bid": bid};
      await Connector.getDataByPost(parameter);
      result = await Connector.getDataByPost(parameter);
      tagNode = html.parse(result);
      title = tagNode.getElementsByTagName("title").first.text;
      return !title.contains("取消");
    } catch (e) {
      return false;
    }
  }

  static Future<String> getBid(String courseId) async {
    /*
    ConnectorParameter parameter;
    html.Document tagNode;
    String result;
    try {
      await _selectCourse(courseId);
      parameter = ConnectorParameter(
          "https://istudy.ntut.edu.tw/forum/m_node_list.php");
      result = await RequestsConnector.getDataByPost(parameter);
      tagNode = html.parse(result);
      return tagNode
          .getElementById("bid")
          .attributes["value"];
    } catch (e) {
      throw e;
    }
     */
    return bid;
  }

  static Future<bool> _selectCourse(String courseId) async {
    ConnectorParameter parameter;
    html.Document tagNode;
    html.Element node;
    List<html.Element> nodes;
    String result;
    try {
      parameter = ConnectorParameter(_getCourseName);
      result = await Connector.getDataByGet(parameter);
      tagNode = html.parse(result);
      node = tagNode.getElementById("selcourse");
      nodes = node.getElementsByTagName("option");
      String courseValue;
      for (int i = 1; i < nodes.length; i++) {
        node = nodes[i];
        String name = node.text.split("_").last;
        if (name == courseId) {
          courseValue = node.attributes["value"];
          break;
        }
      }
      if (courseValue == null) {
        return false;
      }
      String xml = "<manifest><ticket/><course_id>$courseValue</course_id><env/></manifest>";
      parameter = ConnectorParameter("https://istudy.ntut.edu.tw/learn/goto_course.php");
      parameter.data = xml;
      await Connector.getDataByPost(
          parameter); //因為RequestsConnector無法傳送XML但是 DioConnector無法解析 Content-Type: text/html;;charset=UTF-8
      return true;
    } catch (e, stack) {
      Log.eWithStack(e, stack);
      return false;
    }
  }
}
