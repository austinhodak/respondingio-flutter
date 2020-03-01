import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:respondingio_flutter/models/ResponseOption.dart';

List<ResponseOption> defaultOptions = [ResponseOption("Station", "STATION"), ResponseOption("Scene", "SCENE"), ResponseOption("Delayed", "DELAYED"), ResponseOption("Unavailable", "UNAVAILABLE")];

class AgencyFS {
  String agencyName;
  String agencyShortName;
  String agencyID;
  String stationNumber;
  List<ResponseOption> responseOptions;

  AgencyFS.fromSnapshot(DocumentSnapshot snapshot)
      : agencyID = snapshot.documentID,
        agencyName = snapshot['agencyName'],
        agencyShortName = snapshot['shortName'],
        stationNumber = snapshot['stationNumber'],
        responseOptions = getResponseOptions(snapshot);
}

List<ResponseOption> getResponseOptions(DocumentSnapshot snapshot) {
  if (snapshot['responseOptions'] == null) return defaultOptions;
  List<ResponseOption> list = [];
  (snapshot['responseOptions'] as List<dynamic>).forEach((f) =>
      list.add(ResponseOption(f['name'], f['type']))
  );
  return list;
}
