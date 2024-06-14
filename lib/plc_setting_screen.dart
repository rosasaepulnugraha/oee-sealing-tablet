import 'dart:developer';
import 'dart:io';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:fancy_snackbar/fancy_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isuzu_oee_app/models/get_setting_model.dart';
import 'package:path_provider/path_provider.dart';

import 'constants/color_constant.dart';
import 'main.dart';
import 'models/post_integration_setting.dart';

class PlcSettingScreen extends StatefulWidget {
  const PlcSettingScreen({super.key});

  @override
  State<PlcSettingScreen> createState() => _PlcSettingScreenState();
}

class _PlcSettingScreenState extends State<PlcSettingScreen> {
  TextEditingController controllerIp = new TextEditingController();
  TextEditingController controllerPort = new TextEditingController();
  TextEditingController controllerConnection = new TextEditingController();
  TextEditingController controllerData = new TextEditingController();
  TextEditingController controllerUsername = new TextEditingController();
  TextEditingController controllerPassword = new TextEditingController();
  double windowWidth = 0;

  var storage = new FlutterSecureStorage();
  String token = "";

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

  bool _isLoading = false;

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

  var getSetting = new GetSetting();

  void _getItem() async {
    setState(() {
      // _isLoading = true;
    });
    try {
      //await storage.write(key: key, value: value);
      token = await storage.read(key: "token") ?? "";

      // EasyLoading.show(status: 'loading...');
      //print("Nama =" + emailController.text);
      GetSetting.connectToApi(token).then((value) async {
        getSetting = value;
        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            _isLoading = false;
          });
        });
        if (getSetting.statusCode == 200) {
          setState(() {
            controllerConnection.text = getSetting.mqttConnection == null
                ? ""
                : getSetting.mqttConnection!.connectionType;
            controllerData.text = getSetting.mqttConnection == null
                ? ""
                : getSetting.mqttConnection!.dataType;
            controllerIp.text = getSetting.mqttConnection == null
                ? ""
                : getSetting.mqttConnection!.ipAddress;
            controllerPassword.text = getSetting.mqttConnection == null
                ? ""
                : getSetting.mqttConnection!.password;

            controllerPort.text = getSetting.mqttConnection == null
                ? ""
                : getSetting.mqttConnection!.port;

            controllerUsername.text = getSetting.mqttConnection == null
                ? ""
                : getSetting.mqttConnection!.username;
          });
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
            await storage.write(key: 'token', value: "");
            await storage.write(key: 'keep', value: "");
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => MyApp()),
                (Route<dynamic> route) => false);
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
  void initState() {
    // TODO: implement initState
    super.initState();
    _getItem();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: mBackgroundColor,
        body: Container(
          width: MediaQuery.of(context).size.width / 1.2,
          height: 730,
          margin: EdgeInsets.only(
              left: windowWidth < 1400 ? 10 : 15,
              right: windowWidth < 1400 ? 10 : 15,
              top: windowWidth < 1400 ? 10 : 15),
          padding: windowWidth < 1400
              ? EdgeInsets.symmetric(vertical: 10, horizontal: 10)
              : EdgeInsets.symmetric(vertical: 15, horizontal: 15),
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
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Text(
                              "PLC SETTINGS",
                              textAlign: TextAlign.start,
                              style: GoogleFonts.poppins(
                                  color: mDarkBlue,
                                  fontSize: windowWidth < 1400 ? 14 : 18,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Container(
                            margin: EdgeInsets.only(bottom: 10),
                            child: Text(
                              "IP Address",
                              style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: mTitleBlue,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          InputText(
                            icon: Icons.label_important_outline_sharp,
                            hint: "IP Address",
                            password: false,
                            controller: controllerIp,
                            maxLine: 1,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            margin: EdgeInsets.only(bottom: 10),
                            child: Text(
                              "Port",
                              style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: mTitleBlue,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          InputText(
                            icon: Icons.label_important_outline_sharp,
                            hint: "Port",
                            password: false,
                            controller: controllerPort,
                            maxLine: 1,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            margin: EdgeInsets.only(bottom: 10),
                            child: Text(
                              "Connection Type",
                              style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: mTitleBlue,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Color.fromARGB(250, 230, 230, 230),
                                    width: 1),
                                borderRadius: BorderRadius.circular(10)),
                            // width: 150,
                            child: CustomDropdown<dynamic>(
                              hintText: "Connection Type",
                              initialItem: "MQTT",
                              items: ["MQTT"],
                              decoration: CustomDropdownDecoration(
                                listItemStyle: TextStyle(
                                  fontFamily: "Netflix",
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                  letterSpacing: 0.0,
                                  color: Color.fromARGB(255, 83, 83, 83),
                                ),
                                headerStyle: TextStyle(
                                  fontFamily: "Netflix",
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                  letterSpacing: 0.0,
                                  color: Color.fromARGB(255, 83, 83, 83),
                                ),
                                hintStyle: TextStyle(
                                  fontFamily: "Netflix",
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                  letterSpacing: 0.0,
                                  color: Color.fromARGB(255, 110, 110, 110),
                                ),
                              ),
                              // initialItem: "Tomat",
                              onChanged: (value) {
                                setState(() {
                                  controllerConnection = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 35,
                          ),
                          Container(
                            margin: EdgeInsets.only(bottom: 10),
                            child: Text(
                              "Data Type",
                              style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: mTitleBlue,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Color.fromARGB(250, 230, 230, 230),
                                    width: 1),
                                borderRadius: BorderRadius.circular(10)),
                            // width: 150,
                            child: CustomDropdown<dynamic>(
                              hintText: "Data Type",
                              initialItem: "JSON",
                              items: ["JSON"],
                              decoration: CustomDropdownDecoration(
                                listItemStyle: TextStyle(
                                  fontFamily: "Netflix",
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                  letterSpacing: 0.0,
                                  color: Color.fromARGB(255, 83, 83, 83),
                                ),
                                headerStyle: TextStyle(
                                  fontFamily: "Netflix",
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                  letterSpacing: 0.0,
                                  color: Color.fromARGB(255, 83, 83, 83),
                                ),
                                hintStyle: TextStyle(
                                  fontFamily: "Netflix",
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                  letterSpacing: 0.0,
                                  color: Color.fromARGB(255, 110, 110, 110),
                                ),
                              ),
                              // initialItem: "Tomat",
                              onChanged: (value) {
                                setState(() {
                                  controllerData = value;
                                });
                              },
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            margin: EdgeInsets.only(bottom: 10),
                            child: Text(
                              "Username",
                              style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: mTitleBlue,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          InputText(
                            icon: Icons.label_important_outline_sharp,
                            hint: "Username",
                            password: false,
                            controller: controllerUsername,
                            maxLine: 1,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            margin: EdgeInsets.only(bottom: 10),
                            child: Text(
                              "Password",
                              style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: mTitleBlue,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          InputText(
                            icon: Icons.label_important_outline_sharp,
                            hint: "Password",
                            password: false,
                            controller: controllerPassword,
                            maxLine: 1,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 25,
              ),
              InkWell(
                onTap: () {
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
                              'Are you sure you will save status?',
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
                                              color:
                                                  Colors.grey.withOpacity(0.2),
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
                                      try {
                                        token = await readToken();
                                        log("To " + token);
                                        Future.delayed(
                                            const Duration(milliseconds: 0),
                                            () {
                                          setState(() {
                                            _isLoading = true;
                                          });
                                        });
                                        PostIntegrationSetting.connectToApi(
                                                token,
                                                controllerIp.text,
                                                controllerPort.text,
                                                controllerConnection.text,
                                                controllerData.text,
                                                controllerUsername.text,
                                                controllerPassword.text)
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
                                            if (value.status == 200) {
                                              FancySnackbar.showSnackbar(
                                                context,
                                                snackBarType:
                                                    FancySnackBarType.success,
                                                title: "Successfully!",
                                                message: value.message,
                                                duration: 1,
                                                onCloseEvent: () {},
                                              );
                                              _getItem();
                                              setState(() {});
                                              Navigator.pop(dialogcontext);
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
                                              setState(() {});
                                            }
                                          });
                                        });
                                      } catch (x) {
                                        Future.delayed(
                                            const Duration(milliseconds: 2000),
                                            () {
                                          setState(() {
                                            _isLoading = false;
                                            setState(() {});
                                            Navigator.pop(dialogcontext);
                                          });
                                        });
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  mTitleBlue.withOpacity(0.2),
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
                                          "Save",
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
                child: Container(
                  margin: EdgeInsets.only(bottom: 15),
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
                      borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                  child: Center(
                    child: Text(
                      "Save",
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

class InputText extends StatefulWidget {
  final IconData icon;
  final String hint;
  final bool password;
  final TextEditingController controller;
  final int maxLine;
  final int? maxLength;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  void Function(String)? onChanged;
  InputText(
      {required this.icon,
      required this.hint,
      required this.password,
      required this.controller,
      required this.maxLine,
      this.maxLength,
      this.keyboardType,
      this.inputFormatters,
      this.onChanged});

  @override
  _InputTextState createState() => _InputTextState();
}

class _InputTextState extends State<InputText> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          border:
              Border.all(color: Color.fromARGB(249, 241, 241, 241), width: 1.5),
          borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: <Widget>[
          // Container(
          //     width: 60,
          //     child: Icon(
          //       widget.icon,
          //       size: 15,
          //       color: Color(0xFFBB9B9B9),
          //     )),
          SizedBox(
            width: 15,
          ),
          Expanded(
            child: TextField(
              controller: widget.controller,
              obscureText: widget.password,
              maxLines: widget.maxLine,
              keyboardType:
                  widget.keyboardType != null ? widget.keyboardType : null,
              inputFormatters: widget.inputFormatters != null
                  ? widget.inputFormatters
                  : null,
              maxLength: widget.maxLength != null ? widget.maxLength : null,
              style: GoogleFonts.poppins(
                  fontSize: 11, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 11,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 2),
                  border: InputBorder.none,
                  hintText: widget.hint),
              onChanged: widget.onChanged,
            ),
          )
        ],
      ),
    );
  }
}
