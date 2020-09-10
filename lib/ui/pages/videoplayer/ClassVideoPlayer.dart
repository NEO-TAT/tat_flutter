import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/config/AppConfig.dart';
import 'package:flutter_app/src/config/Appthemes.dart';
import 'package:flutter_app/src/connector/core/Connector.dart';
import 'package:flutter_app/src/connector/core/ConnectorParameter.dart';
import 'package:flutter_app/src/providers/AppProvider.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/ui/other/MyToast.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class ClassVideoPlayer extends StatefulWidget {
  final String videoUrl;

  ClassVideoPlayer(this.videoUrl);

  @override
  _VideoPlayer createState() => _VideoPlayer();
}

class VideoInfo {
  String name;
  String url;
}

class _VideoPlayer extends State<ClassVideoPlayer> {
  bool isLoading = true;
  VideoPlayerController controller;
  ChewieController _chewieController;
  List<VideoInfo> videoName = List();
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
    controller?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent) {
    Navigator.of(context).pop();
    return true;
  }

  void parseVideo() async {
    isLoading = true;
    ConnectorParameter parameter = ConnectorParameter(widget.videoUrl);
    String result = await Connector.getDataByGet(parameter);
    dom.Document tagNode = parse(result);
    dom.Element node = tagNode.getElementById("videoplayer");
    if (node?.children == null) {
      MyToast.show(R.current.unknownError);
      Navigator.of(context).pop();
    }
    for (dom.Element child in node.children) {
      try {
        if (child.children.first.localName == 'source') {
          String url = child.children.first.attributes['src'];
          VideoInfo info = VideoInfo();
          info.url = url;
          info.name = child.id;
          videoName.add(info);
        }
      } catch (e, stack) {
        continue;
      }
    }
    await _buildDialog();
    setState(() {
      isLoading = false;
    });
  }

  String getVideoUrl(String path) {
    String url = "https://istream.ntut.edu.tw/videoplayer/$path";
    return url;
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
                    child: Text(videoName[index].name),
                    onPressed: () {
                      String url = getVideoUrl(videoName[index].url);
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
          await initController(url);
        }
      }
    } else {
      await initController(url);
    }
  }

  Future<void> initController(String url) async {
    controller = VideoPlayerController.network(
      url,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    controller.addListener(() {
      setState(() {});
    });
    controller.setLooping(true);
    await controller.initialize();
    _chewieController = ChewieController(
      videoPlayerController: controller,
      autoPlay: true,
      //aspectRatio: 3 / 2.0,
      //customControls: CustomControls(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (BuildContext context, AppProvider appProvider, Widget child) {
        return MaterialApp(
          title: AppConfig.appName,
          theme: appProvider.theme,
          darkTheme: AppThemes.darkTheme,
          home: Scaffold(
            appBar: AppBar(
              leading: BackButton(
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(R.current.classVideo),
            ),
            body: (isLoading || controller == null)
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : buildVideoPlayer(controller),
          ),
        );
      },
    );
  }

  Widget buildVideoPlayer(VideoPlayerController controller) {
    return Container(
      // height: 400, // 這裡隨意
      child: Chewie(
        controller: _chewieController,
      ),
    );
  }
}
