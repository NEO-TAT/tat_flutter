import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';

class PictureStorage {
  static pictureInformationMap(String courseId, String label, String picturePath) {
    return {
      'courseId': courseId,
      'label': label,
      'picturePath': picturePath,
    };
  }

  static takePictureToStorage(String courseId, String picturePath) async {
    Database pictureDB = Get.find<Database>();
    final information = pictureInformationMap(courseId, "unlabeled", picturePath);
    await pictureDB.insert(
      "photo_storage",
      information,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static getCoursePicture(String courseId) async {
    Database pictureDB = Get.find<Database>();
    List<Map> picturePaths =  await pictureDB.rawQuery('SELECT picturePath '
                          'FROM photo_storage '
                          'WHERE $courseId');
    print(picturePaths);
  }
}
