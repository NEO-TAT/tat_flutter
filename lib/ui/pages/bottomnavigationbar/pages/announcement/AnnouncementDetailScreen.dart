import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/store/json/NewAnnouncementJson.dart';
import 'package:flutter_html/flutter_html.dart';

class AnnouncementDetailScreen extends StatefulWidget {
  final NewAnnouncementJson data;

  AnnouncementDetailScreen(this.data);

  @override
  _AnnouncementDetailScreen createState() => _AnnouncementDetailScreen();
}

class _AnnouncementDetailScreen extends State<AnnouncementDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Email'),
      ),
      body: Html(
        data: widget.data.detail,
        //Optional parameters:
        padding: EdgeInsets.all(8.0),
        backgroundColor: Colors.white70,
        defaultTextStyle: TextStyle(fontFamily: 'serif'),
        linkStyle: const TextStyle(
          color: Colors.redAccent,
        ),
        onLinkTap: (url) {
          // open url in a webview
        },
        onImageTap: (src) {
          // Display the image in large form.
        },
      ),
    );
  }
}
