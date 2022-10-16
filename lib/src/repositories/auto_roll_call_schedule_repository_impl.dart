import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_app/debug/log/log.dart';
import 'package:flutter_app/src/controllers/zuvio_auth_controller.dart';
import 'package:tat_core/core/auto_roll_call/data/auto_roll_call_schedule_repository.dart';
import 'package:tat_core/core/auto_roll_call/domain/auto_roll_call_schedule.dart';

const String _kAutoRollCallScheduleCollectionName = 'auto-roll-call-schedules';
const String _kSchedulesFieldName = 'schedules';
const String _kUserInfoFieldName = 'userInfo';

@immutable
class AutoRollCallScheduleRepositoryImpl implements AutoRollCallScheduleRepository {
  AutoRollCallScheduleRepositoryImpl({
    required FirebaseAuth firebaseAuth,
  })  : assert(firebaseAuth.currentUser != null),
        _firebaseAuth = firebaseAuth {
    _createUserDocumentIfNotExists();
  }

  final FirebaseAuth _firebaseAuth;
  final CollectionReference<Map<String, dynamic>> _scheduleCollectionRef =
      FirebaseFirestore.instance.collection(_kAutoRollCallScheduleCollectionName);
  late final CollectionReference<Map<String, dynamic>> _userScheduleCollectionRef;

  Future<void> _createUserDocumentIfNotExists() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      // TODO: implement the error handling.
      Log.e('User not sign in!');
      return;
    }

    final userDoc = _scheduleCollectionRef.doc(user.uid);
    final userDocSnapshot = await userDoc.get();

    _userScheduleCollectionRef = userDoc.collection(_kSchedulesFieldName);

    if (!userDocSnapshot.exists) {
      final userInfo = ZAuthController.to.currentZUserInfo();
      await _scheduleCollectionRef.doc(user.uid).set({
        // TODO: handle the case when `userInfo` is null.
        _kUserInfoFieldName: userInfo?.toJson(),
      });

      // create schedules collection for this user.
      await _userScheduleCollectionRef.doc().set(const {});

      // clean up the schedules collection,
      // this is because the `doc().set({})` will create a document with an empty map.
      await _cleanUpUserScheduleCollection();
    }
  }

  // clean up the user schedule collection.
  Future<void> _cleanUpUserScheduleCollection() async {
    final userScheduleDocs = await _userScheduleCollectionRef.get();
    for (final doc in userScheduleDocs.docs) {
      await doc.reference.delete();
    }
  }

  @override
  Future<void> addSchedule(AutoRollCallSchedule schedule) async =>
      _userScheduleCollectionRef.doc(schedule.id).set(schedule.toJson());

  @override
  Future<void> deleteSchedule(String scheduleId) => _userScheduleCollectionRef.doc(scheduleId).delete();

  @override
  Future<List<AutoRollCallSchedule>> getAllSchedules(String userId) async {
    final userScheduleSnapshot = await _userScheduleCollectionRef.get();
    final schedules = userScheduleSnapshot.docs.map((scheduleMap) {
      return AutoRollCallSchedule.fromJson(scheduleMap.data());
    }).toList();
    return schedules;
  }

  @override
  Future<AutoRollCallSchedule?> getSchedule(String scheduleId) async {
    final scheduleSnapshot = await _userScheduleCollectionRef.doc(scheduleId).get();
    if (!scheduleSnapshot.exists) {
      return null;
    }

    return AutoRollCallSchedule.fromJson(scheduleSnapshot.data()!);
  }

  @override
  Future<void> updateSchedule(AutoRollCallSchedule schedule) =>
      _userScheduleCollectionRef.doc(schedule.id).update(schedule.toJson());
}
