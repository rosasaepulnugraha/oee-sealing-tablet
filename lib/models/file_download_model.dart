import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'package:path_provider/path_provider.dart';

class FileDownload {
  Dio dio = Dio();
  bool isSuccess = false;

  void startDownloading(BuildContext context, final Function okCallback,
      String token, String path, String baseUrl) async {
    log(token);

    // String path = await _getFilePath(fileName);

    dio.options.headers['Authorization'] = 'Bearer $token';
    try {
      await dio.download(
        baseUrl,
        path,
        onReceiveProgress: (recivedBytes, totalBytes) {
          log('recivedBytes : ' +
              recivedBytes.toString() +
              " === totalBytes : " +
              totalBytes.toString());
          // okCallback(recivedBytes, totalBytes);
        },
        deleteOnError: true,
      ).then((_) {
        isSuccess = true;
      });
    } catch (e) {
      print("Exception$e");
    }

    if (isSuccess) {
      okCallback(true);
      Navigator.pop(context);
    } else {
      okCallback(false);
      Navigator.pop(context);
    }
  }

  Future<String> _getFilePath(String filename) async {
    Directory? dir;

    try {
      if (Platform.isIOS) {
        dir = await getApplicationDocumentsDirectory(); // for iOS
      } else {
        dir = Directory('/storage/emulated/0/Download/'); // for android
        if (!await dir.exists()) dir = (await getExternalStorageDirectory())!;
      }
    } catch (err) {
      print("Cannot get download folder path $err");
    }
    return "${dir?.path}$filename";
  }
}
