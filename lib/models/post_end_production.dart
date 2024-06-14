import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../url.dart';

class PostEndProduction {
  int status;
  String message;

  PostEndProduction({this.message = "", this.status = 0});

  factory PostEndProduction.createPostEndProduction(
      Map<String, dynamic> object, int status) {
    return PostEndProduction(
        message: object['message'] != null ? object['message'].toString() : "",
        status: status);
  }

  static Future<PostEndProduction> connectToApi(String token, String id) async {
    String apiURL = Url().val + "api/end-session";

    try {
      var apiResult = await http.post(Uri.parse(apiURL), headers: {
        'Accept': 'application/json',
        "Connection": "Keep-Alive",
        "Keep-Alive": "timeout=5, max=1000",
        'Authorization': 'Bearer $token',
      }, body: {
        "achievement_id": id
      });
      log("PostEndProduction : " + apiResult.body);
      dynamic jsonObject = null;
      jsonObject = json.decode(apiResult.body);
      // if (apiResult.statusCode == 200) {
      // } else {
      //   int code = apiResult.statusCode;
      //   jsonObject =
      //       json.decode("{\"status\": $code,\"message\": \"Status Code $code\"}");
      // }

      return PostEndProduction.createPostEndProduction(
          jsonObject, apiResult.statusCode);
    } catch (x) {
      log(x.toString());
      return PostEndProduction.createPostEndProduction(
          json.decode("{\"status\": 400,\"message\": \"Request Timeout\"}"),
          800);
    }
  }
}
