import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../url.dart';

class Login {
  String token;
  String webToken;
  int status;
  String message;

  Login(
      {this.token = "",
      this.message = "",
      this.webToken = "",
      this.status = 0});

  factory Login.createLogin(Map<String, dynamic> object, int status) {
    return Login(
        token: status == 200 ? object['token'] : "",
        webToken: status == 200 ? object['web_view_token'] : "",
        message: object['message'] != null ? object['message'].toString() : "",
        status: status);
  }

  static Future<Login> connectToApi(
      String email, String password, String device) async {
    String apiURL = Url().val + "api/login";

    try {
      var apiResult = await http.post(Uri.parse(apiURL), headers: {
        'Accept': 'application/json',
        "Connection": "Keep-Alive",
        "Keep-Alive": "timeout=5, max=1000",
      }, body: {
        "employee_id": email,
        "password": password,
        "device": device
      });
      log("LOGIN : " + apiResult.body);
      dynamic jsonObject = null;
      jsonObject = json.decode(apiResult.body);
      // if (apiResult.statusCode == 200) {
      // } else {
      //   int code = apiResult.statusCode;
      //   jsonObject =
      //       json.decode("{\"status\": $code,\"message\": \"Status Code $code\"}");
      // }

      return Login.createLogin(jsonObject, apiResult.statusCode);
    } catch (x) {
      log(x.toString());
      return Login.createLogin(
          json.decode("{\"status\": 400,\"message\": \"Request Timeout\"}"),
          800);
    }
  }
}
