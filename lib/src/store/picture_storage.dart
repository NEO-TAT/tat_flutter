import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';

class PictureStorage {

  PictureStorage() : _pictureDB = Get.find<Database>();

  final Database _pictureDB;

  Map<String, String> pictureInformationMap(String courseId, String label, String picturePath, String note) {
    return {
      'courseId': courseId,
      'label': label,
      'note': note,
      'picturePath': picturePath,
    };
  }

  Future<void> takePictureToStorage(String courseId, String picturePath) async {
    final information = pictureInformationMap(courseId, "unlabeled", picturePath, "");
    await _pictureDB.insert(
      "photo_storage",
      information,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, Object?>>> getCoursePicture(String courseId) async {
    return await _pictureDB.rawQuery('SELECT  * '
        'FROM photo_storage '
        'WHERE courseId=$courseId');
  }
}

class Picture {
  final int _id;
  final String _path;
  String label;
  String note;

  Picture(this._id, this.label, this.note, this._path);

  String get getLabel => label;

  String get getNote => note;

  String get getPath => _path;

  void modifyLabel() {}

  void modifyNote() {}

  Future<void> deletePicture() async {
    Database pictureDB = Get.find<Database>();
    await pictureDB.delete(
      "photo_storage",
      where: "_id = ?",
      whereArgs: [_id],
    );

    File(_path).delete();
  }
}
