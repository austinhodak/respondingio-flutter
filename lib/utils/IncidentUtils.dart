import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:respondingio_flutter/models/AgencyFS.dart';
import 'package:respondingio_flutter/utils/AgencyUtils.dart';
import 'package:respondingio_flutter/utils/RespondingUtils.dart';
import 'package:rxdart/rxdart.dart';

class IncidentUtils {
  static final IncidentUtils _singlton = IncidentUtils._internal();

  factory IncidentUtils() {
    return _singlton;
  }

  IncidentUtils._internal();
  StreamController<List<DocumentSnapshot>> controller = BehaviorSubject();
  List<DocumentSnapshot> activeIncidents = List<DocumentSnapshot>();
  
  void loadActiveIncidents() {
    for (String agencyID in AgencyUtils().agencyIDs) {
      Firestore.instance.collection("agencies").document(agencyID).collection("incidents").where("isActive", isEqualTo: true).snapshots().listen((QuerySnapshot event) {
        activeIncidents.clear();
        for (DocumentSnapshot doc in event.documents) {
          if (!activeIncidents.contains(doc)) {
            activeIncidents.add(doc);
            controller.add(activeIncidents);
          }
        }
      });
    }
  }
}