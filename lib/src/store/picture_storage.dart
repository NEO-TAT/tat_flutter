import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';

class PictureStorage {
  static pictureInformationMap(String courseId, String label, String picturePath, String note) {
    return {
      'courseId': courseId,
      'label': label,
      'note': note,
      'picturePath': picturePath,
    };
  }

  static takePictureToStorage(String courseId, String picturePath) async {
    Database pictureDB = Get.find<Database>();
    final information = pictureInformationMap(courseId, "unlabeled", picturePath, "");
    await pictureDB.insert(
      "photo_storage",
      information,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static getCoursePicture(String courseId) async {
    Database pictureDB = Get.find<Database>();
    List<Map> picturePaths =  await pictureDB.rawQuery('SELECT  * '
                          'FROM photo_storage '
                          'WHERE courseId=$courseId');
    return picturePaths;
  }
}

class Picture{
  late int id;
  late String label;
  late String note;
  late String path;

  Picture(this.id, this.label, this.note, this.path);

  String getLabel() => label;

  String getNote() => note;

  String getPath() => path;

  void modifyLabel(){}

  void modifyNote(){}

  void deletePicture() async {
    Database pictureDB = Get.find<Database>();
    await pictureDB.delete(
      "photo_storage",
      where: "_id = ?",
      whereArgs: [id],
    );

    File(getPath()).delete();
  }
}