import 'dart:developer';
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
import 'package:isuzu_oee_app/constants/color_constant.dart';
import 'package:isuzu_oee_app/url.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';

import 'custom/InputText.dart';
import 'main.dart';
import 'models/edit_password_model.dart';
import 'models/edit_photo_profile_model.dart';
import 'models/edit_profile_model.dart';
import 'models/profile_model.dart';

class ProfileManagementScreen extends StatefulWidget {
  const ProfileManagementScreen({super.key});

  @override
  State<ProfileManagementScreen> createState() =>
      _ProfileManagementScreenState();
}

class _ProfileManagementScreenState extends State<ProfileManagementScreen> {
  double windowWidth = 0;
  TextEditingController oldPassword = new TextEditingController();
  TextEditingController newPassword = new TextEditingController();
  TextEditingController confirmNewPassword = new TextEditingController();

  TextEditingController nameController = new TextEditingController();
  TextEditingController operatorController = new TextEditingController();
  DateTime selectedDate = DateTime.now();
  final DateFormat formatter = DateFormat('yyyy-M-d');

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
                _getItem();
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

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
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

  bool _passwordVisible = true;
  bool _passwordVisible2 = true;
  bool _passwordVisible3 = true;

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

  File? _image;

  bool _isLoading = false;
  var storage = new FlutterSecureStorage();
  String token = "";
  var profileResult = new Profile();

  void _getItem() async {
    setState(() {
      // _isLoading = true;
    });
    try {
      token = await storage.read(key: "token") ?? "";

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
          nameController.text = profileResult.user!.name;
          operatorController.text = profileResult.user!.employeeId;
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
                width: windowWidth / 2.5,
                margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
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
                    borderRadius: BorderRadius.circular(20)),
                child: Stack(children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(bottom: 50),
                          height: 80,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                image:
                                    AssetImage('assets/images/bgProfile.png'),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: InkWell(
                      onTap: () {
                        getImageFromGallery();
                      },
                      child: Container(
                        margin: EdgeInsets.only(top: 40),
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100)),
                        // width: MediaQuery.of(context).size.width,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 30.0,
                              backgroundImage: NetworkImage(
                                  profileResult.user != null
                                      ? (Url().valPic +
                                          (profileResult.user?.picture ?? ""))
                                      : ""),
                              backgroundColor: Colors.transparent,
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                // alignment: Alignment.center,
                                // padding: EdgeInsets.all(5),
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border:
                                        Border.all(color: mTitleBlue, width: 2),
                                    borderRadius: BorderRadius.circular(5)),
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
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      margin: EdgeInsets.only(top: 110),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            profileResult.user != null
                                ? profileResult.user!.name
                                : "",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                color: mDarkBlue,
                                fontSize: windowWidth < 1400 ? 17 : 22,
                                fontWeight: FontWeight.w700),
                          ),
                          Text(
                            profileResult.user != null
                                ? profileResult.user!.division
                                : "",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                color: mDarkBlue.withOpacity(0.5),
                                fontSize: windowWidth < 1400 ? 11 : 14,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: InkWell(
                      onTap: () async {
                        showDialog(
                            barrierDismissible: true,
                            context: context,
                            builder: (BuildContext dialogcontext) {
                              String formattedDate =
                                  formatter.format(selectedDate);
                              return StatefulBuilder(
                                builder:
                                    (BuildContext dialogcontext, setState) =>
                                        AlertDialog(
                                  content: Container(
                                    height: 340,
                                    width:
                                        MediaQuery.of(context).size.width / 3,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          child: Text(
                                            "Edit Employee Profile",
                                            textAlign: TextAlign.start,
                                            style: GoogleFonts.poppins(
                                                color: mDarkBlue,
                                                fontSize: windowWidth < 1400
                                                    ? 14
                                                    : 18,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),

                                        // Container(
                                        //   margin: EdgeInsets.only(bottom: 10),
                                        //   child: Text(
                                        //     "Contact",
                                        //     style: GoogleFonts.poppins(
                                        //         fontSize: 14,
                                        //         color: mTitleBlue,
                                        //         fontWeight: FontWeight.w600),
                                        //   ),
                                        // ),
                                        // Row(
                                        //   children: [
                                        //     Container(
                                        //       width: 100,
                                        //       decoration: BoxDecoration(
                                        //           border: Border.all(
                                        //               color: Color.fromARGB(
                                        //                   250, 230, 230, 230),
                                        //               width: 1),
                                        //           borderRadius:
                                        //               BorderRadius.circular(10)),
                                        //       // width: 150,
                                        //       child: CustomDropdown<dynamic>(
                                        //         // hintText: "+",
                                        //         initialItem: "+62",
                                        //         items: ["+62", "+1", "+31"],
                                        //         decoration:
                                        //             CustomDropdownDecoration(
                                        //           listItemStyle: TextStyle(
                                        //             fontFamily: "Netflix",
                                        //             fontWeight: FontWeight.w600,
                                        //             fontSize: 14,
                                        //             letterSpacing: 0.0,
                                        //             color: Color.fromARGB(
                                        //                 255, 83, 83, 83),
                                        //           ),
                                        //           headerStyle: TextStyle(
                                        //             fontFamily: "Netflix",
                                        //             fontWeight: FontWeight.w600,
                                        //             fontSize: 14,
                                        //             letterSpacing: 0.0,
                                        //             color: Color.fromARGB(
                                        //                 255, 83, 83, 83),
                                        //           ),
                                        //           hintStyle: TextStyle(
                                        //             fontFamily: "Netflix",
                                        //             fontWeight: FontWeight.w600,
                                        //             fontSize: 14,
                                        //             letterSpacing: 0.0,
                                        //             color: Color.fromARGB(
                                        //                 255, 110, 110, 110),
                                        //           ),
                                        //         ),
                                        //         // initialItem: "Tomat",
                                        //         onChanged: (value) {
                                        //           setState(() {
                                        //             controllerConnection = value;
                                        //           });
                                        //         },
                                        //       ),
                                        //     ),
                                        //     SizedBox(
                                        //       width: 20,
                                        //     ),
                                        //     Expanded(
                                        //       child: InputText(
                                        //         icon: Icons
                                        //             .label_important_outline_sharp,
                                        //         hint: "xxxx",
                                        //         password: false,
                                        //         controller: controllerPort,
                                        //         maxLine: 1,
                                        //       ),
                                        //     ),
                                        //   ],
                                        // ),

                                        Container(
                                          margin: EdgeInsets.only(
                                              bottom: 10, top: 20),
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
                                          hint:
                                              "Enter your Employee ID here...",
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
                                          height: 35,
                                        ),
                                        InkWell(
                                          onTap: () async {
                                            if (_isLoading) {
                                              return;
                                            }
                                            Future.delayed(
                                                const Duration(milliseconds: 0),
                                                () {
                                              setState(() {
                                                _isLoading = true;
                                              });
                                            });
                                            token = await storage.read(
                                                    key: "token") ??
                                                "";

                                            if (nameController.text == "" ||
                                                operatorController.text == "") {
                                              setState(() {
                                                _isLoading = false;
                                              });
                                              FancySnackbar.showSnackbar(
                                                dialogcontext,
                                                snackBarType:
                                                    FancySnackBarType.error,
                                                title: "Failed!",
                                                message:
                                                    "all columns are required to be filled in!",
                                                duration: 5,
                                                onCloseEvent: () {},
                                              );
                                              return;
                                            }

                                            try {
                                              Future.delayed(
                                                  const Duration(
                                                      milliseconds: 0), () {
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
                                                      const Duration(
                                                          milliseconds: 2000),
                                                      () {
                                                    setState(() {
                                                      _isLoading = false;
                                                    });
                                                  });
                                                  //print(storage.read(key: "token"));
                                                  if (value.status == 200) {
                                                    FancySnackbar.showSnackbar(
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
                                                    FancySnackbar.showSnackbar(
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
                                                      milliseconds: 2000), () {
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
                                                    BorderRadius.circular(10)),
                                            padding: EdgeInsets.symmetric(
                                                vertical: 12, horizontal: 15),
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
                                                                  fontSize: 16),
                                                        ),
                                                      ],
                                                    )
                                                  : Text(
                                                      "Save",
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
                                  ),
                                ),
                              );
                            });
                      },
                      child: Container(
                        // alignment: Alignment.center,
                        // padding: EdgeInsets.all(5),
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                            color: Color.fromARGB(255, 241, 247, 255),
                            borderRadius: BorderRadius.circular(10)),
                        child: Icon(
                          Icons.edit,
                          color: mBlueColor,
                          size: 20,
                        ),
                      ),
                    ),
                  )
                ]),
              ),
              Container(
                width: windowWidth / 2.5,
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
                        ? BorderRadius.circular(20)
                        : BorderRadius.circular(25)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "General Information",
                      textAlign: TextAlign.start,
                      style: GoogleFonts.poppins(
                          color: mDarkBlue,
                          fontSize: 15,
                          fontWeight: FontWeight.w700),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: Container(
                          padding: windowWidth < 1400
                              ? EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10)
                              : EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 20),
                          decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromARGB(255, 203, 217, 248)
                                      .withOpacity(0.2),
                                  spreadRadius: 5,
                                  blurRadius: 10,
                                  offset: Offset(0, 15),
                                )
                              ],
                              color: Colors.white,
                              borderRadius: windowWidth < 1400
                                  ? BorderRadius.circular(20)
                                  : BorderRadius.circular(25)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Employee ID Number",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                    color: mDarkBlue.withOpacity(0.5),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500),
                              ),
                              Text(
                                profileResult.user != null
                                    ? profileResult.user!.employeeId
                                    : "",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                    color: mDarkBlue,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                              )
                            ],
                          ),
                        )),
                        SizedBox(
                          width: 20,
                        ),
                        Expanded(
                            child: Container(
                          padding: windowWidth < 1400
                              ? EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10)
                              : EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 20),
                          decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromARGB(255, 203, 217, 248)
                                      .withOpacity(0.2),
                                  spreadRadius: 5,
                                  blurRadius: 10,
                                  offset: Offset(0, 15),
                                )
                              ],
                              color: Colors.white,
                              borderRadius: windowWidth < 1400
                                  ? BorderRadius.circular(20)
                                  : BorderRadius.circular(25)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Email",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                    color: mDarkBlue.withOpacity(0.5),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500),
                              ),
                              Text(
                                profileResult.user != null
                                    ? profileResult.user!.email
                                    : "",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                    color: mDarkBlue,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                              )
                            ],
                          ),
                        ))
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: Container(
                          padding: windowWidth < 1400
                              ? EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10)
                              : EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 20),
                          decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromARGB(255, 203, 217, 248)
                                      .withOpacity(0.2),
                                  spreadRadius: 5,
                                  blurRadius: 15,
                                  offset: Offset(0, 15),
                                )
                              ],
                              color: Colors.white,
                              borderRadius: windowWidth < 1400
                                  ? BorderRadius.circular(20)
                                  : BorderRadius.circular(25)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Departement",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                    color: mDarkBlue.withOpacity(0.5),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500),
                              ),
                              Text(
                                profileResult.user != null
                                    ? profileResult.user!.division
                                    : "",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                    color: mDarkBlue,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                              )
                            ],
                          ),
                        )),
                        SizedBox(
                          width: 20,
                        ),
                        Expanded(
                            child: InkWell(
                          onTap: () async {
                            showDialog(
                                barrierDismissible: true,
                                context: context,
                                builder: (BuildContext dialogcontext) {
                                  String formattedDate =
                                      formatter.format(selectedDate);
                                  return StatefulBuilder(
                                    builder: (BuildContext dialogcontext,
                                            setState) =>
                                        AlertDialog(
                                      content: Container(
                                        height: 460,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                3,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              child: Text(
                                                "Edit Password",
                                                textAlign: TextAlign.start,
                                                style: GoogleFonts.poppins(
                                                    color: mDarkBlue,
                                                    fontSize: windowWidth < 1400
                                                        ? 14
                                                        : 18,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 15,
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(
                                                  bottom: 10, top: 20),
                                              child: Text(
                                                "Old Password",
                                                style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    color: mTitleBlue,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Color.fromARGB(
                                                          250, 230, 230, 230),
                                                      width: 1.5),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Row(
                                                children: <Widget>[
                                                  SizedBox(
                                                    width: 20,
                                                  ),
                                                  Expanded(
                                                    child: TextField(
                                                      controller: oldPassword,
                                                      obscureText:
                                                          _passwordVisible,
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                      decoration:
                                                          InputDecoration(
                                                              hintStyle: GoogleFonts
                                                                  .poppins(
                                                                      fontSize:
                                                                          15),
                                                              border:
                                                                  InputBorder
                                                                      .none,
                                                              suffixIcon:
                                                                  IconButton(
                                                                icon: Icon(
                                                                  // Based on passwordVisible state choose the icon
                                                                  _passwordVisible
                                                                      ? Icons
                                                                          .visibility_off
                                                                      : Icons
                                                                          .visibility,
                                                                  size: 22,
                                                                  color: _passwordVisible
                                                                      ? Colors
                                                                          .grey
                                                                      : Color.fromARGB(
                                                                          255,
                                                                          224,
                                                                          224,
                                                                          224),
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
                                                                  "Enter here..."),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            Container(
                                              margin:
                                                  EdgeInsets.only(bottom: 10),
                                              child: Text(
                                                "New Password",
                                                style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    color: mTitleBlue,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Color.fromARGB(
                                                          250, 230, 230, 230),
                                                      width: 1.5),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Row(
                                                children: <Widget>[
                                                  SizedBox(
                                                    width: 20,
                                                  ),
                                                  Expanded(
                                                    child: TextField(
                                                      controller: newPassword,
                                                      obscureText:
                                                          _passwordVisible2,
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                      decoration:
                                                          InputDecoration(
                                                              hintStyle: GoogleFonts
                                                                  .poppins(
                                                                      fontSize:
                                                                          15),
                                                              border:
                                                                  InputBorder
                                                                      .none,
                                                              suffixIcon:
                                                                  IconButton(
                                                                icon: Icon(
                                                                  // Based on passwordVisible state choose the icon
                                                                  _passwordVisible2
                                                                      ? Icons
                                                                          .visibility_off
                                                                      : Icons
                                                                          .visibility,
                                                                  size: 22,
                                                                  color: _passwordVisible2
                                                                      ? Colors
                                                                          .grey
                                                                      : Color.fromARGB(
                                                                          255,
                                                                          224,
                                                                          224,
                                                                          224),
                                                                ),
                                                                onPressed: () {
                                                                  // Update the state i.e. toogle the state of passwordVisible variable
                                                                  setState(() {
                                                                    _passwordVisible2 =
                                                                        !_passwordVisible2;
                                                                  });
                                                                },
                                                              ),
                                                              hintText:
                                                                  "Enter here..."),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            Container(
                                              margin:
                                                  EdgeInsets.only(bottom: 10),
                                              child: Text(
                                                "Confirmation New Password",
                                                style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    color: mTitleBlue,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Color.fromARGB(
                                                          250, 230, 230, 230),
                                                      width: 1.5),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Row(
                                                children: <Widget>[
                                                  SizedBox(
                                                    width: 20,
                                                  ),
                                                  Expanded(
                                                    child: TextField(
                                                      controller:
                                                          confirmNewPassword,
                                                      obscureText:
                                                          _passwordVisible3,
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                      decoration:
                                                          InputDecoration(
                                                              hintStyle: GoogleFonts
                                                                  .poppins(
                                                                      fontSize:
                                                                          15),
                                                              border:
                                                                  InputBorder
                                                                      .none,
                                                              suffixIcon:
                                                                  IconButton(
                                                                icon: Icon(
                                                                  // Based on passwordVisible state choose the icon
                                                                  _passwordVisible3
                                                                      ? Icons
                                                                          .visibility_off
                                                                      : Icons
                                                                          .visibility,
                                                                  size: 22,
                                                                  color: _passwordVisible3
                                                                      ? Colors
                                                                          .grey
                                                                      : Color.fromARGB(
                                                                          255,
                                                                          224,
                                                                          224,
                                                                          224),
                                                                ),
                                                                onPressed: () {
                                                                  // Update the state i.e. toogle the state of passwordVisible variable
                                                                  setState(() {
                                                                    _passwordVisible3 =
                                                                        !_passwordVisible3;
                                                                  });
                                                                },
                                                              ),
                                                              hintText:
                                                                  "Enter here..."),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: 45,
                                            ),
                                            InkWell(
                                              onTap: () async {
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

                                                if (oldPassword.text == "" ||
                                                    newPassword.text == "" ||
                                                    confirmNewPassword.text ==
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
                                                        "all columns are required to be filled in!",
                                                    duration: 5,
                                                    onCloseEvent: () {},
                                                  );
                                                  return;
                                                }

                                                try {
                                                  Future.delayed(
                                                      const Duration(
                                                          milliseconds: 0), () {
                                                    setState(() {
                                                      _isLoading = true;
                                                    });
                                                  });
                                                  EditPassword.connectToApi(
                                                          token,
                                                          oldPassword.text,
                                                          newPassword.text,
                                                          confirmNewPassword
                                                              .text)
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
                                                      if (value.status == 200) {
                                                        oldPassword.text = "";
                                                        newPassword.text = "";
                                                        confirmNewPassword
                                                            .text = "";
                                                        FancySnackbar
                                                            .showSnackbar(
                                                          dialogcontext,
                                                          snackBarType:
                                                              FancySnackBarType
                                                                  .success,
                                                          title:
                                                              "Successfully!",
                                                          message:
                                                              value.message,
                                                          duration: 1,
                                                          onCloseEvent: () {
                                                            setState(() {
                                                              _isLoading =
                                                                  false;
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
                                                        Future.delayed(
                                                            const Duration(
                                                                milliseconds:
                                                                    2000), () {
                                                          setState(() {
                                                            _isLoading = false;
                                                          });
                                                        });
                                                        FancySnackbar
                                                            .showSnackbar(
                                                          dialogcontext,
                                                          snackBarType:
                                                              FancySnackBarType
                                                                  .error,
                                                          title: "Failed!",
                                                          message:
                                                              value.message,
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
                                                    vertical: 12,
                                                    horizontal: 15),
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
                                                          "Save",
                                                          style: GoogleFonts
                                                              .poppins(
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
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromARGB(255, 203, 217, 248)
                                        .withOpacity(0.2),
                                    spreadRadius: 5,
                                    blurRadius: 15,
                                    offset: Offset(0, 15),
                                  )
                                ],
                                color: mDarkBlue,
                                borderRadius: windowWidth < 1400
                                    ? BorderRadius.circular(20)
                                    : BorderRadius.circular(25)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "EDIT PASSWORD",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                              ],
                            ),
                          ),
                        ))
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    // Row(
                    //   children: [
                    //     Expanded(
                    //         child: Container(
                    //       padding: windowWidth < 1400
                    //           ? EdgeInsets.symmetric(vertical: 10, horizontal: 10)
                    //           : EdgeInsets.symmetric(
                    //               vertical: 20, horizontal: 20),
                    //       decoration: BoxDecoration(
                    //           boxShadow: [
                    //             BoxShadow(
                    //               color: Color.fromARGB(255, 203, 217, 248)
                    //                   .withOpacity(0.2),
                    //               spreadRadius: 5,
                    //               blurRadius: 15,
                    //               offset: Offset(0, 15),
                    //             )
                    //           ],
                    //           color: Colors.white,
                    //           borderRadius: windowWidth < 1400
                    //               ? BorderRadius.circular(20)
                    //               : BorderRadius.circular(25)),
                    //       child: Column(
                    //         crossAxisAlignment: CrossAxisAlignment.start,
                    //         children: [
                    //           Text(
                    //             "Join Date",
                    //             textAlign: TextAlign.center,
                    //             style: GoogleFonts.poppins(
                    //                 color: mDarkBlue.withOpacity(0.5),
                    //                 fontSize: windowWidth < 1400 ? 11 : 14,
                    //                 fontWeight: FontWeight.w500),
                    //           ),
                    //           Text(
                    //             "12 February 2024",
                    //             textAlign: TextAlign.center,
                    //             style: GoogleFonts.poppins(
                    //                 color: mDarkBlue,
                    //                 fontSize: windowWidth < 1400 ? 17 : 22,
                    //                 fontWeight: FontWeight.w500),
                    //           )
                    //         ],
                    //       ),
                    //     )),
                    //     SizedBox(
                    //       width: 20,
                    //     ),
                    //     Expanded(
                    //         child: Container(
                    //       padding: windowWidth < 1400
                    //           ? EdgeInsets.symmetric(vertical: 10, horizontal: 10)
                    //           : EdgeInsets.symmetric(
                    //               vertical: 20, horizontal: 20),
                    //       decoration: BoxDecoration(
                    //           boxShadow: [
                    //             BoxShadow(
                    //               color: Color.fromARGB(255, 203, 217, 248)
                    //                   .withOpacity(0.2),
                    //               spreadRadius: 5,
                    //               blurRadius: 15,
                    //               offset: Offset(0, 15),
                    //             )
                    //           ],
                    //           color: Colors.white,
                    //           borderRadius: windowWidth < 1400
                    //               ? BorderRadius.circular(20)
                    //               : BorderRadius.circular(25)),
                    //       child: Column(
                    //         crossAxisAlignment: CrossAxisAlignment.start,
                    //         children: [
                    //           Text(
                    //             "Birthday",
                    //             textAlign: TextAlign.center,
                    //             style: GoogleFonts.poppins(
                    //                 color: mDarkBlue.withOpacity(0.5),
                    //                 fontSize: windowWidth < 1400 ? 11 : 14,
                    //                 fontWeight: FontWeight.w500),
                    //           ),
                    //           Text(
                    //             "28 January 1996",
                    //             textAlign: TextAlign.center,
                    //             style: GoogleFonts.poppins(
                    //                 color: mDarkBlue,
                    //                 fontSize: windowWidth < 1400 ? 17 : 22,
                    //                 fontWeight: FontWeight.w500),
                    //           )
                    //         ],
                    //       ),
                    //     ))
                    //   ],
                    // ),
                    // SizedBox(
                    //   height: 10,
                    // ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
