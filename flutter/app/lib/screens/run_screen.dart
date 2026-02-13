import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../services/api_service.dart';

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

  DateTime? _startTime;
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  static const CameraPosition initialPosition = CameraPosition(
    target: LatLng(52.5200, 13.4050),
    zoom: 15,
  );

  @override
  void dispose() {
    locationSub?.cancel();
    _timer?.cancel();
    super.dispose();
  }

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
    _startTime = DateTime.now();
    _elapsed = Duration.zero;

    setState(() => isRunning = true);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _elapsed = DateTime.now().difference(_startTime!);
        });
      }
    });

    locationSub = location.onLocationChanged.listen((loc) {
      if (loc.latitude == null || loc.longitude == null) return;
      final point = LatLng(loc.latitude!, loc.longitude!);

      if (route.isNotEmpty) {
        totalDistance += _calculateDistance(route.last, point);
      }
      route.add(point);
      _updatePolyline();
      mapController?.animateCamera(CameraUpdate.newLatLng(point));
      setState(() {});
    });
  }

  Future<void> stopRun() async {
    await locationSub?.cancel();
    _timer?.cancel();
    setState(() => isRunning = false);
    await _saveRunToBackend();
  }

  void _updatePolyline() {
    polylines.clear();
    polylines.add(Polyline(
      polylineId: const PolylineId('route'),
      points: route,
      width: 5,
      color: const Color(0xFF00C9FF),
      endCap: Cap.roundCap,
      startCap: Cap.roundCap,
    ));
  }

  double _calculateDistance(LatLng p1, LatLng p2) {
    const R = 6371000;
    double lat1 = p1.latitude * 0.0174533;
    double lat2 = p2.latitude * 0.0174533;
    double dLat = (p2.latitude - p1.latitude) * 0.0174533;
    double dLng = (p2.longitude - p1.longitude) * 0.0174533;
    double a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(lat1) * cos(lat2) * sin(dLng / 2) * sin(dLng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  Future<void> _saveRunToBackend() async {
    final routeData =
        route.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList();
    try {
      await ApiService.saveRun(totalDistance, routeData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Run saved!',
              style: GoogleFonts.outfit()),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to save run',
              style: GoogleFonts.outfit()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
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
            mapType: MapType.normal,
            zoomControlsEnabled: false,
          ),

          // Back button
          Positioned(
            top: 50,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_back_ios_new,
                    color: Color(0xFF1F2937), size: 18),
              ),
            ),
          ),

          // Stats Card
          Positioned(
            top: 50,
            left: 60,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statBox(
                    'Distance',
                    '${(totalDistance / 1000).toStringAsFixed(2)} km',
                    const Color(0xFF1F2937),
                  ),
                  Container(
                      width: 1, height: 30, color: Colors.grey[200]),
                  _statBox(
                    'Time',
                    _formatDuration(_elapsed),
                    const Color(0xFF1F2937),
                  ),
                  Container(
                      width: 1, height: 30, color: Colors.grey[200]),
                  _statBox(
                    'Status',
                    isRunning ? '🏃' : '⏸',
                    isRunning ? const Color(0xFFFF6B00) : const Color(0xFF9CA3AF),
                  ),
                ],
              ),
            ),
          ),

          // Start / Stop Button
          Positioned(
            bottom: 40,
            left: 40,
            right: 40,
            child: GestureDetector(
              onTap: isRunning ? stopRun : startRun,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: isRunning ? const Color(0xFFEF4444) : const Color(0xFFFF6B00),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: (isRunning
                              ? const Color(0xFFEF4444)
                              : const Color(0xFFFF6B00))
                          .withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    isRunning ? 'STOP RUN' : 'START RUN',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBox(String title, String value, Color valueColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title,
            style: GoogleFonts.outfit(color: const Color(0xFF6B7280), fontSize: 11)),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.outfit(
                color: valueColor,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}
