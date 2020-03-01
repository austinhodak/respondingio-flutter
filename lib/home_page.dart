import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:respondingio_flutter/feed_widget.dart';
import 'package:respondingio_flutter/home_more_page.dart';
import 'package:respondingio_flutter/incidents/home_incidents.dart';
import 'package:respondingio_flutter/models/AgencyFS.dart';
import 'package:respondingio_flutter/models/ResponseOption.dart';
import 'package:respondingio_flutter/utils/AgencyUtils.dart';
import 'package:respondingio_flutter/utils/RespondingUtils.dart';
import 'package:respondingio_flutter/widgets/FABBottomAppBar.dart';
import 'package:tinycolor/tinycolor.dart';
import 'main.dart';
import 'authentication.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, String title, this.auth, VoidCallback logoutCallback});

  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _lastSelected = 0;
  bool isResponding = false;
  ImageIcon _fabIcon = ImageIcon(AssetImage("assets/icons8_steering_wheel_100.png"));

  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((user) {
      FirebaseDatabase.instance.reference().child("users").child(user.uid).onValue.listen((Event event) {
        setState(() {
          if (event.snapshot.value["responding"] == null) {
            isResponding = false;
            _fabIcon = ImageIcon(AssetImage("assets/icons8_steering_wheel_100.png"));
          } else {
            isResponding = true;
            _fabIcon = ImageIcon(AssetImage("assets/icons8_place_marker_96.png"));
          }
        });
      });
    });
  }

  void _selectedTab(int index) {
    setState(() {
      _lastSelected = index;
    });
  }

  final List<Widget> _children = [FeedWidget(), HomeIncidents(), FeedWidget(), HomeMorePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light ? null : TinyColor.fromString("#121212").color,
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.light ? Colors.red[400] : TinyColor.fromString("#1f1f1f").color,
        title: new Image(
            image: new ExactAssetImage(Theme.of(context).brightness == Brightness.light ? "assets/responding_icon_black.png" : "assets/respondingio_logo_light.png"),
            height: 100.0,
            width: 200.0,
            alignment: FractionalOffset.center),
      ),
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
          FABBottomAppBarItem(iconData: 'assets/fire_truck_1.png', text: 'Bottom', disabled: true),
          FABBottomAppBarItem(iconData: 'assets/icons8_more_100.png', text: 'Bar', disabled: false),
        ],
      ),
      body: _children[_lastSelected],
    );
  }

  void _settingModalBottomSheet(context) {
    AgencyFS selectedAgency;
    String selectedSTring;

    if (AgencyUtils().agencies.length == 1) {
      selectedAgency = AgencyUtils().agencies.first;
    }

    ResponseOption selectedOption;

    List<Widget> getAgencyRadios(StateSetter setter) {
      List<Widget> widgets = new List<Widget>();
      for (AgencyFS agency in AgencyUtils().agencies) {
        widgets.add(RadioListTile<AgencyFS>(
          dense: false,
          title: Text("${agency.agencyShortName}"),
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
          title: Text("${option.name}"),
          activeColor: Colors.red,
          value: option,
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
        builder: (BuildContext bc) {
          return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
            return Container(
              child: new Wrap(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Row(
                      children: <Widget>[
                        InkResponse(
                          child: Container(
                            child: new Icon(Icons.arrow_back),
                            padding: EdgeInsets.all(12.0),
                          ),
                          onTap: () => Navigator.of(context).pop(),
                        ),
                        Expanded(
                          child: Text(
                            "RESPONDING",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ),
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
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 24.0),
                    child: Row(
                      children: <Widget>[
                        Image.asset(
                          "assets/icons8_fire_station_96.png",
                          height: 28,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 12),
                          child: Text(
                            "Select Agency",
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0),
                    child: Container(
                      decoration: BoxDecoration(shape: BoxShape.rectangle, borderRadius: BorderRadius.all(Radius.circular(20.0)), color: Theme.of(context).brightness == Brightness.light ? Colors.grey[300] : Colors.grey[800]),
                      child: Material(type: MaterialType.transparency, child: Column(children: getAgencyRadios(setState))),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 24.0, top: 12),
                    child: Row(
                      children: <Widget>[
                        Image.asset(
                          "assets/icons8_region_96.png",
                          height: 28,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 12),
                          child: Text(
                            "Responding to...",
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0, bottom: 24),
                    child: DecoratedBox(
                        decoration: BoxDecoration(shape: BoxShape.rectangle, borderRadius: BorderRadius.all(Radius.circular(20.0)), color: Theme.of(context).brightness == Brightness.light ? Colors.grey[300] : Colors.grey[800]),
                        child: Column(children: getResponseOptions(setState))),
                  ),
                ],
              ),
            );
          });
        });
  }
}
