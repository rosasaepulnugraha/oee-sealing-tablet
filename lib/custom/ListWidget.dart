import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/color_constant.dart';

class listWidget extends StatelessWidget {
  void Function()? onTap;
  String text;
  IconData icon;
  listWidget(
      {super.key, required this.onTap, required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
        // color: Colors.white,
        child: Row(children: [
          Icon(
            icon,
            color: mDarkBlue,
          ),
          SizedBox(
            width: 20,
          ),
          Container(
            margin: EdgeInsets.only(top: 0),
            child: Text(
              text,
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Color.fromARGB(255, 90, 90, 90),
                  fontWeight: FontWeight.w500),
            ),
          ),
        ]),
      ),
    );
  }
}
