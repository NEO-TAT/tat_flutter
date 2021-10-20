import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:tat/debug/log/log.dart';
import 'package:tat/src/R.dart';
import 'package:tat/src/file/file_download.dart';
import 'package:tat/src/model/course_table/course_table_json.dart';
import 'package:tat/src/util/html_utils.dart';
import 'package:tat/ui/other/listview_animator.dart';
import 'package:url_launcher/url_launcher.dart';

class IPlusAnnouncementDetailPage extends StatefulWidget {
  final Map data;
  final CourseInfoJson courseInfo;

  const IPlusAnnouncementDetailPage(this.courseInfo, this.data);

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

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo routeInfo) {
    Get.back();
    return true;
  }

  bool addLink = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => Get.back(),
        ),
        title: Text(widget.courseInfo.main!.course!.name),
        actions: [
          PopupMenuButton<int>(
            onSelected: (result) {
              if (!addLink) {
                setState(() {
                  addLink = true;
                  widget.data["body"] = HtmlUtils.addLink(widget.data["body"]);
                });
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 0,
                child: Text(R.current.identifyLinks),
              ),
            ],
          )
        ],
      ),
      body: SingleChildScrollView(
        child: _showAnnouncementDetail(),
      ),
    );
  }

  Widget _showAnnouncementDetail() {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.data["title"],
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
                // show lines
                Row(
                  children: [
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
    final List<String> fileNameList = widget.data['file'].keys.toList();
    final Map fileUrlMap = widget.data["file"];
    if (fileNameList.length == 0) {
      return Container(
        color: Colors.black12,
        height: 1,
      );
    } else {
      return Container(
        child: Column(
          children: [
            Container(
              color: Colors.black12,
              height: 1,
            ),
            Row(
              children: [
                Text(
                  R.current.file,
                  textAlign: TextAlign.start,
                ),
              ],
            ),
            ListView.separated(
              shrinkWrap: true,
              itemCount: fileNameList.length,
              itemBuilder: (context, index) {
                final fileWidget = Container(
                  child: Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: Row(
                      children: [
                        Text(
                          fileNameList[index],
                          style: TextStyle(fontSize: 15, color: Colors.blue),
                        )
                      ],
                    ),
                  ),
                );
                return InkWell(
                  child: WidgetAnimator(fileWidget),
                  onTap: () {
                    _downloadFile(
                      fileUrlMap[fileNameList[index]],
                      fileNameList[index],
                    );
                  },
                );
              },
              separatorBuilder: (context, index) {
                // show cell lines
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
        return true;
      },
    );
  }

  void _downloadFile(String url, String name) async {
    final courseName = widget.courseInfo.main!.course!.name;
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
