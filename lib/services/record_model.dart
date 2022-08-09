import 'package:ridbrain_project/services/objects.dart';

class Record {
  Record({
    required this.recordId,
    required this.recordDate,
    required this.recordStatus,
    required this.recordNote,
    required this.company,
    required this.recordHistory,
    required this.cash,
    this.driver,
  });

  int recordId;
  int recordDate;
  StatusRecord recordStatus;
  String recordNote;
  Company company;
  Driver? driver;
  List<RecordStatus> recordHistory;
  int cash;

  String driverName() {
    if (driver == null) {
      return "Водитель не назначен";
    }
    return driver!.driverName;
  }

  static StatusRecord getStatusFromString(String statusString) {
    for (StatusRecord item in StatusRecord.values) {
      if (item.toString() == statusString) {
        return item;
      }
    }
    return StatusRecord.wait;
  }

  factory Record.fromJson(Map<String, dynamic> json) => Record(
        recordId: json["record_id"],
        recordDate: json["record_date"],
        recordHistory: List<RecordStatus>.from(
          json["record_history"].map((x) => RecordStatus.fromJson(x)),
        ),
        recordNote: json["record_note"],
        driver: json["driver"] != null ? Driver.fromJson(json["driver"]) : null,
        company: Company.fromJson(json["company"]),
        recordStatus: getStatusFromString(json['record_status']),
        cash: json["cash"],
      );

  Map<String, dynamic> toJson() => {
        "record_id": recordId,
        "record_date": recordDate,
        "record_history": List<dynamic>.from(
          recordHistory.map((x) => x.toJson()),
        ),
        "record_note": recordNote,
        "driver": driver != null ? driver!.toJson() : "",
        "record_status": recordStatus.name,
        "company": company.toJson(),
        "cash": cash,
      };
}
