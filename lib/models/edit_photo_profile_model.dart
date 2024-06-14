import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'package:isuzu_oee_app/url.dart';

class EditPhotoProfile {
  int status;
  String message;

  EditPhotoProfile({this.message = "", this.status = 0});

  factory EditPhotoProfile.createEditPhotoProfile(
      Map<String, dynamic> object, int status) {
    return EditPhotoProfile(
        message: object['message'] != null ? object['message'] : "",
        status: status);
  }

  static Future<EditPhotoProfile> connectToApi(
      String token, File? picture) async {
    String apiURL = Url().val + "api/update-photo";
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

    if (picture != null) {
      int size = await picture.length();
      log("size " + size.toString());
      request.files.add(
        http.MultipartFile(
          'picture',
          picture.readAsBytes().asStream(),
          picture.lengthSync(),
          filename: "picture",
          contentType: MediaType('image', 'jpg'),
        ),
      );
    }

    request.headers.addAll(headers);

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
      return EditPhotoProfile.createEditPhotoProfile(jsonObject, 800);
    }

    return EditPhotoProfile.createEditPhotoProfile(jsonObject, res.statusCode);
  }
}
