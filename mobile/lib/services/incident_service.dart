import 'dart:convert';
import 'dart:io';

import 'package:emma_mobile/env/env.dart';
import 'package:emma_mobile/models/coordinates.dart';
import 'package:emma_mobile/models/incident.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class IncidentService {
  Session? _getSupabaseSession() {
    return Supabase.instance.client.auth.currentSession;
  }

  Future<http.Response> _getHttpRequest(Uri uri, Map<String, String> headers) {
    return http.get(uri, headers: headers);
  }

  Future<http.Response> fetchNearbyIncidents(
    double lat,
    double lon,
    double radius,
  ) async {
    final token = _getSupabaseSession()?.accessToken;

    final uri = Uri.parse(
      "${Env.apiUrl}/incidents/nearby?lat=$lat&lon=$lon&radius=$radius",
    );

    return _getHttpRequest(uri, {'Authorization': "Bearer $token"});
  }

  Future<List<Incident>> fetchViewportIncidents(
    Coordinates topPoint,
    Coordinates bottomPoint,
  ) async {
    final token = _getSupabaseSession()?.accessToken;

    final uri = Uri.parse(
      "${Env.apiUrl}/incidents/viewport?"
      "topLeft.lat=${topPoint.lat}&topLeft.lon=${topPoint.lon}&"
      "bottomRight.lat=${bottomPoint.lat}&bottomRight.lon=${bottomPoint.lon}",
    );

    var viewportIncidents = await _getHttpRequest(uri, {
      'Authorization': "Bearer $token",
    });


    if (viewportIncidents.statusCode == HttpStatus.ok) {
      debugPrint("Viewport request OK!");

      return (jsonDecode(viewportIncidents.body) as List<dynamic>)
          .map((e) => Incident.fromJson(e))
          .toList(growable: false);
    } else {
      throw HttpException('Failed to load incidents: ${viewportIncidents.statusCode}');
    }
  }
}
