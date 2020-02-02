import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/generated/i18n.dart';
import 'package:flutter_app/src/connector/CourseConnector.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/ui/other/MyProgressDialog.dart';
import 'package:flutter_app/src/store/json/CourseDetailJson.dart';
import '../../../ui/other/ErrorDialog.dart';
import 'TaskModel.dart';

class CourseByStudentIdTask extends TaskModel{
  static final String taskName = "CourseByStudentIdTask";
  String id;
  SemesterJson semester;
  CourseByStudentIdTask(BuildContext context,this.id,this.semester) : super(context, taskName);

  @override
  Future<TaskStatus> taskStart() async{
    MyProgressDialog.showProgressDialog(context, S.current.getCourseSemester );
    CourseTableJson courseTable = await CourseConnector.getCourseByStudentId(id , semester );
    MyProgressDialog.hideProgressDialog();
    Model.instance.addCourseTable( courseTable );
    await Model.instance.save( Model.courseTableJsonKey );

    if( courseTable != null  ) {
      return TaskStatus.TaskSuccess;
    }else {
      _handleError();
      return TaskStatus.TaskFail;
    }
  }

  void _handleError() {

    ErrorDialogParameter parameter = ErrorDialogParameter(
      context: context,
      desc: S.current.getCourseSemesterError,
    );
    ErrorDialog(parameter).show();
  }


}