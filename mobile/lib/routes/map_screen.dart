import 'dart:async';
import 'dart:io';

import 'package:emma_mobile/env/env.dart';
import 'package:emma_mobile/models/coordinates.dart';
import 'package:emma_mobile/models/incident_report_request.dart';
import 'package:emma_mobile/models/incident_type.dart';
import 'package:emma_mobile/routes/map_sheet_content.dart';
import 'package:emma_mobile/services/incident_service.dart';
import 'package:emma_mobile/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:toastification/toastification.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';

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
  bool _isSubmittingReport = false;

  final TextEditingController _titleTextController = TextEditingController();
  final TextEditingController _descriptionTextController =
      TextEditingController();
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

  void _submitIncidentReport() async {
    setState(() {
      _isSubmittingReport = true;
    });

    final reportRequest = IncidentReportRequest(
      coordinates: Coordinates(
        lon: _userLocation.longitude,
        lat: _userLocation.latitude,
      ),
      title: _titleTextController.text,
      description: _descriptionTextController.text,
      type: _incidentType,
    );

    try {
      final Incident created = await _incidentService.submitIncidentRequest(
        reportRequest,
      );

      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.success,
          style: ToastificationStyle.flatColored,
          title: const Text("Incident reported!"),
          autoCloseDuration: const Duration(seconds: 3),
        );
      }
    } on HttpException catch (e) {
      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.flatColored,
          title: const Text("Could submit incident."),
          description: Text(e.message),
          alignment: Alignment.topCenter,
          autoCloseDuration: const Duration(seconds: 5),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: lowModeShadow,
          closeButton: ToastCloseButton(showType: CloseButtonShowType.always),
        );

        setState(() {
          _isSubmittingReport = false;
        });

        return;
      }
      return;
    } on Exception catch (_) {
      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.flatColored,
          title: const Text("Could submit incident due to app error."),
          description: Text("This is on us, sorry! Please try again."),
          alignment: Alignment.topCenter,
          autoCloseDuration: const Duration(seconds: 5),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: lowModeShadow,
          closeButton: ToastCloseButton(showType: CloseButtonShowType.always),
        );

        setState(() {
          _isSubmittingReport = false;
        });

        return;
      }
      return;
    }

    debugPrint("Successful incident request!");

    setState(() {
      _titleTextController.clear();
      _descriptionTextController.clear();
      _mapSheetContent = MapSheetContent.nearbyList;
      _isSubmittingReport = false;
    });
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
          _buildGoogleMap(context),

          AnimatedBuilder(
            animation: _sheetController,

            builder: (context, child) {
              bool sheetIsAttached = _sheetController.isAttached;

              double sheetSize = sheetIsAttached ? _sheetController.size : 0.15;

              double sheetSizeInPixels = sheetIsAttached
                  ? _sheetController.sizeToPixels(sheetSize)
                  : MediaQuery.of(context).size.height * 0.15;

              return Stack(
                children: [
                  if (_mapSheetContent == MapSheetContent.nearbyList)
                    _buildReportButton(sheetSizeInPixels),

                  child!,
                ],
              );
            },

            child: _buildMapSheet(),
          ),
        ],
      ),
    );
  }

  SafeArea _buildGoogleMap(BuildContext context) {
    return SafeArea(
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
          bottom: (MediaQuery.of(context).size.height * 0.15) - 32,
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
    );
  }

  DraggableScrollableSheet _buildMapSheet() {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0.12,
      minChildSize: 0.12,
      maxChildSize: _mapSheetContent == MapSheetContent.reportForm ? 0.6 : 0.9,
      snap: true,
      snapSizes: [
        0.12,
        0.6,
        ?_mapSheetContent == MapSheetContent.reportForm ? null : 0.9,
      ],
      builder: (context, scrollController) {
        final sheet = switch (_mapSheetContent) {
          MapSheetContent.nearbyList => _buildNearbyIncidents(),
          MapSheetContent.reportForm => _buildReportForm(),
        };

        return Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.elliptical(24, 32),
              topRight: Radius.elliptical(24, 32),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          child: MediaQuery.removePadding(
            removeTop: true,
            context: context,
            child: CustomScrollView(
              controller: scrollController,
              slivers: sheet,
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildReportForm() {
    return <Widget>[
      SliverToBoxAdapter(child: Center(child: const ScrollDivider())),
      SliverAppBar(
        backgroundColor: Theme.of(context).canvasColor,
        pinned: true,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [const ReportFormHeader()],
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton.outlined(
            onPressed: () {
              setState(() {
                _nearbyIncidentsRefresh = Timer.periodic(
                  Duration(seconds: 30),
                  (_) {
                    setState(() {
                      _isLoadingNearby = true;

                      _fetchNearbyIncidents();
                    });
                  },
                );

                _sheetController.animateTo(
                  0.15,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutExpo,
                );
                _mapSheetContent = MapSheetContent.nearbyList;
              });
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ],
        actionsPadding: EdgeInsets.only(top: 12),
      ),

      if (!_isSubmittingReport)
        SliverToBoxAdapter(
          child: Column(
            children: [
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: _buildIncidentSelection(),
              ),
              const Divider(),

              TextField(
                controller: _titleTextController,
                decoration: const InputDecoration(labelText: 'Title'),
                buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
                  return Text(
                    "$currentLength of 6-$maxLength characters",
                    style: TextStyle(
                      fontSize: 12,
                      color: currentLength >= 6 && currentLength <= 255 ? Colors.green : Colors.redAccent
                    )
                  );
                },
                maxLength: 64,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
              ),

              TextField(
                controller: _descriptionTextController,
                decoration: const InputDecoration(labelText: 'Description'),
                buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
                  return Text(
                      "$currentLength of 6-$maxLength characters",
                      style: TextStyle(
                          fontSize: 12,
                          color: currentLength >= 6 && currentLength <= 255 ? Colors.green : Colors.redAccent
                      )
                  );
                },
                maxLength: 255,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                maxLines: 3,
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FilledButton.icon(
                  onPressed: () {
                    if (_titleTextController.text.length > 64 ||
                        _titleTextController.text.length < 6) {
                      if (mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text("Title must be between 6-64 characters.")));
                      }
                      return;
                    }

                    if (_descriptionTextController.text.length > 255 ||
                        _descriptionTextController.text.length < 6) {
                      if (mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text("Description must be between 6-255 characters.")));
                      }
                      return;
                    }

                    _submitIncidentReport();
                  },
                  label: const Text("Submit Incident"),
                  icon: Icon(Icons.send),
                ),
              ),

              Text(
                'Submitting incident at coordinates:\n${_userLocation.latitude}, ${_userLocation.longitude}',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        )
      else
        SliverToBoxAdapter(child: _buildLoadingIndicator()),
    ];
  }

  List<Widget> _buildNearbyIncidents() {
    return <Widget>[
      SliverToBoxAdapter(child: Center(child: const ScrollDivider())),
      SliverAppBar(
        backgroundColor: Theme.of(context).canvasColor,
        pinned: true,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [const NearbyIncidentsHeader()],
        ),
        automaticallyImplyLeading: false,
      ),

      if (_isLoadingNearby)
        SliverToBoxAdapter(child: _buildLoadingIndicator())
      else if (_nearbyIncidents.isEmpty)
        SliverToBoxAdapter(child: Text("No incidents near you right now!"))
      else
        SuperSliverList.builder(
          itemCount: _nearbyIncidents.length,
          itemBuilder: (context, index) {
            return IncidentListTile(incident: _nearbyIncidents[index]);
          },
        ),
    ];
  }

  Padding _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Center(
        child: SizedBox.square(
          dimension: 32,
          child: CircularProgressIndicator.adaptive(),
        ),
      ),
    );
  }

  PositionedDirectional _buildReportButton(double sheetSizeInPixels) {
    return PositionedDirectional(
      end: 16,
      bottom: sheetSizeInPixels + 8,
      child: FloatingActionButton(
        onPressed: () {
          setState(() {
            _nearbyIncidentsRefresh?.cancel();

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

  CarouselSlider _buildIncidentSelection() {
    return CarouselSlider(
      options: CarouselOptions(
        viewportFraction: 0.3,
        onPageChanged: (index, reason) {
          setState(() {
            _incidentType = IncidentType.values[index];
          });
        },
        aspectRatio: 16 / 3,
        enlargeCenterPage: true,
        enlargeFactor: 0.45,
      ),
      items: IncidentType.values.map((i) {
        return Builder(
          builder: (BuildContext context) {
            return FittedBox(
              fit: BoxFit.scaleDown,
              clipBehavior: Clip.hardEdge,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(i.icon.icon, color: i.icon.color, size: 36),
                    Text(i.formattedName),
                  ],
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

class ScrollDivider extends StatelessWidget {
  const ScrollDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Divider(endIndent: 144, indent: 144, thickness: 4),
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
        onPressed: () {},
        child: Icon(Icons.add_alert),
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

class ReportFormHeader extends StatelessWidget {
  const ReportFormHeader({super.key});

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
