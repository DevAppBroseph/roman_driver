import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:line_icons/line_icons.dart';
import 'package:ridbrain_project/services/constants.dart';
import 'package:ridbrain_project/services/convert_date.dart';
import 'package:ridbrain_project/services/extentions.dart';
import 'package:table_calendar/table_calendar.dart';

class ValuePicker {
  final BuildContext context;
  final PickerAdapter adapter;
  final Function(int index) onConfirm;

  ValuePicker({
    required this.context,
    required this.adapter,
    required this.onConfirm,
  }) {
    Picker(
      height: 250,
      itemExtent: 35,
      cancelText: "Отмена",
      cancelTextStyle: TextStyle(
        color: Colors.grey,
        fontSize: 16,
      ),
      confirmText: "Готово",
      confirmTextStyle: TextStyle(
        color: Colors.blue,
        fontSize: 16,
      ),
      adapter: adapter,
      onConfirm: (picker, value) {
        onConfirm(value.first);
      },
    ).showModal(context);
  }
}

class DatePicker {
  final BuildContext context;
  final Function(DateTime date) onConfirm;

  final int yearBegin;
  final int yearEnd;

  DatePicker({
    required this.context,
    required this.yearBegin,
    required this.yearEnd,
    required this.onConfirm,
  }) {
    Picker(
      height: 250,
      itemExtent: 35,
      cancelText: "Отмена",
      cancelTextStyle: TextStyle(
        color: Colors.grey,
        fontSize: 16,
      ),
      confirmText: "Готово",
      confirmTextStyle: TextStyle(
        color: Colors.blue,
        fontSize: 16,
      ),
      columnFlex: [2, 3, 2],
      adapter: DateTimePickerAdapter(
        yearBegin: yearBegin,
        yearEnd: yearEnd,
        customColumnType: [2, 1, 0],
        months: [
          "Январь",
          "Февраль",
          "Март",
          "Апрель",
          "Май",
          "Июнь",
          "Июль",
          "Август",
          "Сентябрь",
          "Октябрь",
          "Ноябрь",
          "Декабрь"
        ],
      ),
      onConfirm: (picker, value) {
        onConfirm((picker.adapter as DateTimePickerAdapter).value!);
      },
    ).showModal(context);
  }
}

class TimePicker {
  final BuildContext context;
  final Function(int hours, int minutes) onConfirm;
  final DateTime date;

  TimePicker({
    required this.context,
    required this.onConfirm,
    required this.date,
  }) {
    Picker(
      height: 250,
      itemExtent: 35,
      cancelText: "Отмена",
      cancelTextStyle: TextStyle(
        color: Colors.grey,
        fontSize: 16,
      ),
      confirmText: "Готово",
      confirmTextStyle: TextStyle(
        color: Colors.blue,
        fontSize: 16,
      ),
      columnFlex: [1, 1],
      adapter: DateTimePickerAdapter(
        yearBegin: DateTime.now().year,
        yearEnd: DateTime.now().year,
        value: date,
        customColumnType: [3, 4],
      ),
      onConfirm: (picker, value) {
        onConfirm(value[0], value[1]);
      },
    ).showModal(context);
  }
}

class CalendarPicker extends StatefulWidget {
  CalendarPicker({
    required this.eventLoader,
    required this.selectDate,
    required this.focusDate,
  });

  final List<Object> Function(DateTime day) eventLoader;
  final Function(DateTime date) selectDate;
  final Function(DateTime date) focusDate;

  @override
  _CalendarPickerState createState() => _CalendarPickerState();
}

class _CalendarPickerState extends State<CalendarPicker> {
  static final _today = ConvertDate.dayBegin();
  var _firstDay = DateTime(_today.year, _today.month - 2, 1, 0);
  var _lastDay = DateTime(_today.year, _today.month + 2, 0);
  late PageController _controller;

  DateTime _focusedDay = _today;
  DateTime _selectedDay = _today;

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

    widget.selectDate(selectedDay);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 5),
          child: TableCalendar<Object>(
            onCalendarCreated: (controller) {
              _controller = controller;
            },
            locale: "ru",
            firstDay: _firstDay,
            lastDay: _lastDay,
            headerVisible: false,
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: CalendarFormat.twoWeeks,
            eventLoader: widget.eventLoader,
            startingDayOfWeek: StartingDayOfWeek.monday,
            onDaySelected: _onDaySelected,
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, items) {
                if (date.day == _selectedDay.day) {
                  return Container();
                }
                if (items.isNotEmpty) {
                  return Container(
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                  );
                }
              },
            ),
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
              widget.focusDate(focusedDay);
              setState(() {
                _focusedDay = focusedDay;
              });
            },
          ),
        ),
        Container(
          height: 50,
          margin: const EdgeInsets.fromLTRB(15, 20, 15, 10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.05),
            borderRadius: radius,
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(LineIcons.arrowCircleLeft),
                onPressed: () => _controller.previousPage(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                ),
              ),
              Container(
                child: Expanded(
                  child: Text(
                    ConvertDate(context)
                        .fromDate(_selectedDay, "EEEE, d MMMM")
                        .capitalLetter(),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(LineIcons.arrowCircleRight),
                onPressed: () => _controller.nextPage(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
