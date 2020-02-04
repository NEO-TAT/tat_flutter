

import 'package:flutter/cupertino.dart';
import 'package:flutter_app/src/store/json/CourseMainJson.dart';
import 'package:flutter_app/src/store/json/CoursePartJson.dart';

class CourseFileScreen extends StatefulWidget {
  final CourseInfoJson courseInfo;
  CourseFileScreen( this.courseInfo );

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