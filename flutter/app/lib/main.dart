// main.dart
// Flutter Run Tracking App (Strava-like basic version)
// Requires: google_maps_flutter, location, http

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const RunTrackerApp());
}

class RunTrackerApp extends StatelessWidget {
  const RunTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const RunScreen(),
    );
  }
}

class RunScreen extends StatefulWidget {
  const RunScreen({super.key});

  @override
  State<RunScreen> createState() => _RunScreenState();
}

class _RunScreenState extends State<RunScreen> {
  final Location location = Location();
  StreamSubscription<LocationData>? locationSub;

  GoogleMapController? mapController;

  bool isRunning = false;
  List<LatLng> route = [];

  double totalDistance = 0;

  final Set<Polyline> polylines = {};

  static const CameraPosition initialPosition = CameraPosition(
    target: LatLng(52.5200, 13.4050), // Berlin
    zoom: 15,
  );

  @override
  void dispose() {
    locationSub?.cancel();
    super.dispose();
  }

  // Start tracking
  Future<void> startRun() async {
    bool enabled = await location.serviceEnabled();
    if (!enabled) enabled = await location.requestService();

    PermissionStatus permission = await location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await location.requestPermission();
    }

    if (permission != PermissionStatus.granted) return;

    route.clear();
    totalDistance = 0;

    setState(() {
      isRunning = true;
    });

    locationSub = location.onLocationChanged.listen((loc) {
      if (loc.latitude == null || loc.longitude == null) return;

      final point = LatLng(loc.latitude!, loc.longitude!);

      if (route.isNotEmpty) {
        totalDistance += calculateDistance(route.last, point);
      }

      route.add(point);

      updatePolyline();

      mapController?.animateCamera(
        CameraUpdate.newLatLng(point),
      );

      setState(() {});
    });
  }

  // Stop tracking
  Future<void> stopRun() async {
    await locationSub?.cancel();

    setState(() {
      isRunning = false;
    });

    await saveRunToBackend();
  }

  // Draw polyline
  void updatePolyline() {
    polylines.clear();

    polylines.add(
      Polyline(
        polylineId: const PolylineId("route"),
        points: route,
        width: 6,
        color: Colors.orangeAccent,
        endCap: Cap.roundCap,
        startCap: Cap.roundCap,
      ),
    );
  }

  // Distance in meters (Haversine)
  double calculateDistance(LatLng p1, LatLng p2) {
    const R = 6371000; // Earth radius

    double lat1 = p1.latitude * 0.0174533;
    double lat2 = p2.latitude * 0.0174533;
    double dLat = (p2.latitude - p1.latitude) * 0.0174533;
    double dLng = (p2.longitude - p1.longitude) * 0.0174533;

    double a =
        (sin(dLat / 2) * sin(dLat / 2)) +
            cos(lat1) * cos(lat2) * sin(dLng / 2) * sin(dLng / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }

  // Send run to Java backend
  Future<void> saveRunToBackend() async {
    final data = {
      "distance": totalDistance,
      "route": route
          .map((p) => {"lat": p.latitude, "lng": p.longitude})
          .toList(),
    };

    await http.post(
      Uri.parse("http://10.0.2.2:8080/api/run"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: initialPosition,
            myLocationEnabled: true,
            polylines: polylines,
            onMapCreated: (c) => mapController = c,
          ),

          // Top Stats
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: Colors.black87,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    statBox("Distance", "${(totalDistance / 1000).toStringAsFixed(2)} km"),
                    statBox("Status", isRunning ? "Running" : "Stopped"),
                  ],
                ),
              ),
            ),
          ),

          // Start/Stop Button
          Positioned(
            bottom: 40,
            left: 40,
            right: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                backgroundColor: isRunning ? Colors.red : Colors.green,
              ),
              onPressed: isRunning ? stopRun : startRun,
              child: Text(
                isRunning ? "STOP RUN" : "START RUN",
                style: const TextStyle(fontSize: 18),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget statBox(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
