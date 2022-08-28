import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ridbrain_project/screens/picture_full_screen.dart';

class PictureList extends StatelessWidget {
  final Function onAddImage;
  final Function(int) onDeleteImage;
  final List images;
  const PictureList(
      {Key? key,
      required this.images,
      required this.onAddImage,
      required this.onDeleteImage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        padding: EdgeInsets.symmetric(vertical: 10),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: images.length + 1,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
        itemBuilder: (context, int index) {
          if (index == images.length) {
            return InkWell(
              onTap: onAddImage as void Function(),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey,
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                    Text("Добавить", style: TextStyle(color: Colors.white),)
                  ],
                ),
              ),
            );
          } else {
            final img = images[index];
            return Stack(
              children: <Widget>[
                _image(context, img),
                Positioned(
                    right: -10,
                    top: -10,
                    child: IconButton(
                      padding: EdgeInsets.only(right: 2),
                        icon: Icon(
                          Icons.cancel,
                          color: Colors.red.withOpacity(0.5),
                          size: 20,
                        ),
                        onPressed: () => onDeleteImage(index)))
              ],
            );
          }
        });
  }

  Widget _image(context, String img) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => FullScreenPicture(
                  img: img,
                ))),
        child: CachedNetworkImage(imageUrl: img, fit: BoxFit.cover, height: 150,),
      ),
    );
  }
}
