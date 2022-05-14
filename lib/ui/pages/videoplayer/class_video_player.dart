// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.10
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/config/app_config.dart';
import 'package:flutter_app/src/config/app_themes.dart';
import 'package:flutter_app/src/connector/core/connector.dart';
import 'package:flutter_app/src/connector/core/connector_parameter.dart';
import 'package:flutter_app/src/file/file_download.dart';
import 'package:flutter_app/src/model/coursetable/course_table_json.dart';
import 'package:flutter_app/src/providers/app_provider.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/src/store/local_storage.dart';
import 'package:flutter_app/src/util/language_util.dart';
import 'package:flutter_app/src/util/mx_player_util.dart';
import 'package:flutter_app/ui/other/my_toast.dart';
import 'package:get/get.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

class ClassVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final CourseInfoJson courseInfo;
  final String name;

  const ClassVideoPlayer(this.videoUrl, this.courseInfo, this.name, {Key key}) : super(key: key);

  @override
  State<ClassVideoPlayer> createState() => _VideoPlayer();
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
        content: SizedBox(
          width: double.minPositive,
          child: ListView.builder(
            itemCount: videoName.length,
            shrinkWrap: true, //使清單最小化
            itemBuilder: (BuildContext context, int index) {
              return TextButton(
                child: Text(videoName[index].name),
                onPressed: () {
                  String url = getVideoUrl(videoName[index].url);
                  _select = videoName[index];
                  Get.back<String>(result: url);
                },
              );
            },
          ),
        ),
      ),
      barrierDismissible: true,
    );
    bool open = false;
    if (LocalStorage.instance.getOtherSetting().useExternalVideoPlayer) {
      String name = "${widget.name}_${_select.name}.mp4";
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
                    icon: const Icon(Icons.file_download),
                    onPressed: () async {
                      String url = _controller.dataSource;
                      String courseName = widget.courseInfo.main.course.name;
                      String saveName = "${widget.name}_${_select.name}.mp4";
                      String subDir = (LanguageUtil.getLangIndex() == LangEnum.zh) ? "上課錄影" : "video";
                      String dirName = path.join(courseName, subDir);
                      FileDownload.download(url, dirName, saveName);
                    },
                  ),
                if (!isLoading)
                  IconButton(
                    icon: const Icon(Icons.open_in_new),
                    onPressed: () async {
                      await launchUrl(Uri.parse(_controller.dataSource));
                    },
                  )
              ],
            ),
            body: (isLoading || _controller == null)
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : buildVideoPlayer(_controller),
          ),
        );
      },
    );
  }

  Widget buildVideoPlayer(VideoPlayerController controller) {
    return Chewie(
      controller: _chewieController,
    );
  }
}
