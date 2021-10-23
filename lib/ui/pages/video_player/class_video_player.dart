import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html/parser.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:tat/src/R.dart';
import 'package:tat/src/config/app_config.dart';
import 'package:tat/src/config/app_themes.dart';
import 'package:tat/src/connector/core/connector.dart';
import 'package:tat/src/connector/core/connector_parameter.dart';
import 'package:tat/src/file/file_download.dart';
import 'package:tat/src/model/course_table/course_table_json.dart';
import 'package:tat/src/providers/app_provider.dart';
import 'package:tat/src/store/model.dart';
import 'package:tat/src/util/language_utils.dart';
import 'package:tat/src/util/mx_player_utils.dart';
import 'package:tat/ui/other/my_toast.dart';
import 'package:url_launcher/url_launcher.dart' as URI;
import 'package:video_player/video_player.dart';

class ClassVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final CourseInfoJson courseInfo;
  final String name;

  const ClassVideoPlayer(this.videoUrl, this.courseInfo, this.name);

  @override
  _VideoPlayer createState() => _VideoPlayer();
}

class VideoInfo {
  String? name;
  String? url;
}

class _VideoPlayer extends State<ClassVideoPlayer> {
  bool isLoading = true;
  late VideoPlayerController? _controller;
  late ChewieController? _chewieController;
  final List<VideoInfo> videoName = [];
  late VideoInfo _select;
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
    final parameter = ConnectorParameter(widget.videoUrl);
    final result = await Connector.getDataByGet(parameter);
    final tagNode = parse(result);
    final node = tagNode.getElementById("videoplayer");
    if (node?.children == null) {
      MyToast.show(R.current.unknownError);
      Get.back();
      return;
    }
    for (final child in node!.children) {
      try {
        if (child.children.first.localName == 'source') {
          final url = child.children.first.attributes['src'];
          final info = VideoInfo();
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

  String getVideoUrl(String path) => "https://istream.ntut.edu.tw/videoplayer/$path";

  Future<void> _buildDialog() async {
    final url = await Get.dialog<String>(
      AlertDialog(
        content: Container(
          width: double.minPositive,
          child: ListView.builder(
            itemCount: videoName.length,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                child: TextButton(
                  child: Text(videoName[index].name ?? ''),
                  onPressed: () {
                    final url = getVideoUrl(videoName[index].url ?? '');
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
    if (Model.instance.getOtherSetting()!.useExternalVideoPlayer) {
      final name = widget.name + "_" + (_select.name ?? '') + ".mp4";
      open = await MXPlayerUtils.launch(url: url ?? '', name: name);
    }
    if (!open) {
      await initController(url ?? '');
    } else {
      Get.back();
    }
  }

  Future<void> initController(String url) async {
    _controller = VideoPlayerController.network(
      url,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    _controller!.addListener(() {
      setState(() {});
    });
    _controller!.setLooping(true);
    await _controller!.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _controller!,
      autoPlay: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (BuildContext context, AppProvider appProvider, Widget? child) {
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
                      final url = _controller!.dataSource;
                      final courseName = widget.courseInfo.main!.course!.name;
                      final saveName = widget.name + "_" + (_select.name ?? '') + ".mp4";
                      final subDir = (LanguageUtils.getLangIndex() == LangEnum.zh) ? "上課錄影" : "video";
                      final dirName = path.join(courseName, subDir);
                      FileDownload.download(context, url, dirName, saveName);
                    },
                  ),
                if (!isLoading)
                  IconButton(
                    icon: Icon(Icons.open_in_new),
                    onPressed: () async {
                      await URI.launch(_controller!.dataSource);
                    },
                  )
              ],
            ),
            body: (isLoading || _controller == null)
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : buildVideoPlayer(_controller!),
          ),
        );
      },
    );
  }

  Widget buildVideoPlayer(VideoPlayerController controller) {
    return Container(
      child: Chewie(
        controller: _chewieController!,
      ),
    );
  }
}
