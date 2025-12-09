import 'package:json_annotation/json_annotation.dart';

import 'coordinates.dart';

part 'geo_json_point.g.dart';

@JsonSerializable()
class GeoJsonPoint {
  final String type;
  final Coordinates coordinates;

  GeoJsonPoint({required this.type, required this.coordinates});

  factory GeoJsonPoint.fromJson(Map<String, dynamic> json) => _$GeoJsonPointFromJson(json);
}