import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class ListReason {
  int status;
  final String message;
  final List<Reason>? data;

  ListReason({this.message = "", this.status = 0, this.data});

  factory ListReason.createListReason(String object, int status) {
    var linksList = jsonDecode(object) as List<dynamic>;

    List<Reason> links = linksList.map((i) => Reason.fromJson(i)).toList();
    // List<Plant> plants =
    //     jsonData.map((plantJson) => Plant.fromJson(plantJson)).toList();

    // log("Tanaman " + object.toString());
    // log(Intepretasi.fromJson(object['P']).SRendah.toString());
    return ListReason(
      // message: object['message'] ?? "",
      status: status,
      data: links,
    );
  }

  static Future<ListReason> connectToApi(String url, String token) async {
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
        jsonObject = apiResult.body;
      } else {
        int code = apiResult.statusCode;
        jsonObject = "{\"status\": $code,\"message\": \"Status Code $code\"}";
      }
      return ListReason.createListReason(jsonObject, apiResult.statusCode);
    } catch (x) {
      log(x.toString());
      jsonObject = "{\"status\": 501,\"message\": \"Terjadi kesalahan\"}";
      return ListReason.createListReason(jsonObject, 501);
    }
  }
}

class Reason {
  final int id;
  final String? reason;

  Reason({
    required this.id,
    required this.reason,
  });

  factory Reason.fromJson(Map<String, dynamic> json) {
    return Reason(
      id: json['id'],
      reason: json['reason'],
    );
  }
  @override
  String toString() {
    return reason ?? "";
  }
}
