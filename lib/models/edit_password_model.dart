import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'package:isuzu_oee_app/url.dart';

class EditPassword {
  int status;
  String message;

  EditPassword({this.message = "", this.status = 0});

  factory EditPassword.createEditPassword(
      Map<String, dynamic> object, int status) {
    return EditPassword(
        message: object['message'] != null ? object['message'] : "",
        status: status);
  }

  static Future<EditPassword> connectToApi(String token, String old_password,
      String new_password, String new_password_confirmation) async {
    String apiURL = Url().val + "api/update-password";
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
    request.fields.addAll({
      "old_password": old_password,
      "new_password": new_password,
      "new_password_confirmation": new_password_confirmation
    });
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
      return EditPassword.createEditPassword(jsonObject, 800);
    }

    return EditPassword.createEditPassword(jsonObject, res.statusCode);
  }
}
