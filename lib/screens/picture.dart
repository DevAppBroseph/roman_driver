import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class PicturePage extends StatelessWidget {
  final XFile file;
  const PicturePage({Key? key, required this.file}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('Фото'),
        elevation: 0,
      ),
      body: Image.file(
        File(file.path),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context, file);
        },
        backgroundColor: Colors.white,
        child: Icon(
          Icons.done,
          color: Colors.black,
        ),
      ),
    );
  }
}
