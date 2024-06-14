import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SearchInput extends StatefulWidget {
  String nama;
  TextEditingController controller;
  double? width;
  IconData icons;
  void Function() onclick;
  SearchInput(
      {super.key,
      required this.nama,
      required this.controller,
      required this.icons,
      this.width,
      required this.onclick});

  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 40,
          width: widget.width == null ? 180 : widget.width,
          // padding: EdgeInsets.symmetric(horizontal: 5),
          // margin: EdgeInsets.symmetric(horizontal: 0),
          decoration: BoxDecoration(
              color: Color.fromARGB(255, 255, 255, 255),
              border: Border.all(
                  color: Color.fromARGB(155, 240, 240, 240), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(115, 241, 241, 241).withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: Offset(0, 2),
                )
              ],
              borderRadius: BorderRadius.circular(30)),
          child: Row(
            children: <Widget>[
              Container(
                width: 15,
              ),
              Expanded(
                child: TextField(
                  maxLines: 1,

                  controller: widget.controller,
                  style: TextStyle(
                    fontFamily: "Netflix",
                    fontWeight: FontWeight.w600,
                    height: 0.3,
                    fontSize: 11,
                    letterSpacing: 0.0,
                    color: Color.fromARGB(255, 83, 83, 83),
                  ),
                  // keyboardType: SearchInputType.numberWithOptions(decimal: true),
                  // inputFormatters: [
                  //   FilteringSearchInputFormatter.allow(
                  //       RegExp(r'^\d+\.?\d{0,1}')),
                  //   // FilteringSearchInputFormatter.allow(
                  //   //     RegExp(r'^\d+\.?\d{0,1}')),
                  //   // FilteringSearchInputFormatter.allow(
                  //   //     RegExp(r'^([0-9]|[1-9][0-9]|100)$')),
                  // ],
                  decoration: InputDecoration(
                      hintStyle: TextStyle(
                        fontFamily: "Netflix",
                        fontWeight: FontWeight.w400,
                        fontSize: 11,
                        height: 0.3,
                        letterSpacing: 0.0,
                        color: Color.fromARGB(255, 150, 150, 150),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                      border: InputBorder.none,
                      hintText: "${widget.nama}"),
                ),
              ),
              Container(
                width: 10,
              ),
              InkWell(
                onTap: widget.onclick,
                child: Icon(
                  widget.icons,
                  color: const Color.fromARGB(255, 131, 131, 131),
                  size: 20,
                ),
              ),
              Container(
                width: 10,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
