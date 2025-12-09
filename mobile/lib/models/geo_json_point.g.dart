// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geo_json_point.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeoJsonPoint _$GeoJsonPointFromJson(Map<String, dynamic> json) => GeoJsonPoint(
  type: json['type'] as String,
  coordinates: Coordinates.fromJson(
    json['coordinates'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$GeoJsonPointToJson(GeoJsonPoint instance) =>
    <String, dynamic>{
      'type': instance.type,
      'coordinates': instance.coordinates,
    };
