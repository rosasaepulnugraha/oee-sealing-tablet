import 'dart:developer';
import 'dart:io';

import 'package:fancy_snackbar/fancy_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isuzu_oee_app/dashboard_screen.dart';
import 'package:isuzu_oee_app/downtime_report_screen.dart';
import 'package:isuzu_oee_app/home_screen.dart';
import 'package:isuzu_oee_app/main.dart';
import 'package:isuzu_oee_app/plc_setting_screen.dart';
import 'package:isuzu_oee_app/profile_management_screen.dart';
import 'package:isuzu_oee_app/report_quality_screen.dart';
import 'package:isuzu_oee_app/url.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:window_size/window_size.dart' as window_size;

import 'constants/color_constant.dart';
import 'models/dashboard_model.dart';
import 'models/profile_model.dart';
import 'navigation/time_cubit.dart';
import 'navigation/webviewPage.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int currentPage = 0;
  double windowWidth = 0;
  bool _isLoading = false;

  bool isWindows = false;

  screen() async {
    // WidgetsFlutterBinding.ensureInitialized();
    if (Platform.isWindows) {
      window_size.getWindowInfo().then((window) {
        final screen = window.screen;
        if (screen != null) {
          window_size.setWindowMinSize(
              Size(window.screen!.frame.width, window.screen!.frame.height));
          window_size.setWindowMaxSize(
              Size(window.screen!.frame.width, window.screen!.frame.height));
          // window_size.setWindowMinSize(Size(1366, 720));
          // window_size.setWindowMaxSize(Size(1366, 720));
        }
      });
      await windowManager.ensureInitialized();
      // disableWindowResize();
      WindowOptions windowOptions = const WindowOptions(fullScreen: true);
      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });

      setState(() {
        isWindows = true;
      });
    }
  }

  var storage = new FlutterSecureStorage();
  String token = "";
  var profileResult = new Profile();
  Future<void> saveRemember(String data) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/remember.txt');
    await file.writeAsString(data);
  }

  Future<void> saveToken(String data) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/token.txt');
      await file.writeAsString(data);
    } catch (x) {
      log(x.toString());
    }
  }

  Future<String> readToken() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/token.txt');
      return await file.readAsString();
    } catch (e) {
      // Handle errors
      return '';
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getProfile();
  }

  void _getProfile() async {
    setState(() {
      // _isLoading = true;
    });
    try {
      //await storage.write(key: key, value: value);
      if (isWindows) {
        token = await readToken();
      } else {
        token = await storage.read(key: "token") ?? "";
      }

      log("KEEP : " + token);
      // EasyLoading.show(status: 'loading...');
      //print("Nama =" + emailController.text);
      Profile.connectToApi(token).then((value) async {
        profileResult = value;
        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            _isLoading = false;
          });
        });
        if (profileResult.statusCode == 200) {
          setState(() {});
        } else {
          if (value.message!.contains('Unauthenticated')) {
            FancySnackbar.showSnackbar(
              context,
              snackBarType: FancySnackBarType.error,
              title: "Information!",
              message:
                  "Your account is used by someone else, please log in again",
              duration: 5,
              onCloseEvent: () {},
            );
            await saveRemember("false");
            await saveToken("");
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (BuildContext context) => MyApp()),
                (Route<dynamic> route) => false);
            await windowManager.ensureInitialized();
          } else {
            FancySnackbar.showSnackbar(
              context,
              snackBarType: FancySnackBarType.error,
              title: "Information!",
              message: value.message,
              duration: 5,
              onCloseEvent: () {},
            );
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
        setState(() {
          //print(storage.read(key: "token"));
        });
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
        appBar: AppBar(
          backgroundColor: Colors.white,
          toolbarHeight: 0,
          shadowColor: mBackgroundColor,
        ),
        backgroundColor: mBackgroundColor,
        body: BlocProvider(
          create: (context) => TimeCubit(),
          child: Scaffold(
              resizeToAvoidBottomInset: false,
              body: Container(
                child: LoadingOverlay(
                  isLoading: _isLoading,
                  // demo of some additional parameters
                  opacity: 0.5,
                  color: Color.fromARGB(255, 0, 0, 0),
                  progressIndicator: Container(
                    height: 160,
                    width: 150,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
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
                  child: Row(children: [
                    Container(
                      color: Colors.white,
                      width: 180,
                      height: MediaQuery.of(context).size.height,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          Image.asset(
                            "assets/images/logo2.png",
                            width: isWindows
                                ? windowWidth < 1400
                                    ? 110
                                    : 150
                                : 80,
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                currentPage = 0;
                                _getProfile();
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.only(left: 15, bottom: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.home_filled,
                                    color: Color.fromARGB(255, 184, 196, 216),
                                    size: 20,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "Dashboard",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                        color: currentPage == 0
                                            ? mDarkBlue
                                            : Color.fromARGB(
                                                255, 184, 196, 216),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600),
                                  )
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                currentPage = 1;
                                _getProfile();
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.only(left: 15, bottom: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.devices_fold_rounded,
                                    color: Color.fromARGB(255, 184, 196, 216),
                                    size: 20,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "PLC Integration Settings",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                        color: currentPage == 1
                                            ? mDarkBlue
                                            : Color.fromARGB(
                                                255, 184, 196, 216),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600),
                                  )
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                currentPage = 2;
                                _getProfile();
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.only(left: 15, bottom: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.fact_check_rounded,
                                      color: Color.fromARGB(255, 184, 196, 216),
                                      size: 20),
                                  SizedBox(width: 10),
                                  Text(
                                    "Quality Check Report",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                        color: currentPage == 2
                                            ? mDarkBlue
                                            : Color.fromARGB(
                                                255, 184, 196, 216),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600),
                                  )
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                currentPage = 3;
                                _getProfile();
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.only(left: 15, bottom: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.manage_history_outlined,
                                    color: Color.fromARGB(255, 184, 196, 216),
                                    size: 20,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "Downtime Report",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                        color: currentPage == 3
                                            ? mDarkBlue
                                            : Color.fromARGB(
                                                255, 184, 196, 216),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600),
                                  )
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                currentPage = 4;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.only(left: 15, bottom: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.manage_accounts,
                                      color: Color.fromARGB(255, 184, 196, 216),
                                      size: 20),
                                  SizedBox(width: 10),
                                  Text(
                                    "Profile Management",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                        color: currentPage == 4
                                            ? mDarkBlue
                                            : Color.fromARGB(
                                                255, 184, 196, 216),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                        child: Column(
                      children: [
                        header(context),
                        Expanded(
                            child: currentPage == 0
                                ? DashboardScreen()
                                : (currentPage == 1
                                    ? WebViewPage()
                                    : (currentPage == 2
                                        ? ReportQualityScreen()
                                        : (currentPage == 3
                                            ? DowntimeReportScreen()
                                            : (currentPage == 4
                                                ? ProfileManagementScreen()
                                                : Container())))))
                      ],
                    ))
                  ]),
                ),
              )),
        ));
  }

  Container header(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(
            horizontal: windowWidth < 1400 ? 10 : 20,
            vertical: windowWidth < 1400 ? 10 : 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  currentPage == 0
                      ? "SEALING"
                      : (currentPage == 1
                          ? "Tracking Unit Data"
                          : (currentPage == 2
                              ? "Quality Check Report"
                              : (currentPage == 3
                                  ? "Downtime Report"
                                  : (currentPage == 4
                                      ? "Profile Management"
                                      : "")))),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      color: mDarkBlue,
                      fontSize: windowWidth < 1400 ? 20 : 30,
                      fontWeight: FontWeight.w700),
                )
              ],
            ),
            Row(
              children: [
                Container(
                  margin: EdgeInsets.only(left: 10, right: 8),
                  padding: windowWidth < 1400
                      ? EdgeInsets.symmetric(vertical: 3, horizontal: 6)
                      : EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromARGB(255, 231, 231, 231),
                          spreadRadius: 5,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        )
                      ],
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
                      borderRadius: BorderRadius.circular(30)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Row(
                      //   children: [
                      //     Icon(
                      //       Icons.notifications_outlined,
                      //       color:
                      //           mDarkBlue.withOpacity(0.5),
                      //     ),
                      //     SizedBox(
                      //       width: 10,
                      //     ),
                      //     Icon(
                      //       Icons.info_outline_rounded,
                      //       color:
                      //           mDarkBlue.withOpacity(0.5),
                      //     )
                      //   ],
                      // ),
                      SizedBox(
                        width: 10,
                      ),
                      InkWell(
                        onTap: () async {
                          showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (dialogcontext) {
                                return AlertDialog(
                                    content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Lottie.asset(
                                    //     'assets/json/loadingBlue.json',
                                    //     height: 100,
                                    //     width: 100),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      'Are you sure you will log out?',
                                      style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 17,
                                          color:
                                              Color.fromARGB(255, 75, 75, 75)),
                                    ),
                                    SizedBox(
                                      height: 50,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: InkWell(
                                            onTap: () async {
                                              Navigator.pop(dialogcontext);
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.2),
                                                      spreadRadius: 5,
                                                      blurRadius: 5,
                                                      offset: Offset(0, 2),
                                                    )
                                                  ],
                                                  color: Color.fromARGB(
                                                      255, 107, 107, 107),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              padding: EdgeInsets.all(8),
                                              child: Center(
                                                child: Text(
                                                  "Cancel",
                                                  style: GoogleFonts.poppins(
                                                      color: Colors.white,
                                                      fontSize: 16),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Expanded(
                                          child: InkWell(
                                            onTap: () async {
                                              try {
                                                await storage.write(
                                                    key: "keep",
                                                    value: "false");
                                                await storage.write(
                                                    key: "token", value: "");
                                                Navigator.pop(dialogcontext);
                                                Navigator.pushAndRemoveUntil(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (BuildContext
                                                                context) =>
                                                            MyApp()),
                                                    (Route<dynamic> route) =>
                                                        false);
                                              } catch (x) {
                                                Future.delayed(
                                                    const Duration(
                                                        milliseconds: 2000),
                                                    () {
                                                  setState(() {
                                                    _isLoading = false;
                                                    setState(() {});
                                                    Navigator.pop(
                                                        dialogcontext);
                                                  });
                                                });
                                              }
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: mTitleBlue
                                                          .withOpacity(0.2),
                                                      spreadRadius: 5,
                                                      blurRadius: 5,
                                                      offset: Offset(0, 2),
                                                    )
                                                  ],
                                                  color: mTitleBlue,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              padding: EdgeInsets.all(8),
                                              child: Center(
                                                child: Text(
                                                  "Logout",
                                                  style: GoogleFonts.poppins(
                                                      color: Colors.white,
                                                      fontSize: 16),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ));
                              });
                          // disableWindowResize();
                        },
                        child: Icon(
                          Icons.logout_rounded,
                          color: mDarkBlue.withOpacity(0.5),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                profileResult.user != null
                                    ? profileResult.user!.name
                                    : "",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                    color: mDarkBlue,
                                    fontSize: windowWidth < 1400 ? 12 : 15,
                                    fontWeight: FontWeight.w700),
                              ),
                              Text(
                                profileResult.user != null
                                    ? profileResult.user!.division
                                    : "",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                    color: mDarkBlue.withOpacity(0.5),
                                    fontSize: windowWidth < 1400 ? 9 : 12,
                                    fontWeight: FontWeight.w700),
                              )
                            ],
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          CircleAvatar(
                            radius: windowWidth < 1400 ? 20 : 25.0,
                            backgroundImage: NetworkImage(
                                profileResult.user != null
                                    ? (Url().valPic +
                                        (profileResult.user?.picture ?? ""))
                                    : ""),
                            backgroundColor: Colors.transparent,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 10, right: 8),
                  padding: windowWidth < 1400
                      ? EdgeInsets.symmetric(vertical: 6, horizontal: 6)
                      : EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromARGB(255, 231, 231, 231),
                          spreadRadius: 5,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        )
                      ],
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
                      borderRadius: BorderRadius.circular(30)),
                  child: InkWell(
                    onTap: () {
                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (dialogcontext) {
                            return AlertDialog(
                                content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Lottie.asset(
                                //     'assets/json/loadingBlue.json',
                                //     height: 100,
                                //     width: 100),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  'Are you sure you will exit the application?',
                                  style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 17,
                                      color: Color.fromARGB(255, 75, 75, 75)),
                                ),
                                SizedBox(
                                  height: 50,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () async {
                                          Navigator.pop(dialogcontext);
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.2),
                                                  spreadRadius: 5,
                                                  blurRadius: 5,
                                                  offset: Offset(0, 2),
                                                )
                                              ],
                                              color: Color.fromARGB(
                                                  255, 107, 107, 107),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          padding: EdgeInsets.all(8),
                                          child: Center(
                                            child: Text(
                                              "Cancel",
                                              style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: 16),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () async {
                                          exit(0);
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: mTitleBlue
                                                      .withOpacity(0.2),
                                                  spreadRadius: 5,
                                                  blurRadius: 5,
                                                  offset: Offset(0, 2),
                                                )
                                              ],
                                              color: mTitleBlue,
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          padding: EdgeInsets.all(8),
                                          child: Center(
                                            child: Text(
                                              "Exit App ",
                                              style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: 16),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ));
                          });
                    },
                    child: Icon(
                      Icons.close_rounded,
                      size: 35,
                      color: const Color.fromARGB(255, 51, 51, 51),
                    ),
                  ),
                )
              ],
            )
          ],
        ));
  }
}
