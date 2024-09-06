import 'dart:async';
import 'dart:developer';
import 'dart:ffi';
import 'dart:io';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:fancy_snackbar/fancy_snackbar.dart';
import 'package:isuzu_oee_app/models/list_reason.dart' as reason;
import 'models/edit_loading_data.dart';
import 'models/edit_wos_model.dart';
import 'models/list_operation_time.dart';
import 'models/list_shift.dart' as shift;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:isuzu_oee_app/models/data_model.dart';
import 'package:isuzu_oee_app/models/list_downtime_dashboard.dart';
import 'package:isuzu_oee_app/models/list_reason.dart' as reason;
import 'package:isuzu_oee_app/models/post_okng_model.dart';
import 'package:isuzu_oee_app/url.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'constants/color_constant.dart';
import 'custom/InputText.dart';
import 'custom/searchInput.dart';
import 'main.dart';
import 'models/chart_model.dart';
import 'models/dashboard_model.dart';
import 'models/list_downtime.dart';
import 'models/list_operation.dart';
import 'models/list_shift.dart';
import 'models/list_storage.dart';
import 'models/post_barcode_model.dart';
import 'models/post_downtime.dart';
import 'models/post_end_production.dart';
import 'models/post_seal_model.dart';
import 'models/post_wos_model.dart';
import 'models/repair_barcode_model.dart';
import 'navigation/load_scan_widget.dart';
import 'navigation/time_cubit.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

int _rowsPerPage = 10;

class _DashboardScreenState extends State<DashboardScreen> {
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

  void _nextPageStorage() async {
    setState(() {
      _isLoading = true;
    });
    try {
      token = await storage.read(key: "token") ?? "";

      ListStorage.connectToApi(nextUrlStorage, token).then((value) async {
        resultListLoadingStorage = value;
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

          nextUrlStorage =
              value.data != null ? value.data!.nextPageUrl ?? "" : "";
          prevUrlStorage =
              value.data != null ? value.data!.prevPageUrl ?? "" : "";
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

  bool isStorage = false;

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

  void _prevPageStorage() async {
    setState(() {
      _isLoading = true;
    });
    try {
      token = await storage.read(key: "token") ?? "";

      ListStorage.connectToApi(prevUrlStorage, token).then((value) async {
        resultListLoadingStorage = value;
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

          nextUrlStorage =
              value.data != null ? value.data!.nextPageUrl ?? "" : "";
          prevUrlStorage =
              value.data != null ? value.data!.prevPageUrl ?? "" : "";
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
              "${Url().val}api/operations?per_page=200&is_processed=0&filter=today&operation=SEALING${search ? "&search=${controllerSearchLoadingSeal.text}" : ""}${body_type != null ? (body_type == "All" ? "" : "&body_type=$body_type") : ""}",
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
  var resultListLoadingStorage = new ListStorage();
  void _getLoadingStorage(bool search, String? body_type) async {
    setState(() {
      _isLoading = true;
    });
    try {
      token = await storage.read(key: "token") ?? "";

      ListStorage.connectToApi(
              "${Url().val}api/wip-storage?per_page=200&is_processed=0&operation=SEALING${search ? "&search=${controllerSearchLoadingSeal.text}" : ""}",
              token)
          .then((value) async {
        resultListLoadingStorage = value;
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

          nextUrlStorage =
              value.data != null ? value.data!.nextPageUrl ?? "" : "";
          prevUrlStorage =
              value.data != null ? value.data!.prevPageUrl ?? "" : "";
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

  String nextUrlStorage = "";
  String prevUrlStorage = "";
  double windowWidth = 0;

  int latestStatus = 0;

  int report = 1;
  String formattedDate = "";

  var storage = new FlutterSecureStorage();
  String token = "";
  var dashboardResult = new Dashboard();
  TextEditingController controllerCari = new TextEditingController();

  int _currentPage = 1;
  int _itemsPerPage = 6; // Ubah sesuai kebutuhan
  List<String> _data = List.generate(100, (index) => 'Item ${index + 1}');

  List<String> get _currentItems {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    return _data.sublist(
        startIndex, endIndex < _data.length ? endIndex : _data.length);
  }

  Timer? _timer;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getShift();
    _getOperationTime();
    _getItem();
    _getLoadingSeal(false, null);
    // _timer = new Timer.periodic(Duration(seconds: 1), (Timer timer) {
    //   setState(() {
    //     DateTime now = DateTime.now();
    //     formattedDate = DateFormat('d MMMM yyyy', 'id_ID').format(now);
    //   });
    // });
  }

  @override
  void dispose() {
    try {
      _timer!.cancel();
    } catch (x) {}
    super.dispose();
  }

  TextEditingController controllerSearchLoading = new TextEditingController();
  TextEditingController downtimeController = new TextEditingController();

  var resultReason = new reason.ListReason();
  void _getAll() async {
    setState(() {
      _isLoading = true;
    });
    try {
      token = await storage.read(key: "token") ?? "";

      reason.ListReason.connectToApi(Url().val + "api/down-time-reasons", token)
          .then((value) async {
        resultReason = value;
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
          idReason = resultReason.data != null
              ? resultReason.data![0].id.toString()
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
      }).then((value) {
        _getLoading(false, null);
      });
    } catch (x) {
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });
      });
    }
  }

  bool _isLoading = false;
  void _getItem() async {
    setState(() {
      _isLoading = true;
    });
    try {
      token = await storage.read(key: "token") ?? "";

      // EasyLoading.show(status: 'loading...');
      //print("Nama =" + emailController.text);
      Dashboard.connectToApi(token, "TOPCOAT").then((value) async {
        dashboardResult = value;
        // Future.delayed(Duration(seconds: 1), () {
        //   setState(() {
        //     _isLoading = false;
        //   });
        // });
        if (dashboardResult.statusCode == 200) {
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
            await storage.write(key: "keep", value: "false");
            await storage.write(key: "token", value: "");
            // Navigator.of(context).pushAndRemoveUntil(
            //     MaterialPageRoute(builder: (context) => MyApp()),
            //     (Route<dynamic> route) => false);
            return;
          } else {
            // FancySnackbar.showSnackbar(
            //   context,
            //   snackBarType: FancySnackBarType.error,
            //   title: "Information!",
            //   message: value.message,
            //   duration: 5,
            //   onCloseEvent: () {},
            // );
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
      }).then((value) {
        if (dashboardResult.message!.contains('Unauthenticated')) {
        } else {
          _getAll();
        }
      });
    } catch (x) {
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });
      });
    }
  }

  TimeOfDay timeOfDay = TimeOfDay.now();
  TimeOfDay? picked;

  Future<void> _selectTime(BuildContext context) async {
    picked = await showTimePicker(
      context: context,
      initialTime: timeOfDay,
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
  }

  TimeOfDay? pickedEnd;
  Future<void> _selectTimeEnd(BuildContext context) async {
    pickedEnd = await showTimePicker(
      context: context,
      initialTime: timeOfDay,
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
  }

  String idReason = "";
  String selectedTime = "";

  String selectedTimeEnd = "";

  String nextUrl = "";
  String prevUrl = "";

  var resultListLoading = new ListOperation();
  void _getLoading(bool search, String? body_type) async {
    setState(() {
      _isLoading = true;
    });
    try {
      token = await storage.read(key: "token") ?? "";

      ListOperation.connectToApi(
              Url().val +
                  "api/operations?per_page=5&filter=today&operation=TOPCOAT" +
                  (search ? "&search=${controllerSearchLoading.text}" : "") +
                  (body_type != null
                      ? (body_type == "All" ? "" : "&body_type=${body_type}")
                      : ""),
              token)
          .then((value) async {
        resultListLoading = value;
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

          nextUrl = value.data != null ? value.data!.nextPageUrl ?? "" : "";
          prevUrl = value.data != null ? value.data!.prevPageUrl ?? "" : "";
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
      }).then((value) => _getDowntime(false));
    } catch (x) {
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });
      });
    }
  }

  int startNo = 0;

  void _nextPage() async {
    setState(() {
      _isLoading = true;
    });
    try {
      token = await storage.read(key: "token") ?? "";

      ListOperation.connectToApi(nextUrl, token).then((value) async {
        resultListLoading = value;
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

          nextUrl = value.data != null ? value.data!.nextPageUrl ?? "" : "";
          prevUrl = value.data != null ? value.data!.prevPageUrl ?? "" : "";
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

  void _prevPage() async {
    setState(() {
      _isLoading = true;
    });
    try {
      token = await storage.read(key: "token") ?? "";

      ListOperation.connectToApi(prevUrl, token).then((value) async {
        resultListLoading = value;
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

          nextUrl = value.data != null ? value.data!.nextPageUrl ?? "" : "";
          prevUrl = value.data != null ? value.data!.prevPageUrl ?? "" : "";
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

  String latestDateScan = "-";
  String latestTimeScan = "-";
  String latestBodyScan = "-";
  //////////////////////////////////
  ///DOWNTIME
  //////////////////////////////////

  String nextUrlDowntime = "";
  String prevUrlDowntime = "";

  var resultListDevice = new ListDowntimeDashboard();
  void _getDowntime(bool search) async {
    setState(() {
      _isLoading = true;
    });
    try {
      token = await storage.read(key: "token") ?? "";

      ListDowntimeDashboard.connectToApi(
              Url().val +
                  "api/down-time?per_page=7&operation=TOPCOAT" +
                  (search ? "&search=${controllerCari.text}" : ""),
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

          nextUrlDowntime = value.data != null
              ? value.data != null
                  ? value.data!.nextPageUrl ?? ""
                  : ""
              : "";
          prevUrlDowntime = value.data != null
              ? value.data != null
                  ? value.data!.prevPageUrl ?? ""
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

  void _nextPageDowntime() async {
    setState(() {
      _isLoading = true;
    });
    try {
      token = await storage.read(key: "token") ?? "";

      ListDowntimeDashboard.connectToApi(nextUrl, token).then((value) async {
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

          nextUrlDowntime = value.data != null
              ? value.data != null
                  ? value.data!.nextPageUrl ?? ""
                  : ""
              : "";
          prevUrlDowntime = value.data != null
              ? value.data != null
                  ? value.data!.prevPageUrl ?? ""
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

  void _prevPageDowntime() async {
    setState(() {
      _isLoading = true;
    });
    try {
      token = await storage.read(key: "token") ?? "";
      ListDowntimeDashboard.connectToApi(prevUrl, token).then((value) async {
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

          nextUrlDowntime = value.data != null
              ? value.data != null
                  ? value.data!.nextPageUrl ?? ""
                  : ""
              : "";
          prevUrlDowntime = value.data != null
              ? value.data != null
                  ? value.data!.prevPageUrl ?? ""
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

  TextEditingController scanController = TextEditingController();
  TextEditingController planWosController = TextEditingController();
  TextEditingController operationTimeController = TextEditingController();

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

  var selectedShift = shift.Shift(id: 1111111, name: "no data available");

  var resultShift = new ListShift();
  void _getShift() async {
    setState(() {
      _isLoading = true;
    });
    try {
      token = await storage.read(key: "token") ?? "";

      ListShift.connectToApi(Url().val + "api/shift", token)
          .then((value) async {
        resultShift = value;
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
          if (resultShift.data != null) {
            selectedShift = resultShift.data![0];
          }
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
      }).then((value) {
        _getLoading(false, null);
      });
    } catch (x) {
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });
      });
    }
  }

  String selectedBody = "700P/FS";
  TextEditingController bodyController = new TextEditingController();

  int chooseSeries = 0;
  var selectedOperationTime =
      OperationTime(value: "tidak ada", name: "no data available");

  var resultOperationTime = new ListOperationTime();
  void _getOperationTime() async {
    setState(() {
      _isLoading = true;
    });
    try {
      token = await storage.read(key: "token") ?? "";

      ListOperationTime.connectToApi(Url().val + "api/operation_time", token)
          .then((value) async {
        resultOperationTime = value;
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
          if (resultOperationTime.data != null) {
            selectedOperationTime = resultOperationTime.data![0];
          }
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
      }).then((value) {
        _getLoading(false, null);
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                  margin: EdgeInsets.all(20),
                  padding: EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    borderRadius: windowWidth < 1400
                        ? BorderRadius.circular(10)
                        : BorderRadius.circular(15),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color:
                            Color.fromARGB(255, 203, 217, 248).withOpacity(0.2),
                        spreadRadius: 5,
                        blurRadius: 10,
                        offset: Offset(0, 15),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Stack(children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 200,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/bgProfile.png'),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: windowWidth < 1400
                                        ? BorderRadius.circular(10)
                                        : BorderRadius.circular(15)),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                  top: 15, left: 15, right: 15, bottom: 0),
                              height: 170,
                              width: 170,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white.withOpacity(0.4)),
                              child: SfRadialGauge(
                                axes: <RadialAxis>[
                                  RadialAxis(
                                    axisLabelStyle:
                                        GaugeTextStyle(color: Colors.white),
                                    majorTickStyle:
                                        MajorTickStyle(color: Colors.white),
                                    minorTickStyle:
                                        MinorTickStyle(color: Colors.white),
                                    minimum: 0,
                                    maximum: 100,
                                    ranges: <GaugeRange>[
                                      GaugeRange(
                                        startValue: 0,
                                        endValue: dashboardResult.data != null
                                            ? (dashboardResult.data!.oee != null
                                                ? dashboardResult.data!.oee!.oee
                                                : 0)
                                            : 0,
                                        color:
                                            Color.fromARGB(255, 115, 192, 255),
                                        startWidth: 10, // Lebar awal
                                        endWidth: 10, // Lebar akhir
                                        rangeOffset: 0,
                                        labelStyle: GaugeTextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                    pointers: <GaugePointer>[
                                      NeedlePointer(
                                        value: dashboardResult.data != null
                                            ? (dashboardResult.data!.oee != null
                                                ? dashboardResult.data!.oee!.oee
                                                : 0)
                                            : 0,
                                        needleColor: Colors.white,
                                      ),
                                    ],
                                    annotations: <GaugeAnnotation>[
                                      GaugeAnnotation(
                                        widget: Container(
                                          child: Text(
                                            'OEE\n${dashboardResult.data != null ? (dashboardResult.data!.oee != null ? dashboardResult.data!.oee!.oee.toString() : "0") : "0"}%',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        angle: 90,
                                        positionFactor: 0.9,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  top: 15, left: 15, right: 15, bottom: 0),
                              height: 170,
                              width: 170,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white.withOpacity(0.4)),
                              child: SfRadialGauge(
                                axes: <RadialAxis>[
                                  RadialAxis(
                                    axisLabelStyle:
                                        GaugeTextStyle(color: Colors.white),
                                    majorTickStyle:
                                        MajorTickStyle(color: Colors.white),
                                    minorTickStyle:
                                        MinorTickStyle(color: Colors.white),
                                    minimum: 0,
                                    maximum: 100,
                                    ranges: <GaugeRange>[
                                      GaugeRange(
                                        startValue: 0,
                                        endValue: dashboardResult.data != null
                                            ? (dashboardResult.data!.oee != null
                                                ? dashboardResult
                                                    .data!.oee!.availability
                                                : 0)
                                            : 0,
                                        color:
                                            Color.fromARGB(255, 115, 192, 255),
                                        startWidth: 10, // Lebar awal
                                        endWidth: 10, // Lebar akhir
                                        rangeOffset: 0,
                                        labelStyle: GaugeTextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                    pointers: <GaugePointer>[
                                      NeedlePointer(
                                        value: dashboardResult.data != null
                                            ? (dashboardResult.data!.oee != null
                                                ? dashboardResult
                                                    .data!.oee!.availability
                                                : 0)
                                            : 0,
                                        needleColor: Colors.white,
                                      ),
                                    ],
                                    annotations: <GaugeAnnotation>[
                                      GaugeAnnotation(
                                        widget: Container(
                                          child: Text(
                                            'AVAILABILITY\n${dashboardResult.data != null ? (dashboardResult.data!.oee != null ? dashboardResult.data!.oee!.availability.toString() : "0") : "0"}%',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        angle: 90,
                                        positionFactor: 1,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  top: 15, left: 15, right: 15, bottom: 0),
                              height: 170,
                              width: 170,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white.withOpacity(0.4)),
                              child: SfRadialGauge(
                                axes: <RadialAxis>[
                                  RadialAxis(
                                    axisLabelStyle:
                                        GaugeTextStyle(color: Colors.white),
                                    majorTickStyle:
                                        MajorTickStyle(color: Colors.white),
                                    minorTickStyle:
                                        MinorTickStyle(color: Colors.white),
                                    minimum: 0,
                                    maximum: 100,
                                    ranges: <GaugeRange>[
                                      GaugeRange(
                                        startValue: 0,
                                        endValue: dashboardResult.data != null
                                            ? (dashboardResult.data!.oee != null
                                                ? dashboardResult
                                                    .data!.oee!.performance
                                                : 0)
                                            : 0,
                                        color:
                                            Color.fromARGB(255, 115, 192, 255),
                                        startWidth: 10, // Lebar awal
                                        endWidth: 10, // Lebar akhir
                                        rangeOffset: 0,
                                        labelStyle: GaugeTextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                    pointers: <GaugePointer>[
                                      NeedlePointer(
                                        value: dashboardResult.data != null
                                            ? (dashboardResult.data!.oee != null
                                                ? dashboardResult
                                                    .data!.oee!.performance
                                                : 0)
                                            : 0,
                                        needleColor: Colors.white,
                                      ),
                                    ],
                                    annotations: <GaugeAnnotation>[
                                      GaugeAnnotation(
                                        widget: Container(
                                          child: Text(
                                            'PERFORMANCE\n${dashboardResult.data != null ? (dashboardResult.data!.oee != null ? dashboardResult.data!.oee!.performance.toString() : "0") : "0"}%',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        angle: 90,
                                        positionFactor: 0.9,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  top: 15, left: 15, right: 15, bottom: 0),
                              height: 170,
                              width: 170,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white.withOpacity(0.4)),
                              child: SfRadialGauge(
                                axes: <RadialAxis>[
                                  RadialAxis(
                                    axisLabelStyle:
                                        GaugeTextStyle(color: Colors.white),
                                    majorTickStyle:
                                        MajorTickStyle(color: Colors.white),
                                    minorTickStyle:
                                        MinorTickStyle(color: Colors.white),
                                    minimum: 0,
                                    maximum: 100,
                                    ranges: <GaugeRange>[
                                      GaugeRange(
                                        startValue: 0,
                                        endValue: dashboardResult.data != null
                                            ? (dashboardResult.data!.oee != null
                                                ? dashboardResult
                                                    .data!.oee!.quality
                                                : 0)
                                            : 0,
                                        color:
                                            Color.fromARGB(255, 115, 192, 255),
                                        startWidth: 10, // Lebar awal
                                        endWidth: 10, // Lebar akhir
                                        rangeOffset: 0,
                                        labelStyle: GaugeTextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                    pointers: <GaugePointer>[
                                      NeedlePointer(
                                        value: dashboardResult.data != null
                                            ? (dashboardResult.data!.oee != null
                                                ? dashboardResult
                                                    .data!.oee!.quality
                                                : 0)
                                            : 0,
                                        needleColor: Colors.white,
                                      ),
                                    ],
                                    annotations: <GaugeAnnotation>[
                                      GaugeAnnotation(
                                        widget: Container(
                                          child: Text(
                                            'QUALITY\n${dashboardResult.data != null ? (dashboardResult.data!.oee != null ? dashboardResult.data!.oee!.quality.toString() : "0") : "0"}%',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        angle: 90,
                                        positionFactor: 0.9,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      ]),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: Container(
                            padding: EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              borderRadius: windowWidth < 1400
                                  ? BorderRadius.circular(10)
                                  : BorderRadius.circular(15),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromARGB(255, 203, 217, 248)
                                      .withOpacity(0.5),
                                  spreadRadius: 3,
                                  blurRadius: 10,
                                  offset: Offset(0, 0),
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "DATE",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                      color: Color.fromARGB(255, 171, 177, 184),
                                      fontSize: windowWidth < 1400 ? 14 : 18,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  dashboardResult.data != null
                                      ? dashboardResult.data!.date
                                      : "",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                      color: Color.fromARGB(255, 37, 90, 151),
                                      fontSize: windowWidth < 1400 ? 16 : 20,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          )),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                              child: Container(
                            padding: EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              borderRadius: windowWidth < 1400
                                  ? BorderRadius.circular(10)
                                  : BorderRadius.circular(15),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromARGB(255, 203, 217, 248)
                                      .withOpacity(0.5),
                                  spreadRadius: 3,
                                  blurRadius: 10,
                                  offset: Offset(0, 0),
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "PRODUCTION TIME",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                      color: Color.fromARGB(255, 171, 177, 184),
                                      fontSize: windowWidth < 1400 ? 14 : 18,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  dashboardResult.data != null
                                      ? dashboardResult.data!.shift.name
                                      : "",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                      color: Color.fromARGB(255, 37, 90, 151),
                                      fontSize: windowWidth < 1400 ? 20 : 23,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          )),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                              child: Container(
                            padding: EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              borderRadius: windowWidth < 1400
                                  ? BorderRadius.circular(10)
                                  : BorderRadius.circular(15),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromARGB(255, 203, 217, 248)
                                      .withOpacity(0.5),
                                  spreadRadius: 3,
                                  blurRadius: 10,
                                  offset: Offset(0, 0),
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "OPERATION TIME",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                      color: Color.fromARGB(255, 171, 177, 184),
                                      fontSize: windowWidth < 1400 ? 14 : 18,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  dashboardResult.data != null
                                      ? dashboardResult.data!.operationTime
                                              .toString() +
                                          " MINUTES"
                                      : "",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                      color: Color.fromARGB(255, 37, 90, 151),
                                      fontSize: windowWidth < 1400 ? 20 : 23,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          )),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                              child: Container(
                            padding: EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              borderRadius: windowWidth < 1400
                                  ? BorderRadius.circular(10)
                                  : BorderRadius.circular(15),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromARGB(255, 203, 217, 248)
                                      .withOpacity(0.5),
                                  spreadRadius: 3,
                                  blurRadius: 10,
                                  offset: Offset(0, 0),
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "LINE STOP",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                      color: Color.fromARGB(255, 171, 177, 184),
                                      fontSize: windowWidth < 1400 ? 14 : 18,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  dashboardResult.data != null
                                      ? dashboardResult.data!.lineStop
                                              .toString() +
                                          " MINUTES"
                                      : "",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                      color: Color.fromARGB(255, 37, 90, 151),
                                      fontSize: windowWidth < 1400 ? 20 : 23,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          )),
                          SizedBox(
                            width: 10,
                          ),
                          Column(
                            children: [
                              BlocBuilder<TimeCubit, TimeState>(
                                builder: (context, state) {
                                  if (state is TimeLoaded) {
                                    return Text(
                                      '${state.time.hour}:${state.time.minute}:${state.time.second}',
                                      style: TextStyle(fontSize: 48),
                                    );
                                  }
                                  return CircularProgressIndicator();
                                },
                              ),
                              InkWell(
                                onTap: () {
                                  _getShift();
                                  _getOperationTime();
                                  _getItem();
                                  _getLoadingSeal(false, null);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 13),
                                  decoration: BoxDecoration(
                                    borderRadius: windowWidth < 1400
                                        ? BorderRadius.circular(10)
                                        : BorderRadius.circular(15),
                                    color: mBlueColor,
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Color.fromARGB(255, 203, 217, 248)
                                                .withOpacity(0.5),
                                        spreadRadius: 3,
                                        blurRadius: 10,
                                        offset: Offset(0, 0),
                                      )
                                    ],
                                  ),
                                  child: Text(
                                    "REFRESH DATA",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                        height: 1,
                                        color: Colors.white,
                                        fontSize: windowWidth < 1400 ? 20 : 23,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      )
                    ],
                  )),
              SizedBox(
                height: !dashboardResult.hasOee ? 0 : 300,
                child: !dashboardResult.hasOee
                    ? Container()
                    : Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 300,
                              margin: const EdgeInsets.all(20),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Scan Barcode",
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.poppins(
                                                      color: Colors.black,
                                                      fontSize:
                                                          windowWidth < 1400
                                                              ? 14
                                                              : 18,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                Text(
                                                  "Choose Series",
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.poppins(
                                                      color: Colors.black,
                                                      fontSize:
                                                          windowWidth < 1400
                                                              ? 14
                                                              : 18,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                Row(
                                                  children: [
                                                    InkWell(
                                                      onTap: () async {
                                                        setState(() {
                                                          chooseSeries = 1;
                                                        });
                                                      },
                                                      child: Container(
                                                        margin: EdgeInsets.only(
                                                            right: 10),
                                                        decoration: BoxDecoration(
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .grey
                                                                    .withOpacity(
                                                                        0.2),
                                                                spreadRadius: 5,
                                                                blurRadius: 5,
                                                                offset: Offset(
                                                                    0, 2),
                                                              )
                                                            ],
                                                            color: chooseSeries ==
                                                                    1
                                                                ? Color
                                                                    .fromARGB(
                                                                        255,
                                                                        134,
                                                                        219,
                                                                        137)
                                                                : Colors.grey,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 6,
                                                                horizontal: 8),
                                                        child: Center(
                                                          child: Text(
                                                            "NS",
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            255,
                                                                            255,
                                                                            255),
                                                                    fontSize:
                                                                        16),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onTap: () async {
                                                        setState(() {
                                                          chooseSeries = 2;
                                                        });
                                                      },
                                                      child: Container(
                                                        margin: EdgeInsets.only(
                                                            right: 10),
                                                        decoration: BoxDecoration(
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .grey
                                                                    .withOpacity(
                                                                        0.2),
                                                                spreadRadius: 5,
                                                                blurRadius: 5,
                                                                offset: Offset(
                                                                    0, 2),
                                                              )
                                                            ],
                                                            color: chooseSeries ==
                                                                    2
                                                                ? Color
                                                                    .fromARGB(
                                                                        255,
                                                                        134,
                                                                        219,
                                                                        137)
                                                                : Colors.grey,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 6,
                                                                horizontal: 8),
                                                        child: Center(
                                                          child: Text(
                                                            "FS",
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
                                              ],
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    border: Border.all(
                                                        color: Color.fromARGB(
                                                            249, 241, 241, 241),
                                                        width: 1.5),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Row(
                                                  children: <Widget>[
                                                    // Container(
                                                    //     width: 60,
                                                    //     child: Icon(
                                                    //       widget.icon,
                                                    //       size: 20,
                                                    //       color: Color(0xFFBB9B9B9),
                                                    //     )),
                                                    SizedBox(
                                                      width: 20,
                                                    ),
                                                    Expanded(
                                                      child: TextField(
                                                        autofocus:
                                                            false, // Set autofocus to true
                                                        controller:
                                                            controllerCari,
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                        decoration:
                                                            InputDecoration(
                                                                hintStyle:
                                                                    GoogleFonts
                                                                        .poppins(
                                                                  fontSize: 14,
                                                                ),
                                                                contentPadding:
                                                                    EdgeInsets.symmetric(
                                                                        vertical:
                                                                            5),
                                                                border:
                                                                    InputBorder
                                                                        .none,
                                                                hintText:
                                                                    "Input Manually"),
                                                        onChanged: (val) async {
                                                          if (val != "") {
                                                            print(val);
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              "Or",
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.poppins(
                                                  color: Colors.black,
                                                  fontSize: windowWidth < 1400
                                                      ? 14
                                                      : 18,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Expanded(
                                              child: Container(
                                                padding: EdgeInsets.all(2),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Color.fromARGB(
                                                            250, 230, 230, 230),
                                                        width: 1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                // width: 150,
                                                child: CustomDropdown<String>(
                                                  hintText: "Body Type",
                                                  initialItem: "700P/FS",
                                                  items: [
                                                    "700P/FS",
                                                    "700P/NS",
                                                    "Rear Body",
                                                    "Spareparts",
                                                    "VT/P",
                                                    "Rak Bumper",
                                                    "Rak Fender",
                                                    "Rak Door"
                                                  ],
                                                  decoration:
                                                      CustomDropdownDecoration(
                                                    listItemStyle: TextStyle(
                                                      fontFamily: "Netflix",
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                      letterSpacing: 0.0,
                                                      color: Color.fromARGB(
                                                          255, 83, 83, 83),
                                                    ),
                                                    headerStyle: TextStyle(
                                                      fontFamily: "Netflix",
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                      letterSpacing: 0.0,
                                                      color: Color.fromARGB(
                                                          255, 83, 83, 83),
                                                    ),
                                                    hintStyle: TextStyle(
                                                      fontFamily: "Netflix",
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                      letterSpacing: 0.0,
                                                      color: Color.fromARGB(
                                                          255, 110, 110, 110),
                                                    ),
                                                  ),
                                                  // initialItem: "Tomat",
                                                  onChanged: (value) {
                                                    setState(() {
                                                      selectedBody = value;
                                                    });
                                                  },
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: InkWell(
                                                onTap: () async {
                                                  try {
                                                    String pilih = "";
                                                    if (controllerCari.text
                                                        .toLowerCase()
                                                        .startsWith('b')) {
                                                      if (chooseSeries == 0) {
                                                        FancySnackbar
                                                            .showSnackbar(
                                                          context,
                                                          snackBarType:
                                                              FancySnackBarType
                                                                  .error,
                                                          title: "Failed!",
                                                          message:
                                                              "Please choose series",
                                                          duration: 5,
                                                          onCloseEvent: () {},
                                                        );
                                                        return;
                                                      } else {
                                                        if (chooseSeries == 1) {
                                                          pilih = "700P/NS";
                                                        } else {
                                                          pilih = "700P/FS";
                                                        }
                                                      }
                                                    }
                                                    log("To " + token);
                                                    Future.delayed(
                                                        const Duration(
                                                            milliseconds: 0),
                                                        () {
                                                      setState(() {
                                                        _isLoading = true;
                                                      });
                                                    });
                                                    PostBarcode.connectToApi(
                                                            token,
                                                            controllerCari.text,
                                                            pilih == ""
                                                                ? selectedBody
                                                                : pilih)
                                                        .then((value) {
                                                      setState(() {
                                                        Future.delayed(
                                                            const Duration(
                                                                milliseconds:
                                                                    2000), () {
                                                          setState(() {
                                                            _isLoading = false;
                                                          });
                                                        });
                                                        //print(storage.read(key: "token"));
                                                        if (value.status ==
                                                                200 &&
                                                            value.type ==
                                                                "complete") {
                                                          chooseSeries = 0;
                                                          _getItem();
                                                          FancySnackbar
                                                              .showSnackbar(
                                                            context,
                                                            snackBarType:
                                                                FancySnackBarType
                                                                    .success,
                                                            title:
                                                                "Successfully!",
                                                            message:
                                                                value.message,
                                                            duration: 1,
                                                            onCloseEvent: () {},
                                                          );

                                                          DateTime dt =
                                                              new DateTime
                                                                  .now();
                                                          String formattedDate =
                                                              DateFormat(
                                                                      'dd MMMM yyyy',
                                                                      'id_ID')
                                                                  .format(dt);
                                                          String formattedTime =
                                                              DateFormat(
                                                                      'HH:mm:ss',
                                                                      'id_ID')
                                                                  .format(dt);
                                                          latestDateScan =
                                                              formattedDate;
                                                          latestTimeScan =
                                                              formattedTime;
                                                          latestBodyScan =
                                                              controllerCari
                                                                          .text ==
                                                                      ""
                                                                  ? selectedBody
                                                                  : controllerCari
                                                                      .text;
                                                          controllerCari.text =
                                                              "";
                                                          latestStatus = 1;

                                                          setState(() {});
                                                          _getItem();
                                                          setState(() {});
                                                        } else if (value
                                                                    .status ==
                                                                200 &&
                                                            value.type ==
                                                                "confirm") {
                                                          showDialog(
                                                              barrierDismissible:
                                                                  true,
                                                              context: context,
                                                              builder:
                                                                  (dialogcontext) {
                                                                return AlertDialog(
                                                                    content:
                                                                        Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    // Lottie.asset(
                                                                    //     'assets/json/loadingBlue.json',
                                                                    //     height: 100,
                                                                    //     width: 100),
                                                                    SizedBox(
                                                                      height:
                                                                          20,
                                                                    ),
                                                                    Text(
                                                                      value
                                                                          .message,
                                                                      style: GoogleFonts.inter(
                                                                          fontWeight: FontWeight
                                                                              .w700,
                                                                          fontSize:
                                                                              17,
                                                                          color: Color.fromARGB(
                                                                              255,
                                                                              75,
                                                                              75,
                                                                              75)),
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          50,
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        Expanded(
                                                                          child:
                                                                              InkWell(
                                                                            onTap:
                                                                                () async {
                                                                              Navigator.pop(dialogcontext);
                                                                            },
                                                                            child:
                                                                                Container(
                                                                              decoration: BoxDecoration(boxShadow: [
                                                                                BoxShadow(
                                                                                  color: Colors.grey.withOpacity(0.2),
                                                                                  spreadRadius: 5,
                                                                                  blurRadius: 5,
                                                                                  offset: Offset(0, 2),
                                                                                )
                                                                              ], color: Color.fromARGB(255, 107, 107, 107), borderRadius: BorderRadius.circular(10)),
                                                                              padding: EdgeInsets.all(8),
                                                                              child: Center(
                                                                                child: Text(
                                                                                  "Cancel",
                                                                                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              20,
                                                                        ),
                                                                        Expanded(
                                                                          child:
                                                                              InkWell(
                                                                            onTap:
                                                                                () async {
                                                                              Navigator.pop(context);
                                                                              Future.delayed(const Duration(milliseconds: 0), () {
                                                                                setState(() {
                                                                                  _isLoading = true;
                                                                                });
                                                                              });
                                                                              RepairBarcode.connectToApi(token, controllerCari.text).then((valuea) {
                                                                                Future.delayed(const Duration(milliseconds: 2000), () {
                                                                                  setState(() {
                                                                                    _isLoading = false;
                                                                                  });
                                                                                });
                                                                                //print(storage.read(key: "token"));
                                                                                if (valuea.status == 200) {
                                                                                  chooseSeries = 0;
                                                                                  _getItem();
                                                                                  FancySnackbar.showSnackbar(
                                                                                    context,
                                                                                    snackBarType: FancySnackBarType.success,
                                                                                    title: "Successfully!",
                                                                                    message: valuea.message,
                                                                                    duration: 1,
                                                                                    onCloseEvent: () {},
                                                                                  );

                                                                                  DateTime dt = new DateTime.now();
                                                                                  String formattedDate = DateFormat('dd MMMM yyyy', 'id_ID').format(dt);
                                                                                  String formattedTime = DateFormat('HH:mm:ss', 'id_ID').format(dt);
                                                                                  latestDateScan = formattedDate;
                                                                                  latestStatus = 2;
                                                                                  latestTimeScan = formattedTime;
                                                                                  latestBodyScan = controllerCari.text == "" ? selectedBody : controllerCari.text;
                                                                                  controllerCari.text = "";

                                                                                  setState(() {});
                                                                                  _getItem();
                                                                                  setState(() {});
                                                                                } else {
                                                                                  FancySnackbar.showSnackbar(
                                                                                    context,
                                                                                    snackBarType: FancySnackBarType.error,
                                                                                    title: "Failed!",
                                                                                    message: valuea.message,
                                                                                    duration: 5,
                                                                                    onCloseEvent: () {},
                                                                                  );
                                                                                  controllerCari.text = "";
                                                                                  setState(() {});
                                                                                }
                                                                              });
                                                                            },
                                                                            child:
                                                                                Container(
                                                                              decoration: BoxDecoration(boxShadow: [
                                                                                BoxShadow(
                                                                                  color: mTitleBlue.withOpacity(0.2),
                                                                                  spreadRadius: 5,
                                                                                  blurRadius: 5,
                                                                                  offset: Offset(0, 2),
                                                                                )
                                                                              ], color: mTitleBlue, borderRadius: BorderRadius.circular(10)),
                                                                              padding: EdgeInsets.all(8),
                                                                              child: Center(
                                                                                child: Text(
                                                                                  "Repair",
                                                                                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
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
                                                          FancySnackbar
                                                              .showSnackbar(
                                                            context,
                                                            snackBarType:
                                                                FancySnackBarType
                                                                    .error,
                                                            title: "Failed!",
                                                            message:
                                                                value.message,
                                                            duration: 5,
                                                            onCloseEvent: () {},
                                                          );
                                                          controllerCari.text =
                                                              "";
                                                          setState(() {});
                                                        }
                                                      });
                                                    });
                                                  } catch (x) {
                                                    Future.delayed(
                                                        const Duration(
                                                            milliseconds: 2000),
                                                        () {
                                                      setState(() {
                                                        _isLoading = false;
                                                        controllerCari.text =
                                                            "";
                                                        setState(() {});
                                                      });
                                                    });
                                                  }
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
                                                      color: mBlueColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  padding: EdgeInsets.all(8),
                                                  child: Center(
                                                    child: Text(
                                                      "Load",
                                                      style:
                                                          GoogleFonts.poppins(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 16),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
              ),
              SizedBox(
                height: 280,
                child: Row(
                  children: [
                    dashboardResult.hasOee
                        ? Container()
                        : Expanded(
                            child: Container(
                              margin: const EdgeInsets.all(20),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Input data WOS production",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                        color: Colors.black,
                                        fontSize: windowWidth < 1400 ? 14 : 18,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Row(
                                    children: [
                                      // InkWell(
                                      //   onTap: () {
                                      //     setState(() {
                                      //       _selectDate(context).then((value) {
                                      //         setState(() {
                                      //           formattedDate =
                                      //               formatter.format(selectedDate);
                                      //         });
                                      //       });
                                      //     });
                                      //   },
                                      //   child: Expanded(
                                      //     child:
                                      //   ),
                                      // ),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              _selectDate(context)
                                                  .then((value) {
                                                formattedDate = formatter
                                                    .format(selectedDate);
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
                                                Expanded(
                                                  child: TextField(
                                                    // controller:
                                                    //     controllerSearchLoading,
                                                    enabled: false,
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                    decoration: InputDecoration(
                                                        hintStyle: GoogleFonts
                                                            .poppins(
                                                          fontSize: 14,
                                                        ),
                                                        contentPadding:
                                                            EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        5),
                                                        border:
                                                            InputBorder.none,
                                                        hintText:
                                                            formattedDate),
                                                    onChanged: (val) {},
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Expanded(
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
                                              // Container(
                                              //     width: 60,
                                              //     child: Icon(
                                              //       widget.icon,
                                              //       size: 20,
                                              //       color: Color(0xFFBB9B9B9),
                                              //     )),
                                              SizedBox(
                                                width: 20,
                                              ),
                                              Expanded(
                                                child: TextField(
                                                  // focusNode: _focusNode,
                                                  // autofocus:
                                                  //     true, // Set autofocus to true
                                                  controller: planWosController,
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                  decoration: InputDecoration(
                                                      hintStyle:
                                                          GoogleFonts.poppins(
                                                        fontSize: 14,
                                                      ),
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 5),
                                                      border: InputBorder.none,
                                                      hintText: "Plan WOS"),
                                                  onChanged: (val) async {
                                                    if (val != "") {
                                                      print(val);
                                                    }
                                                  },
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          margin:
                                              EdgeInsets.symmetric(vertical: 5),
                                          padding: EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Color.fromARGB(
                                                      250, 230, 230, 230),
                                                  width: 1),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          // width: 150,
                                          child: CustomDropdown<shift.Shift>(
                                            hintText: "Shift Time",
                                            initialItem: selectedShift,
                                            items: resultShift.data != null
                                                ? resultShift.data!.length == 0
                                                    ? [selectedShift]
                                                    : resultShift.data
                                                : [selectedShift],
                                            decoration:
                                                CustomDropdownDecoration(
                                              listItemStyle: TextStyle(
                                                fontFamily: "Netflix",
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                letterSpacing: 0.0,
                                                color: Color.fromARGB(
                                                    255, 83, 83, 83),
                                              ),
                                              headerStyle: TextStyle(
                                                fontFamily: "Netflix",
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                letterSpacing: 0.0,
                                                color: Color.fromARGB(
                                                    255, 83, 83, 83),
                                              ),
                                              hintStyle: TextStyle(
                                                fontFamily: "Netflix",
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                letterSpacing: 0.0,
                                                color: Color.fromARGB(
                                                    255, 110, 110, 110),
                                              ),
                                            ),
                                            // initialItem: "Tomat",
                                            onChanged: (value) {
                                              setState(() {
                                                selectedShift = value;
                                                // controllerConnection = value;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Expanded(
                                        child: Container(
                                          margin:
                                              EdgeInsets.symmetric(vertical: 5),
                                          padding: EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Color.fromARGB(
                                                      250, 230, 230, 230),
                                                  width: 1),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          // width: 150,
                                          child: CustomDropdown<OperationTime>(
                                            hintText: "Operation Time",
                                            initialItem: selectedOperationTime,
                                            items: resultOperationTime.data !=
                                                    null
                                                ? resultOperationTime
                                                            .data!.length ==
                                                        0
                                                    ? [selectedOperationTime]
                                                    : resultOperationTime.data
                                                : [selectedOperationTime],
                                            decoration:
                                                CustomDropdownDecoration(
                                              listItemStyle: TextStyle(
                                                fontFamily: "Netflix",
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                letterSpacing: 0.0,
                                                color: Color.fromARGB(
                                                    255, 83, 83, 83),
                                              ),
                                              headerStyle: TextStyle(
                                                fontFamily: "Netflix",
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                letterSpacing: 0.0,
                                                color: Color.fromARGB(
                                                    255, 83, 83, 83),
                                              ),
                                              hintStyle: TextStyle(
                                                fontFamily: "Netflix",
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                letterSpacing: 0.0,
                                                color: Color.fromARGB(
                                                    255, 110, 110, 110),
                                              ),
                                            ),
                                            // initialItem: "Tomat",
                                            onChanged: (value) {
                                              setState(() {
                                                selectedOperationTime = value;
                                                operationTimeController.text =
                                                    selectedOperationTime
                                                            .value ??
                                                        "";
                                                // controllerConnection = value;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          onTap: () async {
                                            try {
                                              operationTimeController.text =
                                                  selectedOperationTime.value ??
                                                      "";
                                              token = await storage.read(
                                                      key: "token") ??
                                                  "";
                                              Future.delayed(
                                                  const Duration(
                                                      milliseconds: 0), () {
                                                setState(() {
                                                  _isLoading = true;
                                                });
                                              });
                                              if (planWosController
                                                  .text.isEmpty) {
                                                setState(() {
                                                  _isLoading = false;
                                                });
                                                // ignore: use_build_context_synchronously
                                                FancySnackbar.showSnackbar(
                                                  context,
                                                  snackBarType:
                                                      FancySnackBarType.error,
                                                  title: "Failed!",
                                                  message:
                                                      "Plan WOS Wajib diisi",
                                                  duration: 5,
                                                  onCloseEvent: () {
                                                    setState(() {
                                                      _isLoading = false;
                                                    });
                                                  },
                                                );
                                                setState(() {
                                                  _isLoading = false;
                                                });
                                                return;
                                              }
                                              if (operationTimeController
                                                  .text.isEmpty) {
                                                setState(() {
                                                  _isLoading = false;
                                                });
                                                // ignore: use_build_context_synchronously
                                                FancySnackbar.showSnackbar(
                                                  context,
                                                  snackBarType:
                                                      FancySnackBarType.error,
                                                  title: "Failed!",
                                                  message:
                                                      "Operation Time Wajib diisi",
                                                  duration: 5,
                                                  onCloseEvent: () {
                                                    setState(() {
                                                      _isLoading = false;
                                                    });
                                                  },
                                                );
                                                setState(() {
                                                  _isLoading = false;
                                                });
                                                return;
                                              }
                                              PosWos.connectToApi(
                                                      token,
                                                      formattedDate,
                                                      selectedShift.id
                                                          .toString(),
                                                      planWosController.text,
                                                      operationTimeController
                                                          .text,
                                                      "TOPCOAT")
                                                  .then((value) {
                                                setState(() {
                                                  Future.delayed(
                                                      const Duration(
                                                          milliseconds: 2000),
                                                      () {
                                                    setState(() {
                                                      _isLoading = false;
                                                    });
                                                  });
                                                  //print(storage.read(key: "token"));
                                                  if (value.status == 200) {
                                                    _getItem();
                                                    FancySnackbar.showSnackbar(
                                                      context,
                                                      snackBarType:
                                                          FancySnackBarType
                                                              .success,
                                                      title: "Successfully!",
                                                      message: value.message,
                                                      duration: 1,
                                                      onCloseEvent: () {},
                                                    );
                                                    controllerCari.text = "";

                                                    _getItem();
                                                    setState(() {});
                                                  } else {
                                                    FancySnackbar.showSnackbar(
                                                      context,
                                                      snackBarType:
                                                          FancySnackBarType
                                                              .error,
                                                      title: "Failed!",
                                                      message: value.message,
                                                      duration: 5,
                                                      onCloseEvent: () {},
                                                    );
                                                    controllerCari.text = "";
                                                    setState(() {});
                                                  }
                                                });
                                              });
                                            } catch (x) {
                                              Future.delayed(
                                                  const Duration(
                                                      milliseconds: 2000), () {
                                                setState(() {
                                                  _isLoading = false;
                                                  controllerCari.text = "";
                                                  setState(() {});
                                                });
                                              });
                                            }
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
                                                color: mBlueColor,
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            padding: EdgeInsets.all(8),
                                            child: Center(
                                              child: Text(
                                                "Create",
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
                              ),
                            ),
                          ),
                    !dashboardResult.hasOee
                        ? Container()
                        : Container(
                            height: 300,
                            child: Container(
                              height: 300,
                              width: MediaQuery.of(context).size.width - 220,
                              margin: const EdgeInsets.all(20),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white),
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          width: 500,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(children: [
                                                InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      if (isStorage) {
                                                        isStorage = false;

                                                        _getLoadingSeal(
                                                            false, null);
                                                      }
                                                    });
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.all(5),
                                                    decoration: BoxDecoration(
                                                        color: isStorage
                                                            ? Colors.grey
                                                            : Colors.green,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8)),
                                                    child: Text(
                                                      "OK",
                                                      textAlign:
                                                          TextAlign.start,
                                                      style:
                                                          GoogleFonts.poppins(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 5),
                                                InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      if (!isStorage) {
                                                        isStorage = true;

                                                        _getLoadingStorage(
                                                            false, null);
                                                      }
                                                    });
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.all(5),
                                                    decoration: BoxDecoration(
                                                        color: isStorage
                                                            ? Colors.green
                                                            : Colors.grey,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8)),
                                                    child: Text(
                                                      "STORAGE",
                                                      textAlign:
                                                          TextAlign.start,
                                                      style:
                                                          GoogleFonts.poppins(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700),
                                                    ),
                                                  ),
                                                ),
                                              ]),
                                              // Row(
                                              //   mainAxisAlignment:
                                              //       MainAxisAlignment.center,
                                              //   children: [
                                              //     Container(
                                              //       width: 20,
                                              //       height: 20,
                                              //       decoration: BoxDecoration(
                                              //           border: Border.all(
                                              //               color: Color
                                              //                   .fromARGB(
                                              //                       255,
                                              //                       190,
                                              //                       190,
                                              //                       190)),
                                              //           color: Color.fromARGB(
                                              //               255,
                                              //               255,
                                              //               255,
                                              //               255),
                                              //           borderRadius:
                                              //               BorderRadius
                                              //                   .circular(
                                              //                       30)),
                                              //       child: InkWell(
                                              //         onTap: (!isStorage
                                              //                     ? (resultListLoadingSeal.data !=
                                              //                             null
                                              //                         ? resultListLoadingSeal.data!.prevPageUrl ??
                                              //                             ""
                                              //                         : "")
                                              //                     : (resultListLoadingStorage.data !=
                                              //                             null
                                              //                         ? resultListLoadingStorage.data!.prevPageUrl ??
                                              //                             ""
                                              //                         : "")) !=
                                              //                 ""
                                              //             ? () => setState(
                                              //                 () => isStorage
                                              //                     ? _prevPageStorage()
                                              //                     : _prevPageSeal())
                                              //             : null,
                                              //         child: Icon(
                                              //           Icons
                                              //               .arrow_back_ios_rounded,
                                              //           size: 10,
                                              //           color: (isStorage
                                              //                       ? (resultListLoadingStorage.data !=
                                              //                               null
                                              //                           ? resultListLoadingStorage.data!.prevPageUrl ??
                                              //                               ""
                                              //                           : "")
                                              //                       : (resultListLoadingSeal.data !=
                                              //                               null
                                              //                           ? resultListLoadingSeal.data!.prevPageUrl ??
                                              //                               ""
                                              //                           : "")) !=
                                              //                   ""
                                              //               ? mTitleBlue
                                              //               : Colors.grey,
                                              //         ),
                                              //       ),
                                              //     ),
                                              //     Container(
                                              //       margin:
                                              //           EdgeInsets.symmetric(
                                              //               horizontal: 7),
                                              //       width: 20,
                                              //       height: 20,
                                              //       decoration: BoxDecoration(
                                              //           color: mTitleBlue,
                                              //           borderRadius:
                                              //               BorderRadius
                                              //                   .circular(
                                              //                       30)),
                                              //       child: Align(
                                              //         alignment:
                                              //             Alignment.center,
                                              //         child: Text(
                                              //           isStorage
                                              //               ? ("${resultListLoadingStorage.data != null ? resultListLoadingStorage.data!.currentPage.toString() : ""}")
                                              //               : ("${resultListLoadingSeal.data != null ? resultListLoadingSeal.data!.currentPage.toString() : ""}"),
                                              //           textAlign:
                                              //               TextAlign.center,
                                              //           style: GoogleFonts
                                              //               .poppins(
                                              //                   color: Colors
                                              //                       .white,
                                              //                   fontSize: 11,
                                              //                   fontWeight:
                                              //                       FontWeight
                                              //                           .w600),
                                              //         ),
                                              //       ),
                                              //     ),
                                              //     Container(
                                              //       width: 20,
                                              //       height: 20,
                                              //       decoration: BoxDecoration(
                                              //           border: Border.all(
                                              //               color: Color
                                              //                   .fromARGB(
                                              //                       255,
                                              //                       190,
                                              //                       190,
                                              //                       190)),
                                              //           color: Color.fromARGB(
                                              //               255,
                                              //               255,
                                              //               255,
                                              //               255),
                                              //           borderRadius:
                                              //               BorderRadius
                                              //                   .circular(
                                              //                       30)),
                                              //       child: InkWell(
                                              //         onTap: (isStorage
                                              //                     ? (resultListLoadingStorage.data !=
                                              //                             null
                                              //                         ? resultListLoadingStorage.data!.nextPageUrl ??
                                              //                             ""
                                              //                         : "")
                                              //                     : (resultListLoadingSeal.data !=
                                              //                             null
                                              //                         ? resultListLoadingSeal.data!.nextPageUrl ??
                                              //                             ""
                                              //                         : "")) !=
                                              //                 ""
                                              //             ? () => setState(
                                              //                 () => isStorage
                                              //                     ? _nextPageStorage()
                                              //                     : _nextPageSeal())
                                              //             : null,
                                              //         child: Icon(
                                              //           Icons
                                              //               .arrow_forward_ios_rounded,
                                              //           size: 10,
                                              //           color: (isStorage
                                              //                       ? (resultListLoadingStorage.data !=
                                              //                               null
                                              //                           ? resultListLoadingStorage.data!.nextPageUrl ??
                                              //                               ""
                                              //                           : "")
                                              //                       : (resultListLoadingSeal.data !=
                                              //                               null
                                              //                           ? resultListLoadingSeal.data!.nextPageUrl ??
                                              //                               ""
                                              //                           : "")) !=
                                              //                   ""
                                              //               ? mTitleBlue
                                              //               : Colors.grey,
                                              //         ),
                                              //       ),
                                              //     ),
                                              //   ],
                                              // ),
                                              Container(
                                                  width: 209,
                                                  padding: EdgeInsets.symmetric(
                                                      // horizontal: 5,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFFF4F7FE),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            40),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Color.fromARGB(
                                                            134, 244, 247, 254),
                                                        spreadRadius: 1,
                                                        blurRadius: 1,
                                                        offset: Offset(0, 1),
                                                      )
                                                    ],
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      SearchInput(
                                                        width: 209,
                                                        controller:
                                                            controllerSearchLoadingSeal,
                                                        nama: "search",
                                                        onclick: () {
                                                          if (isStorage) {
                                                            _getLoadingStorage(
                                                                true, null);
                                                          } else {
                                                            _getLoadingSeal(
                                                                true, null);
                                                          }
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
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 10),
                                        // color: Colors.white,
                                        padding: EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                            color: Color.fromARGB(
                                                255, 255, 255, 255),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 20,
                                              child: Text(
                                                "No",
                                                textAlign: TextAlign.start,
                                                style: GoogleFonts.poppins(
                                                    color: Colors.grey,
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.w500),
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
                                                    fontWeight:
                                                        FontWeight.w500),
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
                                                    fontWeight:
                                                        FontWeight.w500),
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
                                                    fontWeight:
                                                        FontWeight.w500),
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
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Divider(
                                        height: 2,
                                      ),
                                      Container(
                                        height: 130,
                                        child: SingleChildScrollView(
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: List.generate(
                                                  isStorage
                                                      ? (resultListLoadingStorage
                                                                  .data !=
                                                              null
                                                          ? (resultListLoadingStorage
                                                                      .data!
                                                                      .data !=
                                                                  null
                                                              ? resultListLoadingStorage
                                                                  .data!.data!.length
                                                              : 0)
                                                          : 0)
                                                      : (resultListLoadingSeal
                                                                  .data !=
                                                              null
                                                          ? (resultListLoadingSeal
                                                                      .data!
                                                                      .data !=
                                                                  null
                                                              ? resultListLoadingSeal
                                                                  .data!
                                                                  .data!
                                                                  .length
                                                              : 0)
                                                          : 0), (index) {
                                                final item = isStorage
                                                    ? null
                                                    : resultListLoadingSeal
                                                        .data!.data![index];
                                                final itemStorage = isStorage
                                                    ? resultListLoadingStorage
                                                        .data!.data![index]
                                                    : null;
                                                return Container(
                                                  width: 500,
                                                  margin: EdgeInsets.only(
                                                      bottom: 5),
                                                  padding: EdgeInsets.all(3),
                                                  decoration: BoxDecoration(
                                                      color: Color.fromARGB(
                                                          255, 255, 255, 255),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        width: 30,
                                                        child: Text(
                                                          isStorage
                                                              ? (((resultListLoadingStorage.data!.currentPage! -
                                                                              1) *
                                                                          4) +
                                                                      (index +
                                                                          1))
                                                                  .toString()
                                                              : (((resultListLoadingSeal.data!.currentPage! -
                                                                              1) *
                                                                          4) +
                                                                      (index +
                                                                          1))
                                                                  .toString(),
                                                          textAlign:
                                                              TextAlign.start,
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  color:
                                                                      mDarkBlue,
                                                                  fontSize: 11,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                        ),
                                                      ),
                                                      Container(
                                                        width: 100,
                                                        child: Text(
                                                          isStorage
                                                              ? itemStorage ==
                                                                      null
                                                                  ? ""
                                                                  : itemStorage
                                                                      .timeOut
                                                              : item == null
                                                                  ? ""
                                                                  : item.date,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  color:
                                                                      mDarkBlue,
                                                                  fontSize: 11,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                        ),
                                                      ),
                                                      Container(
                                                        width: 150,
                                                        child: Text(
                                                          isStorage
                                                              ? itemStorage ==
                                                                      null
                                                                  ? ""
                                                                  : itemStorage
                                                                      .bodyId
                                                              : item == null
                                                                  ? ""
                                                                  : item.bodyId,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  color:
                                                                      mDarkBlue,
                                                                  fontSize: 11,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                        ),
                                                      ),
                                                      Container(
                                                        width: 100,
                                                        child: Text(
                                                          isStorage
                                                              ? itemStorage ==
                                                                      null
                                                                  ? ""
                                                                  : itemStorage
                                                                      .variant
                                                              : item == null
                                                                  ? ""
                                                                  : item
                                                                      .bodyType,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  color:
                                                                      mDarkBlue,
                                                                  fontSize: 11,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
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
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            InkWell(
                                                              onTap: () async {
                                                                if (_isLoading) {
                                                                  return;
                                                                }
                                                                konfirmasiDialog(
                                                                    isStorage
                                                                        ? itemStorage ==
                                                                                null
                                                                            ? ""
                                                                            : itemStorage
                                                                                .bodyId
                                                                        : item ==
                                                                                null
                                                                            ? ""
                                                                            : item
                                                                                .bodyId,
                                                                    isStorage
                                                                        ? itemStorage ==
                                                                                null
                                                                            ? ""
                                                                            : itemStorage
                                                                                .variant
                                                                        : item ==
                                                                                null
                                                                            ? ""
                                                                            : item
                                                                                .bodyType,
                                                                    context,
                                                                    () async {
                                                                  Navigator.pop(
                                                                      context);
                                                                  try {
                                                                    token = await storage.read(
                                                                            key:
                                                                                "token") ??
                                                                        "";

                                                                    Future.delayed(
                                                                        const Duration(
                                                                            milliseconds:
                                                                                0),
                                                                        () {
                                                                      setState(
                                                                          () {
                                                                        _isLoading =
                                                                            true;
                                                                      });
                                                                    });
                                                                    PostSeal.connectToApi(
                                                                            token,
                                                                            isStorage
                                                                                ? itemStorage == null
                                                                                    ? ""
                                                                                    : itemStorage.bodyId
                                                                                : item == null
                                                                                    ? ""
                                                                                    : item.bodyId,
                                                                            isStorage
                                                                                ? itemStorage == null
                                                                                    ? ""
                                                                                    : itemStorage.variant
                                                                                : item == null
                                                                                    ? ""
                                                                                    : item.bodyType)
                                                                        .then((value) {
                                                                      setState(
                                                                          () {
                                                                        Future.delayed(
                                                                            const Duration(milliseconds: 2000),
                                                                            () {
                                                                          setState(
                                                                              () {
                                                                            _isLoading =
                                                                                false;
                                                                          });
                                                                        });
                                                                        //print(storage.read(key: "token"));
                                                                        if (value.status ==
                                                                                200 &&
                                                                            value.type ==
                                                                                "complete") {
                                                                          FancySnackbar
                                                                              .showSnackbar(
                                                                            context,
                                                                            snackBarType:
                                                                                FancySnackBarType.success,
                                                                            title:
                                                                                "Successfully!",
                                                                            message:
                                                                                value.message,
                                                                            duration:
                                                                                1,
                                                                            onCloseEvent:
                                                                                () {},
                                                                          );

                                                                          DateTime
                                                                              dt =
                                                                              new DateTime.now();
                                                                          String
                                                                              formattedDate =
                                                                              DateFormat('dd MMMM yyyy', 'id_ID').format(dt);
                                                                          String
                                                                              formattedTime =
                                                                              DateFormat('HH:mm:ss', 'id_ID').format(dt);
                                                                          latestDateScan =
                                                                              formattedDate;
                                                                          latestTimeScan =
                                                                              formattedTime;
                                                                          latestBodyScan = isStorage
                                                                              ? itemStorage == null
                                                                                  ? ""
                                                                                  : itemStorage.bodyId
                                                                              : item == null
                                                                                  ? ""
                                                                                  : item.bodyId;
                                                                          controllerSearchLoadingSeal.text =
                                                                              "";

                                                                          setState(
                                                                              () {});
                                                                          _getLoadingSeal(
                                                                              false,
                                                                              null);
                                                                          setState(
                                                                              () {});
                                                                        } else if (value.status ==
                                                                                200 &&
                                                                            value.type ==
                                                                                "confirm") {
                                                                          showDialog(
                                                                              barrierDismissible: true,
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
                                                                                      value.message,
                                                                                      style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 17, color: Color.fromARGB(255, 75, 75, 75)),
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
                                                                                              decoration: BoxDecoration(boxShadow: [
                                                                                                BoxShadow(
                                                                                                  color: Colors.grey.withOpacity(0.2),
                                                                                                  spreadRadius: 5,
                                                                                                  blurRadius: 5,
                                                                                                  offset: Offset(0, 2),
                                                                                                )
                                                                                              ], color: Color.fromARGB(255, 107, 107, 107), borderRadius: BorderRadius.circular(10)),
                                                                                              padding: EdgeInsets.all(8),
                                                                                              child: Center(
                                                                                                child: Text(
                                                                                                  "Cancel",
                                                                                                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
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
                                                                                              Navigator.pop(context);
                                                                                              Future.delayed(const Duration(milliseconds: 0), () {
                                                                                                setState(() {
                                                                                                  _isLoading = true;
                                                                                                });
                                                                                              });
                                                                                              RepairBarcode.connectToApi(
                                                                                                      token,
                                                                                                      isStorage
                                                                                                          ? itemStorage == null
                                                                                                              ? ""
                                                                                                              : itemStorage.bodyId
                                                                                                          : item == null
                                                                                                              ? ""
                                                                                                              : item.bodyId)
                                                                                                  .then((valuea) {
                                                                                                Future.delayed(const Duration(milliseconds: 2000), () {
                                                                                                  setState(() {
                                                                                                    _isLoading = false;
                                                                                                  });
                                                                                                });
                                                                                                //print(storage.read(key: "token"));
                                                                                                if (valuea.status == 200) {
                                                                                                  FancySnackbar.showSnackbar(
                                                                                                    context,
                                                                                                    snackBarType: FancySnackBarType.success,
                                                                                                    title: "Successfully!",
                                                                                                    message: valuea.message,
                                                                                                    duration: 1,
                                                                                                    onCloseEvent: () {},
                                                                                                  );

                                                                                                  DateTime dt = new DateTime.now();
                                                                                                  String formattedDate = DateFormat('dd MMMM yyyy', 'id_ID').format(dt);
                                                                                                  String formattedTime = DateFormat('HH:mm:ss', 'id_ID').format(dt);

                                                                                                  latestDateScan = formattedDate;
                                                                                                  latestTimeScan = formattedTime;
                                                                                                  latestBodyScan = isStorage
                                                                                                      ? itemStorage == null
                                                                                                          ? ""
                                                                                                          : itemStorage.bodyId
                                                                                                      : item == null
                                                                                                          ? ""
                                                                                                          : item.bodyId;
                                                                                                  controllerSearchLoadingSeal.text = "";

                                                                                                  _getItem();
                                                                                                  _getLoadingSeal(false, null);
                                                                                                } else {
                                                                                                  FancySnackbar.showSnackbar(
                                                                                                    context,
                                                                                                    snackBarType: FancySnackBarType.error,
                                                                                                    title: "Failed!",
                                                                                                    message: valuea.message,
                                                                                                    duration: 5,
                                                                                                    onCloseEvent: () {},
                                                                                                  );
                                                                                                  controllerSearchLoadingSeal.text = "";
                                                                                                  setState(() {});
                                                                                                }
                                                                                              });
                                                                                            },
                                                                                            child: Container(
                                                                                              decoration: BoxDecoration(boxShadow: [
                                                                                                BoxShadow(
                                                                                                  color: mTitleBlue.withOpacity(0.2),
                                                                                                  spreadRadius: 5,
                                                                                                  blurRadius: 5,
                                                                                                  offset: Offset(0, 2),
                                                                                                )
                                                                                              ], color: mTitleBlue, borderRadius: BorderRadius.circular(10)),
                                                                                              padding: EdgeInsets.all(8),
                                                                                              child: Center(
                                                                                                child: Text(
                                                                                                  "Submit",
                                                                                                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
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
                                                                          FancySnackbar
                                                                              .showSnackbar(
                                                                            context,
                                                                            snackBarType:
                                                                                FancySnackBarType.error,
                                                                            title:
                                                                                "Failed!",
                                                                            message:
                                                                                value.message,
                                                                            duration:
                                                                                5,
                                                                            onCloseEvent:
                                                                                () {},
                                                                          );
                                                                          controllerSearchLoadingSeal.text =
                                                                              "";
                                                                          setState(
                                                                              () {});
                                                                        }
                                                                      });
                                                                    });
                                                                  } catch (x) {
                                                                    FancySnackbar
                                                                        .showSnackbar(
                                                                      context,
                                                                      snackBarType:
                                                                          FancySnackBarType
                                                                              .error,
                                                                      title:
                                                                          "Failed!",
                                                                      message: x
                                                                          .toString(),
                                                                      duration:
                                                                          5,
                                                                      onCloseEvent:
                                                                          () {},
                                                                    );
                                                                  }
                                                                });
                                                              },
                                                              child: Container(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        vertical:
                                                                            2,
                                                                        horizontal:
                                                                            8),
                                                                decoration: BoxDecoration(
                                                                    color: !_isLoading
                                                                        ? Color.fromARGB(
                                                                            255,
                                                                            129,
                                                                            218,
                                                                            88)
                                                                        : const Color.fromARGB(
                                                                            255,
                                                                            202,
                                                                            202,
                                                                            202),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            4)),
                                                                child: Text(
                                                                  "SUBMIT",
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  style: GoogleFonts.poppins(
                                                                      color: const Color
                                                                              .fromARGB(
                                                                          255,
                                                                          44,
                                                                          44,
                                                                          44),
                                                                      fontSize:
                                                                          13,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600),
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
                                        ),
                                      ),
                                    ],
                                  )),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Latest Scanned",
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.poppins(
                                                    color: Colors.black,
                                                    fontSize: windowWidth < 1400
                                                        ? 14
                                                        : 18,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              InkWell(
                                                onTap: () async {
                                                  if (resultShift.data !=
                                                      null) {
                                                    DateTime parsedDate = DateFormat(
                                                            'dd MMMM yyyy')
                                                        .parse(dashboardResult
                                                                .data
                                                                ?.formatted_date ??
                                                            "05 Januari 2024");
                                                    formattedDate = formatter
                                                        .format(parsedDate);
                                                    planWosController.text =
                                                        dashboardResult
                                                                .data?.planWos
                                                                .toString() ??
                                                            "";
                                                    selectedShift = resultShift
                                                        .data!
                                                        .firstWhere((shift) =>
                                                            shift.id ==
                                                            dashboardResult
                                                                .data?.shiftId);
                                                    selectedOperationTime =
                                                        resultOperationTime
                                                            .data!
                                                            .firstWhere((shift) =>
                                                                shift.value ==
                                                                dashboardResult
                                                                    .data
                                                                    ?.operationTime
                                                                    .toString());
                                                    operationTimeController
                                                            .text =
                                                        selectedOperationTime
                                                                .value ??
                                                            "";
                                                  }
                                                  showDialog(
                                                      barrierDismissible: true,
                                                      context: context,
                                                      builder: (BuildContext
                                                          dialogcontext) {
                                                        return StatefulBuilder(
                                                          builder: (BuildContext
                                                                      dialogcontext,
                                                                  setState) =>
                                                              AlertDialog(
                                                            content: Container(
                                                              height: 250,
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  2.5,
                                                              margin:
                                                                  const EdgeInsets
                                                                      .all(20),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(20),
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20),
                                                                  color: Colors
                                                                      .white),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    "Edit data WOS production",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: GoogleFonts.poppins(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize: windowWidth <
                                                                                1400
                                                                            ? 14
                                                                            : 18,
                                                                        fontWeight:
                                                                            FontWeight.w500),
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      // InkWell(
                                                                      //   onTap: () {
                                                                      //     setState(() {
                                                                      //       _selectDate(context).then((value) {
                                                                      //         setState(() {
                                                                      //           formattedDate =
                                                                      //               formatter.format(selectedDate);
                                                                      //         });
                                                                      //       });
                                                                      //     });
                                                                      //   },
                                                                      //   child: Expanded(
                                                                      //     child:
                                                                      //   ),
                                                                      // ),
                                                                      Expanded(
                                                                        child:
                                                                            InkWell(
                                                                          onTap:
                                                                              () {
                                                                            setState(() {
                                                                              _selectDate(context).then((value) {
                                                                                formattedDate = formatter.format(selectedDate);
                                                                              });
                                                                            });
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            decoration: BoxDecoration(
                                                                                color: Colors.white,
                                                                                border: Border.all(color: Color.fromARGB(249, 241, 241, 241), width: 1.5),
                                                                                borderRadius: BorderRadius.circular(10)),
                                                                            child:
                                                                                Row(
                                                                              children: <Widget>[
                                                                                SizedBox(
                                                                                  width: 20,
                                                                                ),
                                                                                Expanded(
                                                                                  child: TextField(
                                                                                    // controller:
                                                                                    //     controllerSearchLoading,
                                                                                    enabled: false,
                                                                                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                                                                                    decoration: InputDecoration(
                                                                                        hintStyle: GoogleFonts.poppins(
                                                                                          fontSize: 14,
                                                                                        ),
                                                                                        contentPadding: EdgeInsets.symmetric(vertical: 5),
                                                                                        border: InputBorder.none,
                                                                                        hintText: formattedDate),
                                                                                    onChanged: (val) {},
                                                                                  ),
                                                                                )
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            20,
                                                                      ),
                                                                      Expanded(
                                                                        child:
                                                                            Container(
                                                                          decoration: BoxDecoration(
                                                                              color: Colors.white,
                                                                              border: Border.all(color: Color.fromARGB(249, 241, 241, 241), width: 1.5),
                                                                              borderRadius: BorderRadius.circular(10)),
                                                                          child:
                                                                              Row(
                                                                            children: <Widget>[
                                                                              // Container(
                                                                              //     width: 60,
                                                                              //     child: Icon(
                                                                              //       widget.icon,
                                                                              //       size: 20,
                                                                              //       color: Color(0xFFBB9B9B9),
                                                                              //     )),
                                                                              SizedBox(
                                                                                width: 20,
                                                                              ),
                                                                              Expanded(
                                                                                child: TextField(
                                                                                  // focusNode: _focusNode,
                                                                                  // autofocus:
                                                                                  //     true, // Set autofocus to true
                                                                                  controller: planWosController,
                                                                                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                                                                                  decoration: InputDecoration(
                                                                                      hintStyle: GoogleFonts.poppins(
                                                                                        fontSize: 14,
                                                                                      ),
                                                                                      contentPadding: EdgeInsets.symmetric(vertical: 5),
                                                                                      border: InputBorder.none,
                                                                                      hintText: "Plan WOS"),
                                                                                  onChanged: (val) async {
                                                                                    if (val != "") {
                                                                                      print(val);
                                                                                    }
                                                                                  },
                                                                                ),
                                                                              )
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Expanded(
                                                                        child:
                                                                            Container(
                                                                          margin:
                                                                              EdgeInsets.symmetric(vertical: 5),
                                                                          padding:
                                                                              EdgeInsets.all(2),
                                                                          decoration: BoxDecoration(
                                                                              border: Border.all(color: Color.fromARGB(250, 230, 230, 230), width: 1),
                                                                              borderRadius: BorderRadius.circular(10)),
                                                                          // width: 150,
                                                                          child:
                                                                              CustomDropdown<shift.Shift>(
                                                                            hintText:
                                                                                "Shift Time",
                                                                            initialItem:
                                                                                selectedShift,
                                                                            items: resultShift.data != null
                                                                                ? resultShift.data!.length == 0
                                                                                    ? [selectedShift]
                                                                                    : resultShift.data
                                                                                : [selectedShift],
                                                                            decoration:
                                                                                CustomDropdownDecoration(
                                                                              listItemStyle: TextStyle(
                                                                                fontFamily: "Netflix",
                                                                                fontWeight: FontWeight.w600,
                                                                                fontSize: 14,
                                                                                letterSpacing: 0.0,
                                                                                color: Color.fromARGB(255, 83, 83, 83),
                                                                              ),
                                                                              headerStyle: TextStyle(
                                                                                fontFamily: "Netflix",
                                                                                fontWeight: FontWeight.w600,
                                                                                fontSize: 14,
                                                                                letterSpacing: 0.0,
                                                                                color: Color.fromARGB(255, 83, 83, 83),
                                                                              ),
                                                                              hintStyle: TextStyle(
                                                                                fontFamily: "Netflix",
                                                                                fontWeight: FontWeight.w600,
                                                                                fontSize: 14,
                                                                                letterSpacing: 0.0,
                                                                                color: Color.fromARGB(255, 110, 110, 110),
                                                                              ),
                                                                            ),
                                                                            // initialItem: "Tomat",
                                                                            onChanged:
                                                                                (value) {
                                                                              setState(() {
                                                                                selectedShift = value;
                                                                                // controllerConnection = value;
                                                                              });
                                                                            },
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            20,
                                                                      ),
                                                                      Expanded(
                                                                        child:
                                                                            Container(
                                                                          margin:
                                                                              EdgeInsets.symmetric(vertical: 5),
                                                                          padding:
                                                                              EdgeInsets.all(2),
                                                                          decoration: BoxDecoration(
                                                                              border: Border.all(color: Color.fromARGB(250, 230, 230, 230), width: 1),
                                                                              borderRadius: BorderRadius.circular(10)),
                                                                          // width: 150,
                                                                          child:
                                                                              CustomDropdown<OperationTime>(
                                                                            hintText:
                                                                                "Operation Time",
                                                                            initialItem:
                                                                                selectedOperationTime,
                                                                            items: resultOperationTime.data !=
                                                                                    null
                                                                                ? resultOperationTime.data!.length ==
                                                                                        0
                                                                                    ? [
                                                                                        selectedOperationTime
                                                                                      ]
                                                                                    : resultOperationTime
                                                                                        .data
                                                                                : [
                                                                                    selectedOperationTime
                                                                                  ],
                                                                            decoration:
                                                                                CustomDropdownDecoration(
                                                                              listItemStyle: TextStyle(
                                                                                fontFamily: "Netflix",
                                                                                fontWeight: FontWeight.w600,
                                                                                fontSize: 14,
                                                                                letterSpacing: 0.0,
                                                                                color: Color.fromARGB(255, 83, 83, 83),
                                                                              ),
                                                                              headerStyle: TextStyle(
                                                                                fontFamily: "Netflix",
                                                                                fontWeight: FontWeight.w600,
                                                                                fontSize: 14,
                                                                                letterSpacing: 0.0,
                                                                                color: Color.fromARGB(255, 83, 83, 83),
                                                                              ),
                                                                              hintStyle: TextStyle(
                                                                                fontFamily: "Netflix",
                                                                                fontWeight: FontWeight.w600,
                                                                                fontSize: 14,
                                                                                letterSpacing: 0.0,
                                                                                color: Color.fromARGB(255, 110, 110, 110),
                                                                              ),
                                                                            ),
                                                                            // initialItem: "Tomat",
                                                                            onChanged:
                                                                                (value) {
                                                                              setState(() {
                                                                                selectedOperationTime = value;
                                                                                operationTimeController.text = selectedOperationTime.value ?? "";
                                                                                // controllerConnection = value;
                                                                              });
                                                                            },
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Expanded(
                                                                        child:
                                                                            InkWell(
                                                                          onTap:
                                                                              () async {
                                                                            try {
                                                                              operationTimeController.text = selectedOperationTime.value ?? "";
                                                                              Future.delayed(const Duration(milliseconds: 0), () {
                                                                                setState(() {
                                                                                  _isLoading = true;
                                                                                });
                                                                              });
                                                                              if (planWosController.text.isEmpty) {
                                                                                setState(() {
                                                                                  _isLoading = false;
                                                                                });
                                                                                // ignore: use_build_context_synchronously
                                                                                FancySnackbar.showSnackbar(
                                                                                  context,
                                                                                  snackBarType: FancySnackBarType.error,
                                                                                  title: "Failed!",
                                                                                  message: "Plan WOS Wajib diisi",
                                                                                  duration: 5,
                                                                                  onCloseEvent: () {},
                                                                                );
                                                                                return;
                                                                              }
                                                                              if (operationTimeController.text.isEmpty) {
                                                                                setState(() {
                                                                                  _isLoading = false;
                                                                                });
                                                                                // ignore: use_build_context_synchronously
                                                                                FancySnackbar.showSnackbar(
                                                                                  context,
                                                                                  snackBarType: FancySnackBarType.error,
                                                                                  title: "Failed!",
                                                                                  message: "Operation Time Wajib diisi",
                                                                                  duration: 5,
                                                                                  onCloseEvent: () {},
                                                                                );
                                                                                return;
                                                                              }
                                                                              EditWos.connectToApi(token, formattedDate, selectedShift.id.toString(), planWosController.text, operationTimeController.text).then((value) {
                                                                                setState(() {
                                                                                  Navigator.pop(dialogcontext);
                                                                                  Future.delayed(const Duration(milliseconds: 2000), () {
                                                                                    setState(() {
                                                                                      _isLoading = false;
                                                                                    });
                                                                                  });
                                                                                  //print(storage.read(key: "token"));
                                                                                  if (value.status == 200) {
                                                                                    _getItem();
                                                                                    FancySnackbar.showSnackbar(
                                                                                      context,
                                                                                      snackBarType: FancySnackBarType.success,
                                                                                      title: "Successfully!",
                                                                                      message: value.message,
                                                                                      duration: 1,
                                                                                      onCloseEvent: () {},
                                                                                    );
                                                                                    controllerCari.text = "";

                                                                                    _getItem();
                                                                                    setState(() {});
                                                                                  } else {
                                                                                    FancySnackbar.showSnackbar(
                                                                                      context,
                                                                                      snackBarType: FancySnackBarType.error,
                                                                                      title: "Failed!",
                                                                                      message: value.message,
                                                                                      duration: 5,
                                                                                      onCloseEvent: () {},
                                                                                    );
                                                                                    controllerCari.text = "";
                                                                                    setState(() {});
                                                                                  }
                                                                                });
                                                                              });
                                                                            } catch (x) {
                                                                              Future.delayed(const Duration(milliseconds: 2000), () {
                                                                                setState(() {
                                                                                  _isLoading = false;
                                                                                  controllerCari.text = "";
                                                                                  setState(() {});
                                                                                });
                                                                              });
                                                                            }
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            decoration:
                                                                                BoxDecoration(boxShadow: [
                                                                              BoxShadow(
                                                                                color: Colors.grey.withOpacity(0.2),
                                                                                spreadRadius: 5,
                                                                                blurRadius: 5,
                                                                                offset: Offset(0, 2),
                                                                              )
                                                                            ], color: mBlueColor, borderRadius: BorderRadius.circular(10)),
                                                                            padding:
                                                                                EdgeInsets.all(8),
                                                                            child:
                                                                                Center(
                                                                              child: Text(
                                                                                "Edit",
                                                                                style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      });
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
                                                      color: Colors.grey,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 5),
                                                  child: Center(
                                                    child: Text(
                                                      "Edit WOS",
                                                      style:
                                                          GoogleFonts.poppins(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 16),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 15,
                                          ),
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      latestDateScan,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style:
                                                          GoogleFonts.poppins(
                                                              color: mDarkBlue,
                                                              fontSize:
                                                                  windowWidth <
                                                                          1400
                                                                      ? 12
                                                                      : 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                    ),
                                                    Text(
                                                      latestTimeScan,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style:
                                                          GoogleFonts.poppins(
                                                              color: mDarkBlue,
                                                              fontSize:
                                                                  windowWidth <
                                                                          1400
                                                                      ? 12
                                                                      : 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        // Text(
                                                        //   "",
                                                        //   textAlign: TextAlign.center,
                                                        //   style: GoogleFonts.poppins(
                                                        //       color: mDarkBlue,
                                                        //       fontSize:
                                                        //           windowWidth < 1400
                                                        //               ? 25
                                                        //               : 35,
                                                        //       fontWeight:
                                                        //           FontWeight.w800),
                                                        // ),
                                                        Text(
                                                          latestBodyScan,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: GoogleFonts.poppins(
                                                              color: mDarkBlue,
                                                              fontSize:
                                                                  windowWidth <
                                                                          1400
                                                                      ? 25
                                                                      : 25,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      width: 20,
                                                    ),
                                                    Expanded(
                                                      child: InkWell(
                                                        onTap: () async {
                                                          showDialog(
                                                              barrierDismissible:
                                                                  true,
                                                              context: context,
                                                              builder:
                                                                  (dialogcontext) {
                                                                return AlertDialog(
                                                                    content:
                                                                        Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    // Lottie.asset(
                                                                    //     'assets/json/loadingBlue.json',
                                                                    //     height: 100,
                                                                    //     width: 100),
                                                                    SizedBox(
                                                                      height:
                                                                          20,
                                                                    ),
                                                                    Text(
                                                                      "Confirmation",
                                                                      style: GoogleFonts.inter(
                                                                          fontWeight: FontWeight
                                                                              .w700,
                                                                          fontSize:
                                                                              17,
                                                                          color: Color.fromARGB(
                                                                              255,
                                                                              75,
                                                                              75,
                                                                              75)),
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          50,
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        Expanded(
                                                                          child:
                                                                              InkWell(
                                                                            onTap:
                                                                                () async {
                                                                              Navigator.pop(dialogcontext);
                                                                            },
                                                                            child:
                                                                                Container(
                                                                              decoration: BoxDecoration(boxShadow: [
                                                                                BoxShadow(
                                                                                  color: Colors.grey.withOpacity(0.2),
                                                                                  spreadRadius: 5,
                                                                                  blurRadius: 5,
                                                                                  offset: Offset(0, 2),
                                                                                )
                                                                              ], color: Color.fromARGB(255, 107, 107, 107), borderRadius: BorderRadius.circular(10)),
                                                                              padding: EdgeInsets.all(8),
                                                                              child: Center(
                                                                                child: Text(
                                                                                  "Cancel",
                                                                                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              20,
                                                                        ),
                                                                        Expanded(
                                                                          child:
                                                                              InkWell(
                                                                            onTap:
                                                                                () async {
                                                                              Navigator.pop(context);
                                                                              Future.delayed(const Duration(milliseconds: 0), () {
                                                                                setState(() {
                                                                                  _isLoading = true;
                                                                                });
                                                                              });
                                                                              PostEndProduction.connectToApi(token, dashboardResult.id.toString()).then((valuea) {
                                                                                Future.delayed(const Duration(milliseconds: 2000), () {
                                                                                  setState(() {
                                                                                    _isLoading = false;
                                                                                  });
                                                                                });
                                                                                //print(storage.read(key: "token"));
                                                                                if (valuea.status == 200) {
                                                                                  _getItem();
                                                                                  FancySnackbar.showSnackbar(
                                                                                    context,
                                                                                    snackBarType: FancySnackBarType.success,
                                                                                    title: "Successfully!",
                                                                                    message: valuea.message,
                                                                                    duration: 1,
                                                                                    onCloseEvent: () {},
                                                                                  );
                                                                                  _getItem();
                                                                                } else {
                                                                                  FancySnackbar.showSnackbar(
                                                                                    context,
                                                                                    snackBarType: FancySnackBarType.error,
                                                                                    title: "Failed!",
                                                                                    message: valuea.message,
                                                                                    duration: 5,
                                                                                    onCloseEvent: () {},
                                                                                  );
                                                                                  controllerCari.text = "";
                                                                                  setState(() {});
                                                                                }
                                                                              });
                                                                            },
                                                                            child:
                                                                                Container(
                                                                              decoration: BoxDecoration(boxShadow: [
                                                                                BoxShadow(
                                                                                  color: mTitleBlue.withOpacity(0.2),
                                                                                  spreadRadius: 5,
                                                                                  blurRadius: 5,
                                                                                  offset: Offset(0, 2),
                                                                                )
                                                                              ], color: mTitleBlue, borderRadius: BorderRadius.circular(10)),
                                                                              padding: EdgeInsets.all(8),
                                                                              child: Center(
                                                                                child: Text(
                                                                                  "Confirm",
                                                                                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
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
                                                        child: Container(
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
                                                              color:
                                                                  Colors.grey,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                          padding:
                                                              EdgeInsets.all(8),
                                                          child: Center(
                                                            child: Text(
                                                              "End Production",
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
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                  ],
                ),
              ),
              SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height - 100,
                  child: Column(
                    children: [
                      headInfo(context),
                      tableLoading(),
                      tableDowntime()
                    ],
                  )),
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
            top: 5),
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
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
                  width: 300,
                  padding: const EdgeInsets.only(left: 20, top: 3),
                  child: Text(
                    "DOWNTIME TABLE",
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
                        onTap: (resultListDevice.data != null
                                    ? resultListDevice.data != null
                                        ? resultListDevice.data!.prevPageUrl ??
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
                                      ? resultListDevice.data != null
                                          ? resultListDevice
                                                  .data!.prevPageUrl ??
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
                          "${resultListDevice.data != null ? resultListDevice.data != null ? resultListDevice.data!.currentPage.toString() : "" : ""}",
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
                                    ? resultListDevice.data != null
                                        ? resultListDevice.data!.nextPageUrl ??
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
                                      ? resultListDevice.data != null
                                          ? resultListDevice
                                                  .data!.nextPageUrl ??
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
                  width: 400,
                  margin: EdgeInsets.only(right: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () async {
                          showDialog(
                              barrierDismissible: true,
                              context: context,
                              builder: (BuildContext dialogcontext) {
                                List<reason.Reason> listReason =
                                    resultReason.data ?? [];
                                // String formattedDate =
                                //     formatter.format(selectedDate);
                                return StatefulBuilder(
                                  builder:
                                      (BuildContext dialogcontext, setState) =>
                                          AlertDialog(
                                    content: Container(
                                      height: 620,
                                      width:
                                          MediaQuery.of(context).size.width / 3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            child: Text(
                                              "Report Downtime",
                                              textAlign: TextAlign.start,
                                              style: GoogleFonts.poppins(
                                                  color: mDarkBlue,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 15,
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(bottom: 10),
                                            child: Text(
                                              "Reason",
                                              style: GoogleFonts.poppins(
                                                  fontSize: 10,
                                                  color: mTitleBlue,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Color.fromARGB(
                                                        250, 230, 230, 230),
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            // width: 150,
                                            child: CustomDropdown<dynamic>(
                                              hintText: "Select Reason",
                                              // initialItem: listReason[0].reason,
                                              items: listReason.length == 0
                                                  ? ["-"]
                                                  : listReason,
                                              initialItem:
                                                  listReason.length == 0
                                                      ? ["-"]
                                                      : listReason[0],
                                              decoration:
                                                  CustomDropdownDecoration(
                                                listItemStyle: TextStyle(
                                                  fontFamily: "Netflix",
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 11,
                                                  letterSpacing: 0.0,
                                                  color: Color.fromARGB(
                                                      255, 83, 83, 83),
                                                ),
                                                headerStyle: TextStyle(
                                                  fontFamily: "Netflix",
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 11,
                                                  letterSpacing: 0.0,
                                                  color: Color.fromARGB(
                                                      255, 83, 83, 83),
                                                ),
                                                hintStyle: TextStyle(
                                                  fontFamily: "Netflix",
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 11,
                                                  letterSpacing: 0.0,
                                                  color: Color.fromARGB(
                                                      255, 110, 110, 110),
                                                ),
                                              ),
                                              // initialItem: "Tomat",
                                              onChanged: (value) {
                                                setState(() {
                                                  log(value.id.toString());
                                                  idReason =
                                                      value.id.toString();
                                                });
                                              },
                                            ),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: report == 1
                                                      ? Color.fromARGB(
                                                              255, 54, 236, 30)
                                                          .withOpacity(0.7)
                                                      : Colors.grey
                                                          .withOpacity(0.4),
                                                  spreadRadius: 5,
                                                  blurRadius: 10,
                                                  offset: Offset(0, 2),
                                                )
                                              ],
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          bottom: 5),
                                                      child: Text(
                                                        "Downtime",
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontSize: 11,
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
                                                          report = 1;
                                                        });
                                                      },
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .grey
                                                                    .withOpacity(
                                                                        0.2),
                                                                spreadRadius: 5,
                                                                blurRadius: 5,
                                                                offset: Offset(
                                                                    0, 2),
                                                              )
                                                            ],
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    67,
                                                                    226,
                                                                    73),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30)),
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 2,
                                                                horizontal: 4),
                                                        child: Center(
                                                          child: Text(
                                                            "Select",
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        10),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                InputText(
                                                  icon: Icons.phone_rounded,
                                                  hint: "(Minutes)",
                                                  password: false,
                                                  controller:
                                                      downtimeController,
                                                  maxLine: 1,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter
                                                        .allow(RegExp(
                                                            r'^[0-9]*$')),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            // margin: EdgeInsets.only(bottom: 10),
                                            child: Text(
                                              "OR",
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.poppins(
                                                  fontSize: 11,
                                                  color: mTitleBlue,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: report == 0
                                                      ? Color.fromARGB(
                                                              255, 54, 236, 30)
                                                          .withOpacity(0.7)
                                                      : Colors.grey
                                                          .withOpacity(0.4),
                                                  spreadRadius: 5,
                                                  blurRadius: 10,
                                                  offset: Offset(0, 2),
                                                )
                                              ],
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          bottom: 5),
                                                      child: Text(
                                                        "Start",
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontSize: 11,
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
                                                          report = 0;
                                                        });
                                                      },
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .grey
                                                                    .withOpacity(
                                                                        0.2),
                                                                spreadRadius: 5,
                                                                blurRadius: 5,
                                                                offset: Offset(
                                                                    0, 2),
                                                              )
                                                            ],
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    67,
                                                                    226,
                                                                    73),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30)),
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 2,
                                                                horizontal: 4),
                                                        child: Center(
                                                          child: Text(
                                                            "Select",
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        11),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                InkWell(
                                                  onTap: () async {
                                                    _selectTime(dialogcontext)
                                                        .then((value) {
                                                      if (picked != null) {
                                                        setState(() {
                                                          selectedTime =
                                                              "${picked!.hour}:${picked!.minute}";
                                                        });
                                                      }
                                                    });
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color:
                                                                Color.fromARGB(
                                                                    250,
                                                                    230,
                                                                    230,
                                                                    230),
                                                            width: 1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    padding: EdgeInsets.only(
                                                        left: 20, right: 10),
                                                    child: Row(
                                                      children: <Widget>[
                                                        Expanded(
                                                          child: Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    bottom: 5,
                                                                    top: 5),
                                                            child: Text(
                                                              selectedTime != ""
                                                                  ? selectedTime
                                                                  : "Select Time",
                                                              style: GoogleFonts.poppins(
                                                                  fontSize: 14,
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          37,
                                                                          37,
                                                                          37),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            ),
                                                          ),
                                                        ),
                                                        Icon(
                                                          Icons.timer_outlined,
                                                          color: Colors.grey,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      bottom: 5),
                                                  child: Text(
                                                    "End",
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 11,
                                                        color: mTitleBlue,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () async {
                                                    _selectTimeEnd(
                                                            dialogcontext)
                                                        .then((value) {
                                                      if (pickedEnd != null) {
                                                        setState(() {
                                                          selectedTimeEnd =
                                                              "${pickedEnd!.hour}:${pickedEnd!.minute}";
                                                        });
                                                      }
                                                    });
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color:
                                                                Color.fromARGB(
                                                                    250,
                                                                    230,
                                                                    230,
                                                                    230),
                                                            width: 1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    padding: EdgeInsets.only(
                                                        left: 20, right: 10),
                                                    child: Row(
                                                      children: <Widget>[
                                                        Expanded(
                                                          child: Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    bottom: 5,
                                                                    top: 5),
                                                            child: Text(
                                                              selectedTimeEnd !=
                                                                      ""
                                                                  ? selectedTimeEnd
                                                                  : "Select Time",
                                                              style: GoogleFonts.poppins(
                                                                  fontSize: 14,
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          37,
                                                                          37,
                                                                          37),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            ),
                                                          ),
                                                        ),
                                                        Icon(
                                                          Icons.timer_outlined,
                                                          color: Colors.grey,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 25,
                                          ),
                                          InkWell(
                                            onTap: () async {
                                              if (_isLoading) {
                                                return;
                                              }
                                              Future.delayed(
                                                  const Duration(
                                                      milliseconds: 0), () {
                                                setState(() {
                                                  _isLoading = true;
                                                });
                                              });
                                              token = await storage.read(
                                                      key: "token") ??
                                                  "";

                                              if (report == 1) {
                                                if (downtimeController.text ==
                                                    "") {
                                                  setState(() {
                                                    _isLoading = false;
                                                  });
                                                  FancySnackbar.showSnackbar(
                                                    dialogcontext,
                                                    snackBarType:
                                                        FancySnackBarType.error,
                                                    title: "Failed!",
                                                    message:
                                                        "Downtime are required to be filled in!",
                                                    duration: 5,
                                                    onCloseEvent: () {},
                                                  );
                                                  return;
                                                }
                                              } else if (report == 0) {
                                                if (selectedTime == "" ||
                                                    selectedTimeEnd == "") {
                                                  setState(() {
                                                    _isLoading = false;
                                                  });
                                                  FancySnackbar.showSnackbar(
                                                    dialogcontext,
                                                    snackBarType:
                                                        FancySnackBarType.error,
                                                    title: "Failed!",
                                                    message:
                                                        "Start time and End time are required to be filled in!",
                                                    duration: 5,
                                                    onCloseEvent: () {},
                                                  );
                                                  return;
                                                } else {
                                                  DateTime dt =
                                                      new DateTime.now();
                                                  String formattedDate =
                                                      DateFormat('yyyy-MM-dd',
                                                              'id_ID')
                                                          .format(dt);
                                                  selectedTime = formattedDate +
                                                      " " +
                                                      selectedTime +
                                                      ":00";
                                                  selectedTimeEnd =
                                                      formattedDate +
                                                          " " +
                                                          selectedTimeEnd +
                                                          ":00";
                                                }
                                              }

                                              try {
                                                Future.delayed(
                                                    const Duration(
                                                        milliseconds: 0), () {
                                                  setState(() {
                                                    _isLoading = true;
                                                  });
                                                });
                                                PostDowntime.connectToApi(
                                                        token,
                                                        idReason,
                                                        downtimeController.text,
                                                        selectedTime,
                                                        selectedTimeEnd)
                                                    .then((value) {
                                                  setState(() {
                                                    Future.delayed(
                                                        const Duration(
                                                            milliseconds: 2000),
                                                        () {
                                                      setState(() {
                                                        _isLoading = false;
                                                      });
                                                    });
                                                    //print(storage.read(key: "token"));
                                                    if (value.status == 200) {
                                                      FancySnackbar
                                                          .showSnackbar(
                                                        dialogcontext,
                                                        snackBarType:
                                                            FancySnackBarType
                                                                .success,
                                                        title: "Successfully!",
                                                        message: value.message,
                                                        duration: 1,
                                                        onCloseEvent: () {
                                                          setState(() {
                                                            _isLoading = false;
                                                          });
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
                                                    } else {
                                                      setState(() {
                                                        _isLoading = false;
                                                      });
                                                      FancySnackbar
                                                          .showSnackbar(
                                                        dialogcontext,
                                                        snackBarType:
                                                            FancySnackBarType
                                                                .error,
                                                        title: "Failed!",
                                                        message: value.message,
                                                        duration: 5,
                                                        onCloseEvent: () {},
                                                      );
                                                    }
                                                  });
                                                });
                                              } catch (x) {
                                                Future.delayed(
                                                    const Duration(
                                                        milliseconds: 2000),
                                                    () {
                                                  setState(() {
                                                    _isLoading = false;
                                                  });
                                                });
                                              }
                                            },
                                            child: Container(
                                              // margin: EdgeInsets.only(right: 15),
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
                                                  color: _isLoading
                                                      ? const Color.fromARGB(
                                                          255, 179, 179, 179)
                                                      : mBlueColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 5, horizontal: 10),
                                              child: Center(
                                                child: _isLoading
                                                    ? Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Lottie.asset(
                                                              'assets/json/loadingBlue.json',
                                                              width: 25),
                                                          Text(
                                                            "  Loading ...",
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        16),
                                                          ),
                                                        ],
                                                      )
                                                    : Text(
                                                        "REPORT",
                                                        style:
                                                            GoogleFonts.poppins(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 16),
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
                        child: Container(
                          margin: EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 5,
                                  blurRadius: 5,
                                  offset: Offset(0, 2),
                                )
                              ],
                              color: mBlueColor,
                              borderRadius: BorderRadius.circular(30)),
                          padding:
                              EdgeInsets.symmetric(vertical: 4, horizontal: 7),
                          child: Center(
                            child: Text(
                              "Report Downtime",
                              style: GoogleFonts.poppins(
                                  color: Colors.white, fontSize: 11),
                            ),
                          ),
                        ),
                      ),
                      Container(
                          width: 150,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F7FE),
                            borderRadius: BorderRadius.circular(40),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromARGB(148, 244, 247, 254),
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
                                width: 149,
                                controller: controllerCari,
                                nama: "search",
                                onclick: () {
                                  _getDowntime(true);
                                },
                                icons: Icons.search,
                              ),
                              // Row(
                              //   children: [
                              //     Icon(
                              //       Icons.print,
                              //       color: mBlueColor,
                              //       size: 30,
                              //     ),
                              //     SizedBox(
                              //       width: 10,
                              //     ),
                              //     Icon(
                              //       Icons.download_for_offline_rounded,
                              //       color: mBlueColor,
                              //       size: 30,
                              //     ),
                              //     SizedBox(
                              //       width: 10,
                              //     ),
                              //   ],
                              // ),
                            ],
                          )),
                    ],
                  ),
                ),
              ],
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
                          fontSize: 9,
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
                          fontSize: 9,
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
                          fontSize: 9,
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
                          fontSize: 9,
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
                          fontSize: 9,
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
                          fontSize: 9,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 2,
            ),
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
                            ? (resultListDevice.data != null
                                ? resultListDevice.data!.data.length
                                : 0)
                            : 0, (index) {
                      final item = resultListDevice.data!.data[index];
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
                                resultListDevice.data!.currentPage == null
                                    ? "0"
                                    : (((resultListDevice.data!.currentPage! -
                                                    1) *
                                                10) +
                                            (index + 1))
                                        .toString(),
                                textAlign: TextAlign.start,
                                style: GoogleFonts.poppins(
                                    color: mDarkBlue,
                                    fontSize: 9,
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
                                    fontSize: 9,
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
                                    fontSize: 9,
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
                                    fontSize: 9,
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
                                    fontSize: 9,
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
                                    fontSize: 9,
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

  Expanded tableLoading() {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(
            left: windowWidth < 1400 ? 10 : 20,
            right: windowWidth < 1400 ? 10 : 20,
            top: windowWidth < 1400 ? 10 : 20),
        padding: EdgeInsets.symmetric(vertical: 3, horizontal: 3),
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
                  width: 300,
                  padding: EdgeInsets.only(left: 20, top: 5),
                  child: Text(
                    "PART ON TOPCOAT",
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
                        onTap: (resultListLoading.data != null
                                    ? resultListLoading.data!.prevPageUrl ?? ""
                                    : "") !=
                                ""
                            ? () => setState(() => _prevPage())
                            : null,
                        child: Icon(
                          Icons.arrow_back_ios_rounded,
                          size: 10,
                          color: (resultListLoading.data != null
                                      ? resultListLoading.data!.prevPageUrl ??
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
                          "${resultListLoading.data != null ? resultListLoading.data!.currentPage.toString() : ""}",
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
                        onTap: (resultListLoading.data != null
                                    ? resultListLoading.data!.nextPageUrl ?? ""
                                    : "") !=
                                ""
                            ? () => setState(() => _nextPage())
                            : null,
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 10,
                          color: (resultListLoading.data != null
                                      ? resultListLoading.data!.nextPageUrl ??
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
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Color.fromARGB(250, 230, 230, 230),
                            width: 1),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF4F7FE),
                            spreadRadius: 3,
                            blurRadius: 3,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      width: 200,
                      child: CustomDropdown<String>(
                        hintText: "Filter",
                        initialItem: "All",
                        items: [
                          "All",
                          "700P/FS",
                          "700P/NS",
                          "Rear Body",
                          "Spareparts",
                          "VT/P",
                          "Rak Bumper",
                          "Rak Fender",
                          "Rak Door"
                        ],
                        decoration: CustomDropdownDecoration(
                          listItemStyle: TextStyle(
                            fontFamily: "Netflix",
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            letterSpacing: 0.0,
                            color: Color.fromARGB(255, 83, 83, 83),
                          ),
                          headerStyle: TextStyle(
                            fontFamily: "Netflix",
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            letterSpacing: 0.0,
                            color: Color.fromARGB(255, 83, 83, 83),
                          ),
                          hintStyle: TextStyle(
                            fontFamily: "Netflix",
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            letterSpacing: 0.0,
                            color: Color.fromARGB(255, 110, 110, 110),
                          ),
                        ),
                        // initialItem: "Tomat",
                        onChanged: (value) {
                          _getLoading(true, value);
                        },
                      ),
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
                              controller: controllerSearchLoading,
                              nama: "search",
                              onclick: () {
                                _getLoading(true, null);
                              },
                              icons: Icons.search,
                            ),
                          ],
                        )),
                  ],
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
                          fontSize: 9,
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
                          fontSize: 9,
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
                          fontSize: 9,
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
                          fontSize: 9,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  // Container(
                  //   width: windowWidth / 8,
                  //   child: Text(
                  //     "Time",
                  //     textAlign: TextAlign.center,
                  //     style: GoogleFonts.poppins(
                  //         color: Colors.grey,
                  //         fontSize: 9,
                  //         fontWeight: FontWeight.w500),
                  //   ),
                  // ),
                  Container(
                    width: windowWidth / 4,
                    child: Text(
                      "Status Quality Update",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 9,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 2,
            ),
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
                        resultListLoading.data != null
                            ? (resultListLoading.data!.data != null
                                ? resultListLoading.data!.data!.length
                                : 0)
                            : 0, (index) {
                      final item = resultListLoading.data!.data![index];
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
                                (((resultListLoading.data!.currentPage! - 1) *
                                            5) +
                                        (index + 1))
                                    .toString(),
                                textAlign: TextAlign.start,
                                style: GoogleFonts.poppins(
                                    color: mDarkBlue,
                                    fontSize: 9,
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
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            Container(
                              width: windowWidth / 7,
                              child: Text(
                                item.bodyId,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                    color: mDarkBlue,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            Container(
                              width: windowWidth / 8,
                              child: Text(
                                item.bodyType,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                    color: mDarkBlue,
                                    fontSize: 9,
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
                              width: windowWidth / 4,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      // showDialog(
                                      //     barrierDismissible: true,
                                      //     context: context,
                                      //     builder: (dialogcontext) {
                                      //       return AlertDialog(
                                      //           content: Column(
                                      //         mainAxisSize: MainAxisSize.min,
                                      //         crossAxisAlignment:
                                      //             CrossAxisAlignment.center,
                                      //         children: [
                                      //           // Lottie.asset(
                                      //           //     'assets/json/loadingBlue.json',
                                      //           //     height: 100,
                                      //           //     width: 100),
                                      //           SizedBox(
                                      //             height: 20,
                                      //           ),
                                      //           Text(
                                      //             'Are you sure you will save status?',
                                      //             style: GoogleFonts.inter(
                                      //                 fontWeight:
                                      //                     FontWeight.w700,
                                      //                 fontSize: 17,
                                      //                 color: Color.fromARGB(
                                      //                     255, 75, 75, 75)),
                                      //           ),
                                      //           SizedBox(
                                      //             height: 50,
                                      //           ),
                                      //           Row(
                                      //             children: [
                                      //               Expanded(
                                      //                 child: InkWell(
                                      //                   onTap: () async {
                                      //                     Navigator.pop(
                                      //                         dialogcontext);
                                      //                   },
                                      //                   child: Container(
                                      //                     decoration: BoxDecoration(
                                      //                         boxShadow: [
                                      //                           BoxShadow(
                                      //                             color: Colors
                                      //                                 .grey
                                      //                                 .withOpacity(
                                      //                                     0.2),
                                      //                             spreadRadius:
                                      //                                 5,
                                      //                             blurRadius: 5,
                                      //                             offset:
                                      //                                 Offset(
                                      //                                     0, 2),
                                      //                           )
                                      //                         ],
                                      //                         color: Color
                                      //                             .fromARGB(
                                      //                                 255,
                                      //                                 107,
                                      //                                 107,
                                      //                                 107),
                                      //                         borderRadius:
                                      //                             BorderRadius
                                      //                                 .circular(
                                      //                                     10)),
                                      //                     padding:
                                      //                         EdgeInsets.all(8),
                                      //                     child: Center(
                                      //                       child: Text(
                                      //                         "Cancel",
                                      //                         style: GoogleFonts
                                      //                             .poppins(
                                      //                                 color: Colors
                                      //                                     .white,
                                      //                                 fontSize:
                                      //                                     16),
                                      //                       ),
                                      //                     ),
                                      //                   ),
                                      //                 ),
                                      //               ),
                                      //               SizedBox(
                                      //                 width: 20,
                                      //               ),
                                      //               Expanded(
                                      //                 child: InkWell(
                                      //                   onTap: () async {
                                      //                     try {
                                      //                       token = await storage
                                      //                               .read(
                                      //                                   key:
                                      //                                       "token") ??
                                      //                           "";
                                      //                       log("To " + token);
                                      //                       Future.delayed(
                                      //                           const Duration(
                                      //                               milliseconds:
                                      //                                   0), () {
                                      //                         setState(() {
                                      //                           _isLoading =
                                      //                               true;
                                      //                         });
                                      //                       });
                                      //                       PostOkNg.connectToApi(
                                      //                               token,
                                      //                               item.bodyId,
                                      //                               "ok")
                                      //                           .then((value) {
                                      //                         setState(() {
                                      //                           Future.delayed(
                                      //                               const Duration(
                                      //                                   milliseconds:
                                      //                                       2000),
                                      //                               () {
                                      //                             setState(() {
                                      //                               _isLoading =
                                      //                                   false;
                                      //                             });
                                      //                           });
                                      //                           //print(storage.read(key: "token"));
                                      //                           if (value
                                      //                                   .status ==
                                      //                               200) {
                                      //                             item.status =
                                      //                                 "ok";
                                      //                             _getItem();
                                      //                             FancySnackbar
                                      //                                 .showSnackbar(
                                      //                               context,
                                      //                               snackBarType:
                                      //                                   FancySnackBarType
                                      //                                       .success,
                                      //                               title:
                                      //                                   "Successfully!",
                                      //                               message: value
                                      //                                   .message,
                                      //                               duration: 1,
                                      //                               onCloseEvent:
                                      //                                   () {},
                                      //                             );
                                      //                             setState(
                                      //                                 () {});
                                      //                             Navigator.pop(
                                      //                                 dialogcontext);
                                      //                           } else {
                                      //                             FancySnackbar
                                      //                                 .showSnackbar(
                                      //                               context,
                                      //                               snackBarType:
                                      //                                   FancySnackBarType
                                      //                                       .error,
                                      //                               title:
                                      //                                   "Failed!",
                                      //                               message: value
                                      //                                   .message,
                                      //                               duration: 5,
                                      //                               onCloseEvent:
                                      //                                   () {},
                                      //                             );
                                      //                             setState(
                                      //                                 () {});
                                      //                           }
                                      //                         });
                                      //                       });
                                      //                     } catch (x) {
                                      //                       Future.delayed(
                                      //                           const Duration(
                                      //                               milliseconds:
                                      //                                   2000),
                                      //                           () {
                                      //                         setState(() {
                                      //                           _isLoading =
                                      //                               false;
                                      //                           setState(() {});
                                      //                           Navigator.pop(
                                      //                               dialogcontext);
                                      //                         });
                                      //                       });
                                      //                     }
                                      //                   },
                                      //                   child: Container(
                                      //                     decoration: BoxDecoration(
                                      //                         boxShadow: [
                                      //                           BoxShadow(
                                      //                             color: mTitleBlue
                                      //                                 .withOpacity(
                                      //                                     0.2),
                                      //                             spreadRadius:
                                      //                                 5,
                                      //                             blurRadius: 5,
                                      //                             offset:
                                      //                                 Offset(
                                      //                                     0, 2),
                                      //                           )
                                      //                         ],
                                      //                         color: mTitleBlue,
                                      //                         borderRadius:
                                      //                             BorderRadius
                                      //                                 .circular(
                                      //                                     10)),
                                      //                     padding:
                                      //                         EdgeInsets.all(8),
                                      //                     child: Center(
                                      //                       child: Text(
                                      //                         "Save",
                                      //                         style: GoogleFonts
                                      //                             .poppins(
                                      //                                 color: Colors
                                      //                                     .white,
                                      //                                 fontSize:
                                      //                                     16),
                                      //                       ),
                                      //                     ),
                                      //                   ),
                                      //                 ),
                                      //               ),
                                      //             ],
                                      //           ),
                                      //         ],
                                      //       ));
                                      //     });
                                      // disableWindowResize();
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 2, horizontal: 4),
                                      decoration: BoxDecoration(
                                          color: item.status == "ok"
                                              ? Color.fromARGB(
                                                  255, 129, 218, 88)
                                              : const Color.fromARGB(
                                                  255, 202, 202, 202),
                                          borderRadius:
                                              BorderRadius.circular(4)),
                                      child: Text(
                                        "OK",
                                        textAlign: TextAlign.start,
                                        style: GoogleFonts.poppins(
                                            color: const Color.fromARGB(
                                                255, 44, 44, 44),
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      // showDialog(
                                      //     barrierDismissible: true,
                                      //     context: context,
                                      //     builder: (dialogcontext) {
                                      //       return AlertDialog(
                                      //           content: Column(
                                      //         mainAxisSize: MainAxisSize.min,
                                      //         crossAxisAlignment:
                                      //             CrossAxisAlignment.center,
                                      //         children: [
                                      //           // Lottie.asset(
                                      //           //     'assets/json/loadingBlue.json',
                                      //           //     height: 100,
                                      //           //     width: 100),
                                      //           SizedBox(
                                      //             height: 20,
                                      //           ),
                                      //           Text(
                                      //             'Are you sure you will save status?',
                                      //             style: GoogleFonts.inter(
                                      //                 fontWeight:
                                      //                     FontWeight.w700,
                                      //                 fontSize: 17,
                                      //                 color: Color.fromARGB(
                                      //                     255, 75, 75, 75)),
                                      //           ),
                                      //           SizedBox(
                                      //             height: 50,
                                      //           ),
                                      //           Row(
                                      //             children: [
                                      //               Expanded(
                                      //                 child: InkWell(
                                      //                   onTap: () async {
                                      //                     Navigator.pop(
                                      //                         dialogcontext);
                                      //                   },
                                      //                   child: Container(
                                      //                     decoration: BoxDecoration(
                                      //                         boxShadow: [
                                      //                           BoxShadow(
                                      //                             color: Colors
                                      //                                 .grey
                                      //                                 .withOpacity(
                                      //                                     0.2),
                                      //                             spreadRadius:
                                      //                                 5,
                                      //                             blurRadius: 5,
                                      //                             offset:
                                      //                                 Offset(
                                      //                                     0, 2),
                                      //                           )
                                      //                         ],
                                      //                         color: Color
                                      //                             .fromARGB(
                                      //                                 255,
                                      //                                 107,
                                      //                                 107,
                                      //                                 107),
                                      //                         borderRadius:
                                      //                             BorderRadius
                                      //                                 .circular(
                                      //                                     10)),
                                      //                     padding:
                                      //                         EdgeInsets.all(8),
                                      //                     child: Center(
                                      //                       child: Text(
                                      //                         "Cancel",
                                      //                         style: GoogleFonts
                                      //                             .poppins(
                                      //                                 color: Colors
                                      //                                     .white,
                                      //                                 fontSize:
                                      //                                     16),
                                      //                       ),
                                      //                     ),
                                      //                   ),
                                      //                 ),
                                      //               ),
                                      //               SizedBox(
                                      //                 width: 20,
                                      //               ),
                                      //               Expanded(
                                      //                 child: InkWell(
                                      //                   onTap: () async {
                                      //                     try {
                                      //                       token = await storage
                                      //                               .read(
                                      //                                   key:
                                      //                                       "token") ??
                                      //                           "";
                                      //                       log("To " + token);
                                      //                       Future.delayed(
                                      //                           const Duration(
                                      //                               milliseconds:
                                      //                                   0), () {
                                      //                         setState(() {
                                      //                           _isLoading =
                                      //                               true;
                                      //                         });
                                      //                       });
                                      //                       PostOkNg.connectToApi(
                                      //                               token,
                                      //                               item.bodyId,
                                      //                               "ng")
                                      //                           .then((value) {
                                      //                         setState(() {
                                      //                           Future.delayed(
                                      //                               const Duration(
                                      //                                   milliseconds:
                                      //                                       2000),
                                      //                               () {
                                      //                             setState(() {
                                      //                               _isLoading =
                                      //                                   false;
                                      //                             });
                                      //                           });
                                      //                           //print(storage.read(key: "token"));
                                      //                           if (value
                                      //                                   .status ==
                                      //                               200) {
                                      //                             item.status =
                                      //                                 "ng";
                                      //                             _getItem();
                                      //                             FancySnackbar
                                      //                                 .showSnackbar(
                                      //                               context,
                                      //                               snackBarType:
                                      //                                   FancySnackBarType
                                      //                                       .success,
                                      //                               title:
                                      //                                   "Successfully!",
                                      //                               message: value
                                      //                                   .message,
                                      //                               duration: 1,
                                      //                               onCloseEvent:
                                      //                                   () {},
                                      //                             );
                                      //                             setState(
                                      //                                 () {});
                                      //                             Navigator.pop(
                                      //                                 dialogcontext);
                                      //                           } else {
                                      //                             FancySnackbar
                                      //                                 .showSnackbar(
                                      //                               context,
                                      //                               snackBarType:
                                      //                                   FancySnackBarType
                                      //                                       .error,
                                      //                               title:
                                      //                                   "Failed!",
                                      //                               message: value
                                      //                                   .message,
                                      //                               duration: 5,
                                      //                               onCloseEvent:
                                      //                                   () {},
                                      //                             );
                                      //                             setState(
                                      //                                 () {});
                                      //                           }
                                      //                         });
                                      //                       });
                                      //                     } catch (x) {
                                      //                       Future.delayed(
                                      //                           const Duration(
                                      //                               milliseconds:
                                      //                                   2000),
                                      //                           () {
                                      //                         setState(() {
                                      //                           _isLoading =
                                      //                               false;
                                      //                           setState(() {});
                                      //                           Navigator.pop(
                                      //                               dialogcontext);
                                      //                         });
                                      //                       });
                                      //                     }
                                      //                   },
                                      //                   child: Container(
                                      //                     decoration: BoxDecoration(
                                      //                         boxShadow: [
                                      //                           BoxShadow(
                                      //                             color: mTitleBlue
                                      //                                 .withOpacity(
                                      //                                     0.2),
                                      //                             spreadRadius:
                                      //                                 5,
                                      //                             blurRadius: 5,
                                      //                             offset:
                                      //                                 Offset(
                                      //                                     0, 2),
                                      //                           )
                                      //                         ],
                                      //                         color: mTitleBlue,
                                      //                         borderRadius:
                                      //                             BorderRadius
                                      //                                 .circular(
                                      //                                     10)),
                                      //                     padding:
                                      //                         EdgeInsets.all(8),
                                      //                     child: Center(
                                      //                       child: Text(
                                      //                         "Save",
                                      //                         style: GoogleFonts
                                      //                             .poppins(
                                      //                                 color: Colors
                                      //                                     .white,
                                      //                                 fontSize:
                                      //                                     16),
                                      //                       ),
                                      //                     ),
                                      //                   ),
                                      //                 ),
                                      //               ),
                                      //             ],
                                      //           ),
                                      //         ],
                                      //       ));
                                      //     });
                                      // disableWindowResize();
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 2, horizontal: 4),
                                      decoration: BoxDecoration(
                                          color: item.status == "repair"
                                              ? Colors.amber
                                              : const Color.fromARGB(
                                                  255, 202, 202, 202),
                                          borderRadius:
                                              BorderRadius.circular(4)),
                                      child: Text(
                                        "REPAIR",
                                        textAlign: TextAlign.start,
                                        style: GoogleFonts.poppins(
                                            color: const Color.fromARGB(
                                                255, 46, 46, 46),
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  InkWell(
                                    onTap: () async {
                                      bodyController.text = item.bodyId;
                                      selectedBody = item.bodyType;
                                      showDialog(
                                          barrierDismissible: true,
                                          context: context,
                                          builder:
                                              (BuildContext dialogcontext) {
                                            String formattedDate =
                                                formatter.format(selectedDate);
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
                                                          "Edit",
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
                                                            top: 10),
                                                        child: Text(
                                                          "No Body",
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  fontSize: 10,
                                                                  color:
                                                                      mTitleBlue,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                        ),
                                                      ),
                                                      InputText(
                                                        icon:
                                                            Icons.phone_rounded,
                                                        hint: "No Body",
                                                        password: false,
                                                        controller:
                                                            bodyController,
                                                        maxLine: 1,
                                                      ),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      Container(
                                                        margin: EdgeInsets.only(
                                                            bottom: 5),
                                                        child: Text(
                                                          "Body Type",
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  fontSize: 10,
                                                                  color:
                                                                      mTitleBlue,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                        ),
                                                      ),
                                                      Container(
                                                        padding:
                                                            EdgeInsets.all(2),
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                                color: Color
                                                                    .fromARGB(
                                                                        250,
                                                                        230,
                                                                        230,
                                                                        230),
                                                                width: 1),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                        // width: 150,
                                                        child: CustomDropdown<
                                                            String>(
                                                          hintText: "Body Type",
                                                          initialItem:
                                                              "700P/FS",
                                                          items: [
                                                            "700P/FS",
                                                            "700P/NS",
                                                            "Rear Body",
                                                            "Spareparts",
                                                            "VT/P"
                                                          ],
                                                          decoration:
                                                              CustomDropdownDecoration(
                                                            listItemStyle:
                                                                TextStyle(
                                                              fontFamily:
                                                                  "Netflix",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 14,
                                                              letterSpacing:
                                                                  0.0,
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      83,
                                                                      83,
                                                                      83),
                                                            ),
                                                            headerStyle:
                                                                TextStyle(
                                                              fontFamily:
                                                                  "Netflix",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 14,
                                                              letterSpacing:
                                                                  0.0,
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      83,
                                                                      83,
                                                                      83),
                                                            ),
                                                            hintStyle:
                                                                TextStyle(
                                                              fontFamily:
                                                                  "Netflix",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 14,
                                                              letterSpacing:
                                                                  0.0,
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      110,
                                                                      110,
                                                                      110),
                                                            ),
                                                          ),
                                                          // initialItem: "Tomat",
                                                          onChanged: (value) {
                                                            setState(() {
                                                              selectedBody =
                                                                  value;
                                                            });
                                                          },
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

                                                          // if (bodyController
                                                          //             .text ==
                                                          //         "" ||
                                                          //     operatorController
                                                          //             .text ==
                                                          //         "") {
                                                          //   setState(() {
                                                          //     _isLoading =
                                                          //         false;
                                                          //   });
                                                          //   FancySnackbar
                                                          //       .showSnackbar(
                                                          //     dialogcontext,
                                                          //     snackBarType:
                                                          //         FancySnackBarType
                                                          //             .error,
                                                          //     title: "Failed!",
                                                          //     message:
                                                          //         "all columns are required to be filled in!",
                                                          //     duration: 5,
                                                          //     onCloseEvent:
                                                          //         () {},
                                                          //   );
                                                          //   return;
                                                          // }

                                                          try {
                                                            Future.delayed(
                                                                const Duration(
                                                                    milliseconds:
                                                                        0), () {
                                                              setState(() {
                                                                _isLoading =
                                                                    true;
                                                              });
                                                            });
                                                            EditLoadingData.connectToApi(
                                                                    token,
                                                                    bodyController
                                                                        .text,
                                                                    selectedBody,
                                                                    item.id
                                                                        .toString())
                                                                .then((value) {
                                                              setState(() {
                                                                Future.delayed(
                                                                    const Duration(
                                                                        milliseconds:
                                                                            500),
                                                                    () {
                                                                  setState(() {
                                                                    _isLoading =
                                                                        false;
                                                                  });
                                                                });
                                                                //print(storage.read(key: "token"));
                                                                if (value
                                                                        .status ==
                                                                    200) {
                                                                  FancySnackbar
                                                                      .showSnackbar(
                                                                    dialogcontext,
                                                                    snackBarType:
                                                                        FancySnackBarType
                                                                            .success,
                                                                    title:
                                                                        "Successfully!",
                                                                    message: value
                                                                        .message,
                                                                    duration: 1,
                                                                    onCloseEvent:
                                                                        () {
                                                                      setState(
                                                                          () {
                                                                        _isLoading =
                                                                            false;
                                                                      });
                                                                      Navigator.pop(
                                                                          dialogcontext);
                                                                      _getShift();
                                                                      _getOperationTime();
                                                                      _getItem();
                                                                      // Navigator.pushReplacement(context,
                                                                      //     MaterialPageRoute(builder: (context) {
                                                                      //   return NavigateScreen(
                                                                      //     id: 1,
                                                                      //   );
                                                                      // }));
                                                                    },
                                                                  );
                                                                } else {
                                                                  setState(() {
                                                                    _isLoading =
                                                                        false;
                                                                  });
                                                                  FancySnackbar
                                                                      .showSnackbar(
                                                                    dialogcontext,
                                                                    snackBarType:
                                                                        FancySnackBarType
                                                                            .error,
                                                                    title:
                                                                        "Failed!",
                                                                    message: value
                                                                        .message,
                                                                    duration: 5,
                                                                    onCloseEvent:
                                                                        () {},
                                                                  );
                                                                }
                                                              });
                                                            });
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
                                                            child: _isLoading
                                                                ? Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Lottie.asset(
                                                                          'assets/json/loadingBlue.json',
                                                                          width:
                                                                              25),
                                                                      Text(
                                                                        "  Loading ...",
                                                                        style: GoogleFonts.poppins(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize: 16),
                                                                      ),
                                                                    ],
                                                                  )
                                                                : Text(
                                                                    "Save",
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
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: windowWidth < 1400 ? 3 : 6,
                                          horizontal:
                                              windowWidth < 1400 ? 3 : 5),
                                      decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                              255, 202, 202, 202),
                                          borderRadius:
                                              BorderRadius.circular(7)),
                                      child: Icon(
                                        Icons.edit,
                                        size: 18,
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
              ),
            )),
          ],
        ),
      ),
    );
  }

  // Row headInfo(BuildContext context) {
  //   return Row(
  //     children: [
  //       Expanded(
  //         child: Container(
  //           margin:
  //               EdgeInsets.only(left: windowWidth < 1400 ? 10 : 20, right: 4),
  //           padding: windowWidth < 1400
  //               ? EdgeInsets.symmetric(vertical: 10, horizontal: 10)
  //               : EdgeInsets.symmetric(vertical: 20, horizontal: 20),
  //           decoration: BoxDecoration(
  //               // boxShadow: [
  //               //   BoxShadow(
  //               //     color:
  //               //         const Color.fromARGB(255, 214, 214, 214)
  //               //             .withOpacity(0.1),
  //               //     spreadRadius: 5,
  //               //     blurRadius: 5,
  //               //     offset: Offset(0, 2),
  //               //   )
  //               // ],
  //               color: Colors.white,
  //               borderRadius: BorderRadius.circular(10)),
  //           child: Row(
  //             children: [
  //               Container(
  //                 padding: EdgeInsets.all(5),
  //                 decoration: BoxDecoration(
  //                     gradient: LinearGradient(
  //                         begin: Alignment.topLeft,
  //                         end: Alignment.bottomRight,
  //                         colors: <Color>[
  //                           Color.fromARGB(255, 1, 121, 219),
  //                           Color.fromARGB(255, 95, 183, 255)
  //                         ]),
  //                     // color: mDarkBlue.withOpacity(0.1),
  //                     borderRadius: BorderRadius.circular(50)),
  //                 child: Icon(
  //                   Icons.date_range_rounded,
  //                   color: Colors.white,
  //                   size: 15,
  //                 ),
  //               ),
  //               SizedBox(
  //                 width: 10,
  //               ),
  //               Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     "Date",
  //                     textAlign: TextAlign.center,
  //                     style: GoogleFonts.poppins(
  //                         color: mDarkBlue.withOpacity(0.5),
  //                         fontSize: 9,
  //                         fontWeight: FontWeight.w600),
  //                   ),
  //                   Text(
  //                     (dashboardResult.data != null
  //                             ? dashboardResult.data!.date
  //                             : "")
  //                         .toString(),
  //                     textAlign: TextAlign.center,
  //                     style: GoogleFonts.poppins(
  //                         color: mDarkBlue,
  //                         fontSize: 11,
  //                         fontWeight: FontWeight.w600),
  //                   )
  //                 ],
  //               )
  //             ],
  //           ),
  //         ),
  //       ),
  //       Expanded(
  //         child: Container(
  //           margin: EdgeInsets.only(left: 4, right: 4),
  //           padding: windowWidth < 1400
  //               ? EdgeInsets.symmetric(vertical: 10, horizontal: 10)
  //               : EdgeInsets.symmetric(vertical: 20, horizontal: 20),
  //           decoration: BoxDecoration(
  //               // boxShadow: [
  //               //   BoxShadow(
  //               //     color:
  //               //         const Color.fromARGB(255, 214, 214, 214)
  //               //             .withOpacity(0.1),
  //               //     spreadRadius: 5,
  //               //     blurRadius: 5,
  //               //     offset: Offset(0, 2),
  //               //   )
  //               // ],
  //               color: Colors.white,
  //               borderRadius: BorderRadius.circular(10)),
  //           child: Row(
  //             children: [
  //               Container(
  //                 padding: EdgeInsets.all(5),
  //                 decoration: BoxDecoration(
  //                     color: mDarkBlue.withOpacity(0.1),
  //                     borderRadius: BorderRadius.circular(50)),
  //                 child: Icon(
  //                   Icons.file_copy,
  //                   color: mBlueColor,
  //                   size: 15,
  //                 ),
  //               ),
  //               SizedBox(
  //                 width: 10,
  //               ),
  //               Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     "Shift",
  //                     textAlign: TextAlign.center,
  //                     style: GoogleFonts.poppins(
  //                         color: mDarkBlue.withOpacity(0.5),
  //                         fontSize: 9,
  //                         fontWeight: FontWeight.w600),
  //                   ),
  //                   Text(
  //                     dashboardResult.data != null
  //                         ? dashboardResult.data!.shift.name
  //                         : "",
  //                     textAlign: TextAlign.center,
  //                     style: GoogleFonts.poppins(
  //                         color: mDarkBlue,
  //                         fontSize: 11,
  //                         fontWeight: FontWeight.w600),
  //                   )
  //                 ],
  //               )
  //             ],
  //           ),
  //         ),
  //       ),
  //       Expanded(
  //         child: Container(
  //           margin: EdgeInsets.only(left: 4, right: 4),
  //           padding: windowWidth < 1400
  //               ? EdgeInsets.symmetric(vertical: 10, horizontal: 10)
  //               : EdgeInsets.symmetric(vertical: 20, horizontal: 20),
  //           decoration: BoxDecoration(
  //               // boxShadow: [
  //               //   BoxShadow(
  //               //     color:
  //               //         const Color.fromARGB(255, 214, 214, 214)
  //               //             .withOpacity(0.1),
  //               //     spreadRadius: 5,
  //               //     blurRadius: 5,
  //               //     offset: Offset(0, 2),
  //               //   )
  //               // ],
  //               color: Colors.white,
  //               borderRadius: BorderRadius.circular(10)),
  //           child: Row(
  //             children: [
  //               Container(
  //                 padding: EdgeInsets.all(5),
  //                 decoration: BoxDecoration(
  //                     color: mDarkBlue.withOpacity(0.1),
  //                     borderRadius: BorderRadius.circular(50)),
  //                 child: Icon(
  //                   Icons.file_copy,
  //                   color: mBlueColor,
  //                   size: 15,
  //                 ),
  //               ),
  //               SizedBox(
  //                 width: 10,
  //               ),
  //               Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     "Planaa",
  //                     textAlign: TextAlign.center,
  //                     style: GoogleFonts.poppins(
  //                         color: mDarkBlue.withOpacity(0.5),
  //                         fontSize: 9,
  //                         fontWeight: FontWeight.w600),
  //                   ),
  //                   Text(
  //                     dashboardResult.data != null
  //                         ? dashboardResult.data!.planWos.toString()
  //                         : "",
  //                     textAlign: TextAlign.center,
  //                     style: GoogleFonts.poppins(
  //                         color: mDarkBlue,
  //                         fontSize: 11,
  //                         fontWeight: FontWeight.w600),
  //                   )
  //                 ],
  //               )
  //             ],
  //           ),
  //         ),
  //       ),
  //       Expanded(
  //         child: Container(
  //           margin: EdgeInsets.only(left: 4, right: 4),
  //           padding: windowWidth < 1400
  //               ? EdgeInsets.symmetric(vertical: 10, horizontal: 10)
  //               : EdgeInsets.symmetric(vertical: 20, horizontal: 20),
  //           decoration: BoxDecoration(
  //               // boxShadow: [
  //               //   BoxShadow(
  //               //     color:
  //               //         const Color.fromARGB(255, 214, 214, 214)
  //               //             .withOpacity(0.1),
  //               //     spreadRadius: 5,
  //               //     blurRadius: 5,
  //               //     offset: Offset(0, 2),
  //               //   )
  //               // ],
  //               color: Colors.white,
  //               borderRadius: BorderRadius.circular(10)),
  //           child: Row(
  //             children: [
  //               Container(
  //                 padding: EdgeInsets.all(5),
  //                 decoration: BoxDecoration(
  //                     color: mDarkBlue.withOpacity(0.1),
  //                     borderRadius: BorderRadius.circular(50)),
  //                 child: Icon(
  //                   Icons.file_copy,
  //                   color: mBlueColor,
  //                   size: 15,
  //                 ),
  //               ),
  //               SizedBox(
  //                 width: 10,
  //               ),
  //               Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     "Plan",
  //                     textAlign: TextAlign.center,
  //                     style: GoogleFonts.poppins(
  //                         color: mDarkBlue.withOpacity(0.5),
  //                         fontSize: 9,
  //                         fontWeight: FontWeight.w600),
  //                   ),
  //                   Text(
  //                     dashboardResult.data != null
  //                         ? dashboardResult.data!.planWos.toString()
  //                         : "",
  //                     textAlign: TextAlign.center,
  //                     style: GoogleFonts.poppins(
  //                         color: mDarkBlue,
  //                         fontSize: 11,
  //                         fontWeight: FontWeight.w600),
  //                   )
  //                 ],
  //               )
  //             ],
  //           ),
  //         ),
  //       ),
  //       Expanded(
  //         child: Container(
  //           margin: EdgeInsets.only(left: 4, right: 10),
  //           decoration: BoxDecoration(
  //               // boxShadow: [
  //               //   BoxShadow(
  //               //     color:
  //               //         const Color.fromARGB(255, 214, 214, 214)
  //               //             .withOpacity(0.1),
  //               //     spreadRadius: 5,
  //               //     blurRadius: 5,
  //               //     offset: Offset(0, 2),
  //               //   )
  //               // ],
  //               color: Colors.white,
  //               borderRadius: BorderRadius.circular(10)),
  //           child: Row(
  //             children: [
  //               // Container(
  //               //   padding: windowWidth < 1400
  //               //       ? EdgeInsets.all(10)
  //               //       : EdgeInsets.all(15),
  //               //   decoration: BoxDecoration(
  //               //       color: mDarkBlue.withOpacity(0.1),
  //               //       borderRadius: BorderRadius.circular(50)),
  //               //   child: Icon(
  //               //     Icons.file_copy,
  //               //     color: mBlueColor,
  //               //     size: windowWidth < 1400 ? 20 : 25,
  //               //   ),
  //               // ),

  //               Container(
  //                 // color: Colors.red,
  //                 height: 40,
  //                 width: 40,
  //                 child: SfCircularChart(palette: <Color>[
  //                   Color.fromARGB(255, 134, 219, 137),
  //                   Color.fromARGB(255, 238, 238, 238)
  //                 ], series: <CircularSeries>[
  //                   // Initialize line series
  //                   PieSeries<ChartData, String>(
  //                       // Enables the tooltip for individual series
  //                       enableTooltip: true,
  //                       dataSource: [
  //                         ChartData(
  //                             'Sudah',
  //                             dashboardResult.data != null
  //                                 ? double.parse(
  //                                     dashboardResult.data!.okCount.toString())
  //                                 : 0),
  //                         ChartData(
  //                             'Belum',
  //                             (dashboardResult.data != null
  //                                 ? double.parse(
  //                                     dashboardResult.data!.ngCount.toString())
  //                                 : 0)),
  //                       ],
  //                       xValueMapper: (ChartData data, _) => data.x,
  //                       yValueMapper: (ChartData data, _) => data.y)
  //                 ]),
  //               ),
  //               Expanded(
  //                 child: Container(
  //                   margin: windowWidth < 1400
  //                       ? EdgeInsets.symmetric(vertical: 10, horizontal: 10)
  //                       : EdgeInsets.symmetric(vertical: 11, horizontal: 20),
  //                   child: Column(
  //                     children: [
  //                       Row(
  //                         mainAxisAlignment: MainAxisAlignment.start,
  //                         children: [
  //                           Text(
  //                             "Actual",
  //                             textAlign: TextAlign.center,
  //                             style: GoogleFonts.poppins(
  //                                 color: mDarkBlue.withOpacity(0.5),
  //                                 fontSize: 10,
  //                                 fontWeight: FontWeight.w600),
  //                           ),
  //                           SizedBox(
  //                             width: 15,
  //                           ),
  //                           Text(
  //                             // dashboardResult.data != null
  //                             //     ? (dashboardResult.data!.displayData != null
  //                             //         ? dashboardResult.data!.displayData!.actualWos
  //                             //             .toString()
  //                             //         : "")
  //                             //     : "",
  //                             ((dashboardResult.data != null
  //                                         ? dashboardResult.data!.okCount
  //                                         : 0) +
  //                                     (dashboardResult.data != null
  //                                         ? dashboardResult.data!.ngCount
  //                                         : 0))
  //                                 .toString(),
  //                             textAlign: TextAlign.center,
  //                             style: GoogleFonts.poppins(
  //                                 color: mDarkBlue,
  //                                 fontSize: 10,
  //                                 fontWeight: FontWeight.w700),
  //                           )
  //                         ],
  //                       ),
  //                       Row(
  //                         children: [
  //                           Expanded(
  //                             child: Row(
  //                               children: [
  //                                 InkWell(
  //                                   onTap: () async {},
  //                                   child: Container(
  //                                     margin: EdgeInsets.only(right: 5),
  //                                     decoration: BoxDecoration(
  //                                         boxShadow: [
  //                                           BoxShadow(
  //                                             color:
  //                                                 Colors.grey.withOpacity(0.2),
  //                                             spreadRadius: 5,
  //                                             blurRadius: 5,
  //                                             offset: Offset(0, 2),
  //                                           )
  //                                         ],
  //                                         color: Color.fromARGB(
  //                                             255, 134, 219, 137),
  //                                         borderRadius:
  //                                             BorderRadius.circular(3)),
  //                                     padding: EdgeInsets.symmetric(
  //                                         vertical: 2, horizontal: 4),
  //                                     child: Center(
  //                                       child: Text(
  //                                         "OK",
  //                                         style: GoogleFonts.poppins(
  //                                             color: Color.fromARGB(
  //                                                 255, 255, 255, 255),
  //                                             fontSize: 9),
  //                                       ),
  //                                     ),
  //                                   ),
  //                                 ),
  //                                 Text(
  //                                   // dashboardResult.data != null
  //                                   //     ? (dashboardResult.data!.displayData != null
  //                                   //         ? dashboardResult.data!.displayData!.actualWos
  //                                   //             .toString()
  //                                   //         : "")
  //                                   //     : "",
  //                                   (dashboardResult.data != null
  //                                           ? dashboardResult.data!.okCount
  //                                           : 0)
  //                                       .toString(),
  //                                   textAlign: TextAlign.center,
  //                                   style: GoogleFonts.poppins(
  //                                       color: mDarkBlue,
  //                                       fontSize: 10,
  //                                       fontWeight: FontWeight.w600),
  //                                 )
  //                               ],
  //                             ),
  //                           ),
  //                           SizedBox(
  //                             width: 5,
  //                           ),
  //                           Expanded(
  //                             child: Row(
  //                               children: [
  //                                 InkWell(
  //                                   onTap: () async {},
  //                                   child: Container(
  //                                     margin: EdgeInsets.only(right: 3),
  //                                     decoration: BoxDecoration(
  //                                         boxShadow: [
  //                                           BoxShadow(
  //                                             color:
  //                                                 Colors.grey.withOpacity(0.2),
  //                                             spreadRadius: 5,
  //                                             blurRadius: 5,
  //                                             offset: Offset(0, 2),
  //                                           )
  //                                         ],
  //                                         color: Colors.red,
  //                                         borderRadius:
  //                                             BorderRadius.circular(3)),
  //                                     padding: EdgeInsets.symmetric(
  //                                         vertical: 2, horizontal: 4),
  //                                     child: Center(
  //                                       child: Text(
  //                                         "NG",
  //                                         style: GoogleFonts.poppins(
  //                                             color: Colors.white, fontSize: 9),
  //                                       ),
  //                                     ),
  //                                   ),
  //                                 ),
  //                                 Text(
  //                                   // dashboardResult.data != null
  //                                   //     ? (dashboardResult.data!.displayData != null
  //                                   //         ? dashboardResult.data!.displayData!.actualWos
  //                                   //             .toString()
  //                                   //         : "")
  //                                   //     : "",
  //                                   (dashboardResult.data != null
  //                                           ? dashboardResult.data!.ngCount
  //                                           : 0)
  //                                       .toString(),
  //                                   textAlign: TextAlign.center,
  //                                   style: GoogleFonts.poppins(
  //                                       color: mDarkBlue,
  //                                       fontSize: 10,
  //                                       fontWeight: FontWeight.w600),
  //                                 )
  //                               ],
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               )
  //             ],
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Row headInfo(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
              margin:
                  EdgeInsets.only(left: windowWidth < 1400 ? 10 : 20, right: 8),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Loading Production Data",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        color: mDarkBlue.withOpacity(0.8),
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            dashboardResult.loadingAchievement != null
                                ? dashboardResult.loadingAchievement!.planWos
                                    .toString()
                                : "0",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                color: mDarkBlue.withOpacity(1),
                                fontSize: 25,
                                fontWeight: FontWeight.w800),
                          ),
                          Text(
                            "PLAN",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                color: mDarkBlue.withOpacity(0.5),
                                fontSize: 15,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            dashboardResult.loadingAchievement != null
                                ? dashboardResult.loadingAchievement!.actualWos
                                    .toString()
                                : "0",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                color: mDarkBlue.withOpacity(1),
                                fontSize: 25,
                                fontWeight: FontWeight.w800),
                          ),
                          Text(
                            "ACTUAL",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                color: mDarkBlue.withOpacity(0.5),
                                fontSize: 15,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            dashboardResult.loadingAchievement != null
                                ? dashboardResult.loadingAchievement!.repair
                                    .toString()
                                : "0",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                color: mDarkBlue.withOpacity(1),
                                fontSize: 25,
                                fontWeight: FontWeight.w800),
                          ),
                          Text(
                            "REPAIR",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                color: mDarkBlue.withOpacity(0.5),
                                fontSize: 15,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      )
                    ],
                  )
                ],
              )),
        ),
        Expanded(
          child: Container(
              margin:
                  EdgeInsets.only(left: windowWidth < 1400 ? 10 : 20, right: 8),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Sealing Production Data",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        color: mDarkBlue.withOpacity(0.8),
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            dashboardResult.sealingAchievement != null
                                ? dashboardResult.sealingAchievement!.planWos
                                    .toString()
                                : "0",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                color: mDarkBlue.withOpacity(1),
                                fontSize: 25,
                                fontWeight: FontWeight.w800),
                          ),
                          Text(
                            "PLAN",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                color: mDarkBlue.withOpacity(0.5),
                                fontSize: 15,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            dashboardResult.sealingAchievement != null
                                ? dashboardResult.sealingAchievement!.actualWos
                                    .toString()
                                : "0",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                color: mDarkBlue.withOpacity(1),
                                fontSize: 25,
                                fontWeight: FontWeight.w800),
                          ),
                          Text(
                            "ACTUAL",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                color: mDarkBlue.withOpacity(0.5),
                                fontSize: 15,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            dashboardResult.sealingAchievement != null
                                ? dashboardResult.sealingAchievement!.repair
                                    .toString()
                                : "0",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                color: mDarkBlue.withOpacity(1),
                                fontSize: 25,
                                fontWeight: FontWeight.w800),
                          ),
                          Text(
                            "REPAIR",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                color: mDarkBlue.withOpacity(0.5),
                                fontSize: 15,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      )
                    ],
                  )
                ],
              )),
        ),
        Expanded(
          child: Container(
              margin:
                  EdgeInsets.only(left: windowWidth < 1400 ? 10 : 20, right: 8),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Top Coat Production Data",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        color: mDarkBlue.withOpacity(0.8),
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            dashboardResult.topcoatAchievement != null
                                ? dashboardResult.topcoatAchievement!.planWos
                                    .toString()
                                : "0",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                color: mDarkBlue.withOpacity(1),
                                fontSize: 25,
                                fontWeight: FontWeight.w800),
                          ),
                          Text(
                            "PLAN",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                color: mDarkBlue.withOpacity(0.5),
                                fontSize: 15,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            dashboardResult.topcoatAchievement != null
                                ? dashboardResult.topcoatAchievement!.actualWos
                                    .toString()
                                : "0",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                color: mDarkBlue.withOpacity(1),
                                fontSize: 25,
                                fontWeight: FontWeight.w800),
                          ),
                          Text(
                            "ACTUAL",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                color: mDarkBlue.withOpacity(0.5),
                                fontSize: 15,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            dashboardResult.topcoatAchievement != null
                                ? dashboardResult.topcoatAchievement!.repair
                                    .toString()
                                : "0",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                color: mDarkBlue.withOpacity(1),
                                fontSize: 25,
                                fontWeight: FontWeight.w800),
                          ),
                          Text(
                            "REPAIR",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                color: mDarkBlue.withOpacity(0.5),
                                fontSize: 15,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      )
                    ],
                  )
                ],
              )),
        ),
        Container(
          width: 300,
          margin: EdgeInsets.only(left: windowWidth < 1400 ? 10 : 20, right: 8),
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
              // Container(
              //   padding: windowWidth < 1400
              //       ? EdgeInsets.all(10)
              //       : EdgeInsets.all(15),
              //   decoration: BoxDecoration(
              //       color: mDarkBlue.withOpacity(0.1),
              //       borderRadius: BorderRadius.circular(50)),
              //   child: Icon(
              //     Icons.file_copy,
              //     color: mBlueColor,
              //     size: windowWidth < 1400 ? 20 : 25,
              //   ),
              // ),

              Container(
                // color: Colors.red,
                height: 110,
                width: 110,
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
                            dashboardResult.data != null
                                ? double.parse(
                                    dashboardResult.data!.okCount.toString())
                                : 0),
                        ChartData(
                            'Belum',
                            (dashboardResult.data != null
                                ? double.parse(
                                    dashboardResult.data!.ngCount.toString())
                                : 0)),
                      ],
                      xValueMapper: (ChartData data, _) => data.x,
                      yValueMapper: (ChartData data, _) => data.y)
                ]),
              ),
              Expanded(
                child: Container(
                  margin: windowWidth < 1400
                      ? EdgeInsets.symmetric(vertical: 10, horizontal: 10)
                      : EdgeInsets.symmetric(vertical: 11, horizontal: 20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () async {},
                                      child: Container(
                                        margin: EdgeInsets.only(right: 10),
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
                                                255, 134, 219, 137),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 6, horizontal: 8),
                                        child: Center(
                                          child: Text(
                                            "OK",
                                            style: GoogleFonts.poppins(
                                                color: Color.fromARGB(
                                                    255, 255, 255, 255),
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
                                      (dashboardResult.data != null
                                              ? dashboardResult.data!.okCount
                                              : 0)
                                          .toString(),
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                          color: mDarkBlue,
                                          fontSize:
                                              windowWidth < 1400 ? 17 : 22,
                                          fontWeight: FontWeight.w600),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () async {},
                                      child: Container(
                                        margin: EdgeInsets.only(right: 10),
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
                                            color: Colors.red,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 6, horizontal: 8),
                                        child: Center(
                                          child: Text(
                                            "REPAIR",
                                            style: GoogleFonts.poppins(
                                                color: Colors.white,
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
                                      (dashboardResult.data != null
                                              ? dashboardResult.data!.ngCount
                                              : 0)
                                          .toString(),
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                          color: mDarkBlue,
                                          fontSize:
                                              windowWidth < 1400 ? 17 : 22,
                                          fontWeight: FontWeight.w600),
                                    )
                                  ],
                                ),
                              ]),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Actual",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                    color: mDarkBlue.withOpacity(0.5),
                                    fontSize: windowWidth < 1400 ? 11 : 14,
                                    fontWeight: FontWeight.w600),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              Text(
                                // dashboardResult.data != null
                                //     ? (dashboardResult.data!.displayData != null
                                //         ? dashboardResult.data!.displayData!.actualWos
                                //             .toString()
                                //         : "")
                                //     : "",
                                ((dashboardResult.data != null
                                            ? dashboardResult.data!.okCount
                                            : 0) +
                                        (dashboardResult.data != null
                                            ? dashboardResult.data!.ngCount
                                            : 0))
                                    .toString(),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                    color: mDarkBlue,
                                    fontSize: windowWidth < 1400 ? 17 : 25,
                                    fontWeight: FontWeight.w700),
                              )
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

Future<dynamic> konfirmasiDialog(String bodyId, String bodyType,
    BuildContext context, void Function()? onTap) {
  return showDialog(
      barrierDismissible: true,
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
              "Confirmation\n\nBody Id : $bodyId\nBody Type : $bodyType",
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
                      return;
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 5,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            )
                          ],
                          color: Color.fromARGB(255, 107, 107, 107),
                          borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.all(8),
                      child: Center(
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.poppins(
                              color: Colors.white, fontSize: 16),
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
                    onTap: onTap,
                    child: Container(
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: mTitleBlue.withOpacity(0.2),
                              spreadRadius: 5,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            )
                          ],
                          color: mTitleBlue,
                          borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.all(8),
                      child: Center(
                        child: Text(
                          "Confirm",
                          style: GoogleFonts.poppins(
                              color: Colors.white, fontSize: 16),
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
}
