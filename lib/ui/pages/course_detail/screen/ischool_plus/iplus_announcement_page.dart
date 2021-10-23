import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tat/src/R.dart';
import 'package:tat/src/model/course_table/course_table_json.dart';
import 'package:tat/src/model/ischool_plus/ischool_plus_announcement_json.dart';
import 'package:tat/src/store/model.dart';
import 'package:tat/src/task/iplus/iplus_course_announcement_detail_task.dart';
import 'package:tat/src/task/iplus/iplus_course_announcement_task.dart';
import 'package:tat/src/task/iplus/iplus_get_course_subscribe_task.dart';
import 'package:tat/src/task/iplus/iplus_set_course_subscribe_task.dart';
import 'package:tat/src/task/task_flow.dart';
import 'package:tat/src/util/route_utils.dart';

class IPlusAnnouncementPage extends StatefulWidget {
  final CourseInfoJson courseInfo;
  final String studentId;

  const IPlusAnnouncementPage(this.studentId, this.courseInfo);

  @override
  _IPlusAnnouncementPage createState() => _IPlusAnnouncementPage();
}

class _IPlusAnnouncementPage extends State<IPlusAnnouncementPage>
    with AutomaticKeepAliveClientMixin {
  late final List<ISchoolPlusAnnouncementJson>? items;
  late final String courseBid;
  final needRefresh = false;
  late final bool isSupport;
  bool openNotifications = false;

  @override
  void initState() {
    super.initState();
    isSupport = Model.instance.getAccount() == widget.studentId;
    items = [];
    if (isSupport) {
      _addTask();
    }
  }

  void _addTask() async {
    final courseId = widget.courseInfo.main!.course!.id;
    final taskFlow = TaskFlow();
    final task = IPlusCourseAnnouncementTask(courseId);
    final getTask = IPlusGetCourseSubscribeTask();
    taskFlow.addTask(task);
    taskFlow.addTask(getTask);

    if (await taskFlow.start()) {
      items = task.result;
      courseBid = getTask.result["courseBid"];
      openNotifications = getTask.result["openNotifications"];
    }

    items ??= [];
    setState(() {});
  }

  void _getAnnouncementDetail(ISchoolPlusAnnouncementJson value) async {
    final taskFlow = TaskFlow();
    final task = IPlusCourseAnnouncementDetailTask(value);
    taskFlow.addTask(task);
    late Map detail;

    if (await taskFlow.start()) {
      detail = task.result;
    }

    RouteUtils.toIPlusAnnouncementDetailPage(widget.courseInfo, detail);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: (items!.length > 0)
          ? _buildMailList()
          : isSupport
              ? Center(
                  child: Text(R.current.noAnyAnnouncement),
                )
              : Center(
                  child: Text(R.current.notSupport),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final taskFlow = TaskFlow();
          taskFlow.addTask(
            IPlusSetCourseSubscribeTask(
              courseBid,
              !openNotifications,
            ),
          );
          if (await taskFlow.start()) {
            setState(() {
              openNotifications = !openNotifications;
            });
          }
        },
        tooltip: R.current.subscribe,
        child: (openNotifications)
            ? Icon(Icons.notifications_active)
            : Icon(Icons.notifications_off),
      ),
    );
  }

  Widget _buildMailList() {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(0.0),
      scrollDirection: Axis.vertical,
      primary: true,
      itemCount: items!.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            ISchoolPlusAnnouncementJson value = items![index];
            _getAnnouncementDetail(value);
          },
          child: _listItem(
            items![index],
          ),
        );
      },
    );
  }

  Widget _listItem(ISchoolPlusAnnouncementJson data) {
    final fontWeight =
        (data.readflag != 1) ? FontWeight.bold : FontWeight.normal;
    return Container(
      child: Column(
        children: [
          Padding(
            padding:
                EdgeInsets.only(left: 14.0, right: 14.0, top: 5.0, bottom: 5.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_circle,
                  size: 55.0,
                  color: Colors.red,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                data.subject,
                                overflow: TextOverflow.visible,
                                style: TextStyle(
                                  fontWeight: fontWeight,
                                  fontSize: 17.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              data.realname,
                              style: TextStyle(
                                fontWeight: fontWeight,
                                fontSize: 15.5,
                              ),
                            ),
                            Text(
                              data.postdate,
                              style: TextStyle(
                                fontWeight: fontWeight,
                                fontSize: 13.5,
                              ),
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
