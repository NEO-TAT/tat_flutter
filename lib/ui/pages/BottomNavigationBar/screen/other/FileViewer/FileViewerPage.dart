import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/file/FileStore.dart';
import 'package:flutter_app/ui/pages/BottomNavigationBar/screen/other/FileViewer/providers/core_provider.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'folder.dart';

class FileViewerPage extends StatefulWidget {
  @override
  _FileViewerPage createState() => _FileViewerPage();
}

class _FileViewerPage extends State<FileViewerPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      String directory = await FileStore.findLocalPath(context);
      Navigator.of(context).push(
        PageTransition(
            type: PageTransitionType.rightToLeft,
            child: Folder(
              title: "Device",
              path: directory,
            )),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Setting'),
      ),
      body: Text("_FileViewerPage"),
    );
  }
}
