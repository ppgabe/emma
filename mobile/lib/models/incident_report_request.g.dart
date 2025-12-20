// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'incident_report_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IncidentReportRequest _$IncidentReportRequestFromJson(
  Map<String, dynamic> json,
) => IncidentReportRequest(
  coordinates: Coordinates.fromJson(
    json['coordinates'] as Map<String, dynamic>,
  ),
  title: json['title'] as String,
  description: json['description'] as String,
  type: $enumDecode(_$IncidentTypeEnumMap, json['type']),
);

Map<String, dynamic> _$IncidentReportRequestToJson(
  IncidentReportRequest instance,
) => <String, dynamic>{
  'coordinates': instance.coordinates,
  'title': instance.title,
  'description': instance.description,
  'type': _$IncidentTypeEnumMap[instance.type]!,
};

const _$IncidentTypeEnumMap = {
  IncidentType.EARTHQUAKE: 'EARTHQUAKE',
  IncidentType.LANDSLIDE: 'LANDSLIDE',
  IncidentType.FIRE: 'FIRE',
  IncidentType.FLOOD: 'FLOOD',
  IncidentType.ROAD_CRASH: 'ROAD_CRASH',
  IncidentType.ROAD_BLOCK: 'ROAD_BLOCK',
  IncidentType.POWER_OUTAGE: 'POWER_OUTAGE',
};
