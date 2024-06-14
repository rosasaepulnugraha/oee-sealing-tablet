import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../url.dart';

class PostIntegrationSetting {
  int status;
  String message;

  PostIntegrationSetting({this.message = "", this.status = 0});

  factory PostIntegrationSetting.createPostIntegrationSetting(
      Map<String, dynamic> object, int status) {
    return PostIntegrationSetting(
        message: object['message'] != null ? object['message'].toString() : "",
        status: status);
  }

  static Future<PostIntegrationSetting> connectToApi(
      String token,
      String ip_address,
      String port,
      String connection_type,
      String data_type,
      String username,
      String password) async {
    String apiURL = "${Url().val}api/integration-setting";

    try {
      var apiResult = await http.post(Uri.parse(apiURL), headers: {
        'Accept': 'application/json',
        "Connection": "Keep-Alive",
        "Keep-Alive": "timeout=5, max=1000",
        'Authorization': 'Bearer $token',
      }, body: {
        "ip_address": ip_address,
        "port": port,
        "connection_type": connection_type,
        "data_type": data_type,
        "username": username,
        "password": password
      });
      log("body ${{
        "ip_address": ip_address,
        "port": port,
        "connection_type": connection_type,
        "data_type": data_type,
        "username": username,
        "password": password
      }}");
      log("PostIntegrationSetting : " + apiResult.body);
      dynamic jsonObject = null;
      jsonObject = json.decode(apiResult.body);
      // if (apiResult.statusCode == 200) {
      // } else {
      //   int code = apiResult.statusCode;
      //   jsonObject =
      //       json.decode("{\"status\": $code,\"message\": \"Status Code $code\"}");
      // }

      return PostIntegrationSetting.createPostIntegrationSetting(
          jsonObject, apiResult.statusCode);
    } catch (x) {
      log(x.toString());
      return PostIntegrationSetting.createPostIntegrationSetting(
          json.decode("{\"status\": 400,\"message\": \"Request Timeout\"}"),
          800);
    }
  }
}
