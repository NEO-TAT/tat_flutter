import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/connector/core/Connector.dart';
import 'package:flutter_app/src/connector/core/ConnectorParameter.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';

class VideoPlayer extends StatefulWidget {
  final String uuid;

  VideoPlayer(this.uuid);

  @override
  _VideoPlayer createState() => _VideoPlayer();
}

class _VideoPlayer extends State<VideoPlayer> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    parseVideo();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void parseVideo() async {
    isLoading = true;
    ConnectorParameter parameter = ConnectorParameter(
        "https://istream.ntut.edu.tw/lecture/api/Search/recordingSearchByUUID");
    parameter.data = {"type": "xml", "uuid": widget.uuid};
    String xml = await Connector.getDataByGet(parameter);
    dom.Document tagNode = parse(xml);
    dom.Element node = tagNode.getElementsByTagName("item").first;
    String title = node.getElementsByTagName("title").first.text;
    String description = node.getElementsByTagName("description").first.text;
    String presenterVideo =
        node.getElementsByTagName("presenter_video").first.text;
    String presenterVideo2 =
        node.getElementsByTagName("presenter2_video").first.text;
    String presentationVideo =
        node.getElementsByTagName("presentation_video").first.text;
    Log.d(title);
    Log.d(description);
    String presenterRTMPUrl = "rtmp://istreaming.ntut.edu.tw/lecture/" +
        widget.uuid +
        "/" +
        presenterVideo;
    String presentationRTMPUrl = "rtmp://istreaming.ntut.edu.tw/lecture/" +
        widget.uuid +
        "/" +
        presentationVideo;

    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return (isLoading)
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Center(
            child: CircularProgressIndicator(),
          );
  }
}
