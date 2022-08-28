import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ridbrain_project/main.dart';
import 'package:ridbrain_project/screens/picture.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  // double _minAvailableZoom = 1.0;
  // double _maxAvailableZoom = 1.0;
  // double _currentScale = 1.0;
  // double _baseScale = 1.0;
  // int _pointers = 0;
  XFile? picture;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    checkCameraPermission();
    _controller = CameraController(
      cameras[0],
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    _initializeControllerFuture = _controller.initialize();
    _controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
  }

  void checkCameraPermission() async {
    var status = await Permission.camera.status;
    if (status.isDenied) {
      await Permission.camera.request();
    } else if (status.isPermanentlyDenied) {
      showSimpleNotification(Text("Необходимо разрешить доступ к камере."),
          autoDismiss: false,
          slideDismissDirection: DismissDirection.up,
          trailing: TextButton(
              onPressed: () => openAppSettings(),
              child: Text("Перейти в настройки")),
          background: Colors.white);
    }
  }

  void initCamera() {
    _initializeControllerFuture = _controller.initialize();
    // _controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
    // _controller
    //     .getMaxZoomLevel()
    //     .then((double value) => _maxAvailableZoom = value);
    // _controller
    //     .getMinZoomLevel()
    // .then((double value) => _minAvailableZoom = value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return picture != null
        ? PicturePage(
            file: picture!,
            onRecaptureImage: () => setState(() {
              picture = null;
            }),
          )
        : Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              child: FutureBuilder(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Stack(
                      children: [
                        _cameraPreview(),
                        _snapButton(context),
                        _appMenu()
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          );
  }

  Widget _appMenu() {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.cancel,
              size: 40,
              color: Colors.white,
            )),
      ),
    );
  }

  Widget _cameraPreview() {
    print("AspectRation: ${_controller.value.aspectRatio}");
    return Align(
      alignment: Alignment.topCenter,
      child: RotatedBox(
        quarterTurns:
            MediaQuery.of(context).orientation == Orientation.landscape ? 3 : 0,
        child: AspectRatio(
          aspectRatio: 1 / _controller.value.aspectRatio,
          // child: _controller.buildPreview(),
          child: CameraPreview(
            _controller,
          ),
        ),
      ),
    );
  }

  Widget _snapButton(context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: Colors.black54,
        width: double.infinity,
        child: GestureDetector(
          onTap: () async {
            try {
              final pic = await _controller.takePicture();
              final path = join(
                (await getTemporaryDirectory()).path,
                '${DateTime.now()}.png',
              );
              pic.saveTo(path);
              print(pic.path);
              setState(() {
                picture = pic;
              });
            } catch (e) {
              print("ERROR: $e");
            }
          },
          child: SizedBox(
            height: 70,
            child: Align(
              alignment: Alignment.center,
              child: Icon(
                Icons.camera,
                color: Colors.white,
                size: 70,
              ),
            ),
          ),
        ),
      ),
    );
  }

  ///#ZOOM functions#

  // void _handleScaleStart(ScaleStartDetails details) {
  //   _baseScale = _currentScale;
  // }

  // Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
  //   // When there are not exactly two fingers on screen don't scale
  //   if (_controller == null || _pointers != 2) {
  //     return;
  //   }

  //   _currentScale = (_baseScale * details.scale)
  //       .clamp(_minAvailableZoom, _maxAvailableZoom);

  //   await _controller!.setZoomLevel(_currentScale);
  // }

  // void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
  //   if (_controller == null) {
  //     return;
  //   }

  //   final CameraController cameraController = _controller;

  //   final Offset offset = Offset(
  //     details.localPosition.dx / constraints.maxWidth,
  //     details.localPosition.dy / constraints.maxHeight,
  //   );
  //   cameraController.setExposurePoint(offset);
  //   cameraController.setFocusPoint(offset);
  // }
}
