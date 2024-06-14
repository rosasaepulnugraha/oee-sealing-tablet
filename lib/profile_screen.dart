import 'package:fancy_snackbar/fancy_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isuzu_oee_app/edit_password_screen.dart';
import 'package:isuzu_oee_app/edit_profile_screen.dart';
import 'package:isuzu_oee_app/main.dart';
import 'package:isuzu_oee_app/models/edit_password_model.dart';
import 'package:isuzu_oee_app/url.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:loadmore_listview/loadmore_listview.dart';
import 'package:lottie/lottie.dart';

import 'about_app_screen.dart';
import 'constants/color_constant.dart';
import 'custom/ListWidget.dart';
import 'models/profile_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;
  var storage = new FlutterSecureStorage();
  String token = "";
  var profileResult = new Profile();

  void _getItem() async {
    setState(() {
      // _isLoading = true;
    });
    try {
      //await storage.write(key: key, value: value);
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

  double windowWidth = 0;
  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: mBackgroundColor,
          toolbarHeight: 0,
          shadowColor: mBackgroundColor,
        ),
        backgroundColor: Colors.white,
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
            child: LoadMoreListView.builder(
                shrinkWrap: true,
                hasMoreItem: true,
                onRefresh: () async {
                  await Future.delayed(const Duration(seconds: 1), () {});
                },
                loadMoreWidget: Container(
                  margin: const EdgeInsets.all(20.0),
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(
                        Color.fromARGB(255, 95, 170, 60)),
                  ),
                ),
                itemCount: 1,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  return Container(
                    child: Stack(
                      children: [
                        //bg
                        Container(
                          margin: EdgeInsets.only(top: 80),
                          height: 120,
                          width: windowWidth < 411 ? 150 : 170,
                          decoration: BoxDecoration(
                              color: mBlueColor,
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromARGB(255, 109, 109, 109)
                                      .withOpacity(0.4),
                                  spreadRadius: 5,
                                  blurRadius: 5,
                                  offset: Offset(0, 2),
                                )
                              ],
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(100),
                                  bottomRight: Radius.circular(100))),
                        ),
                        Column(
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 20),
                              width: MediaQuery.of(context).size.width,
                              child: Text(
                                "Profile",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                    color: Color.fromARGB(255, 70, 70, 70),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            SizedBox(
                              height: 50,
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  left: windowWidth < 411 ? 42 : 62),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(100)),
                                    child: CircleAvatar(
                                      radius: 40.0,
                                      backgroundImage: NetworkImage(
                                          profileResult.user != null
                                              ? (Url().valPic +
                                                  (profileResult
                                                          .user?.picture ??
                                                      ""))
                                              : ""),
                                      backgroundColor: Colors.transparent,
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(left: 28),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                                255, 180, 180, 180),
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Text(
                                          profileResult.user != null
                                              ? profileResult.user!.division
                                              : "",
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                              color: Color.fromARGB(
                                                  255, 255, 255, 255),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(left: 30),
                                        width: windowWidth < 411
                                            ? windowWidth - 170
                                            : windowWidth - 190,
                                        child: Text(
                                          profileResult.user != null
                                              ? profileResult.user!.name
                                              : "",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.start,
                                          style: GoogleFonts.poppins(
                                              color: Color.fromARGB(
                                                  255, 73, 73, 73),
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                      Container(
                                        width: windowWidth < 411
                                            ? windowWidth - 170
                                            : windowWidth - 190,
                                        margin: EdgeInsets.only(left: 32),
                                        child: Text(
                                          profileResult.user != null
                                              ? profileResult.user!.email
                                              : "",
                                          textAlign: TextAlign.start,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.poppins(
                                              color: Color.fromARGB(
                                                  255, 94, 94, 94),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      Container(
                                        width: windowWidth < 411
                                            ? windowWidth - 170
                                            : windowWidth - 190,
                                        margin: EdgeInsets.only(left: 32),
                                        child: Text(
                                          profileResult.user != null
                                              ? "ID : " +
                                                  profileResult.user!.employeeId
                                              : "",
                                          textAlign: TextAlign.start,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.poppins(
                                              color: Color.fromARGB(
                                                  255, 94, 94, 94),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 50),
                              height: 10,
                              color: mBackgroundColor,
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            listWidget(
                              icon: Icons.edit,
                              onTap: () {
                                if (profileResult.user != null) {
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (context) =>
                                              EditProfileScreen(
                                                user: profileResult.user!,
                                              )))
                                      .then((value) => _getItem());
                                }
                              },
                              text: "Update Profile",
                            ),
                            listWidget(
                              icon: Icons.key_rounded,
                              onTap: () {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(
                                        builder: (context) =>
                                            EditPasswordScreen()))
                                    .then((value) => _getItem());
                              },
                              text: "Update Password",
                            ),
                            // listWidget(
                            //   icon: Icons.info,
                            //   onTap: () {
                            //     Navigator.of(context).push(MaterialPageRoute(
                            //         builder: (context) => AboutAppScreen()));
                            //   },
                            //   text: "About App",
                            // ),
                            listWidget(
                              icon: Icons.logout_rounded,
                              onTap: () async {
                                showModalBottomSheet(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  backgroundColor: Colors.white,
                                  context: context,
                                  isDismissible: true,
                                  builder: (BuildContext context) {
                                    return BottomSheet(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                      ),
                                      backgroundColor: Colors.white,
                                      onClosing: () {},
                                      builder: (BuildContext context) {
                                        return StatefulBuilder(
                                          builder: (BuildContext context,
                                                  setState) =>
                                              Container(
                                            padding:
                                                EdgeInsets.only(bottom: 20),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      left: 20,
                                                      top: 15,
                                                      bottom: 10,
                                                      right: 20),
                                                  child: Text(
                                                    "Are you sure you want to logout?",
                                                    textAlign: TextAlign.start,
                                                    style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 15,
                                                      letterSpacing: 0.0,
                                                      color: Color.fromARGB(
                                                          255, 41, 41, 41),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 20,
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: InkWell(
                                                        onTap: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Container(
                                                          margin: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      10,
                                                                  vertical: 5),
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      15,
                                                                  vertical: 7),
                                                          decoration:
                                                              BoxDecoration(
                                                                  gradient:
                                                                      LinearGradient(
                                                                          colors: [
                                                                            Color.fromARGB(
                                                                                255,
                                                                                238,
                                                                                238,
                                                                                238),
                                                                            Color.fromARGB(
                                                                                255,
                                                                                206,
                                                                                206,
                                                                                206),
                                                                          ],
                                                                          begin: Alignment
                                                                              .topLeft,
                                                                          end: Alignment
                                                                              .bottomRight,
                                                                          stops: [
                                                                            0.0,
                                                                            1.0
                                                                          ],
                                                                          tileMode: TileMode
                                                                              .clamp),
                                                                  border: Border.all(
                                                                      color: Color.fromARGB(
                                                                          210,
                                                                          255,
                                                                          255,
                                                                          255),
                                                                      width: 2),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Color.fromARGB(
                                                                              209,
                                                                              189,
                                                                              189,
                                                                              189)
                                                                          .withOpacity(
                                                                              0.2),
                                                                      spreadRadius:
                                                                          2,
                                                                      blurRadius:
                                                                          3,
                                                                      offset:
                                                                          Offset(
                                                                              0,
                                                                              2),
                                                                    )
                                                                  ],
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5)),
                                                          child: Text(
                                                            "Cancel",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: GoogleFonts
                                                                .poppins(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontSize: 13,
                                                              letterSpacing:
                                                                  0.0,
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      41,
                                                                      41,
                                                                      41),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: InkWell(
                                                        onTap: () async {
                                                          if (_isLoading) {
                                                            return;
                                                          }
                                                          try {
                                                            await storage.write(
                                                                key: 'token',
                                                                value: "");
                                                            await storage.write(
                                                                key: 'keep',
                                                                value: "");
                                                            Navigator.of(context).pushAndRemoveUntil(
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            MyApp()),
                                                                (Route<dynamic>
                                                                        route) =>
                                                                    false);
                                                          } catch (x) {
                                                            Future.delayed(
                                                                Duration(
                                                                    seconds: 2),
                                                                () {
                                                              setState(() {
                                                                _isLoading =
                                                                    false;
                                                              });
                                                            });

                                                            await storage.write(
                                                                key: 'token',
                                                                value: "");
                                                            await storage.write(
                                                                key: 'keep',
                                                                value: "");
                                                            Navigator.of(context).pushAndRemoveUntil(
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            MyApp()),
                                                                (Route<dynamic>
                                                                        route) =>
                                                                    false);
                                                          }
                                                        },
                                                        child: Container(
                                                          margin: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      10,
                                                                  vertical: 5),
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      15,
                                                                  vertical: 7),
                                                          decoration:
                                                              BoxDecoration(
                                                                  gradient:
                                                                      LinearGradient(
                                                                          colors: [
                                                                            mBlueColor,
                                                                            mBlueColor,
                                                                          ],
                                                                          begin: Alignment
                                                                              .topLeft,
                                                                          end: Alignment
                                                                              .bottomRight,
                                                                          stops: [
                                                                            0.0,
                                                                            1.0
                                                                          ],
                                                                          tileMode: TileMode
                                                                              .clamp),
                                                                  border: Border.all(
                                                                      color: Color.fromARGB(
                                                                          210,
                                                                          255,
                                                                          255,
                                                                          255),
                                                                      width: 2),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Color.fromARGB(
                                                                              209,
                                                                              189,
                                                                              189,
                                                                              189)
                                                                          .withOpacity(
                                                                              0.2),
                                                                      spreadRadius:
                                                                          2,
                                                                      blurRadius:
                                                                          3,
                                                                      offset:
                                                                          Offset(
                                                                              0,
                                                                              2),
                                                                    )
                                                                  ],
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5)),
                                                          child: Text(
                                                            _isLoading
                                                                ? "Loading ..."
                                                                : "Confirm",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: GoogleFonts
                                                                .poppins(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontSize: 13,
                                                              letterSpacing:
                                                                  0.0,
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      255,
                                                                      255,
                                                                      255),
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
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                              text: "Logout",
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                })));
  }
}
