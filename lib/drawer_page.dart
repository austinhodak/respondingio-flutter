import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:respondingio_flutter/feed_widget.dart';
import 'package:respondingio_flutter/home_more_page.dart';
import 'package:respondingio_flutter/home_page.dart';
import 'package:respondingio_flutter/incidents/home_incidents.dart';
import 'package:respondingio_flutter/inventory_page.dart';
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
  final List<Widget> _children = new List(2);

  int _selectedDrawerItem = 0;

  @override
  void initState() {
    super.initState();
    loggedOut = widget.logout;
    auth2 = widget.auth;
    _children[0] = HomePage(
      title: "Responding.io",
      auth: auth2,
      logout: loggedOut,
    );
    _children[1] = InventoryPage(
      title: "Responding.io",
      auth: auth2,
      logout: loggedOut,
    );
  }

  void _drawerSelected(int index) {
    setState(() {
      _lastSelected = index;
      _selectedDrawerItem = index;
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light ? null : TinyColor.fromString("#121212").color,
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.light ? Colors.red[400] : TinyColor.fromString("#1f1f1f").color,
        //elevation: 0.0,
        title: Image(
            image: new ExactAssetImage(Theme.of(context).brightness == Brightness.light ? "assets/responding_icon_black.png" : "assets/respondingio_logo_light.png"),
            height: 100.0,
            width: 180.0,
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
            padding: EdgeInsets.only(top: 40),
            children: <Widget>[
              ListTile(
                title: Text(
                  "Austin Hodak",
                  style: TextStyle(fontSize: 22),
                ),
                subtitle: Text("ahodak65@gmail.com"),
              ),
              _createDrawerItem("assets/icons8_fire_station_96.png", "Dashboard", 0),
              _createDrawerItem("assets/icons8_product_96.png", "Inventory", 1)
            ],
          ),
        ),

      ],
    ));
  }

  Widget _createDrawerItem(String icon, String text, int identifier) {
    return ClipRRect(
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        decoration: BoxDecoration(shape: BoxShape.rectangle, color: _selectedDrawerItem == identifier ? Color.fromRGBO(244, 67, 54, 0.1) : Colors.transparent),
        alignment: Alignment.topCenter,
        child: ListTile(
          dense: true,
          leading: Image.asset(
            icon,
            height: 24,
          ),
          title: Text(text).textColor(_selectedDrawerItem == identifier ? Colors.red : Theme.of(context).brightness == Brightness.light ? Colors.black87 : Colors.white).fontSize(14),
          selected: true,
          onTap: () => _drawerSelected(identifier),
        ),
      ),
    ).padding(left: 8, right: 8, top: identifier == 0 ? 0 : 8);
  }

  Widget _createStickyItem(String icon, String text, int identifier) {
    return Container(
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
    );
  }
}
