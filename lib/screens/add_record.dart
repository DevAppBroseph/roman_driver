import 'dart:convert';

import 'package:animated_size_and_fade/animated_size_and_fade.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:ridbrain_project/services/app_bar.dart';
import 'package:ridbrain_project/services/buttons.dart';
import 'package:ridbrain_project/services/convert_date.dart';
import 'package:ridbrain_project/services/network.dart';
import 'package:ridbrain_project/services/objects.dart';
import 'package:ridbrain_project/services/picker.dart';
import 'package:ridbrain_project/services/prefs_handler.dart';
import 'package:ridbrain_project/services/snack_bar.dart';
import 'package:ridbrain_project/services/text_field.dart';

class AddRecordPage extends StatefulWidget {
  const AddRecordPage({
    Key? key,
    required this.succes,
  }) : super(key: key);

  final Function(AdminRecord record) succes;

  @override
  _AddRecordPageState createState() => _AddRecordPageState();
}

class _AddRecordPageState extends State<AddRecordPage> {
  final _dateController = TextEditingController();
  final _companyController = TextEditingController();
  final _noteController = TextEditingController();

  Company? _selectedCompany;
  List<Company> _companies = [];
  DateTime _selectedDate = DateTime.now().toLocal();

  void _search(String token, String text) async {
    var result = await Network(context).searchCompanies(token, text);

    if (result.isNotEmpty && mounted) {
      setState(() {
        _companies = result;
      });
    }
  }

  void _addRecord(String token) async {
    var name = Provider.of<DataProvider>(context, listen: false).admin.userName;
    if (_selectedCompany == null) {
      StandartSnackBar.show(
        context,
        "Укажите компанию",
        SnackBarStatus.warning(),
      );
      return;
    }

    var result = await Network(context).addRecord(
      token,
      ConvertDate(context).fromDateTime(_selectedDate).toString(),
      jsonEncode(_selectedCompany),
      jsonEncode(
        [
          RecordStatus(
            status: StatusRecord.wait,
            date: ConvertDate(context).fromDateTime(DateTime.now().toLocal()),
          ),
        ],
      ),
      _noteController.text,
      name,
    );

    if (result != null) {
      result.manager = name;
      widget.succes(result);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<DataProvider>(context);

    _dateController.text = ConvertDate(context).fromDate(
      _selectedDate,
      "dd.MM.yy",
    );

    if (_selectedCompany != null) {
      _companyController.text = _selectedCompany!.companyName;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: CustomScrollView(
          slivers: [
            StandartAppBar(
              title: Text("Новая заявка"),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: TextFieldWidget(
                  readOnly: true,
                  hint: "Дата",
                  icon: LineIcons.calendar,
                  controller: _dateController,
                  onTap: () => DatePicker(
                    onConfirm: (date) {
                      setState(() {
                        _selectedDate = date;
                      });
                    },
                    context: context,
                    yearBegin: 2022,
                    yearEnd: 2025,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: TextFieldWidget(
                  icon: LineIcons.addressCard,
                  hint: "Компания",
                  controller: _companyController,
                  onChanged: (value) {
                    _selectedCompany = null;
                    if (value.isNotEmpty) {
                      _search(provider.admin.token!, value);
                    } else {
                      if (_companies.isNotEmpty && mounted) {
                        setState(() {
                          _companies = [];
                        });
                      }
                    }
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: AnimatedSizeAndFade(
                child: SizedBox(
                  height: _companies.isEmpty ? 0 : 200,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(0),
                    itemCount: _companies.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_companies[index].companyName),
                        subtitle:
                            Text(_companies[index].companyLocation.address),
                        onTap: () {
                          setState(() {
                            _selectedCompany = _companies[index];
                            _companies = [];
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 15, 15, 30),
                child: TextFieldWidget(
                  icon: LineIcons.stickyNote,
                  controller: _noteController,
                  hint: "Заметка",
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: StandartButton(
                label: 'Сохранить',
                onTap: () => _addRecord(provider.admin.token!),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
