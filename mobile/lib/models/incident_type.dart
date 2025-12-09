import 'package:emma_mobile/models/incident.dart';
import 'package:flutter/material.dart';

enum IncidentType {
  EARTHQUAKE,
  LANDSLIDE,
  FIRE,
  FLOOD,
  ROAD_CRASH,
  ROAD_BLOCK,
  POWER_OUTAGE,
}

extension IncidentTypeExtension on IncidentType {
  Icon get icon => switch (this) {
    IncidentType.EARTHQUAKE => const Icon(
      Icons.vibration,
      color: Colors.deepOrangeAccent,
    ),
    IncidentType.FIRE => const Icon(
      Icons.local_fire_department,
      color: Colors.red,
    ),
    IncidentType.FLOOD => const Icon(Icons.flood, color: Colors.blue),
    IncidentType.LANDSLIDE => const Icon(
      Icons.landslide,
      color: Colors.lightGreen,
    ),
    IncidentType.POWER_OUTAGE => const Icon(
      Icons.power_off,
      color: Colors.blueGrey,
    ),
    IncidentType.ROAD_CRASH => const Icon(
      Icons.car_crash,
      color: Colors.yellow,
    ),
    IncidentType.ROAD_BLOCK => const Icon(
      Icons.remove_road_outlined,
      color: Colors.grey,
    ),
  };
}
