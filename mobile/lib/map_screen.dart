import 'package:emma_mobile/env/env.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<StatefulWidget> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _sheetController,

        builder: (context, child) {
          bool sheetIsAttached = _sheetController.isAttached;

          double sheetSize = sheetIsAttached ? _sheetController.size : 0.15;

          double sheetSizeInPixels = sheetIsAttached
              ? _sheetController.sizeToPixels(sheetSize)
              : MediaQuery.of(context).size.height * 0.15;

          return Stack(
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
                    bottom: sheetSizeInPixels - 48,
                  ),
                  zoomControlsEnabled: false,
                ),
              ),

              PositionedDirectional(
                end: 16,
                bottom: sheetSizeInPixels + 8,
                child: FloatingActionButton(
                  onPressed: () {},
                  child: Icon(Icons.add_alert),
                ),
              ),

              child!,
            ],
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
                  const Center(
                    child: Divider(endIndent: 144, indent: 144, thickness: 4),
                  ),

                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                      controller: scrollController,
                      children: [
                        Row(
                         children: [
                           Text(
                             "Nearby incidents",
                             style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                           ),

                         ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
