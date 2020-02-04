

import 'package:flutter/cupertino.dart';
import 'package:flutter_app/src/store/json/CourseDetailJson.dart';
import 'package:flutter_app/src/store/json/CourseInfoJson.dart';

class CourseFileScreen extends StatefulWidget {
  final CourseTableDetailJson courseTableDetail;
  CourseFileScreen( this.courseTableDetail );

  @override
  _CourseFileScreen createState( ) => _CourseFileScreen();
}

class _CourseFileScreen extends State<CourseFileScreen> with AutomaticKeepAliveClientMixin {
  CourseInfoJson courseInfo;

  @override
  void initState() {
    _addTask();
    super.initState();
  }

  void _addTask() async {
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);  //如果使用AutomaticKeepAliveClientMixin需要呼叫
    return Container(
      child: Text("file"),
    );
  }

  @override
  bool get wantKeepAlive => true;
}