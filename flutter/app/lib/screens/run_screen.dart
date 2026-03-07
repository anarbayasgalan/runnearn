import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../services/api_service.dart';
import '../widgets/glass_container.dart';
import '../theme.dart';

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
  double _currentPace = 0; // min/km
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
        // Pace = elapsed minutes / distance in km
        final elapsedMinutes = _elapsed.inSeconds / 60.0;
        final distanceKm = totalDistance / 1000.0;
        if (distanceKm > 0) {
          _currentPace = elapsedMinutes / distanceKm;
        }
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
      await ApiService.saveRun(
        totalDistance,
        routeData,
        pace: _currentPace > 0 ? _currentPace : null,
        durationSeconds: _elapsed.inSeconds,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Run saved!', style: GoogleFonts.lexend()),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to save run', style: GoogleFonts.lexend()),
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

  /// Format pace as mm:ss /km  (e.g. 5:30 /km)
  String _formatPace(double paceMinPerKm) {
    if (paceMinPerKm <= 0) return '--:-- /km';
    final mins = paceMinPerKm.floor();
    final secs = ((paceMinPerKm - mins) * 60).round();
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')} /km';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Google Map (Full Screen Background)
          GoogleMap(
            initialCameraPosition: initialPosition,
            myLocationEnabled: true,
            polylines: polylines,
            onMapCreated: (c) => mapController = c,
            mapType: MapType.normal,
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
          ),

          // 2. Back button (Glass)
          Positioned(
            top: 50,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: GlassContainer(
                width: 44,
                height: 44,
                borderRadius: 22,
                padding: EdgeInsets.zero,
                child: const Icon(Icons.arrow_back_ios_new,
                    color: AppTheme.primaryDark, size: 18),
              ),
            ),
          ),

          // 3. Stats Card (Glass)
          Positioned(
            top: 50,
            left: 70,
            right: 16,
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              borderRadius: 24,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statBox(
                    'Distance',
                    '${(totalDistance / 1000).toStringAsFixed(2)} km',
                    AppTheme.primaryDark,
                  ),
                  Container(
                      width: 1, height: 30, color: AppTheme.primaryDark.withValues(alpha: 0.1)),
                  _statBox(
                    'Time',
                    _formatDuration(_elapsed),
                    AppTheme.primaryDark,
                  ),
                  Container(
                      width: 1, height: 30, color: AppTheme.primaryDark.withValues(alpha: 0.1)),
                  _statBox(
                    'Pace',
                    _formatPace(_currentPace),
                    AppTheme.primaryOrange,
                  ),
                  Container(
                      width: 1, height: 30, color: AppTheme.primaryDark.withValues(alpha: 0.1)),
                  _statBox(
                    'Status',
                    isRunning ? '🏃' : '⏸',
                    isRunning ? AppTheme.primaryOrange : Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          ),

          // 4. Start / Stop Button (Glass over solid color)
          Positioned(
            bottom: 40,
            left: 40,
            right: 40,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: (isRunning
                            ? const Color(0xFFEF4444)
                            : AppTheme.primaryOrange)
                        .withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: isRunning ? stopRun : startRun,
                child: GlassContainer(
                  height: 60,
                  borderRadius: 30,
                  color: isRunning
                      ? const Color(0xFFEF4444).withValues(alpha: 0.8)
                      : AppTheme.primaryOrange.withValues(alpha: 0.8),
                  borderColor: isRunning
                      ? const Color(0xFFEF4444).withValues(alpha: 0.9)
                      : AppTheme.primaryOrange.withValues(alpha: 0.9),
                  child: Center(
                    child: Text(
                      isRunning ? 'STOP RUN' : 'START RUN',
                      style: GoogleFonts.lexend(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
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
            style: GoogleFonts.lexend(color: Colors.grey.shade700, fontSize: 11, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.lexend(
                color: valueColor,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}
