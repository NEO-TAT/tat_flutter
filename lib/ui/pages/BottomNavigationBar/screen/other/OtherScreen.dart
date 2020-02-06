import 'package:flutter/material.dart';
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
    Future.delayed(Duration.zero, () {
      Navigator.of(context).push(
        PageTransition(
          type: PageTransitionType.rightToLeft,
          child: FileViewerPage(),
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
