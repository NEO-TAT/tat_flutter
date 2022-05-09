// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.16

import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';

class PictureStorage{
  static pictureInformationMap(String courseId, String label, String picturePath){
    return {
      'courseId': courseId,
      'label': label,
      'picturePath' : picturePath,
    };
  }

  static takePictureToStorage(String courseId, String picturePath) async{
    Database pictureDB = Get.find<Database>();
    final information = pictureInformationMap(courseId, "unlabeled", picturePath);
    await pictureDB.insert(
      "photo_storage",
      information,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}