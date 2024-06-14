import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../url.dart';

class PostOkNg {
  int status;
  String message;

  PostOkNg({this.message = "", this.status = 0});

  factory PostOkNg.createPostOkNg(Map<String, dynamic> object, int status) {
    return PostOkNg(
        message: object['message'] != null ? object['message'].toString() : "",
        status: status);
  }

  static Future<PostOkNg> connectToApi(
      String token, String bodyId, String status) async {
    String apiURL =
        Url().val + "api/update-quality-control/$bodyId?status=$status";

    try {
      var apiResult = await http.post(Uri.parse(apiURL), headers: {
        'Accept': 'application/json',
        "Connection": "Keep-Alive",
        "Keep-Alive": "timeout=5, max=1000",
        'Authorization': 'Bearer $token',
      });
      log("PostOkNg : " + apiResult.body);
      dynamic jsonObject = null;
      jsonObject = json.decode(apiResult.body);
      // if (apiResult.statusCode == 200) {
      // } else {
      //   int code = apiResult.statusCode;
      //   jsonObject =
      //       json.decode("{\"status\": $code,\"message\": \"Status Code $code\"}");
      // }

      return PostOkNg.createPostOkNg(jsonObject, apiResult.statusCode);
    } catch (x) {
      log(x.toString());
      return PostOkNg.createPostOkNg(
          json.decode("{\"status\": 400,\"message\": \"Request Timeout\"}"),
          800);
    }
  }
}
