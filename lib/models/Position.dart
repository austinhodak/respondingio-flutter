import 'package:firebase_database/firebase_database.dart';

class Position {
  String color;
  String name;
  String type;
  String key;

  Position.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        name = snapshot.value['name'],
        color = snapshot.value['color'],
        type = snapshot.value['type'];

  String getImage() {
    switch (type.toUpperCase()) {
      case "FIRE": return "fire_1.png";
      case "EMS": return "star_of_life.png";
      case "POLICE": return "icons8_police_badge.png";
      case "OFFICER": return "icons8_firefighter.png";
      case "ADMINISTRATIVE": return "icons8_businessman.png";
      case "JUNIOR": return "icons8_babys_room.png";
      case "SUPPORT": return "icons8_fire_hydrant.png";
      case "DRIVER": return "icons8_steering_wheel_100.png";
      default: return "icons8_fire_hydrant.png";
    }
  }
}
