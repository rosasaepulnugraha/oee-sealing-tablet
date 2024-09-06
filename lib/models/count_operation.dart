import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class Operation {
  final int id;
  final int achievementId;
  final String bodyId;
  final String status;
  final String createdAt;
  final String updatedAt;
  final String bodyType;
  final String timeIn;
  final String? timeOut;
  final int isProcessed;
  final String position;
  final String? exists;
  final String date;
  final String dateTime;

  Operation({
    required this.id,
    required this.achievementId,
    required this.bodyId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.bodyType,
    required this.timeIn,
    this.timeOut,
    required this.isProcessed,
    required this.position,
    this.exists,
    required this.date,
    required this.dateTime,
  });

  factory Operation.fromJson(Map<String, dynamic> json) {
    return Operation(
      id: json['id'] ?? 0,
      achievementId: json['achievement_id'] ?? 0,
      bodyId: json['body_id'] ?? "",
      status: json['status'] ?? "",
      createdAt: json['created_at'] ?? "",
      updatedAt: json['updated_at'] ?? "",
      bodyType: json['body_type'] ?? "",
      timeIn: json['time_in'] ?? "",
      timeOut: json['time_out'] ?? "",
      isProcessed: json['is_processed'] ?? 0,
      position: json['position'] ?? "",
      exists: json['exists'],
      date: json['date'] ?? "",
      dateTime: json['date_time'] ?? "",
    );
  }
}

class OperationPagination {
  final int currentPage;
  List<Operation> data;
  final int lastPage;
  final String? nextPageUrl;
  final String? prevPageUrl;
  final int total;

  OperationPagination({
    required this.currentPage,
    required this.data,
    required this.lastPage,
    this.nextPageUrl,
    this.prevPageUrl,
    required this.total,
  });

  factory OperationPagination.fromJson(Map<String, dynamic> json) {
    var operationsData = (json['data'] as List).map((operationJson) {
      return Operation.fromJson(operationJson);
    }).toList();

    return OperationPagination(
      currentPage: json['current_page'],
      data: operationsData,
      lastPage: json['last_page'],
      nextPageUrl: json['next_page_url'],
      prevPageUrl: json['prev_page_url'],
      total: json['total'],
    );
  }
}

class Summaries {
  final int ns700P;
  final int rearBody;
  final int fs700P;
  final int vtP;
  final int spareparts;

  Summaries({
    required this.ns700P,
    required this.rearBody,
    required this.fs700P,
    required this.vtP,
    required this.spareparts,
  });

  factory Summaries.fromJson(Map<String, dynamic> json) {
    return Summaries(
      ns700P: json['700P/NS'] ?? 0,
      rearBody: json['Rear Body'] ?? 0,
      fs700P: json['700P/FS'] ?? 0,
      vtP: json['VT/P'] ?? 0,
      spareparts: json['Spareparts'] ?? 0,
    );
  }
}

class CountOperation {
  final int? okCount;
  final int? ngCount;
  final int? totalCount;
  final OperationPagination? operations;
  final Summaries? summaries;
  final String message;
  final int status;

  CountOperation({
    this.okCount,
    this.ngCount,
    this.totalCount,
    this.operations,
    this.summaries,
    this.message = "",
    this.status = 0,
  });

  factory CountOperation.createCountOperation(
      Map<String, dynamic> json, int status) {
    return CountOperation(
      message: json['message'] ?? "",
      status: status,
      okCount: json['okCount'],
      ngCount: json['ngCount'],
      totalCount: json['totalCount'],
      operations: OperationPagination.fromJson(json['operations']),
      summaries: Summaries.fromJson(json['summaries']),
    );
  }

  static Future<CountOperation> connectToApi(String url, String token) async {
    dynamic jsonObject;
    try {
      String apiURL = url;
      log("URL: $url");
      var apiResult = await http.get(Uri.parse(apiURL), headers: {
        'Accept': 'application/json',
        'Connection': 'Keep-Alive',
        'Keep-Alive': 'timeout=5, max=10000',
        'Authorization': 'Bearer $token',
      });
      log("Response: ${apiResult.body}");

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
