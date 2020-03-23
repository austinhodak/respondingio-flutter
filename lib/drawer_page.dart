import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:respondingio_flutter/feed_widget.dart';
import 'package:respondingio_flutter/home_more_page.dart';
import 'package:respondingio_flutter/home_page.dart';
import 'package:respondingio_flutter/incidents/home_incidents.dart';
import 'package:respondingio_flutter/models/AgencyFS.dart';
import 'package:respondingio_flutter/models/ResponseOption.dart';
import 'package:respondingio_flutter/utils/AgencyUtils.dart';
import 'package:respondingio_flutter/utils/RespondingUtils.dart';
import 'package:respondingio_flutter/widgets/FABBottomAppBar.dart';
import 'package:tinycolor/tinycolor.dart';
import 'authentication.dart';
import 'package:styled_widget/styled_widget.dart';

class DrawerPage extends StatefulWidget {
  DrawerPage({Key key, String title, this.auth, this.logout});

  final BaseAuth auth;
  final VoidCallback logout;

  @override
  State<StatefulWidget> createState() => new _DrawerPage();
}

class _DrawerPage extends State<DrawerPage> {

  int _lastSelected = 0;
  bool isResponding = false;
  ImageIcon _fabIcon = ImageIcon(AssetImage("assets/icons8_steering_wheel_100.png"));
  static VoidCallback loggedOut;
  static BaseAuth auth2;

  static HomePage home;
  final List<Widget> _children = new List(1);

  @override
  void initState() {
    super.initState();
    loggedOut = widget.logout;
    auth2 = widget.auth;
    _children[0] = HomePage(title: "Responding.io", auth: auth2, logout: loggedOut,);
  }

  void _selectedTab(int index) {
    setState(() {
      _lastSelected = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light ? null : TinyColor.fromString("#121212").color,
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.light ? Colors.red[400] : TinyColor.fromString("#1f1f1f").color,
        title: Image(
            image: new ExactAssetImage(Theme.of(context).brightness == Brightness.light ? "assets/responding_icon_black.png" : "assets/respondingio_logo_light.png"),
            height: 100.0,
            width: 200.0,
            alignment: FractionalOffset.center),
      ),
      body: _children[_lastSelected],
      drawer: getDrawer(),
    );
  }

  Widget getDrawer() {
    //return null;
    return Drawer(
        child: Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              ListTile(
                title: Text(
                  "Austin Hodak",
                  style: TextStyle(fontSize: 22),
                ),
                subtitle: Text("ahodak65@gmail.com"),
              ),
              ClipRRect(
                  clipBehavior: Clip.antiAlias,
                  borderRadius: BorderRadius.circular(5),
                  child: Container(
                    decoration: BoxDecoration(shape: BoxShape.rectangle, color: Color.fromRGBO(244, 67, 54, 0.1)),
                    alignment: Alignment.topCenter,
                    child: ListTile(
                      dense: true,
                      leading: Image.asset(
                        "assets/icons8_fire_station_96.png",
                        height: 24,
                      ),
                      title: Text('Dashboard').textColor(Colors.red).fontSize(14),
                      selected: true,
                    ),
                  )).padding(left: 8, right: 8),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
              boxShadow: <BoxShadow>[BoxShadow(color: Colors.black54, blurRadius: 3.0, offset: Offset(0.0, 0))],
              color: Theme.of(context).brightness == Brightness.light ? Colors.white : Colors.grey[850]),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              child: ListTile(
                dense: true,
                leading: Image.asset(
                  "assets/icons8_settings.png",
                  height: 24,
                ),
                title: Text('Settings').fontSize(14),
              ),
            ),
          ),
        )
      ],
    ));
  }
}
