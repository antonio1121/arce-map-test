import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(MaterialApp(
    home: const MyApp(),
    theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple)),
    darkTheme: ThemeData.dark(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Current Location code courtesy of tlserver , of "flutter_map_location_marker."
  // TODO implement buttons for centering on location, and centering on cemetery.
  // TODO mention performance vs quality marker clustering.
  late FollowOnLocationUpdate _followOnLocationUpdate;
  late StreamController<double?> _followCurrentLocationStreamController;

  // object for controlling map
  MapController mapController = MapController();

  // vars defining zoom and center
  double currentZoom = 14.0;
  LatLng currentCenter = LatLng(42.709027641543, -73.73557230235694);

  /*
    functions for controlling zoom
   */
  void _zoomOut() {
    currentZoom = currentZoom - 1;
    mapController.move(currentCenter, currentZoom);
  }
  void _zoomIn() { // TODO implement
    currentZoom = currentZoom + 1;
    mapController.move(currentCenter, currentZoom);
  }

  @override
  Widget build(BuildContext context) {
    _determinePosition();
    return Scaffold(
      /*
        top screen AppBar

       */
      appBar: AppBar(
        title: const Text('ARCE Client (dev)'),
        centerTitle: true,
      ),
      /*
        main map body

       */
      body: FlutterMap(
        mapController: mapController, // MapController
        options: MapOptions(
          initialCenter: currentCenter,
          initialZoom: currentZoom,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'edu.albany.arce',
          ),

          RichAttributionWidget(
            attributions: [
              TextSourceAttribution(
                'OpenStreetMap contributors',
                onTap: () =>
                    launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
              ),
            ],
          ),

          CurrentLocationLayer(),

          const MarkerLayer( // Only a demo of a marker, marker clustering plugin must be found.
            markers: [
              Marker(
                point: LatLng(42.70902764154, -73.7355723023569),
                width: 60,
                height: 60,
                child: Image(
                  image: NetworkImage('https://www.albany.edu/arce/images/Pillars2.jpg')
                ),
              ),
              Marker(
                point: LatLng(42.708, -73.736),
                width: 60,
                height: 60,
                child: Image(
                    image: NetworkImage('https://www.albany.edu/arce/images/Pillars2.jpg')
                ),
              )
            ]
          )
        ],),
      /*
        button responsible for zooming out

       */
      floatingActionButton: FloatingActionButton(
        onPressed: _zoomOut,
        tooltip: 'Zoom',
        child: const Icon(Icons.remove_circle_outline_rounded),
      ),
      /*
        button responsible for zooming in

       */
    );
  }

  @override
  void dispose() {
    _followCurrentLocationStreamController.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _followOnLocationUpdate = FollowOnLocationUpdate.always;
    _followCurrentLocationStreamController = StreamController<double?>();
  }
}

Future<Position> _determinePosition() async {
  // Done with help from the Geolocator#usage page on pub.dev.
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error(
        'Location services are not enabled. Please turn on location services if you\'d like to see your location.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error(
          'Location permissions are denied. Please give permission if you\'d like to see your location.');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied. Please give permission if you\'d like to see your location.');
  }

  return await Geolocator.getCurrentPosition();
}
