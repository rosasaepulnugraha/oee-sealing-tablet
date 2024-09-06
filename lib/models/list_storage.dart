import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class ListStorage {
  int status;
  final String message;
  final OperationList? data;

  ListStorage({this.message = "", this.status = 0, this.data});

  factory ListStorage.createListStorage(
      Map<String, dynamic> object, int status) {
    OperationList operationList = OperationList.fromJson(object);
    // List<Plant> plants =
    //     jsonData.map((plantJson) => Plant.fromJson(plantJson)).toList();

    // log("Tanaman " + object.toString());
    // log(Intepretasi.fromJson(object['P']).SRendah.toString());
    return ListStorage(
      message: object['message'] ?? "",
      status: status,
      data: operationList,
    );
  }

  static Future<ListStorage> connectToApi(String url, String token) async {
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
      log("OPPPPP " + apiResult.body);
      if (apiResult.statusCode != 500) {
        jsonObject = json.decode(apiResult.body);
      } else {
        int code = apiResult.statusCode;
        jsonObject = json
            .decode("{\"status\": $code,\"message\": \"Status Code $code\"}");
      }
      return ListStorage.createListStorage(jsonObject, apiResult.statusCode);
    } catch (x) {
      log(x.toString());
      jsonObject =
          json.decode("{\"status\": 501,\"message\": \"Terjadi kesalahan\"}");
      return ListStorage.createListStorage(jsonObject, 501);
    }
  }
}

class Operation {
  final int id;
  final String operation;
  final DateTime dateIn;
  final DateTime dateOut;
  final String bodyId;
  final String variant;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int isProcessed;
  final String parsedCreatedAt;
  final String timeIn;
  final String timeOut;

  Operation({
    required this.id,
    required this.operation,
    required this.dateIn,
    required this.dateOut,
    required this.bodyId,
    required this.variant,
    required this.createdAt,
    required this.updatedAt,
    required this.isProcessed,
    required this.parsedCreatedAt,
    required this.timeIn,
    required this.timeOut,
  });

  // Factory constructor to create an Operation from JSON
  factory Operation.fromJson(Map<String, dynamic> json) {
    return Operation(
      id: json['id'] ?? 999,
      operation: json['operation'] ?? "",
      dateIn: DateTime.parse(json['date_in']),
      dateOut: DateTime.parse(json['date_out']),
      bodyId: json['body_id'] ?? "",
      variant: json['variant'] ?? "",
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isProcessed: json['is_processed'] ?? 0,
      parsedCreatedAt: json['parsed_created_at'],
      timeIn: json['time_in'] ?? "",
      timeOut: json['time_out'] ?? "",
    );
  }

  // Method to convert an Operation object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'operation': operation,
      'date_in': dateIn.toIso8601String(),
      'date_out': dateOut.toIso8601String(),
      'body_id': bodyId,
      'variant': variant,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_processed': isProcessed,
      'parsed_created_at': parsedCreatedAt,
      'time_in': timeIn,
      'time_out': timeOut,
    };
  }
}

class OperationList {
  final int? currentPage;
  final List<Operation>? data;
  final String? firstPageUrl;
  final int? from;
  final int? lastPage;
  final String? lastPageUrl;
  final List<Link>? links;
  final String? nextPageUrl;
  final String? path;
  final int? perPage;
  final String? prevPageUrl;
  final int? to;
  final int? total;

  OperationList({
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

  factory OperationList.fromJson(Map<String, dynamic> json) {
    var list = json['data'] == null ? [] : json['data'] as List;
    List<Operation> operations =
        list.map((i) => Operation.fromJson(i)).toList();

    var linksList = json['links'] as List;
    List<Link> links = linksList.map((i) => Link.fromJson(i)).toList();

    return OperationList(
      currentPage: json['current_page'],
      data: operations,
      firstPageUrl: json['first_page_url'],
      from: json['from'],
      lastPage: json['last_page'],
      lastPageUrl: json['last_page_url'],
      links: links,
      nextPageUrl: json['next_page_url'],
      path: json['path'],
      perPage: json['per_page'],
      prevPageUrl: json['prev_page_url'],
      to: json['to'],
      total: json['total'],
    );
  }
}

class Link {
  final String? url;
  final String? label;
  final bool? active;

  Link({
    required this.url,
    required this.label,
    required this.active,
  });

  factory Link.fromJson(Map<String, dynamic> json) {
    return Link(
      url: json['url'],
      label: json['label'],
      active: json['active'],
    );
  }
}
