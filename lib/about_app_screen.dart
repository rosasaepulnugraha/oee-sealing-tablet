import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:fancy_snackbar/fancy_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:lottie/lottie.dart';
import '../constants/color_constant.dart';
import '../pdf_api.dart';

class AboutAppScreen extends StatefulWidget {
  const AboutAppScreen({super.key});

  @override
  State<AboutAppScreen> createState() => _AboutAppScreenState();
}

class _AboutAppScreenState extends State<AboutAppScreen> {
  File? pathFile;
  show() async {
    setState(() {
      _isLoading = true;
    });
    final path = 'assets/document/about.pdf';
    pathFile = await PDFApi.loadAsset(path);
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  void initState() {
    show();
    super.initState();
  }

  bool _isLoading = false;
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  int? pages = 0;
  int? currentPage = 0;
  int indexPage = 0;
  bool isReady = false;
  String errorMessage = '';
  @override
  Widget build(BuildContext context) {
    final text = '${indexPage + 1} of $pages';
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About App',
        ),
        titleTextStyle: GoogleFonts.poppins(
          color: Color.fromARGB(255, 58, 58, 58),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: mBackgroundColor,
      body: LoadingOverlay(
        isLoading: _isLoading,
        // demo of some additional parameters
        opacity: 0.5,
        color: Color.fromARGB(255, 0, 0, 0),
        progressIndicator: Container(
          height: 160,
          width: 150,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset('assets/json/loadingBlue.json',
                  height: 100, width: 100),
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
          ),
        ),
        child: pathFile != null
            ? PDFView(
                filePath: pathFile!.path,
                enableSwipe: true,
                swipeHorizontal: true,
                autoSpacing: false,
                pageFling: false,
                onRender: (_pages) {
                  setState(() {
                    pages = _pages;
                    isReady = true;
                  });
                },
                onError: (error) {
                  print(error.toString());
                },
                onPageError: (page, error) {
                  print('$page: ${error.toString()}');
                },
                onViewCreated: (PDFViewController pdfViewController) {
                  _controller.complete(pdfViewController);
                },
                onPageChanged: (int? page, int? total) {
                  print('page change: $page/$total');
                },
              )
            : Container(),
      ),
    );
  }
}
