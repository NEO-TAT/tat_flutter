import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/file/FileDownload.dart';
import 'package:flutter_app/src/file/FileStore.dart';
import 'package:flutter_app/src/store/json/CourseTableJson.dart';
import 'package:flutter_app/ui/other/ListViewAnimator.dart';
import 'package:html/dom.dart' as dom;
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:url_launcher/url_launcher.dart';

class IPlusAnnouncementDetailPage extends StatefulWidget {
  final Map data;
  final CourseInfoJson courseInfo;

  IPlusAnnouncementDetailPage(this.courseInfo, this.data);

  @override
  _IPlusAnnouncementDetailPage createState() => _IPlusAnnouncementDetailPage();
}

class _IPlusAnnouncementDetailPage extends State<IPlusAnnouncementDetailPage> {
  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent) {
    Navigator.of(context).pop();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.courseInfo.main.course.name),
      ),
      body: SingleChildScrollView(
        child: _showAnnouncementDetail(),
      ),
    );
  }

  Widget _showAnnouncementDetail() {
    return Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      widget.data["title"],
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
                // 顯示格線
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(widget.data["sender"]),
                    ),
                    Expanded(
                      child: Text(
                        widget.data["postTime"],
                        textAlign: TextAlign.end,
                      ),
                    )
                  ],
                ),
                Container(
                  color: Colors.black12,
                  height: 1,
                ),
                _showHtmlWidget(),
                _showFileList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _showFileList() {
    List<String> keyMap = widget.data['file'].keys.toList();
    Map fileMap = widget.data["file"];
    if (keyMap.length == 0) {
      return Container(
        color: Colors.black12,
        height: 1,
      );
    } else {
      return Container(
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.black12,
              height: 1,
            ),
            Row(
              children: <Widget>[
                Text(
                  R.current.file,
                  textAlign: TextAlign.start,
                ),
              ],
            ),
            ListView.separated(
              shrinkWrap: true,
              itemCount: keyMap.length,
              itemBuilder: (context, index) {
                Widget fileWidget;
                fileWidget = Container(
                  child: Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: Row(
                      children: <Widget>[
                        Text(
                          keyMap[index],
                          style: TextStyle(fontSize: 15, color: Colors.blue),
                        )
                      ],
                    ),
                  ),
                );
                return InkWell(
                  child: WidgetAnimator(fileWidget),
                  onTap: () {
                    _downloadFile(fileMap[keyMap[index]], keyMap[index]);
                  },
                );
              },
              separatorBuilder: (context, index) {
                // 顯示格線
                return Container(
                  color: Colors.black12,
                  height: 1,
                );
              },
            ),
          ],
        ),
      );
    }
  }

  Widget _showHtmlWidget() {
    return HtmlWidget(
      widget.data["body"],
      onTapUrl: (url) {
        onUrlTap(url);
      },
    );
  }

  void _downloadFile(String url, String name) async {
    String courseName = widget.courseInfo.main.course.name;
    await FileDownload.download(context, url, courseName, name);
  }

  void onUrlTap(String url) async {
    Log.d(url);
    if (Uri.parse(url).host.contains("istudy")) {
    } else {
      _launchURL(url);
    }
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
