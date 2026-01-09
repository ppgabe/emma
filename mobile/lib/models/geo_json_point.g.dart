// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geo_json_point.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeoJsonPoint _$GeoJsonPointFromJson(Map<String, dynamic> json) => GeoJsonPoint(
  type: json['type'] as String,
  coordinates: GeoJsonPoint._coordinatesFromJson(json['coordinates'] as List),
);

Map<String, dynamic> _$GeoJsonPointToJson(GeoJsonPoint instance) =>
    <String, dynamic>{
      'type': instance.type,
      'coordinates': instance.coordinates,
    };
