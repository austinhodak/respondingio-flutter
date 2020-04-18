import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:respondingio_flutter/utils/AgencyUtils.dart';
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
      return Text(DateFormat("HH:mm").format(DateTime.fromMillisecondsSinceEpoch(doc.data["times"]["dispatch"]["epoch"])))
          .fontSize(12)
          .fontWeight(FontWeight.w400)
          .textColor(TinyColor.fromString(doc.data["type"]["color"]).isDark() ? Colors.white : Colors.black);
    } else {
      return Container(width: 0, height: 0);
    }
  }

  Widget getAlert(DocumentSnapshot doc) {
    if (doc.data["alert"] != null) {
      return Row(
        children: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 16.0, left: 16),
              child: Icon(Icons.warning).iconColor(TinyColor(getAlertColor(doc.data["alert"]["severity"], doc)).isDark() ? Colors.white : Colors.black)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  doc.data["alert"]["text"].toString().toUpperCase().replaceAll(RegExp(r'\\n'), "\n"),
                  style:
                      GoogleFonts.roboto(textStyle: TextStyle(fontWeight: FontWeight.w700, color: TinyColor(getAlertColor(doc.data["alert"]["severity"], doc)).isDark() ? Colors.white : Colors.black)),
                )
              ],
            ),
          ),
        ],
      ).padding(top: 8, bottom: 8, right: 16).backgroundColor(getAlertColor(doc.data["alert"]["severity"], doc));
    } else {
      return Container(width: 0, height: 0);
    }
  }

  Color getAlertColor(String severity, doc) {
    if (doc.data['alert']['color'] != null) {
      return TinyColor.fromString(doc.data['alert']['color']).color;
    }
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

  Widget getPriority(DocumentSnapshot doc) {
    if (doc.data["type"]["priority"] != null) {
      return Text(
        doc.data["type"]["priority"].toString(),
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: TinyColor.fromString(doc.data["type"]["color"]).isDark() ? Colors.white : Colors.black),
      );
    } else {
      return Container(width: 0, height: 0);
    }
  }

  Widget getUnits(DocumentSnapshot doc) {
    var list = (doc.data['units'] as List<dynamic>);
    list.sort((a, b) => (a['displayName'] ?? a['unitID']).toString().compareTo((b['displayName'] ?? b['unitID']).toString()));
    if (doc.data['units'] != null) {
      return Wrap(
        children: list.map(
          (item) {
            var color = TinyColor.fromString(item['color'] ?? "#E0E0E0");
            return DecoratedBox(
              decoration: BoxDecoration(
                  color: color.color,
                  shape: BoxShape.rectangle, borderRadius: BorderRadius.all(Radius.circular(80.0)),
                  border: AgencyUtils().agencyIDs.contains(item['agencyID']) == true ? Border.all(
                    color: Theme.of(context).brightness == Brightness.light ? Colors.black87 : Colors.white,
                    width: 1.5
                  ) : null,
              ),
              child: Text(
                item['displayName'] ?? item['unitID'],
                style: GoogleFonts.roboto(textStyle: TextStyle(
                    fontSize: 13,
                    //decoration: AgencyUtils().agencyIDs.contains(item['agencyID']) == true ? TextDecoration.underline : TextDecoration.none,
                    //fontStyle: AgencyUtils().agencyIDs.contains(item['agencyID']) == true ? FontStyle.italic : FontStyle.normal,
                    fontWeight: FontWeight.w700,
                    color: color.isDark() ? Colors.white : Colors.black
                )),
              ).padding(left: 8, right: 8, top: 5, bottom: 5),
            ).padding(left: 8, bottom: 8);
          }
        ).toList(),
      ).padding(bottom: 4);
    } else {
      return Container(width: 0, height: 0);
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
                          padding: EdgeInsets.only(left: 16.0, top: 16.0, bottom: 16, right: 16.0),
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(right: 16.0),
                                child: Image.asset(
                                  "assets/icons8_fire_alarm_100.png",
                                  height: 25,
                                  color: TinyColor.fromString(doc.data["type"]["color"]).isDark() ? Colors.white : Colors.black,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      doc.data["type"]["CADCode"].toString().replaceAll(RegExp(r'\\n'), "\n"),
                                      style: GoogleFonts.roboto(
                                          textStyle: TextStyle(fontWeight: FontWeight.w700, color: TinyColor.fromString(doc.data["type"]["color"]).isDark() ? Colors.white : Colors.black)),
                                    ),
                                    Text(
                                      doc.data["address"]["fromText"].toString(),
                                      style: GoogleFonts.roboto(
                                          textStyle:
                                              TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: TinyColor.fromString(doc.data["type"]["color"]).isDark() ? Colors.white : Colors.black)),
                                    )
                                  ],
                                ),
                              ),
                              Column(
                                children: <Widget>[getPriority(doc), getDispatchTime(doc)],
                              )
                            ],
                          ),
                        ).backgroundColor(TinyColor.fromString(doc.data["type"]["color"]).color ?? Colors.grey[800]),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            (doc.data["remarks"] as List<dynamic>).join("\n\u2015\n"),
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                          ).padding(left: 12, right: 12, top: 12),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          getUnits(doc)
                        ],
                      ).padding(left: 4, right: 12, top: 12),
                    ],
                  ).backgroundColor(Theme.of(context).brightness == Brightness.light ? Colors.white : TinyColor.fromString("#1d1d1d").color),
                );
              },
            );
          },
        ))
      ],
    ).animate(Duration(milliseconds: 500), Curves.elasticIn);
  }

  Color hexToColor(String code) {
    return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }
}
