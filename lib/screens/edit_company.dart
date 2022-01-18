import 'dart:convert';

import 'package:animated_size_and_fade/animated_size_and_fade.dart';
import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:ridbrain_project/screens/select_driver.dart';
import 'package:ridbrain_project/services/app_bar.dart';
import 'package:ridbrain_project/services/buttons.dart';
import 'package:ridbrain_project/services/constants.dart';
import 'package:ridbrain_project/services/convert_date.dart';
import 'package:ridbrain_project/services/extentions.dart';
import 'package:ridbrain_project/services/network.dart';
import 'package:ridbrain_project/services/objects.dart';
import 'package:ridbrain_project/services/prefs_handler.dart';
import 'package:ridbrain_project/services/snack_bar.dart';
import 'package:ridbrain_project/services/text_field.dart';

class EditCompanyPage extends StatefulWidget {
  const EditCompanyPage({
    Key? key,
    required this.company,
    required this.save,
  }) : super(key: key);

  final Company company;
  final Function(Company record) save;

  @override
  _EditCompanyPageState createState() => _EditCompanyPageState();
}

class _EditCompanyPageState extends State<EditCompanyPage> {
  late Company _company;

  final _companyController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _noteController = TextEditingController();
  final _emailController = TextEditingController();

  final GooglePlace _googlePlace = GooglePlace(
    "AIzaSyALQnGInxCs7qV-ATtbEnI61oJTAUTGWh0",
  );
  List<AutocompletePrediction> _predictions = [];
  CompanyLocation? _companyLocation;

  @override
  void initState() {
    super.initState();
    _company = widget.company;

    _companyLocation = widget.company.companyLocation;
    _companyController.text = _company.companyName;
    _addressController.text = _company.companyLocation.address;
    _phoneController.text = _company.companyPhone;
    _addressController.text = _company.companyLocation.address;
    _noteController.text = _company.companyNote;
    _emailController.text = _company.companyWeb;
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<DataProvider>(context);

    void _autoCompleteSearch(String value) async {
      var result =
          await _googlePlace.autocomplete.get(value, language: "ru_RU");
      if (result != null && result.predictions != null && mounted) {
        setState(() {
          _predictions = result.predictions ?? [];
        });
      }
    }

    void _getDelails(String place) async {
      var result = await _googlePlace.details.get(place, language: "ru_RU");
      var adr = result?.result;

      if (adr != null) {
        setState(() {
          _companyLocation = CompanyLocation(
            address: adr.formattedAddress!,
            latitude: adr.geometry!.location!.lat!,
            longitude: adr.geometry!.location!.lng!,
          );
          _predictions = [];
        });
      }
    }

    void _saveCompany(String token) async {
      if (_companyController.text.isEmpty) {
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

      var result = await Network(context).editCompany(
        token,
        widget.company.companyId.toString(),
        _companyController.text,
        _phoneController.text,
        jsonEncode(_companyLocation),
        _noteController.text,
        _emailController.text,
      );

      if (result != null) {
        widget.save(result);
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: CustomScrollView(
          slivers: [
            StandartAppBar(
              title: Text("Компания"),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: TextFieldWidget(
                    hint: "Указать имя компании",
                    icon: LineIcons.addressCard,
                    controller: _companyController,
                    onTap: () {}
                    // _changeDriver(provider.admin.token!),
                    ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                child: TextFieldWidget(
                    hint: "Указать номер компании",
                    icon: LineIcons.phone,
                    controller: _phoneController,
                    onTap: () {}
                    // _changeDriver(provider.admin.token!),
                    ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                child: TextFieldWidget(
                    hint: "Указать адрес компании",
                    icon: LineIcons.mapPin,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        _autoCompleteSearch(value);
                        _companyLocation = null;
                      } else {
                        if (_predictions.isNotEmpty && mounted) {
                          setState(() {
                            _predictions = [];
                          });
                        }
                      }
                    },
                    controller: _addressController,
                    onTap: () {}
                    // _changeDriver(provider.admin.token!),
                    ),
              ),
            ),
            SliverToBoxAdapter(
              child: AnimatedSizeAndFade(
                child: _predictions.isNotEmpty
                    ? SizedBox(
                        height: 200,
                        child: ListView.builder(
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
                              title:
                                  Text(_predictions[index].description ?? ""),
                              onTap: () {
                                _getDelails(_predictions[index].placeId!);
                              },
                            );
                          },
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                child: TextFieldWidget(
                  icon: LineIcons.stickyNote,
                  controller: _noteController,
                  hint: "Заметка",
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                child: TextFieldWidget(
                  icon: LineIcons.globe,
                  controller: _emailController,
                  hint: "E-Mail",
                ),
              ),
            ),
            // SliverToBoxAdapter(
            //   child: _getNoteButton(provider.admin.token!),
            // ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 15,
              ),
            ),
            SliverToBoxAdapter(
              child: StandartButton(
                label: 'Сохранить',
                onTap: () => _saveCompany(provider.admin.token!),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
