import 'package:flutter/material.dart';
import 'package:flutter_app/src/store/picture_storage.dart';

class AlbumPage extends StatelessWidget {
  final String courseId;

  const AlbumPage({
    super.key,
    required this.courseId
  });

  @override
  Widget build(BuildContext context) {
    PictureStorage.getCoursePicture(courseId);
    return Container();
  }
}
