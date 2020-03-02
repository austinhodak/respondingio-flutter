import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respondingio_flutter/utils/IncidentUtils.dart';

class HomeMorePage extends StatefulWidget {
  HomeMorePage({Key key, this.loggedOut});

  VoidCallback loggedOut;

  @override
  State<HomeMorePage> createState() => _HomeMorePage();
}

class _HomeMorePage extends State<HomeMorePage> {
  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        RaisedButton(
          onPressed: () {
            FirebaseAuth.instance.signOut().then((value) {
              widget.loggedOut();
            });
          },
          child: Text(
              'Logout',
              style: TextStyle(fontSize: 20)
          ),
        )
      ],
    );
  }
}
