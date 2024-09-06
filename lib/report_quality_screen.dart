import 'dart:developer';
import 'dart:io';

import 'package:fancy_snackbar/fancy_snackbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:isuzu_oee_app/url.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:loadmore_listview/loadmore_listview.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'constants/color_constant.dart';
import 'custom/InputText.dart';
import 'custom/searchInput.dart';
import 'download_progress_dialog.dart';
import 'main.dart';
import 'models/chart_model.dart';
import 'models/count_operation.dart';
import 'models/list_operation.dart';

class ReportQualityScreen extends StatefulWidget {
  const ReportQualityScreen({super.key});

  @override
  State<ReportQualityScreen> createState() => _ReportQualityScreenState();
}

class _ReportQualityScreenState extends State<ReportQualityScreen> {
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

  @override
  void initState() {
    super.initState();
    // _getAll(false);
    _getCount(false, null, null);
  }

  var storage = const FlutterSecureStorage();
  // var resultListDevice = ListOperation();
  // void _getAll(bool search) async {
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   try {
  //     token = await storage.read(key: "token") ?? "";

  //     ListOperation.connectToApi(
  //             "${Url().val}api/operations?per_page=13&filter=all&operation=TOPCOAT${search ? "&search=${controllerSearchLoading.text}" : ""}",
  //             token)
  //         .then((value) async {
  //       resultListDevice = value;
  //       Future.delayed(const Duration(seconds: 1), () {
  //         setState(() {
  //           _isLoading = false;
  //         });
  //       });
  //       //print(storage.read(key: "token"));
  //       if (value.status == 200) {
  //         Future.delayed(const Duration(seconds: 3), () {
  //           if (mounted) {
  //             setState(() {
  //               _isLoading = false;
  //             });
  //           }
  //         });

  //         nextUrl = value.data != null ? value.data!.nextPageUrl ?? "" : "";
  //         prevUrl = value.data != null ? value.data!.prevPageUrl ?? "" : "";
  //         setState(() {});
  //       } else {
  //         if (value.message.contains('Unauthenticated')) {
  //           FancySnackbar.showSnackbar(
  //             context,
  //             snackBarType: FancySnackBarType.error,
  //             title: "Information!",
  //             message:
  //                 "Your account is used by someone else, please log in again",
  //             duration: 5,
  //             onCloseEvent: () {},
  //           );
  //           await storage.write(key: "keep", value: "false");
  //           await storage.write(key: "token", value: "");
  //           Navigator.of(context).pushAndRemoveUntil(
  //               MaterialPageRoute(builder: (context) => MyApp()),
  //               (Route<dynamic> route) => false);
  //         }
  //         // FancySnackbar.showSnackbar(
  //         //   context,
  //         //   snackBarType: FancySnackBarType.error,
  //         //   title: "Information!",
  //         //   message: profileResult.message,
  //         //   duration: 5,
  //         //   onCloseEvent: () {},
  //         // );
  //       }
  //       setState(() {});
  //     });
  //   } catch (x) {
  //     Future.delayed(Duration(seconds: 2), () {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //     });
  //   }
  // }

  var countOperation = new CountOperation();
  void _getCount(bool search, String? dateAwal, String? dateAkhir) async {
    setState(() {
      _isLoading = true;
    });
    try {
      token = await storage.read(key: "token") ?? "";

      CountOperation.connectToApi(
              Url().val +
                  "api/operations-report?per_page=99999&operation=TOPCOAT${search ? "&search=${controllerSearchLoading.text}" : ""}${dateAwal != null ? "&start_date=${dateAwal}" : ""}${dateAkhir != null ? "&end_date=${dateAkhir}" : ""}",
              token)
          .then((value) async {
        countOperation = value;
        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            _isLoading = false;
          });
        });
        //print(storage.read(key: "token"));
        if (value.status == 200) {
          Future.delayed(Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          });
          nextUrl = value.operations != null
              ? value.operations!.nextPageUrl ?? ""
              : "";
          prevUrl = value.operations != null
              ? value.operations!.prevPageUrl ?? ""
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

  int startNo = 0;

  bool _isLoadmore = false;
  void _nextPage() async {
    setState(() {
      _isLoading = true;
    });
    try {
      token = await storage.read(key: "token") ?? "";

      CountOperation.connectToApi(nextUrl, token).then((value) async {
        countOperation = value;
        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            _isLoading = false;
          });
        });
        //print(storage.read(key: "token"));
        if (value.status == 200) {
          nextUrl = value.operations != null
              ? value.operations!.nextPageUrl ?? ""
              : "";
          prevUrl = value.operations != null
              ? value.operations!.prevPageUrl ?? ""
              : "";
          Future.delayed(Duration(seconds: 3), () {
            setState(() {
              _isLoading = false;
            });
          });
        } else {
          if (value.message.contains('Unauthenticated')) {
            _isLoadmore = false;
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
          _isLoadmore = false;
          _isLoading = false;
        });
      });
    }
  }

  void _prevPage() async {
    setState(() {
      _isLoading = true;
    });
    // try {
    //   token = await storage.read(key: "token") ?? "";

    //   ListOperation.connectToApi(prevUrl, token).then((value) async {
    //     resultListDevice = value;
    //     Future.delayed(Duration(seconds: 1), () {
    //       setState(() {
    //         _isLoading = false;
    //       });
    //     });
    //     //print(storage.read(key: "token"));
    //     if (value.status == 200) {
    //       Future.delayed(Duration(seconds: 3), () {
    //         setState(() {
    //           _isLoading = false;
    //         });
    //       });

    //       nextUrl = value.data != null ? value.data!.nextPageUrl ?? "" : "";
    //       prevUrl = value.data != null ? value.data!.prevPageUrl ?? "" : "";
    //       setState(() {});
    //     } else {
    //       if (value.message.contains('Unauthenticated')) {
    //         FancySnackbar.showSnackbar(
    //           context,
    //           snackBarType: FancySnackBarType.error,
    //           title: "Information!",
    //           message:
    //               "Your account is used by someone else, please log in again",
    //           duration: 5,
    //           onCloseEvent: () {},
    //         );
    //         await storage.write(key: "keep", value: "false");
    //         await storage.write(key: "token", value: "");
    //         Navigator.of(context).pushAndRemoveUntil(
    //             MaterialPageRoute(builder: (context) => MyApp()),
    //             (Route<dynamic> route) => false);
    //       }
    //       // FancySnackbar.showSnackbar(
    //       //   context,
    //       //   snackBarType: FancySnackBarType.error,
    //       //   title: "Information!",
    //       //   message: profileResult.message,
    //       //   duration: 5,
    //       //   onCloseEvent: () {},
    //       // );
    //     }
    //     setState(() {});
    //   });
    // } catch (x) {
    //   Future.delayed(Duration(seconds: 2), () {
    //     setState(() {
    //       _isLoading = false;
    //     });
    //   });
    // }
  }

  DateTime selectedDate = DateTime.now();
  DateTime selectedDateEnd = DateTime.now();
  DateFormat formatter = DateFormat('yyyy-M-d');

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

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    String formattedDate2 = formatter.format(selectedDate);
    String formattedDateEnd2 = formatter.format(selectedDateEnd);
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      // color: Colors.red,
                      height: 80,
                      width: 80,
                      child: SfCircularChart(palette: <Color>[
                        Color.fromARGB(255, 134, 219, 137),
                        Color.fromARGB(255, 238, 238, 238)
                      ], series: <CircularSeries>[
                        // Initialize line series
                        PieSeries<ChartData, String>(
                            // Enables the tooltip for individual series
                            enableTooltip: true,
                            dataSource: [
                              ChartData(
                                  'Sudah',
                                  countOperation.okCount != null
                                      ? double.parse(
                                          countOperation.okCount.toString())
                                      : 0),
                              ChartData(
                                  'Belum',
                                  countOperation.ngCount != null
                                      ? double.parse(
                                          countOperation.ngCount.toString())
                                      : 0),
                            ],
                            xValueMapper: (ChartData data, _) => data.x,
                            yValueMapper: (ChartData data, _) => data.y)
                      ]),
                    ),
                    const SizedBox(
                      width: 30,
                    ),
                    InkWell(
                      onTap: () async {},
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 5,
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              )
                            ],
                            color: const Color.fromARGB(255, 134, 219, 137),
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 8),
                        child: Center(
                          child: Text(
                            "OK",
                            style: GoogleFonts.poppins(
                                color: const Color.fromARGB(255, 255, 255, 255),
                                fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      // dashboardResult.data != null
                      //     ? (dashboardResult.data!.displayData != null
                      //         ? dashboardResult.data!.displayData!.actualWos
                      //             .toString()
                      //         : "")
                      //     : "",
                      countOperation.okCount != null
                          ? countOperation.okCount.toString()
                          : "-",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          color: mDarkBlue,
                          fontSize: windowWidth < 1400 ? 17 : 22,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    InkWell(
                      onTap: () async {},
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 5,
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              )
                            ],
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 8),
                        child: Center(
                          child: Text(
                            "REPAIR",
                            style: GoogleFonts.poppins(
                                color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      // dashboardResult.data != null
                      //     ? (dashboardResult.data!.displayData != null
                      //         ? dashboardResult.data!.displayData!.actualWos
                      //             .toString()
                      //         : "")
                      //     : "",
                      countOperation.ngCount != null
                          ? countOperation.ngCount.toString()
                          : "-",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          color: mDarkBlue,
                          fontSize: windowWidth < 1400 ? 17 : 22,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      width: 60,
                    ),
                    Text(
                      "Actual",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          color: mDarkBlue.withOpacity(0.5),
                          fontSize: windowWidth < 1400 ? 16 : 18,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      width: 25,
                    ),
                    Text(
                      // dashboardResult.data != null
                      //     ? (dashboardResult.data!.displayData != null
                      //         ? dashboardResult.data!.displayData!.actualWos
                      //             .toString()
                      //         : "")
                      //     : "",
                      countOperation.totalCount != null
                          ? countOperation.totalCount.toString()
                          : "-",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          color: mDarkBlue,
                          fontSize: windowWidth < 1400 ? 17 : 25,
                          fontWeight: FontWeight.w700),
                    )
                  ],
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: 10, right: 10, top: 5),
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
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
                            // Container(
                            //   width: 200,
                            //   padding: const EdgeInsets.only(left: 20, top: 5),
                            //   child: Text(
                            //     "",
                            //     textAlign: TextAlign.start,
                            //     style: GoogleFonts.poppins(
                            //         color: mDarkBlue,
                            //         fontSize: windowWidth < 1400 ? 18 : 23,
                            //         fontWeight: FontWeight.w700),
                            //   ),
                            // ),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.center,
                            //   children: [
                            //     Container(
                            //       width: 20,
                            //       height: 20,
                            //       decoration: BoxDecoration(
                            //           border: Border.all(
                            //               color: const Color.fromARGB(
                            //                   255, 190, 190, 190)),
                            //           color: const Color.fromARGB(
                            //               255, 255, 255, 255),
                            //           borderRadius: BorderRadius.circular(30)),
                            //       child: InkWell(
                            //         onTap: (countOperation.operations != null
                            //                     ? countOperation.operations!
                            //                             .prevPageUrl ??
                            //                         ""
                            //                     : "") !=
                            //                 ""
                            //             ? () => setState(() => _prevPage())
                            //             : null,
                            //         child: Icon(
                            //           Icons.arrow_back_ios_rounded,
                            //           size: 10,
                            //           color: (countOperation.operations != null
                            //                       ? countOperation.operations!
                            //                               .prevPageUrl ??
                            //                           ""
                            //                       : "") !=
                            //                   ""
                            //               ? mTitleBlue
                            //               : Colors.grey,
                            //         ),
                            //       ),
                            //     ),
                            //     Container(
                            //       margin:
                            //           const EdgeInsets.symmetric(horizontal: 7),
                            //       width: 20,
                            //       height: 20,
                            //       decoration: BoxDecoration(
                            //           color: mTitleBlue,
                            //           borderRadius: BorderRadius.circular(30)),
                            //       child: Align(
                            //         alignment: Alignment.center,
                            //         child: Text(
                            //           countOperation.operations != null
                            //               ? countOperation
                            //                   .operations!.currentPage
                            //                   .toString()
                            //               : "",
                            //           textAlign: TextAlign.center,
                            //           style: GoogleFonts.poppins(
                            //               color: Colors.white,
                            //               fontSize: 11,
                            //               fontWeight: FontWeight.w600),
                            //         ),
                            //       ),
                            //     ),
                            //     Container(
                            //       width: 20,
                            //       height: 20,
                            //       decoration: BoxDecoration(
                            //           border: Border.all(
                            //               color: const Color.fromARGB(
                            //                   255, 190, 190, 190)),
                            //           color: const Color.fromARGB(
                            //               255, 255, 255, 255),
                            //           borderRadius: BorderRadius.circular(30)),
                            //       child: InkWell(
                            //         onTap: (countOperation.operations != null
                            //                     ? countOperation.operations!
                            //                             .nextPageUrl ??
                            //                         ""
                            //                     : "") !=
                            //                 ""
                            //             ? () => setState(() => _nextPage())
                            //             : null,
                            //         child: Icon(
                            //           Icons.arrow_forward_ios_rounded,
                            //           size: 10,
                            //           color: (countOperation.operations != null
                            //                       ? countOperation.operations!
                            //                               .nextPageUrl ??
                            //                           ""
                            //                       : "") !=
                            //                   ""
                            //               ? mTitleBlue
                            //               : Colors.grey,
                            //         ),
                            //       ),
                            //     ),
                            //   ],
                            // ),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(bottom: 10, top: 20),
                                  child: Text(
                                    "Start Date",
                                    style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: mTitleBlue,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectDate(context).then((value) {
                                        setState(() {
                                          formattedDate2 =
                                              formatter.format(selectedDate);
                                        });
                                      });
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            color: Color.fromARGB(
                                                249, 241, 241, 241),
                                            width: 1.5),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Row(
                                      children: <Widget>[
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Container(
                                          width: 140,
                                          child: TextField(
                                            // controller:
                                            //     controllerSearchLoading,
                                            enabled: false,
                                            style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600),
                                            decoration: InputDecoration(
                                                hintStyle: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 5),
                                                border: InputBorder.none,
                                                hintText: formattedDate2),
                                            onChanged: (val) {},
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  margin: EdgeInsets.only(bottom: 10, top: 20),
                                  child: Text(
                                    "End Date",
                                    style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: mTitleBlue,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectDateEnd(context).then((value) {
                                        setState(() {
                                          formattedDateEnd2 =
                                              formatter.format(selectedDateEnd);
                                        });
                                      });
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            color: Color.fromARGB(
                                                249, 241, 241, 241),
                                            width: 1.5),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Row(
                                      children: <Widget>[
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Container(
                                          width: 140,
                                          child: TextField(
                                            enabled: false,
                                            style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600),
                                            decoration: InputDecoration(
                                                hintStyle: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 0),
                                                border: InputBorder.none,
                                                hintText: formattedDateEnd2),
                                            onChanged: (val) {},
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                IconButton(
                                    onPressed: () {
                                      _getCount(true, formattedDate2,
                                          formattedDateEnd2);
                                    },
                                    icon: Icon(
                                      Icons.search,
                                      color: mBlueColor,
                                      size: 30,
                                    )),
                              ],
                            ),
                            Container(
                                width: 260,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF4F7FE),
                                  borderRadius: BorderRadius.circular(40),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0xFFF4F7FE),
                                      spreadRadius: 3,
                                      blurRadius: 3,
                                      offset: Offset(0, 2),
                                    )
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SearchInput(
                                      width: 200,
                                      controller: controllerSearchLoading,
                                      nama: "search",
                                      onclick: () {
                                        _getCount(true, formattedDate2,
                                            formattedDateEnd2);
                                      },
                                      icons: Icons.search,
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 10,
                                        ),
                                        InkWell(
                                          onTap: () async {
                                            showDialog(
                                                barrierDismissible: true,
                                                context: context,
                                                builder: (BuildContext
                                                    dialogcontext) {
                                                  String formattedDate =
                                                      formatter
                                                          .format(selectedDate);
                                                  String formattedDateEnd =
                                                      formatter.format(
                                                          selectedDateEnd);
                                                  return StatefulBuilder(
                                                    builder: (BuildContext
                                                                dialogcontext,
                                                            setState) =>
                                                        AlertDialog(
                                                      content: Container(
                                                        height: 340,
                                                        width: MediaQuery.of(
                                                                    context)
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
                                                                    TextAlign
                                                                        .start,
                                                                style: GoogleFonts.poppins(
                                                                    color:
                                                                        mDarkBlue,
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
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      bottom:
                                                                          10,
                                                                      top: 20),
                                                              child: Text(
                                                                "Start Date",
                                                                style: GoogleFonts.poppins(
                                                                    fontSize:
                                                                        14,
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
                                                                      .then(
                                                                          (value) {
                                                                    setState(
                                                                        () {
                                                                      formattedDate =
                                                                          formatter
                                                                              .format(selectedDate);
                                                                    });
                                                                  });
                                                                });
                                                              },
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    border: Border.all(
                                                                        color: Color.fromARGB(
                                                                            249,
                                                                            241,
                                                                            241,
                                                                            241),
                                                                        width:
                                                                            1.5),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
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
                                                                                FontWeight.w600),
                                                                        decoration: InputDecoration(
                                                                            hintStyle: GoogleFonts.poppins(
                                                                              fontSize: 14,
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
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      bottom:
                                                                          10,
                                                                      top: 20),
                                                              child: Text(
                                                                "End Date",
                                                                style: GoogleFonts.poppins(
                                                                    fontSize:
                                                                        14,
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
                                                                      .then(
                                                                          (value) {
                                                                    setState(
                                                                        () {
                                                                      formattedDateEnd =
                                                                          formatter
                                                                              .format(selectedDateEnd);
                                                                    });
                                                                  });
                                                                });
                                                              },
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    border: Border.all(
                                                                        color: Color.fromARGB(
                                                                            249,
                                                                            241,
                                                                            241,
                                                                            241),
                                                                        width:
                                                                            1.5),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
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
                                                                                FontWeight.w600),
                                                                        decoration: InputDecoration(
                                                                            hintStyle: GoogleFonts.poppins(
                                                                              fontSize: 14,
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
                                                                            0),
                                                                    () {
                                                                  setState(() {
                                                                    _isLoading =
                                                                        true;
                                                                  });
                                                                });
                                                                token = await storage
                                                                        .read(
                                                                            key:
                                                                                "token") ??
                                                                    "";

                                                                try {
                                                                  if (await Permission
                                                                      .manageExternalStorage
                                                                      .request()
                                                                      .isGranted) {
                                                                  } else {
                                                                    // ignore: use_build_context_synchronously
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
                                                                      duration:
                                                                          2,
                                                                      onCloseEvent:
                                                                          () {
                                                                        Navigator.pop(
                                                                            dialogcontext);
                                                                        // Navigator.pushReplacement(context,
                                                                        //     MaterialPageRoute(builder: (context) {
                                                                        //   return NavigateScreen(
                                                                        //     id: 1,
                                                                        //   );
                                                                        // }));
                                                                      },
                                                                    );
                                                                    return;
                                                                  }
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
                                                                          DateFormat('yyyy-MM-dd h mm ss a')
                                                                              .format(datetime);
                                                                      showDialog(
                                                                          barrierDismissible:
                                                                              false,
                                                                          context:
                                                                              context,
                                                                          builder:
                                                                              (dialogcontext) {
                                                                            return DownloadProgressDialog(
                                                                              path: "$folderPath/Export History ${formattedDateTime}.xlsx",
                                                                              token: token,
                                                                              baseUrl: Url().val + "api/operation-export?date_start=${formattedDate}&date_end=${formattedDateEnd}&operation=TOPCOAT",
                                                                            );
                                                                          }).then((value) {
                                                                        setState(
                                                                            () {
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
                                                                      duration:
                                                                          2,
                                                                      onCloseEvent:
                                                                          () {
                                                                        Navigator.pop(
                                                                            dialogcontext);
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
                                                                    setState(
                                                                        () {
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
                                                                            .withOpacity(0.2),
                                                                        spreadRadius:
                                                                            5,
                                                                        blurRadius:
                                                                            5,
                                                                        offset: Offset(
                                                                            0,
                                                                            2),
                                                                      )
                                                                    ],
                                                                    color: _isLoading
                                                                        ? const Color.fromARGB(
                                                                            255,
                                                                            179,
                                                                            179,
                                                                            179)
                                                                        : mBlueColor,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10)),
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        vertical:
                                                                            12,
                                                                        horizontal:
                                                                            15),
                                                                child: Center(
                                                                  child: Text(
                                                                    "Export",
                                                                    style: GoogleFonts.poppins(
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
                        SizedBox(
                          height: windowWidth < 1400 ? 10 : 20,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(left: 4, right: 4),
                                padding: windowWidth < 1400
                                    ? EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 10)
                                    : EdgeInsets.symmetric(
                                        vertical: 20, horizontal: 20),
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
                                    color: Color.fromARGB(255, 245, 245, 245),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          color: mDarkBlue.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                      child: Icon(
                                        Icons.file_copy,
                                        color: mBlueColor,
                                        size: 15,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "VT/P",
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                              color: mDarkBlue.withOpacity(0.5),
                                              fontSize: 9,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          countOperation.summaries?.vtP
                                                  .toString() ??
                                              "0",
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                              color: mDarkBlue,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(left: 4, right: 4),
                                padding: windowWidth < 1400
                                    ? EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 10)
                                    : EdgeInsets.symmetric(
                                        vertical: 20, horizontal: 20),
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
                                    color: Color.fromARGB(255, 245, 245, 245),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          color: mDarkBlue.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                      child: Icon(
                                        Icons.file_copy,
                                        color: mBlueColor,
                                        size: 15,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "700P/FS",
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                              color: mDarkBlue.withOpacity(0.5),
                                              fontSize: 9,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          countOperation.summaries?.fs700P
                                                  .toString() ??
                                              "0",
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                              color: mDarkBlue,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(left: 4, right: 4),
                                padding: windowWidth < 1400
                                    ? EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 10)
                                    : EdgeInsets.symmetric(
                                        vertical: 20, horizontal: 20),
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
                                    color: Color.fromARGB(255, 245, 245, 245),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          color: mDarkBlue.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                      child: Icon(
                                        Icons.file_copy,
                                        color: mBlueColor,
                                        size: 15,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "700P/NS",
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                              color: mDarkBlue.withOpacity(0.5),
                                              fontSize: 9,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          countOperation.summaries?.ns700P
                                                  .toString() ??
                                              "0",
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                              color: mDarkBlue,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(left: 4, right: 4),
                                padding: windowWidth < 1400
                                    ? EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 10)
                                    : EdgeInsets.symmetric(
                                        vertical: 20, horizontal: 20),
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
                                    color: Color.fromARGB(255, 245, 245, 245),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          color: mDarkBlue.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                      child: Icon(
                                        Icons.file_copy,
                                        color: mBlueColor,
                                        size: 15,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Rear Body",
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                              color: mDarkBlue.withOpacity(0.5),
                                              fontSize: 9,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          countOperation.summaries?.rearBody
                                                  .toString() ??
                                              "0",
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                              color: mDarkBlue,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(left: 4, right: 4),
                                padding: windowWidth < 1400
                                    ? EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 10)
                                    : EdgeInsets.symmetric(
                                        vertical: 20, horizontal: 20),
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
                                    color: Color.fromARGB(255, 245, 245, 245),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          color: mDarkBlue.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                      child: Icon(
                                        Icons.file_copy,
                                        color: mBlueColor,
                                        size: 15,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Spareparts",
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                              color: mDarkBlue.withOpacity(0.5),
                                              fontSize: 9,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          countOperation.summaries?.spareparts
                                                  .toString() ??
                                              "0",
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                              color: mDarkBlue,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600),
                                        )
                                      ],
                                    )
                                  ],
                                ),
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
                                      fontSize: 12,
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
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              Container(
                                width: windowWidth / 7,
                                child: Text(
                                  "No.  Body",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              Container(
                                width: windowWidth / 8,
                                child: Text(
                                  "Variant",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              Container(
                                width: windowWidth / 8,
                                child: Text(
                                  "Time",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              Container(
                                width: windowWidth / 8,
                                child: Text(
                                  "Status Quality Update",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(
                                horizontal: windowWidth < 1400 ? 10 : 20),
                            child: LoadMoreListView.builder(
                              shrinkWrap: true,
                              itemCount:
                                  countOperation.operations?.data.length ?? 0,
                              hasMoreItem:
                                  countOperation.operations?.nextPageUrl !=
                                      null,
                              // onLoadMore: () async {
                              //   if (_isLoadmore) return;
                              //   _isLoadmore = true;

                              //   _isLoadmore = false;
                              // },
                              onRefresh: () async {
                                _getCount(false, null, null);
                              },
                              loadMoreWidget: Container(
                                margin: const EdgeInsets.all(20.0),
                                alignment: Alignment.center,
                                child: const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(
                                      Color.fromARGB(255, 95, 170, 60)),
                                ),
                              ),
                              itemBuilder: (context, index) {
                                final item =
                                    countOperation.operations?.data[index];
                                return Container(
                                  width: windowWidth,
                                  margin: EdgeInsets.only(bottom: 0),
                                  padding: EdgeInsets.all(
                                      windowWidth < 1400 ? 3 : 5),
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 255, 255, 255),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: windowWidth / 13,
                                        child: Text(
                                          ((((countOperation.operations
                                                                  ?.currentPage ??
                                                              0) -
                                                          1) *
                                                      13) +
                                                  (index + 1))
                                              .toString(),
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize:
                                                windowWidth < 1400 ? 12 : 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: windowWidth / 7,
                                        child: Text(
                                          item?.date ?? "",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize:
                                                windowWidth < 1400 ? 12 : 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: windowWidth / 7,
                                        child: Text(
                                          item?.bodyId ?? "",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize:
                                                windowWidth < 1400 ? 12 : 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: windowWidth / 8,
                                        child: Text(
                                          item?.bodyType ?? "",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize:
                                                windowWidth < 1400 ? 12 : 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: windowWidth / 8,
                                        child: Text(
                                          item?.timeIn ?? "",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize:
                                                windowWidth < 1400 ? 12 : 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: windowWidth / 8,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            _buildStatusContainer(windowWidth,
                                                "OK", item?.status == "ok"),
                                            SizedBox(width: 10),
                                            _buildStatusContainer(
                                                windowWidth,
                                                "REPAIR",
                                                item?.status == "repair"),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }

  Widget _buildStatusContainer(double width, String text, bool isActive) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: width < 1400 ? 5 : 8,
        horizontal: width < 1400 ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? (text == "OK" ? Color.fromARGB(255, 129, 218, 88) : Colors.red)
            : const Color.fromARGB(255, 202, 202, 202),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        text,
        textAlign: TextAlign.start,
        style: TextStyle(
          color:
              isActive ? Colors.white : const Color.fromARGB(255, 61, 61, 61),
          fontSize: width < 1400 ? 13 : 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
