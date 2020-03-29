import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/connector/core/Connector.dart';
import 'package:flutter_app/src/connector/core/ConnectorParameter.dart';
import 'package:flutter_ijkplayer/flutter_ijkplayer.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';

class ClassVideoPlayer extends StatefulWidget {
  final String uuid;

  ClassVideoPlayer(this.uuid);

  @override
  _VideoPlayer createState() => _VideoPlayer();
}

class _VideoPlayer extends State<ClassVideoPlayer> {
  bool isLoading = true;
  List<IjkMediaController> controllerList = List();
  List<String> videoName = List();
  int selectIndex = 0;

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    parseVideo();
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    for (IjkMediaController item in controllerList) {
      item.dispose();
    }
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent) {
    Navigator.of(context).pop();
    return true;
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

    int number = 0;
    for (String name in [presenterVideo, presenterVideo2, presentationVideo]) {
      if (name != null && name.isNotEmpty) {
        controllerList.add(IjkMediaController());
        String url = getRTMPUrl(name);
        controllerList[number].setNetworkDataSource(url, autoPlay: true);
        videoName.add(name);
        number++;
      }
    }
    await _buildDialog();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _buildDialog() async {
    await showDialog(
      useRootNavigator: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            width: double.minPositive,
            child: ListView.builder(
              itemCount: videoName.length,
              shrinkWrap: true, //使清單最小化
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  child: FlatButton(
                    child: Text(videoName[index]),
                    onPressed: () {
                      Navigator.of(context).pop();
                      selectIndex = index;
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  String getRTMPUrl(String name) {
    return "rtmp://istreaming.ntut.edu.tw/lecture/" + widget.uuid + "/" + name;
  }

  @override
  Widget build(BuildContext context) {
    return (isLoading)
        ? Center(
            child: CircularProgressIndicator(),
          )
        : buildIjkPlayer(controllerList[selectIndex]);
  }

  Widget _buildVideoPlayer() {
    return Column(
      children: controllerList.map((controller) {
        return buildIjkPlayer(controller);
      }).toList(),
    );
  }

  Widget buildIjkPlayer(IjkMediaController controller) {
    return Container(
      // height: 400, // 这里随意
      child: IjkPlayer(
        mediaController: controller,
      ),
    );
  }
}