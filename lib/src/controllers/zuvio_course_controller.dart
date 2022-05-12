// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.16

import 'package:flutter_app/src/store/local_storage.dart';
import 'package:get/get.dart';
import 'package:tat_core/core/zuvio/domain/course.dart';
import 'package:tat_core/core/zuvio/usecase/get_student_course_list_use_case.dart';

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
}
