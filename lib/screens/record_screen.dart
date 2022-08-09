import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridbrain_project/screens/weight_screen.dart';
import 'package:ridbrain_project/services/buttons.dart';
import 'package:ridbrain_project/services/constants.dart';
import 'package:ridbrain_project/services/convert_date.dart';
import 'package:ridbrain_project/services/extentions.dart';
import 'package:ridbrain_project/services/network.dart';
import 'package:ridbrain_project/services/objects.dart';
import 'package:ridbrain_project/services/prefs_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({
    Key? key,
    required this.record,
    required this.update,
  }) : super(key: key);

  final Record record;
  final Function(Record record) update;

  @override
  _RecordScreenState createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  late Record _record;
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

  void _confirmRecord(Driver driver) async {
    var status = RecordStatus(
      status: StatusRecord.taken,
      date: DateTime.now().secondsSinceEpoch(),
    );
    var history = widget.record.recordHistory;
    history.add(status);

    var result = await Network(context).confirmRecord(
      driver.driverToken,
      widget.record.recordId.toString(),
      jsonEncode(driver),
      jsonEncode(history),
    );

    if (result) {
      setState(() {
        _record.recordHistory = history;
        _record.recordStatus = StatusRecord.taken;
      });
      widget.update(_record);
    }
  }

  void _changeStatus(StatusRecord newStatus, String token) async {
    var status = RecordStatus(
      status: newStatus,
      date: DateTime.now().secondsSinceEpoch(),
    );
    var history = widget.record.recordHistory;
    history.add(status);

    var result = await Network.changeRecordStatus(
      token,
      _record.recordId.toString(),
      newStatus.name,
      jsonEncode(history),
    );

    if (result) {
      setState(() {
        _record.recordHistory = history;
        _record.recordStatus = newStatus;
      });
      widget.update(_record);
    }
  }

  Widget _button(String label, StatusRecord newStatus, String token) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: StandartButton(
        label: label,
        onTap: () => _changeStatus(newStatus, token),
      ),
    );
  }

  Widget _getButton(Driver driver) {
    switch (widget.record.recordStatus) {
      case StatusRecord.wait:
        return Padding(
          padding: const EdgeInsets.all(15),
          child: StandartButton(
            label: 'Принять заявку',
            onTap: () => _confirmRecord(driver),
          ),
        );
      case StatusRecord.set:
        return Padding(
          padding: const EdgeInsets.all(15),
          child: StandartButton(
            label: 'Принять заявку',
            onTap: () => _confirmRecord(driver),
          ),
        );
      case StatusRecord.taken:
        return _button(
          "На загрузке",
          StatusRecord.loading,
          driver.driverToken,
        );
      case StatusRecord.loading:
        return _button(
          "На выгрузке",
          StatusRecord.unloading,
          driver.driverToken,
        );
      case StatusRecord.unloading:
        return _button(
          "Выполнена",
          StatusRecord.done,
          driver.driverToken,
        );
      case StatusRecord.done:
        return const SizedBox.shrink();
      case StatusRecord.cancel:
        return const SizedBox.shrink();
    }
  }

  void _openMap(BuildContext context, double latitude, double longitude) async {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      await launch(
        "maps://?q=$latitude,$longitude",
      );
    } else {
      await launch(
        "geo:$latitude,$longitude",
      );
    }
  }

  @override
  void initState() {
    _getWeight();
    _record = widget.record;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.record.manager);
    var provider = Provider.of<DataProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Заявка',
                style: TextStyle(color: Colors.black),
              ),
              centerTitle: true,
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    _record.company.companyName,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: StandartButton(
                label: "Проложить маршрут",
                onTap: () => _openMap(
                  context,
                  _record.company.companyLocation.latitude,
                  _record.company.companyLocation.longitude,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 25,
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
              height: 25,
            ),
          ),
          SliverToBoxAdapter(
            child: _getButton(provider.driver),
          ),
          if (_record.recordStatus != StatusRecord.wait)
            SliverToBoxAdapter(
              child: StandartButton(
                label: "Отказаться от заяки",
                onTap: () => _changeStatus(
                  StatusRecord.wait,
                  provider.driver.driverToken,
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: radius,
              ),
              child: Column(
                children: [
                  Text(
                    _record.recordNote.isEmpty
                        ? "Без заметки"
                        : _record.recordNote,
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.only(
                  top: 0, left: 20, right: 20, bottom: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: radius,
              ),
              child: Column(
                children: [
                  Text(
                    _record.manager.isEmpty
                        ? "Менеджер не указан"
                        : _record.manager,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
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
              height: 25,
            ),
          ),
        ],
      ),
    );
  }
}
