import 'package:emma_mobile/models/incident_type.dart';
import 'package:json_annotation/json_annotation.dart';

import 'geo_json_point.dart';

part 'incident.g.dart';

@JsonSerializable()
class Incident {
  final int id;
  final String reporterId;

  final GeoJsonPoint location;

  final String title;
  final String description;

  final IncidentType type;

  final DateTime reportedAt;
  final DateTime updatedAt;

  Incident({
    required this.id,
    required this.reporterId,
    required this.location,
    required this.title,
    required this.description,
    required this.type,
    required this.reportedAt,
    required this.updatedAt,
  });

  factory Incident.fromJson(Map<String, dynamic> json) => _$IncidentFromJson(json);
}
