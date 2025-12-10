import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  final geolocator = Geolocator();

  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
  );

  Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      debugPrint("Location service not enabled.");
      if (!await Geolocator.openLocationSettings()) {
        return Future.error(LocationServiceDisabledException());
      }
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error(PermissionDeniedException('Location permission denied.'));
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(PermissionDeniedException('Location permission denied forever. This app cannot work without location.'));
    }

    return await Geolocator.getCurrentPosition(locationSettings: locationSettings);
  }
}