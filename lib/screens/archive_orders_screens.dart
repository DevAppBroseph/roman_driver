import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridbrain_project/screens/record_cell.dart';
import 'package:ridbrain_project/screens/record_screen.dart';
import 'package:ridbrain_project/services/app_bar.dart';
import 'package:ridbrain_project/services/network.dart';
import 'package:ridbrain_project/services/objects.dart';
import 'package:ridbrain_project/services/prefs_handler.dart';

class ArchiveOrdersScreen extends StatefulWidget {
  const ArchiveOrdersScreen({Key? key}) : super(key: key);

  @override
  _ArchiveOrdersScreenState createState() => _ArchiveOrdersScreenState();
}

class _ArchiveOrdersScreenState extends State<ArchiveOrdersScreen> {
  List<Record> _records = [];
  bool _loading = true;
  bool _first = true;

  void _updateList(String token) async {
    setState(() {
      _loading = true;
    });

    var result = await Network.getArchiveRecords(token);

    if (mounted) {
      setState(() {
        _records = result.reversed.toList();
        _loading = false;
      });
    }
  }

  void _updateRecord(Record record) {
    var index = 0;
    for (var item in _records) {
      if (item.recordId == record.recordId) {
        setState(() {
          _records[index] = record;
        });
        break;
      }
      index++;
    }
  }

  Widget _getRecordList() {
    if (_loading) {
      return SliverToBoxAdapter(
        child: Container(
          height: 400,
          child: CupertinoActivityIndicator(),
        ),
      );
    }
    if (_records.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          height: 600,
          alignment: Alignment.center,
          child: Text(
            "Выполненных заявок нет",
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return RecordCell(
            record: _records[index],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecordScreen(
                    record: _records[index],
                    update: _updateRecord,
                  ),
                ),
              );
            },
          );
        },
        childCount: _records.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<DataProvider>(context);

    if (_first) {
      _updateList(provider.driver.driverToken);
      _first = false;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        triggerMode: RefreshIndicatorTriggerMode.anywhere,
        edgeOffset:
            MediaQuery.of(context).padding.top + AppBar().preferredSize.height,
        onRefresh: () async {
          _updateList(provider.driver.driverToken);
        },
        child: CustomScrollView(
          slivers: [
            StandartAppBar(
              title: Text("Выполненые заявки"),
            ),
            _getRecordList(),
          ],
        ),
      ),
    );
  }
}
