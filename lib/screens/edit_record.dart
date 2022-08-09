import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:ridbrain_project/screens/select_driver.dart';
import 'package:ridbrain_project/screens/weight_screen.dart';
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

  String? _weightId;

  void _getWeight() async {
    var provider = Provider.of<DataProvider>(context, listen: false);
    var result = await Network(context).getWeight(
      provider.user == User.driver
          ? provider.driver.driverToken
          : provider.admin.token!,
      widget.record.recordId.toString(),
      admin: provider.user == User.admin ? true : false,
    );

    if (result != null) {
      _weightId = result.weightId.toString();
    } else {
      _weightId = '';
    }
    setState(() {});
  }

  // final _companyController = TextEditingController();
  // final _addressController = TextEditingController();
  final _driverController = TextEditingController();
  final _noteController = TextEditingController();
  final _managerController = TextEditingController();

  Widget _getNoteButton(String token) {
    if (_record.recordStatus == StatusRecord.cancel ||
        _record.recordStatus == StatusRecord.done) {
      return const SizedBox.shrink();
    }
    return StandartButton(
      label: "Сохранить",
      onTap: () => _editRecord(token),
    );
  }

  Widget _getCancelButton(String token) {
    if (_record.recordStatus == StatusRecord.cancel ||
        _record.recordStatus == StatusRecord.done) {
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

  void _changeCash(String token, int cash) async {
    await Network.changeCash(
      token,
      _record.recordId.toString(),
      cash.toString(),
    );

    setState(() {
      _record.cash = cash;
    });
    widget.save(_record);
  }

  void _cancelRecord(String token) async {
    var status = RecordStatus(
      status: StatusRecord.cancel,
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
        _record.recordStatus = StatusRecord.cancel;
      });
      widget.save(_record);
    }
  }

  void _setDriver(String token, AdminDriver driver) async {
    var status = RecordStatus(
      status: StatusRecord.set,
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
        _record.recordStatus = StatusRecord.set;
      });
      widget.save(_record);
    }
  }

  void _editRecord(String token) async {
    _editRecordManager(token);
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

  void _editRecordManager(String token) async {
    var manager = _managerController.text;
    var result = await Network(context).editRecordManager(
      token,
      _record.recordId.toString(),
      manager,
    );

    if (result) {
      setState(() {
        _record.manager = manager;
      });
      widget.save(_record);
    }
  }

  void _changeDriver(String token) {
    if (_record.recordStatus == StatusRecord.cancel ||
        _record.recordStatus == StatusRecord.done) {
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
    _getWeight();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<DataProvider>(context);

    _driverController.text = _record.driver?.driverName ?? "Не назначен";
    _noteController.text = _record.recordNote;
    _managerController.text = _record.manager;

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
              child: Container(
                height: 55,
                margin: const EdgeInsets.fromLTRB(15, 10, 15, 0),
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: radius,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "₽ ₽ ₽",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                    CupertinoSwitch(
                      activeColor: Colors.blueGrey,
                      onChanged: (value) {
                        _changeCash(provider.admin.token!, value ? 1 : 0);
                      },
                      value: _record.cash == 1,
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
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                child: TextFieldWidget(
                  icon: LineIcons.user,
                  controller: _managerController,
                  hint: "Менеджер",
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(15, 10, 15, 0),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: radius,
                ),
                child: Center(
                  child: _weightId == null
                      ? CircularProgressIndicator.adaptive()
                      : Text(
                          _weightId != ''
                              ? 'ID отвеса: $_weightId'
                              : 'Отвес не добавлен',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 15)),
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
                            color: status.status.color,
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              status.status.label,
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
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: StandartButton(
                  label: 'Отвес',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WeightScreen(
                          orderId: widget.record.recordId,
                          company: widget.record.company,
                        ),
                      ),
                    );
                  },
                ),
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
            SliverToBoxAdapter(
              child: SizedBox(
                height: 25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
