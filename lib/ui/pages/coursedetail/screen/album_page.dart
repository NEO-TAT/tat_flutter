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
  bool isLoading = true;

  late int pictureNum;
  late List<Picture> pictures = [];

  dynamic picturesInfo;

  late double screenWidth;
  late double screenHeight;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      useCourseIdToGetPicturePaths();
    });
  }

  void useCourseIdToGetPicturePaths() async {
    picturesInfo = await PictureStorage.getCoursePicture(widget.courseId);
    isLoading = false;
    pictureNum = picturesInfo.length;
    for (int i = 0; i < pictureNum; i++) {
      int infoId = picturesInfo[i]['_id'];
      String infoLabel = picturesInfo[i]['label'];
      String infoNote = picturesInfo[i]['note'];
      String infoPath = picturesInfo[i]['picturePath'];

      pictures.add(Picture(infoId, infoLabel, infoNote, infoPath));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Container(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Expanded(
                  child: pictureAlbum(),
                ),
        ],
      ),
    );
  }

  Widget pictureAlbum() {
    return ListView(children: [
      Wrap(
        alignment: WrapAlignment.center,
        spacing: 10.0, // gap between adjacent chips
        runSpacing: 6.0,
        children: [
          for (Picture picture in pictures)
            SizedBox(
              width: screenWidth / 4,
              height: screenHeight / 8,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: InkWell(
                      child: PhotoView(
                        imageProvider: FileImage(File(picture.getPath())),
                      ),
                      onTap: () => openOriginalSizePicture(context, picture))),
            )
        ],
      )
    ]);
  }

  void openOriginalSizePicture(BuildContext context, Picture picture) {
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
      return Scaffold(
          body: PhotoView(
            imageProvider: FileImage(File(picture.getPath())),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              picture.deletePicture();
              pictures.remove(picture);
              setState(() {});
              Navigator.pop(context);
            },
            label: const Text('Delete'),
            backgroundColor: Colors.pink,
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat);
    }));
  }
}
//
