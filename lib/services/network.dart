import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ridbrain_project/services/check_token.dart';
import 'package:http/http.dart' as http;
import 'package:ridbrain_project/services/constants.dart';
import 'package:ridbrain_project/services/objects.dart';
import 'package:ridbrain_project/services/snack_bar.dart';

class Network {
  Network(
    this.context,
  );

  final BuildContext context;

  static Future<String?> _request({
    required String url,
    Map<String, dynamic>? params,
  }) async {
    var response = await http.post(
      Uri.parse(apiUrl + url),
      body: params,
    );

    print(response.statusCode);

    if (response.statusCode == 200) {
      return response.body;
    } else {
      return null;
    }
  }

  static Future<String?> _webRequest({
    required String url,
    Map<String, String>? params,
  }) async {
    var response = await http.post(
      Uri.parse(apiWebUrl + url),
      body: params,
    );

    print(response.body);

    if (response.statusCode == 200) {
      return response.body;
    } else {
      return null;
    }
  }

  void _showAnswer(int status, String message) {
    StandartSnackBar.show(
      context,
      message,
      status == 0 ? SnackBarStatus.success() : SnackBarStatus.warning(),
    );
  }

  static Future<bool> checkDriverToken(
    String token,
  ) async {
    print('request is send');
    var address = 'check_token.php';

    var data = await _request(url: address, params: {
      "token": token,
    });
    print(data);

    if (data != null) {
      var answer = checkTokenFromJson(data);
      if (answer.error == 0) {
        return answer.status == 1;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<bool> checkAdminToken(String token) async {
    print('request is send');
    var address = 'check_token.php';

    var data = await _webRequest(url: address, params: {
      "token": token,
    });
    print(data);

    if (data != null) {
      var answer = tokenAnswerFromJson(data);

      if (answer.error == 0) {
        return answer.status == 1;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<List<Company>> getCompanies(String token) async {
    var address = 'get_companies.php';

    var data = await _webRequest(url: address, params: {
      "token": token,
    });

    if (data != null) {
      var answer = companiesAnswerFromJson(data);

      if (answer.error == 0) {
        return answer.companies;
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  Future<List<Nomenclature>?> getNomenclatures(String token) async {
    var address = 'get_nomenclatures.php';

    var data = await _request(url: address, params: {
      "token": token,
    });
    print(data);

    if (data != null) {
      var answer = nomenclatureFromJson(data);

      if (answer.error == 0) {
        return answer.nomenclatures;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  static Future<DriverAnswer?> getDriver(
    String login,
    String pass,
  ) async {
    var address = 'user_auth.php';

    var data = await _request(url: address, params: {
      "login": login,
      "pass": pass,
    });
    print(data);

    if (data != null) {
      var answer = driverAnswerFromJson(data);
      return answer;
    } else {
      return null;
    }
  }

  Future<UserAnswer?> userAuth(
    String login,
    String pass,
  ) async {
    var address = 'user_auth.php';
    print('object');

    var data = await _webRequest(url: address, params: {
      "login": login,
      "pass": pass,
    });
    print(data);
    if (data != null) {
      var answer = userAnswerFromJson(data);
      if (answer.error == 0) {
        return answer;
      } else {
        _showAnswer(answer.error, answer.error.toString());
        return null;
      }
    } else {
      return null;
    }
  }

  static Future<List<Record>> getRecords(
    String token,
  ) async {
    var address = 'get_records.php';

    var data = await _request(url: address, params: {
      "token": token,
    });

    if (data != null) {
      var answer = recordsAnswerFromJson(data);
      print(data);

      return answer.records;
    } else {
      return [];
    }
  }

  static Future<List<AdminRecord>> getAdminRecords(
    String token,
  ) async {
    var address = 'get_records.php';

    var data = await _webRequest(url: address, params: {
      "token": token,
    });

    if (data != null) {
      var answer = adminsRecordsAnswerFromJson(data);

      return answer.records;
    } else {
      return [];
    }
  }

  Future<Company?> addCompany(
    String token,
    String name,
    String phone,
    String location,
    String note,
    String web,
  ) async {
    var address = 'add_company.php';

    var data = await _webRequest(url: address, params: {
      "token": token,
      "name": name,
      "phone": phone,
      "location": location,
      "note": note,
      "web": web,
    });
    print(data);
    if (data != null) {
      var answer = companyAnswerFromJson(data);

      if (answer.error == 0) {
        return answer.company;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  Future<Company?> editCompany(
    String token,
    String id,
    String name,
    String phone,
    String location,
    String note,
    String web,
  ) async {
    var address = 'edit_company.php';

    var data = await _webRequest(url: address, params: {
      "token": token,
      "company_id": id,
      "name": name,
      "phone": phone,
      "location": location,
      "note": note,
      "web": web,
    });

    if (data != null) {
      var answer = companyAnswerFromJson(data);

      if (answer.error == 0) {
        return answer.company;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  Future<List<Result>> getPlaces(
    String token,
    String input,
  ) async {
    var address = 'get_places.php';

    var data = await _webRequest(url: address, params: {
      "token": token,
      "input": input,
    });

    if (data != null) {
      var answer = placesAnswerFromJson(data);

      if (answer.status == "OK") {
        return answer.results;
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  static Future<List<Record>> getActiveRecords(
    String token,
  ) async {
    var address = 'get_active_records.php';

    var data = await _request(url: address, params: {
      "token": token,
    });

    if (data != null) {
      var answer = recordsAnswerFromJson(data);

      return answer.records;
    } else {
      return [];
    }
  }

  static Future<List<Record>> getArchiveRecords(
    String token,
  ) async {
    var address = 'get_archive_records.php';

    var data = await _request(url: address, params: {
      "token": token,
    });

    if (data != null) {
      var answer = recordsAnswerFromJson(data);

      return answer.records;
    } else {
      return [];
    }
  }

  static Future<bool> changeRecordStatus(
    String token,
    String recordId,
    String recordStatus,
    String recordHistory,
  ) async {
    var address = 'change_record_status.php';

    var data = await _request(url: address, params: {
      "token": token,
      "record_id": recordId,
      "record_status": recordStatus,
      "record_history": recordHistory
    });

    if (data != null) {
      var answer = messageAnswerFromJson(data);

      return answer.error == 0;
    } else {
      return false;
    }
  }

  Future<bool> confirmRecord(
    String token,
    String recordId,
    String driver,
    String recordHistory,
  ) async {
    var address = 'confirm_record.php';

    var data = await _request(url: address, params: {
      "token": token,
      "record_id": recordId,
      "driver": driver,
      "record_history": recordHistory,
    });

    if (data != null) {
      var answer = messageAnswerFromJson(data);
      _showAnswer(answer.error, answer.message);

      return answer.error == 0;
    } else {
      return false;
    }
  }

  Future<bool> changePass(
    String token,
    String oldPass,
    String newPass,
  ) async {
    var address = 'change_pass.php';

    var data = await _request(url: address, params: {
      "token": token,
      "old_pass": oldPass,
      "new_pass": newPass,
    });

    if (data != null) {
      var answer = messageAnswerFromJson(data);
      _showAnswer(answer.error, answer.message);

      return answer.error == 0;
    } else {
      return false;
    }
  }

  static Future addCoordinates(
    String token,
    String driverId,
    String latitude,
    String longitude,
  ) async {
    var address = 'add_coordinate.php';

    await _request(url: address, params: {
      "token": token,
      "driver_id": driverId,
      "latitude": latitude,
      "longitude": longitude,
    });
  }

  static Future updateFcm(
    String token,
    String driverId,
    String firebaseToken,
  ) async {
    var address = 'update_fcm.php';

    await _request(url: address, params: {
      "token": token,
      "driver_id": driverId,
      "firebase_token": firebaseToken
    });
  }

  Future<List<Company>> searchCompanies(String token, String text) async {
    var address = 'search_companies.php';

    var data = await _webRequest(url: address, params: {
      "token": token,
      "text": text,
    });

    if (data != null) {
      var answer = companiesAnswerFromJson(data);

      if (answer.error == 0) {
        return answer.companies;
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  Future<AdminRecord?> addRecord(
    String token,
    String date,
    String company,
    String status,
    String note,
    String managerName,
  ) async {
    var address = 'add_record.php';

    var data = await _webRequest(url: address, params: {
      "token": token,
      "date": date,
      "company": company,
      "status": status,
      "note": note,
      "manager": managerName,
    });

    if (data != null) {
      var answer = adminRecordAnswerFromJson(data);

      if (answer.error == 0) {
        return answer.record;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  Future<bool> cancelRecord(
    String token,
    String recordId,
    String history,
  ) async {
    var address = 'cancel_record.php';

    var data = await _webRequest(url: address, params: {
      "token": token,
      "record_id": recordId,
      "record_history": history,
    });

    if (data != null) {
      var answer = messageAnswerFromJson(data);
      _showAnswer(answer.error, answer.message);

      return answer.error == 0;
    } else {
      return false;
    }
  }

  Future<bool> editRecordNote(
    String token,
    String recordId,
    String note,
  ) async {
    var address = 'edit_record_note.php';

    var data = await _webRequest(url: address, params: {
      "token": token,
      "record_id": recordId,
      "note": note,
    });

    if (data != null) {
      var answer = messageAnswerFromJson(data);
      _showAnswer(answer.error, answer.message);

      return answer.error == 0;
    } else {
      return false;
    }
  }

  Future<bool> editRecordManager(
    String token,
    String recordId,
    String manager,
  ) async {
    var address = 'edit_record_manager.php';

    var data = await _webRequest(url: address, params: {
      "token": token,
      "record_id": recordId,
      "manager": manager,
    });
    print(data);

    if (data != null) {
      var answer = messageAnswerFromJson(data);
      _showAnswer(answer.error, answer.message);

      return answer.error == 0;
    } else {
      return false;
    }
  }

  Future<bool> setDriver(
    String token,
    String recordId,
    String driver,
    String recordHistory,
  ) async {
    var address = 'set_driver.php';

    var data = await _webRequest(url: address, params: {
      "token": token,
      "record_id": recordId,
      "driver": driver,
      "record_history": recordHistory,
    });

    if (data != null) {
      var answer = messageAnswerFromJson(data);
      _showAnswer(answer.error, answer.message);

      return answer.error == 0;
    } else {
      return false;
    }
  }

  Future<List<AdminDriver>> searchDrivers(String token, String text) async {
    var address = 'search_drivers.php';

    var data = await _webRequest(url: address, params: {
      "token": token,
      "text": text,
    });

    if (data != null) {
      var answer = adminDriversAnswerFromJson(data);

      if (answer.error == 0) {
        return answer.drivers;
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  Future<Weight?> editWeight(
      String token,
      int orderId,
      List<DriverNomenclature> values,
      String comment,
      Company company,
      String driverName,
      List images) async {
    var address = 'weight.php';

    var data = await _request(url: address, params: {
      "token": token,
      "order_id": orderId.toString(),
      "values": weightToJson(values),
      "comment": comment,
      "company": companyToJson(company),
      "driver_name": driverName,
      "images": jsonEncode(images)
    });

    print(data);

    // try {
    if (data != null) {
      var answer = weightAnswerFromJson(data);
      if (answer.success == 'true') {
        _showAnswer(0, '?????????? ????????????????');
      } else {
        _showAnswer(0, '?????????? ???? ????????????????');
      }

      return answer.weight;
    } else {
      return null;
    }
    // } catch (e) {
    //   if (data != null) {
    //     var answer = messageAnswerFromJson(data);
    //     _showAnswer(answer.error, answer.message);
    //     return null;
    //   }
    // }
    // return null;
  }

  Future<Weight?> getWeight(
    String token,
    String orderId, {
    bool admin = false,
  }) async {
    var address = 'get_weight.php';

    var data;

    if (admin) {
      data = await _webRequest(url: address, params: {
        "token": token,
        "order_id": orderId,
      });
      print(data);
    } else {
      data = await _request(url: address, params: {
        "token": token,
        "order_id": orderId,
      });
      print(data);
    }
    // try {
    // try {
    try {
      if (data != null) {
        var answer = weightFromJson(data);
        // _showAnswer(1, answer.success);

        return answer;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
    // } catch (e) {
    //   print('im here');
    //   return null;
    // }
    // } catch (e) {
    //   var answer = messageAnswerFromJson(data!);
    //   _showAnswer(answer.error, answer.message);
    //   return null;
    // }
  }

  static Future changeCash(
    String token,
    String recordId,
    String cash,
  ) async {
    var address = 'change_cash.php';

    await _webRequest(url: address, params: {
      "token": token,
      "record_id": recordId,
      "cash": cash,
    });
  }

  static Future<Record?> getRecord(
    String token,
    String recordId,
  ) async {
    print(recordId);
    var address = 'get_record.php';

    var data = await _request(url: address, params: {
      "token": token,
      "record_id": recordId,
    });
    print(data);

    if (data != null) {
      var answer = recordAnswerFromJson(data);

      return answer.record;
    } else {
      return null;
    }
  }
}
