
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class FullScreenPicture extends StatelessWidget {
  final String img;
  const FullScreenPicture({Key? key, required this.img}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Изображение"),
      //   centerTitle: false,
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      // ),
      body: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: img,
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
            alignment: Alignment.center,
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Row(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.grey.withOpacity(0.5),
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(15)),
                    child:  Icon(
                      Icons.adaptive.arrow_back,
                      // size: 30,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
