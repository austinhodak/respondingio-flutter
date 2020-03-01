import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:respondingio_flutter/models/AgencyFS.dart';
import 'package:respondingio_flutter/models/Position.dart';
import 'package:respondingio_flutter/utils/IncidentUtils.dart';
import 'package:respondingio_flutter/utils/RespondingUtils.dart';
import 'package:rxdart/rxdart.dart';

class AgencyUtils {
  static final AgencyUtils _singlton = AgencyUtils._internal();

  factory AgencyUtils() {
    return _singlton;
  }

  AgencyUtils._internal();

  List<String> agencyIDs = [];
  List<AgencyFS> agencies = [];

  Map<String, Position> positions = Map<String, Position>();

  StreamController<List<AgencyFS>> controller = BehaviorSubject();
  List<AgencyFS> list = List<AgencyFS>();

  void loadUserAgencies(String uid) {
    agencyIDs.clear();
    agencies.clear();
    FirebaseDatabase.instance.reference().child("users/$uid/agencies").onChildAdded.listen((Event event) {
      agencyIDs.add(event.snapshot.key);
      loadAgencyPositions(event.snapshot.key);
      Firestore.instance.collection("agencies").document(event.snapshot.key).get().then((DocumentSnapshot snapshot) {
        AgencyFS agency = AgencyFS.fromSnapshot(snapshot);
        agencies.add(agency);
        FirebaseDatabase.instance.reference().child("users").orderByChild("responding/agency").equalTo(snapshot.documentID).onValue.listen((Event event) {
          DataSnapshot snap = event.snapshot;
          if (snap.value == null) {
            list.remove(agency);
            controller.add(list);
          } else {
            if (list.contains(agency)) {
              controller.add(list);
            } else {
              list.add(agency);
              controller.add(list);
            }
          }
        });
      });
    });
    FirebaseDatabase.instance.reference().child("users/$uid/agencies").once().then((DataSnapshot data) {
      //RespondingUtils().loadAgencyResponding(uid);
      IncidentUtils().loadActiveIncidents();
    });
  }

  void loadAgencyPositions(String agencyID) {
    FirebaseDatabase(databaseURL: 'https://responding-io-agency.firebaseio.com/').reference().child('$agencyID/positions').onChildAdded.listen((Event event) {
      positions[event.snapshot.key] = Position.fromSnapshot(event.snapshot);
    });
  }
}