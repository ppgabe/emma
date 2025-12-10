import 'dart:async';
import 'dart:io';

import 'package:emma_mobile/env/env.dart';
import 'package:emma_mobile/models/coordinates.dart';
import 'package:emma_mobile/models/incident_type.dart';
import 'package:emma_mobile/routes/map_sheet_content.dart';
import 'package:emma_mobile/services/incident_service.dart';
import 'package:emma_mobile/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:toastification/toastification.dart';

import '../models/incident.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<StatefulWidget> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LocationService _locationService = LocationService();

  final IncidentService _incidentService = IncidentService();
  List<Incident> _nearbyIncidents = [];
  Set<Marker> _markers = {};

  late GoogleMapController _mapController;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  MapSheetContent _mapSheetContent = MapSheetContent.nearbyList;

  Timer? _viewportDebounce;
  Timer? _nearbyIncidentsRefresh;
  bool _isLoadingNearby = true;

  TextEditingController _titleTextController = TextEditingController();
  TextEditingController _descriptionTextController = TextEditingController();
  IncidentType _incidentType = IncidentType.EARTHQUAKE;

  late Position _userLocation;

  void _fetchNearbyIncidents() async {
    try {
      _userLocation = await _locationService.getCurrentPosition();
    } on LocationServiceDisabledException {
      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.flatColored,
          title: const Text("Location services disabled!"),
          description: Text("Please enable location services on your device."),
          alignment: Alignment.topCenter,
          autoCloseDuration: const Duration(seconds: 5),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: lowModeShadow,
          closeButton: ToastCloseButton(showType: CloseButtonShowType.none),
        );
      }

      return;
    } on PermissionDeniedException catch (e) {
      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.flatColored,
          title: const Text("Location permissions needed!"),
          description: Text(
            e.message ?? 'Please allow location access for this app.',
          ),
          alignment: Alignment.topCenter,
          autoCloseDuration: const Duration(seconds: 5),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: lowModeShadow,
          closeButton: ToastCloseButton(showType: CloseButtonShowType.none),
        );
      }

      return;
    }

    try {
      _nearbyIncidents = await _incidentService.fetchNearbyIncidents(
        _userLocation.latitude,
        _userLocation.longitude,
        100000,
      );
    } on HttpException catch (e) {
      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.flatColored,
          title: const Text("Could not get nearby incidents."),
          description: Text(e.message),
          alignment: Alignment.topCenter,
          autoCloseDuration: const Duration(seconds: 5),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: lowModeShadow,
          closeButton: ToastCloseButton(showType: CloseButtonShowType.none),
        );
      }

      return;
    }

    if (mounted) {
      setState(() {
        _isLoadingNearby = false;
      });
    }
  }

  void _getViewportIncidents() async {
    final bounds = await _mapController.getVisibleRegion();

    final topLeftPoint = Coordinates(
      lon: bounds.southwest.longitude,
      lat: bounds.northeast.latitude,
    );
    final bottomRightPoint = Coordinates(
      lon: bounds.northeast.longitude,
      lat: bounds.southwest.latitude,
    );

    List<Incident> viewportIncidents = [];

    try {
      viewportIncidents = await _incidentService.fetchViewportIncidents(
        topLeftPoint,
        bottomRightPoint,
      );
    } on HttpException catch (e) {
      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.flatColored,
          title: const Text("Could not load incidents."),
          description: Text(e.message),
          alignment: Alignment.topCenter,
          autoCloseDuration: const Duration(seconds: 5),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: lowModeShadow,
          closeButton: ToastCloseButton(showType: CloseButtonShowType.none),
        );
      }

      return;
    }

    Set<Marker> newMarkers = {};
    for (var incident in viewportIncidents) {
      final coordinates = incident.location.coordinates;

      newMarkers.add(
        Marker(
          markerId: MarkerId(incident.id.toString()),
          position: LatLng(coordinates.lat, coordinates.lon),
        ),
      );
    }

    if (mounted) {
      setState(() {
        _markers = newMarkers;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _nearbyIncidentsRefresh = Timer.periodic(Duration(seconds: 30), (_) {
      setState(() {
        _isLoadingNearby = true;

        _fetchNearbyIncidents();
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchNearbyIncidents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            top: false,
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(14.599, 120.984), // Manila
                zoom: 14,
              ),
              cloudMapId: Env.cloudMapId,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              padding: EdgeInsets.only(
                top: 32,
                left: 16,
                bottom: (MediaQuery.of(context).size.height * 0.15) - 8,
              ),
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              markers: _markers,
              onCameraIdle: () {
                _viewportDebounce?.cancel();
                _viewportDebounce = Timer(
                  Duration(milliseconds: 500),
                  () => _getViewportIncidents(),
                );
              },
              onMapCreated: (controller) {
                setState(() {
                  _mapController = controller;
                });
              },
            ),
          ),

          AnimatedBuilder(
            animation: _sheetController,

            builder: (context, child) {
              bool sheetIsAttached = _sheetController.isAttached;

              double sheetSize = sheetIsAttached ? _sheetController.size : 0.15;

              double sheetSizeInPixels = sheetIsAttached
                  ? _sheetController.sizeToPixels(sheetSize)
                  : MediaQuery.of(context).size.height * 0.15;

              return Stack(
                children: [buildReportButton(sheetSizeInPixels), child!],
              );
            },

            child: DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: 0.12,
              minChildSize: 0.12,
              maxChildSize: 0.9,
              snap: true,
              snapSizes: [0.12, 0.6, 0.9],
              builder: (context, scrollController) {
                return switch (_mapSheetContent) {
                  MapSheetContent.nearbyList => NearbyIncidents(
                    isLoadingNearby: _isLoadingNearby,
                    nearbyIncidents: _nearbyIncidents,
                    scrollController: scrollController,
                  ),
                  MapSheetContent.reportForm => ReportForm(
                    titleTextController: _titleTextController,
                    descriptionTextController: _descriptionTextController,
                    scrollController: scrollController,
                  ),
                };
              },
            ),
          ),
        ],
      ),
    );
  }

  PositionedDirectional buildReportButton(double sheetSizeInPixels) {
    return PositionedDirectional(
      end: 16,
      bottom: sheetSizeInPixels + 8,
      child: FloatingActionButton(
        onPressed: () {
          setState(() {
            _mapSheetContent = MapSheetContent.reportForm;
            _sheetController.animateTo(
              0.6,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOutExpo,
            );
          });
        },
        child: Icon(Icons.add_alert),
      ),
    );
  }
}

class ReportForm extends StatelessWidget {
  const ReportForm({
    super.key,
    required TextEditingController titleTextController,
    required TextEditingController descriptionTextController,
    required ScrollController scrollController,
  }) : _titleTextController = titleTextController,
       _scrollController = scrollController,
       _descriptionTextController = descriptionTextController;

  final TextEditingController _titleTextController;
  final TextEditingController _descriptionTextController;
  final ScrollController _scrollController;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.elliptical(24, 32),
          topRight: Radius.elliptical(24, 32),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        controller: _scrollController,
        children: [
          const Center(
            child: Divider(endIndent: 144, indent: 144, thickness: 4),
          ),

          Row(children: [ReportIncidentHeader()]),

          TextField(
            controller: _titleTextController,
            decoration: const InputDecoration(labelText: 'Title'),
            maxLength: 64,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
          ),

          TextField(
            controller: _descriptionTextController,
            decoration: const InputDecoration(labelText: 'Description'),
            maxLength: 255,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
          ),
        ],
      ),
    );
  }
}

class ReportIncidentButton extends StatelessWidget {
  const ReportIncidentButton({super.key, required this.sheetSizeInPixels});

  final double sheetSizeInPixels;

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      end: 16,
      bottom: sheetSizeInPixels + 8,
      child: FloatingActionButton(
        onPressed: () {
          setState() {}
        },
        child: Icon(Icons.add_alert),
      ),
    );
  }
}

class NearbyIncidents extends StatelessWidget {
  const NearbyIncidents({
    super.key,
    required bool isLoadingNearby,
    required List<Incident> nearbyIncidents,
    required ScrollController scrollController,
  }) : _isLoadingNearby = isLoadingNearby,
       _nearbyIncidents = nearbyIncidents,
       _scrollController = scrollController;

  final bool _isLoadingNearby;
  final List<Incident> _nearbyIncidents;
  final ScrollController _scrollController;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.elliptical(24, 32),
          topRight: Radius.elliptical(24, 32),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              controller: _scrollController,
              children: [
                const Center(
                  child: Divider(endIndent: 144, indent: 144, thickness: 4),
                ),

                Row(children: [NearbyIncidentsHeader()]),

                if (_isLoadingNearby)
                  Center(
                    child: SizedBox.square(
                      dimension: 32,
                      child: CircularProgressIndicator.adaptive(),
                    ),
                  )
                else
                  for (final incident in _nearbyIncidents)
                    IncidentListTile(incident: incident),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NearbyIncidentsHeader extends StatelessWidget {
  const NearbyIncidentsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      "Nearby incidents",
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }
}

class ReportIncidentHeader extends StatelessWidget {
  const ReportIncidentHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      "Report an incident",
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }
}

class IncidentListTile extends StatelessWidget {
  const IncidentListTile({super.key, required this.incident});

  final Incident incident;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(incident.title),
      subtitle: Text(incident.description),
      leading: incident.type.icon,
      trailing: Text(
        '${incident.reportedAt.hour}:'
        '${incident.reportedAt.minute.toString().padLeft(2, '0')}',
      ),
    );
  }
}
