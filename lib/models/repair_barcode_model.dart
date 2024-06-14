import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../url.dart';

class RepairBarcode {
  int status;
  String message;
  String type;

  RepairBarcode({this.message = "", this.type = "", this.status = 0});

  factory RepairBarcode.createRepairBarcode(
      Map<String, dynamic> object, int status) {
    return RepairBarcode(
        message: object['message'] != null ? object['message'].toString() : "",
        type: object['status'] != null ? object['status'].toString() : "",
        status: status);
  }

  static Future<RepairBarcode> connectToApi(
      String token, String barcode) async {
    String apiURL = Url().val + "api/repair";

    try {
      var apiResult = await http.post(Uri.parse(apiURL), headers: {
        'Accept': 'application/json',
        "Connection": "Keep-Alive",
        "Keep-Alive": "timeout=5, max=1000",
        'Authorization': 'Bearer $token',
      }, body: {
        "barcode": barcode,
        "operation": "SEALING"
      });
      log("RepairBarcode : " + apiResult.body);
      dynamic jsonObject = null;
      jsonObject = json.decode(apiResult.body);
      // if (apiResult.statusCode == 200) {
      // } else {
      //   int code = apiResult.statusCode;
      //   jsonObject =
      //       json.decode("{\"status\": $code,\"message\": \"Status Code $code\"}");
      // }

      return RepairBarcode.createRepairBarcode(
          jsonObject, apiResult.statusCode);
    } catch (x) {
      log(x.toString());
      return RepairBarcode.createRepairBarcode(
          json.decode("{\"status\": 400,\"message\": \"Request Timeout\"}"),
          800);
    }
  }
}
