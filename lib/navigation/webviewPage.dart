import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../url.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late InAppWebViewController _webViewController;

  late final WebViewController _controller;
  var storage = new FlutterSecureStorage();
  getUrl() async {
    String token = await storage.read(key: "webViewToken") ?? "";
    url = '${Url().val}public-tracking?token=' + token;
    log(url);
  }

  String url = "";
  bool wait = true;

  @override
  void initState() {
    super.initState();
    getUrl();
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        wait = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: wait
          ? Center(child: CircularProgressIndicator())
          : InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri.uri(Uri.parse(url))),
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  useShouldOverrideUrlLoading: true,
                  mediaPlaybackRequiresUserGesture: false,
                ),
                android: AndroidInAppWebViewOptions(
                  useHybridComposition: true,
                ),
              ),
              onWebViewCreated: (InAppWebViewController controller) {
                _webViewController = controller;
              },
              onLoadStart: (controller, url) {
                print("Started loading: $url");
              },
              onLoadStop: (controller, url) async {
                print("Stopped loading: $url");
              },
            ),
    );
  }
}
