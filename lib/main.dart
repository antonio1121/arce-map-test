import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
import 'package:flutter/services.dart';
import 'package:anim_search_bar/anim_search_bar.dart';


// For Layer Toggle Popup Menu
enum SampleItem { itemOne, itemTwo, itemThree }

void main() {
  runApp(MaterialApp(
    home: const MyApp(),
    theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blueGrey)),
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
  TextEditingController textController = TextEditingController();

  MapController mapController = MapController();

  // For Layer Toggle Popup Menu
  SampleItem? selectedItem;

  double baseZoom = 14.8;
  double focusZoom = 14.9;
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

  // Method for centering on user current location
  Future<void> _centerOnLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    mapController.move(LatLng(position.latitude, position.longitude), baseZoom);
    mapController.rotate(baseBearing);
  }

  // Method for centering on Chestur Arthur grave
  Future<void> _centerOnCenter() async {
    mapController.move(arcCenter, baseZoom);
    mapController.rotate(baseBearing);
  }

  // Method for GeoJson parsing
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
      notables20Tour.parseGeoJsonAsString(notables20TourGeoString);
      societyPillarsTour.parseGeoJsonAsString(societyPillarsTourGeoString);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('ARC Explorer'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.settings_rounded,
              color: Colors.black54,
            ),
            onPressed: () {

            },
            )
        ],
      ),
      
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
          // ArcBoundary
          PolygonLayer(polygons: arcBoundary.polygons),
          // ArcRoads
          PolylineLayer(polylines: arcRoads.polylines),
          // ARCSections
          PolygonLayer(polygons: arcSections.polygons),
          // ARC Tour layers
          // African American Tour
          MarkerLayer(markers: africanAmericanTour.markers),
          // Albany Mayors Tour
          MarkerLayer(markers: albanyMayorsTour.markers),
          // Artists Tour
          MarkerLayer(markers: artistsTour.markers),
          // Associations Tour
          MarkerLayer(markers: associationsTour.markers),
          // Authors Publishers Tour
          MarkerLayer(markers: authorsPublishersTour.markers),
          // Business Finance Tour
          MarkerLayer(markers: businessFinanceTour.markers),
          // Civil War Tour
          MarkerLayer(markers: civilWarTour.markers),
          // GAR Tour
          MarkerLayer(markers: garTour.markers),
          // Independence 20 Tour
          MarkerLayer(markers: independence20Tour.markers),
          // Notables 20 tour
          MarkerLayer(markers: notables20Tour.markers),
          // Society Pillars tour
          MarkerLayer(markers: societyPillarsTour.markers),
          // Button group
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
                // Focus on map home
                IconButton.filled(
                  icon: const Icon(Icons.home_rounded),
                  tooltip: 'Focus on map center.',
                  onPressed: _centerOnCenter,
                ),
                // Focus on current location
                IconButton.filled(
                  icon: const Icon(Icons.near_me_rounded),
                  tooltip: 'Focus on current location.',
                  onPressed: _centerOnLocation,
                ),

              ],
            ), 
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