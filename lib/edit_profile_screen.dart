import 'dart:io';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:fancy_snackbar/fancy_snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:isuzu_oee_app/models/edit_photo_profile_model.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:lottie/lottie.dart';
import 'package:isuzu_oee_app/constants/color_constant.dart';
import 'package:isuzu_oee_app/models/edit_profile_model.dart';
import 'package:isuzu_oee_app/models/profile_model.dart';

import '../main.dart';
import '../url.dart';

class EditProfileScreen extends StatefulWidget {
  User user;
  EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String gender = "";
  String birthdate = "";
  TextEditingController nameController = new TextEditingController();
  TextEditingController operatorController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController addressController = new TextEditingController();
  var storage = new FlutterSecureStorage();
  String token = "";
  bool _isLoading = false;
  String url = "";

  getDa() async {
    url = await storage.read(key: "ip") ?? "";
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDa();
    setState(() {
      nameController.text = widget.user.name;
      operatorController.text = widget.user.employeeId;
      emailController.text = widget.user.email;
    });
  }

  DateTime selectedDate = DateTime.now();
  final DateFormat formatter = DateFormat('yyyy-M-d');

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

  void _getProfile() async {
    setState(() {
      // _isLoading = true;
    });
    try {
      //await storage.write(key: key, value: value);
      token = await storage.read(key: "token") ?? "";

      // EasyLoading.show(status: 'loading...');
      //print("Nama =" + emailController.text);
      Profile.connectToApi(token).then((value) async {
        // profileResult = value;
        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            _isLoading = false;
          });
        });
        if (value.statusCode == 200) {
          if (value.user != null) {
            widget.user = value.user!;
            setState(() {});
          }
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

  File? _image;
  final picker = ImagePicker();

//Image Picker function to get image from gallery
  Future getImageFromGallery() async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 30);

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      Future.delayed(const Duration(milliseconds: 0), () {
        setState(() {
          _isLoading = true;
        });
      });
      token = await storage.read(key: "token") ?? "";

      try {
        Future.delayed(const Duration(milliseconds: 0), () {
          setState(() {
            _isLoading = true;
          });
        });
        EditPhotoProfile.connectToApi(token, _image).then((value) {
          setState(() {
            Future.delayed(const Duration(milliseconds: 2000), () {
              setState(() {
                _getProfile();
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
                  // Navigator.pop(context);
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
        Future.delayed(const Duration(milliseconds: 2000), () {
          setState(() {
            _isLoading = false;
          });
        });
      }
    }
    setState(() {});
  }

//Image Picker function to get image from camera
  Future getImageFromCamera() async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 30);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      Future.delayed(const Duration(milliseconds: 0), () {
        setState(() {
          _isLoading = true;
        });
      });
      token = await storage.read(key: "token") ?? "";

      try {
        Future.delayed(const Duration(milliseconds: 0), () {
          setState(() {
            _isLoading = true;
          });
        });
        EditPhotoProfile.connectToApi(token, _image).then((value) {
          setState(() {
            Future.delayed(const Duration(milliseconds: 2000), () {
              setState(() {
                _getProfile();
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
                  // Navigator.pop(context);
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
        Future.delayed(const Duration(milliseconds: 2000), () {
          setState(() {
            _isLoading = false;
          });
        });
      }
    }
    setState(() {});
  }

  Future showOptions() async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: Text('Photo Gallery'),
            onPressed: () {
              // close the options modal
              Navigator.of(context).pop();
              // get image from gallery
              getImageFromGallery();
            },
          ),
          CupertinoActionSheetAction(
            child: Text('Camera'),
            onPressed: () {
              // close the options modal
              Navigator.of(context).pop();
              // get image from camera
              getImageFromCamera();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = formatter.format(selectedDate);

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
                        "My Profile",
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
                        Align(
                          alignment: Alignment.center,
                          child: InkWell(
                            onTap: () {
                              showOptions();
                            },
                            child: Container(
                              // width: MediaQuery.of(context).size.width,
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 40.0,
                                    backgroundImage: NetworkImage(
                                        Url().valPic + widget.user.picture),
                                    // _image == null
                                    //     ? NetworkImage(
                                    //         Url().valPic + widget.user.picture)
                                    //     : Image.file(_image!).image,
                                    backgroundColor: Colors.transparent,
                                  ),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      // alignment: Alignment.center,
                                      // padding: EdgeInsets.all(5),
                                      width: 23,
                                      height: 23,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                              color: mTitleBlue, width: 2),
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: Icon(
                                        Icons.edit_rounded,
                                        color: mTitleBlue,
                                        size: 15,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 10, top: 20),
                          child: Text(
                            "Name",
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: mTitleBlue,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        InputText(
                          icon: Icons.phone_rounded,
                          hint: "Enter your name here...",
                          password: false,
                          controller: nameController,
                          maxLine: 1,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 10),
                          child: Text(
                            "Employee ID",
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: mTitleBlue,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        InputText(
                          icon: Icons.phone_rounded,
                          hint: "Enter your Employee ID here...",
                          password: false,
                          controller: operatorController,
                          maxLine: 1,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^[0-9]*$')),
                          ],
                        ),
                        SizedBox(
                          height: 40,
                        ),
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

                            if (nameController.text == "" ||
                                operatorController.text == "") {
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
                              EditProfile.connectToApi(
                                      token,
                                      nameController.text,
                                      operatorController.text)
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
