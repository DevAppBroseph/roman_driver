import 'package:flutter/material.dart';
import 'package:ridbrain_project/services/convert_date.dart';
import 'package:ridbrain_project/services/objects.dart';

extension Times on DateTime {
  int secondsSinceEpoch() {
    return millisecondsSinceEpoch ~/ 1000;
  }
}

extension StringExtension on String {
  String capitalLetter() {
    if (this.isEmpty) {
      return this;
    } else {
      return '${this[0].toUpperCase()}${this.substring(1).toLowerCase()}';
    }
  }
}

extension Records on List<Record> {
  List<Record> forDate(BuildContext context, DateTime date) {
    List<Record> events = [];

    var thisDay = ConvertDate(context).fromDate(date, "dd.MM.yy");

    for (var item in this) {
      var day = ConvertDate(context).fromUnix(item.recordDate, "dd.MM.yy");

      if (thisDay == day) {
        events.add(item);
      }
    }

    return events;
  }
}

extension AdminRecords on List<AdminRecord> {
  List<AdminRecord> forDate(BuildContext context, DateTime date) {
    List<AdminRecord> events = [];

    var thisDay = ConvertDate(context).fromDate(date, "dd.MM.yy");

    for (var item in this) {
      var day = ConvertDate(context).fromUnix(item.recordDate, "dd.MM.yy");

      if (thisDay == day) {
        events.add(item);
      }
    }

    events.sort(
      (a, b) => a.recordStatus.index.compareTo(b.recordStatus.index),
    );

    return events;
  }
}

extension StatusRecordExt on StatusRecord {
  String get label {
    switch (this) {
      case StatusRecord.wait:
        return "Ожидание";
      case StatusRecord.set:
        return "Назначен";
      case StatusRecord.taken:
        return "Принята";
      case StatusRecord.loading:
        return "На загрузке";
      case StatusRecord.unloading:
        return "На выгрузке";
      case StatusRecord.done:
        return "Выполнена";
      case StatusRecord.cancel:
        return "Отменена";
    }
  }

  Color get color {
    switch (this) {
      case StatusRecord.wait:
        return Colors.red.shade100;
      case StatusRecord.set:
        return Colors.yellow.shade100;
      case StatusRecord.taken:
        return Colors.orange.shade100;
      case StatusRecord.loading:
        return Colors.blue.shade100;
      case StatusRecord.unloading:
        return Colors.teal.shade100;
      case StatusRecord.done:
        return Colors.green.shade100;
      case StatusRecord.cancel:
        return Colors.grey.shade100;
    }
  }
}
