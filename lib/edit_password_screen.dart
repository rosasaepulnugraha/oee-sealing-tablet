import 'dart:async';
import 'dart:io';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:fancy_snackbar/fancy_snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:isuzu_oee_app/models/edit_password_model.dart';
import 'package:isuzu_oee_app/models/edit_photo_profile_model.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:lottie/lottie.dart';
import 'package:isuzu_oee_app/constants/color_constant.dart';
import 'package:isuzu_oee_app/models/edit_profile_model.dart';
import 'package:isuzu_oee_app/models/profile_model.dart';

import '../main.dart';
import '../url.dart';

class EditPasswordScreen extends StatefulWidget {
  EditPasswordScreen({super.key});

  @override
  State<EditPasswordScreen> createState() => _EditPasswordScreenState();
}

class _EditPasswordScreenState extends State<EditPasswordScreen> {
  TextEditingController oldPassword = new TextEditingController();
  TextEditingController newPassword = new TextEditingController();
  TextEditingController confirmNewPassword = new TextEditingController();
  var storage = new FlutterSecureStorage();
  String token = "";
  bool _isLoading = false;
  String url = "";
  bool _passwordVisible = true;
  bool _passwordVisible2 = true;
  bool _passwordVisible3 = true;

  bool _keyboardVisible = false;
  late StreamSubscription<bool> keyboardSubscription;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mBlueColor,
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
              Container(
                margin: EdgeInsets.only(top: 60),
                child: Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(top: 0),
                      child: Text(
                        "Update Password",
                        style: GoogleFonts.poppins(
                            fontSize: 17,
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    Positioned(
                      right: 20,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          // alignment: Alignment.center,
                          // padding: EdgeInsets.all(5),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: mBlueColor,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 20),
                height: 50,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(45),
                        topRight: Radius.circular(45))),
              ),
              Expanded(
                  child: Container(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 10, top: 20),
                          child: Text(
                            "Old Password",
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: mTitleBlue,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color.fromARGB(250, 230, 230, 230),
                                  width: 1.5),
                              borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            children: <Widget>[
                              SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: TextField(
                                  controller: oldPassword,
                                  obscureText: _passwordVisible,
                                  style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600),
                                  decoration: InputDecoration(
                                      hintStyle:
                                          GoogleFonts.poppins(fontSize: 15),
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
                                      hintText: "Enter here..."),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 10),
                          child: Text(
                            "New Password",
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: mTitleBlue,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color.fromARGB(250, 230, 230, 230),
                                  width: 1.5),
                              borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            children: <Widget>[
                              SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: TextField(
                                  controller: newPassword,
                                  obscureText: _passwordVisible2,
                                  style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600),
                                  decoration: InputDecoration(
                                      hintStyle:
                                          GoogleFonts.poppins(fontSize: 15),
                                      border: InputBorder.none,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          // Based on passwordVisible state choose the icon
                                          _passwordVisible2
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          size: 22,
                                          color: _passwordVisible2
                                              ? Colors.grey
                                              : Color.fromARGB(
                                                  255, 224, 224, 224),
                                        ),
                                        onPressed: () {
                                          // Update the state i.e. toogle the state of passwordVisible variable
                                          setState(() {
                                            _passwordVisible2 =
                                                !_passwordVisible2;
                                          });
                                        },
                                      ),
                                      hintText: "Enter here..."),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 10),
                          child: Text(
                            "Confirmation New Password",
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: mTitleBlue,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color.fromARGB(250, 230, 230, 230),
                                  width: 1.5),
                              borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            children: <Widget>[
                              SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: TextField(
                                  controller: confirmNewPassword,
                                  obscureText: _passwordVisible3,
                                  style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600),
                                  decoration: InputDecoration(
                                      hintStyle:
                                          GoogleFonts.poppins(fontSize: 15),
                                      border: InputBorder.none,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          // Based on passwordVisible state choose the icon
                                          _passwordVisible3
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          size: 22,
                                          color: _passwordVisible3
                                              ? Colors.grey
                                              : Color.fromARGB(
                                                  255, 224, 224, 224),
                                        ),
                                        onPressed: () {
                                          // Update the state i.e. toogle the state of passwordVisible variable
                                          setState(() {
                                            _passwordVisible3 =
                                                !_passwordVisible3;
                                          });
                                        },
                                      ),
                                      hintText: "Enter here..."),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        if (_keyboardVisible == true) ...[
                          SizedBox(
                            height: 250,
                          )
                        ],
                        PrimaryButton(
                          btnText: "Save",
                          login: true,
                          onTap: () async {
                            Future.delayed(const Duration(milliseconds: 0), () {
                              setState(() {
                                _isLoading = true;
                              });
                            });
                            token = await storage.read(key: "token") ?? "";

                            if (oldPassword.text == "" ||
                                newPassword.text == "" ||
                                confirmNewPassword.text == "") {
                              setState(() {
                                _isLoading = false;
                              });
                              FancySnackbar.showSnackbar(
                                context,
                                snackBarType: FancySnackBarType.error,
                                title: "Failed!",
                                message:
                                    "all columns are required to be filled in!",
                                duration: 5,
                                onCloseEvent: () {},
                              );
                              return;
                            }

                            try {
                              Future.delayed(const Duration(milliseconds: 0),
                                  () {
                                setState(() {
                                  _isLoading = true;
                                });
                              });
                              EditPassword.connectToApi(token, oldPassword.text,
                                      newPassword.text, confirmNewPassword.text)
                                  .then((value) {
                                setState(() {
                                  Future.delayed(
                                      const Duration(milliseconds: 2000), () {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  });
                                  //print(storage.read(key: "token"));
                                  if (value.status == 200) {
                                    FancySnackbar.showSnackbar(
                                      context,
                                      snackBarType: FancySnackBarType.success,
                                      title: "Successfully!",
                                      message: value.message,
                                      duration: 1,
                                      onCloseEvent: () {
                                        Navigator.pop(context);
                                        // Navigator.pushReplacement(context,
                                        //     MaterialPageRoute(builder: (context) {
                                        //   return NavigateScreen(
                                        //     id: 1,
                                        //   );
                                        // }));
                                      },
                                    );
                                  } else {
                                    FancySnackbar.showSnackbar(
                                      context,
                                      snackBarType: FancySnackBarType.error,
                                      title: "Failed!",
                                      message: value.message,
                                      duration: 5,
                                      onCloseEvent: () {},
                                    );
                                  }
                                });
                              });
                            } catch (x) {
                              Future.delayed(const Duration(milliseconds: 2000),
                                  () {
                                setState(() {
                                  _isLoading = false;
                                });
                              });
                            }
                          },
                        ),
                        SizedBox(
                          height: 40,
                        )
                      ],
                    ),
                  ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
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
              maxLines: widget.maxLine,
              keyboardType:
                  widget.keyboardType != null ? widget.keyboardType : null,
              inputFormatters: widget.inputFormatters != null
                  ? widget.inputFormatters
                  : null,
              maxLength: widget.maxLength != null ? widget.maxLength : null,
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 14,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 5),
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

class InputTextDouble extends StatefulWidget {
  final IconData icon;
  final String hint;
  final bool password;
  final TextEditingController controller;
  final int maxLine;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  InputTextDouble(
      {required this.icon,
      required this.hint,
      required this.password,
      required this.controller,
      required this.maxLine,
      required this.inputFormatters,
      this.maxLength});

  @override
  _InputTextDoubleState createState() => _InputTextDoubleState();
}

class _InputTextDoubleState extends State<InputTextDouble> {
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
              maxLines: widget.maxLine,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: widget.inputFormatters,
              maxLength: widget.maxLength != null ? widget.maxLength : null,
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 14,
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
