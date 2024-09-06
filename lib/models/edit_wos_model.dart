import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../url.dart';

class EditWos {
  int status;
  String message;

  EditWos({this.message = "", this.status = 0});

  factory EditWos.createEditWos(Map<String, dynamic> object, int status) {
    return EditWos(
        message: object['message'] != null ? object['message'].toString() : "",
        status: status);
  }

  static Future<EditWos> connectToApi(String token, String date,
      String shift_id, String plan_wos, String operation_time) async {
    String apiURL = Url().val + "api/edit-wos";

    try {
      var apiResult = await http.post(Uri.parse(apiURL), headers: {
        'Accept': 'application/json',
        "Connection": "Keep-Alive",
        "Keep-Alive": "timeout=5, max=1000",
        'Authorization': 'Bearer $token',
      }, body: {
        "date": date,
        "shift_id": shift_id,
        "plan_wos": plan_wos,
        "operation_time": operation_time,
        "operation": "TOPCOAT",
      });
      log("EditWos : " + apiResult.body);
      dynamic jsonObject = null;
      jsonObject = json.decode(apiResult.body);
      // if (apiResult.statusCode == 200) {
      // } else {
      //   int code = apiResult.statusCode;
      //   jsonObject =
      //       json.decode("{\"status\": $code,\"message\": \"Status Code $code\"}");
      // }

      return EditWos.createEditWos(jsonObject, apiResult.statusCode);
    } catch (x) {
      log(x.toString());
      return EditWos.createEditWos(
          json.decode("{\"status\": 400,\"message\": \"Request Timeout\"}"),
          800);
    }
  }
}
