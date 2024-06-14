// import 'dart:async';
// import 'dart:developer';
// import 'dart:io';
// import 'dart:ui';

// import 'package:desktop_window/desktop_window.dart';
// import 'package:fancy_snackbar/fancy_snackbar.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
// import 'package:isuzu_oee_app/models/post_barcode_model.dart';
// import 'package:isuzu_oee_app/url.dart';
// import 'package:loading_overlay/loading_overlay.dart';
// import 'package:loadmore_listview/loadmore_listview.dart';
// import 'package:lottie/lottie.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';
// import 'package:window_manager/window_manager.dart';

// import 'package:window_size/window_size.dart' as window_size;
// import 'package:window_size/window_size.dart';
// import 'constants/color_constant.dart';
// import 'main.dart';
// import 'models/chart_model.dart';
// import 'models/dashboard_model.dart';
// import 'models/profile_model.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   bool _isLoading = false;
//   bool isWindows = false;

//   screen() async {
//     // WidgetsFlutterBinding.ensureInitialized();
//     if (Platform.isWindows) {
//       window_size.getWindowInfo().then((window) {
//         final screen = window.screen;
//         if (screen != null) {
//           window_size.setWindowMinSize(
//               Size(window.screen!.frame.width, window.screen!.frame.height));
//           window_size.setWindowMaxSize(
//               Size(window.screen!.frame.width, window.screen!.frame.height));
//           // window_size.setWindowMinSize(Size(1366, 720));
//           // window_size.setWindowMaxSize(Size(1366, 720));
//         }
//       });
//       await windowManager.ensureInitialized();
//       // disableWindowResize();
//       WindowOptions windowOptions = const WindowOptions(fullScreen: true);
//       windowManager.waitUntilReadyToShow(windowOptions, () async {
//         await windowManager.show();
//         await windowManager.focus();
//       });

//       setState(() {
//         isWindows = true;
//       });
//     }
//   }

//   Future<void> saveRemember(String data) async {
//     final directory = await getApplicationDocumentsDirectory();
//     final file = File('${directory.path}/remember.txt');
//     await file.writeAsString(data);
//   }

//   Future<void> saveToken(String data) async {
//     try {
//       final directory = await getApplicationDocumentsDirectory();
//       final file = File('${directory.path}/token.txt');
//       await file.writeAsString(data);
//     } catch (x) {
//       log(x.toString());
//     }
//   }

//   late FocusNode _focusNode;

//   @override
//   void dispose() {
//     _focusNode.dispose();
//     try {
//       _timer!.cancel();
//     } catch (x) {}
//     try {
//       _timer2!.cancel();
//     } catch (x) {}
//     super.dispose();
//   }

//   Future<String> readToken() async {
//     try {
//       final directory = await getApplicationDocumentsDirectory();
//       final file = File('${directory.path}/token.txt');
//       return await file.readAsString();
//     } catch (e) {
//       // Handle errors
//       return '';
//     }
//   }

//   Timer? _timer;
//   var storage = new FlutterSecureStorage();
//   String token = "";
//   var dashboardResult = new Dashboard();
//   var profileResult = new Profile();

//   void _getProfile() async {
//     setState(() {
//       // _isLoading = true;
//     });
//     try {
//       //await storage.write(key: key, value: value);
//       if (isWindows) {
//         token = await readToken();
//       } else {
//         token = await storage.read(key: "token") ?? "";
//       }

//       log("KEEP : " + token);
//       // EasyLoading.show(status: 'loading...');
//       //print("Nama =" + emailController.text);
//       Profile.connectToApi(token).then((value) async {
//         profileResult = value;
//         Future.delayed(Duration(seconds: 1), () {
//           setState(() {
//             _isLoading = false;
//           });
//         });
//         if (profileResult.statusCode == 200) {
//           setState(() {});
//         } else {
//           if (value.message!.contains('Unauthenticated')) {
//             FancySnackbar.showSnackbar(
//               context,
//               snackBarType: FancySnackBarType.error,
//               title: "Information!",
//               message:
//                   "Your account is used by someone else, please log in again",
//               duration: 5,
//               onCloseEvent: () {},
//             );
//             await storage.write(key: 'token', value: "");
//             await storage.write(key: 'keep', value: "");
//             Navigator.of(context).pushAndRemoveUntil(
//                 MaterialPageRoute(builder: (context) => MyApp()),
//                 (Route<dynamic> route) => false);
//           } else {
//             FancySnackbar.showSnackbar(
//               context,
//               snackBarType: FancySnackBarType.error,
//               title: "Information!",
//               message: value.message,
//               duration: 5,
//               onCloseEvent: () {},
//             );
//           }
//           // FancySnackbar.showSnackbar(
//           //   context,
//           //   snackBarType: FancySnackBarType.error,
//           //   title: "Information!",
//           //   message: profileResult.message,
//           //   duration: 5,
//           //   onCloseEvent: () {},
//           // );
//         }
//         setState(() {
//           //print(storage.read(key: "token"));
//         });
//       });
//     } catch (x) {
//       Future.delayed(Duration(seconds: 2), () {
//         setState(() {
//           _isLoading = false;
//         });
//       });
//     }
//   }

//   void _getItem() async {
//     setState(() {
//       _isLoading = true;
//     });
//     try {
//       //await storage.write(key: key, value: value);
//       if (isWindows) {
//         token = await readToken();
//       } else {
//         token = await storage.read(key: "token") ?? "";
//       }

//       // EasyLoading.show(status: 'loading...');
//       //print("Nama =" + emailController.text);
//       Dashboard.connectToApi(token).then((value) async {
//         dashboardResult = value;
//         Future.delayed(Duration(seconds: 1), () {
//           setState(() {
//             _isLoading = false;
//           });
//         });
//         if (dashboardResult.statusCode == 200) {
//           chartData.clear();
//           chartData.add(ChartData(
//               "LOADING (" +
//                   (dashboardResult.data != null
//                       ? (dashboardResult.data!.downTimes != null
//                           ? (double.parse(dashboardResult
//                                   .data!.downTimes!.loading
//                                   .toString())
//                               .toStringAsFixed(0))
//                           : "0")
//                       : "0") +
//                   ")",
//               dashboardResult.data != null
//                   ? (dashboardResult.data!.downTimes != null
//                       ? (double.parse(
//                           dashboardResult.data!.downTimes!.loading.toString()))
//                       : 0)
//                   : 0));

//           chartData.add(ChartData(
//               "SEALING (" +
//                   (dashboardResult.data != null
//                       ? (dashboardResult.data!.downTimes != null
//                           ? (double.parse(dashboardResult
//                                   .data!.downTimes!.sealing
//                                   .toString())
//                               .toStringAsFixed(0))
//                           : "0")
//                       : "0") +
//                   ")",
//               dashboardResult.data != null
//                   ? (dashboardResult.data!.downTimes != null
//                       ? (double.parse(
//                           dashboardResult.data!.downTimes!.sealing.toString()))
//                       : 0)
//                   : 0));

//           chartData.add(ChartData(
//               "TOP COAT (" +
//                   (dashboardResult.data != null
//                       ? (dashboardResult.data!.downTimes != null
//                           ? (double.parse(dashboardResult
//                                   .data!.downTimes!.topCoat
//                                   .toString())
//                               .toStringAsFixed(0))
//                           : "0")
//                       : "0") +
//                   ")",
//               dashboardResult.data != null
//                   ? (dashboardResult.data!.downTimes != null
//                       ? (double.parse(
//                           dashboardResult.data!.downTimes!.topCoat.toString()))
//                       : 0)
//                   : 0));
//           setState(() {});
//         } else {
//           if (value.message!.contains('Unauthenticated')) {
//             FancySnackbar.showSnackbar(
//               context,
//               snackBarType: FancySnackBarType.error,
//               title: "Information!",
//               message:
//                   "Your account is used by someone else, please log in again",
//               duration: 5,
//               onCloseEvent: () {},
//             );
//             await storage.write(key: 'token', value: "");
//             await storage.write(key: 'keep', value: "");
//             Navigator.of(context).pushAndRemoveUntil(
//                 MaterialPageRoute(builder: (context) => MyApp()),
//                 (Route<dynamic> route) => false);
//           } else {
//             // FancySnackbar.showSnackbar(
//             //   context,
//             //   snackBarType: FancySnackBarType.error,
//             //   title: "Information!",
//             //   message: value.message,
//             //   duration: 5,
//             //   onCloseEvent: () {},
//             // );
//           }
//           // FancySnackbar.showSnackbar(
//           //   context,
//           //   snackBarType: FancySnackBarType.error,
//           //   title: "Information!",
//           //   message: profileResult.message,
//           //   duration: 5,
//           //   onCloseEvent: () {},
//           // );
//         }
//         setState(() {
//           //print(storage.read(key: "token"));
//         });
//       });
//     } catch (x) {
//       Future.delayed(Duration(seconds: 2), () {
//         setState(() {
//           _isLoading = false;
//         });
//       });
//     }
//   }

//   Timer? _timer2;
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     if (Platform.isWindows) {
//       isWindows = true;
//     }
//     _focusNode = FocusNode();
//     screen();
//     _getItem();
//     _getProfile();
//     _timer = new Timer.periodic(Duration(seconds: 1), (Timer timer) {
//       setState(() {
//         DateTime now = DateTime.now();
//         formattedDate = DateFormat('d MMMM yyyy', 'id_ID').format(now);
//       });
//     });
//     _timer2 = new Timer.periodic(Duration(seconds: 10), (Timer timer) {
//       try {
//         // EasyLoading.show(status: 'loading...');
//         //print("Nama =" + emailController.text);
//         Dashboard.connectToApi(token).then((value) async {
//           dashboardResult = value;
//           if (dashboardResult.statusCode == 200) {
//             // chartData.clear();
//             if (chartData.length > 2) {
//               chartData[0] = ChartData(
//                   "LOADING (" +
//                       (dashboardResult.data != null
//                           ? (dashboardResult.data!.downTimes != null
//                               ? (double.parse(dashboardResult
//                                       .data!.downTimes!.loading
//                                       .toString())
//                                   .toStringAsFixed(0))
//                               : "0")
//                           : "0") +
//                       ")",
//                   dashboardResult.data != null
//                       ? (dashboardResult.data!.downTimes != null
//                           ? (double.parse(dashboardResult
//                               .data!.downTimes!.loading
//                               .toString()))
//                           : 0)
//                       : 0);

//               chartData[1] = ChartData(
//                   "SEALING (" +
//                       (dashboardResult.data != null
//                           ? (dashboardResult.data!.downTimes != null
//                               ? (double.parse(dashboardResult
//                                       .data!.downTimes!.sealing
//                                       .toString())
//                                   .toStringAsFixed(0))
//                               : "0")
//                           : "0") +
//                       ")",
//                   dashboardResult.data != null
//                       ? (dashboardResult.data!.downTimes != null
//                           ? (double.parse(dashboardResult
//                               .data!.downTimes!.sealing
//                               .toString()))
//                           : 0)
//                       : 0);

//               chartData[2] = ChartData(
//                   "TOP COAT (" +
//                       (dashboardResult.data != null
//                           ? (dashboardResult.data!.downTimes != null
//                               ? (double.parse(dashboardResult
//                                       .data!.downTimes!.topCoat
//                                       .toString())
//                                   .toStringAsFixed(0))
//                               : "0")
//                           : "0") +
//                       ")",
//                   dashboardResult.data != null
//                       ? (dashboardResult.data!.downTimes != null
//                           ? (double.parse(dashboardResult
//                               .data!.downTimes!.topCoat
//                               .toString()))
//                           : 0)
//                       : 0);
//             }
//             setState(() {});
//           } else {}
//           setState(() {
//             //print(storage.read(key: "token"));
//           });
//         });
//       } catch (x) {}
//     });
//   }

//   final List<ChartData> chartData = [];
//   String formattedDate = "";
//   TextEditingController controllerCari = new TextEditingController();
//   double windowWidth = 0;
//   @override
//   Widget build(BuildContext context) {
//     windowWidth = MediaQuery.of(context).size.width;
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         toolbarHeight: 0,
//         shadowColor: mBackgroundColor,
//       ),
//       backgroundColor:
//           isWindows ? Color.fromARGB(255, 247, 248, 255) : mBackgroundColor,
//       body: LoadingOverlay(
//         isLoading: _isLoading,
//         // demo of some additional parameters
//         opacity: 0.5,
//         color: Color.fromARGB(255, 0, 0, 0),
//         progressIndicator: Container(
//           height: 160,
//           width: 150,
//           decoration: BoxDecoration(
//               color: Colors.white, borderRadius: BorderRadius.circular(10)),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Lottie.asset('assets/json/loadingBlue.json',
//                   height: 100, width: 100),
//               SizedBox(
//                 height: 10,
//               ),
//               Text(
//                 'Loading ...',
//                 style: GoogleFonts.inter(
//                     fontWeight: FontWeight.w700,
//                     fontSize: 17,
//                     color: Color.fromARGB(255, 75, 75, 75)),
//               ),
//             ],
//           ),
//         ),
//         child: Row(
//           children: [
//             Container(
//               color: Colors.white,
//               width: 270,
//               height: MediaQuery.of(context).size.height,
//               child: Column(
//                 children: [
//                   SizedBox(
//                     height: 20,
//                   ),
//                   Image.asset(
//                     "assets/images/logo2.png",
//                     width: isWindows
//                         ? windowWidth < 1400
//                             ? 110
//                             : 150
//                         : 80,
//                   ),
//                   SizedBox(
//                     height: 40,
//                   ),
//                   Container(
//                     padding: EdgeInsets.only(left: 20, bottom: 30),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         Icon(
//                           Icons.home_filled,
//                           color: Color.fromARGB(255, 103, 111, 124),
//                         ),
//                         SizedBox(width: 10),
//                         Text(
//                           "Dashboard",
//                           textAlign: TextAlign.center,
//                           style: GoogleFonts.poppins(
//                               color: Color.fromARGB(255, 103, 111, 122),
//                               fontSize: windowWidth < 1400 ? 13 : 15,
//                               fontWeight: FontWeight.w600),
//                         )
//                       ],
//                     ),
//                   ),
//                   Container(
//                     padding: EdgeInsets.only(left: 20, bottom: 30),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         Icon(
//                           Icons.settings,
//                           color: Color.fromARGB(255, 103, 111, 124),
//                         ),
//                         SizedBox(width: 10),
//                         Text(
//                           "PLC Integration Settings",
//                           textAlign: TextAlign.center,
//                           style: GoogleFonts.poppins(
//                               color: Color.fromARGB(255, 103, 111, 122),
//                               fontSize: windowWidth < 1400 ? 13 : 15,
//                               fontWeight: FontWeight.w600),
//                         )
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: Column(
//                 children: [
//                   LoadMoreListView.builder(
//                       shrinkWrap: true,
//                       hasMoreItem: true,
//                       onRefresh: () async {
//                         _getItem();
//                       },
//                       loadMoreWidget: Container(
//                         margin: const EdgeInsets.all(20.0),
//                         alignment: Alignment.center,
//                         child: const CircularProgressIndicator(
//                           valueColor: AlwaysStoppedAnimation(
//                               Color.fromARGB(255, 95, 170, 60)),
//                         ),
//                       ),
//                       itemCount: 1,
//                       scrollDirection: Axis.vertical,
//                       itemBuilder: (context, index) {
//                         return Container(
//                           child: Column(
//                             children: [
//                               Container(
//                                 padding: EdgeInsets.symmetric(
//                                     horizontal: windowWidth < 1400 ? 10 : 20,
//                                     vertical: windowWidth < 1400 ? 10 : 20),
//                                 child: isWindows
//                                     ? Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceBetween,
//                                             children: [
//                                               Text(
//                                                 "OEE LOADING PTED",
//                                                 textAlign: TextAlign.center,
//                                                 style: GoogleFonts.poppins(
//                                                     color: mDarkBlue,
//                                                     fontSize: windowWidth < 1400
//                                                         ? 20
//                                                         : 30,
//                                                     fontWeight:
//                                                         FontWeight.w700),
//                                               )
//                                             ],
//                                           ),
//                                           Row(
//                                             children: [
//                                               Container(
//                                                 margin: EdgeInsets.only(
//                                                     left: 10, right: 8),
//                                                 padding: windowWidth < 1400
//                                                     ? EdgeInsets.symmetric(
//                                                         vertical: 3,
//                                                         horizontal: 6)
//                                                     : EdgeInsets.symmetric(
//                                                         vertical: 5,
//                                                         horizontal: 10),
//                                                 decoration: BoxDecoration(
//                                                     boxShadow: [
//                                                       BoxShadow(
//                                                         color: Color.fromARGB(
//                                                             255, 231, 231, 231),
//                                                         spreadRadius: 5,
//                                                         blurRadius: 5,
//                                                         offset: Offset(0, 2),
//                                                       )
//                                                     ],
//                                                     // boxShadow: [
//                                                     //   BoxShadow(
//                                                     //     color:
//                                                     //         const Color.fromARGB(255, 214, 214, 214)
//                                                     //             .withOpacity(0.1),
//                                                     //     spreadRadius: 5,
//                                                     //     blurRadius: 5,
//                                                     //     offset: Offset(0, 2),
//                                                     //   )
//                                                     // ],
//                                                     color: Colors.white,
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             30)),
//                                                 child: Row(
//                                                   mainAxisAlignment:
//                                                       MainAxisAlignment
//                                                           .spaceBetween,
//                                                   children: [
//                                                     // Row(
//                                                     //   children: [
//                                                     //     Icon(
//                                                     //       Icons.notifications_outlined,
//                                                     //       color:
//                                                     //           mDarkBlue.withOpacity(0.5),
//                                                     //     ),
//                                                     //     SizedBox(
//                                                     //       width: 10,
//                                                     //     ),
//                                                     //     Icon(
//                                                     //       Icons.info_outline_rounded,
//                                                     //       color:
//                                                     //           mDarkBlue.withOpacity(0.5),
//                                                     //     )
//                                                     //   ],
//                                                     // ),
//                                                     SizedBox(
//                                                       width: 10,
//                                                     ),
//                                                     InkWell(
//                                                       onTap: () async {
//                                                         showDialog(
//                                                             barrierDismissible:
//                                                                 false,
//                                                             context: context,
//                                                             builder:
//                                                                 (dialogcontext) {
//                                                               return AlertDialog(
//                                                                   content:
//                                                                       Column(
//                                                                 mainAxisSize:
//                                                                     MainAxisSize
//                                                                         .min,
//                                                                 crossAxisAlignment:
//                                                                     CrossAxisAlignment
//                                                                         .center,
//                                                                 children: [
//                                                                   // Lottie.asset(
//                                                                   //     'assets/json/loadingBlue.json',
//                                                                   //     height: 100,
//                                                                   //     width: 100),
//                                                                   SizedBox(
//                                                                     height: 20,
//                                                                   ),
//                                                                   Text(
//                                                                     'Are you sure you will log out?',
//                                                                     style: GoogleFonts.inter(
//                                                                         fontWeight:
//                                                                             FontWeight
//                                                                                 .w700,
//                                                                         fontSize:
//                                                                             17,
//                                                                         color: Color.fromARGB(
//                                                                             255,
//                                                                             75,
//                                                                             75,
//                                                                             75)),
//                                                                   ),
//                                                                   SizedBox(
//                                                                     height: 50,
//                                                                   ),
//                                                                   Row(
//                                                                     children: [
//                                                                       Expanded(
//                                                                         child:
//                                                                             InkWell(
//                                                                           onTap:
//                                                                               () async {
//                                                                             Navigator.pop(dialogcontext);
//                                                                           },
//                                                                           child:
//                                                                               Container(
//                                                                             decoration:
//                                                                                 BoxDecoration(boxShadow: [
//                                                                               BoxShadow(
//                                                                                 color: Colors.grey.withOpacity(0.2),
//                                                                                 spreadRadius: 5,
//                                                                                 blurRadius: 5,
//                                                                                 offset: Offset(0, 2),
//                                                                               )
//                                                                             ], color: Color.fromARGB(255, 107, 107, 107), borderRadius: BorderRadius.circular(10)),
//                                                                             padding:
//                                                                                 EdgeInsets.all(8),
//                                                                             child:
//                                                                                 Center(
//                                                                               child: Text(
//                                                                                 "Cancel",
//                                                                                 style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
//                                                                               ),
//                                                                             ),
//                                                                           ),
//                                                                         ),
//                                                                       ),
//                                                                       SizedBox(
//                                                                         width:
//                                                                             20,
//                                                                       ),
//                                                                       Expanded(
//                                                                         child:
//                                                                             InkWell(
//                                                                           onTap:
//                                                                               () async {
//                                                                             try {
//                                                                               await saveRemember("false");
//                                                                               await saveToken("");
//                                                                               Navigator.pop(dialogcontext);
//                                                                               Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context) => MyApp()), (Route<dynamic> route) => false);
//                                                                               await windowManager.ensureInitialized();
//                                                                             } catch (x) {
//                                                                               Future.delayed(const Duration(milliseconds: 2000), () {
//                                                                                 setState(() {
//                                                                                   _isLoading = false;
//                                                                                   controllerCari.text = "";
//                                                                                   setState(() {});
//                                                                                   Navigator.pop(dialogcontext);
//                                                                                 });
//                                                                               });
//                                                                             }
//                                                                           },
//                                                                           child:
//                                                                               Container(
//                                                                             decoration:
//                                                                                 BoxDecoration(boxShadow: [
//                                                                               BoxShadow(
//                                                                                 color: mTitleBlue.withOpacity(0.2),
//                                                                                 spreadRadius: 5,
//                                                                                 blurRadius: 5,
//                                                                                 offset: Offset(0, 2),
//                                                                               )
//                                                                             ], color: mTitleBlue, borderRadius: BorderRadius.circular(10)),
//                                                                             padding:
//                                                                                 EdgeInsets.all(8),
//                                                                             child:
//                                                                                 Center(
//                                                                               child: Text(
//                                                                                 "Logout",
//                                                                                 style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
//                                                                               ),
//                                                                             ),
//                                                                           ),
//                                                                         ),
//                                                                       ),
//                                                                     ],
//                                                                   ),
//                                                                 ],
//                                                               ));
//                                                             });
//                                                         // disableWindowResize();
//                                                       },
//                                                       child: Icon(
//                                                         Icons.logout_rounded,
//                                                         color: mDarkBlue
//                                                             .withOpacity(0.5),
//                                                       ),
//                                                     ),
//                                                     SizedBox(
//                                                       width: 50,
//                                                     ),
//                                                     Row(
//                                                       children: [
//                                                         Column(
//                                                           crossAxisAlignment:
//                                                               CrossAxisAlignment
//                                                                   .end,
//                                                           children: [
//                                                             Text(
//                                                               profileResult
//                                                                           .user !=
//                                                                       null
//                                                                   ? profileResult
//                                                                       .user!
//                                                                       .name
//                                                                   : "",
//                                                               textAlign:
//                                                                   TextAlign
//                                                                       .center,
//                                                               style: GoogleFonts.poppins(
//                                                                   color:
//                                                                       mDarkBlue,
//                                                                   fontSize:
//                                                                       windowWidth <
//                                                                               1400
//                                                                           ? 12
//                                                                           : 15,
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .w700),
//                                                             ),
//                                                             Text(
//                                                               profileResult
//                                                                           .user !=
//                                                                       null
//                                                                   ? profileResult
//                                                                       .user!
//                                                                       .division
//                                                                   : "",
//                                                               textAlign:
//                                                                   TextAlign
//                                                                       .center,
//                                                               style: GoogleFonts.poppins(
//                                                                   color: mDarkBlue
//                                                                       .withOpacity(
//                                                                           0.5),
//                                                                   fontSize:
//                                                                       windowWidth <
//                                                                               1400
//                                                                           ? 9
//                                                                           : 12,
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .w700),
//                                                             )
//                                                           ],
//                                                         ),
//                                                         SizedBox(
//                                                           width: 10,
//                                                         ),
//                                                         CircleAvatar(
//                                                           radius:
//                                                               windowWidth < 1400
//                                                                   ? 20
//                                                                   : 25.0,
//                                                           backgroundImage: NetworkImage(profileResult
//                                                                       .user !=
//                                                                   null
//                                                               ? (Url().valPic +
//                                                                   (profileResult
//                                                                           .user
//                                                                           ?.picture ??
//                                                                       ""))
//                                                               : ""),
//                                                           backgroundColor:
//                                                               Colors
//                                                                   .transparent,
//                                                         ),
//                                                       ],
//                                                     )
//                                                   ],
//                                                 ),
//                                               ),
//                                               Container(
//                                                 margin: EdgeInsets.only(
//                                                     left: 10, right: 8),
//                                                 padding: windowWidth < 1400
//                                                     ? EdgeInsets.symmetric(
//                                                         vertical: 6,
//                                                         horizontal: 6)
//                                                     : EdgeInsets.symmetric(
//                                                         vertical: 10,
//                                                         horizontal: 10),
//                                                 decoration: BoxDecoration(
//                                                     boxShadow: [
//                                                       BoxShadow(
//                                                         color: Color.fromARGB(
//                                                             255, 231, 231, 231),
//                                                         spreadRadius: 5,
//                                                         blurRadius: 5,
//                                                         offset: Offset(0, 2),
//                                                       )
//                                                     ],
//                                                     // boxShadow: [
//                                                     //   BoxShadow(
//                                                     //     color:
//                                                     //         const Color.fromARGB(255, 214, 214, 214)
//                                                     //             .withOpacity(0.1),
//                                                     //     spreadRadius: 5,
//                                                     //     blurRadius: 5,
//                                                     //     offset: Offset(0, 2),
//                                                     //   )
//                                                     // ],
//                                                     color: Colors.white,
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             30)),
//                                                 child: InkWell(
//                                                   onTap: () {
//                                                     showDialog(
//                                                         barrierDismissible:
//                                                             false,
//                                                         context: context,
//                                                         builder:
//                                                             (dialogcontext) {
//                                                           return AlertDialog(
//                                                               content: Column(
//                                                             mainAxisSize:
//                                                                 MainAxisSize
//                                                                     .min,
//                                                             crossAxisAlignment:
//                                                                 CrossAxisAlignment
//                                                                     .center,
//                                                             children: [
//                                                               // Lottie.asset(
//                                                               //     'assets/json/loadingBlue.json',
//                                                               //     height: 100,
//                                                               //     width: 100),
//                                                               SizedBox(
//                                                                 height: 20,
//                                                               ),
//                                                               Text(
//                                                                 'Are you sure you will exit the application?',
//                                                                 style: GoogleFonts.inter(
//                                                                     fontWeight:
//                                                                         FontWeight
//                                                                             .w700,
//                                                                     fontSize:
//                                                                         17,
//                                                                     color: Color
//                                                                         .fromARGB(
//                                                                             255,
//                                                                             75,
//                                                                             75,
//                                                                             75)),
//                                                               ),
//                                                               SizedBox(
//                                                                 height: 50,
//                                                               ),
//                                                               Row(
//                                                                 children: [
//                                                                   Expanded(
//                                                                     child:
//                                                                         InkWell(
//                                                                       onTap:
//                                                                           () async {
//                                                                         Navigator.pop(
//                                                                             dialogcontext);
//                                                                       },
//                                                                       child:
//                                                                           Container(
//                                                                         decoration: BoxDecoration(
//                                                                             boxShadow: [
//                                                                               BoxShadow(
//                                                                                 color: Colors.grey.withOpacity(0.2),
//                                                                                 spreadRadius: 5,
//                                                                                 blurRadius: 5,
//                                                                                 offset: Offset(0, 2),
//                                                                               )
//                                                                             ],
//                                                                             color: Color.fromARGB(
//                                                                                 255,
//                                                                                 107,
//                                                                                 107,
//                                                                                 107),
//                                                                             borderRadius:
//                                                                                 BorderRadius.circular(10)),
//                                                                         padding:
//                                                                             EdgeInsets.all(8),
//                                                                         child:
//                                                                             Center(
//                                                                           child:
//                                                                               Text(
//                                                                             "Cancel",
//                                                                             style:
//                                                                                 GoogleFonts.poppins(color: Colors.white, fontSize: 16),
//                                                                           ),
//                                                                         ),
//                                                                       ),
//                                                                     ),
//                                                                   ),
//                                                                   SizedBox(
//                                                                     width: 20,
//                                                                   ),
//                                                                   Expanded(
//                                                                     child:
//                                                                         InkWell(
//                                                                       onTap:
//                                                                           () async {
//                                                                         exit(0);
//                                                                       },
//                                                                       child:
//                                                                           Container(
//                                                                         decoration: BoxDecoration(
//                                                                             boxShadow: [
//                                                                               BoxShadow(
//                                                                                 color: mTitleBlue.withOpacity(0.2),
//                                                                                 spreadRadius: 5,
//                                                                                 blurRadius: 5,
//                                                                                 offset: Offset(0, 2),
//                                                                               )
//                                                                             ],
//                                                                             color:
//                                                                                 mTitleBlue,
//                                                                             borderRadius:
//                                                                                 BorderRadius.circular(10)),
//                                                                         padding:
//                                                                             EdgeInsets.all(8),
//                                                                         child:
//                                                                             Center(
//                                                                           child:
//                                                                               Text(
//                                                                             "Exit App ",
//                                                                             style:
//                                                                                 GoogleFonts.poppins(color: Colors.white, fontSize: 16),
//                                                                           ),
//                                                                         ),
//                                                                       ),
//                                                                     ),
//                                                                   ),
//                                                                 ],
//                                                               ),
//                                                             ],
//                                                           ));
//                                                         });
//                                                   },
//                                                   child: Icon(
//                                                     Icons.close_rounded,
//                                                     size: 35,
//                                                     color: const Color.fromARGB(
//                                                         255, 51, 51, 51),
//                                                   ),
//                                                 ),
//                                               )
//                                             ],
//                                           )
//                                         ],
//                                       )
//                                     : Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           Image.asset(
//                                             "assets/images/logo2.png",
//                                             width: isWindows ? 150 : 80,
//                                           ),
//                                           Text(
//                                             profileResult.user != null
//                                                 ? profileResult.user!.division
//                                                 : "",
//                                             textAlign: TextAlign.center,
//                                             style: GoogleFonts.poppins(
//                                                 color: mDarkBlue,
//                                                 fontSize: 20,
//                                                 fontWeight: FontWeight.w600),
//                                           )
//                                         ],
//                                       ),
//                               ),
//                               if (!isWindows) ...[
//                                 Row(
//                                   children: [
//                                     Expanded(
//                                       child: Container(
//                                         margin:
//                                             EdgeInsets.only(left: 10, right: 8),
//                                         padding: EdgeInsets.symmetric(
//                                             vertical: 20, horizontal: 10),
//                                         decoration: BoxDecoration(
//                                             // boxShadow: [
//                                             //   BoxShadow(
//                                             //     color:
//                                             //         const Color.fromARGB(255, 214, 214, 214)
//                                             //             .withOpacity(0.1),
//                                             //     spreadRadius: 5,
//                                             //     blurRadius: 5,
//                                             //     offset: Offset(0, 2),
//                                             //   )
//                                             // ],
//                                             color: Colors.white,
//                                             borderRadius:
//                                                 BorderRadius.circular(15)),
//                                         child: Row(
//                                           children: [
//                                             Container(
//                                               padding: EdgeInsets.all(10),
//                                               decoration: BoxDecoration(
//                                                   color: mDarkBlue
//                                                       .withOpacity(0.1),
//                                                   borderRadius:
//                                                       BorderRadius.circular(
//                                                           50)),
//                                               child: Icon(
//                                                 Icons.file_copy,
//                                                 color: mBlueColor,
//                                                 size: 20,
//                                               ),
//                                             ),
//                                             SizedBox(
//                                               width: 10,
//                                             ),
//                                             Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 Text(
//                                                   "Shift",
//                                                   textAlign: TextAlign.center,
//                                                   style: GoogleFonts.poppins(
//                                                       color: mDarkBlue
//                                                           .withOpacity(0.5),
//                                                       fontSize:
//                                                           windowWidth < 411
//                                                               ? 10
//                                                               : 12,
//                                                       fontWeight:
//                                                           FontWeight.w600),
//                                                 ),
//                                                 Text(
//                                                   dashboardResult.data != null
//                                                       ? (dashboardResult.data!
//                                                                   .displayData !=
//                                                               null
//                                                           ? dashboardResult
//                                                               .data!
//                                                               .displayData!
//                                                               .shift
//                                                               .name
//                                                           : "")
//                                                       : "",
//                                                   textAlign: TextAlign.center,
//                                                   style: GoogleFonts.poppins(
//                                                       color: mDarkBlue,
//                                                       fontSize: 17,
//                                                       fontWeight:
//                                                           FontWeight.w600),
//                                                 )
//                                               ],
//                                             )
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                     Expanded(
//                                       child: Container(
//                                         margin:
//                                             EdgeInsets.only(left: 8, right: 10),
//                                         padding: EdgeInsets.symmetric(
//                                             vertical: 20, horizontal: 10),
//                                         decoration: BoxDecoration(
//                                             // boxShadow: [
//                                             //   BoxShadow(
//                                             //     color:
//                                             //         const Color.fromARGB(255, 214, 214, 214)
//                                             //             .withOpacity(0.1),
//                                             //     spreadRadius: 5,
//                                             //     blurRadius: 5,
//                                             //     offset: Offset(0, 2),
//                                             //   )
//                                             // ],
//                                             color: Colors.white,
//                                             borderRadius:
//                                                 BorderRadius.circular(15)),
//                                         child: Row(
//                                           children: [
//                                             Container(
//                                               padding: EdgeInsets.all(10),
//                                               decoration: BoxDecoration(
//                                                   color: mDarkBlue
//                                                       .withOpacity(0.1),
//                                                   borderRadius:
//                                                       BorderRadius.circular(
//                                                           50)),
//                                               child: Icon(
//                                                 Icons.file_copy,
//                                                 color: mBlueColor,
//                                                 size: 20,
//                                               ),
//                                             ),
//                                             SizedBox(
//                                               width: 10,
//                                             ),
//                                             Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 Text(
//                                                   "Plan",
//                                                   textAlign: TextAlign.center,
//                                                   style: GoogleFonts.poppins(
//                                                       color: mDarkBlue
//                                                           .withOpacity(0.5),
//                                                       fontSize:
//                                                           windowWidth < 411
//                                                               ? 10
//                                                               : 12,
//                                                       fontWeight:
//                                                           FontWeight.w600),
//                                                 ),
//                                                 Text(
//                                                   dashboardResult.data != null
//                                                       ? (dashboardResult.data!
//                                                                   .displayData !=
//                                                               null
//                                                           ? dashboardResult
//                                                               .data!
//                                                               .displayData!
//                                                               .planWos
//                                                               .toString()
//                                                           : "")
//                                                       : "",
//                                                   textAlign: TextAlign.center,
//                                                   style: GoogleFonts.poppins(
//                                                       color: mDarkBlue,
//                                                       fontSize: 17,
//                                                       fontWeight:
//                                                           FontWeight.w600),
//                                                 )
//                                               ],
//                                             )
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 SizedBox(
//                                   height: 15,
//                                 ),
//                                 Row(
//                                   children: [
//                                     Expanded(
//                                       child: Container(
//                                         margin:
//                                             EdgeInsets.only(left: 10, right: 8),
//                                         padding: EdgeInsets.symmetric(
//                                             vertical: 20, horizontal: 10),
//                                         decoration: BoxDecoration(
//                                             // boxShadow: [
//                                             //   BoxShadow(
//                                             //     color:
//                                             //         const Color.fromARGB(255, 214, 214, 214)
//                                             //             .withOpacity(0.1),
//                                             //     spreadRadius: 5,
//                                             //     blurRadius: 5,
//                                             //     offset: Offset(0, 2),
//                                             //   )
//                                             // ],
//                                             color: Colors.white,
//                                             borderRadius:
//                                                 BorderRadius.circular(15)),
//                                         child: Row(
//                                           children: [
//                                             Container(
//                                               padding: EdgeInsets.all(10),
//                                               decoration: BoxDecoration(
//                                                   color: mDarkBlue
//                                                       .withOpacity(0.1),
//                                                   borderRadius:
//                                                       BorderRadius.circular(
//                                                           50)),
//                                               child: Icon(
//                                                 Icons.file_copy,
//                                                 color: mBlueColor,
//                                                 size: 20,
//                                               ),
//                                             ),
//                                             SizedBox(
//                                               width: 10,
//                                             ),
//                                             Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 Text(
//                                                   "Actual",
//                                                   textAlign: TextAlign.center,
//                                                   style: GoogleFonts.poppins(
//                                                       color: mDarkBlue
//                                                           .withOpacity(0.5),
//                                                       fontSize:
//                                                           windowWidth < 411
//                                                               ? 10
//                                                               : 12,
//                                                       fontWeight:
//                                                           FontWeight.w600),
//                                                 ),
//                                                 Text(
//                                                   dashboardResult.data != null
//                                                       ? (dashboardResult.data!
//                                                                   .displayData !=
//                                                               null
//                                                           ? dashboardResult
//                                                               .data!
//                                                               .displayData!
//                                                               .actualWos
//                                                               .toString()
//                                                           : "")
//                                                       : "",
//                                                   textAlign: TextAlign.center,
//                                                   style: GoogleFonts.poppins(
//                                                       color: mDarkBlue,
//                                                       fontSize: 17,
//                                                       fontWeight:
//                                                           FontWeight.w600),
//                                                 )
//                                               ],
//                                             )
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                     Expanded(
//                                       child: Container(
//                                         margin:
//                                             EdgeInsets.only(left: 8, right: 10),
//                                         padding: EdgeInsets.symmetric(
//                                             vertical: 12, horizontal: 10),
//                                         decoration: BoxDecoration(
//                                             // boxShadow: [
//                                             //   BoxShadow(
//                                             //     color:
//                                             //         const Color.fromARGB(255, 214, 214, 214)
//                                             //             .withOpacity(0.1),
//                                             //     spreadRadius: 5,
//                                             //     blurRadius: 5,
//                                             //     offset: Offset(0, 2),
//                                             //   )
//                                             // ],
//                                             color: Colors.white,
//                                             borderRadius:
//                                                 BorderRadius.circular(15)),
//                                         child: Row(
//                                           children: [
//                                             Container(
//                                               padding: EdgeInsets.all(10),
//                                               decoration: BoxDecoration(
//                                                   color: mDarkBlue
//                                                       .withOpacity(0.1),
//                                                   borderRadius:
//                                                       BorderRadius.circular(
//                                                           50)),
//                                               child: Icon(
//                                                 Icons.file_copy,
//                                                 color: mBlueColor,
//                                                 size: 20,
//                                               ),
//                                             ),
//                                             SizedBox(
//                                               width: 10,
//                                             ),
//                                             Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 Text(
//                                                   "Down Time",
//                                                   textAlign: TextAlign.center,
//                                                   style: GoogleFonts.poppins(
//                                                       color: mDarkBlue
//                                                           .withOpacity(0.5),
//                                                       fontSize:
//                                                           windowWidth < 411
//                                                               ? 10
//                                                               : 12,
//                                                       fontWeight:
//                                                           FontWeight.w600),
//                                                 ),
//                                                 Text(
//                                                   "Minutes",
//                                                   textAlign: TextAlign.center,
//                                                   style: GoogleFonts.poppins(
//                                                       color: mDarkBlue
//                                                           .withOpacity(0.5),
//                                                       fontSize: 10,
//                                                       fontWeight:
//                                                           FontWeight.w600),
//                                                 ),
//                                                 Text(
//                                                   dashboardResult.data != null
//                                                       ? (dashboardResult.data!
//                                                                   .displayData !=
//                                                               null
//                                                           ? dashboardResult
//                                                               .data!
//                                                               .displayData!
//                                                               .stopTime
//                                                               .toString()
//                                                           : "")
//                                                       : "",
//                                                   textAlign: TextAlign.center,
//                                                   style: GoogleFonts.poppins(
//                                                       color: mDarkBlue,
//                                                       fontSize: 17,
//                                                       fontWeight:
//                                                           FontWeight.w600),
//                                                 )
//                                               ],
//                                             )
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 SizedBox(
//                                   height: 15,
//                                 ),
//                               ] else ...[
//                                 Row(
//                                   children: [
//                                     Expanded(
//                                       child: Container(
//                                         margin: EdgeInsets.only(
//                                             left: windowWidth < 1400 ? 10 : 20,
//                                             right: 8),
//                                         padding: windowWidth < 1400
//                                             ? EdgeInsets.symmetric(
//                                                 vertical: 10, horizontal: 10)
//                                             : EdgeInsets.symmetric(
//                                                 vertical: 20, horizontal: 20),
//                                         decoration: BoxDecoration(
//                                             // boxShadow: [
//                                             //   BoxShadow(
//                                             //     color:
//                                             //         const Color.fromARGB(255, 214, 214, 214)
//                                             //             .withOpacity(0.1),
//                                             //     spreadRadius: 5,
//                                             //     blurRadius: 5,
//                                             //     offset: Offset(0, 2),
//                                             //   )
//                                             // ],
//                                             color: Colors.white,
//                                             borderRadius:
//                                                 BorderRadius.circular(15)),
//                                         child: Row(
//                                           children: [
//                                             Container(
//                                               padding: windowWidth < 1400
//                                                   ? EdgeInsets.all(10)
//                                                   : EdgeInsets.all(15),
//                                               decoration: BoxDecoration(
//                                                   gradient: LinearGradient(
//                                                       begin: Alignment.topLeft,
//                                                       end:
//                                                           Alignment.bottomRight,
//                                                       colors: <Color>[
//                                                         Color.fromARGB(
//                                                             255, 1, 121, 219),
//                                                         Color.fromARGB(
//                                                             255, 95, 183, 255)
//                                                       ]),
//                                                   // color: mDarkBlue.withOpacity(0.1),
//                                                   borderRadius:
//                                                       BorderRadius.circular(
//                                                           50)),
//                                               child: Icon(
//                                                 Icons.date_range_rounded,
//                                                 color: Colors.white,
//                                                 size: windowWidth < 1400
//                                                     ? 20
//                                                     : 25,
//                                               ),
//                                             ),
//                                             SizedBox(
//                                               width: 10,
//                                             ),
//                                             Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 Text(
//                                                   "Date",
//                                                   textAlign: TextAlign.center,
//                                                   style: GoogleFonts.poppins(
//                                                       color: mDarkBlue
//                                                           .withOpacity(0.5),
//                                                       fontSize:
//                                                           windowWidth < 1400
//                                                               ? 11
//                                                               : 14,
//                                                       fontWeight:
//                                                           FontWeight.w600),
//                                                 ),
//                                                 Text(
//                                                   formattedDate,
//                                                   textAlign: TextAlign.center,
//                                                   style: GoogleFonts.poppins(
//                                                       color: mDarkBlue,
//                                                       fontSize:
//                                                           windowWidth < 1400
//                                                               ? 17
//                                                               : 22,
//                                                       fontWeight:
//                                                           FontWeight.w600),
//                                                 )
//                                               ],
//                                             )
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                     Expanded(
//                                       child: Container(
//                                         margin: EdgeInsets.only(
//                                             left: windowWidth < 1400 ? 10 : 20,
//                                             right: 8),
//                                         padding: windowWidth < 1400
//                                             ? EdgeInsets.symmetric(
//                                                 vertical: 10, horizontal: 10)
//                                             : EdgeInsets.symmetric(
//                                                 vertical: 20, horizontal: 20),
//                                         decoration: BoxDecoration(
//                                             // boxShadow: [
//                                             //   BoxShadow(
//                                             //     color:
//                                             //         const Color.fromARGB(255, 214, 214, 214)
//                                             //             .withOpacity(0.1),
//                                             //     spreadRadius: 5,
//                                             //     blurRadius: 5,
//                                             //     offset: Offset(0, 2),
//                                             //   )
//                                             // ],
//                                             color: Colors.white,
//                                             borderRadius: windowWidth < 1400
//                                                 ? BorderRadius.circular(10)
//                                                 : BorderRadius.circular(15)),
//                                         child: Row(
//                                           children: [
//                                             Container(
//                                               padding: windowWidth < 1400
//                                                   ? EdgeInsets.all(10)
//                                                   : EdgeInsets.all(15),
//                                               decoration: BoxDecoration(
//                                                   color: mDarkBlue
//                                                       .withOpacity(0.1),
//                                                   borderRadius:
//                                                       BorderRadius.circular(
//                                                           50)),
//                                               child: Icon(
//                                                 Icons.file_copy,
//                                                 color: mBlueColor,
//                                                 size: windowWidth < 1400
//                                                     ? 20
//                                                     : 25,
//                                               ),
//                                             ),
//                                             SizedBox(
//                                               width: 10,
//                                             ),
//                                             Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 Text(
//                                                   "Shift",
//                                                   textAlign: TextAlign.center,
//                                                   style: GoogleFonts.poppins(
//                                                       color: mDarkBlue
//                                                           .withOpacity(0.5),
//                                                       fontSize:
//                                                           windowWidth < 1400
//                                                               ? 11
//                                                               : 14,
//                                                       fontWeight:
//                                                           FontWeight.w600),
//                                                 ),
//                                                 Text(
//                                                   dashboardResult.data != null
//                                                       ? (dashboardResult.data!
//                                                                   .displayData !=
//                                                               null
//                                                           ? dashboardResult
//                                                               .data!
//                                                               .displayData!
//                                                               .shift
//                                                               .name
//                                                           : "")
//                                                       : "",
//                                                   textAlign: TextAlign.center,
//                                                   style: GoogleFonts.poppins(
//                                                       color: mDarkBlue,
//                                                       fontSize:
//                                                           windowWidth < 1400
//                                                               ? 17
//                                                               : 22,
//                                                       fontWeight:
//                                                           FontWeight.w600),
//                                                 )
//                                               ],
//                                             )
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                     Expanded(
//                                       child: Container(
//                                         margin: EdgeInsets.only(
//                                             left: windowWidth < 1400 ? 10 : 20,
//                                             right: 10),
//                                         padding: windowWidth < 1400
//                                             ? EdgeInsets.symmetric(
//                                                 vertical: 10, horizontal: 10)
//                                             : EdgeInsets.symmetric(
//                                                 vertical: 20, horizontal: 20),
//                                         decoration: BoxDecoration(
//                                             // boxShadow: [
//                                             //   BoxShadow(
//                                             //     color:
//                                             //         const Color.fromARGB(255, 214, 214, 214)
//                                             //             .withOpacity(0.1),
//                                             //     spreadRadius: 5,
//                                             //     blurRadius: 5,
//                                             //     offset: Offset(0, 2),
//                                             //   )
//                                             // ],
//                                             color: Colors.white,
//                                             borderRadius: windowWidth < 1400
//                                                 ? BorderRadius.circular(10)
//                                                 : BorderRadius.circular(15)),
//                                         child: Row(
//                                           children: [
//                                             Container(
//                                               padding: windowWidth < 1400
//                                                   ? EdgeInsets.all(10)
//                                                   : EdgeInsets.all(15),
//                                               decoration: BoxDecoration(
//                                                   color: mDarkBlue
//                                                       .withOpacity(0.1),
//                                                   borderRadius:
//                                                       BorderRadius.circular(
//                                                           50)),
//                                               child: Icon(
//                                                 Icons.file_copy,
//                                                 color: mBlueColor,
//                                                 size: windowWidth < 1400
//                                                     ? 20
//                                                     : 25,
//                                               ),
//                                             ),
//                                             SizedBox(
//                                               width: 10,
//                                             ),
//                                             Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 Text(
//                                                   "Plan",
//                                                   textAlign: TextAlign.center,
//                                                   style: GoogleFonts.poppins(
//                                                       color: mDarkBlue
//                                                           .withOpacity(0.5),
//                                                       fontSize:
//                                                           windowWidth < 1400
//                                                               ? 11
//                                                               : 14,
//                                                       fontWeight:
//                                                           FontWeight.w600),
//                                                 ),
//                                                 Text(
//                                                   dashboardResult.data != null
//                                                       ? (dashboardResult.data!
//                                                                   .displayData !=
//                                                               null
//                                                           ? dashboardResult
//                                                               .data!
//                                                               .displayData!
//                                                               .planWos
//                                                               .toString()
//                                                           : "")
//                                                       : "",
//                                                   textAlign: TextAlign.center,
//                                                   style: GoogleFonts.poppins(
//                                                       color: mDarkBlue,
//                                                       fontSize:
//                                                           windowWidth < 1400
//                                                               ? 17
//                                                               : 22,
//                                                       fontWeight:
//                                                           FontWeight.w600),
//                                                 )
//                                               ],
//                                             )
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                     Expanded(
//                                       child: Container(
//                                         margin: EdgeInsets.only(
//                                             left: windowWidth < 1400 ? 10 : 20,
//                                             right: 8),
//                                         padding: windowWidth < 1400
//                                             ? EdgeInsets.symmetric(
//                                                 vertical: 10, horizontal: 10)
//                                             : EdgeInsets.symmetric(
//                                                 vertical: 20, horizontal: 20),
//                                         decoration: BoxDecoration(
//                                             // boxShadow: [
//                                             //   BoxShadow(
//                                             //     color:
//                                             //         const Color.fromARGB(255, 214, 214, 214)
//                                             //             .withOpacity(0.1),
//                                             //     spreadRadius: 5,
//                                             //     blurRadius: 5,
//                                             //     offset: Offset(0, 2),
//                                             //   )
//                                             // ],
//                                             color: Colors.white,
//                                             borderRadius: windowWidth < 1400
//                                                 ? BorderRadius.circular(10)
//                                                 : BorderRadius.circular(15)),
//                                         child: Row(
//                                           children: [
//                                             Container(
//                                               padding: windowWidth < 1400
//                                                   ? EdgeInsets.all(10)
//                                                   : EdgeInsets.all(15),
//                                               decoration: BoxDecoration(
//                                                   color: mDarkBlue
//                                                       .withOpacity(0.1),
//                                                   borderRadius:
//                                                       BorderRadius.circular(
//                                                           50)),
//                                               child: Icon(
//                                                 Icons.file_copy,
//                                                 color: mBlueColor,
//                                                 size: windowWidth < 1400
//                                                     ? 20
//                                                     : 25,
//                                               ),
//                                             ),
//                                             SizedBox(
//                                               width: 10,
//                                             ),
//                                             Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 Text(
//                                                   "Actual",
//                                                   textAlign: TextAlign.center,
//                                                   style: GoogleFonts.poppins(
//                                                       color: mDarkBlue
//                                                           .withOpacity(0.5),
//                                                       fontSize:
//                                                           windowWidth < 1400
//                                                               ? 11
//                                                               : 14,
//                                                       fontWeight:
//                                                           FontWeight.w600),
//                                                 ),
//                                                 Text(
//                                                   dashboardResult.data != null
//                                                       ? (dashboardResult.data!
//                                                                   .displayData !=
//                                                               null
//                                                           ? dashboardResult
//                                                               .data!
//                                                               .displayData!
//                                                               .actualWos
//                                                               .toString()
//                                                           : "")
//                                                       : "",
//                                                   textAlign: TextAlign.center,
//                                                   style: GoogleFonts.poppins(
//                                                       color: mDarkBlue,
//                                                       fontSize:
//                                                           windowWidth < 1400
//                                                               ? 17
//                                                               : 22,
//                                                       fontWeight:
//                                                           FontWeight.w600),
//                                                 )
//                                               ],
//                                             )
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                     Expanded(
//                                       child: Container(
//                                         margin: EdgeInsets.only(
//                                             left: windowWidth < 1400 ? 10 : 20,
//                                             right:
//                                                 windowWidth < 1400 ? 10 : 20),
//                                         decoration: BoxDecoration(
//                                             // boxShadow: [
//                                             //   BoxShadow(
//                                             //     color:
//                                             //         const Color.fromARGB(255, 214, 214, 214)
//                                             //             .withOpacity(0.1),
//                                             //     spreadRadius: 5,
//                                             //     blurRadius: 5,
//                                             //     offset: Offset(0, 2),
//                                             //   )
//                                             // ],
//                                             color: mBlueColor,
//                                             borderRadius: windowWidth < 1400
//                                                 ? BorderRadius.circular(10)
//                                                 : BorderRadius.circular(15)),
//                                         child: new Material(
//                                           color: Colors.transparent,
//                                           borderRadius:
//                                               BorderRadius.circular(15),
//                                           child: InkWell(
//                                             onTap: () {
//                                               showDialog(
//                                                   barrierDismissible: false,
//                                                   context: context,
//                                                   builder: (dialogcontext) {
//                                                     return AlertDialog(
//                                                         content: Column(
//                                                       mainAxisSize:
//                                                           MainAxisSize.min,
//                                                       crossAxisAlignment:
//                                                           CrossAxisAlignment
//                                                               .center,
//                                                       children: [
//                                                         // Lottie.asset(
//                                                         //     'assets/json/loadingBlue.json',
//                                                         //     height: 100,
//                                                         //     width: 100),
//                                                         SizedBox(
//                                                           height: 20,
//                                                           width: 400,
//                                                         ),
//                                                         Text(
//                                                           'Scan Barcode',
//                                                           style:
//                                                               GoogleFonts.inter(
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .w700,
//                                                                   fontSize: 17,
//                                                                   color: Color
//                                                                       .fromARGB(
//                                                                           255,
//                                                                           75,
//                                                                           75,
//                                                                           75)),
//                                                         ),
//                                                         SizedBox(
//                                                           height: 20,
//                                                         ),
//                                                         Container(
//                                                           decoration: BoxDecoration(
//                                                               color:
//                                                                   Colors.white,
//                                                               border: Border.all(
//                                                                   color: Color
//                                                                       .fromARGB(
//                                                                           249,
//                                                                           241,
//                                                                           241,
//                                                                           241),
//                                                                   width: 1.5),
//                                                               borderRadius:
//                                                                   BorderRadius
//                                                                       .circular(
//                                                                           10)),
//                                                           child: Row(
//                                                             children: <Widget>[
//                                                               // Container(
//                                                               //     width: 60,
//                                                               //     child: Icon(
//                                                               //       widget.icon,
//                                                               //       size: 20,
//                                                               //       color: Color(0xFFBB9B9B9),
//                                                               //     )),
//                                                               SizedBox(
//                                                                 width: 20,
//                                                               ),
//                                                               Expanded(
//                                                                 child:
//                                                                     TextField(
//                                                                   focusNode:
//                                                                       _focusNode,
//                                                                   autofocus:
//                                                                       true, // Set autofocus to true
//                                                                   controller:
//                                                                       controllerCari,
//                                                                   style: GoogleFonts.poppins(
//                                                                       fontSize:
//                                                                           14,
//                                                                       fontWeight:
//                                                                           FontWeight
//                                                                               .w600),
//                                                                   decoration: InputDecoration(
//                                                                       hintStyle: GoogleFonts.poppins(
//                                                                         fontSize:
//                                                                             14,
//                                                                       ),
//                                                                       contentPadding: EdgeInsets.symmetric(vertical: 5),
//                                                                       border: InputBorder.none,
//                                                                       hintText: "Input Manually"),
//                                                                   onChanged:
//                                                                       (val) async {
//                                                                     if (val !=
//                                                                         "") {
//                                                                       print(
//                                                                           val);
//                                                                     }
//                                                                   },
//                                                                 ),
//                                                               )
//                                                             ],
//                                                           ),
//                                                         ),
//                                                         SizedBox(
//                                                           height: 20,
//                                                         ),
//                                                         Row(
//                                                           children: [
//                                                             Expanded(
//                                                               child: InkWell(
//                                                                 onTap:
//                                                                     () async {
//                                                                   try {
//                                                                     token =
//                                                                         await readToken();
//                                                                     log("To " +
//                                                                         token);
//                                                                     Future.delayed(
//                                                                         const Duration(
//                                                                             milliseconds:
//                                                                                 0),
//                                                                         () {
//                                                                       setState(
//                                                                           () {
//                                                                         _isLoading =
//                                                                             true;
//                                                                       });
//                                                                     });
//                                                                     PostBarcode.connectToApi(
//                                                                             token,
//                                                                             controllerCari
//                                                                                 .text)
//                                                                         .then(
//                                                                             (value) {
//                                                                       setState(
//                                                                           () {
//                                                                         Future.delayed(
//                                                                             const Duration(milliseconds: 2000),
//                                                                             () {
//                                                                           setState(
//                                                                               () {
//                                                                             _isLoading =
//                                                                                 false;
//                                                                           });
//                                                                         });
//                                                                         //print(storage.read(key: "token"));
//                                                                         if (value.status ==
//                                                                             200) {
//                                                                           FancySnackbar
//                                                                               .showSnackbar(
//                                                                             context,
//                                                                             snackBarType:
//                                                                                 FancySnackBarType.success,
//                                                                             title:
//                                                                                 "Successfully!",
//                                                                             message:
//                                                                                 value.message,
//                                                                             duration:
//                                                                                 1,
//                                                                             onCloseEvent:
//                                                                                 () {},
//                                                                           );
//                                                                           controllerCari.text =
//                                                                               "";
//                                                                           setState(
//                                                                               () {});
//                                                                           Navigator.pop(
//                                                                               dialogcontext);
//                                                                         } else {
//                                                                           FancySnackbar
//                                                                               .showSnackbar(
//                                                                             context,
//                                                                             snackBarType:
//                                                                                 FancySnackBarType.error,
//                                                                             title:
//                                                                                 "Failed!",
//                                                                             message:
//                                                                                 value.message,
//                                                                             duration:
//                                                                                 5,
//                                                                             onCloseEvent:
//                                                                                 () {},
//                                                                           );
//                                                                           controllerCari.text =
//                                                                               "";
//                                                                           setState(
//                                                                               () {});
//                                                                         }
//                                                                       });
//                                                                     });
//                                                                   } catch (x) {
//                                                                     Future.delayed(
//                                                                         const Duration(
//                                                                             milliseconds:
//                                                                                 2000),
//                                                                         () {
//                                                                       setState(
//                                                                           () {
//                                                                         _isLoading =
//                                                                             false;
//                                                                         controllerCari.text =
//                                                                             "";
//                                                                         setState(
//                                                                             () {});
//                                                                         Navigator.pop(
//                                                                             dialogcontext);
//                                                                       });
//                                                                     });
//                                                                   }
//                                                                 },
//                                                                 child:
//                                                                     Container(
//                                                                   decoration: BoxDecoration(
//                                                                       boxShadow: [
//                                                                         BoxShadow(
//                                                                           color: Colors
//                                                                               .grey
//                                                                               .withOpacity(0.2),
//                                                                           spreadRadius:
//                                                                               5,
//                                                                           blurRadius:
//                                                                               5,
//                                                                           offset: Offset(
//                                                                               0,
//                                                                               2),
//                                                                         )
//                                                                       ],
//                                                                       color:
//                                                                           mBlueColor,
//                                                                       borderRadius:
//                                                                           BorderRadius.circular(
//                                                                               10)),
//                                                                   padding:
//                                                                       EdgeInsets
//                                                                           .all(
//                                                                               8),
//                                                                   child: Center(
//                                                                     child: Text(
//                                                                       "Check",
//                                                                       style: GoogleFonts.poppins(
//                                                                           color: Colors
//                                                                               .white,
//                                                                           fontSize:
//                                                                               16),
//                                                                     ),
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                         SizedBox(
//                                                           height: 20,
//                                                         ),
//                                                         Row(
//                                                           mainAxisAlignment:
//                                                               MainAxisAlignment
//                                                                   .spaceBetween,
//                                                           children: [
//                                                             Column(
//                                                               crossAxisAlignment:
//                                                                   CrossAxisAlignment
//                                                                       .start,
//                                                               children: [
//                                                                 Text(
//                                                                   "Serial Number",
//                                                                   textAlign:
//                                                                       TextAlign
//                                                                           .start,
//                                                                   style: GoogleFonts.poppins(
//                                                                       color: Colors
//                                                                           .grey,
//                                                                       fontSize: windowWidth <
//                                                                               1400
//                                                                           ? 13
//                                                                           : 16,
//                                                                       fontWeight:
//                                                                           FontWeight
//                                                                               .w600),
//                                                                 ),
//                                                                 Text(
//                                                                   "-",
//                                                                   textAlign:
//                                                                       TextAlign
//                                                                           .start,
//                                                                   style: GoogleFonts.poppins(
//                                                                       color:
//                                                                           mDarkBlue,
//                                                                       fontSize: windowWidth <
//                                                                               1400
//                                                                           ? 15
//                                                                           : 18,
//                                                                       fontWeight:
//                                                                           FontWeight
//                                                                               .w700),
//                                                                 ),
//                                                               ],
//                                                             ),
//                                                             Column(
//                                                               crossAxisAlignment:
//                                                                   CrossAxisAlignment
//                                                                       .start,
//                                                               children: [
//                                                                 Text(
//                                                                   "Scanned Time",
//                                                                   textAlign:
//                                                                       TextAlign
//                                                                           .start,
//                                                                   style: GoogleFonts.poppins(
//                                                                       color: Colors
//                                                                           .grey,
//                                                                       fontSize: windowWidth <
//                                                                               1400
//                                                                           ? 10
//                                                                           : 12,
//                                                                       fontWeight:
//                                                                           FontWeight
//                                                                               .w600),
//                                                                 ),
//                                                                 Text(
//                                                                   "21/02/2024\n09:29:22",
//                                                                   textAlign:
//                                                                       TextAlign
//                                                                           .start,
//                                                                   style: GoogleFonts.poppins(
//                                                                       color:
//                                                                           mDarkBlue,
//                                                                       fontSize: windowWidth <
//                                                                               1400
//                                                                           ? 11
//                                                                           : 13,
//                                                                       fontWeight:
//                                                                           FontWeight
//                                                                               .w700),
//                                                                 ),
//                                                               ],
//                                                             ),
//                                                           ],
//                                                         ),
//                                                         SizedBox(
//                                                           height: 20,
//                                                         ),
//                                                         Row(
//                                                           children: [
//                                                             Expanded(
//                                                               child: InkWell(
//                                                                 onTap:
//                                                                     () async {
//                                                                   Navigator.pop(
//                                                                       dialogcontext);
//                                                                 },
//                                                                 child:
//                                                                     Container(
//                                                                   decoration: BoxDecoration(
//                                                                       boxShadow: [
//                                                                         BoxShadow(
//                                                                           color: Colors
//                                                                               .grey
//                                                                               .withOpacity(0.2),
//                                                                           spreadRadius:
//                                                                               5,
//                                                                           blurRadius:
//                                                                               5,
//                                                                           offset: Offset(
//                                                                               0,
//                                                                               2),
//                                                                         )
//                                                                       ],
//                                                                       color: Color.fromARGB(
//                                                                           255,
//                                                                           134,
//                                                                           219,
//                                                                           137),
//                                                                       borderRadius:
//                                                                           BorderRadius.circular(
//                                                                               10)),
//                                                                   padding:
//                                                                       EdgeInsets
//                                                                           .all(
//                                                                               8),
//                                                                   child: Center(
//                                                                     child: Text(
//                                                                       "OK",
//                                                                       style: GoogleFonts.poppins(
//                                                                           color: const Color.fromARGB(
//                                                                               255,
//                                                                               46,
//                                                                               46,
//                                                                               46),
//                                                                           fontSize:
//                                                                               16),
//                                                                     ),
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                             SizedBox(
//                                                               width: 20,
//                                                             ),
//                                                             Expanded(
//                                                               child: InkWell(
//                                                                 onTap:
//                                                                     () async {
//                                                                   Navigator.pop(
//                                                                       dialogcontext);
//                                                                 },
//                                                                 child:
//                                                                     Container(
//                                                                   decoration: BoxDecoration(
//                                                                       boxShadow: [
//                                                                         BoxShadow(
//                                                                           color: Colors
//                                                                               .grey
//                                                                               .withOpacity(0.2),
//                                                                           spreadRadius:
//                                                                               5,
//                                                                           blurRadius:
//                                                                               5,
//                                                                           offset: Offset(
//                                                                               0,
//                                                                               2),
//                                                                         )
//                                                                       ],
//                                                                       color: Colors
//                                                                           .red,
//                                                                       borderRadius:
//                                                                           BorderRadius.circular(
//                                                                               10)),
//                                                                   padding:
//                                                                       EdgeInsets
//                                                                           .all(
//                                                                               8),
//                                                                   child: Center(
//                                                                     child: Text(
//                                                                       "NG",
//                                                                       style: GoogleFonts.poppins(
//                                                                           color: Colors
//                                                                               .white,
//                                                                           fontSize:
//                                                                               16),
//                                                                     ),
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                         SizedBox(
//                                                           height: 20,
//                                                         ),
//                                                         Row(
//                                                           children: [
//                                                             Expanded(
//                                                               child: InkWell(
//                                                                 onTap:
//                                                                     () async {
//                                                                   Navigator.pop(
//                                                                       dialogcontext);
//                                                                 },
//                                                                 child:
//                                                                     Container(
//                                                                   decoration: BoxDecoration(
//                                                                       boxShadow: [
//                                                                         BoxShadow(
//                                                                           color: Colors
//                                                                               .grey
//                                                                               .withOpacity(0.2),
//                                                                           spreadRadius:
//                                                                               5,
//                                                                           blurRadius:
//                                                                               5,
//                                                                           offset: Offset(
//                                                                               0,
//                                                                               2),
//                                                                         )
//                                                                       ],
//                                                                       color: Color.fromARGB(
//                                                                           255,
//                                                                           107,
//                                                                           107,
//                                                                           107),
//                                                                       borderRadius:
//                                                                           BorderRadius.circular(
//                                                                               10)),
//                                                                   padding:
//                                                                       EdgeInsets
//                                                                           .all(
//                                                                               8),
//                                                                   child: Center(
//                                                                     child: Text(
//                                                                       "Cancel",
//                                                                       style: GoogleFonts.poppins(
//                                                                           color: Colors
//                                                                               .white,
//                                                                           fontSize:
//                                                                               16),
//                                                                     ),
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                         // Row(
//                                                         //   children: [
//                                                         //     Expanded(
//                                                         //       child: InkWell(
//                                                         //         onTap: () async {
//                                                         //         },
//                                                         //         child: Container(
//                                                         //           decoration: BoxDecoration(
//                                                         //               boxShadow: [
//                                                         //                 BoxShadow(
//                                                         //                   color: mTitleBlue
//                                                         //                       .withOpacity(
//                                                         //                           0.2),
//                                                         //                   spreadRadius: 5,
//                                                         //                   blurRadius: 5,
//                                                         //                   offset: Offset(
//                                                         //                       0, 2),
//                                                         //                 )
//                                                         //               ],
//                                                         //               color: mTitleBlue,
//                                                         //               borderRadius:
//                                                         //                   BorderRadius
//                                                         //                       .circular(
//                                                         //                           10)),
//                                                         //           padding:
//                                                         //               EdgeInsets.all(8),
//                                                         //           child: Center(
//                                                         //             child: Text(
//                                                         //               "Download ",
//                                                         //               style: GoogleFonts
//                                                         //                   .poppins(
//                                                         //                       color: Colors
//                                                         //                           .white,
//                                                         //                       fontSize:
//                                                         //                           16),
//                                                         //             ),
//                                                         //           ),
//                                                         //         ),
//                                                         //       ),
//                                                         //     ),
//                                                         //     SizedBox(
//                                                         //       width: 10,
//                                                         //     ),

//                                                         //   ],
//                                                         // ),
//                                                       ],
//                                                     ));
//                                                   });
//                                             },
//                                             child: Container(
//                                               padding: windowWidth < 1400
//                                                   ? EdgeInsets.symmetric(
//                                                       vertical: 10,
//                                                       horizontal: 10)
//                                                   : EdgeInsets.symmetric(
//                                                       vertical: 20,
//                                                       horizontal: 20),
//                                               decoration: BoxDecoration(
//                                                   // boxShadow: [
//                                                   //   BoxShadow(
//                                                   //     color:
//                                                   //         const Color.fromARGB(255, 214, 214, 214)
//                                                   //             .withOpacity(0.1),
//                                                   //     spreadRadius: 5,
//                                                   //     blurRadius: 5,
//                                                   //     offset: Offset(0, 2),
//                                                   //   )
//                                                   // ],
//                                                   color: Colors.transparent,
//                                                   borderRadius: windowWidth <
//                                                           1400
//                                                       ? BorderRadius.circular(
//                                                           10)
//                                                       : BorderRadius.circular(
//                                                           15)),
//                                               child: Row(
//                                                 children: [
//                                                   Container(
//                                                     padding: windowWidth < 1400
//                                                         ? EdgeInsets.all(10)
//                                                         : EdgeInsets.all(15),
//                                                     decoration: BoxDecoration(
//                                                         color: Colors.white,
//                                                         borderRadius:
//                                                             BorderRadius
//                                                                 .circular(50)),
//                                                     child: Icon(
//                                                       Icons
//                                                           .qr_code_scanner_rounded,
//                                                       color: mBlueColor,
//                                                       size: windowWidth < 1400
//                                                           ? 20
//                                                           : 25,
//                                                     ),
//                                                   ),
//                                                   SizedBox(
//                                                     width: 10,
//                                                   ),
//                                                   Column(
//                                                     crossAxisAlignment:
//                                                         CrossAxisAlignment
//                                                             .start,
//                                                     children: [
//                                                       Text(
//                                                         "Barcode Scanner",
//                                                         textAlign:
//                                                             TextAlign.center,
//                                                         style:
//                                                             GoogleFonts.poppins(
//                                                                 color: Colors
//                                                                     .white,
//                                                                 fontSize:
//                                                                     windowWidth <
//                                                                             1400
//                                                                         ? 11
//                                                                         : 14,
//                                                                 fontWeight:
//                                                                     FontWeight
//                                                                         .w600),
//                                                       ),
//                                                       Text(
//                                                         "SCAN NOW",
//                                                         textAlign:
//                                                             TextAlign.center,
//                                                         style:
//                                                             GoogleFonts.poppins(
//                                                                 color: Colors
//                                                                     .white,
//                                                                 fontSize:
//                                                                     windowWidth <
//                                                                             1400
//                                                                         ? 17
//                                                                         : 22,
//                                                                 fontWeight:
//                                                                     FontWeight
//                                                                         .w600),
//                                                       )
//                                                     ],
//                                                   )
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 SizedBox(
//                                   height: 15,
//                                 ),
//                               ],
//                               SizedBox(
//                                 height: windowWidth < 1400 ? 0 : 15,
//                               ),
//                             ],
//                           ),
//                         );
//                       }),
//                   if (isWindows) ...[
//                     Expanded(
//                       child: Column(
//                         children: [
//                           Container(
//                             margin: EdgeInsets.only(right: 10),
//                             child: Row(
//                               children: [
//                                 Expanded(
//                                   child: cardChart(
//                                     isWindows: isWindows,
//                                     chartData: [
//                                       ChartData(
//                                           'Sudah',
//                                           dashboardResult.data != null
//                                               ? (dashboardResult
//                                                           .data!.displayData !=
//                                                       null
//                                                   ? double.parse(dashboardResult
//                                                       .data!
//                                                       .displayData!
//                                                       .oee
//                                                       .oee)
//                                                   : 0)
//                                               : 0),
//                                       ChartData(
//                                           'Belum',
//                                           100 -
//                                               (dashboardResult.data != null
//                                                   ? (dashboardResult.data!
//                                                               .displayData !=
//                                                           null
//                                                       ? double.parse(
//                                                           dashboardResult
//                                                               .data!
//                                                               .displayData!
//                                                               .oee
//                                                               .oee)
//                                                       : 0)
//                                                   : 0)),
//                                     ],
//                                     colorChart: mBlueColor,
//                                     nameChart: "OEE SEALING",
//                                     valueChart: dashboardResult.data != null
//                                         ? (dashboardResult.data!.displayData !=
//                                                 null
//                                             ? double.parse(dashboardResult
//                                                 .data!.displayData!.oee.oee)
//                                             : 0)
//                                         : 0,
//                                     valueTopCoat: dashboardResult.data != null
//                                         ? (dashboardResult.data!.displayData !=
//                                                 null
//                                             ? double.parse(dashboardResult
//                                                     .data!
//                                                     .displayData!
//                                                     .oee
//                                                     .availability) /
//                                                 100
//                                             : 0)
//                                         : 0,
//                                     valueSealing: dashboardResult.data != null
//                                         ? (dashboardResult.data!.displayData !=
//                                                 null
//                                             ? double.parse(dashboardResult
//                                                     .data!
//                                                     .displayData!
//                                                     .oee
//                                                     .performance) /
//                                                 100
//                                             : 0)
//                                         : 0,
//                                     valueLoading: dashboardResult.data != null
//                                         ? (dashboardResult.data!.displayData !=
//                                                 null
//                                             ? double.parse(dashboardResult.data!
//                                                     .displayData!.oee.quality) /
//                                                 100
//                                             : 0)
//                                         : 0,
//                                     detailName: "DETAIL",
//                                     nameDataOne: "Availability",
//                                     nameDataTwo: "Performance",
//                                     nameDataThree: "Quality",
//                                   ),
//                                 ),
//                                 Expanded(
//                                   child: cardChart(
//                                     isWindows: isWindows,
//                                     chartData: [
//                                       ChartData(
//                                           'Sudah',
//                                           dashboardResult.data != null
//                                               ? (dashboardResult
//                                                           .data!.displayData !=
//                                                       null
//                                                   ? double.parse(dashboardResult
//                                                       .data!
//                                                       .displayData!
//                                                       .oee
//                                                       .availability)
//                                                   : 0)
//                                               : 0),
//                                       ChartData(
//                                           'Belum',
//                                           100 -
//                                               (dashboardResult.data != null
//                                                   ? (dashboardResult.data!
//                                                               .displayData !=
//                                                           null
//                                                       ? double.parse(
//                                                           dashboardResult
//                                                               .data!
//                                                               .displayData!
//                                                               .oee
//                                                               .availability)
//                                                       : 0)
//                                                   : 0)),
//                                     ],
//                                     colorChart: Colors.green,
//                                     nameChart: "AVAILABILITY SEALING",
//                                     valueChart: dashboardResult.data != null
//                                         ? (dashboardResult.data!.displayData !=
//                                                 null
//                                             ? double.parse(dashboardResult.data!
//                                                 .displayData!.oee.availability)
//                                             : 0)
//                                         : 0,
//                                     valueTopCoat: dashboardResult.data != null
//                                         ? (dashboardResult
//                                                     .data!.availabilityData !=
//                                                 null
//                                             ? double.parse(dashboardResult.data!
//                                                     .availabilityData!.topCoat
//                                                     .toString()) /
//                                                 100
//                                             : 0)
//                                         : 0,
//                                     valueSealing: dashboardResult.data != null
//                                         ? (dashboardResult
//                                                     .data!.availabilityData !=
//                                                 null
//                                             ? double.parse(dashboardResult.data!
//                                                     .availabilityData!.sealing
//                                                     .toString()) /
//                                                 100
//                                             : 0)
//                                         : 0,
//                                     valueLoading: dashboardResult.data != null
//                                         ? (dashboardResult
//                                                     .data!.availabilityData !=
//                                                 null
//                                             ? double.parse(dashboardResult.data!
//                                                     .availabilityData!.loading
//                                                     .toString()) /
//                                                 100
//                                             : 0)
//                                         : 0,
//                                     detailName: "AVAILABILITY DETAIL",
//                                     nameDataOne: "Top Coat",
//                                     nameDataTwo: "Sealing",
//                                     nameDataThree: "Loading PTED",
//                                   ),
//                                 ),
//                                 Expanded(
//                                   child: cardChart(
//                                     isWindows: isWindows,
//                                     chartData: [
//                                       ChartData(
//                                           'Sudah',
//                                           dashboardResult.data != null
//                                               ? (dashboardResult
//                                                           .data!.displayData !=
//                                                       null
//                                                   ? double.parse(dashboardResult
//                                                       .data!
//                                                       .displayData!
//                                                       .oee
//                                                       .performance)
//                                                   : 0)
//                                               : 0),
//                                       ChartData(
//                                           'Belum',
//                                           100 -
//                                               (dashboardResult.data != null
//                                                   ? (dashboardResult.data!
//                                                               .displayData !=
//                                                           null
//                                                       ? double.parse(
//                                                           dashboardResult
//                                                               .data!
//                                                               .displayData!
//                                                               .oee
//                                                               .performance)
//                                                       : 0)
//                                                   : 0)),
//                                     ],
//                                     colorChart: Colors.orange,
//                                     nameChart: "PERFORMANCE SEALING",
//                                     valueChart: dashboardResult.data != null
//                                         ? (dashboardResult.data!.displayData !=
//                                                 null
//                                             ? double.parse(dashboardResult.data!
//                                                 .displayData!.oee.performance)
//                                             : 0)
//                                         : 0,
//                                     valueTopCoat: dashboardResult.data != null
//                                         ? (dashboardResult
//                                                     .data!.performanceData !=
//                                                 null
//                                             ? double.parse(dashboardResult.data!
//                                                     .performanceData!.topCoat
//                                                     .toString()) /
//                                                 100
//                                             : 0)
//                                         : 0,
//                                     valueSealing: dashboardResult.data != null
//                                         ? (dashboardResult
//                                                     .data!.performanceData !=
//                                                 null
//                                             ? double.parse(dashboardResult.data!
//                                                     .performanceData!.sealing
//                                                     .toString()) /
//                                                 100
//                                             : 0)
//                                         : 0,
//                                     valueLoading: dashboardResult.data != null
//                                         ? (dashboardResult
//                                                     .data!.performanceData !=
//                                                 null
//                                             ? double.parse(dashboardResult.data!
//                                                     .performanceData!.loading
//                                                     .toString()) /
//                                                 100
//                                             : 0)
//                                         : 0,
//                                     detailName: "PERFORMANCE DETAIL",
//                                     nameDataOne: "Top Coat",
//                                     nameDataTwo: "Sealing",
//                                     nameDataThree: "Loading PTED",
//                                   ),
//                                 ),
//                                 Expanded(
//                                   child: cardChart(
//                                     isWindows: isWindows,
//                                     chartData: [
//                                       ChartData(
//                                           'Sudah',
//                                           dashboardResult.data != null
//                                               ? (dashboardResult
//                                                           .data!.displayData !=
//                                                       null
//                                                   ? double.parse(dashboardResult
//                                                       .data!
//                                                       .displayData!
//                                                       .oee
//                                                       .quality)
//                                                   : 0)
//                                               : 0),
//                                       ChartData(
//                                           'Belum',
//                                           100 -
//                                               (dashboardResult.data != null
//                                                   ? (dashboardResult.data!
//                                                               .displayData !=
//                                                           null
//                                                       ? double.parse(
//                                                           dashboardResult
//                                                               .data!
//                                                               .displayData!
//                                                               .oee
//                                                               .quality)
//                                                       : 0)
//                                                   : 0)),
//                                     ],
//                                     colorChart: Colors.amber,
//                                     nameChart: "QUALITY SEALING",
//                                     valueChart: dashboardResult.data != null
//                                         ? (dashboardResult.data!.displayData !=
//                                                 null
//                                             ? double.parse(dashboardResult
//                                                 .data!.displayData!.oee.quality)
//                                             : 0)
//                                         : 0,
//                                     valueTopCoat: dashboardResult.data != null
//                                         ? (dashboardResult.data!.qualityData !=
//                                                 null
//                                             ? double.parse(dashboardResult
//                                                     .data!.qualityData!.topCoat
//                                                     .toString()) /
//                                                 100
//                                             : 0)
//                                         : 0,
//                                     valueSealing: dashboardResult.data != null
//                                         ? (dashboardResult.data!.qualityData !=
//                                                 null
//                                             ? double.parse(dashboardResult
//                                                     .data!.qualityData!.sealing
//                                                     .toString()) /
//                                                 100
//                                             : 0)
//                                         : 0,
//                                     valueLoading: dashboardResult.data != null
//                                         ? (dashboardResult.data!.qualityData !=
//                                                 null
//                                             ? double.parse(dashboardResult
//                                                     .data!.qualityData!.loading
//                                                     .toString()) /
//                                                 100
//                                             : 0)
//                                         : 0,
//                                     detailName: "QUALITY DETAIL",
//                                     nameDataOne: "Top Coat",
//                                     nameDataTwo: "Sealing",
//                                     nameDataThree: "Loading PTED",
//                                   ),
//                                 )
//                               ],
//                             ),
//                           ),
//                           SizedBox(
//                             height: windowWidth < 1400 ? 0 : 10,
//                           ),
//                           Expanded(
//                             child: windowWidth < 1400
//                                 ? SingleChildScrollView(
//                                     child: Container(
//                                       margin: EdgeInsets.symmetric(
//                                           horizontal:
//                                               windowWidth < 1400 ? 10 : 20),
//                                       padding: EdgeInsets.all(
//                                           windowWidth < 1400 ? 10 : 20),
//                                       color: Colors.white,
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             "DOWNTIME LOADING PTED (Minutes)",
//                                             textAlign: TextAlign.start,
//                                             style: GoogleFonts.poppins(
//                                                 color: mDarkBlue,
//                                                 fontSize: windowWidth < 1400
//                                                     ? 15
//                                                     : 20,
//                                                 fontWeight: FontWeight.w600),
//                                           ),
//                                           Container(
//                                             height: 140,
//                                             child: SfCartesianChart(
//                                               series: <CartesianSeries>[
//                                                 BarSeries<ChartData, String>(
//                                                   name: "Downtime Loading PTED",
//                                                   dataSource: chartData,
//                                                   xValueMapper:
//                                                       (ChartData data, _) =>
//                                                           data.x,
//                                                   yValueMapper:
//                                                       (ChartData data, _) =>
//                                                           data.y,
//                                                   borderRadius:
//                                                       BorderRadius.only(
//                                                           topRight:
//                                                               Radius.circular(
//                                                                   30),
//                                                           bottomRight:
//                                                               Radius.circular(
//                                                                   30)),
//                                                   gradient: LinearGradient(
//                                                       begin:
//                                                           Alignment.centerLeft,
//                                                       end:
//                                                           Alignment.centerRight,
//                                                       colors: [
//                                                         mBlueColor
//                                                             .withOpacity(0.2),
//                                                         mBlueColor
//                                                             .withOpacity(1)
//                                                       ],
//                                                       stops: [
//                                                         0.0,
//                                                         1
//                                                       ]),
//                                                 )
//                                               ],
//                                               plotAreaBorderWidth: 0,
//                                               primaryXAxis: CategoryAxis(
//                                                 labelStyle: GoogleFonts.poppins(
//                                                     color: mDarkBlue,
//                                                     fontSize: windowWidth < 1400
//                                                         ? 10
//                                                         : 15,
//                                                     fontWeight:
//                                                         FontWeight.w700),
//                                                 // axisBorderType: AxisBorderType.rectangle,
//                                                 // rangePadding: ChartRangePadding.round,
//                                                 axisLine: AxisLine(
//                                                     width:
//                                                         0), // Hide the axis line
//                                                 majorGridLines:
//                                                     MajorGridLines(width: 0),
//                                                 minorGridLines:
//                                                     MinorGridLines(width: 0),
//                                               ),
//                                               primaryYAxis: NumericAxis(
//                                                 axisLine: AxisLine(
//                                                     width:
//                                                         0), // Hide the axis line
//                                                 // visibleMinimum: 0,
//                                                 // visibleMaximum: 38,
//                                                 majorGridLines:
//                                                     MajorGridLines(width: 0),
//                                                 minorGridLines:
//                                                     MinorGridLines(width: 0),
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   )
//                                 : Row(
//                                     children: [
//                                       Expanded(
//                                         child: Container(
//                                           margin: EdgeInsets.symmetric(
//                                               horizontal:
//                                                   windowWidth < 1400 ? 10 : 20),
//                                           padding: EdgeInsets.all(
//                                               windowWidth < 1400 ? 10 : 20),
//                                           color: Colors.white,
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment
//                                                         .spaceBetween,
//                                                 children: [
//                                                   Text(
//                                                     "DOWNTIME LOADING PTED (Minutes)",
//                                                     textAlign: TextAlign.start,
//                                                     style: GoogleFonts.poppins(
//                                                         color: mDarkBlue,
//                                                         fontSize:
//                                                             windowWidth < 1400
//                                                                 ? 15
//                                                                 : 20,
//                                                         fontWeight:
//                                                             FontWeight.w600),
//                                                   ),
//                                                   Container(
//                                                     padding: EdgeInsets.all(
//                                                         windowWidth < 1400
//                                                             ? 5
//                                                             : 8),
//                                                     decoration: BoxDecoration(
//                                                         color: Colors.red,
//                                                         borderRadius:
//                                                             BorderRadius
//                                                                 .circular(10)),
//                                                     child: Text(
//                                                       "Down Time Report",
//                                                       textAlign:
//                                                           TextAlign.start,
//                                                       style:
//                                                           GoogleFonts.poppins(
//                                                               color:
//                                                                   Colors.white,
//                                                               fontSize:
//                                                                   windowWidth <
//                                                                           1400
//                                                                       ? 10
//                                                                       : 12,
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .w600),
//                                                     ),
//                                                   )
//                                                 ],
//                                               ),
//                                               Expanded(
//                                                 child: Container(
//                                                   child: SfCartesianChart(
//                                                     series: <CartesianSeries>[
//                                                       BarSeries<ChartData,
//                                                           String>(
//                                                         name:
//                                                             "Downtime Loading PTED",
//                                                         dataSource: chartData,
//                                                         xValueMapper:
//                                                             (ChartData data,
//                                                                     _) =>
//                                                                 data.x,
//                                                         yValueMapper:
//                                                             (ChartData data,
//                                                                     _) =>
//                                                                 data.y,
//                                                         borderRadius:
//                                                             BorderRadius.only(
//                                                                 topRight: Radius
//                                                                     .circular(
//                                                                         30),
//                                                                 bottomRight: Radius
//                                                                     .circular(
//                                                                         30)),
//                                                         gradient: LinearGradient(
//                                                             begin: Alignment
//                                                                 .centerLeft,
//                                                             end: Alignment
//                                                                 .centerRight,
//                                                             colors: [
//                                                               mBlueColor
//                                                                   .withOpacity(
//                                                                       0.2),
//                                                               mBlueColor
//                                                                   .withOpacity(
//                                                                       1)
//                                                             ],
//                                                             stops: [
//                                                               0.0,
//                                                               1
//                                                             ]),
//                                                       )
//                                                     ],
//                                                     plotAreaBorderWidth: 0,
//                                                     primaryXAxis: CategoryAxis(
//                                                       labelStyle:
//                                                           GoogleFonts.poppins(
//                                                               color: mDarkBlue,
//                                                               fontSize:
//                                                                   windowWidth <
//                                                                           1400
//                                                                       ? 10
//                                                                       : 15,
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .w700),
//                                                       // axisBorderType: AxisBorderType.rectangle,
//                                                       // rangePadding: ChartRangePadding.round,
//                                                       axisLine: AxisLine(
//                                                           width:
//                                                               0), // Hide the axis line
//                                                       majorGridLines:
//                                                           MajorGridLines(
//                                                               width: 0),
//                                                       minorGridLines:
//                                                           MinorGridLines(
//                                                               width: 0),
//                                                     ),
//                                                     primaryYAxis: NumericAxis(
//                                                       axisLine: AxisLine(
//                                                           width:
//                                                               0), // Hide the axis line
//                                                       // visibleMinimum: 0,
//                                                       // visibleMaximum: 38,
//                                                       majorGridLines:
//                                                           MajorGridLines(
//                                                               width: 0),
//                                                       minorGridLines:
//                                                           MinorGridLines(
//                                                               width: 0),
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                       Container(
//                                         width: windowWidth < 1400 ? 400 : 500,
//                                         margin: EdgeInsets.symmetric(
//                                             horizontal:
//                                                 windowWidth < 1400 ? 10 : 20),
//                                         // color: Colors.white,
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               "LOADED PART",
//                                               textAlign: TextAlign.start,
//                                               style: GoogleFonts.poppins(
//                                                   color: mDarkBlue,
//                                                   fontSize: windowWidth < 1400
//                                                       ? 15
//                                                       : 20,
//                                                   fontWeight: FontWeight.w600),
//                                             ),
//                                             SizedBox(
//                                               height: 10,
//                                             ),
//                                             Expanded(
//                                               child: SingleChildScrollView(
//                                                 child: Column(
//                                                     mainAxisAlignment:
//                                                         MainAxisAlignment.start,
//                                                     children: List.generate(10,
//                                                         (index) {
//                                                       return Container(
//                                                         margin: EdgeInsets.only(
//                                                             bottom: 10),
//                                                         padding: EdgeInsets.all(
//                                                             windowWidth < 1400
//                                                                 ? 5
//                                                                 : 10),
//                                                         decoration: BoxDecoration(
//                                                             color: Colors.white,
//                                                             borderRadius:
//                                                                 BorderRadius
//                                                                     .circular(
//                                                                         10)),
//                                                         child: Row(
//                                                           mainAxisAlignment:
//                                                               MainAxisAlignment
//                                                                   .spaceBetween,
//                                                           children: [
//                                                             Column(
//                                                               crossAxisAlignment:
//                                                                   CrossAxisAlignment
//                                                                       .start,
//                                                               children: [
//                                                                 Text(
//                                                                   "Serial Number",
//                                                                   textAlign:
//                                                                       TextAlign
//                                                                           .start,
//                                                                   style: GoogleFonts.poppins(
//                                                                       color: Colors
//                                                                           .grey,
//                                                                       fontSize: windowWidth <
//                                                                               1400
//                                                                           ? 12
//                                                                           : 14,
//                                                                       fontWeight:
//                                                                           FontWeight
//                                                                               .w600),
//                                                                 ),
//                                                                 Text(
//                                                                   "SKJSUIRJ",
//                                                                   textAlign:
//                                                                       TextAlign
//                                                                           .start,
//                                                                   style: GoogleFonts.poppins(
//                                                                       color:
//                                                                           mDarkBlue,
//                                                                       fontSize: windowWidth <
//                                                                               1400
//                                                                           ? 15
//                                                                           : 18,
//                                                                       fontWeight:
//                                                                           FontWeight
//                                                                               .w700),
//                                                                 ),
//                                                               ],
//                                                             ),
//                                                             Column(
//                                                               crossAxisAlignment:
//                                                                   CrossAxisAlignment
//                                                                       .start,
//                                                               children: [
//                                                                 Text(
//                                                                   "Scanned Time",
//                                                                   textAlign:
//                                                                       TextAlign
//                                                                           .start,
//                                                                   style: GoogleFonts.poppins(
//                                                                       color: Colors
//                                                                           .grey,
//                                                                       fontSize: windowWidth <
//                                                                               1400
//                                                                           ? 11
//                                                                           : 13,
//                                                                       fontWeight:
//                                                                           FontWeight
//                                                                               .w500),
//                                                                 ),
//                                                                 Text(
//                                                                   "20/21/2024 09:21:33",
//                                                                   textAlign:
//                                                                       TextAlign
//                                                                           .start,
//                                                                   style: GoogleFonts.poppins(
//                                                                       color:
//                                                                           mDarkBlue,
//                                                                       fontSize: windowWidth <
//                                                                               1400
//                                                                           ? 13
//                                                                           : 15,
//                                                                       fontWeight:
//                                                                           FontWeight
//                                                                               .w600),
//                                                                 ),
//                                                               ],
//                                                             ),
//                                                             Container(
//                                                               padding: EdgeInsets
//                                                                   .all(windowWidth <
//                                                                           1400
//                                                                       ? 5
//                                                                       : 8),
//                                                               decoration: BoxDecoration(
//                                                                   color: Color
//                                                                       .fromARGB(
//                                                                           255,
//                                                                           79,
//                                                                           184,
//                                                                           31),
//                                                                   borderRadius:
//                                                                       BorderRadius
//                                                                           .circular(
//                                                                               10)),
//                                                               child: Text(
//                                                                 "OK",
//                                                                 textAlign:
//                                                                     TextAlign
//                                                                         .start,
//                                                                 style: GoogleFonts.poppins(
//                                                                     color: Colors
//                                                                         .white,
//                                                                     fontSize:
//                                                                         windowWidth <
//                                                                                 1400
//                                                                             ? 13
//                                                                             : 15,
//                                                                     fontWeight:
//                                                                         FontWeight
//                                                                             .w600),
//                                                               ),
//                                                             )
//                                                           ],
//                                                         ),
//                                                       );
//                                                     })),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       )
//                                     ],
//                                   ),
//                           )
//                         ],
//                       ),
//                     ),
//                   ] else ...[
//                     Expanded(
//                       child: SingleChildScrollView(
//                         physics: BouncingScrollPhysics(),
//                         child: Column(
//                           children: [
//                             cardChart(
//                               isWindows: isWindows,
//                               chartData: [
//                                 ChartData(
//                                     'Sudah',
//                                     dashboardResult.data != null
//                                         ? (dashboardResult.data!.displayData !=
//                                                 null
//                                             ? double.parse(dashboardResult
//                                                 .data!.displayData!.oee.oee)
//                                             : 0)
//                                         : 0),
//                                 ChartData(
//                                     'Belum',
//                                     100 -
//                                         (dashboardResult.data != null
//                                             ? (dashboardResult
//                                                         .data!.displayData !=
//                                                     null
//                                                 ? double.parse(dashboardResult
//                                                     .data!.displayData!.oee.oee)
//                                                 : 0)
//                                             : 0)),
//                               ],
//                               colorChart: mBlueColor,
//                               nameChart: "OEE SEALING",
//                               valueChart: dashboardResult.data != null
//                                   ? (dashboardResult.data!.displayData != null
//                                       ? double.parse(dashboardResult
//                                           .data!.displayData!.oee.oee)
//                                       : 0)
//                                   : 0,
//                               valueTopCoat: dashboardResult.data != null
//                                   ? (dashboardResult.data!.displayData != null
//                                       ? double.parse(dashboardResult.data!
//                                               .displayData!.oee.availability) /
//                                           100
//                                       : 0)
//                                   : 0,
//                               valueSealing: dashboardResult.data != null
//                                   ? (dashboardResult.data!.displayData != null
//                                       ? double.parse(dashboardResult.data!
//                                               .displayData!.oee.performance) /
//                                           100
//                                       : 0)
//                                   : 0,
//                               valueLoading: dashboardResult.data != null
//                                   ? (dashboardResult.data!.displayData != null
//                                       ? double.parse(dashboardResult
//                                               .data!.displayData!.oee.quality) /
//                                           100
//                                       : 0)
//                                   : 0,
//                               detailName: "DETAIL",
//                               nameDataOne: "Availability",
//                               nameDataTwo: "Performance",
//                               nameDataThree: "Quality",
//                             ),
//                             cardChart(
//                               isWindows: isWindows,
//                               chartData: [
//                                 ChartData(
//                                     'Sudah',
//                                     dashboardResult.data != null
//                                         ? (dashboardResult.data!.displayData !=
//                                                 null
//                                             ? double.parse(dashboardResult.data!
//                                                 .displayData!.oee.availability)
//                                             : 0)
//                                         : 0),
//                                 ChartData(
//                                     'Belum',
//                                     100 -
//                                         (dashboardResult.data != null
//                                             ? (dashboardResult
//                                                         .data!.displayData !=
//                                                     null
//                                                 ? double.parse(dashboardResult
//                                                     .data!
//                                                     .displayData!
//                                                     .oee
//                                                     .availability)
//                                                 : 0)
//                                             : 0)),
//                               ],
//                               colorChart: Colors.green,
//                               nameChart: "AVAILABILITY SEALING",
//                               valueChart: dashboardResult.data != null
//                                   ? (dashboardResult.data!.displayData != null
//                                       ? double.parse(dashboardResult
//                                           .data!.displayData!.oee.availability)
//                                       : 0)
//                                   : 0,
//                               valueTopCoat: dashboardResult.data != null
//                                   ? (dashboardResult.data!.availabilityData !=
//                                           null
//                                       ? double.parse(dashboardResult
//                                               .data!.availabilityData!.topCoat
//                                               .toString()) /
//                                           100
//                                       : 0)
//                                   : 0,
//                               valueSealing: dashboardResult.data != null
//                                   ? (dashboardResult.data!.availabilityData !=
//                                           null
//                                       ? double.parse(dashboardResult
//                                               .data!.availabilityData!.sealing
//                                               .toString()) /
//                                           100
//                                       : 0)
//                                   : 0,
//                               valueLoading: dashboardResult.data != null
//                                   ? (dashboardResult.data!.availabilityData !=
//                                           null
//                                       ? double.parse(dashboardResult
//                                               .data!.availabilityData!.loading
//                                               .toString()) /
//                                           100
//                                       : 0)
//                                   : 0,
//                               detailName: "AVAILABILITY DETAIL",
//                               nameDataOne: "Top Coat",
//                               nameDataTwo: "Sealing",
//                               nameDataThree: "Loading PTED",
//                             ),
//                             cardChart(
//                               isWindows: isWindows,
//                               chartData: [
//                                 ChartData(
//                                     'Sudah',
//                                     dashboardResult.data != null
//                                         ? (dashboardResult.data!.displayData !=
//                                                 null
//                                             ? double.parse(dashboardResult.data!
//                                                 .displayData!.oee.performance)
//                                             : 0)
//                                         : 0),
//                                 ChartData(
//                                     'Belum',
//                                     100 -
//                                         (dashboardResult.data != null
//                                             ? (dashboardResult
//                                                         .data!.displayData !=
//                                                     null
//                                                 ? double.parse(dashboardResult
//                                                     .data!
//                                                     .displayData!
//                                                     .oee
//                                                     .performance)
//                                                 : 0)
//                                             : 0)),
//                               ],
//                               colorChart: Colors.orange,
//                               nameChart: "PERFORMANCE SEALING",
//                               valueChart: dashboardResult.data != null
//                                   ? (dashboardResult.data!.displayData != null
//                                       ? double.parse(dashboardResult
//                                           .data!.displayData!.oee.performance)
//                                       : 0)
//                                   : 0,
//                               valueTopCoat: dashboardResult.data != null
//                                   ? (dashboardResult.data!.performanceData !=
//                                           null
//                                       ? double.parse(dashboardResult
//                                               .data!.performanceData!.topCoat
//                                               .toString()) /
//                                           100
//                                       : 0)
//                                   : 0,
//                               valueSealing: dashboardResult.data != null
//                                   ? (dashboardResult.data!.performanceData !=
//                                           null
//                                       ? double.parse(dashboardResult
//                                               .data!.performanceData!.sealing
//                                               .toString()) /
//                                           100
//                                       : 0)
//                                   : 0,
//                               valueLoading: dashboardResult.data != null
//                                   ? (dashboardResult.data!.performanceData !=
//                                           null
//                                       ? double.parse(dashboardResult
//                                               .data!.performanceData!.loading
//                                               .toString()) /
//                                           100
//                                       : 0)
//                                   : 0,
//                               detailName: "PERFORMANCE DETAIL",
//                               nameDataOne: "Top Coat",
//                               nameDataTwo: "Sealing",
//                               nameDataThree: "Loading PTED",
//                             ),
//                             cardChart(
//                               isWindows: isWindows,
//                               chartData: [
//                                 ChartData(
//                                     'Sudah',
//                                     dashboardResult.data != null
//                                         ? (dashboardResult.data!.displayData !=
//                                                 null
//                                             ? double.parse(dashboardResult
//                                                 .data!.displayData!.oee.quality)
//                                             : 0)
//                                         : 0),
//                                 ChartData(
//                                     'Belum',
//                                     100 -
//                                         (dashboardResult.data != null
//                                             ? (dashboardResult
//                                                         .data!.displayData !=
//                                                     null
//                                                 ? double.parse(dashboardResult
//                                                     .data!
//                                                     .displayData!
//                                                     .oee
//                                                     .quality)
//                                                 : 0)
//                                             : 0)),
//                               ],
//                               colorChart: Colors.amber,
//                               nameChart: "QUALITY SEALING",
//                               valueChart: dashboardResult.data != null
//                                   ? (dashboardResult.data!.displayData != null
//                                       ? double.parse(dashboardResult
//                                           .data!.displayData!.oee.quality)
//                                       : 0)
//                                   : 0,
//                               valueTopCoat: dashboardResult.data != null
//                                   ? (dashboardResult.data!.qualityData != null
//                                       ? double.parse(dashboardResult
//                                               .data!.qualityData!.topCoat
//                                               .toString()) /
//                                           100
//                                       : 0)
//                                   : 0,
//                               valueSealing: dashboardResult.data != null
//                                   ? (dashboardResult.data!.qualityData != null
//                                       ? double.parse(dashboardResult
//                                               .data!.qualityData!.sealing
//                                               .toString()) /
//                                           100
//                                       : 0)
//                                   : 0,
//                               valueLoading: dashboardResult.data != null
//                                   ? (dashboardResult.data!.qualityData != null
//                                       ? double.parse(dashboardResult
//                                               .data!.qualityData!.loading
//                                               .toString()) /
//                                           100
//                                       : 0)
//                                   : 0,
//                               detailName: "QUALITY DETAIL",
//                               nameDataOne: "Top Coat",
//                               nameDataTwo: "Sealing",
//                               nameDataThree: "Loading PTED",
//                             )
//                           ],
//                         ),
//                       ),
//                     )
//                   ],
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class cardChart extends StatefulWidget {
//   const cardChart({
//     super.key,
//     required this.chartData,
//     required this.colorChart,
//     required this.nameChart,
//     required this.nameDataOne,
//     required this.nameDataTwo,
//     required this.nameDataThree,
//     required this.detailName,
//     required this.valueChart,
//     required this.valueTopCoat,
//     required this.valueSealing,
//     required this.valueLoading,
//     required this.isWindows,
//   });

//   final List<ChartData> chartData;
//   final Color colorChart;
//   final String nameChart;
//   final String detailName;
//   final double valueChart;
//   final double valueTopCoat;
//   final double valueSealing;
//   final double valueLoading;
//   final bool isWindows;
//   final String nameDataOne;
//   final String nameDataTwo;
//   final String nameDataThree;

//   @override
//   State<cardChart> createState() => _cardChartState();
// }

// class _cardChartState extends State<cardChart> {
//   @override
//   Widget build(BuildContext context) {
//     double windowWidth = MediaQuery.of(context).size.width;
//     return Container(
//       height: widget.isWindows
//           ? windowWidth < 1400
//               ? 350
//               : 550
//           : windowWidth < 411
//               ? 160
//               : 180,
//       margin: EdgeInsets.only(
//           left: widget.isWindows
//               ? windowWidth < 1400
//                   ? 10
//                   : 20
//               : 10,
//           right: widget.isWindows
//               ? windowWidth < 1400
//                   ? 5
//                   : 10
//               : 5,
//           bottom: 15),
//       padding: EdgeInsets.symmetric(
//           vertical: widget.isWindows
//               ? windowWidth < 1400
//                   ? 10
//                   : 30
//               : 10,
//           horizontal: widget.isWindows
//               ? windowWidth < 1400
//                   ? 15
//                   : 35
//               : 15),
//       decoration: BoxDecoration(
//           color: Colors.white, borderRadius: BorderRadius.circular(10)),
//       child: widget.isWindows
//           ? Column(
//               children: [
//                 Container(
//                   height: widget.isWindows
//                       ? windowWidth < 1400
//                           ? 210
//                           : 300
//                       : 300,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         widget.nameChart,
//                         textAlign: TextAlign.start,
//                         style: GoogleFonts.poppins(
//                             color: mDarkBlue,
//                             fontSize: widget.isWindows
//                                 ? windowWidth < 1400
//                                     ? 15
//                                     : 20
//                                 : 20,
//                             fontWeight: FontWeight.w600),
//                       ),
//                       Container(
//                         height: widget.isWindows
//                             ? windowWidth < 1400
//                                 ? 130
//                                 : 200
//                             : 200,
//                         child: SfCircularChart(palette: <Color>[
//                           widget.colorChart,
//                           Color.fromARGB(255, 238, 238, 238)
//                         ], series: <CircularSeries>[
//                           // Initialize line series
//                           PieSeries<ChartData, String>(
//                               // Enables the tooltip for individual series
//                               enableTooltip: true,
//                               dataSource: widget.chartData,
//                               xValueMapper: (ChartData data, _) => data.x,
//                               yValueMapper: (ChartData data, _) => data.y)
//                         ]),
//                       ),
//                       Container(
//                         width: MediaQuery.of(context).size.width - 100,
//                         child: Text(
//                           "${widget.valueChart}%",
//                           textAlign: TextAlign.center,
//                           style: GoogleFonts.poppins(
//                               color: mDarkBlue,
//                               fontSize: widget.isWindows
//                                   ? windowWidth < 1400
//                                       ? 25
//                                       : 35
//                                   : 35,
//                               fontWeight: FontWeight.w700),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: Container(
//                     child: Column(
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               widget.detailName,
//                               textAlign: TextAlign.start,
//                               style: GoogleFonts.poppins(
//                                   color: mDarkBlue,
//                                   fontSize: widget.isWindows
//                                       ? windowWidth < 1400
//                                           ? 15
//                                           : 20
//                                       : 20,
//                                   fontWeight: FontWeight.w600),
//                             ),
//                             // new Container(
//                             //   padding: EdgeInsets.symmetric(
//                             //       horizontal: 3, vertical: 3),
//                             //   decoration: BoxDecoration(
//                             //       color: mDarkBlue.withOpacity(0.1),
//                             //       borderRadius: BorderRadius.circular(5)),
//                             //   child: new Material(
//                             //     color: Colors.transparent,
//                             //     child: InkWell(
//                             //       onTap: () {},
//                             //       child: Icon(
//                             //         Icons.more_horiz_rounded,
//                             //         color: mBlueColor,
//                             //         size: 30,
//                             //       ),
//                             //     ),
//                             //   ),
//                             // ),
//                           ],
//                         ),
//                         SizedBox(
//                           height: widget.isWindows
//                               ? windowWidth < 1400
//                                   ? 5
//                                   : 20
//                               : 20,
//                         ),
//                         Expanded(
//                           child: Container(
//                               padding: EdgeInsets.only(
//                                   bottom: widget.isWindows
//                                       ? windowWidth < 1400
//                                           ? 10
//                                           : 20
//                                       : 20),
//                               child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Text(
//                                         "NAME",
//                                         textAlign: TextAlign.start,
//                                         style: GoogleFonts.dmSans(
//                                             color:
//                                                 Color.fromARGB(255, 99, 99, 99),
//                                             fontSize: widget.isWindows
//                                                 ? windowWidth < 1400
//                                                     ? 12
//                                                     : 17
//                                                 : 17,
//                                             fontWeight: FontWeight.w500),
//                                       ),
//                                       Text(
//                                         widget.nameDataOne,
//                                         textAlign: TextAlign.start,
//                                         style: GoogleFonts.dmSans(
//                                             color: mDarkBlue,
//                                             fontSize: widget.isWindows
//                                                 ? windowWidth < 1400
//                                                     ? 12
//                                                     : 17
//                                                 : 17,
//                                             fontWeight: FontWeight.w800),
//                                       ),
//                                       Text(
//                                         widget.nameDataTwo,
//                                         textAlign: TextAlign.start,
//                                         style: GoogleFonts.dmSans(
//                                             color: mDarkBlue,
//                                             fontSize: widget.isWindows
//                                                 ? windowWidth < 1400
//                                                     ? 12
//                                                     : 17
//                                                 : 17,
//                                             fontWeight: FontWeight.w800),
//                                       ),
//                                       Text(
//                                         widget.nameDataThree,
//                                         textAlign: TextAlign.start,
//                                         style: GoogleFonts.dmSans(
//                                             color: mDarkBlue,
//                                             fontSize: widget.isWindows
//                                                 ? windowWidth < 1400
//                                                     ? 12
//                                                     : 17
//                                                 : 17,
//                                             fontWeight: FontWeight.w800),
//                                       ),
//                                     ],
//                                   ),
//                                   Expanded(
//                                     child: Container(
//                                       margin:
//                                           EdgeInsets.only(left: 5, right: 10),
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           Text(
//                                             "PROGRESS",
//                                             textAlign: TextAlign.start,
//                                             style: GoogleFonts.dmSans(
//                                                 color: Color.fromARGB(
//                                                     255, 99, 99, 99),
//                                                 fontSize: widget.isWindows
//                                                     ? windowWidth < 1400
//                                                         ? 12
//                                                         : 17
//                                                     : 17,
//                                                 fontWeight: FontWeight.w500),
//                                           ),
//                                           Container(
//                                             child: ClipRRect(
//                                               borderRadius: BorderRadius.circular(
//                                                   20), // Same as container's border radius
//                                               child: LinearProgressIndicator(
//                                                 backgroundColor: Colors.grey,
//                                                 valueColor:
//                                                     AlwaysStoppedAnimation<
//                                                         Color>(Colors.blue),
//                                                 minHeight: widget.isWindows
//                                                     ? windowWidth < 1400
//                                                         ? 10
//                                                         : 15
//                                                     : 15,
//                                                 value: widget
//                                                     .valueTopCoat, // Set the progress value (0.0 - 1.0)
//                                               ),
//                                             ),
//                                           ),
//                                           Container(
//                                             child: ClipRRect(
//                                               borderRadius: BorderRadius.circular(
//                                                   20), // Same as container's border radius
//                                               child: LinearProgressIndicator(
//                                                 backgroundColor: Colors.grey,
//                                                 valueColor:
//                                                     AlwaysStoppedAnimation<
//                                                         Color>(Colors.blue),
//                                                 minHeight: widget.isWindows
//                                                     ? windowWidth < 1400
//                                                         ? 10
//                                                         : 15
//                                                     : 15,
//                                                 value: widget
//                                                     .valueSealing, // Set the progress value (0.0 - 1.0)
//                                               ),
//                                             ),
//                                           ),
//                                           Container(
//                                             margin: EdgeInsets.only(bottom: 5),
//                                             child: ClipRRect(
//                                               borderRadius: BorderRadius.circular(
//                                                   20), // Same as container's border radius
//                                               child: LinearProgressIndicator(
//                                                 backgroundColor: Colors.grey,
//                                                 valueColor:
//                                                     AlwaysStoppedAnimation<
//                                                         Color>(Colors.blue),
//                                                 minHeight: widget.isWindows
//                                                     ? windowWidth < 1400
//                                                         ? 10
//                                                         : 15
//                                                     : 15,
//                                                 value: widget
//                                                     .valueLoading, // Set the progress value (0.0 - 1.0)
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                   Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Text(
//                                         "IN NUMBER",
//                                         textAlign: TextAlign.start,
//                                         style: GoogleFonts.dmSans(
//                                             color:
//                                                 Color.fromARGB(255, 99, 99, 99),
//                                             fontSize: widget.isWindows
//                                                 ? windowWidth < 1400
//                                                     ? 12
//                                                     : 17
//                                                 : 17,
//                                             fontWeight: FontWeight.w500),
//                                       ),
//                                       Text(
//                                         "${widget.valueTopCoat * 100}%",
//                                         textAlign: TextAlign.start,
//                                         style: GoogleFonts.dmSans(
//                                             color: mDarkBlue,
//                                             fontSize: widget.isWindows
//                                                 ? windowWidth < 1400
//                                                     ? 12
//                                                     : 17
//                                                 : 17,
//                                             fontWeight: FontWeight.w800),
//                                       ),
//                                       Text(
//                                         "${widget.valueSealing * 100}%",
//                                         textAlign: TextAlign.start,
//                                         style: GoogleFonts.dmSans(
//                                             color: mDarkBlue,
//                                             fontSize: widget.isWindows
//                                                 ? windowWidth < 1400
//                                                     ? 12
//                                                     : 17
//                                                 : 17,
//                                             fontWeight: FontWeight.w800),
//                                       ),
//                                       Text(
//                                         "${widget.valueLoading * 100}%",
//                                         textAlign: TextAlign.start,
//                                         style: GoogleFonts.dmSans(
//                                             color: mDarkBlue,
//                                             fontSize: widget.isWindows
//                                                 ? windowWidth < 1400
//                                                     ? 12
//                                                     : 17
//                                                 : 17,
//                                             fontWeight: FontWeight.w800),
//                                       ),
//                                     ],
//                                   )
//                                 ],
//                               )),
//                         ),
//                       ],
//                     ),
//                   ),
//                 )
//               ],
//             )
//           : Row(
//               children: [
//                 Container(
//                   width: windowWidth < 411 ? 100 : 150,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         widget.nameChart,
//                         textAlign: TextAlign.start,
//                         style: GoogleFonts.poppins(
//                             color: mDarkBlue,
//                             fontSize: 11,
//                             fontWeight: FontWeight.w600),
//                       ),
//                       Container(
//                         height: windowWidth < 411 ? 80 : 100,
//                         child: SfCircularChart(palette: <Color>[
//                           widget.colorChart,
//                           Color.fromARGB(255, 238, 238, 238)
//                         ], series: <CircularSeries>[
//                           // Initialize line series
//                           PieSeries<ChartData, String>(
//                               // Enables the tooltip for individual series
//                               enableTooltip: true,
//                               dataSource: widget.chartData,
//                               xValueMapper: (ChartData data, _) => data.x,
//                               yValueMapper: (ChartData data, _) => data.y)
//                         ]),
//                       ),
//                       Container(
//                         width: 200,
//                         child: Text(
//                           "${widget.valueChart}%",
//                           textAlign: TextAlign.center,
//                           style: GoogleFonts.poppins(
//                               color: mDarkBlue,
//                               fontSize: 18,
//                               fontWeight: FontWeight.w700),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: Container(
//                     child: Column(
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               widget.detailName,
//                               textAlign: TextAlign.start,
//                               style: GoogleFonts.poppins(
//                                   color: mDarkBlue,
//                                   fontSize: windowWidth < 411 ? 13 : 15,
//                                   fontWeight: FontWeight.w600),
//                             ),
//                             // new Container(
//                             //   padding: EdgeInsets.symmetric(
//                             //       horizontal: 3, vertical: 3),
//                             //   decoration: BoxDecoration(
//                             //       color: mDarkBlue.withOpacity(0.1),
//                             //       borderRadius: BorderRadius.circular(5)),
//                             //   child: new Material(
//                             //     color: Colors.transparent,
//                             //     child: InkWell(
//                             //       onTap: () {},
//                             //       child: Icon(
//                             //         Icons.more_horiz_rounded,
//                             //         color: mBlueColor,
//                             //         size: 20,
//                             //       ),
//                             //     ),
//                             //   ),
//                             // ),
//                           ],
//                         ),
//                         SizedBox(
//                           height: 20,
//                         ),
//                         Expanded(
//                           child: Container(
//                               padding: EdgeInsets.only(bottom: 20),
//                               child: Row(
//                                 children: [
//                                   Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Text(
//                                         "NAME",
//                                         textAlign: TextAlign.start,
//                                         style: GoogleFonts.dmSans(
//                                             color:
//                                                 Color.fromARGB(255, 99, 99, 99),
//                                             fontSize:
//                                                 windowWidth < 411 ? 9 : 10,
//                                             fontWeight: FontWeight.w500),
//                                       ),
//                                       Text(
//                                         widget.nameDataOne,
//                                         textAlign: TextAlign.start,
//                                         style: GoogleFonts.dmSans(
//                                             color: mDarkBlue,
//                                             fontSize:
//                                                 windowWidth < 411 ? 11 : 12,
//                                             fontWeight: FontWeight.w800),
//                                       ),
//                                       Text(
//                                         widget.nameDataTwo,
//                                         textAlign: TextAlign.start,
//                                         style: GoogleFonts.dmSans(
//                                             color: mDarkBlue,
//                                             fontSize:
//                                                 windowWidth < 411 ? 11 : 12,
//                                             fontWeight: FontWeight.w800),
//                                       ),
//                                       Text(
//                                         widget.nameDataThree,
//                                         textAlign: TextAlign.start,
//                                         style: GoogleFonts.dmSans(
//                                             color: mDarkBlue,
//                                             fontSize:
//                                                 windowWidth < 411 ? 11 : 12,
//                                             fontWeight: FontWeight.w800),
//                                       ),
//                                     ],
//                                   ),
//                                   Container(
//                                     margin: EdgeInsets.only(left: 5, right: 10),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Text(
//                                           "PROGRESS",
//                                           textAlign: TextAlign.start,
//                                           style: GoogleFonts.dmSans(
//                                               color: Color.fromARGB(
//                                                   255, 99, 99, 99),
//                                               fontSize:
//                                                   windowWidth < 411 ? 9 : 10,
//                                               fontWeight: FontWeight.w500),
//                                         ),
//                                         Container(
//                                           width: 60,
//                                           child: ClipRRect(
//                                             borderRadius: BorderRadius.circular(
//                                                 20), // Same as container's border radius
//                                             child: LinearProgressIndicator(
//                                               backgroundColor: Colors.grey,
//                                               valueColor:
//                                                   AlwaysStoppedAnimation<Color>(
//                                                       Colors.blue),
//                                               minHeight: 10,
//                                               value: widget
//                                                   .valueTopCoat, // Set the progress value (0.0 - 1.0)
//                                             ),
//                                           ),
//                                         ),
//                                         Container(
//                                           width: 60,
//                                           child: ClipRRect(
//                                             borderRadius: BorderRadius.circular(
//                                                 20), // Same as container's border radius
//                                             child: LinearProgressIndicator(
//                                               backgroundColor: Colors.grey,
//                                               valueColor:
//                                                   AlwaysStoppedAnimation<Color>(
//                                                       Colors.blue),
//                                               minHeight: 10,
//                                               value: widget
//                                                   .valueSealing, // Set the progress value (0.0 - 1.0)
//                                             ),
//                                           ),
//                                         ),
//                                         Container(
//                                           width: 60,
//                                           margin: EdgeInsets.only(bottom: 5),
//                                           child: ClipRRect(
//                                             borderRadius: BorderRadius.circular(
//                                                 20), // Same as container's border radius
//                                             child: LinearProgressIndicator(
//                                               backgroundColor: Colors.grey,
//                                               valueColor:
//                                                   AlwaysStoppedAnimation<Color>(
//                                                       Colors.blue),
//                                               minHeight: 10,
//                                               value: widget
//                                                   .valueLoading, // Set the progress value (0.0 - 1.0)
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Text(
//                                         "IN NUMBER",
//                                         textAlign: TextAlign.start,
//                                         style: GoogleFonts.dmSans(
//                                             color:
//                                                 Color.fromARGB(255, 99, 99, 99),
//                                             fontSize:
//                                                 windowWidth < 411 ? 9 : 10,
//                                             fontWeight: FontWeight.w500),
//                                       ),
//                                       Text(
//                                         "${widget.valueTopCoat * 100}%",
//                                         textAlign: TextAlign.start,
//                                         style: GoogleFonts.dmSans(
//                                             color: mDarkBlue,
//                                             fontSize:
//                                                 windowWidth < 411 ? 11 : 12,
//                                             fontWeight: FontWeight.w800),
//                                       ),
//                                       Text(
//                                         "${widget.valueSealing * 100}%",
//                                         textAlign: TextAlign.start,
//                                         style: GoogleFonts.dmSans(
//                                             color: mDarkBlue,
//                                             fontSize:
//                                                 windowWidth < 411 ? 11 : 12,
//                                             fontWeight: FontWeight.w800),
//                                       ),
//                                       Text(
//                                         "${widget.valueLoading * 100}%",
//                                         textAlign: TextAlign.start,
//                                         style: GoogleFonts.dmSans(
//                                             color: mDarkBlue,
//                                             fontSize:
//                                                 windowWidth < 411 ? 11 : 12,
//                                             fontWeight: FontWeight.w800),
//                                       ),
//                                     ],
//                                   )
//                                 ],
//                               )),
//                         ),
//                       ],
//                     ),
//                   ),
//                 )
//               ],
//             ),
//     );
//   }
// }
