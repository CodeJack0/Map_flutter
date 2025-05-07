import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart'; // Import the location package

class OSMMapScreen extends StatefulWidget {
  const OSMMapScreen({super.key});

  @override
  OSMMapScreenState createState() => OSMMapScreenState();
}

class OSMMapScreenState extends State<OSMMapScreen> {
  Location location = Location();
  LocationData? _currentLocation;

  // Define the bounds for Albay, Philippines (Southwest and Northeast coordinates)
  final LatLngBounds albayBounds = LatLngBounds(
    LatLng(12.95, 123.4), // Southwest corner
    LatLng(13.45, 124.0), // Northeast corner
  );

  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _getLocation(); // Call the function to get the current location
  }

  // Function to get current location
  Future<void> _getLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Check if location services are enabled
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return; // Return if the user denies enabling location service
      }
    }

    // Check if permission is granted
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return; // Return if permission is denied
      }
    }

    // Get current location data
    _currentLocation = await location.getLocation();

    setState(() {
      // Update the state with the fetched location
    });
  }

  @override
  Widget build(BuildContext context) {
    // Default to a fixed location (Albay, Philippines) if location data is not available
    final LatLng initialLocation =
        _currentLocation == null
            ? LatLng(13.1771, 123.5938) // Albay
            : LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!);

    return Scaffold(
      appBar: AppBar(title: const Text('Albay, Philippines')),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: initialLocation,
          initialZoom: 12.0, // Start at a zoom level
          maxZoom: 20.0, // Limit the zoom-out level
          minZoom: 5.0, // Prevent zooming in too far
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
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.yourapp',
          ),
        ],
      ),
    );
  }
}
