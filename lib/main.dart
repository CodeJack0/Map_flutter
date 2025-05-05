import 'package:flutter/material.dart';
import 'map.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenStreetMap Sample',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const OSMMapScreen(), // updated class name
    );
  }
}
