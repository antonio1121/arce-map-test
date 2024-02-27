import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
// import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
import 'geojson_file_reader.dart';

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

  // Current Location code courtesy of tlserver, of "flutter_map_location_marker."
  // TODO Centering on cemetery (NEED UI!)

  late AlignOnUpdate _alignOnUpdate;
  late StreamController<double?> _followCurrentLocationStreamController;

  // object for controlling map
  MapController mapController = MapController();

  // vars defining zoom and center, and GeoJSON parser
  double currentZoom = 14.0;
  LatLng currentCenter = const LatLng(42.709027641543, -73.73557230235694);
  GeoJsonParser myGeoJson = GeoJsonParser();

  // function for centering on location
  Future<void> _centerOnLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    mapController.move(LatLng(position.latitude, position.longitude), currentZoom);
    CompassEvent lastCompassEvent = await FlutterCompass.events!.last;
    double? degree = lastCompassEvent.heading;
    mapController.rotate(degree!);
  }

  Future<void> _loadGeoJson() async {
    //Geojson parser
    myGeoJson.parseGeoJsonAsString(await GeojsonFileReader().readFile());
  }

  @override
  Widget build(BuildContext context) {

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
                  image: AssetImage('assets/images/rsz_960889.png')
                ),
              ),
              Marker(
                point: LatLng(42.708, -73.736),
                width: 60,
                height: 60,
                child: Image(
                    image: AssetImage('assets/images/rsz_960889.png')
                ),
              )
            ]
          ),
          PolylineLayer(polylines: myGeoJson.polylines),
          MarkerLayer(markers: myGeoJson.markers),
          CircleLayer(circles: myGeoJson.circles),
          PolygonLayer(polygons: myGeoJson.polygons),
        ],),
      /*
        Button responsible for zooming on location
       */
      floatingActionButton: FloatingActionButton(
        onPressed: _centerOnLocation,
        tooltip: 'Zoom',
        child: const Icon(Icons.adjust),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _followCurrentLocationStreamController.close();
  }

  @override
  void initState() {
    super.initState();
    _alignOnUpdate = AlignOnUpdate.always;
    _followCurrentLocationStreamController = StreamController<double?>();
    _determinePosition();
    _loadGeoJson();
  }
}

// Internal methods area

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
