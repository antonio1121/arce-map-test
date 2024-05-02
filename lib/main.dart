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
  double baseZoom = 14.8;
  double focusZoom = 14.9; // Adjust
  double baseBearing = 0.0;
  LatLng arcCenter = const LatLng(42.70752390652762, -73.73354281098088);
  // metadata
  GeoJsonParser arcBoundary = GeoJsonParser();
  GeoJsonParser arcRoads = GeoJsonParser();
  GeoJsonParser arcSections = GeoJsonParser();
  // TODO: add projected data
  // tour data
  GeoJsonParser africanAmericanTour = GeoJsonParser();
  GeoJsonParser albanyMayorsTour = GeoJsonParser();
  GeoJsonParser artistsTour = GeoJsonParser();
  GeoJsonParser associationsTour = GeoJsonParser();
  GeoJsonParser authorsPublishersTour = GeoJsonParser();
  GeoJsonParser businessFinanceTour = GeoJsonParser();
  GeoJsonParser civilWarTour = GeoJsonParser();
  GeoJsonParser garTour = GeoJsonParser();
  GeoJsonParser independence20Tour = GeoJsonParser();
  GeoJsonParser notables20Tour = GeoJsonParser();
  GeoJsonParser societyPillarsTour = GeoJsonParser();

  /*
    Function for centering on location
  */
  Future<void> _centerOnLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    mapController.move(LatLng(position.latitude, position.longitude), baseZoom);
    mapController.rotate(baseBearing);
  }

  /*
    Function for centering on cemetery middle
  */
  Future<void> _centerOnCenter() async {
    mapController.move(arcCenter, baseZoom);
    mapController.rotate(baseBearing);
  }

  /*
    Function for GeoJson parsing
  */
  Future<void> _loadGeoJson() async {      
      
      // metadata
      String arcBoundaryGeoString = await rootBundle.loadString('assets/geojson/meta/arc_boundary.geojson');
      String arcRoadsGeoString = await rootBundle.loadString('assets/geojson/meta/arc_roads.geojson');
      String arcSectionsGeoString = await rootBundle.loadString('assets/geojson/meta/arc_sections.geojson');

      // tour data
      String africanAmericanTourGeoString = await rootBundle.loadString('assets/geojson/tours/african_american.geojson');
      String albanyMayorsTourGeoString = await rootBundle.loadString('assets/geojson/tours/albany_mayors.geojson');
      String artistsTourGeoString = await rootBundle.loadString('assets/geojson/tours/artists.geojson');
      String associationsTourGeoString = await rootBundle.loadString('assets/geojson/tours/associations.geojson');
      String authorsPublishersTourGeoString = await rootBundle.loadString('assets/geojson/tours/authors_publishers.geojson');
      String businessFinanceTourGeoString = await rootBundle.loadString('assets/geojson/tours/business_finance.geojson');
      String civilWarTourGeoString = await rootBundle.loadString('assets/geojson/tours/civil_war.geojson');
      String garTourGeoString = await rootBundle.loadString('assets/geojson/tours/gar.geojson');
      String independence20TourGeoString = await rootBundle.loadString('assets/geojson/tours/independence20.geojson');
      String notables20TourGeoString = await rootBundle.loadString('assets/geojson/tours/notables20.geojson');
      String societyPillarsTourGeoString = await rootBundle.loadString('assets/geojson/tours/society_pillars.geojson');

      // parsing meta
      arcBoundary.parseGeoJsonAsString(arcBoundaryGeoString);
      arcRoads.parseGeoJsonAsString(arcRoadsGeoString);
      arcSections.parseGeoJsonAsString(arcSectionsGeoString);

      // parsing tours
      africanAmericanTour.parseGeoJsonAsString(africanAmericanTourGeoString);
      albanyMayorsTour.parseGeoJsonAsString(albanyMayorsTourGeoString);
      artistsTour.parseGeoJsonAsString(artistsTourGeoString);
      associationsTour.parseGeoJsonAsString(associationsTourGeoString);
      authorsPublishersTour.parseGeoJsonAsString(authorsPublishersTourGeoString);
      businessFinanceTour.parseGeoJsonAsString(businessFinanceTourGeoString);
      civilWarTour.parseGeoJsonAsString(civilWarTourGeoString);
      garTour.parseGeoJsonAsString(garTourGeoString);
      independence20Tour.parseGeoJsonAsString(independence20TourGeoString);
      notables20Tour.parseGeoJsonAsString();
      societyPillarsTour.parseGeoJsonAsString();
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
        title: const Text('ARC Explorer'),
      ),
      /*
        main map body

       */
      body: FlutterMap(
        mapController: mapController, // MapController
        options: MapOptions(
          initialCenter: arcCenter,
          initialZoom: baseZoom,
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
          PolylineLayer(polylines: arcBoundary.polylines),
          MarkerLayer(markers: arcSections.markers),
          CircleLayer(circles: arcSections.circles),
          PolygonLayer(polygons: arcBoundary.polygons),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            // Search bar
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AnimSearchBar(
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
                /*
                  Center on home
                */
                IconButton.filled(
                  icon: const Icon(Icons.home_rounded),
                  tooltip: 'Focus on ARC center.',
                  onPressed: _centerOnCenter,
                ),
                /*
                  Center on current user location btn
                */
                IconButton.filled(
                  icon: const Icon(Icons.near_me_rounded),
                  tooltip: 'Focus on your location.',
                  onPressed: _centerOnLocation,
                ),

              ],
            ), 
          ),
        ],),
      extendBody: false, // Make true for bottomNavigationBar to work
      /*
        Button responsible for zooming on location
       */
      /*floatingActionButton: FloatingActionButton(
        onPressed: _centerOnLocation,
        tooltip: 'Zoom',
        child: const Icon(Icons.adjust),
      ),*/
      /*bottomNavigationBar: BottomNavigationBar(
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
      ),*/
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

/*

  Internal methods area

*/

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

//TODO have layers page working successfully.
//TODO have markers be clickable, leading to a page of theirs
//TODO have a settings page. Options to select boundaries or not and display them.
//TODO Within the layers, they must be toggleable. Have a clear all layers button.