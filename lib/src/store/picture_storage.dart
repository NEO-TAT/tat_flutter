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

  Future<void> deletePicture(Picture picture) async {
    Database pictureDB = Get.find<Database>();
    await pictureDB.delete(
      "photo_storage",
      where: "_id = ?",
      whereArgs: [picture.id],
    );

    File(picture.path).delete();
  }
}

class Picture {
  final int id;
  final String path;
  final String label;
  final String note;

  const Picture({
    required this.id,
    required this.path,
    required this.label,
    required this.note,
  });

  Picture copyWith({
    int? id,
    String? path,
    String? label,
    String? note,
  }) =>
      Picture(
        id: id ?? this.id,
        path: path ?? this.path,
        label: label ?? this.label,
        note: note ?? this.note,
      );
}
