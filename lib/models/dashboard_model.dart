import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:isuzu_oee_app/url.dart';

class Dashboard {
  int? statusCode;
  final String? message;
  int? id;
  final ProductionData? data;
  bool hasOee;
  Achievement? sealingAchievement;
  Achievement? topcoatAchievement;

  Dashboard({
    this.statusCode,
    this.id,
    this.message,
    this.data,
    this.hasOee = false,
    this.sealingAchievement,
    this.topcoatAchievement,
  });

  factory Dashboard.createDashboard(Map<String, dynamic> object, int status) {
    ProductionData? productionData =
        object["data"] != null ? ProductionData.fromJson(object) : null;
    log("HAS OEE" + object["hasOee"].toString());
    return Dashboard(
      message: object['message'] ?? "",
      data: status == 200 ? productionData : null,
      id: status == 200 ? object["id"] : null,
      hasOee: status == 200 ? object["hasOee"] : false,
      statusCode: status,
      sealingAchievement: object['sealing_achievement'] != null
          ? Achievement.fromJson(object['sealing_achievement'])
          : null,
      topcoatAchievement: object['topcoat_achievement'] != null
          ? Achievement.fromJson(object['topcoat_achievement'])
          : null,
    );
  }

  static Future<Dashboard> connectToApi(String token, String type) async {
    String apiURL = Url().val + "api/desktop-dashboard?operation=$type";
    log("token : " + token);
    var apiResult = await http.get(Uri.parse(apiURL), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      "Connection": "Keep-Alive",
      "Keep-Alive": "timeout=5, max=1000",
      'Authorization': 'Bearer ' + token,
    });
    log("DASHBOARD : " + apiResult.body);
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
      log("RORRR " + x.toString());
      jsonObject =
          json.decode("{\"status\": 800,\"message\": \"Status Code 800\"}");
      return Dashboard.createDashboard(jsonObject, 800);
    }

    return Dashboard.createDashboard(jsonObject, apiResult.statusCode);
  }
}

class ProductionData {
  final int id;
  final String date;
  final int shiftId;
  final int planWos;
  final int actualWos;
  final int repair;
  final int okCount;
  final int lineStop;
  final int operationTime;
  final int ngCount;
  final Shift shift;
  final double okPercent;
  final double ngPercent;
  final Oee? oee;

  ProductionData({
    required this.id,
    required this.date,
    required this.shiftId,
    required this.planWos,
    required this.actualWos,
    required this.okCount,
    required this.repair,
    required this.lineStop,
    required this.operationTime,
    required this.ngCount,
    required this.shift,
    required this.okPercent,
    required this.ngPercent,
    required this.oee,
  });

  factory ProductionData.fromJson(Map<String, dynamic> json) {
    return ProductionData(
      id: json["data"]['id'],
      date: json["data"]['date'],
      shiftId: json["data"]['shift_id'],
      planWos: json["data"]['plan_wos'],
      actualWos: json["data"]['actual_wos'],
      repair: json["data"]['repair'],
      lineStop: json["data"]['line_stop'] ?? 0,
      operationTime: json["data"]['operation_time'] ?? 0,
      okCount: json["data"]['ok_count'],
      ngCount: json["data"]['ng_count'],
      shift: Shift.fromJson(json["data"]['shift']),
      oee: json["data"]['oee'] != null
          ? Oee.fromJson(json["data"]['oee'])
          : null,
      okPercent: json['ok_percent'].toDouble(),
      ngPercent: json['ng_percent'].toDouble(),
    );
  }
}

class Shift {
  final int id;
  final String name;

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
}

class Oee {
  final double oee;
  final double availability;
  final double performance;
  final double quality;

  Oee({
    required this.oee,
    required this.availability,
    required this.performance,
    required this.quality,
  });

  factory Oee.fromJson(Map<String, dynamic> json) {
    return Oee(
      oee: json['oee'] != null ? double.parse(json['oee']) : 0,
      availability:
          json['availability'] != null ? double.parse(json['availability']) : 0,
      performance:
          json['performance'] != null ? double.parse(json['performance']) : 0,
      quality: json['quality'] != null ? double.parse(json['quality']) : 0,
    );
  }
}

class Achievement {
  int id;
  int planWos;
  int actualWos;
  int repair;
  bool hasSession;

  Achievement({
    required this.id,
    required this.planWos,
    required this.actualWos,
    required this.repair,
    required this.hasSession,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      planWos: json['plan_wos'],
      actualWos: json['actual_wos'],
      repair: json['repair'],
      hasSession: json['has_session'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plan_wos': planWos,
      'actual_wos': actualWos,
      'repair': repair,
      'has_session': hasSession,
    };
  }
}
