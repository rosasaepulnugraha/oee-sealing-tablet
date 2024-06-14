import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class ListOperationTime {
  int status;
  final String message;
  final List<OperationTime>? data;

  ListOperationTime({this.message = "", this.status = 0, this.data});

  factory ListOperationTime.createListOperationTime(String object, int status) {
    var linksList = jsonDecode(object) as List<dynamic>;

    List<OperationTime> links =
        linksList.map((i) => OperationTime.fromJson(i)).toList();
    // List<Plant> plants =
    //     jsonData.map((plantJson) => Plant.fromJson(plantJson)).toList();

    // log("Tanaman " + object.toString());
    // log(Intepretasi.fromJson(object['P']).SRendah.toString());
    return ListOperationTime(
      // message: object['message'] ?? "",
      status: status,
      data: links,
    );
  }

  static Future<ListOperationTime> connectToApi(
      String url, String token) async {
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
      log("list shift " + apiResult.body);
      if (apiResult.statusCode != 500) {
        jsonObject = apiResult.body;
      } else {
        int code = apiResult.statusCode;
        jsonObject = "{\"status\": $code,\"message\": \"Status Code $code\"}";
      }
      return ListOperationTime.createListOperationTime(
          jsonObject, apiResult.statusCode);
    } catch (x) {
      log(x.toString());
      jsonObject = "{\"status\": 501,\"message\": \"Terjadi kesalahan\"}";
      return ListOperationTime.createListOperationTime(jsonObject, 501);
    }
  }
}

class OperationTime {
  final String? value;
  final String? name;

  OperationTime({
    required this.value,
    required this.name,
  });

  factory OperationTime.fromJson(Map<String, dynamic> json) {
    return OperationTime(
      value: json['value'],
      name: json['text'],
    );
  }
  @override
  String toString() {
    return name ?? "";
  }
}
