import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/src/controllers/zuvio_auth_controller.dart';
import 'package:get/get.dart';
import 'package:tat_core/tat_core.dart';

class ZRollCallMonitorController extends GetxController {
  ZRollCallMonitorController({
    required ZGetRollCallUseCase getRollCallUseCase,
    required ZMakeRollCallUseCase makeRollCallUseCase,
    required FirebaseFirestore firestore,
  })  : _getRollCallUseCase = getRollCallUseCase,
        _makeRollCallUseCase = makeRollCallUseCase;
  // _firestore = firestore;

  static ZRollCallMonitorController get to => Get.find();

  final ZMakeRollCallUseCase _makeRollCallUseCase;
  final ZGetRollCallUseCase _getRollCallUseCase;
  // final FirebaseFirestore _firestore;

  // TODO: Refactor with TAT-Core implementation, store the schedules in a right way.
  final schedules = <Map<String, dynamic>>[];

  Future<void> getScheduledMonitors() async {
    schedules.clear();

    // TODO: Refactor with TAT-Core implementation, call use cases to get the expected data.
    // final zRollCallScheduleDocRef = _firestore.collection('z-roll-call-schedule');
    //
    // final allSchedule = await zRollCallScheduleDocRef.get();
    // schedules.insertAll(0, allSchedule.docs.map((doc) {
    //   final data = doc.data();
    //   data['id'] = doc.id;
    //   return data;
    // }));

    update();
  }

  Future<void> removeMonitor({
    required String monitorId,
  }) async {
    // final zRollCallScheduleDocRef = _firestore.collection('z-roll-call-schedule');
    // await zRollCallScheduleDocRef.doc(monitorId).delete();
    return getScheduledMonitors();
  }

  Future<bool> makeRollCall({
    required ZCourse course,
  }) async {
    final userInfo = ZAuthController.to.currentZUserInfo();
    if (userInfo == null) {
      // TODO: directly logout (zuvio) while `userInfo` is null.
      return false;
    }

    final currentRollCall = await _getRollCallUseCase(course: course, userInfo: userInfo);
    if (currentRollCall == null) {
      // TODO: show the message which indicates the reason why this roll-call is null.
      return false;
    }

    return _makeRollCallUseCase(userInfo: userInfo, course: course, rollCall: currentRollCall);
  }
}
