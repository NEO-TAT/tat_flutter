// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/debug/log/log.dart';
import 'package:flutter_app/src/connector/core/connector.dart';
import 'package:flutter_app/src/connector/core/connector_parameter.dart';
import 'package:flutter_app/src/file/file_download.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/src/store/local_storage.dart';
import 'package:flutter_app/src/util/language_util.dart';
import 'package:flutter_app/src/util/mx_player_util.dart';
import 'package:flutter_app/ui/other/my_toast.dart';
import 'package:flutter_app/ui/other/route_utils.dart';
import 'package:get/get.dart';
import 'package:html/parser.dart';
import 'package:path/path.dart' as path;
import 'package:video_player/video_player.dart';

import '../../../src/model/coursetable/course.dart';

class ClassVideoPlayer extends StatefulWidget {
  const ClassVideoPlayer(
    this.videoUrl,
    this.course,
    this.name, {
    super.key,
  });

  final String videoUrl;
  final Course course;
  final String name;

  @override
  State<ClassVideoPlayer> createState() => _VideoPlayer();
}

@immutable
class _VideoInfo {
  const _VideoInfo(this.name, this.url);

  final String name;
  final String url;
}

class _VideoPlayer extends State<ClassVideoPlayer> {
  bool _isLoading = true;
  final _videoNames = <_VideoInfo>[];
  VideoPlayerController? _playerController;
  ChewieController? _chewieController;
  late final _VideoInfo _selectedVideoInfo;

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    parseVideo();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    BackButtonInterceptor.remove(myInterceptor);

    _playerController?.dispose();
    _chewieController?.dispose();

    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo routeInfo) {
    Get.back();
    return true;
  }

  void parseVideo() async {
    _isLoading = true;

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
      if (child.children.first.localName == 'source') {
        try {
          final url = child.children.first.attributes['src'];
          if (url == null) {
            continue;
          }

          final info = _VideoInfo(child.id, url);
          _videoNames.add(info);
        } on Exception catch (e, stackTrace) {
          Log.eWithStack(e, stackTrace);
          continue;
        }
      }
    }

    await _buildDialog();
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    setState(() => _isLoading = false);
  }

  String getVideoUrl(String path) => "https://istream.ntut.edu.tw/videoplayer/$path";

  Future<void> _buildDialog() async {
    final urlStr = await Get.dialog<String>(
      AlertDialog(
        content: SizedBox(
          width: double.minPositive,
          child: ListView.builder(
            itemCount: _videoNames.length,
            shrinkWrap: true,
            itemBuilder: (context, index) => TextButton(
              child: Text(_videoNames[index].name),
              onPressed: () {
                final url = getVideoUrl(_videoNames[index].url);
                _selectedVideoInfo = _videoNames[index];
                Get.back<String>(result: url);
              },
            ),
          ),
        ),
      ),
      barrierDismissible: true,
    );

    bool externalPlayerHasLaunched = false;

    if (LocalStorage.instance.getOtherSetting().useExternalVideoPlayer) {
      final name = "${widget.name}_${_selectedVideoInfo.name}.mp4";
      externalPlayerHasLaunched = await MXPlayerUtil.launch(url: urlStr, name: name);
    }

    final url = Uri.tryParse(urlStr ?? "");

    if (!externalPlayerHasLaunched && url != null) {
      await initController(url);
    } else {
      Get.back();
    }
  }

  Future<void> initController(Uri url) async {
    _playerController = VideoPlayerController.networkUrl(
      url,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );

    _playerController?.addListener(() => setState(() {}));
    _playerController?.setLooping(true);

    await _playerController?.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _playerController!,
      autoPlay: true,
      autoInitialize: true,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () => Get.back(),
          ),
          title: Text(R.current.classVideo),
          actions: [
            if (!_isLoading)
              IconButton(
                icon: const Icon(Icons.file_download),
                onPressed: () {
                  final url = _playerController?.dataSource;
                  if (url == null) {
                    return;
                  }

                  final courseName = widget.course.name;
                  final saveName = "${widget.name}_${_selectedVideoInfo.name}.mp4";
                  final subDir = (LanguageUtil.getLangIndex() == LangEnum.zh) ? "上課錄影" : "video";
                  final dirName = path.join(courseName, subDir);

                  FileDownload.download(url, dirName, saveName);
                },
              ),
            if (!_isLoading)
              IconButton(
                icon: const Icon(Icons.open_in_new),
                onPressed: () async {
                  final dataSource = _playerController?.dataSource;

                  if (dataSource == null) {
                    return;
                  }

                  await RouteUtils.toWebViewPage(initialUrl: Uri.parse(dataSource));
                },
              ),
          ],
        ),
        body: SafeArea(
          child: (!_isLoading && _chewieController != null)
              ? Chewie(controller: _chewieController!)
              : const Center(child: CircularProgressIndicator()),
        ),
      );
}
