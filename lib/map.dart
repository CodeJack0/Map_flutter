import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class OSMMapScreen extends StatefulWidget {
  const OSMMapScreen({super.key});

  @override
  OSMMapScreenState createState() => OSMMapScreenState();
}

class OSMMapScreenState extends State<OSMMapScreen> {
  Location location = Location();
  LocationData? _currentLocation;
  final MapController _mapController = MapController();

  final LatLngBounds albayBounds = LatLngBounds(
    LatLng(12.95, 123.4), // Southwest
    LatLng(13.45, 124.0), // Northeast
  );

  List<Marker> _markers = [];
  bool _canPlaceMarker = false; // 👈 Add this flag

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    _currentLocation = await location.getLocation();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final LatLng initialLocation =
        _currentLocation == null
            ? LatLng(13.1771, 123.5938)
            : LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!);

    return Scaffold(
      appBar: AppBar(title: const Text('Albay, Philippines')),
      body: Column(
        children: [
          // Search Bar below AppBar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 5.0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search for a location...',
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ),
          ),

          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: initialLocation,
                    initialZoom: 12,
                    maxZoom: 16,
                    minZoom: 12,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                    onTap: (tapPosition, latlng) {
                      if (_canPlaceMarker && albayBounds.contains(latlng)) {
                        setState(() {
                          _markers = [
                            Marker(
                              point: latlng,
                              width: 80,
                              height: 80,
                              child: const Icon(
                                Icons.location_pin,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ];
                          _canPlaceMarker = false; // Reset after placing
                        });
                      }
                    },
                    onPositionChanged: (position, hasGesture) {
                      if (!albayBounds.contains(position.center)) {
                        final LatLng restrictedCenter = LatLng(
                          position.center.latitude.clamp(
                            albayBounds.southWest.latitude,
                            albayBounds.northEast.latitude,
                          ),
                          position.center.longitude.clamp(
                            albayBounds.southWest.longitude,
                            albayBounds.northEast.longitude,
                          ),
                        );
                        _mapController.move(restrictedCenter, position.zoom);
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.yourapp',
                    ),
                    const CurrentLocationLayer(),
                    MarkerLayer(markers: _markers),
                  ],
                ),

                // Floating Button to Enable Marker Mode
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        _canPlaceMarker = true;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tap on the map to place a marker.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Icon(Icons.add_location_alt),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
