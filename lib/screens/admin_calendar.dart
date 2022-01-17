import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:ridbrain_project/screens/add_record.dart';
import 'package:ridbrain_project/screens/admin_record_cell.dart';
import 'package:ridbrain_project/screens/edit_record.dart';
import 'package:ridbrain_project/services/app_bar.dart';
import 'package:ridbrain_project/services/convert_date.dart';
import 'package:ridbrain_project/services/extentions.dart';
import 'package:ridbrain_project/services/network.dart';
import 'package:ridbrain_project/services/objects.dart';
import 'package:table_calendar/table_calendar.dart';

import '../services/prefs_handler.dart';

class AdminCalendar extends StatefulWidget {
  const AdminCalendar({Key? key}) : super(key: key);

  @override
  _AdminCalendarState createState() => _AdminCalendarState();
}

class _AdminCalendarState extends State<AdminCalendar> {
  static final _today = ConvertDate.dayBegin();
  static final _firstDay = DateTime(_today.year, _today.month - 1, _today.day);
  static final _lastDay = DateTime(_today.year, _today.month + 3, _today.day);

  DateTime _focusedDay = _today;
  DateTime _selectedDay = _today;

  List<AdminRecord> _records = [];
  bool _loading = true;
  bool _first = true;

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    var select = selectedDay.toLocal().add(
          Duration(
            hours: -selectedDay.toLocal().hour,
            minutes: -selectedDay.toLocal().minute,
          ),
        );
    var focused = focusedDay.toLocal().add(
          Duration(
            hours: -focusedDay.toLocal().hour,
            minutes: -focusedDay.toLocal().minute,
          ),
        );

    if (!isSameDay(_selectedDay, select)) {
      setState(() {
        _selectedDay = select;
        _focusedDay = focused;
      });
    }
  }

  void _updateList(String token) async {
    setState(() {
      _loading = true;
    });

    var result = await Network.getAdminRecords(token);

    if (mounted) {
      setState(() {
        _records = result;
        _loading = false;
      });
    }
  }

  void _updateRecord(AdminRecord record) {
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
    if (_records.forDate(_selectedDay).isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          height: 400,
          alignment: Alignment.center,
          child: Text(
            "Заявок в этот день нет",
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
          var record = _records.forDate(_selectedDay)[index];
          return AdminRecordCell(
            record: record,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditRecordPage(
                  record: record,
                  save: _updateRecord,
                ),
              ),
            ),
          );
        },
        childCount: _records.forDate(_selectedDay).length,
      ),
    );
  }

  @override
  void initState() {
    initializeDateFormatting();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<DataProvider>(context);

    if (_first) {
      _updateList(provider.admin.token!);
      _first = false;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey[800],
        child: Icon(
          LineIcons.plus,
          color: Colors.white,
        ),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddRecordPage(
              succes: (record) {
                setState(() {
                  _records.add(record);
                });
              },
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        triggerMode: RefreshIndicatorTriggerMode.anywhere,
        edgeOffset:
            MediaQuery.of(context).padding.top + AppBar().preferredSize.height,
        onRefresh: () async {
          _updateList(provider.admin.token!);
        },
        child: CustomScrollView(
          slivers: [
            StandartAppBar(
              title: Text("Календарь"),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.only(top: 5),
                child: TableCalendar<AdminRecord>(
                  locale: "ru",
                  firstDay: _firstDay,
                  lastDay: _lastDay,
                  headerVisible: false,
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: CalendarFormat.twoWeeks,
                  eventLoader: _records.forDate,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  onDaySelected: _onDaySelected,
                  calendarStyle: CalendarStyle(
                    markerSize: 7,
                    markersMaxCount: 3,
                    markerMargin: const EdgeInsets.all(0.8),
                    markerDecoration: BoxDecoration(
                      color: Colors.grey[800],
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    todayDecoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.grey[800],
                      shape: BoxShape.circle,
                    ),
                  ),
                  onPageChanged: (focusedDay) {
                    setState(() {
                      _focusedDay = focusedDay;
                    });
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 15,
              ),
            ),
            _getRecordList(),
          ],
        ),
      ),
    );
  }
}
