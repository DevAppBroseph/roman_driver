import 'package:flutter/material.dart';
import 'package:ridbrain_project/services/constants.dart';
import 'package:ridbrain_project/services/convert_date.dart';
import 'package:ridbrain_project/services/extentions.dart';
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
      margin: const EdgeInsets.fromLTRB(15, 5, 15, 10),
      decoration: const BoxDecoration(
        borderRadius: radius,
      ),
      child: Material(
        borderRadius: radius,
        color: record.recordStatus.color,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.company.companyName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  record.driver?.driverName ?? "Водитель не назначен",
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  record.company.companyLocation.address,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  "Дата: " +
                      ConvertDate(context).fromUnix(
                        record.recordDate,
                        "dd.MM.yy",
                      ),
                ),
                if (record.cash == 1)
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      "₽",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
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
