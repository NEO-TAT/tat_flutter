import 'dart:convert';
import 'dart:io';

import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:tat/debug/log/Log.dart';
import 'package:tat/src/connector/core/Connector.dart';
import 'package:tat/src/model/ischool_plus/course_file_json.dart';
import 'package:tat/src/model/ischool_plus/ischool_plus_announcement_json.dart';
import 'package:tat/src/util/html_utils.dart';

import 'core/connector_parameter.dart';
import 'ntut_connector.dart';

enum ISchoolPlusConnectorStatus { LoginSuccess, LoginFail, UnknownError }
enum IPlusReturnStatus { Success, Fail, NoPermission }

class ReturnWithStatus<T> {
  ReturnWithStatus({this.status, this.result});

  IPlusReturnStatus? status;
  T? result;
}

class ISchoolPlusConnector {
  static const host = "https://istudy.ntut.edu.tw/";
  static const _getCourseName = host + "learn/mooc_sysbar.php";
  static final _ssoLoginUrl = "${NTUTConnector.host}ssoIndex.do";

  static Future<ISchoolPlusConnectorStatus?> login(String account) async {
    try {
      ConnectorParameter parameter;
      final data = {
        "apUrl": "https://istudy.ntut.edu.tw/login.php",
        "apOu": "ischool_plus_",
        "sso": "true",
        "datetime1": DateTime.now().millisecondsSinceEpoch.toString()
      };
      parameter = ConnectorParameter(_ssoLoginUrl)..data = data;

      final result = await Connector.getDataByGet(parameter);
      final tagNode = parse(result);
      final nodes = tagNode.getElementsByTagName("input");

      data.clear();

      for (final node in nodes) {
        final name = node.attributes['name']!;
        final value = node.attributes['value']!;
        data[name] = value;
      }

      final jumpUrl =
          tagNode.getElementsByTagName("form")[0].attributes["action"]!;
      parameter = ConnectorParameter(jumpUrl)..data = data;

      await Connector.getDataByPostResponse(parameter);

      return ISchoolPlusConnectorStatus.LoginSuccess;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return ISchoolPlusConnectorStatus.LoginFail;
    }
  }

  static Future<ReturnWithStatus<List<CourseFileJson>>> getCourseFile(
    String courseId,
  ) async {
    ConnectorParameter parameter;
    String result;
    Document tagNode;
    Element resourceNode = Element.tag('a');

    final value = ReturnWithStatus<List<CourseFileJson>>();

    try {
      final List<CourseFileJson> courseFileList = [];

      if (!await _selectCourse(courseId)) {
        value.status = IPlusReturnStatus.NoPermission;
        return value;
      }

      parameter = ConnectorParameter(host + "learn/path/launch.php");
      result = await Connector.getDataByGet(parameter);
      final matches = RegExp(r"cid=\(?<cid>[\w|-]+,\)").firstMatch(result)!;

      final cid = matches.group(1)!;
      final data = {'cid': cid};

      parameter = ConnectorParameter(host + "learn/path/pathtree.php")
        ..data = data;

      result = await Connector.getDataByGet(parameter);
      tagNode = parse(result);

      final nodes = tagNode
          .getElementById("fetchResourceForm")!
          .getElementsByTagName("input");

      final downloadPost = {
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

      for (final node in nodes) {
        final key = node.attributes['name']!;
        if (downloadPost.containsKey(key)) {
          downloadPost[key] = node.attributes['value']!;
        }
      }

      // get the xml file for the file to be downloaded.
      parameter = ConnectorParameter(host + "learn/path/SCORM_loadCA.php");
      result = await Connector.getDataByGet(parameter);
      tagNode = parse(result);
      final itemNodes = tagNode.getElementsByTagName("item");
      final resourceNodes = tagNode.getElementsByTagName("resource");

      for (int i = 0; i < itemNodes.length; i++) {
        final itemNode = itemNodes[i];

        if (!itemNode.attributes.containsKey("identifierref")) {
          continue;
        }

        final iref = itemNode.attributes["identifierref"];

        for (int i = 0; i < resourceNodes.length; i++) {
          resourceNode = resourceNodes[i];
          if (resourceNode.attributes["identifier"] == iref) {
            break;
          }
        }

        final base = resourceNode.attributes["xml:base"];
        final href =
            '${((base != null) ? base : '')}@${resourceNode.attributes["href"]}';

        final courseFile = CourseFileJson();
        courseFile.name = itemNodes[i]
            .text
            .split("\t")[0]
            .replaceAll(RegExp(r"[\s|\n| ]"), "");

        final fileType = FileType();
        downloadPost['href'] = href;
        fileType.postData = Map.of(downloadPost);
        fileType.type = CourseFileType.Unknown;
        courseFile.fileType = [fileType];
        courseFileList.add(courseFile);
      }

      value.status = IPlusReturnStatus.Success;
      value.result = courseFileList;

      return value;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      value.status = IPlusReturnStatus.Fail;
      return value;
    }
  }

  static Future<List<String>?> getRealFileUrl(
    Map<String, String> postParameter,
  ) async {
    ConnectorParameter parameter;
    String url;
    String result = '';

    try {
      parameter = ConnectorParameter(
        host + "learn/path/SCORM_fetchResource.php",
      )
        ..data = postParameter
        ..charsetName = 'big5'
        ..referer =
            "https://istudy.ntut.edu.tw/learn/path/pathtree.php?cid=${postParameter['course_id']}";

      final response = await Connector.getDataByPostResponse(parameter);
      result = response.toString();

      RegExpMatch? matches;

      if (response.statusCode == HttpStatus.ok) {
        matches =
            RegExp("[\"\'](?<url>https?:\/\/.+)[\"\']").firstMatch(result);
        final pass = (matches?.groupCount == null)
            ? false
            : matches!.group(1)!.toLowerCase().contains("http")
                ? true
                : false;

        if (pass) {
          url = matches!.group(1)!;
          return [url, url];
        } else {
          matches = RegExp("\"(?<url>\/.+)\"").firstMatch(result);
          final pass = (matches?.groupCount == null) ? false : true;

          if (pass) {
            final realUrl = host + matches!.group(1)!;
            return [realUrl, realUrl];
          } else {
            matches = RegExp("\"(?<url>.+)\"").firstMatch(result);
            url = host +
                "learn/path/" +
                matches!.group(1)!; // is a PDF preview page
            parameter = ConnectorParameter(
                url); // get the real download link from the PDF preview page
            result = await Connector.getDataByGet(parameter);
            matches = RegExp("DEFAULT_URL.+['|\"](?<url>.+)['|\"]")
                .firstMatch(result); // get PDF real download location
            final realUrl = host + "learn/path/" + matches!.group(1)!;

            return [
              realUrl,
              url
            ]; // it is necessary to add `referer` when downloading a PDF file
          }
        }
      } else if (response.isRedirect! || result.isEmpty) {
        url = response.headers[HttpHeaders.locationHeader]![0];
        url = host + "learn/path/" + url;
        url = url.replaceAll("download_preview",
            "download"); // replace download preview page to real download page url
        return [url, url];
      }
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      Log.e(result);
      return null;
    }
    return null;
  }

  static String bid = '';

  static getBid() => bid;

  static Future<ReturnWithStatus<List<ISchoolPlusAnnouncementJson>>>
      getCourseAnnouncement(String courseId) async {
    String result;
    final value = ReturnWithStatus<List<ISchoolPlusAnnouncementJson>>();

    try {
      if (!await _selectCourse(courseId)) {
        value.status = IPlusReturnStatus.NoPermission;
        return value;
      }

      ConnectorParameter parameter;

      Map<String, String> data = {
        "cid": "",
        "bid": "",
        "nid": "",
      };

      final List<ISchoolPlusAnnouncementJson> announcementList = [];

      parameter = ConnectorParameter(
        "https://istudy.ntut.edu.tw/forum/m_node_list.php",
      )..data = data;

      result = await Connector.getDataByPost(parameter);
      final tagNode = parse(result);
      bid = tagNode.getElementById("bid")!.attributes["value"]!;
      final node = tagNode.getElementById("formSearch");
      final nodes = node!.getElementsByTagName("input");
      final selectPage =
          tagNode.getElementById("selectPage")!.attributes['value'];
      final inputPerPage =
          tagNode.getElementById("inputPerPage")!.attributes['value'];

      data = {
        "token": "",
        "bid": "",
        "curtab": "",
        "action": "getNews",
        "tpc": "1",
        "selectPage": selectPage.toString(),
        "inputPerPage": inputPerPage.toString(),
      };

      for (final node in nodes) {
        final name = node.attributes['name']!;
        if (data.containsKey(name)) {
          data[name] = node.attributes['value']!;
        }
      }

      parameter = ConnectorParameter(
        "https://istudy.ntut.edu.tw/mooc/controllers/forum_ajax.php",
      )..data = data;

      result = await Connector.getDataByPost(parameter);
      Map<String, dynamic> jsonData = Map();
      final j = json.decode(result);

      if (j["code"] == 0) {
        jsonData = j['data'];
        final totalRows = int.parse(json.decode(result)['total_rows']);

        if (totalRows > 0) {
          for (final keyName in json.decode(result)['data'].keys.toList()) {
            final courseInfo =
                ISchoolPlusAnnouncementJson.fromJson(jsonData[keyName]);
            courseInfo.subject = HtmlUtils.clean(courseInfo.subject);
            courseInfo.token = data['token']!;
            courseInfo.bid = keyName.split("|").first;
            courseInfo.nid = keyName.split("|").last;
            announcementList.add(courseInfo);
          }
        }
      }

      value.status = IPlusReturnStatus.Success;
      value.result = announcementList;

      return value;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      value.status = IPlusReturnStatus.Fail;
      return value;
    }
  }

  static Future<Map?> getCourseAnnouncementDetail(
      ISchoolPlusAnnouncementJson value) async {
    try {
      Element node;
      final data = {
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

      final parameter = ConnectorParameter(
        "https://istudy.ntut.edu.tw/forum/m_node_chain.php",
      )..data = data;

      final result = await Connector.getDataByPost(parameter);
      final tagNode = parse(result);
      node = tagNode.getElementsByClassName("main node-info").first;
      final detail = Map();

      String title = node.attributes["data-title"]!;
      node = tagNode.getElementsByClassName("author-name").first;

      String sender = node.text;
      node = tagNode.getElementsByClassName("post-time").first;

      String postTime = node.text;
      node = tagNode.getElementsByClassName("bottom-tmp").first;
      node = node.getElementsByClassName("content").first;

      String body = node.innerHtml;
      node = tagNode.getElementsByClassName("bottom-tmp").first;

      List<Element> nodes = node.getElementsByClassName("file");
      final fileMap = Map();

      if (nodes.length >= 1) {
        node = nodes.first;
        nodes = node.getElementsByTagName("a");

        for (final node in nodes) {
          String? href = node.attributes["href"];

          if (href![0] == '/') {
            href = href.substring(1, href.length);
          }

          fileMap[node.text] = host + href;
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
    try {
      final data = {"bid": bid};
      final parameter = ConnectorParameter(
        "https://istudy.ntut.edu.tw/forum/subscribe.php",
      )..data = data;

      int time = 0;
      String title = '';

      do {
        final result = await Connector.getDataByPost(parameter);
        title = parse(result).getElementsByTagName("title").first.text;
        Log.d(title);
        time++;
      } while (title.contains("取消") == subscribe && time < 2);

      return time < 2;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return false;
    }
  }

  static Future<List<String>?> getSubscribeNotice() async {
    Element node;
    List<Element> nodes;
    final List<String> courseNameList = [];

    try {
      final parameter =
          ConnectorParameter("https://istudy.ntut.edu.tw/learn/my_forum.php");
      final result = await Connector.getDataByPost(parameter);

      nodes = parse(result).getElementsByTagName("tbody");
      if (nodes.length > 1) {
        node = nodes[1];
      } else {
        return [];
      }

      nodes = node.getElementsByTagName("tr");
      for (int i = 0; i < nodes.length; i++) {
        node = nodes[i];
        final courseName =
            node.getElementsByTagName("td")[1].text.split("_")[1];
        courseNameList.add(courseName);
      }

      return courseNameList;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return null;
    }
  }

  static Future<bool> getCourseSubscribe(String bid) async {
    try {
      final data = {"bid": bid};
      final parameter = ConnectorParameter(
        "https://istudy.ntut.edu.tw/forum/subscribe.php",
      )..data = data;

      await Connector.getDataByPost(parameter);
      final result = await Connector.getDataByPost(parameter);
      final title = parse(result).getElementsByTagName("title").first.text;

      return !title.contains("取消");
    } catch (e) {
      return false;
    }
  }

  static Future<bool> _selectCourse(String courseId) async {
    ConnectorParameter parameter;

    try {
      parameter = ConnectorParameter(_getCourseName);
      final result = await Connector.getDataByGet(parameter);
      final nodes = parse(result)
          .getElementById("selcourse")!
          .getElementsByTagName("option");

      String? courseValue;

      for (int i = 1; i < nodes.length; i++) {
        final node = nodes[i];
        final name = node.text.split("_").last;
        if (name == courseId) {
          courseValue = node.attributes["value"]!;
          break;
        }
      }

      if (courseValue == null) {
        return false;
      }

      final xml =
          "<manifest><ticket/><course_id>$courseValue</course_id><env/></manifest>";
      parameter = ConnectorParameter(
        "https://istudy.ntut.edu.tw/learn/goto_course.php",
      )..data = xml;

      await Connector.getDataByPost(parameter);

      return true;
    } catch (e, stack) {
      Log.eWithStack(e, stack);
      return false;
    }
  }
}
