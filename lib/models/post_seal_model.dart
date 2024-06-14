import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../url.dart';

class PostSeal {
  int status;
  String message;
  String type;

  PostSeal({this.message = "", this.type = "", this.status = 0});

  factory PostSeal.createPostSeal(Map<String, dynamic> object, int status) {
    return PostSeal(
        message: object['message'] != null ? object['message'].toString() : "",
        type: object['status'] != null ? object['status'].toString() : "",
        status: status);
  }

  static Future<PostSeal> connectToApi(
      String token, String barcode, String body_type) async {
    String apiURL = Url().val + "api/scan";

    try {
      var apiResult = await http.post(Uri.parse(apiURL), headers: {
        'Accept': 'application/json',
        "Connection": "Keep-Alive",
        "Keep-Alive": "timeout=5, max=1000",
        'Authorization': 'Bearer $token',
      }, body: {
        "barcode": barcode,
        "body_type": body_type,
        "operation": "SEALING"
      });
      log("PostSeal : " + apiResult.body);
      dynamic jsonObject = null;
      jsonObject = json.decode(apiResult.body);
      // if (apiResult.statusCode == 200) {
      // } else {
      //   int code = apiResult.statusCode;
      //   jsonObject =
      //       json.decode("{\"status\": $code,\"message\": \"Status Code $code\"}");
      // }

      return PostSeal.createPostSeal(jsonObject, apiResult.statusCode);
    } catch (x) {
      log(x.toString());
      return PostSeal.createPostSeal(
          json.decode("{\"status\": 400,\"message\": \"Request Timeout\"}"),
          800);
    }
  }
}
