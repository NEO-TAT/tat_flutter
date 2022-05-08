// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.16

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class NoteCamera extends StatefulWidget {
  const NoteCamera({Key? key}) : super(key: key);

  @override
  State<NoteCamera> createState() => _NoteCameraState();
}

class _NoteCameraState extends State<NoteCamera> with WidgetsBindingObserver {
  CameraController? controller;
  bool _isCameraInitialized = false;
  late List<CameraDescription> cameras;

  double _zoom = 1.0;

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
      print('Error initializing camera: $e');
    }

    if (mounted) {
      setState(() {
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    cameras = Get.find<List<CameraDescription>>();
    onNewCameraSelected(cameras[0]);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

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
    return Scaffold(
      body: Column(
        children: [
          _isCameraInitialized
              ? CameraPreview(controller!,
            child: GestureDetector(
              onScaleUpdate: (scaleStartDetails) {
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
              },
            ),
          )
              : Container(),
          Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                border: Border.all(
                  color: Colors.white,
                  width: 3.0,
                ),
              ),
              padding: const EdgeInsets.all(1.0),
              child: ClipOval(
                child: Material(
                  color: Colors.white,
                  child: InkWell(
                    splashColor: Colors.grey[300]?.withOpacity(0.7),
                    splashFactory: InkRipple.splashFactory,
                    onTap: () {},
                    child: const SizedBox(width: 56, height: 56),
                  ),
                ),
              )),
        ],
      )
    );
  }
}
