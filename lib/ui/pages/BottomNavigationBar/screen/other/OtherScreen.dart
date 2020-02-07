import 'package:flutter/material.dart';
import 'package:flutter_app/src/file/FileStore.dart';
import 'package:page_transition/page_transition.dart';

import 'FileViewer/FileViewerPage.dart';

class OtherScreen extends StatefulWidget {
  @override
  _OtherScreen createState() => _OtherScreen();
}

class _OtherScreen extends State<OtherScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async{
      String path = await FileStore.findLocalPath(context);
      Navigator.push(context ,
        PageTransition(
          type: PageTransitionType.rightToLeft,
          child: FileViewerPage(
            title: "FileViewer",
            path: path,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Other'),
      ),
      body: Text("apple"),
    );
  }
}
