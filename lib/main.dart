import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
import 'package:flutter/services.dart';
import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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

  late StreamController<double?> _followCurrentLocationStreamController;
  int _selectedIndex = 0;
  TextEditingController textController = TextEditingController();

  // object for controlling map
  MapController mapController = MapController();

  // vars defining zoom and center, and GeoJSON parser
  double currentZoom = 14.8;
  LatLng currentCenter = const LatLng(42.70802004211283, -73.73236988003);
  GeoJsonParser arcSections = GeoJsonParser();
  GeoJsonParser headstones = GeoJsonParser();

  // function for centering on location
  Future<void> _centerOnLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    mapController.move(LatLng(position.latitude, position.longitude), currentZoom);
    CompassEvent lastCompassEvent = await FlutterCompass.events!.last;
    double? degree = lastCompassEvent.heading;
    mapController.rotate(degree!);
  }

  Future<void> _loadGeoJson() async {
    //GeoJSON Parser

      String geoString = await rootBundle.loadString('assets/geojson/ARC_Sections.geojson');
      String geoString2 = await rootBundle.loadString('assets/geojson/Projected_Sec49_Headstones.geojson');
      arcSections.parseGeoJsonAsString(geoString);
      headstones.parseGeoJsonAsString(geoString2);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      /*
        top screen AppBar

       */
      appBar: AppBar(
        title: const Text('ARCE Map'),
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
          PolylineLayer(polylines: arcSections.polylines),
          MarkerLayer(markers: arcSections.markers),
          CircleLayer(circles: arcSections.circles),
          PolygonLayer(polygons: arcSections.polygons),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: AnimSearchBar(
              width: 400,
              textController: textController,
              onSuffixTap: () {
                setState(() {
                  textController.clear();
                });
              },
              onSubmitted: (String) {
                // handle submitted text here
              },
            ),
          ),
        ],),
      extendBody: true,
      /*
        Button responsible for zooming on location
       */
      floatingActionButton: FloatingActionButton(
        onPressed: _centerOnLocation,
        tooltip: 'Zoom',
        child: const Icon(Icons.adjust),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue, // Set selected item color
        unselectedItemColor: Colors.grey, // Set unselected item color
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.layers),
            label: 'Layers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
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
    _followCurrentLocationStreamController = StreamController<double?>();
    _determinePosition();
    _loadGeoJson();
    _loadDatabase();
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

Future<List<Object>?> _loadDatabase() async {

  var dbPath = await getDatabasesPath();
  var path = join(dbPath,'data.db');
  var exists = await databaseExists(path);

  if(!exists) {
    try {
      await Directory(dirname(path)).create(recursive: true);
    } catch (_) {}

    ByteData data = await rootBundle.load('assets/db/arce.db');
    List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(path).writeAsBytes(bytes, flush: true);

  } else {
    print("Opening existing db.");
  }

  final database = openDatabase(path, readOnly: true);
  final db = await database;
  final List<Map<String, Object?>> dbMap = await db.query('arc_boundary');
  print(dbMap);
  return null ;
}

//TODO once server is connected, have a way to iterate and store the data.
//TODO have layers page working successfully.
//TODO have markers be clickable, leading to a page of theirs
//TODO have a settings page. Options to select boundaries or not and display them.
//TODO Within the layers, they must be toggleable. Have a clear all layers button.