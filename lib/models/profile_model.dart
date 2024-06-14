import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:isuzu_oee_app/url.dart';

class Profile {
  int? statusCode;
  final String? message;
  final User? user;

  Profile({this.statusCode, this.message, this.user});

  factory Profile.createProfile(Map<String, dynamic> object, int status) {
    return Profile(
        message: object['message'] ?? "",
        user: status == 200
            ? object != null
                ? User.fromJson(object)
                : null
            : null,
        statusCode: status);
  }

  static Future<Profile> connectToApi(String token) async {
    String apiURL = Url().val + "api/profile";
    log("token : " + token);
    var apiResult = await http.get(Uri.parse(apiURL), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      "Connection": "Keep-Alive",
      "Keep-Alive": "timeout=5, max=1000",
      'Authorization': 'Bearer ' + token,
    });
    log("token : " + token);
    log("PROFILE : " + apiResult.body);
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
      return Profile.createProfile(jsonObject, 800);
    }

    return Profile.createProfile(jsonObject, apiResult.statusCode);
  }
}

class User {
  final int id;
  final int userId;
  final String name;
  final String employeeId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String picture;
  final String email;
  final String division;

  User({
    required this.id,
    required this.userId,
    required this.name,
    required this.employeeId,
    required this.createdAt,
    required this.updatedAt,
    required this.picture,
    required this.email,
    required this.division,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    log(json['picture']);
    return User(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'] ?? "",
      employeeId: json['employee_id'] ?? "",
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      picture: json['picture'] ?? "",
      email: json['email'] ?? "",
      division: json['division'] ?? "",
    );
  }
}
