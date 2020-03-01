import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:intl/intl.dart';
import 'package:respondingio_flutter/models/AgencyFS.dart';
import 'package:respondingio_flutter/utils/AgencyUtils.dart';
import 'package:respondingio_flutter/utils/RespondingUtils.dart';
import 'package:respondingio_flutter/widgets/PositionWidget.dart';
import 'package:tinycolor/tinycolor.dart';

import 'models/Position.dart';

class FeedWidget extends StatefulWidget {
  FeedWidget({Key key});

  @override
  State<FeedWidget> createState() => _FeedWidget();
}

enum Test2 { test1, test2 }

class _FeedWidget extends State<FeedWidget> {
  Widget getPositionListWidget(Map<dynamic, dynamic> map) {
    if (map.isNotEmpty) {
      return SizedBox(
        height: 24,
        child: ListView.builder(
            itemCount: map.length,
            shrinkWrap: false,
            scrollDirection: Axis.horizontal,
            itemBuilder: (ctx, int) {
              if (map.isNotEmpty)
                return PositionWidget(AgencyUtils().positions[map.keys.toList()[int]]);
              else
                return null;
            }),
      );
    } else {
      return Container(width: 0, height: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    String testString = "Nobody Responding";
    Test2 test = Test2.test2;
    return new Column(
      children: <Widget>[
        new Flexible(
            child: StreamBuilder<List<AgencyFS>>(
          stream: AgencyUtils().controller.stream,
          builder: (context, AsyncSnapshot<List<AgencyFS>> event) {
            if (!event.hasData || event.data.isEmpty) {
              return Container(
                child: Center(
                  child: Text(testString),
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(4.0),
              reverse: false,
              itemCount: event.data.length,
              itemBuilder: (_, int index) {
                String agencyID = event.data[index].agencyID;
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
                          padding: EdgeInsets.only(left: 16.0, top: 10.0, bottom: 10, right: 16.0),
                          child: Row(
                            children: <Widget>[
                              Text(
                                event.data[index].stationNumber,
                                style: GoogleFonts.roboto(textStyle: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.black)),
                              ),
                              Expanded(
                                child: Padding(
                                  child: Text(
                                    event.data[index].agencyName.toUpperCase(),
                                    style: GoogleFonts.roboto(textStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.black)),
                                    textAlign: TextAlign.left,
                                  ),
                                  padding: EdgeInsets.only(left: 16.0),
                                ),
                              ),
                              Padding(
                                child: Text(
                                  "",
                                  style: GoogleFonts.roboto(textStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black)),
                                  textAlign: TextAlign.left,
                                ),
                                padding: EdgeInsets.only(left: 24.0),
                              ),
                            ],
                          ),
                        ),
                        color: Colors.orange[400],
                      ),
                      Container(
                        decoration: BoxDecoration(
                            boxShadow: <BoxShadow>[BoxShadow(color: Colors.black54, blurRadius: 3.0, offset: Offset(0.0, 0))],
                            color: Theme.of(context).brightness == Brightness.light ? Colors.white : TinyColor.fromString("#1d1d1d").color),
                        child: StreamBuilder<Event>(
                          stream: FirebaseDatabase.instance.reference().child("users").orderByChild("responding/agency").equalTo(event.data[index].agencyID).onValue,
                          builder: (context, AsyncSnapshot<Event> event) {
                            if (!event.hasData || event.data.snapshot.value == null) {
                              return Container(
                                child: Center(
                                  child: Text(testString),
                                ),
                              );
                            }

                            Map<dynamic, dynamic> values = event.data.snapshot.value;
                            List<dynamic> list = values.keys.toList();

                            print(list);

                            return StatefulBuilder(builder: (context, StateSetter setter) {
                              return ListView.separated(
                                shrinkWrap: true,
                                padding: EdgeInsets.all(0.0),
                                reverse: false,
                                separatorBuilder: (context, index) => Container(color: Theme.of(context).brightness == Brightness.light ? Colors.grey[400] : Colors.black, height: 0.5),
                                itemCount: values.length,
                                itemBuilder: (_, int index) {
                                  dynamic user = values[list[index]];
                                  Map<dynamic, dynamic> positionValues = user["positions"][agencyID] ?? Map<dynamic, dynamic>();
                                  return StatefulBuilder(
                                    builder: (context, StateSetter newSetter) {
                                      return Container(
                                          padding: EdgeInsets.only(bottom: 4, top: 4),
                                          child: ListTile(
                                              title: Column(
                                            children: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Text(
                                                      "${user["name"]["firstName"]} ${user["name"]["lastName"]}",
                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                        color: user["responding"]["onScene"] == null
                                                            ? RespondingUtils().getRespondingToColors(user["responding"]["respondingToType"].toString().toUpperCase()).colorLight
                                                            : Colors.pinkAccent[400],
                                                        borderRadius: BorderRadius.all(
                                                          Radius.circular(200.0),
                                                        ),
                                                        border: Border.all(
                                                            color: user["responding"]["onScene"] == null
                                                                ? RespondingUtils().getRespondingToColors(user["responding"]["respondingToType"].toString().toUpperCase()).colorDark
                                                                : Colors.pink[800],
                                                            width: 1.0)),
                                                    child: Row(
                                                      children: <Widget>[
                                                        Container(
                                                          decoration: BoxDecoration(
                                                            color: user["responding"]["onScene"] == null
                                                                ? RespondingUtils().getRespondingToColors(user["responding"]["respondingToType"].toString().toUpperCase()).colorDark
                                                                : Colors.pink[800],
                                                            borderRadius: BorderRadius.all(
                                                              Radius.circular(200.0),
                                                            ),
                                                          ),
                                                          child: Padding(
                                                              padding: EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 2),
                                                              child: Text(
                                                                user["responding"]["onScene"] == null ? "${user["responding"]["respondingTo"]}".toUpperCase() : "ON SCENE",
                                                                style: GoogleFonts.roboto(textStyle: TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 13, letterSpacing: .5)),
                                                              )),
                                                        ),
                                                        Container(
                                                          child: Padding(
                                                              padding: EdgeInsets.only(left: 4, right: 8, top: 2, bottom: 2),
                                                              child: Text(
                                                                RespondingUtils().getTimestamp(user),
                                                                style: GoogleFonts.roboto(textStyle: TextStyle(fontWeight: FontWeight.w400, color: Colors.white, fontSize: 13, letterSpacing: .5)),
                                                              )),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              getPositionListWidget(positionValues)
                                            ],
                                          )));
                                    },
                                  );
                                },
                              );
                            });
                          },
                        ),
                        //decoration: BoxDecoration(boxShadow: []),
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
