import 'dart:convert';

import 'package:animated_size_and_fade/animated_size_and_fade.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:ridbrain_project/services/app_bar.dart';
import 'package:ridbrain_project/services/buttons.dart';
import 'package:ridbrain_project/services/formatter.dart';
import 'package:ridbrain_project/services/network.dart';
import 'package:ridbrain_project/services/objects.dart';
import 'package:ridbrain_project/services/prefs_handler.dart';
import 'package:ridbrain_project/services/snack_bar.dart';
import 'package:ridbrain_project/services/text_field.dart';

class AddCompanyScreen extends StatefulWidget {
  AddCompanyScreen({
    Key? key,
    required this.success,
  }) : super(key: key);

  final Function(Company company) success;

  @override
  _AddCompanyScreenState createState() => _AddCompanyScreenState();
}

class _AddCompanyScreenState extends State<AddCompanyScreen> {
  List<Result> _predictions = [];
  CompanyLocation? _companyLocation;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addresController = TextEditingController();
  final _noteController = TextEditingController();
  final _webController = TextEditingController();

  void _autoCompleteSearch(String token, String value) async {
    var result = await Network(context).getPlaces(token, value);
    if (mounted) {
      setState(() {
        _predictions = result;
      });
    }
  }

  void _getDelails(Result place) async {
    setState(() {
      _companyLocation = CompanyLocation(
        address: place.formattedAddress,
        latitude: place.geometry.location.lat,
        longitude: place.geometry.location.lng,
      );
      _predictions = [];
    });
  }

  void _saveCompany(BuildContext context, String token) async {
    if (_nameController.text.isEmpty) {
      StandartSnackBar.show(
        context,
        "Заполните наименование",
        SnackBarStatus.warning(),
      );
      return;
    }
    if (_phoneController.text.isEmpty) {
      StandartSnackBar.show(
        context,
        "Заполните телефон",
        SnackBarStatus.warning(),
      );
      return;
    }
    if (_companyLocation == null) {
      StandartSnackBar.show(
        context,
        "Выберите адрес",
        SnackBarStatus.warning(),
      );
      return;
    }

    var result = await Network(context).addCompany(
      token,
      _nameController.text,
      _phoneController.text,
      jsonEncode(_companyLocation),
      _noteController.text,
      _webController.text,
    );

    if (result != null) {
      widget.success(result);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<DataProvider>(context);

    if (_companyLocation != null) {
      _addresController.text = _companyLocation!.address;
    }

    return Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
          slivers: [
            StandartAppBar(
              title: Text("Новая компания"),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextFieldWidget(
                      icon: LineIcons.addressCard,
                      controller: _nameController,
                      hint: "Наименование",
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    TextFieldWidget(
                      icon: LineIcons.phone,
                      controller: _phoneController,
                      formatter: [
                        MaskTextInputFormatter("+_ (___) ___-__-__"),
                        LengthLimitingTextInputFormatter(18),
                      ],
                      hint: "Телефон",
                      onTap: () {
                        if (_phoneController.text.length < 4) {
                          _phoneController.text = "+7 (";
                        }
                      },
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    TextFieldWidget(
                      icon: LineIcons.mapPin,
                      hint: "Адрес",
                      controller: _addresController,
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          _autoCompleteSearch(provider.admin.token!, value);
                          _companyLocation = null;
                        } else {
                          if (_predictions.isNotEmpty && mounted) {
                            setState(() {
                              _predictions = [];
                            });
                          }
                        }
                      },
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    AnimatedSizeAndFade(
                      child: _predictions.isNotEmpty
                          ? SizedBox(
                              height: 200,
                              child: ListView.builder(
                                padding: EdgeInsets.all(0),
                                itemCount: _predictions.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    leading: const CircleAvatar(
                                      radius: 15,
                                      backgroundColor: Colors.grey,
                                      child: Icon(
                                        Icons.pin_drop,
                                        color: Colors.white,
                                        size: 15,
                                      ),
                                    ),
                                    title: Text(
                                        _predictions[index].formattedAddress),
                                    onTap: () =>
                                        _getDelails(_predictions[index]),
                                  );
                                },
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFieldWidget(
                      icon: LineIcons.stickyNote,
                      controller: _noteController,
                      hint: "Заметка",
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    TextFieldWidget(
                      icon: LineIcons.globe,
                      controller: _webController,
                      hint: "E-Mail",
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: StandartButton(
                label: 'Сохранить',
                onTap: () => _saveCompany(context, provider.admin.token!),
              ),
            ),
          ],
        ));
  }
}
