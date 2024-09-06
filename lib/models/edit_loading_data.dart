import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'package:isuzu_oee_app/url.dart';

class EditLoadingData {
  int status;
  String message;

  EditLoadingData({this.message = "", this.status = 0});

  factory EditLoadingData.createEditLoadingData(
      Map<String, dynamic> object, int status) {
    return EditLoadingData(
        message: object['message'] != null ? object['message'] : "",
        status: status);
  }

  static Future<EditLoadingData> connectToApi(
      String token, String bodyId, String typeBody, String id) async {
    String apiURL = Url().val + "api/operation/$id";
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
    request.fields.addAll({"body_id": bodyId, "body_type": typeBody});
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
      return EditLoadingData.createEditLoadingData(jsonObject, 800);
    }

    return EditLoadingData.createEditLoadingData(jsonObject, res.statusCode);
  }
}
