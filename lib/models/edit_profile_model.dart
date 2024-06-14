import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'package:isuzu_oee_app/url.dart';

class EditProfile {
  int status;
  String message;

  EditProfile({this.message = "", this.status = 0});

  factory EditProfile.createEditProfile(
      Map<String, dynamic> object, int status) {
    return EditProfile(
        message: object['message'] != null ? object['message'] : "",
        status: status);
  }

  static Future<EditProfile> connectToApi(
      String token, String name, String employee_id) async {
    String apiURL = Url().val + "api/profile";
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(apiURL),
    );
    Map<String, String> headers = {
      "Content-type": "multipart/form-data",
      "Accept": "application/json",
      "Connection": "Keep-Alive",
      "Keep-Alive": "timeout=5, max=1000",
      'Authorization': 'Bearer $token',
    };
    request.headers.addAll(headers);
    request.fields.addAll({"employee_id": employee_id, "name": name});
    print(request.fields);

    var res = await request.send();
    final respStr = await res.stream.bytesToString();
    log("res " + respStr);
    dynamic jsonObject = null;
    try {
      if (res.statusCode != 500) {
        jsonObject = json.decode(respStr);
      } else {
        int code = res.statusCode;
        jsonObject = json
            .decode("{\"status\": $code,\"message\": \"Status Code $code\"}");
      }
    } catch (x) {
      jsonObject = json
          .decode("{\"status\": 800,\"${x.toString()}\": \"Status Code 800\"}");
      return EditProfile.createEditProfile(jsonObject, 800);
    }

    return EditProfile.createEditProfile(jsonObject, res.statusCode);
  }
}
