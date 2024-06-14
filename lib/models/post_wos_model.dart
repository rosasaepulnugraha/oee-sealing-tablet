import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../url.dart';

class PosWos {
  int status;
  String message;

  PosWos({this.message = "", this.status = 0});

  factory PosWos.createPosWos(Map<String, dynamic> object, int status) {
    return PosWos(
        message: object['message'] != null ? object['message'].toString() : "",
        status: status);
  }

  static Future<PosWos> connectToApi(String token, String date, String shift_id,
      String plan_wos, String operation_time, String operation) async {
    String apiURL = Url().val + "api/create-wos";

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
        "operation": operation,
      });
      log("PosWos : " + apiResult.body);
      dynamic jsonObject = null;
      jsonObject = json.decode(apiResult.body);
      // if (apiResult.statusCode == 200) {
      // } else {
      //   int code = apiResult.statusCode;
      //   jsonObject =
      //       json.decode("{\"status\": $code,\"message\": \"Status Code $code\"}");
      // }

      return PosWos.createPosWos(jsonObject, apiResult.statusCode);
    } catch (x) {
      log(x.toString());
      return PosWos.createPosWos(
          json.decode("{\"status\": 400,\"message\": \"Request Timeout\"}"),
          800);
    }
  }
}
