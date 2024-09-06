import 'dart:developer';

import 'package:fancy_snackbar/fancy_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../models/file_download_model.dart';

class DownloadProgressDialog extends StatefulWidget {
  String path;
  String token;
  String baseUrl;
  DownloadProgressDialog(
      {super.key,
      required this.path,
      required this.token,
      required this.baseUrl});
  @override
  State<DownloadProgressDialog> createState() => _DownloadProgressDialogState();
}

class _DownloadProgressDialogState extends State<DownloadProgressDialog> {
  double progress = 0.0;
  @override
  void initState() {
    _startDownload();
    super.initState();
  }

  void _startDownload() async {
    log("URL : " + widget.baseUrl);
    log("TOKEN : " + widget.token);
    log("PATH : " + widget.path);
    FileDownload().startDownloading(context, (status) {
      setState(() {
        // progress = recivedBytes / totalBytes;
        // int percent = (progress * 100).toInt();
        if (status == true) {
          FancySnackbar.showSnackbar(
            context,
            snackBarType: FancySnackBarType.success,
            title: "Information!",
            message: "Export was successful\nLocated : " + widget.path,
            duration: 5,
            onCloseEvent: () {},
          );
        } else {
          if (widget.path.contains('pdf')) {
            FancySnackbar.showSnackbar(
              context,
              snackBarType: FancySnackBarType.error,
              title: "Information!",
              message: "Data export failed, please export data in Excel format",
              duration: 5,
              onCloseEvent: () {},
            );
          } else {
            FancySnackbar.showSnackbar(
              context,
              snackBarType: FancySnackBarType.error,
              title: "Information!",
              message: "Data export failed",
              duration: 5,
              onCloseEvent: () {},
            );
          }
        }
      });
    }, widget.token, widget.path, widget.baseUrl);
  }

  @override
  Widget build(BuildContext context) {
    String downloadingProgress = (progress * 100).toInt().toString();
    return AlertDialog(
        content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Lottie.asset('assets/json/loadingBlue.json', height: 100, width: 100),
        SizedBox(
          height: 10,
        ),
        Text(
          'Loading ...',
          style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 17,
              color: Color.fromARGB(255, 75, 75, 75)),
        ),
      ],
    ));
  }
}
