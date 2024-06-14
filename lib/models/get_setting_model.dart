import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:isuzu_oee_app/url.dart';

class GetSetting {
  int? statusCode;
  final String? message;
  final MqttConnection? mqttConnection;

  GetSetting({this.statusCode, this.message, this.mqttConnection});

  factory GetSetting.createGetSetting(Map<String, dynamic> object, int status) {
    return GetSetting(
        message: object['message'] ?? "",
        mqttConnection: status == 200 ? MqttConnection.fromJson(object) : null,
        statusCode: status);
  }

  static Future<GetSetting> connectToApi(String token) async {
    String apiURL = Url().val + "api/integration-setting";
    log("token : " + token);
    var apiResult = await http.get(Uri.parse(apiURL), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      "Connection": "Keep-Alive",
      "Keep-Alive": "timeout=5, max=1000",
      'Authorization': 'Bearer ' + token,
    });
    log("token : " + token);
    log("SETTINGS : " + apiResult.body);
    dynamic jsonObject = null;
    try {
      if (apiResult.statusCode != 500) {
        jsonObject = json.decode(apiResult.body);
      } else {
        int code = apiResult.statusCode;
        jsonObject = json
            .decode("{\"status\": $code,\"message\": \"Status Code $code\"}");
      }
    } catch (x) {
      jsonObject =
          json.decode("{\"status\": 800,\"message\": \"Status Code 800\"}");
      return GetSetting.createGetSetting(jsonObject, 800);
    }

    return GetSetting.createGetSetting(jsonObject, apiResult.statusCode);
  }
}

class MqttConnection {
  final int id;
  final String ipAddress;
  final String port;
  final String connectionType;
  final String dataType;
  final String username;
  final String password;
  final DateTime createdAt;
  final DateTime updatedAt;

  MqttConnection({
    required this.id,
    required this.ipAddress,
    required this.port,
    required this.connectionType,
    required this.dataType,
    required this.username,
    required this.password,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MqttConnection.fromJson(Map<String, dynamic> json) {
    return MqttConnection(
      id: json['id'],
      ipAddress: json['ip_address'] ?? "",
      port: json['port'] ?? "",
      connectionType: json['connection_type'] ?? "",
      dataType: json['data_type'] ?? "",
      username: json['username'] ?? "",
      password: json['password'] ?? "",
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
