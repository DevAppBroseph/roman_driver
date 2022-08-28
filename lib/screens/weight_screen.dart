import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:ridbrain_project/screens/camera.dart';
import 'package:ridbrain_project/screens/pick_nomenclature.dart';
import 'package:ridbrain_project/screens/picture_list.dart';
import 'package:ridbrain_project/services/buttons.dart';
import 'package:ridbrain_project/services/constants.dart';
import 'package:ridbrain_project/services/network.dart';
import 'package:ridbrain_project/services/objects.dart';
import 'package:ridbrain_project/services/prefs_handler.dart';
import 'package:ridbrain_project/services/snack_bar.dart';
import 'package:ridbrain_project/services/text_field.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class WeightScreen extends StatefulWidget {
  final int orderId;
  final Company company;
  const WeightScreen({
    Key? key,
    required this.orderId,
    required this.company,
  }) : super(key: key);

  @override
  State<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {
  Reference ref = FirebaseStorage.instance.ref().child('weight_img');

  List _images = [];
  List<DriverNomenclature> _addedNomenclatures = [
    DriverNomenclature(
        nomenclature: null, botling: null, tare: null, net: null, img: null)
  ];
  var _commentController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    print(widget.orderId);
    _getWeight();
    super.initState();
  }

  void _editWeight() async {
    // if (_addedNomenclatures.last.nomenclature != null) {
    var provider = Provider.of<DataProvider>(context, listen: false);
    var result = await Network(context).editWeight(
        provider.driver.driverToken,
        widget.orderId,
        _addedNomenclatures,
        _commentController.text,
        widget.company,
        provider.driver.driverName,
        _images);
    if (result != null) {}
    // }
  }

  void _getWeight() async {
    setState(() => _loading = true);
    var provider = Provider.of<DataProvider>(context, listen: false);
    var result = await Network(context).getWeight(
      provider.user == User.driver
          ? provider.driver.driverToken
          : provider.admin.token!,
      widget.orderId.toString(),
      admin: provider.user == User.admin ? true : false,
    );
    if (result != null) {
      setState(() {
        if (result.weight.isNotEmpty) {
          _addedNomenclatures = result.weight;
        }
        _commentController.text = result.comment;
        _images = result.images ?? [];
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> pickImagesFromGallery() async {
    final List<AssetEntity>? pickedImages = await AssetPicker.pickAssets(
      context,
    );
    if (pickedImages != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Пожалуйста подождите... Загружаем выбранные фото")));
      for (var img in pickedImages) {
        final file = await img.originFile;
        final imgRef =
            ref.child("order_id${widget.orderId}img${img.createDateTime}");
        await ref.putFile(file!);

        var dowurl = await imgRef.getDownloadURL();
        final url = dowurl.toString();

        _images.add(url);
      }
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
    setState(() {});
  }

  void takePicture() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => CameraPage(),
      ),
    ).then((value) async {
      if (value != null && value is XFile) {
        await ref
            .child("order_id${widget.orderId}img${value.name}")
            .putFile(File(value.path));
        String imageUrl = await ref.getDownloadURL();
        _images.add(imageUrl);
        setState(() {});
      }
    });
  }

  void addVariationSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    pickImagesFromGallery();
                  },
                  leading: Icon(Icons.image),
                  title: Text("Выбрать из галереи"),
                ),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    takePicture();
                  },
                  leading: Icon(Icons.camera_alt_outlined),
                  title: Text("Сделать снимок"),
                ),
                const SizedBox(
                  height: 40,
                )
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         fullscreenDialog: true,
      //         builder: (context) => CameraPage(),
      //       ),
      //     ).then((value) async {
      //       if (value != null && value is XFile) {
      //         setState(() {});
      //       }
      //     });
      //     ///////
      //     // showModalBottomSheet(
      //     //   context: context,
      //     //   backgroundColor: Colors.transparent,
      //     //   builder: (context) => Container(
      //     //     height: 200,
      //     //     decoration: BoxDecoration(
      //     //       color: Colors.white,
      //     //       borderRadius: BorderRadius.only(
      //     //         topLeft: Radius.circular(15),
      //     //         topRight: Radius.circular(15),
      //     //       ),
      //     //     ),
      //     //     child: Row(
      //     //       children: [
      //     //         Expanded(
      //     //             flex: 1,
      //     //             child: Center(
      //     //               child: Column(
      //     //                 children: [
      //     //                   IconButton(
      //     //                     onPressed: () {},
      //     //                     icon: Icon(
      //     //                       Icons.camera_alt_rounded,
      //     //                     ),
      //     //                   ),
      //     //                 ],
      //     //               ),
      //     //             )),
      //     //         Expanded(
      //     //             flex: 1,
      //     //             child: Column(
      //     //               children: [
      //     //                 IconButton(
      //     //                   onPressed: () {},
      //     //                   icon: Icon(
      //     //                     Icons.camera_alt_rounded,
      //     //                   ),
      //     //                 ),
      //     //               ],
      //     //             )),
      //     //       ],
      //     //     ),
      //     //   ),
      //     // );
      //   },
      //   backgroundColor: Colors.grey[700],
      //   child: Icon(
      //     Icons.camera_alt_rounded,
      //     color: Colors.white,
      //   ),
      // ),
      body: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: CustomScrollView(
          slivers: [
            const SliverAppBar(
              pinned: true,
              backgroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Отвес',
                  style: TextStyle(color: Colors.black),
                ),
                centerTitle: true,
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 25)),
            if (!_loading)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _nomenclatureWidget(index, context),
                  childCount: _addedNomenclatures.length,
                ),
              ),
            if (!_loading)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: StandartButton(
                    label: 'Добавить номенклатуру',
                    onTap: () {
                      if (_addedNomenclatures.last.nomenclature != null &&
                          _addedNomenclatures.last.tare != null) {
                        _editWeight();
                        setState(() {
                          _addedNomenclatures.add(
                            DriverNomenclature(
                                nomenclature: null,
                                botling: null,
                                tare: null,
                                net: null),
                          );
                        });
                      } else {
                        StandartSnackBar.show(
                          context,
                          'Чтобы добавить номенклатуру, необходимо заполнить предыдущую.',
                          SnackBarStatus.warning(),
                        );
                      }
                    },
                  ),
                ),
              ),
            if (!_loading)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(left: 15, top: 40, bottom: 5),
                  child: Text(
                    'Поле для заметки',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            if (!_loading)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.only(left: 15, right: 15),
                  child: TextFieldWidget(
                    hint: 'Заметка',
                    onChanged: (text) {},
                    type: TextInputType.text,
                    controller: _commentController,
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 15, top: 40, bottom: 5),
                child: Text(
                  'Изображение',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                  margin: const EdgeInsets.only(left: 15, right: 15),
                  child: PictureList(
                    onAddImage: () => addVariationSheet(context),
                    onDeleteImage: (p01) {
                      setState(() {
                        _images.removeAt(p01);
                      });
                    },
                    images: _images,
                  )),
            ),
            if (!_loading)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: StandartButton(
                    label: 'Сохранить',
                    onTap: () {
                      _editWeight();
                    },
                  ),
                ),
              ),
            SliverToBoxAdapter(child: SizedBox(height: 35)),
          ],
        ),
      ),
    );
  }

  Widget _nomenclatureWidget(int index, BuildContext context) {
    TextEditingController _butController = TextEditingController();
    if (_addedNomenclatures.length > 1 &&
        _addedNomenclatures.last == _addedNomenclatures[index]) {
      if (_addedNomenclatures[_addedNomenclatures.length - 2].tare != null) {
        _butController.text =
            _addedNomenclatures[_addedNomenclatures.length - 2].tare.toString();
        _addedNomenclatures[index].botling =
            _addedNomenclatures[_addedNomenclatures.length - 2].tare;
      } else {
        _butController.text = '';
      }
    } else {
      if (index > 0) {
        if (_addedNomenclatures[index - 1].tare != null) {
          _butController.text = _addedNomenclatures[index - 1].tare.toString();
          _addedNomenclatures[index].botling =
              _addedNomenclatures[index - 1].tare;
        } else
          _butController.text = '';
      } else {
        if (_addedNomenclatures[index].botling != null) {
          _butController.text = _addedNomenclatures[index].botling.toString();
          _addedNomenclatures[index].botling =
              _addedNomenclatures[index].botling;
        } else {
          if (_addedNomenclatures[index].net != null &&
              _addedNomenclatures[index].tare != null) {
            _butController.text = (_addedNomenclatures[index].net! +
                    _addedNomenclatures[index].tare!)
                .toString();
            _addedNomenclatures[index].botling =
                _addedNomenclatures[index].net! +
                    _addedNomenclatures[index].tare!;
          } else {
            _butController.text = '';
          }
        }
      }
    }
    // TextEditingController _butController = TextEditingController(
    //   text: _addedNomenclatures.length > 1 &&
    //           _addedNomenclatures.last == _addedNomenclatures[index]
    //       ? _addedNomenclatures[_addedNomenclatures.length - 2].tare != null
    //           ? _addedNomenclatures[_addedNomenclatures.length - 2]
    //               .tare
    //               .toString()
    //           : ''
    //       : index > 0
    //           ? _addedNomenclatures[index - 1].tare != null
    //               ? _addedNomenclatures[index - 1].tare.toString()
    //               : ''
    //           : _addedNomenclatures[index].botling != null
    //               ? _addedNomenclatures[index].botling.toString()
    //               : _addedNomenclatures[index].net != null &&
    //                       _addedNomenclatures[index].tare != null
    //                   ? (_addedNomenclatures[index].net! +
    //                           _addedNomenclatures[index].tare!)
    //                       .toString()
    //                   : '',
    // );
    TextEditingController _tarController = TextEditingController(
      text: _addedNomenclatures[index].tare != null
          ? _addedNomenclatures[index].tare.toString()
          : '',
    );

    // if (_addedNomenclatures.length > 2) {
    //   _butController.text = _addedNomenclatures[index - 1] != null
    //       ? _addedNomenclatures[index - 1]!.tare.toString()
    //       : '';
    // }

    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        setState(() {
          _addedNomenclatures.removeAt(index);
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: radius,
        ),
        margin: EdgeInsets.only(right: 15, left: 15, bottom: 15),
        child: Column(
          children: [
            if (_addedNomenclatures[index].nomenclature?.name == null)
              Padding(
                padding: EdgeInsets.only(top: 15, left: 15, right: 15),
                child: StandartButton(
                  label: _addedNomenclatures[index].nomenclature?.name ??
                      'Номенклатура',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PickNomenclatureScreen(),
                      ),
                    ).then((value) {
                      if (value is Nomenclature) {
                        setState(() {
                          _addedNomenclatures[index].nomenclature = value;
                        });
                      }
                    });
                  },
                ),
              ),
            if (_addedNomenclatures[index].nomenclature?.name != null)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PickNomenclatureScreen(),
                    ),
                  ).then((value) {
                    if (value is Nomenclature) {
                      setState(() {
                        _addedNomenclatures[index].nomenclature = value;
                      });
                    }
                  });
                },
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 15,
                    right: 15,
                    top: 15,
                  ),
                  child: Text(
                    _addedNomenclatures[index].nomenclature!.name,
                    textAlign: TextAlign.start,
                  ),
                ),
              ),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 15, bottom: 5, left: 15),
                        child: Text('Бутирование'),
                      ),
                      Container(
                        height: 45,
                        margin: EdgeInsets.only(bottom: 15, right: 5, left: 15),
                        child: Stack(
                          children: [
                            TextFieldWidget(
                              onChanged: (value) {
                                _addedNomenclatures[index].botling =
                                    int.parse(value);
                                // setState(() {});
                              },
                              hint: '',
                              type: TextInputType.phone,
                              controller: _butController,
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  bottom: 5,
                                  right: 5,
                                ),
                                child: Text(
                                  'кг',
                                  style: TextStyle(color: Colors.grey[500]),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 15, bottom: 5, left: 15),
                        child: Text('Тарирование'),
                      ),
                      Container(
                        height: 45,
                        margin:
                            EdgeInsets.only(bottom: 15, right: 15, left: 15),
                        child: Stack(
                          children: [
                            TextFieldWidget(
                              hint: '',
                              onChanged: (text) {
                                // setState(() {
                                _addedNomenclatures[index].tare =
                                    int.parse(text);
                                _addedNomenclatures[index].net =
                                    int.parse(_butController.text) -
                                        int.parse(text);
                                // });
                              },
                              type: TextInputType.phone,
                              controller: _tarController,
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  bottom: 5,
                                  right: 5,
                                ),
                                child: Text(
                                  'кг',
                                  style: TextStyle(color: Colors.grey[500]),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () {
                      _editWeight();
                      setState(() {});
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Text('Нетто'),
                        ),
                        Container(
                          margin: EdgeInsets.only(right: 15),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.05),
                            borderRadius: radius,
                          ),
                          height: 45,
                          child: Stack(
                            children: [
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: Text(
                                    _addedNomenclatures[index].net != null
                                        ? _addedNomenclatures[index]
                                            .net
                                            .toString()
                                        : '',
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    bottom: 5,
                                    right: 5,
                                  ),
                                  child: Text(
                                    'кг',
                                    style: TextStyle(color: Colors.grey[500]),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
