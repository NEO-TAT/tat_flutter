import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_app/debug/log/log.dart';
import 'package:flutter_app/src/controllers/zuvio_auth_controller.dart';
import 'package:tat_core/core/auto_roll_call/data/auto_roll_call_schedule_repository.dart';
import 'package:tat_core/core/auto_roll_call/domain/auto_roll_call_schedule.dart';

const String _kAutoRollCallUsersCollectionName = 'auto-roll-call-users';
const String _kSchedulesFieldName = 'schedules';
const String _kUserInfoFieldName = 'userInfo';
const String _kUserDeviceTokensFieldName = 'userDeviceTokens';

@immutable
class AutoRollCallScheduleRepositoryImpl implements AutoRollCallScheduleRepository {
  AutoRollCallScheduleRepositoryImpl({
    required FirebaseAuth firebaseAuth,
    required FirebaseMessaging firebaseMessaging,
  })  : assert(firebaseAuth.currentUser != null),
        _firebaseAuth = firebaseAuth,
        _firebaseMessaging = firebaseMessaging {
    _createUserDocumentIfNotExists();
  }

  final FirebaseAuth _firebaseAuth;
  final FirebaseMessaging _firebaseMessaging;
  final CollectionReference<Map<String, dynamic>> _scheduleCollectionRef =
      FirebaseFirestore.instance.collection(_kAutoRollCallUsersCollectionName);
  late final CollectionReference<Map<String, dynamic>> _userScheduleCollectionRef;

  bool _checkUserSignedIn() {
    if (_firebaseAuth.currentUser == null) {
      // TODO: implement the error handling.
      Log.e('User not sign in!');
      return false;
    }

    return true;
  }

  Future<void> _createUserDocumentIfNotExists() async {
    final isSignedIn = _checkUserSignedIn();
    if (!isSignedIn) return;

    final user = _firebaseAuth.currentUser!;
    final userDoc = _scheduleCollectionRef.doc(user.uid);
    final userDocSnapshot = await userDoc.get();

    _userScheduleCollectionRef = userDoc.collection(_kSchedulesFieldName);

    if (!userDocSnapshot.exists) {
      // create schedules collection for this user.
      await _userScheduleCollectionRef.doc().set(const {});

      // clean up the schedules collection,
      // this is because the `doc().set({})` will create a document with an empty map.
      await _cleanUpUserScheduleCollection();
    }
  }

  // FIXME: Don't call this method in each storage access method (should we?).
  Future<void> _updateZUserInfo() async {
    final isSignedIn = _checkUserSignedIn();
    if (!isSignedIn) return;

    final user = _firebaseAuth.currentUser!;
    final zUserInfo = ZAuthController.to.currentZUserInfo();

    assert(zUserInfo != null, 'ZUserInfo is null!');

    if (zUserInfo != null) {
      final userDoc = _scheduleCollectionRef.doc(user.uid);
      final existingUserInfo = (await userDoc.get()).data();

      // FIXME: Don't use `List<dynamic>`.
      final existingUserDeviceTokens = existingUserInfo?.containsKey(_kUserDeviceTokensFieldName) == true
          ? existingUserInfo![_kUserDeviceTokensFieldName] as List<dynamic>
          : const <dynamic>[];

      final currentUserDeviceToken = await _firebaseMessaging.getToken();
      final newUserDeviceTokens = {...existingUserDeviceTokens};

      if (currentUserDeviceToken != null) {
        newUserDeviceTokens.add(currentUserDeviceToken);
      }

      await userDoc.set({
        _kUserDeviceTokensFieldName: newUserDeviceTokens.toList(),
        _kUserInfoFieldName: zUserInfo.toJson(),
      });
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
  Future<void> addSchedule(AutoRollCallSchedule schedule) async {
    _updateZUserInfo();
    return _userScheduleCollectionRef.doc(schedule.id).set(schedule.toJson());
  }

  @override
  Future<void> deleteSchedule(String scheduleId) {
    _updateZUserInfo();
    return _userScheduleCollectionRef.doc(scheduleId).delete();
  }

  @override
  Future<List<AutoRollCallSchedule>> getAllSchedules(String userId) async {
    _updateZUserInfo();
    final userScheduleSnapshot = await _userScheduleCollectionRef.get();
    final schedules = userScheduleSnapshot.docs.map((scheduleMap) {
      return AutoRollCallSchedule.fromJson(scheduleMap.data());
    }).toList();
    return schedules;
  }

  @override
  Future<AutoRollCallSchedule?> getSchedule(String scheduleId) async {
    _updateZUserInfo();
    final scheduleSnapshot = await _userScheduleCollectionRef.doc(scheduleId).get();
    if (!scheduleSnapshot.exists) {
      return null;
    }

    return AutoRollCallSchedule.fromJson(scheduleSnapshot.data()!);
  }

  @override
  Future<void> updateSchedule(AutoRollCallSchedule schedule) {
    _updateZUserInfo();
    return _userScheduleCollectionRef.doc(schedule.id).update(schedule.toJson());
  }
}
