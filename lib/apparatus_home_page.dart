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

class ApparatusHomePage extends StatefulWidget {
  ApparatusHomePage({Key key, String title, this.auth, this.logout});

  final BaseAuth auth;
  final VoidCallback logout;

  @override
  State<StatefulWidget> createState() => new _ApparatusHomePage();
}

class _ApparatusHomePage extends State<ApparatusHomePage> {

  int _lastSelected = 0;
  bool isResponding = false;
  static VoidCallback loggedOut;
  static BaseAuth auth2;

  static HomePage home;
  final List<Widget> _children = new List(1);

  int _selectedDrawerItem = 0;

  @override
  void initState() {
    super.initState();
    loggedOut = widget.logout;
    auth2 = widget.auth;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light ? null : TinyColor.fromString("#121212").color,
      body: Column(
        children: <Widget>[
        ],
      ),
    );
  }
}
