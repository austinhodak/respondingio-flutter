import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respondingio_flutter/models/Position.dart';
import 'package:tinycolor/tinycolor.dart';

class PositionWidget extends StatelessWidget {
  PositionWidget(this.position);

  final Position position;

  @override
  Widget build(BuildContext context) {
    return Padding(
      child: Container(
        decoration: BoxDecoration(
            color: TinyColor.fromString(position.color).color,
            borderRadius: BorderRadius.all(
              Radius.circular(200.0),
            ),
            border: Border.all(color: TinyColor.fromString(position.color).darken(10).color, width: 1.0)),
        child: Row(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: TinyColor.fromString(position.color).darken(10).color,
                borderRadius: BorderRadius.all(
                  Radius.circular(200.0),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(left: 2, right: 2, top: 3, bottom: 3),
                child: Image.asset(
                  "assets/${position.getImage()}",
                  width: 15,
                ),
              ),
            ),
            Container(
              child: Padding(
                  padding: EdgeInsets.only(left: 4, right: 8),
                  child: Text(
                    position.name,
                    style: GoogleFonts.roboto(textStyle: TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 12)),
                  )),
            ),
          ],
        ),
      ),
      padding: EdgeInsets.only(right: 4, top: 4),
    );
  }
}
