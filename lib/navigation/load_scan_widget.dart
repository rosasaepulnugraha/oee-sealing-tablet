import 'package:fancy_snackbar/fancy_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../constants/color_constant.dart';
import '../custom/searchInput.dart';
import '../main.dart';
import '../models/list_operation.dart';
import '../models/post_barcode_model.dart';
import '../models/post_seal_model.dart';
import '../models/repair_barcode_model.dart';
import '../url.dart';

class LoadScanWidget extends StatefulWidget {
  const LoadScanWidget({super.key});

  @override
  State<LoadScanWidget> createState() => _LoadScanWidgetState();
}

class _LoadScanWidgetState extends State<LoadScanWidget> {
  @override
  void initState() {
    super.initState();
    _getLoadingSeal(false, null);
  }

  TextEditingController controllerSearchLoadingSeal =
      new TextEditingController();

  var resultListLoadingSeal = new ListOperation();
  void _getLoadingSeal(bool search, String? body_type) async {
    setState(() {
      _isLoading = true;
    });
    try {
      token = await storage.read(key: "token") ?? "";

      ListOperation.connectToApi(
              "${Url().val}api/operations?per_page=4&filter=today&operation=LOADING${search ? "&search=${controllerSearchLoadingSeal.text}" : ""}${body_type != null ? (body_type == "All" ? "" : "&body_type=$body_type") : ""}",
              token)
          .then((value) async {
        resultListLoadingSeal = value;
        // Future.delayed(Duration(seconds: 1), () {
        //   setState(() {
        //     _isLoading = false;
        //   });
        // });
        //print(storage.read(key: "token"));
        if (value.status == 200) {
          Future.delayed(Duration(seconds: 3), () {
            setState(() {
              _isLoading = false;
            });
          });

          nextUrlSeal = value.data != null ? value.data!.nextPageUrl ?? "" : "";
          prevUrlSeal = value.data != null ? value.data!.prevPageUrl ?? "" : "";
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
            return;
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

  String nextUrlSeal = "";
  String prevUrlSeal = "";
  var storage = new FlutterSecureStorage();
  int startNoSeal = 0;
  String token = "";
  bool _isLoading = false;
  void _nextPageSeal() async {
    setState(() {
      _isLoading = true;
    });
    try {
      token = await storage.read(key: "token") ?? "";

      ListOperation.connectToApi(nextUrlSeal, token).then((value) async {
        resultListLoadingSeal = value;
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

          nextUrlSeal = value.data != null ? value.data!.nextPageUrl ?? "" : "";
          prevUrlSeal = value.data != null ? value.data!.prevPageUrl ?? "" : "";
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
            return;
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

  void _prevPageSeal() async {
    setState(() {
      _isLoading = true;
    });
    try {
      token = await storage.read(key: "token") ?? "";

      ListOperation.connectToApi(prevUrlSeal, token).then((value) async {
        resultListLoadingSeal = value;
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

          nextUrlSeal = value.data != null ? value.data!.nextPageUrl ?? "" : "";
          prevUrlSeal = value.data != null ? value.data!.prevPageUrl ?? "" : "";
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
            return;
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
    return _isLoading
        ? Center(
            child: Lottie.asset('assets/json/loadingBlue.json',
                height: 100, width: 100))
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 500,
                child: Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 0, top: 0),
                        child: Text(
                          "PART",
                          textAlign: TextAlign.start,
                          style: GoogleFonts.poppins(
                              color: mDarkBlue,
                              fontSize: 12,
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
                              onTap: (resultListLoadingSeal.data != null
                                          ? resultListLoadingSeal
                                                  .data!.prevPageUrl ??
                                              ""
                                          : "") !=
                                      ""
                                  ? () => setState(() => _prevPageSeal())
                                  : null,
                              child: Icon(
                                Icons.arrow_back_ios_rounded,
                                size: 10,
                                color: (resultListLoadingSeal.data != null
                                            ? resultListLoadingSeal
                                                    .data!.prevPageUrl ??
                                                ""
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
                                "${resultListLoadingSeal.data != null ? resultListLoadingSeal.data!.currentPage.toString() : ""}",
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
                              onTap: (resultListLoadingSeal.data != null
                                          ? resultListLoadingSeal
                                                  .data!.nextPageUrl ??
                                              ""
                                          : "") !=
                                      ""
                                  ? () => setState(() => _nextPageSeal())
                                  : null,
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 10,
                                color: (resultListLoadingSeal.data != null
                                            ? resultListLoadingSeal
                                                    .data!.nextPageUrl ??
                                                ""
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
                          width: 209,
                          padding: EdgeInsets.symmetric(
                              // horizontal: 5,
                              ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F7FE),
                            borderRadius: BorderRadius.circular(40),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromARGB(134, 244, 247, 254),
                                spreadRadius: 1,
                                blurRadius: 1,
                                offset: Offset(0, 1),
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SearchInput(
                                width: 209,
                                controller: controllerSearchLoadingSeal,
                                nama: "search",
                                onclick: () {
                                  _getLoadingSeal(true, null);
                                },
                                icons: Icons.search,
                              ),
                            ],
                          )),
                    ],
                  ),
                ),
              ),
              Container(
                width: 500,
                margin: EdgeInsets.symmetric(horizontal: 10),
                // color: Colors.white,
                padding: EdgeInsets.all(3),
                decoration: BoxDecoration(
                    color: Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 20,
                      child: Text(
                        "No",
                        textAlign: TextAlign.start,
                        style: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontSize: 13,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Container(
                      width: 100,
                      child: Text(
                        "Date",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontSize: 13,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Container(
                      width: 150,
                      child: Text(
                        "No.  Body",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontSize: 13,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Container(
                      width: 100,
                      child: Text(
                        "Variant",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontSize: 13,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Container(
                      width: 100,
                      child: Text(
                        "Aksi",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontSize: 13,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 2,
              ),
              Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(
                      resultListLoadingSeal.data != null
                          ? (resultListLoadingSeal.data!.data != null
                              ? resultListLoadingSeal.data!.data!.length
                              : 0)
                          : 0, (index) {
                    final item = resultListLoadingSeal.data!.data![index];
                    return Container(
                      width: 500,
                      margin: EdgeInsets.only(bottom: 5),
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                          color: Color.fromARGB(255, 255, 255, 255),
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: 30,
                            child: Text(
                              (((resultListLoadingSeal.data!.currentPage! - 1) *
                                          5) +
                                      (index + 1))
                                  .toString(),
                              textAlign: TextAlign.start,
                              style: GoogleFonts.poppins(
                                  color: mDarkBlue,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          Container(
                            width: 100,
                            child: Text(
                              item.date,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                  color: mDarkBlue,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          Container(
                            width: 150,
                            child: Text(
                              item.bodyId,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                  color: mDarkBlue,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          Container(
                            width: 100,
                            child: Text(
                              item.bodyType,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                  color: mDarkBlue,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          // Container(
                          //   width: windowWidth / 8,
                          //   child: Text(
                          //     item.operationTime,
                          //     textAlign: TextAlign.center,
                          //     style: GoogleFonts.poppins(
                          //         color: mDarkBlue,
                          //         fontSize: 9,
                          //         fontWeight: FontWeight.w600),
                          //   ),
                          // ),
                          Container(
                            width: 100,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    if (_isLoading) {
                                      return;
                                    }
                                    try {
                                      token =
                                          await storage.read(key: "token") ??
                                              "";

                                      Future.delayed(
                                          const Duration(milliseconds: 0), () {
                                        setState(() {
                                          _isLoading = true;
                                        });
                                      });
                                      PostSeal.connectToApi(
                                              token, item.bodyId, item.bodyType)
                                          .then((value) {
                                        setState(() {
                                          Future.delayed(
                                              const Duration(
                                                  milliseconds: 2000), () {
                                            setState(() {
                                              _isLoading = false;
                                            });
                                          });
                                          //print(storage.read(key: "token"));
                                          if (value.status == 200 &&
                                              value.type == "complete") {
                                            FancySnackbar.showSnackbar(
                                              context,
                                              snackBarType:
                                                  FancySnackBarType.success,
                                              title: "Successfully!",
                                              message: value.message,
                                              duration: 1,
                                              onCloseEvent: () {},
                                            );

                                            DateTime dt = new DateTime.now();
                                            String formattedDate = DateFormat(
                                                    'dd MMMM yyyy', 'id_ID')
                                                .format(dt);
                                            String formattedTime =
                                                DateFormat('HH:mm:ss', 'id_ID')
                                                    .format(dt);
                                            // latestDateScan =
                                            //     formattedDate;
                                            // latestTimeScan =
                                            //     formattedTime;
                                            // latestBodyScan =
                                            //     controllerCari
                                            //         .text;
                                            controllerSearchLoadingSeal.text =
                                                "";

                                            setState(() {});
                                            _getLoadingSeal(false, null);
                                            setState(() {});
                                          } else if (value.status == 200 &&
                                              value.type == "confirm") {
                                            showDialog(
                                                barrierDismissible: true,
                                                context: context,
                                                builder: (dialogcontext) {
                                                  return AlertDialog(
                                                      content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      // Lottie.asset(
                                                      //     'assets/json/loadingBlue.json',
                                                      //     height: 100,
                                                      //     width: 100),
                                                      SizedBox(
                                                        height: 20,
                                                      ),
                                                      Text(
                                                        value.message,
                                                        style:
                                                            GoogleFonts.inter(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                fontSize: 17,
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        75,
                                                                        75,
                                                                        75)),
                                                      ),
                                                      SizedBox(
                                                        height: 50,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: InkWell(
                                                              onTap: () async {
                                                                Navigator.pop(
                                                                    dialogcontext);
                                                              },
                                                              child: Container(
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
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            107,
                                                                            107,
                                                                            107),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10)),
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(8),
                                                                child: Center(
                                                                  child: Text(
                                                                    "Cancel",
                                                                    style: GoogleFonts.poppins(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            16),
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
                                                                Navigator.pop(
                                                                    context);
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
                                                                RepairBarcode.connectToApi(
                                                                        token,
                                                                        item
                                                                            .bodyId)
                                                                    .then(
                                                                        (valuea) {
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
                                                                  //print(storage.read(key: "token"));
                                                                  if (valuea
                                                                          .status ==
                                                                      200) {
                                                                    FancySnackbar
                                                                        .showSnackbar(
                                                                      context,
                                                                      snackBarType:
                                                                          FancySnackBarType
                                                                              .success,
                                                                      title:
                                                                          "Successfully!",
                                                                      message:
                                                                          valuea
                                                                              .message,
                                                                      duration:
                                                                          1,
                                                                      onCloseEvent:
                                                                          () {},
                                                                    );

                                                                    DateTime
                                                                        dt =
                                                                        new DateTime
                                                                            .now();
                                                                    String formattedDate = DateFormat(
                                                                            'dd MMMM yyyy',
                                                                            'id_ID')
                                                                        .format(
                                                                            dt);
                                                                    String formattedTime = DateFormat(
                                                                            'HH:mm:ss',
                                                                            'id_ID')
                                                                        .format(
                                                                            dt);
                                                                    // latestDateScan = formattedDate;
                                                                    // latestStatus = 2;
                                                                    // latestTimeScan = formattedTime;
                                                                    // latestBodyScan = controllerCari.text;
                                                                    controllerSearchLoadingSeal
                                                                        .text = "";

                                                                    setState(
                                                                        () {});
                                                                    _getLoadingSeal(
                                                                        false,
                                                                        null);
                                                                    setState(
                                                                        () {});
                                                                  } else {
                                                                    FancySnackbar
                                                                        .showSnackbar(
                                                                      context,
                                                                      snackBarType:
                                                                          FancySnackBarType
                                                                              .error,
                                                                      title:
                                                                          "Failed!",
                                                                      message:
                                                                          valuea
                                                                              .message,
                                                                      duration:
                                                                          5,
                                                                      onCloseEvent:
                                                                          () {},
                                                                    );
                                                                    controllerSearchLoadingSeal
                                                                        .text = "";
                                                                    setState(
                                                                        () {});
                                                                  }
                                                                });
                                                              },
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                        color: mTitleBlue
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
                                                                    color:
                                                                        mTitleBlue,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10)),
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(8),
                                                                child: Center(
                                                                  child: Text(
                                                                    "Submit",
                                                                    style: GoogleFonts.poppins(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            16),
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
                                          } else {
                                            FancySnackbar.showSnackbar(
                                              context,
                                              snackBarType:
                                                  FancySnackBarType.error,
                                              title: "Failed!",
                                              message: value.message,
                                              duration: 5,
                                              onCloseEvent: () {},
                                            );
                                            controllerSearchLoadingSeal.text =
                                                "";
                                            setState(() {});
                                          }
                                        });
                                      });
                                    } catch (x) {
                                      FancySnackbar.showSnackbar(
                                        context,
                                        snackBarType: FancySnackBarType.error,
                                        title: "Failed!",
                                        message: x.toString(),
                                        duration: 5,
                                        onCloseEvent: () {},
                                      );
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 2, horizontal: 8),
                                    decoration: BoxDecoration(
                                        color: !_isLoading
                                            ? Color.fromARGB(255, 129, 218, 88)
                                            : const Color.fromARGB(
                                                255, 202, 202, 202),
                                        borderRadius: BorderRadius.circular(4)),
                                    child: Text(
                                      "SUBMIT",
                                      textAlign: TextAlign.start,
                                      style: GoogleFonts.poppins(
                                          color: const Color.fromARGB(
                                              255, 44, 44, 44),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  })),
            ],
          );
  }
}
