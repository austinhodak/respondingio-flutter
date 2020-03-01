import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respondingio_flutter/utils/IncidentUtils.dart';

class HomeIncidents extends StatefulWidget {
  HomeIncidents({Key key});

  @override
  State<HomeIncidents> createState() => _HomeIncidents();
}

class _HomeIncidents extends State<HomeIncidents> {
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
                      Container(
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
                                  Text(
                                    "TIME",
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                        color: Colors.red[400],
                      ),
                      Container(
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            (doc.data["remarks"] as List<dynamic>).join("\n"),
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            );
          },
        ))
      ],
    );
  }
}
