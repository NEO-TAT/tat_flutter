import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_app/src/store/picture_storage.dart';

class NoteCamera extends StatefulWidget {
  final String courseId;

  const NoteCamera({super.key, required this.courseId});

  @override
  State<NoteCamera> createState() => _NoteCameraState();
}

class _NoteCameraState extends State<NoteCamera> with WidgetsBindingObserver {
  CameraController? controller;
  bool _isCameraInitialized = false;
  List<CameraDescription> cameras = const [];
  final PictureStorage _pictureStorage;

  double _zoom = 1.0;

  XFile? image;

  final _isPressShutter = false.obs;

  _NoteCameraState() : _pictureStorage = PictureStorage();

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

  void _pressShutter() async{
    image = await controller?.takePicture();
    controller?.pausePreview();
    _isPressShutter.toggle();
  }

  void _deletePicture(){
    String? path = image?.path;
    if (path != null) {
      final imgFile = File(path);
      imgFile.delete();
    }
    _backToCamera();
  }

  void _takePicture() async {
    String? path = image?.path;
    if (path != null) {
      _pictureStorage.takePictureToStorage(widget.courseId, path);
    }
    _backToCamera();
  }

  void _backToCamera(){
    controller?.resumePreview();
    _isPressShutter.toggle();
  }

  void _adjustZoom(scaleStartDetails) {
    double newZoom = 0.0;
    if (scaleStartDetails.scale > 1.0) {
      newZoom = _zoom + 0.01;
    } else if (scaleStartDetails.scale < 1.0) {
      newZoom = _zoom - 0.01;
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
      onScaleUpdate: (scaleStartDetails) => _adjustZoom(scaleStartDetails),
      child: _isCameraInitialized
          ? CameraPreview(
              controller!,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Obx(
                    () => _isPressShutter.isFalse
                        ? ClipOval(
                            child: Material(
                              color: Colors.white,
                              child: InkWell(
                                splashColor: Colors.grey[300]?.withOpacity(0.7),
                                splashFactory: InkRipple.splashFactory,
                                onTap: () => _pressShutter(),
                                child: const SizedBox(width: 56, height: 56),
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _takePicture(),
                                  child: const Text('save'),
                                ),
                              ),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _deletePicture(),
                                  child: const Text('not save'),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
