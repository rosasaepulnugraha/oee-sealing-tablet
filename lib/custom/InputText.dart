import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

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
      height: 50,
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
                  height: 0.3, fontSize: 13, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 13,
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
