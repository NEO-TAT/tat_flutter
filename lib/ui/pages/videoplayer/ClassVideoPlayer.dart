import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/config/AppConfig.dart';
import 'package:flutter_app/src/config/Appthemes.dart';
import 'package:flutter_app/src/connector/core/Connector.dart';
import 'package:flutter_app/src/connector/core/ConnectorParameter.dart';
import 'package:flutter_app/src/file/FileDownload.dart';
import 'package:flutter_app/src/model/coursetable/CourseTableJson.dart';
import 'package:flutter_app/src/providers/AppProvider.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/util/LanguageUtil.dart';
import 'package:flutter_app/src/util/MXPlayerUtil.dart';
import 'package:flutter_app/ui/other/MyToast.dart';
import 'package:get/get.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart' as URI;
import 'package:video_player/video_player.dart';

class ClassVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final CourseInfoJson courseInfo;
  final String name;

  ClassVideoPlayer(this.videoUrl, this.courseInfo, this.name);

  @override
  _VideoPlayer createState() => _VideoPlayer();
}

class VideoInfo {
  String name;
  String url;
}

class _VideoPlayer extends State<ClassVideoPlayer> {
  bool isLoading = true;
  VideoPlayerController _controller;
  ChewieController _chewieController;
  List<VideoInfo> videoName = [];
  VideoInfo _select;
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
    _controller?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo routeInfo) {
    Get.back();
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
      Get.back();
      return;
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
      } catch (e) {
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
    String url = await Get.dialog<String>(
      AlertDialog(
        content: Container(
          width: double.minPositive,
          child: ListView.builder(
            itemCount: videoName.length,
            shrinkWrap: true, //使清單最小化
            itemBuilder: (BuildContext context, int index) {
              return Container(
                child: TextButton(
                  child: Text(videoName[index].name),
                  onPressed: () {
                    String url = getVideoUrl(videoName[index].url);
                    _select = videoName[index];
                    Get.back<String>(result: url);
                  },
                ),
              );
            },
          ),
        ),
      ),
      barrierDismissible: true,
    );
    bool open = false;
    if (Model.instance.getOtherSetting().useExternalVideoPlayer) {
      String name = widget.name + "_" + _select.name + ".mp4";
      open = await MXPlayerUtil.launch(url: url, name: name);
    }
    if (!open) {
      await initController(url);
    } else {
      Get.back();
    }
  }

  Future<void> initController(String url) async {
    _controller = VideoPlayerController.network(
      url,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    _controller.addListener(() {
      setState(() {});
    });
    _controller.setLooping(true);
    await _controller.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _controller,
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
                onPressed: () => Get.back(),
              ),
              title: Text(R.current.classVideo),
              actions: [
                if (!isLoading)
                  IconButton(
                    icon: Icon(Icons.file_download),
                    onPressed: () async {
                      String url = _controller.dataSource;
                      String courseName = widget.courseInfo.main.course.name;
                      String saveName = widget.name + "_" + _select.name + ".mp4";
                      String subDir = (LanguageUtil.getLangIndex() == LangEnum.zh) ? "上課錄影" : "video";
                      String dirName = path.join(courseName, subDir);
                      FileDownload.download(context, url, dirName, saveName);
                    },
                  ),
                if (!isLoading)
                  IconButton(
                    icon: Icon(Icons.open_in_new),
                    onPressed: () async {
                      await URI.launch(_controller.dataSource);
                    },
                  )
              ],
            ),
            body: (isLoading || _controller == null)
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : buildVideoPlayer(_controller),
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
