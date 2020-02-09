import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/generated/i18n.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/store/json/CourseAnnouncementJson.dart';
import 'package:flutter_app/src/store/json/CourseTableJson.dart';
import 'package:flutter_app/src/store/json/CourseMainExtraJson.dart';
import 'package:flutter_app/src/taskcontrol/TaskHandler.dart';
import 'package:flutter_app/src/taskcontrol/task/ISchoolCourseAnnouncementTask.dart';
import 'package:flutter_app/ui/other/MyToast.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:html/dom.dart' as dom;
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

class CourseAnnouncementScreen extends StatefulWidget {
  final CourseInfoJson courseInfo;
  CourseAnnouncementScreen( this.courseInfo );

  @override
  _CourseAnnouncementScreen createState( ) => _CourseAnnouncementScreen();
}

class _CourseAnnouncementScreen extends State<CourseAnnouncementScreen> with AutomaticKeepAliveClientMixin {
  List<CourseAnnouncementJson> courseAnnouncementList = List();
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _addTask();
    });
  }

  void _addTask() async {
    String courseId = widget.courseInfo.main.course.id;
    TaskHandler.instance.addTask( ISchoolCourseAnnouncementTask(context , courseId));
    await TaskHandler.instance.startTaskQueue(context);
    courseAnnouncementList = Model.instance.tempData[ ISchoolCourseAnnouncementTask.courseAnnouncementListTempKey];
    setState(() {

    });
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);  //如果使用AutomaticKeepAliveClientMixin需要呼叫
    return  Scaffold(
      body: (courseAnnouncementList.length > 0)
          ? _buildCourseAnnouncementList()
          : Center(
        child: Text(S.current.noAnyAnnouncement),
      ),
    );
  }



  Widget _buildCourseAnnouncementList(){
    return Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.separated(
                itemCount: courseAnnouncementList.length,
                itemBuilder: (context, index) {
                  return _buildHtmlWidgetCourseAnnouncement(courseAnnouncementList[index]);
                },
                separatorBuilder: (context, index) {
                  // 顯示格線
                  return Container(
                    color: Colors.black12,
                    height: 1,
                  );
                },
              ),
            ),
          ],
        )
    );
  }


  Widget _buildHtmlWidgetCourseAnnouncement( CourseAnnouncementJson courseAnnouncement){
    return HtmlWidget(
      courseAnnouncement.detail,
      onTapUrl: (url) {
        onUrlTap(url);
      },
    );
  }

  void onUrlTap(String url){
    Log.d( url );
    if( Uri.parse(url).host.contains("ischool") ){
      MyToast.show(S.current.pleaseMoveToFilePage);
    }else{
      _launchURL( url );
    }
  }

  Widget _buildHtmlCourseAnnouncement( CourseAnnouncementJson courseAnnouncement){
    return Html(
      data: courseAnnouncement.detail,
      //useRichText: false,
      padding: EdgeInsets.all(8.0),
      backgroundColor: Colors.white,
      onLinkTap: (url) {
        onUrlTap(url);
      },
    );
  }



  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  bool get wantKeepAlive => true;
}