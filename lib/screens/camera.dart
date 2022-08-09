import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:ridbrain_project/main.dart';
import 'package:ridbrain_project/screens/picture.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController controller;

  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            print('User denied camera access.');
            break;
          default:
            print('Handle other errors.');
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        color: Colors.black,
      );
    }
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('Камера'),
        elevation: 0,
      ),
      body: CameraPreview(
        controller,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: Colors.black,
            height: 100,
            width: double.infinity,
            child: GestureDetector(
              onTap: () async {
                var picture = await controller.takePicture();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PicturePage(file: picture),
                  ),
                ).then((value) {
                  if (value != null) {
                    Navigator.pop(context, value);
                  }
                });
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
        ),
      ),
    );
  }
}
