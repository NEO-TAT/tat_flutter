import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/core/Connector.dart';
import 'package:flutter_app/src/connector/core/ConnectorParameter.dart';
import 'package:flutter_app/src/costants/Constants.dart';
import 'package:flutter_app/src/providers/AppProvider.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/ui/other/MyToast.dart';
import 'package:flutter_ijkplayer/flutter_ijkplayer.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:provider/provider.dart';

class ClassVideoPlayer extends StatefulWidget {
  final String uuid;

  ClassVideoPlayer(this.uuid);

  @override
  _VideoPlayer createState() => _VideoPlayer();
}

class _VideoPlayer extends State<ClassVideoPlayer> {
  bool isLoading = true;
  IjkMediaController controller;
  List<String> videoName = List();
  int selectIndex = 0;

  @override
  void initState() {
    controller = IjkMediaController();
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    parseVideo();
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    controller.dispose();
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
    //String title = node.getElementsByTagName("title").first.text;
    //String description = node.getElementsByTagName("description").first.text;
    String presenterVideo =
        node.getElementsByTagName("presenter_video").first.text;
    String presenterVideo2 =
        node.getElementsByTagName("presenter2_video").first.text;
    String presentationVideo =
        node.getElementsByTagName("presentation_video").first.text;

    for (String name in [presenterVideo, presenterVideo2, presentationVideo]) {
      if (name != null && name.isNotEmpty) {
        videoName.add(name);
      }
    }
    await _buildDialog();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _buildDialog() async {
    String url = await showDialog<String>(
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
                      String url = getRTMPUrl(videoName[index]);
                      Navigator.of(context).pop(url);
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
    if (Model.instance.getOtherSetting().useExternalVideoPlayer) {
      if (Platform.isAndroid) {
        AndroidIntent intent = AndroidIntent(
          action: 'action_view',
          data: url,
        );
        try {
          await intent.launch();
          Navigator.of(context).pop();
        } catch (e) {
          MyToast.show(R.current.noSupportExternalVideoPlayer);
          controller.setNetworkDataSource(url, autoPlay: true);
        }
      }
    } else {
      controller.setNetworkDataSource(url, autoPlay: true);
    }
  }

  String getRTMPUrl(String name) {
    return "rtmp://istreaming.ntut.edu.tw/lecture/" + widget.uuid + "/" + name;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (BuildContext context, AppProvider appProvider, Widget child) {
        return MaterialApp(
          title: Constants.appName,
          theme: appProvider.theme,
          darkTheme: Constants.darkTheme,
          home: Scaffold(
            appBar: AppBar(
              leading: BackButton(
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(R.current.classVideo),
            ),
            body: (isLoading)
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : buildIjkPlayer(controller),
          ),
        );
      },
    );
  }

  Widget buildIjkPlayer(IjkMediaController controller) {
    return Container(
      // height: 400, // 這裡隨意
      child: IjkPlayer(
        mediaController: controller,
      ),
    );
  }
}
