import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class ListShift {
  int status;
  final String message;
  final List<Shift>? data;

  ListShift({this.message = "", this.status = 0, this.data});

  factory ListShift.createListShift(String object, int status) {
    var linksList = jsonDecode(object) as List<dynamic>;

    List<Shift> links = linksList.map((i) => Shift.fromJson(i)).toList();
    // List<Plant> plants =
    //     jsonData.map((plantJson) => Plant.fromJson(plantJson)).toList();

    // log("Tanaman " + object.toString());
    // log(Intepretasi.fromJson(object['P']).SRendah.toString());
    return ListShift(
      // message: object['message'] ?? "",
      status: status,
      data: links,
    );
  }

  static Future<ListShift> connectToApi(String url, String token) async {
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
      return ListShift.createListShift(jsonObject, apiResult.statusCode);
    } catch (x) {
      log(x.toString());
      jsonObject = "{\"status\": 501,\"message\": \"Terjadi kesalahan\"}";
      return ListShift.createListShift(jsonObject, 501);
    }
  }
}

class Shift {
  final int id;
  final String? name;

  Shift({
    required this.id,
    required this.name,
  });

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      id: json['id'],
      name: json['name'],
    );
  }
  @override
  String toString() {
    return name ?? "";
  }
}
