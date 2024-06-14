import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:fancy_snackbar/fancy_snackbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:isuzu_oee_app/main.dart';
import 'package:isuzu_oee_app/url.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'constants/color_constant.dart';
import 'custom/searchInput.dart';
import 'download_progress_dialog.dart';
import 'models/list_downtime.dart';

class DowntimeReportScreen extends StatefulWidget {
  const DowntimeReportScreen({super.key});

  @override
  State<DowntimeReportScreen> createState() => _DowntimeReportScreenState();
}

class _DowntimeReportScreenState extends State<DowntimeReportScreen> {
  double windowWidth = 0;

  int _currentPage = 1;
  int _itemsPerPage = 20; // Ubah sesuai kebutuhan
  List<String> _data = List.generate(100, (index) => 'Item ${index + 1}');

  TextEditingController controllerSearchLoading = new TextEditingController();
  List<String> get _currentItems {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    return _data.sublist(
        startIndex, endIndex < _data.length ? endIndex : _data.length);
  }

  String formattedDate = "";

  Timer? _timer;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getAll(false);
    _timer = new Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {
        DateTime now = DateTime.now();
        formattedDate = DateFormat('d MMMM yyyy', 'id_ID').format(now);
      });
    });
  }

  @override
  void dispose() {
    try {
      _timer!.cancel();
    } catch (x) {}
    super.dispose();
  }

  DateTime selectedDate = DateTime.now();
  DateTime selectedDateEnd = DateTime.now();
  DateFormat formatter = DateFormat('yyyy-MM-dd');

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1950),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: mBlueColor, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: mTitleBlue, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                primary: mTitleBlue, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectDateEnd(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateEnd,
      firstDate: DateTime(1950),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: mBlueColor, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: mTitleBlue, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                primary: mTitleBlue, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDateEnd) {
      setState(() {
        selectedDateEnd = picked;
      });
    }
  }

  // Future<void> saveRemember(String data) async {
  //   final directory = await getApplicationDocumentsDirectory();
  //   final file = File('${directory.path}/remember.txt');
  //   await file.writeAsString(data);
  // }

  // Future<void> saveToken(String data) async {
  //   try {
  //     final directory = await getApplicationDocumentsDirectory();
  //     final file = File('${directory.path}/token.txt');
  //     await file.writeAsString(data);
  //   } catch (x) {
  //     log(x.toString());
  //   }
  // }

  // Future<String> readToken() async {
  //   try {
  //     final directory = await getApplicationDocumentsDirectory();
  //     final file = File('${directory.path}/token.txt');
  //     return await file.readAsString();
  //   } catch (e) {
  //     // Handle errors
  //     return '';
  //   }
  // }

  bool value = false;

  Future<bool> requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }

  Future<bool> checkPermission() async {
    ///For Check permission..
    if (Platform.isAndroid
        ? !await requestPermission(Permission.storage) &&
            !await requestPermission(Permission.manageExternalStorage)
        : !await requestPermission(Permission.storage)) {
      await CupertinoAlertDialog(
        title: const Text("Photos, File & Videos permission"),
        content: const Text(
            " Photos & Videos permission should be granted to connect with device, would you like to go to app settings to give Bluetooth & Location permissions?"),
        actions: <Widget>[
          TextButton(
              child: const Text('No thanks'),
              onPressed: () {
                Navigator.pop(context);
              }),
          TextButton(
              child: const Text('Ok'),
              onPressed: () async {
                Navigator.pop(context);
                await openAppSettings();
              })
        ],
      );
      return false;
    } else {
      return true;
    }
  }

  Future<String> getFilePath(String fileName) async {
    // Get the directory for the app's documents directory
    final Directory appDocumentsDirectory =
        await getApplicationDocumentsDirectory();

    // Construct the file path
    final String filePath = '${appDocumentsDirectory.path}/$fileName';

    return filePath;
  }

  String nextUrl = "";
  String prevUrl = "";
  String token = "";
  bool _isLoading = false;
  final storage = FlutterSecureStorage();

  var resultListDevice = new ListDowntime();
  void _getAll(bool search) async {
    setState(() {
      _isLoading = true;
    });
    try {
      token = await storage.read(key: "token") ?? "";

      ListDowntime.connectToApi(
              Url().val +
                  "api/down-time-report?operation=SEALING&per_page=6" +
                  (search ? "&search=${controllerSearchLoading.text}" : ""),
              token)
          .then((value) async {
        resultListDevice = value;
        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            _isLoading = false;
          });
        });
        //print(storage.read(key: "token"));
        if (value.status == 200) {
          Future.delayed(Duration(seconds: 3), () {
            setState(() {
              _isLoading = false;
            });
          });

          nextUrl = value.data != null
              ? value.data!.downTimes != null
                  ? value.data!.downTimes!.nextPageUrl ?? ""
                  : ""
              : "";
          prevUrl = value.data != null
              ? value.data!.downTimes != null
                  ? value.data!.downTimes!.prevPageUrl ?? ""
                  : ""
              : "";
          setState(() {});
        } else {
          if (value.message.contains('Unauthenticated')) {
            FancySnackbar.showSnackbar(
              context,
              snackBarType: FancySnackBarType.error,
              title: "Information!",
              message:
                  "Your account is used by someone else, please log in again",
              duration: 5,
              onCloseEvent: () {},
            );
            await storage.write(key: "keep", value: "false");
            await storage.write(key: "token", value: "");
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => MyApp()),
                (Route<dynamic> route) => false);
          }
          // FancySnackbar.showSnackbar(
          //   context,
          //   snackBarType: FancySnackBarType.error,
          //   title: "Information!",
          //   message: profileResult.message,
          //   duration: 5,
          //   onCloseEvent: () {},
          // );
        }
        setState(() {});
      });
    } catch (x) {
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });
      });
    }
  }

  void _nextPage() async {
    setState(() {
      _isLoading = true;
    });
    try {
      token = await storage.read(key: "token") ?? "";
      ListDowntime.connectToApi(nextUrl, token).then((value) async {
        resultListDevice = value;
        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            _isLoading = false;
          });
        });
        //print(storage.read(key: "token"));
        if (value.status == 200) {
          Future.delayed(Duration(seconds: 3), () {
            setState(() {
              _isLoading = false;
            });
          });

          nextUrl = value.data != null
              ? value.data!.downTimes != null
                  ? value.data!.downTimes!.nextPageUrl ?? ""
                  : ""
              : "";
          prevUrl = value.data != null
              ? value.data!.downTimes != null
                  ? value.data!.downTimes!.prevPageUrl ?? ""
                  : ""
              : "";
          setState(() {});
        } else {
          if (value.message.contains('Unauthenticated')) {
            FancySnackbar.showSnackbar(
              context,
              snackBarType: FancySnackBarType.error,
              title: "Information!",
              message:
                  "Your account is used by someone else, please log in again",
              duration: 5,
              onCloseEvent: () {},
            );
            await storage.write(key: "keep", value: "false");
            await storage.write(key: "token", value: "");
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => MyApp()),
                (Route<dynamic> route) => false);
          }
          // FancySnackbar.showSnackbar(
          //   context,
          //   snackBarType: FancySnackBarType.error,
          //   title: "Information!",
          //   message: profileResult.message,
          //   duration: 5,
          //   onCloseEvent: () {},
          // );
        }
        setState(() {});
      });
    } catch (x) {
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });
      });
    }
  }

  void _prevPage() async {
    setState(() {
      _isLoading = true;
    });
    try {
      token = await storage.read(key: "token") ?? "";

      ListDowntime.connectToApi(prevUrl, token).then((value) async {
        resultListDevice = value;
        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            _isLoading = false;
          });
        });
        //print(storage.read(key: "token"));
        if (value.status == 200) {
          Future.delayed(Duration(seconds: 3), () {
            setState(() {
              _isLoading = false;
            });
          });

          nextUrl = value.data != null
              ? value.data!.downTimes != null
                  ? value.data!.downTimes!.nextPageUrl ?? ""
                  : ""
              : "";
          prevUrl = value.data != null
              ? value.data!.downTimes != null
                  ? value.data!.downTimes!.prevPageUrl ?? ""
                  : ""
              : "";
          setState(() {});
        } else {
          if (value.message.contains('Unauthenticated')) {
            FancySnackbar.showSnackbar(
              context,
              snackBarType: FancySnackBarType.error,
              title: "Information!",
              message:
                  "Your account is used by someone else, please log in again",
              duration: 5,
              onCloseEvent: () {},
            );
            await storage.write(key: "keep", value: "false");
            await storage.write(key: "token", value: "");
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => MyApp()),
                (Route<dynamic> route) => false);
          }
          // FancySnackbar.showSnackbar(
          //   context,
          //   snackBarType: FancySnackBarType.error,
          //   title: "Information!",
          //   message: profileResult.message,
          //   duration: 5,
          //   onCloseEvent: () {},
          // );
        }
        setState(() {});
      });
    } catch (x) {
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    return Scaffold(
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
        child: Container(
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 4,
                    margin: EdgeInsets.only(
                        left: windowWidth < 1400 ? 10 : 20, right: 8),
                    padding: windowWidth < 1400
                        ? EdgeInsets.symmetric(vertical: 10, horizontal: 10)
                        : EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    decoration: BoxDecoration(
                        // boxShadow: [
                        //   BoxShadow(
                        //     color:
                        //         const Color.fromARGB(255, 214, 214, 214)
                        //             .withOpacity(0.1),
                        //     spreadRadius: 5,
                        //     blurRadius: 5,
                        //     offset: Offset(0, 2),
                        //   )
                        // ],
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15)),
                    child: Row(
                      children: [
                        Container(
                          padding: windowWidth < 1400
                              ? EdgeInsets.all(10)
                              : EdgeInsets.all(15),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: <Color>[
                                    Color.fromARGB(255, 1, 121, 219),
                                    Color.fromARGB(255, 95, 183, 255)
                                  ]),
                              // color: mDarkBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(50)),
                          child: Icon(
                            Icons.more_time_rounded,
                            color: Colors.white,
                            size: windowWidth < 1400 ? 20 : 25,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Mostly Reason",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                  color: mDarkBlue.withOpacity(0.5),
                                  fontSize: windowWidth < 1400 ? 11 : 14,
                                  fontWeight: FontWeight.w600),
                            ),
                            Text(
                              resultListDevice.data != null
                                  ? resultListDevice.data!.frequentReason ==
                                          null
                                      ? "-"
                                      : resultListDevice.data!.frequentReason
                                          .toString()
                                  : "",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                  color: mDarkBlue,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 6,
                    margin: EdgeInsets.only(
                        left: windowWidth < 1400 ? 10 : 20, right: 8),
                    padding: windowWidth < 1400
                        ? EdgeInsets.symmetric(vertical: 10, horizontal: 10)
                        : EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    decoration: BoxDecoration(
                        // boxShadow: [
                        //   BoxShadow(
                        //     color:
                        //         const Color.fromARGB(255, 214, 214, 214)
                        //             .withOpacity(0.1),
                        //     spreadRadius: 5,
                        //     blurRadius: 5,
                        //     offset: Offset(0, 2),
                        //   )
                        // ],
                        color: Colors.white,
                        borderRadius: windowWidth < 1400
                            ? BorderRadius.circular(10)
                            : BorderRadius.circular(15)),
                    child: Row(
                      children: [
                        Container(
                          padding: windowWidth < 1400
                              ? EdgeInsets.all(10)
                              : EdgeInsets.all(15),
                          decoration: BoxDecoration(
                              color: mDarkBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(50)),
                          child: Icon(
                            Icons.file_copy,
                            color: mBlueColor,
                            size: windowWidth < 1400 ? 20 : 25,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Longest Duration",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                  color: mDarkBlue.withOpacity(0.5),
                                  fontSize: windowWidth < 1400 ? 11 : 14,
                                  fontWeight: FontWeight.w600),
                            ),
                            Text(
                              resultListDevice.data != null
                                  ? resultListDevice.data!.longestDuration
                                      .toString()
                                  : "",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                  color: mDarkBlue,
                                  fontSize: windowWidth < 1400 ? 17 : 22,
                                  fontWeight: FontWeight.w600),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
              tableDowntime()
            ],
          ),
        ),
      ),
    );
  }

  Expanded tableDowntime() {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(
            left: windowWidth < 1400 ? 10 : 20,
            right: windowWidth < 1400 ? 10 : 20,
            top: windowWidth < 1400 ? 10 : 20),
        padding: windowWidth < 1400
            ? EdgeInsets.symmetric(vertical: 10, horizontal: 10)
            : EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
            // boxShadow: [
            //   BoxShadow(
            //     color:
            //         const Color.fromARGB(255, 214, 214, 214)
            //             .withOpacity(0.1),
            //     spreadRadius: 5,
            //     blurRadius: 5,
            //     offset: Offset(0, 2),
            //   )
            // ],
            color: Colors.white,
            borderRadius: windowWidth < 1400
                ? BorderRadius.circular(10)
                : BorderRadius.circular(15)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 180,
                  padding: EdgeInsets.only(left: 20, top: 5),
                  child: Text(
                    "DOWNTIME TABLE",
                    textAlign: TextAlign.start,
                    style: GoogleFonts.poppins(
                        color: mDarkBlue,
                        fontSize: windowWidth < 1400 ? 18 : 23,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Color.fromARGB(255, 190, 190, 190)),
                          color: Color.fromARGB(255, 255, 255, 255),
                          borderRadius: BorderRadius.circular(30)),
                      child: InkWell(
                        onTap: (resultListDevice.data != null
                                    ? resultListDevice.data!.downTimes != null
                                        ? resultListDevice
                                                .data!.downTimes!.prevPageUrl ??
                                            ""
                                        : ""
                                    : "") !=
                                ""
                            ? () => setState(() => _prevPage())
                            : null,
                        child: Icon(
                          Icons.arrow_back_ios_rounded,
                          size: 10,
                          color: (resultListDevice.data != null
                                      ? resultListDevice.data!.downTimes != null
                                          ? resultListDevice.data!.downTimes!
                                                  .prevPageUrl ??
                                              ""
                                          : ""
                                      : "") !=
                                  ""
                              ? mTitleBlue
                              : Colors.grey,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 7),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                          color: mTitleBlue,
                          borderRadius: BorderRadius.circular(30)),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          "${resultListDevice.data != null ? resultListDevice.data!.downTimes != null ? resultListDevice.data!.downTimes!.currentPage.toString() : "" : ""}",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Color.fromARGB(255, 190, 190, 190)),
                          color: Color.fromARGB(255, 255, 255, 255),
                          borderRadius: BorderRadius.circular(30)),
                      child: InkWell(
                        onTap: (resultListDevice.data != null
                                    ? resultListDevice.data!.downTimes != null
                                        ? resultListDevice
                                                .data!.downTimes!.nextPageUrl ??
                                            ""
                                        : ""
                                    : "") !=
                                ""
                            ? () => setState(() => _nextPage())
                            : null,
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 10,
                          color: (resultListDevice.data != null
                                      ? resultListDevice.data!.downTimes != null
                                          ? resultListDevice.data!.downTimes!
                                                  .nextPageUrl ??
                                              ""
                                          : ""
                                      : "") !=
                                  ""
                              ? mTitleBlue
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 260,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Container(
                      //   margin: EdgeInsets.only(right: 15),
                      //   decoration: BoxDecoration(
                      //       boxShadow: [
                      //         BoxShadow(
                      //           color: Colors.grey.withOpacity(0.2),
                      //           spreadRadius: 5,
                      //           blurRadius: 5,
                      //           offset: Offset(0, 2),
                      //         )
                      //       ],
                      //       color: mBlueColor,
                      //       borderRadius: BorderRadius.circular(30)),
                      //   padding:
                      //       EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                      //   child: Center(
                      //     child: Text(
                      //       "Report Downtime",
                      //       style: GoogleFonts.poppins(
                      //           color: Colors.white, fontSize: 16),
                      //     ),
                      //   ),
                      // ),
                      Container(
                          width: 260,
                          padding:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F7FE),
                            borderRadius: BorderRadius.circular(40),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF4F7FE),
                                spreadRadius: 3,
                                blurRadius: 3,
                                offset: Offset(0, 2),
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SearchInput(
                                width: 200,
                                controller: controllerSearchLoading,
                                nama: "search",
                                onclick: () {
                                  _getAll(true);
                                },
                                icons: Icons.search,
                              ),
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      showDialog(
                                          barrierDismissible: true,
                                          context: context,
                                          builder:
                                              (BuildContext dialogcontext) {
                                            String formattedDate =
                                                formatter.format(selectedDate);
                                            String formattedDateEnd = formatter
                                                .format(selectedDateEnd);
                                            return StatefulBuilder(
                                              builder:
                                                  (BuildContext dialogcontext,
                                                          setState) =>
                                                      AlertDialog(
                                                content: Container(
                                                  height: 340,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      3,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        child: Text(
                                                          "Export Data",
                                                          textAlign:
                                                              TextAlign.start,
                                                          style: GoogleFonts.poppins(
                                                              color: mDarkBlue,
                                                              fontSize:
                                                                  windowWidth <
                                                                          1400
                                                                      ? 14
                                                                      : 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 15,
                                                      ),
                                                      Container(
                                                        margin: EdgeInsets.only(
                                                            bottom: 10,
                                                            top: 20),
                                                        child: Text(
                                                          "Start Date",
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  fontSize: 14,
                                                                  color:
                                                                      mTitleBlue,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                        ),
                                                      ),
                                                      InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            _selectDate(
                                                                    dialogcontext)
                                                                .then((value) {
                                                              setState(() {
                                                                formattedDate =
                                                                    formatter
                                                                        .format(
                                                                            selectedDate);
                                                              });
                                                            });
                                                          });
                                                        },
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              border: Border.all(
                                                                  color: Color
                                                                      .fromARGB(
                                                                          249,
                                                                          241,
                                                                          241,
                                                                          241),
                                                                  width: 1.5),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                          child: Row(
                                                            children: <Widget>[
                                                              SizedBox(
                                                                width: 20,
                                                              ),
                                                              Expanded(
                                                                child:
                                                                    TextField(
                                                                  // controller:
                                                                  //     controllerSearchLoading,
                                                                  enabled:
                                                                      false,
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600),
                                                                  decoration: InputDecoration(
                                                                      hintStyle: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            14,
                                                                      ),
                                                                      contentPadding: EdgeInsets.symmetric(vertical: 5),
                                                                      border: InputBorder.none,
                                                                      hintText: formattedDate),
                                                                  onChanged:
                                                                      (val) {},
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        margin: EdgeInsets.only(
                                                            bottom: 10,
                                                            top: 20),
                                                        child: Text(
                                                          "End Date",
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  fontSize: 14,
                                                                  color:
                                                                      mTitleBlue,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                        ),
                                                      ),
                                                      InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            _selectDateEnd(
                                                                    dialogcontext)
                                                                .then((value) {
                                                              setState(() {
                                                                formattedDateEnd =
                                                                    formatter
                                                                        .format(
                                                                            selectedDateEnd);
                                                              });
                                                            });
                                                          });
                                                        },
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              border: Border.all(
                                                                  color: Color
                                                                      .fromARGB(
                                                                          249,
                                                                          241,
                                                                          241,
                                                                          241),
                                                                  width: 1.5),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                          child: Row(
                                                            children: <Widget>[
                                                              SizedBox(
                                                                width: 20,
                                                              ),
                                                              Expanded(
                                                                child:
                                                                    TextField(
                                                                  enabled:
                                                                      false,
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600),
                                                                  decoration: InputDecoration(
                                                                      hintStyle: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            14,
                                                                      ),
                                                                      contentPadding: EdgeInsets.symmetric(vertical: 5),
                                                                      border: InputBorder.none,
                                                                      hintText: formattedDateEnd),
                                                                  onChanged:
                                                                      (val) {},
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 35,
                                                      ),
                                                      InkWell(
                                                        onTap: () async {
                                                          if (_isLoading) {
                                                            return;
                                                          }
                                                          Future.delayed(
                                                              const Duration(
                                                                  milliseconds:
                                                                      0), () {
                                                            setState(() {
                                                              _isLoading = true;
                                                            });
                                                          });
                                                          token = await storage
                                                                  .read(
                                                                      key:
                                                                          "token") ??
                                                              "";

                                                          try {
                                                            bool result =
                                                                await checkPermission();
                                                            if (result) {
                                                              String?
                                                                  folderPath =
                                                                  await FilePicker
                                                                      .platform
                                                                      .getDirectoryPath();
                                                              if (folderPath !=
                                                                  null) {
                                                                print(
                                                                    "PATHHH $folderPath");

                                                                DateTime
                                                                    datetime =
                                                                    DateTime
                                                                        .now();
                                                                String
                                                                    formattedDateTime =
                                                                    DateFormat(
                                                                            'yyyy-MM-dd h mm ss a')
                                                                        .format(
                                                                            datetime);
                                                                showDialog(
                                                                    barrierDismissible:
                                                                        false,
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (dialogcontext) {
                                                                      return DownloadProgressDialog(
                                                                        path:
                                                                            "$folderPath/Export Downtime ${formattedDateTime}.xlsx",
                                                                        token:
                                                                            token,
                                                                        baseUrl:
                                                                            Url().val +
                                                                                "api/downtime-export?start_date=${formattedDate}&end_date=${formattedDateEnd}",
                                                                      );
                                                                    }).then((value) {
                                                                  setState(() {
                                                                    _isLoading =
                                                                        false;
                                                                  });
                                                                  Navigator.pop(
                                                                      context);
                                                                  // FancySnackbar.showSnackbar(
                                                                  //   context,
                                                                  //   snackBarType: FancySnackBarType.success,
                                                                  //   title: "Information!",
                                                                  //   message: "Export was successful",
                                                                  //   duration: 5,
                                                                  //   onCloseEvent: () {},
                                                                  // );
                                                                });
                                                              }
                                                            } else {
                                                              FancySnackbar
                                                                  .showSnackbar(
                                                                context,
                                                                snackBarType:
                                                                    FancySnackBarType
                                                                        .error,
                                                                title:
                                                                    "Information!",
                                                                message:
                                                                    "No permission to read and write.",
                                                                duration: 2,
                                                                onCloseEvent:
                                                                    () {
                                                                  Navigator.pop(
                                                                      context);
                                                                  // Navigator.pushReplacement(context,
                                                                  //     MaterialPageRoute(builder: (context) {
                                                                  //   return NavigateScreen(
                                                                  //     id: 1,
                                                                  //   );
                                                                  // }));
                                                                },
                                                              );
                                                            }
                                                          } catch (x) {
                                                            Future.delayed(
                                                                const Duration(
                                                                    milliseconds:
                                                                        2000),
                                                                () {
                                                              setState(() {
                                                                _isLoading =
                                                                    false;
                                                              });
                                                            });
                                                          }
                                                        },
                                                        child: Container(
                                                          // margin: EdgeInsets.only(right: 15),
                                                          decoration: BoxDecoration(
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Colors
                                                                      .grey
                                                                      .withOpacity(
                                                                          0.2),
                                                                  spreadRadius:
                                                                      5,
                                                                  blurRadius: 5,
                                                                  offset:
                                                                      Offset(
                                                                          0, 2),
                                                                )
                                                              ],
                                                              color: _isLoading
                                                                  ? const Color
                                                                          .fromARGB(
                                                                      255,
                                                                      179,
                                                                      179,
                                                                      179)
                                                                  : mBlueColor,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 12,
                                                                  horizontal:
                                                                      15),
                                                          child: Center(
                                                            child: Text(
                                                              "Export",
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          16),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          });
                                    },
                                    child: Icon(
                                      Icons.download_for_offline_rounded,
                                      color: mBlueColor,
                                      size: 30,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                ],
                              ),
                            ],
                          )),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: windowWidth < 1400 ? 10 : 20,
            ),
            Container(
              width: windowWidth,
              margin: EdgeInsets.symmetric(
                  horizontal: windowWidth < 1400 ? 10 : 20),
              // color: Colors.white,
              padding: EdgeInsets.all(windowWidth < 1400 ? 3 : 5),
              decoration: BoxDecoration(
                  color: Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: windowWidth / 13,
                    child: Text(
                      "No",
                      textAlign: TextAlign.start,
                      style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 11,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  Container(
                    width: windowWidth / 7,
                    child: Text(
                      "Date",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 11,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  Container(
                    width: windowWidth / 7,
                    child: Text(
                      "Start Time",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 11,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  Container(
                    width: windowWidth / 8,
                    child: Text(
                      "End Time",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 11,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  Container(
                    width: windowWidth / 8,
                    child: Text(
                      "Duration",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 11,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  Container(
                    width: windowWidth / 8,
                    child: Text(
                      "Reason",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 11,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            Expanded(
                child: Container(
              width: windowWidth,
              margin: EdgeInsets.symmetric(
                  horizontal: windowWidth < 1400 ? 10 : 20),
              // color: Colors.white,
              child: SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(
                        resultListDevice.data != null
                            ? (resultListDevice.data!.downTimes != null
                                ? resultListDevice.data!.downTimes!.data.length
                                : 0)
                            : 0, (index) {
                      final item =
                          resultListDevice.data!.downTimes!.data[index];
                      return Container(
                        width: windowWidth,
                        margin: EdgeInsets.only(bottom: 0),
                        padding: EdgeInsets.all(windowWidth < 1400 ? 3 : 5),
                        decoration: BoxDecoration(
                            color: Color.fromARGB(255, 255, 255, 255),
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: windowWidth / 13,
                              child: Text(
                                resultListDevice.data!.downTimes == null
                                    ? "0"
                                    : (((resultListDevice.data!.downTimes!
                                                        .currentPage! -
                                                    1) *
                                                27) +
                                            (index + 1))
                                        .toString(),
                                textAlign: TextAlign.start,
                                style: GoogleFonts.poppins(
                                    color: mDarkBlue,
                                    fontSize: windowWidth < 1400 ? 12 : 14,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            Container(
                              width: windowWidth / 7,
                              child: Text(
                                item.date,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                    color: mDarkBlue,
                                    fontSize: windowWidth < 1400 ? 12 : 14,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            Container(
                              width: windowWidth / 7,
                              child: Text(
                                item.start ?? "",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                    color: mDarkBlue,
                                    fontSize: windowWidth < 1400 ? 12 : 14,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            Container(
                              width: windowWidth / 8,
                              child: Text(
                                item.end ?? "",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                    color: mDarkBlue,
                                    fontSize: windowWidth < 1400 ? 12 : 14,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            Container(
                              width: windowWidth / 8,
                              child: Text(
                                item.downTime != null
                                    ? item.downTime.toString()
                                    : "",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                    color: mDarkBlue,
                                    fontSize: windowWidth < 1400 ? 12 : 14,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            Container(
                              width: windowWidth / 8,
                              child: Text(
                                item.reason.reason,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                    color: mDarkBlue,
                                    fontSize: windowWidth < 1400 ? 12 : 14,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      );
                    })),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
