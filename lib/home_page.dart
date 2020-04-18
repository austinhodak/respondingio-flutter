import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:respondingio_flutter/apparatus_home_page.dart';
import 'package:respondingio_flutter/feed_widget.dart';
import 'package:respondingio_flutter/home_more_page.dart';
import 'package:respondingio_flutter/incidents/home_incidents.dart';
import 'package:respondingio_flutter/models/AgencyFS.dart';
import 'package:respondingio_flutter/models/ResponseOption.dart';
import 'package:respondingio_flutter/utils/AgencyUtils.dart';
import 'package:respondingio_flutter/utils/RespondingUtils.dart';
import 'package:respondingio_flutter/widgets/FABBottomAppBar.dart';
import 'package:tinycolor/tinycolor.dart';
import 'authentication.dart';
import 'package:styled_widget/styled_widget.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, String title, this.auth, this.logout});

  final BaseAuth auth;
  final VoidCallback logout;

  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int _lastSelected = 0;
  bool isResponding = false;
  ImageIcon _fabIcon = ImageIcon(AssetImage("assets/icons8_steering_wheel_100.png"));
  static VoidCallback loggedOut;

  @override
  void initState() {
    super.initState();
    loggedOut = widget.logout;
    widget.auth.getCurrentUser().then((user) {
      FirebaseDatabase.instance.reference().child("users").child(user.uid).onValue.listen((Event event) {
        setState(() {
          _fabIcon = ImageIcon(AssetImage("assets/icons8_steering_wheel_100.png"));

          /*if (event.snapshot.value["responding"] == null) {
            isResponding = false;
            _fabIcon = ImageIcon(AssetImage("assets/icons8_steering_wheel_100.png"));
          } else {
            if (event.snapshot.value["respondingToType"] == "UNAVAILABLE") {
              isResponding = false;
              _fabIcon = ImageIcon(AssetImage("assets/icons8_steering_wheel_100.png"));
            } else {
              isResponding = true;
              _fabIcon = ImageIcon(AssetImage("assets/icons8_place_marker_96.png"));
            }

          }*/
        });
      });
    });
  }

  void _selectedTab(int index) {
    setState(() {
      _lastSelected = index;
    });
  }

  final List<Widget> _children = [FeedWidget(), HomeIncidents(), ApparatusHomePage(), HomeMorePage(loggedOut: loggedOut,)];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light ? null : TinyColor.fromString("#121212").color,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: GestureDetector(
        child: FloatingActionButton(
          onPressed: () {
            if (isResponding) {
              widget.auth.getCurrentUser().then((user) {
                RespondingUtils().markUserOnScene(user.uid);
              });
            } else {
              _settingModalBottomSheet(context);
            }
          },
          child: _fabIcon,
          elevation: 2.0,
          foregroundColor: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
        ),
        onLongPress: () {
          _settingModalBottomSheet(context);
        },
      ),
      bottomNavigationBar: FABBottomAppBar(
        notchedShape: CircularNotchedRectangle(),
        onTabSelected: _selectedTab,
        selectedColor: Theme.of(context).brightness == Brightness.light ? Colors.red[400] : Colors.white,
        color: Theme.of(context).brightness == Brightness.light ? Colors.grey[700] : Colors.grey[500],
        backgroundColor: Theme.of(context).brightness == Brightness.light ? Colors.white : TinyColor.fromString("#1F1F1F").color,
        items: [
          FABBottomAppBarItem(iconData: 'assets/feed_1.png', text: 'This', disabled: false),
          FABBottomAppBarItem(iconData: 'assets/icons8_fire_alarm_100.png', text: 'Is', disabled: false),
          FABBottomAppBarItem(iconData: 'assets/fire_truck_1.png', text: 'Bottom', disabled: false),
          FABBottomAppBarItem(iconData: 'assets/icons8_more_100.png', text: 'Bar', disabled: true),
        ],
      ),
      body: _children[_lastSelected],
    );
  }

  void _settingModalBottomSheet(context) {
    AgencyFS selectedAgency;

    if (AgencyUtils().agencies.length == 1) {
      selectedAgency = AgencyUtils().agencies.first;
    }

    ResponseOption selectedOption;

    List<Widget> getAgencyRadios(StateSetter setter) {
      List<Widget> widgets = new List<Widget>();
      for (AgencyFS agency in AgencyUtils().agencies) {
        widgets.add(RadioListTile<AgencyFS>(
          dense: false,
          title: Text("${agency.agencyShortName}").fontSize(15),
          activeColor: Colors.red,
          value: agency,
          groupValue: selectedAgency,
          onChanged: (AgencyFS value) {
            print(value);
            setter(() {
              selectedAgency = value;
            });
          },
        ));
      }
      return widgets;
    }

    List<Widget> getResponseOptions(StateSetter setter) {
      if (selectedAgency == null) {
        return <Widget>[Padding(padding: EdgeInsets.all(24), child: Text("Response options will show after you select an agency."))];
      }
      List<Widget> widgets = new List<Widget>();
      for (ResponseOption option in selectedAgency.responseOptions) {
        widgets.add(RadioListTile<ResponseOption>(
          title: Text("${option.name}").fontSize(15),
          activeColor: Colors.red,
          value: option,
          dense: true,
          groupValue: selectedOption,
          onChanged: (ResponseOption value) {
            setter(() {
              selectedOption = value;
              widget.auth.getCurrentUser().then((user) {
                RespondingUtils().markUserResponding(user.uid, selectedOption, selectedAgency).then((val) {
                  Navigator.of(context).pop();
                });
              });
            });
          },
        ));
      }
      return widgets;
    }

    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.light ? Colors.white : TinyColor.fromString("#1f1f1f").color,
        builder: (BuildContext bc) {
          return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
            return Container(
              child: new ListView(
                physics: ClampingScrollPhysics(),
                shrinkWrap: true,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      InkResponse(
                        child: Container(
                          child: new Icon(Icons.arrow_back),
                          padding: EdgeInsets.all(12.0),
                        ),
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      Text(
                        "RESPONDING",
                        textAlign: TextAlign.center,
                      ).bold().fontSize(16).expanded(),
                      InkResponse(
                        child: Container(
                          child: new Icon(Icons.clear_all),
                          padding: EdgeInsets.all(12.0),
                        ),
                        onTap: () {
                          RespondingUtils().clearRespondingList(selectedAgency);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ).padding(all: 12),
                  Row(
                    children: <Widget>[
                      Image.asset(
                        "assets/icons8_fire_station_96.png",
                        height: 28,
                      ),
                      Text(
                        "Select Agency",
                        style: TextStyle(fontSize: 16),
                      ).fontSize(16).padding(left: 12),
                    ],
                  ).padding(left: 24),
                  Padding(
                    padding: EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0),
                    child: ClipRRect(
                        clipBehavior: Clip.antiAlias,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          decoration: BoxDecoration(shape: BoxShape.rectangle, color: Theme.of(context).brightness == Brightness.light ? Colors.grey[100] : Colors.grey[850]),
                          child: Material(type: MaterialType.transparency, child: Column(children: getAgencyRadios(setState))),
                        )),
                  ),
                  Row(
                    children: <Widget>[
                      Image.asset(
                        "assets/icons8_marker_96.png",
                        height: 24,
                      ),
                      Text("Responding to...").fontSize(16).padding(left: 12)
                    ],
                  ).padding(left: 24, top: 12),
                  Padding(
                    padding: EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0, bottom: 12),
                    child: ClipRRect(
                        clipBehavior: Clip.antiAlias,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          decoration: BoxDecoration(shape: BoxShape.rectangle, color: Theme.of(context).brightness == Brightness.light ? Colors.grey[100] : Colors.grey[850]),
                          child: Material(type: MaterialType.transparency, child: Column(children: getResponseOptions(setState))),
                        )),
                  ),
                ],
              ),
            );
          });
        });
  }
}
