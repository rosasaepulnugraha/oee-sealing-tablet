import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class LogoutModel {
  int status;
  String message;

  LogoutModel({this.message = "", this.status = 0});

  factory LogoutModel.createLogoutModel(
      Map<String, dynamic> object, int status) {
    return LogoutModel(
        message: object['message'] != null ? object['message'].toString() : "",
        status: status);
  }

  static Future<LogoutModel> connectToApi(String url, String token) async {
    String apiURL = url + "/api/mobile/logout";

    try {
      var apiResult = await http.post(Uri.parse(apiURL), headers: {
        'Accept': 'application/json',
        "Connection": "Keep-Alive",
        "Keep-Alive": "timeout=5, max=1000",
        'Authorization': 'Bearer ' + token,
      });
      log("HHHHHH " + apiResult.body);
      dynamic jsonObject = null;
      jsonObject = json.decode(apiResult.body);
      // if (apiResult.statusCode == 200) {
      // } else {
      //   int code = apiResult.statusCode;
      //   jsonObject =
      //       json.decode("{\"status\": $code,\"message\": \"Status Code $code\"}");
      // }

      return LogoutModel.createLogoutModel(jsonObject, apiResult.statusCode);
    } catch (x) {
      return LogoutModel.createLogoutModel(
          json.decode("{\"status\": 400,\"message\": \"Request Timeout\"}"),
          800);
    }
  }
}
