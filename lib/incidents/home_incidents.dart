import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:respondingio_flutter/utils/IncidentUtils.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:tinycolor/tinycolor.dart';

class HomeIncidents extends StatefulWidget {
  HomeIncidents({Key key});

  @override
  State<HomeIncidents> createState() => _HomeIncidents();
}

class _HomeIncidents extends State<HomeIncidents> {
  Widget getDispatchTime(DocumentSnapshot doc) {
    if (doc.data["times"] != null && doc.data["times"]["dispatch"] != null && doc.data["times"]["dispatch"]["epoch"] != null) {
      return Text(DateFormat("HH:mm").format(DateTime.fromMillisecondsSinceEpoch(doc.data["times"]["dispatch"]["epoch"]))).fontSize(12).fontWeight(FontWeight.w400).textColor(Colors.white);
    } else {
      return Container(width: 0, height: 0);
    }
  }

  Widget getAlert(DocumentSnapshot doc) {
    if (doc.data["alert"] != null) {
      return Row(
        children: <Widget>[
          Padding(padding: EdgeInsets.only(right: 16.0, left: 16), child: Icon(Icons.warning).iconColor(Colors.white)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  doc.data["alert"]["text"].toString().replaceAll(RegExp(r'\\n'), "\n"),
                  style: GoogleFonts.roboto(textStyle: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                )
              ],
            ),
          ),
        ],
      ).padding(top: 8, bottom: 8).backgroundColor(getAlertColor(doc.data["alert"]["severity"]));
    } else {
      return Container(width: 0, height: 0);
    }
  }

  Color getAlertColor(String severity) {
    switch (severity.toUpperCase()) {
      case "HIGH":
        return Colors.redAccent[700];
      case "MED":
        return Colors.orangeAccent[700];
      case "NONE":
        return Colors.grey[700];
      case "LOW":
      default:
        return Colors.blueAccent[700];
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Flexible(
            child: StreamBuilder<List<DocumentSnapshot>>(
          stream: IncidentUtils().controller.stream,
          builder: (context, AsyncSnapshot<List<DocumentSnapshot>> event) {
            if (!event.hasData || event.data.isEmpty) {
              return Container(
                child: Center(
                  child: Text("No Active Incidents"),
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(4.0),
              reverse: false,
              itemCount: event.data.length,
              itemBuilder: (_, int index) {
                DocumentSnapshot doc = event.data[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      getAlert(doc),
                      Container(
                        decoration: BoxDecoration(
                            boxShadow: <BoxShadow>[BoxShadow(color: Colors.black54, blurRadius: 3.0, offset: Offset(0.0, 0))],
                            color: Theme.of(context).brightness == Brightness.light ? Colors.white : TinyColor.fromString("#1d1d1d").color),
                        child: Padding(
                          padding: EdgeInsets.only(left: 16.0, top: 12.0, bottom: 12, right: 16.0),
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(right: 16.0),
                                child: Image.asset(
                                  "assets/icons8_fire_alarm_100.png",
                                  height: 25,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      doc.data["type"]["CADCode"].toString().replaceAll(RegExp(r'\\n'), "\n"),
                                      style: GoogleFonts.roboto(textStyle: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                                    ),
                                    Text(
                                      doc.data["address"]["fromText"].toString(),
                                      style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white)),
                                    )
                                  ],
                                ),
                              ),
                              Column(
                                children: <Widget>[
                                  Text(
                                    doc.data["type"]["priority"].toString(),
                                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.white),
                                  ),
                                  getDispatchTime(doc)
                                ],
                              )
                            ],
                          ),
                        ).backgroundColor(TinyColor.fromString(doc.data["type"]["color"]).color ?? Colors.grey[800]),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            (doc.data["remarks"] as List<dynamic>).join("\n"),
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                          ).padding(all: 12),
                        ],
                      )
                    ],
                  ),
                );
              },
            );
          },
        ))
      ],
    ).animate(Duration(milliseconds: 500), Curves.elasticIn);
  }
}
