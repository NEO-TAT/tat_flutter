// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_app/src/store/local_storage.dart';
import 'package:flutter_app/ui/other/error_dialog.dart';
import 'package:get/get.dart';
import 'package:tat_core/core/zuvio/domain/course.dart';
import 'package:tat_core/core/zuvio/usecase/get_student_course_list_use_case.dart';
import 'package:flutter_app/src/r.dart';

class ZCourseController extends GetxController {
  ZCourseController({
    required ZGetStudentCourseListUseCase getCourseListUseCase,
  }) : _getCourseListUseCase = getCourseListUseCase;

  static ZCourseController get to => Get.find();

  final ZGetStudentCourseListUseCase _getCourseListUseCase;
  final courses = <ZCourse>[];

  Future<void> loadCourses() async {
    final userInfo = LocalStorage.instance.getZuvioUserInfo();
    final fetchedCourses = await _getCourseListUseCase(userInfo: userInfo);

    if (fetchedCourses != null) {
      courses
        ..clear()
        ..addAll(fetchedCourses.skipWhile((course) => course.isSpecialCourse));
      update();
    }
  }

  void addScheduledMonitor() {
    ErrorDialog(ErrorDialogParameter(
      desc: R.current.rollCallScheduledSuccessfully,
      title: R.current.autoRollCall,
      offCancelBtn: true,
      dialogType: DialogType.SUCCES,
      btnOkText: R.current.sure,
    )).show();
  }
}
