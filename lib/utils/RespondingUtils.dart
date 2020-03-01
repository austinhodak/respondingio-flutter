import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:respondingio_flutter/models/AgencyFS.dart';
import 'package:respondingio_flutter/models/Position.dart';
import 'package:respondingio_flutter/models/ResponseOption.dart';
import 'package:respondingio_flutter/utils/AgencyUtils.dart';

class RespondingUtils {
  static final RespondingUtils _singlton = RespondingUtils._internal();

  factory RespondingUtils() {
    return _singlton;
  }

  RespondingUtils._internal();

  Future<void> markUserResponding(String uid, ResponseOption option, AgencyFS agency) {
    return FirebaseDatabase.instance.reference().child("users/$uid/responding").set({
      "agency": agency.agencyID,
      "respondingTo": option.name,
      "respondingToType": option.type,
      "timestamp": DateTime.now().toUtc().millisecondsSinceEpoch
    });
  }

  void markUserOnScene(String uid) {
    FirebaseDatabase.instance.reference().child("users/$uid/responding").update({
      "onSceneTime": DateTime.now().toUtc().millisecondsSinceEpoch,
      "onScene": true
    });
  }

  void clearRespondingList(AgencyFS agency) {
    FirebaseDatabase.instance.reference().child("users").orderByChild("responding/agency").equalTo(agency.agencyID).once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      List<dynamic> list = values.keys.toList();

      for (dynamic item in list) {
        FirebaseDatabase.instance.reference().child("users/$item/responding").remove();
      }
    });
    FirebaseDatabase.instance.reference().child("users").orderByChild("responding/agency").equalTo(agency.agencyID).onChildAdded.listen((Event event) {
      print(event.snapshot.key);
      DataSnapshot snap = event.snapshot;
      //
    });
  }

  StreamController<List<String>> controller = StreamController<List<String>>();
  List<String> list = List<String>();

  void loadAgencyResponding(String uid) {
    for (String agencyID in AgencyUtils().agencyIDs) {
      FirebaseDatabase.instance.reference().child("users").orderByChild("responding/agency").equalTo(agencyID).onValue.listen((Event event) {
        DataSnapshot snap = event.snapshot;
        if (snap.value == null) {
          list.remove(agencyID);
          controller.add(list);
        } else {
          list.add(agencyID);
          controller.add(list);
        }
      });
    }
  }

  MColor getRespondingToColors(String respondingToType) {
    switch (respondingToType) {
      case "STATION":
        return MColor(Colors.orangeAccent[400], Colors.orange[800]);
        break;
      case "SCENE":
        return MColor(Colors.redAccent[400], Colors.red[800]);
        break;
      case "UNAVAILABLE":
      case "DELAYED":
        return MColor(Colors.grey[700], Colors.grey[900]);
        break;
      default: {
        return MColor(Colors.indigoAccent[400], Colors.blue[800]);
      }
    }
  }

  String getTimestamp(dynamic user) {
    if (user["responding"]["onSceneTime"] != null) {
      return DateFormat("HH:mm").format(DateTime.fromMillisecondsSinceEpoch(user["responding"]["onSceneTime"]));
    } else if (user["responding"]["timestamp"] != null) {
      return DateFormat("HH:mm").format(DateTime.fromMillisecondsSinceEpoch(user["responding"]["timestamp"]));
    } else {
      return "NO TIME";
    }
  }

  StreamController<List<Position>> positionController = StreamController<List<Position>>();

}

class MColor {
  final Color colorLight;
  final Color colorDark;

  MColor(this.colorLight, this.colorDark);
}