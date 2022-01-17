import 'dart:convert';

import 'package:flutter/material.dart';
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
import 'package:ridbrain_project/services/text_field.dart';

class EditRecordPage extends StatefulWidget {
  const EditRecordPage({
    Key? key,
    required this.record,
    required this.save,
  }) : super(key: key);

  final AdminRecord record;
  final Function(AdminRecord record) save;

  @override
  _EditRecordPageState createState() => _EditRecordPageState();
}

class _EditRecordPageState extends State<EditRecordPage> {
  late AdminRecord _record;

  final _companyController = TextEditingController();
  final _addressController = TextEditingController();
  final _driverController = TextEditingController();
  final _noteController = TextEditingController();

  Widget _getNoteButton(String token) {
    if (_record.recordStatus == StatusRecord.six ||
        _record.recordStatus == StatusRecord.five) {
      return const SizedBox.shrink();
    }
    return StandartButton(
      label: "Сохранить",
      onTap: () => _editRecordNote(token),
    );
  }

  Widget _getCancelButton(String token) {
    if (_record.recordStatus == StatusRecord.six ||
        _record.recordStatus == StatusRecord.five) {
      return const SizedBox.shrink();
    }
    return StandartButton(
      label: "Отменить",
      onTap: () => _dialogCancelRecord(token),
    );
  }

  void _dialogCancelRecord(String token) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Отменить заявку?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _cancelRecord(token);
              },
              child: const Text("Да"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Нет"),
            ),
          ],
        );
      },
    );
  }

  void _cancelRecord(String token) async {
    var status = RecordStatus(
      status: StatusRecord.six,
      date: DateTime.now().secondsSinceEpoch(),
    );
    var history = _record.recordHistory;
    history.add(status);

    var result = await Network(context).cancelRecord(
      token,
      _record.recordId.toString(),
      jsonEncode(history),
    );

    if (result) {
      setState(() {
        _record.recordHistory = history;
        _record.recordStatus = StatusRecord.six;
      });
      widget.save(_record);
    }
  }

  void _setDriver(String token, AdminDriver driver) async {
    var status = RecordStatus(
      status: StatusRecord.two,
      date: DateTime.now().secondsSinceEpoch(),
    );
    var history = _record.recordHistory;
    history.add(status);

    var result = await Network(context).setDriver(
      token,
      _record.recordId.toString(),
      jsonEncode(driver),
      jsonEncode(history),
    );

    if (result) {
      setState(() {
        _record.driver = driver;
        _record.recordHistory = history;
        _record.recordStatus = StatusRecord.two;
      });
      widget.save(_record);
    }
  }

  void _editRecordNote(String token) async {
    var note = _noteController.text;
    var result = await Network(context).editRecordNote(
      token,
      _record.recordId.toString(),
      note,
    );

    if (result) {
      setState(() {
        _record.recordNote = note;
      });
      widget.save(_record);
    }
  }

  void _changeDriver(String token) {
    if (_record.recordStatus == StatusRecord.six ||
        _record.recordStatus == StatusRecord.five) {
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => SelectDriver(
          onSelcet: (driver) => _setDriver(token, driver),
        ),
      ),
    );
  }

  @override
  void initState() {
    _record = widget.record;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<DataProvider>(context);

    _driverController.text = _record.driver?.driverName ?? "Не назначен";
    _noteController.text = _record.recordNote;

    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: CustomScrollView(
          slivers: [
            StandartAppBar(
              title: Text("Заявка"),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 90,
                margin: const EdgeInsets.fromLTRB(15, 10, 15, 0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: radius,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      _record.company.companyName,
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      _record.company.companyLocation.address,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: TextFieldWidget(
                  readOnly: true,
                  hint: "Указать водителя",
                  icon: LineIcons.car,
                  controller: _driverController,
                  onTap: () => _changeDriver(provider.admin.token!),
                ),
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
              child: _getNoteButton(provider.admin.token!),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 15,
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  var status = _record.recordHistory[index];
                  return SizedBox(
                    height: 60,
                    child: Row(
                      children: [
                        Container(
                          width: 15,
                          height: 15,
                          margin: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: status.getColor(),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              status.getLabel(),
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            Text(
                              ConvertDate(context).fromUnix(
                                status.date,
                                "dd.MM.yyyy HH:mm",
                              ),
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
                childCount: _record.recordHistory.length,
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 15,
              ),
            ),
            SliverToBoxAdapter(
              child: _getCancelButton(provider.admin.token!),
            ),
          ],
        ),
      ),
    );
  }
}
