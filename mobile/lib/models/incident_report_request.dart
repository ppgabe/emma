import 'package:emma_mobile/models/coordinates.dart';
import 'package:emma_mobile/models/incident_type.dart';
import 'package:json_annotation/json_annotation.dart';

part 'incident_report_request.g.dart';

@JsonSerializable()
class IncidentReportRequest {

  final Coordinates coordinates;
  final String title;
  final String description;
  final IncidentType type;

  IncidentReportRequest({
    required this.coordinates,
    required this.title,
    required this.description,
    required this.type,
  });

  Map<String, dynamic> toJson() => _$IncidentReportRequestToJson(this);
}
