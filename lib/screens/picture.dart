import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class PicturePage extends StatelessWidget {
  final XFile file;
  final Function? onRecaptureImage;
  const PicturePage({Key? key, required this.file, this.onRecaptureImage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Image.file(
        File(file.path),
        fit: BoxFit.fitHeight,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            color: Colors.transparent, borderRadius: BorderRadius.circular(10)),
        height: 80,
        margin: EdgeInsets.only(bottom: 50, left: 15, right: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: InkWell(
                onTap: onRecaptureImage as void Function()?,
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.refresh, color: Colors.white),
                      Text("Переснять", style: TextStyle(color: Colors.white))
                    ],
                  ),
                ),
              ),
            ),
            Spacer(),
            Expanded(
              child: InkWell(
                onTap: () => Navigator.pop(context, file),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.done, color: Colors.white),
                      Text("Использовать",
                          style: TextStyle(color: Colors.white))
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.pop(context, file);
      //   },
      //   backgroundColor: Colors.white,
      //   child: Icon(
      //     Icons.done,
      //     color: Colors.black,
      //   ),
      // ),
    );
  }
}
