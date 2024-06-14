import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class CountOperation {
  int status;
  final String message;
  final int? okCount;
  final int? ngCount;
  final int? totalCount;

  CountOperation({
    this.message = "",
    this.status = 0,
    this.okCount = 0,
    this.ngCount = 0,
    this.totalCount = 0,
  });

  factory CountOperation.createCountOperation(
      Map<String, dynamic> object, int status) {
    // OperationList operationList = OperationList.fromJson(object);
    // List<Plant> plants =
    //     jsonData.map((plantJson) => Plant.fromJson(plantJson)).toList();

    // log("Tanaman " + object.toString());
    // log(Intepretasi.fromJson(object['P']).SRendah.toString());
    return CountOperation(
      message: object['message'] ?? "",
      status: status,
      okCount: object['okCount'],
      ngCount: object['ngCount'],
      totalCount: object['totalCount'],
    );
  }

  static Future<CountOperation> connectToApi(String url, String token) async {
    dynamic jsonObject = null;
    try {
      String apiURL = url;
      log("URLL " + url);
      // print("ada");
      var apiResult = await http.get(Uri.parse(apiURL), headers: {
        'Accept': 'application/json',
        "Connection": "Keep-Alive",
        "Keep-Alive": "timeout=5, max=10000",
        'Authorization': 'Bearer ' + token,
      });
      log("respon " + apiResult.body);
      if (apiResult.statusCode != 500) {
        jsonObject = json.decode(apiResult.body);
      } else {
        int code = apiResult.statusCode;
        jsonObject = json
            .decode("{\"status\": $code,\"message\": \"Status Code $code\"}");
      }
      return CountOperation.createCountOperation(
          jsonObject, apiResult.statusCode);
    } catch (x) {
      log(x.toString());
      jsonObject =
          json.decode("{\"status\": 501,\"message\": \"Terjadi kesalahan\"}");
      return CountOperation.createCountOperation(jsonObject, 501);
    }
  }
}
