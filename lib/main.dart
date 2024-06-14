import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:desktop_window/desktop_window.dart';
import 'package:fancy_snackbar/fancy_snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isuzu_oee_app/home_screen.dart';
import 'package:isuzu_oee_app/login_windows_screen.dart';
import 'package:isuzu_oee_app/navigation_screen.dart';
// import 'package:here_sdk/core.dart';
// import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:win32/win32.dart';
import 'package:window_manager/window_manager.dart';

import 'constants/color_constant.dart';
import 'custom/InputText.dart';
import 'models/login_model.dart';
import 'navigation/navigation_screen.dart';
import 'dart:ui' as ui;
import 'package:window_size/window_size.dart' as window_size;

import 'navigation/time_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows) {
    // await DesktopWindow.setFullScreen(true);
    await windowManager.ensureInitialized();
    // disableWindowResize();
  }
  runApp(MyApp());
}

void disableWindowResize() {
  final hWnd = GetConsoleWindow(); // Get the handle to the window
  final windowStyle = GetWindowLongPtr(hWnd, GWL_STYLE);
  SetWindowLongPtr(
      hWnd, GWL_STYLE, windowStyle & ~WS_SIZEBOX); // Disable resizing
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    return MaterialApp(
      locale: const Locale('en', 'US'),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [
        Locale('en', 'GB'),
        Locale('en', 'US'),
        Locale('ar'),
        Locale('zh'),
      ],
      theme: ThemeData(fontFamily: "Nunito"),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          resizeToAvoidBottomInset: false,
          body: BlocProvider(
            create: (context) => TimeCubit(),
            child: Scaffold(
                resizeToAvoidBottomInset: false,
                body: Container(
                  child: LoginPage(),
                )),
          )),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  int _pageState = 1;
  var emailController = new TextEditingController();
  var passController = new TextEditingController();
  final storage = new FlutterSecureStorage();

  var _backgroundColor = Colors.white;
  var _headingColor = Color(0xFFB40284A);

  double _headingTop = 100;
  double _sizeBox = 40;

  double _loginWidth = 0;
  double _loginHeight = 0;
  double _loginOpacity = 1;

  double _loginYOffset = 0;
  double _loginXOffset = 0;
  double _registerYOffset = 0;
  double _registerHeight = 0;

  double windowWidth = 0;
  double windowHeight = 0;

  bool _keyboardVisible = false;

  void _addNewItem(String keyy, String valuee) async {
    final String key = keyy;
    final String value = valuee;

    await storage.write(key: key, value: value);
    final String data = await storage.read(key: key) ?? "";
    //print(data);
  }

  bool isPhone() {
    final data = MediaQueryData.fromWindow(WidgetsBinding.instance.window);
    // return data.size.shortestSide < 600 ? true : false;
    return false;
  }

  // Future<void> saveRemember(String data) async {
  //   final directory = await getApplicationDocumentsDirectory();
  //   final file = File('${directory.path}/remember.txt');
  //   await file.writeAsString(data);
  // }

  // Future<void> saveToken(String data) async {
  //   final directory = await getApplicationDocumentsDirectory();
  //   final file = File('${directory.path}/token.txt');
  //   await file.writeAsString(data);
  // }

  String url = "";
  String tok = "";
  String keep = "";
  // String url = "";

  // Future<String> readRemember() async {
  //   try {
  //     final directory = await getApplicationDocumentsDirectory();
  //     final file = File('${directory.path}/remember.txt');
  //     return await file.readAsString();
  //   } catch (e) {
  //     // Handle errors
  //     return '';
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

  void get() async {
    if (Platform.isWindows) {
      // keep = await readRemember();
      // tok = await readToken();
      window_size.getWindowInfo().then((window) {
        // final screen = window.screen;
        final screen = window.screen;
        if (screen != null) {
          // final screenFrame = screen.visibleFrame;
          // final width =
          //     math.max((screenFrame.width / 2).roundToDouble(), 800.0);
          // final height =
          //     math.max((screenFrame.height / 2).roundToDouble(), 600.0);
          // final left = screenFrame.left +
          //     ((screenFrame.width - width) / 2).roundToDouble();
          // final top = screenFrame.top +
          //     ((screenFrame.height - height) / 3).roundToDouble();
          // final frame = Rect.fromLTWH(left, top, width, height);
          // window_size.setWindowFrame(frame);
          window_size.setWindowMinSize(
              ui.Size(window.screen!.frame.width, window.screen!.frame.height));
          window_size.setWindowMaxSize(
              ui.Size(window.screen!.frame.width, window.screen!.frame.height));
          window_size.setWindowTitle('OEE');
          // window_size.setWindowTitle('OEE');
        }
      });
      await windowManager.ensureInitialized();
      // disableWindowResize();
      WindowOptions windowOptions = const WindowOptions(fullScreen: true);
      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
      isWindows = true;
    } else {
      tok = await storage.read(key: "token") ?? "";
      keep = await storage.read(key: "keep") ?? "false";
      dev.log(tok + "\n" + keep);
    }
    setState(() {});
  }

  bool _passwordVisible = true;
  late StreamSubscription<bool> keyboardSubscription;

  @override
  void dispose() {
    keyboardSubscription.cancel();
    super.dispose();
  }

  bool isWindows = false;
  @override
  void initState() {
    super.initState();
    get();

    _passwordVisible = true;
    var keyboardVisibilityController = KeyboardVisibilityController();
    // Query
    print(
        'Keyboard visibility direct query: ${keyboardVisibilityController.isVisible}');

    // Subscribe
    keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
      print('Keyboard visibility update. Is visible: $visible');

      setState(() {
        _keyboardVisible = visible;
        print("Keyboard State Changed : $visible");
      });
    });
  }

  TextEditingController ipController = new TextEditingController();

  bool rememberMe = false;

  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    windowHeight = MediaQuery.of(context).size.height;
    windowWidth = MediaQuery.of(context).size.width;
    dev.log(windowHeight.toString());
    dev.log(windowWidth.toString());
    _loginHeight = windowHeight - 270;
    _registerHeight = windowHeight - 270;

    switch (_pageState) {
      case 0:
        _backgroundColor = Colors.white;
        _headingColor = Color(0xFFB40284A);

        _headingTop = 250;
        _sizeBox = 40;
        _loginWidth = windowWidth;
        _loginOpacity = 1;

        _loginYOffset = windowHeight;
        _loginHeight = _keyboardVisible ? windowHeight : windowHeight - 270;
        // _loginHeight = windowHeight;

        _loginXOffset = 0;
        _registerYOffset = windowHeight;
        break;
      case 1:
        _backgroundColor = Color(0xFF358873);
        _headingColor = Colors.white;

        _headingTop = (isPhone()
            ? 70
            : (MediaQuery.of(context).orientation == Orientation.portrait
                ? 150
                : 70));
        _sizeBox = 350;

        _loginWidth = windowWidth;
        _loginOpacity = 1;

        _loginYOffset = _keyboardVisible
            ? (isPhone()
                ? 50
                : (MediaQuery.of(context).orientation == Orientation.portrait
                    ? 300
                    : 20))
            : (isPhone()
                ? windowWidth < 411
                    ? 190
                    : 260
                : (MediaQuery.of(context).orientation == Orientation.portrait
                    ? 400
                    : 120));
        _loginHeight = _keyboardVisible
            ? windowHeight
            : windowHeight -
                (isPhone()
                    ? windowWidth < 411
                        ? 170
                        : 250
                    : (MediaQuery.of(context).orientation ==
                            Orientation.portrait
                        ? 400
                        : 120));
        // _loginYOffset = 270;
        // _loginHeight = windowHeight - 270;

        _loginXOffset = 0;
        _registerYOffset = windowHeight;
        break;
      case 2:
        _backgroundColor = Color(0xFF358873);
        _headingColor = Colors.white;

        _headingTop = 100;

        _loginWidth = windowWidth - 40;
        _loginOpacity = 0.7;

        _loginYOffset = _keyboardVisible ? 30 : 130;
        _loginHeight = _keyboardVisible ? windowHeight : windowHeight - 240;

        _loginXOffset = 20;
        _registerYOffset = _keyboardVisible ? 55 : 150;
        _registerHeight = _keyboardVisible ? windowHeight : windowHeight - 150;
        break;
    }

    return tok != "" && keep == "true"
        ? NavigationScreen()
        : LoadingOverlay(
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
            child: isWindows
                ? Container(
                    child: Stack(children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            width: windowWidth < 1000
                                ? MediaQuery.of(context).size.width / 1.8
                                : MediaQuery.of(context).size.width / 2.5,
                            padding: EdgeInsets.symmetric(horizontal: 70),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                AnimatedContainer(
                                    curve: Curves.fastLinearToSlowEaseIn,
                                    duration: Duration(milliseconds: 1000),
                                    margin: EdgeInsets.only(
                                      top: 0,
                                    ),
                                    child: Image.asset(
                                      "assets/images/oee.png",
                                      width:
                                          MediaQuery.of(context).size.width / 4,
                                    )),
                                Container(
                                  margin: EdgeInsets.only(bottom: 0),
                                  child: Text(
                                    "Sign In",
                                    style: GoogleFonts.poppins(
                                        fontSize: windowWidth < 411 ? 22 : 28,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    "Enter your Employee ID and password to sign in! ",
                                    style: GoogleFonts.poppins(
                                        fontSize: windowWidth < 411 ? 12 : 14,
                                        color:
                                            Color.fromARGB(255, 112, 112, 112),
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  margin: EdgeInsets.only(bottom: 5),
                                  child: Text(
                                    "Employee ID*",
                                    style: GoogleFonts.poppins(
                                        fontSize: windowWidth < 411 ? 12 : 14,
                                        color: Color.fromARGB(255, 36, 36, 36),
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                InputText(
                                  icon: Icons.phone_rounded,
                                  hint: "Enter your Employee ID here...",
                                  password: false,
                                  controller: emailController,
                                  maxLine: 1,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  margin: EdgeInsets.only(bottom: 5),
                                  child: Text(
                                    "Password*",
                                    style: GoogleFonts.poppins(
                                        fontSize: windowWidth < 411 ? 12 : 14,
                                        color: Color.fromARGB(255, 36, 36, 36),
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Color.fromARGB(
                                              250, 230, 230, 230),
                                          width: 1.5),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Row(
                                    children: <Widget>[
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Expanded(
                                        child: TextField(
                                          controller: passController,
                                          obscureText: _passwordVisible,
                                          style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600),
                                          decoration: InputDecoration(
                                              hintStyle: GoogleFonts.poppins(
                                                  fontSize: 15),
                                              border: InputBorder.none,
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  // Based on passwordVisible state choose the icon
                                                  _passwordVisible
                                                      ? Icons.visibility_off
                                                      : Icons.visibility,
                                                  size: 22,
                                                  color: _passwordVisible
                                                      ? Colors.grey
                                                      : Color.fromARGB(
                                                          255, 224, 224, 224),
                                                ),
                                                onPressed: () {
                                                  // Update the state i.e. toogle the state of passwordVisible variable
                                                  setState(() {
                                                    _passwordVisible =
                                                        !_passwordVisible;
                                                  });
                                                },
                                              ),
                                              hintText:
                                                  "Enter your password here..."),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 0,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    CupertinoCheckbox(
                                        value: rememberMe,
                                        onChanged: (value) {
                                          setState(() {
                                            rememberMe = value!;

                                            if (rememberMe) {
                                              // TODO: Here goes your functionality that remembers the user.
                                            } else {
                                              // TODO: Forget the user
                                            }
                                          });
                                        }),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (rememberMe) {
                                            rememberMe = false;
                                            // TODO: Here goes your functionality that remembers the user.
                                          } else {
                                            rememberMe = true;
                                            // TODO: Forget the user
                                          }
                                        });
                                      },
                                      child: Container(
                                        // margin: EdgeInsets.only(bottom: 10),
                                        child: Text(
                                          "Keep me logged in",
                                          style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              color: Color.fromARGB(
                                                  255, 73, 73, 73),
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 40,
                                ),
                                Container(
                                  child: PrimaryButton(
                                    btnText: "Login",
                                    login: true,
                                    onTap: () async {
                                      try {
                                        if (Platform.isWindows) {
                                          setState(() {
                                            _isLoading = true;
                                          });
                                          Login.connectToApi(
                                                  emailController.text,
                                                  passController.text,
                                                  "mobile")
                                              .then((value) async {
                                            Future.delayed(Duration(seconds: 2))
                                                .then((value) {
                                              setState(() {
                                                _isLoading = false;
                                              });
                                            });
                                            //print(storage.read(key: "token"));
                                            if (value.status == 200) {
                                              dev.log("remeber " +
                                                  rememberMe.toString());
                                              if (rememberMe) {
                                                await storage.write(
                                                    key: "keep", value: "true");
                                              } else {
                                                await storage.write(
                                                    key: "keep",
                                                    value: "false");
                                              }

                                              _addNewItem("token", value.token);
                                              _addNewItem("webViewToken",
                                                  value.webToken);
                                              String b = await storage.read(
                                                      key: "token") ??
                                                  "";
                                              dev.log("token windows : " + b);
                                              String hasilSImpan =
                                                  await storage.read(
                                                          key:
                                                              "webViewToken") ??
                                                      "";
                                              dev.log(
                                                  "hasilSImpan " + hasilSImpan);
                                              Navigator.pushReplacement(context,
                                                  MaterialPageRoute(
                                                      builder: (context) {
                                                return NavigationScreen();
                                              }));
                                            } else {
                                              Future.delayed(
                                                      Duration(seconds: 2))
                                                  .then((valuea) {
                                                setState(() {
                                                  _isLoading = false;
                                                  _showDialog(
                                                      context, value.message);
                                                });
                                              });
                                            }
                                          });
                                        }
                                      } catch (x) {
                                        Future.delayed(Duration(seconds: 2))
                                            .then((value) {
                                          setState(() {
                                            _isLoading = false;
                                            _showDialog(context, x.toString());
                                          });
                                        });
                                      }
                                    },
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 10),
                                  child: Text(
                                    "Copyright © 2024 PT. Isuzu Astra Motor Indonesia. All Right Reserved.",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: Color.fromARGB(255, 61, 61, 61),
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/images/logo.png",
                                  height: windowWidth < 1000 ? 200 : 250,
                                  fit: BoxFit.contain,
                                ),
                                // Text(
                                //   "  Banana Sprayer Management System",
                                //   style: GoogleFonts.poppins(
                                //     fontWeight: FontWeight.w600,
                                //     fontSize: 22,
                                //     letterSpacing: 0.0,
                                //     color: Color.fromARGB(255, 44, 44, 44),
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                          top: 10,
                          right: 20,
                          child: IconButton(
                            onPressed: () async {
                              showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (dialogcontext) {
                                    return AlertDialog(
                                        content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
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
                                              color: Color.fromARGB(
                                                  255, 75, 75, 75)),
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
                                                          BorderRadius.circular(
                                                              10)),
                                                  padding: EdgeInsets.all(8),
                                                  child: Center(
                                                    child: Text(
                                                      "Exit App ",
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
                                    ));
                                  });
                            },
                            icon: Icon(
                              Icons.close_rounded,
                              size: 35,
                              color: const Color.fromARGB(255, 51, 51, 51),
                            ),
                          ))
                    ]),
                  )
                : Stack(
                    children: <Widget>[
                      AnimatedContainer(
                          curve: Curves.fastLinearToSlowEaseIn,
                          duration: Duration(milliseconds: 1000),
                          color: Colors.white,
                          child: Stack(children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      // mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        AnimatedContainer(
                                            curve:
                                                Curves.fastLinearToSlowEaseIn,
                                            duration:
                                                Duration(milliseconds: 1000),
                                            margin: EdgeInsets.only(
                                              top: _headingTop - 40,
                                            ),
                                            child: Image.asset(
                                              "assets/images/logo.png",
                                              width: 80,
                                            )),
                                        AnimatedContainer(
                                            curve:
                                                Curves.fastLinearToSlowEaseIn,
                                            duration:
                                                Duration(milliseconds: 1000),
                                            margin: EdgeInsets.only(
                                              top: 0,
                                            ),
                                            child: Image.asset(
                                              "assets/images/oee.png",
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  80,
                                            )),

                                        // SizedBox(
                                        //   height: _sizeBox,
                                        // )
                                        // Container(
                                        //   margin: EdgeInsets.all(20),
                                        //   padding: EdgeInsets.symmetric(horizontal: 32),
                                        //   child: Text(
                                        //     "We brought IoT Into the next level\nYou put it, you got it!",
                                        //     textAlign: TextAlign.center,
                                        //     style: TextStyle(
                                        //         color: _headingColor, fontSize: 16),
                                        //   ),
                                        // )
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20))),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (_pageState != 0) {
                                          _pageState = 0;
                                        } else {
                                          _pageState = 1;
                                        }
                                      });
                                    },
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 50,
                                        ),
                                        Text(
                                          "Monitor your Product Easily, Seamless and Portable",
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                              color: const Color.fromARGB(
                                                  255, 49, 49, 49),
                                              fontSize:
                                                  windowWidth < 411 ? 18 : 23,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Container(
                                          margin: EdgeInsets.all(32),
                                          padding: EdgeInsets.all(15),
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: mBlueColor
                                                      .withOpacity(0.2),
                                                  spreadRadius: 5,
                                                  blurRadius: 5,
                                                  offset: Offset(0, 2),
                                                )
                                              ],
                                              color: mBlueColor,
                                              borderRadius:
                                                  BorderRadius.circular(15)),
                                          child: Center(
                                            child: Text(
                                              "Get Started",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ])),
                      AnimatedContainer(
                        padding: EdgeInsets.all(32),
                        width: _loginWidth,
                        // alignment: Alignment.bottomCenter,
                        height: _loginHeight,
                        curve: Curves.fastLinearToSlowEaseIn,
                        duration: Duration(milliseconds: 1000),
                        transform: Matrix4.translationValues(
                            _loginXOffset, _loginYOffset, 1),
                        decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 5,
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              )
                            ],
                            color: Colors.white.withOpacity(_loginOpacity),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(35),
                                topRight: Radius.circular(35))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            SingleChildScrollView(
                              physics: BouncingScrollPhysics(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.only(bottom: 0),
                                    child: Text(
                                      "Sign In",
                                      style: GoogleFonts.poppins(
                                          fontSize: windowWidth < 411 ? 22 : 28,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(bottom: 10),
                                    child: Text(
                                      "Enter your Employee ID and password to sign in! ",
                                      style: GoogleFonts.poppins(
                                          fontSize: windowWidth < 411 ? 12 : 14,
                                          color: Color.fromARGB(
                                              255, 112, 112, 112),
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(bottom: 5),
                                    child: Text(
                                      "Employee ID*",
                                      style: GoogleFonts.poppins(
                                          fontSize: windowWidth < 411 ? 12 : 14,
                                          color:
                                              Color.fromARGB(255, 36, 36, 36),
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  InputText(
                                    icon: Icons.phone_rounded,
                                    hint: "Enter your Employee ID here...",
                                    password: false,
                                    controller: emailController,
                                    maxLine: 1,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(bottom: 5),
                                    child: Text(
                                      "Password*",
                                      style: GoogleFonts.poppins(
                                          fontSize: windowWidth < 411 ? 12 : 14,
                                          color:
                                              Color.fromARGB(255, 36, 36, 36),
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Color.fromARGB(
                                                250, 230, 230, 230),
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
                                            controller: passController,
                                            obscureText: _passwordVisible,
                                            style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600),
                                            decoration: InputDecoration(
                                                hintStyle: GoogleFonts.poppins(
                                                    fontSize: 14),
                                                border: InputBorder.none,
                                                suffixIcon: IconButton(
                                                  icon: Icon(
                                                    // Based on passwordVisible state choose the icon
                                                    _passwordVisible
                                                        ? Icons.visibility_off
                                                        : Icons.visibility,
                                                    size: 22,
                                                    color: _passwordVisible
                                                        ? Colors.grey
                                                        : Color.fromARGB(
                                                            255, 224, 224, 224),
                                                  ),
                                                  onPressed: () {
                                                    // Update the state i.e. toogle the state of passwordVisible variable
                                                    setState(() {
                                                      _passwordVisible =
                                                          !_passwordVisible;
                                                    });
                                                  },
                                                ),
                                                hintText:
                                                    "Enter your password here..."),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 0,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      CupertinoCheckbox(
                                          value: rememberMe,
                                          onChanged: (value) {
                                            setState(() {
                                              rememberMe = value!;

                                              if (rememberMe) {
                                                // TODO: Here goes your functionality that remembers the user.
                                              } else {
                                                // TODO: Forget the user
                                              }
                                            });
                                          }),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            if (rememberMe) {
                                              rememberMe = false;
                                              // TODO: Here goes your functionality that remembers the user.
                                            } else {
                                              rememberMe = true;
                                              // TODO: Forget the user
                                            }
                                          });
                                        },
                                        child: Container(
                                          // margin: EdgeInsets.only(bottom: 10),
                                          child: Text(
                                            "Keep me logged in",
                                            style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                color: Color.fromARGB(
                                                    255, 73, 73, 73),
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Column(
                              children: <Widget>[
                                Container(
                                  child: PrimaryButton(
                                    btnText: "Login",
                                    login: true,
                                    onTap: () async {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      try {
                                        String? ke =
                                            await storage.read(key: "keep") ??
                                                "";
                                        dev.log("KE : " + ke);
                                        Login.connectToApi(emailController.text,
                                                passController.text, "mobile")
                                            .then((value) {
                                          setState(() {
                                            Future.delayed(Duration(seconds: 2))
                                                .then((value) {
                                              setState(() {
                                                _isLoading = false;
                                              });
                                            });
                                            //print(storage.read(key: "token"));
                                            if (value.status == 200) {
                                              dev.log("remeber " +
                                                  rememberMe.toString());
                                              if (rememberMe) {
                                                _addNewItem("keep", "true");
                                              } else {
                                                _addNewItem("keep", "false");
                                              }
                                              _addNewItem("token", value.token);
                                              _addNewItem("password",
                                                  passController.text);

                                              _addNewItem("token", value.token);
                                              _addNewItem("webViewToken",
                                                  value.webToken);
                                              Navigator.pushReplacement(context,
                                                  MaterialPageRoute(
                                                      builder: (context) {
                                                return NavigationScreen();
                                              }));
                                            } else {
                                              Future.delayed(
                                                      Duration(seconds: 2))
                                                  .then((valuea) {
                                                setState(() {
                                                  _isLoading = false;
                                                  _showDialog(
                                                      context, value.message);
                                                });
                                              });
                                            }
                                          });
                                        });
                                        String? ka =
                                            await storage.read(key: "keep") ??
                                                "";
                                        dev.log("KE2 : " + ka);
                                      } catch (x) {
                                        Future.delayed(Duration(seconds: 2))
                                            .then((value) {
                                          setState(() {
                                            _isLoading = false;
                                            _showDialog(context, x.toString());
                                          });
                                        });
                                      }
                                    },
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 10),
                                  child: Text(
                                    "Copyright © 2024 PT. Isuzu Astra Motor Indonesia. All Right Reserved. Version App 1.0.0",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: Color.fromARGB(255, 61, 61, 61),
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      AnimatedContainer(
                        height: _registerHeight,
                        padding: EdgeInsets.all(32),
                        curve: Curves.fastLinearToSlowEaseIn,
                        duration: Duration(milliseconds: 1000),
                        transform:
                            Matrix4.translationValues(0, _registerYOffset, 1),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(25),
                                topRight: Radius.circular(25))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[],
                        ),
                      )
                    ],
                  ),
          );
    ;
  }
}

class InputWithIcon extends StatefulWidget {
  final IconData icon;
  final String hint;
  final bool password;
  final TextEditingController controller;
  InputWithIcon(
      {required this.icon,
      required this.hint,
      required this.password,
      required this.controller});

  @override
  _InputWithIconState createState() => _InputWithIconState();
}

class _InputWithIconState extends State<InputWithIcon> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border:
              Border.all(color: Color.fromARGB(250, 230, 230, 230), width: 1.5),
          borderRadius: BorderRadius.circular(10)),
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
              controller: widget.controller,
              obscureText: widget.password,
              style: GoogleFonts.poppins(
                  fontSize: 15, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 15,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 5),
                  border: InputBorder.none,
                  hintText: widget.hint),
            ),
          )
        ],
      ),
    );
  }
}

void _showDialog(BuildContext context, String pesan) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: new Text("Information!"),
        content: new Text(pesan),
        actions: <Widget>[
          new TextButton(
            child: new Text("OK"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

class PrimaryButton extends StatefulWidget {
  final String btnText;
  final bool login;
  void Function()? onTap;
  PrimaryButton(
      {required this.btnText, required this.login, required this.onTap});

  @override
  _PrimaryButtonState createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: mBlueColor.withOpacity(0.2),
          spreadRadius: 5,
          blurRadius: 5,
          offset: Offset(0, 2),
        )
      ], color: mBlueColor, borderRadius: BorderRadius.circular(10)),
      child: new Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          child: Container(
            padding: EdgeInsets.all(12),
            child: Center(
              child: Text(
                widget.btnText,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OutlineBtn extends StatefulWidget {
  final String btnText;
  OutlineBtn({required this.btnText});

  @override
  _OutlineBtnState createState() => _OutlineBtnState();
}

class _OutlineBtnState extends State<OutlineBtn> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Color(0xFF207567), width: 2),
          borderRadius: BorderRadius.circular(10)),
      padding: EdgeInsets.all(10),
      child: Center(
        child: Text(
          widget.btnText,
          style: TextStyle(color: Color(0xFF207567), fontSize: 16),
        ),
      ),
    );
  }
}
