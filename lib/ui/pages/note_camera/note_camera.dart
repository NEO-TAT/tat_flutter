import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_app/src/store/picture_storage.dart';

class NoteCamera extends StatefulWidget {
  final String courseId;

  const NoteCamera({Key? key, required this.courseId}) : super(key: key);

  @override
  State<NoteCamera> createState() => _NoteCameraState();
}

class _NoteCameraState extends State<NoteCamera> with WidgetsBindingObserver {
  CameraController? controller;
  bool _isCameraInitialized = false;
  List<CameraDescription> cameras = const [];

  double _zoom = 1.0;

  _NoteCameraState();

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;

    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await previousCameraController?.dispose();

    if (mounted) {
      setState(() {
        controller = cameraController;
      });
    }
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      throw Exception('Error initializing camera: $e');
    }

    if (mounted) {
      setState(() {
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }
  }

  void takePicture() async {
    final image = await controller?.takePicture();
    String? path = image?.path;
    if (path != null) {
      PictureStorage.takePictureToStorage(widget.courseId, path);
    }
  }

  void adjustZoom(scaleStartDetails) {
    double newZoom = 0.0;
    if (scaleStartDetails.scale > 1.0) {
      newZoom = _zoom + 0.05;
    } else if (scaleStartDetails.scale < 1.0) {
      newZoom = _zoom - 0.05;
    }
    if (newZoom >= 1.0 && newZoom <= 9.0) {
      _zoom = newZoom;
    }
    controller?.setZoomLevel(_zoom);
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    cameras = Get.find<List<CameraDescription>>();
    onNewCameraSelected(cameras[0]);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onScaleUpdate: (scaleStartDetails) => adjustZoom(scaleStartDetails),
      child: _isCameraInitialized
          ? CameraPreview(
              controller!,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: ClipOval(
                    child: Material(
                      color: Colors.white,
                      child: InkWell(
                        splashColor: Colors.grey[300]?.withOpacity(0.7),
                        splashFactory: InkRipple.splashFactory,
                        onTap: () => takePicture(),
                        child: const SizedBox(width: 56, height: 56),
                      ),
                    ),
                  ),
                ),
              ),
            )
          : Container(),
    );
  }
}
