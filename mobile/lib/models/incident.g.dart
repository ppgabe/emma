// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'incident.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Incident _$IncidentFromJson(Map<String, dynamic> json) => Incident(
  id: (json['id'] as num).toInt(),
  reporterId: json['reporterId'] as String,
  location: GeoJsonPoint.fromJson(json['location'] as Map<String, dynamic>),
  title: json['title'] as String,
  description: json['description'] as String,
  type: $enumDecode(_$IncidentTypeEnumMap, json['type']),
  reportedAt: DateTime.parse(json['reportedAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$IncidentToJson(Incident instance) => <String, dynamic>{
  'id': instance.id,
  'reporterId': instance.reporterId,
  'location': instance.location,
  'title': instance.title,
  'description': instance.description,
  'type': _$IncidentTypeEnumMap[instance.type]!,
  'reportedAt': instance.reportedAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
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
