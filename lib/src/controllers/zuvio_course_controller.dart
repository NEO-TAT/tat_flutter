// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/src/controllers/zuvio_auth_controller.dart';
import 'package:flutter_app/src/store/local_storage.dart';
import 'package:get/get.dart';
import 'package:tat_core/tat_core.dart';

class ZCourseController extends GetxController {
  ZCourseController({
    required ZGetStudentCourseListUseCase getCourseListUseCase,
    required FirebaseFirestore firestore,
  }) : _getCourseListUseCase = getCourseListUseCase;
  // _firestore = firestore;

  static ZCourseController get to => Get.find();

  final ZGetStudentCourseListUseCase _getCourseListUseCase;
  // final FirebaseFirestore _firestore;

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

  Future<void> addScheduledMonitor({
    required ZCourse course,
    required Week weekday,
    required TimeOfDayPeriod period,
  }) async {
    final userInfo = ZAuthController.to.currentZUserInfo();

    if (userInfo == null) {
      // TODO: directly logout (zuvio) while `userInfo` is null.
      return Future.error('Can not get user info from auth controller!');
    }
    //
    // // TODO: pass parameters into the use cases which imported from TAT-Core, instead of the hard-coded Map structure.
    // final Map<String, dynamic> newSchedule = {
    //   'enabled': true,
    //   'z-course': course.toJson(),
    //   'z-user': userInfo.toJson(),
    //   'schedule': {
    //     'weekday': weekday.index,
    //     'start-time': {
    //       'hour': period.startTime.hour,
    //       'minute': period.startTime.minute,
    //     },
    //     'end-time': {
    //       'hour': period.endTime.hour,
    //       'minute': period.endTime.minute,
    //     },
    //   }
    // };
    //
    // final zRollCallScheduleDocRef = _firestore.collection('z-roll-call-schedule');
    //
    // // TODO: use uuid.
    // final newScheduleId = DateTime.now().millisecondsSinceEpoch.toString();
    //
    // return zRollCallScheduleDocRef.doc(newScheduleId).set(newSchedule).then((_) {
    //   ZRollCallMonitorController.to.getScheduledMonitors();
    //
    //   // TODO: move dialog showing to UI layer.
    //   ErrorDialog(ErrorDialogParameter(
    //     desc: R.current.rollCallScheduledSuccessfully,
    //     title: R.current.autoRollCall,
    //     offCancelBtn: true,
    //     dialogType: DialogType.SUCCESS,
    //     btnOkText: R.current.sure,
    //   )).show();
    // });
  }
}
