import 'package:flutter/material.dart';
import 'package:flutter_app/src/store/picture_storage.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:io';

class AlbumPage extends StatefulWidget {
  final String courseId;

  const AlbumPage({Key? key, required this.courseId}) : super(key: key);

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  bool _isLoading = true;

  final List<Picture> pictures = [];

  final PictureStorage _pictureStorage;

  _AlbumPageState() : _pictureStorage = PictureStorage();

  @override
  void initState() {
    super.initState();
    Future.delayed(
      Duration.zero,
      () => useCourseIdToGetPicturePaths(),
    );
  }

  void removePicture(picture){
    _pictureStorage.deletePicture(picture);
    pictures.remove(picture);
    setState(() {});
    Navigator.pop(context);
  }

  void useCourseIdToGetPicturePaths() async {
    dynamic picturesInfo =
        await _pictureStorage.getCoursePicture(widget.courseId);
    for (final pictureInfo in picturesInfo) {
      int infoId = pictureInfo['_id'];
      String infoPath = pictureInfo['picturePath'];
      String infoLabel = pictureInfo['label'];
      String infoNote = pictureInfo['note'];
      pictures.add(Picture(
        id: infoId,
        path: infoPath,
        label: infoLabel,
        note: infoNote,
      ));
    }
    _isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 20),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Expanded(child: pictureAlbum),
    );
  }

  Widget get pictureAlbum {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return ListView(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10.0, // gap between adjacent chips
          runSpacing: 6.0,
          children: [
            for (final picture in pictures)
              SizedBox(
                width: screenWidth / 4,
                height: screenHeight / 8,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: InkWell(
                    child: PhotoView(
                      imageProvider: FileImage(
                        File(picture.path),
                      ),
                    ),
                    onTap: () => openOriginalSizePicture(context, picture),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  MaterialPageRoute checkPhotoViewRoute(picture) {
    return MaterialPageRoute(
      builder: (BuildContext context) {
        return Scaffold(
            body: PhotoView(
              imageProvider: FileImage(File(picture.path)),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => removePicture(picture),
              label: const Text('Delete'),
              backgroundColor: Colors.pink,
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat);
      },
    );
  }

  void openOriginalSizePicture(BuildContext context, Picture picture) {
    Navigator.push(context, checkPhotoViewRoute(picture));
  }
}
