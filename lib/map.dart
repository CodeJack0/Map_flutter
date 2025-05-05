import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class OSMMapScreen extends StatelessWidget {
  const OSMMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Albay, Philippines')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(13.1771, 123.5938),
          initialZoom: 10.0,
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
