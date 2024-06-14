import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class ListDowntime {
  int status;
  final String message;
  final DownTimeReport? data;

  ListDowntime({this.message = "", this.status = 0, this.data});

  factory ListDowntime.createListDowntime(
      Map<String, dynamic> object, int status) {
    DownTimeReport? operationList = DownTimeReport.fromJson(object);
    // List<Plant> plants =
    //     jsonData.map((plantJson) => Plant.fromJson(plantJson)).toList();

    // log("Tanaman " + object.toString());
    // log(Intepretasi.fromJson(object['P']).SRendah.toString());
    return ListDowntime(
      message: object['message'] ?? "",
      status: status,
      data: operationList,
    );
  }

  static Future<ListDowntime> connectToApi(String url, String token) async {
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
      return ListDowntime.createListDowntime(jsonObject, apiResult.statusCode);
    } catch (x) {
      log("ERR " + x.toString());
      jsonObject =
          json.decode("{\"status\": 501,\"message\": \"Terjadi kesalahan\"}");
      return ListDowntime.createListDowntime(jsonObject, 501);
    }
  }
}

class DownTimeReport {
  final String? frequentReason;
  final int? longestDuration;
  final DownTimes? downTimes;

  DownTimeReport({
    required this.frequentReason,
    required this.longestDuration,
    required this.downTimes,
  });

  factory DownTimeReport.fromJson(Map<String, dynamic> json) {
    return DownTimeReport(
      frequentReason: json['frequentReason'],
      longestDuration: json['longest_duration'],
      downTimes: DownTimes.fromJson(json['down_times']),
    );
  }
}

class DownTimes {
  final int? currentPage;
  final List<DownTime> data;
  final String firstPageUrl;
  final int? from;
  final int? lastPage;
  final String lastPageUrl;
  final List<Link> links;
  final String? nextPageUrl;
  final String path;
  final int? perPage;
  final String? prevPageUrl;
  final int? to;
  final int? total;

  DownTimes({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    required this.nextPageUrl,
    required this.path,
    required this.perPage,
    required this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory DownTimes.fromJson(Map<String, dynamic> json) {
    return DownTimes(
      currentPage: json['current_page'],
      data: (json['data'] as List<dynamic>)
          .map((item) => DownTime.fromJson(item))
          .toList(),
      firstPageUrl: json['first_page_url'],
      from: json['from'],
      lastPage: json['last_page'],
      lastPageUrl: json['last_page_url'],
      links: (json['links'] as List<dynamic>)
          .map((item) => Link.fromJson(item))
          .toList(),
      nextPageUrl: json['next_page_url'] ?? "",
      path: json['path'],
      perPage: json['per_page'],
      prevPageUrl: json['prev_page_url'] ?? "",
      to: json['to'],
      total: json['total'],
    );
  }
}

class DownTime {
  final int id;
  final int achievementId;
  final int downTime;
  final String createdAt;
  final String updatedAt;
  final int reasonId;
  final String? start;
  final String? end;
  final String date;
  final Reason reason;

  DownTime({
    required this.id,
    required this.achievementId,
    required this.downTime,
    required this.createdAt,
    required this.updatedAt,
    required this.reasonId,
    required this.start,
    required this.end,
    required this.date,
    required this.reason,
  });

  factory DownTime.fromJson(Map<String, dynamic> json) {
    return DownTime(
      id: json['id'],
      achievementId: json['achievement_id'],
      downTime: json['down_time'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      reasonId: json['reason_id'],
      start: json['start'] ?? "",
      end: json['end'] ?? "",
      date: json['date'],
      reason: Reason.fromJson(json['reason']),
    );
  }
}

class Reason {
  final int id;
  final String reason;
  final String createdAt;
  final String updatedAt;

  Reason({
    required this.id,
    required this.reason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Reason.fromJson(Map<String, dynamic> json) {
    return Reason(
      id: json['id'],
      reason: json['reason'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class Link {
  final String? url;
  final String label;
  final bool active;

  Link({
    required this.url,
    required this.label,
    required this.active,
  });

  factory Link.fromJson(Map<String, dynamic> json) {
    return Link(
      url: json['url'] ?? "",
      label: json['label'],
      active: json['active'],
    );
  }
}
