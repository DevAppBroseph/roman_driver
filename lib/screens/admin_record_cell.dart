import 'package:flutter/material.dart';
import 'package:ridbrain_project/services/constants.dart';
import 'package:ridbrain_project/services/convert_date.dart';
import 'package:ridbrain_project/services/objects.dart';

class AdminRecordCell extends StatelessWidget {
  const AdminRecordCell({
    Key? key,
    required this.record,
    required this.onTap,
  }) : super(key: key);

  final AdminRecord record;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 95,
      margin: const EdgeInsets.fromLTRB(15, 5, 15, 10),
      decoration: const BoxDecoration(
        borderRadius: radius,
      ),
      child: Material(
        borderRadius: radius,
        color: record.getColor(),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  record.company.companyName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  record.driver?.driverName ?? "Водитель не назначен",
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  record.company.companyLocation.address,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "Дата: " +
                      ConvertDate(context).fromUnix(
                        record.recordDate,
                        "dd.MM.yy",
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
