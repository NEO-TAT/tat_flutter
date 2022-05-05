import 'package:flutter/material.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/model/coursetable/CourseTableJson.dart';
import 'package:flutter_app/src/model/ischoolplus/ISchoolPlusAnnouncementJson.dart';
import 'package:flutter_app/src/store/local_storage.dart';
import 'package:flutter_app/src/task/TaskFlow.dart';
import 'package:flutter_app/src/task/iPlus/IPlusGetCourseSubscribeTask.dart';
import 'package:flutter_app/src/task/iPlus/IPlusSetCourseSubscribeTask.dart';
import 'package:flutter_app/src/task/iplus/IPlusCourseAnnouncementDetailTask.dart';
import 'package:flutter_app/src/task/iplus/IPlusCourseAnnouncementTask.dart';
import 'package:flutter_app/ui/other/RouteUtils.dart';

class IPlusAnnouncementPage extends StatefulWidget {
  final CourseInfoJson courseInfo;
  final String studentId;

  IPlusAnnouncementPage(this.studentId, this.courseInfo);

  @override
  _IPlusAnnouncementPage createState() => _IPlusAnnouncementPage();
}

class _IPlusAnnouncementPage extends State<IPlusAnnouncementPage> with AutomaticKeepAliveClientMixin {
  List<ISchoolPlusAnnouncementJson> items;
  String courseBid;
  bool needRefresh = false;
  bool isSupport;
  bool openNotifications = false;

  @override
  void initState() {
    super.initState();
    isSupport = LocalStorage.instance.getAccount() == widget.studentId;
    items = [];
    if (isSupport) {
      _addTask();
    }
  }

  void _addTask() async {
    //第一次
    String courseId = widget.courseInfo.main.course.id;
    TaskFlow taskFlow = TaskFlow();
    var task = IPlusCourseAnnouncementTask(courseId);
    var getTask = IPlusGetCourseSubscribeTask(courseId);
    taskFlow.addTask(task);
    taskFlow.addTask(getTask);
    if (await taskFlow.start()) {
      items = task.result;
      courseBid = getTask.result["courseBid"];
      openNotifications = getTask.result["openNotifications"];
    }
    items = items ?? [];

    if (mounted) {
      setState(() {});
    }
  }

  void _getAnnouncementDetail(ISchoolPlusAnnouncementJson value) async {
    TaskFlow taskFlow = TaskFlow();
    var task = IPlusCourseAnnouncementDetailTask(value);
    taskFlow.addTask(task);
    Map detail;
    if (await taskFlow.start()) {
      detail = task.result;
    }
    RouteUtils.toIPlusAnnouncementDetailPage(widget.courseInfo, detail);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        body: (items.length > 0)
            ? _buildMailList()
            : isSupport
                ? Center(
                    child: Text(R.current.noAnyAnnouncement),
                  )
                : Center(
                    child: Text(R.current.notSupport),
                  ),
        floatingActionButton: FloatingActionButton(
          // FloatingActionButton: 浮動按鈕
          onPressed: () async {
            TaskFlow taskFlow = TaskFlow();
            taskFlow.addTask(IPlusSetCourseSubscribeTask(courseBid, !openNotifications));
            if (await taskFlow.start()) {
              setState(() {
                openNotifications = !openNotifications;
              });
            }
          },
          tooltip: R.current.subscribe,
          // 按住按鈕時出現的提示字
          child: (openNotifications) ? Icon(Icons.notifications_active) : Icon(Icons.notifications_off),
        ));
  }

  Widget _buildMailList() {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(0.0),
      scrollDirection: Axis.vertical,
      primary: true,
      itemCount: items.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            ISchoolPlusAnnouncementJson value = items[index];
            _getAnnouncementDetail(value);
          },
          child: _listItem(
            items[index],
          ),
        );
      },
    );
  }

  Widget _listItem(ISchoolPlusAnnouncementJson data) {
    FontWeight fontWeight = (data.readflag != 1) ? FontWeight.bold : FontWeight.normal;
    return Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 14.0, right: 14.0, top: 5.0, bottom: 5.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.account_circle,
                  size: 55.0,
                  color: Colors.red,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                data.subject,
                                overflow: TextOverflow.visible,
                                style: TextStyle(fontWeight: fontWeight, fontSize: 17.0),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              data.realname,
                              style: TextStyle(fontWeight: fontWeight, fontSize: 15.5),
                            ),
                            Text(
                              data.postdate,
                              style: TextStyle(fontWeight: fontWeight, fontSize: 13.5),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
