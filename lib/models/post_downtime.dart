import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../url.dart';

class PostDowntime {
  int status;
  String message;

  PostDowntime({this.message = "", this.status = 0});

  factory PostDowntime.createPostDowntime(
      Map<String, dynamic> object, int status) {
    return PostDowntime(
        message: object['message'] != null ? object['message'].toString() : "",
        status: status);
  }

  static Future<PostDowntime> connectToApi(String token, String reason_id,
      String down_time, String start, String end) async {
    String apiURL = Url().val + "api/down-time";

    try {
      var apiResult = await http.post(Uri.parse(apiURL), headers: {
        'Accept': 'application/json',
        "Connection": "Keep-Alive",
        "Keep-Alive": "timeout=5, max=1000",
        'Authorization': 'Bearer $token',
      }, body: {
        "reason_id": reason_id,
        "down_time": down_time,
        "start": start,
        "end": end
      });
      log("PostDowntime : " + apiResult.body);
      dynamic jsonObject = null;
      jsonObject = json.decode(apiResult.body);
      // if (apiResult.statusCode == 200) {
      // } else {
      //   int code = apiResult.statusCode;
      //   jsonObject =
      //       json.decode("{\"status\": $code,\"message\": \"Status Code $code\"}");
      // }

      return PostDowntime.createPostDowntime(jsonObject, apiResult.statusCode);
    } catch (x) {
      log(x.toString());
      return PostDowntime.createPostDowntime(
          json.decode("{\"status\": 400,\"message\": \"Request Timeout\"}"),
          800);
    }
  }
}
