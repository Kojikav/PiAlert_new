import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/ors_config.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/pialert_app_bar.dart';
import '../../services/location_service.dart';
import '../../providers/reports_provider.dart';
import '../../providers/siaga_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final LocationService _locationService = LocationService();
  
  LatLng? _currentLocation;
  List<Marker> _titikKumpulMarkers = [];
  List<Polyline> _routingLines = [];
  bool _isLoading = true;
  bool _isRoutingLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMapData();
  }

  Future<void> _loadMapData() async {
    await _loadTitikKumpul();
    setState(() => _isLoading = false);
    _getCurrentLocation();
  }

  Future<void> _loadTitikKumpul() async {
    try {
      final jsonString = await rootBundle.loadString('assets/geojson/titik_kumpul.geojson');
      final data = json.decode(jsonString);
      final features = data['features'] as List;

      _titikKumpulMarkers = features.map((feature) {
        final coords = feature['geometry']['coordinates'];
        final name = feature['properties']['name'] ?? '';
        return Marker(
          point: LatLng(coords[1], coords[0]),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () => _showMarkerInfo(name, feature['properties']),
            child: const Icon(Icons.location_on, color: Colors.blue, size: 40),
          ),
        );
      }).toList();
    } catch (e) {
      debugPrint('Error loading titik kumpul: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final hasPermission = await _locationService.requestPermission();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Izin lokasi diperlukan untuk menampilkan posisi Anda')),
          );
        }
        return;
      }
      final position = await _locationService.getCurrentLocation();
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  void _showMarkerInfo(String title, Map<String, dynamic> properties) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (properties['capacity'] != null)
              Text('Kapasitas: ${properties['capacity']} orang'),
            if (properties['facilities'] != null)
              Text('Fasilitas: ${properties['facilities']}'),
          ],
        ),
      ),
    );
  }

  void _showReportInfo(dynamic report) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(report.category, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(report.description),
            if (report.photoUrl != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: report.photoUrl!, height: 150, width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(height: 150, color: Colors.grey[200]),
                  errorWidget: (context, url, error) => Container(height: 150, color: Colors.grey[200],
                      child: const Icon(Icons.broken_image)),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text('Oleh: ${report.authorName}', style: Theme.of(context).textTheme.bodySmall),
            Text(DateFormatter.timeAgo(report.createdAt), style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  LatLng? _findNearestTitikKumpul() {
    if (_currentLocation == null || _titikKumpulMarkers.isEmpty) return null;
    LatLng? nearestPoint;
    double minDistance = double.infinity;

    for (final marker in _titikKumpulMarkers) {
      final distance = Geolocator.distanceBetween(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
        marker.point.latitude,
        marker.point.longitude,
      );
      if (distance < minDistance) {
        minDistance = distance;
        nearestPoint = marker.point;
      }
    }
    return nearestPoint;
  }

  Future<void> _fetchRouteToNearest() async {
    if (_currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lokasi pengguna belum terdeteksi. Pastikan GPS aktif.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (OrsConfig.apiKey == 'YOUR_ORS_API_KEY_HERE' || OrsConfig.apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('API Key ORS belum diisi. Silakan salin API Key Anda ke ors_config.dart.'),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 6),
        ),
      );
      return;
    }

    final destination = _findNearestTitikKumpul();
    if (destination == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ditemukan titik kumpul terdekat.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isRoutingLoading = true;
    });

    try {
      final startLng = _currentLocation!.longitude;
      final startLat = _currentLocation!.latitude;
      final endLng = destination.longitude;
      final endLat = destination.latitude;

      final url = Uri.parse(
        'https://api.openrouteservice.org/v2/directions/driving-car'
        '?api_key=${OrsConfig.apiKey}'
        '&start=$startLng,$startLat'
        '&end=$endLng,$endLat',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> coordinates =
            data['features'][0]['geometry']['coordinates'];

        final List<LatLng> routePoints = coordinates.map((coord) {
          return LatLng(coord[1] as double, coord[0] as double);
        }).toList();

        setState(() {
          _routingLines = [
            Polyline(
              points: routePoints,
              strokeWidth: 5.5,
              color: Colors.deepOrange,
            ),
          ];
        });

        _fitRouteBounds(_currentLocation!, destination);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Rute evakuasi terdekat berhasil ditampilkan'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        final errorMsg = response.statusCode == 401 || response.statusCode == 403
            ? 'API Key ORS tidak valid. Periksa kembali token Anda.'
            : 'Gagal menghubungi server navigasi ORS.';
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Koneksi rute bermasalah: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRoutingLoading = false;
        });
      }
    }
  }

  void _fitRouteBounds(LatLng start, LatLng end) {
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds(start, end),
        padding: const EdgeInsets.all(80),
      ),
    );
  }

  void _clearRoute() {
    setState(() {
      _routingLines = [];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rute navigasi dibersihkan'),
      ),
    );
  }

  List<Marker> _buildReportMarkers(List<dynamic> reports) {
    return reports.map((report) {
      return Marker(
        point: LatLng(report.latitude, report.longitude),
        width: 36,
        height: 36,
        child: GestureDetector(
          onTap: () => _showReportInfo(report),
          child: const Icon(Icons.report, color: Colors.red, size: 36),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final reports = context.watch<ReportsProvider>().reports;
    final reportMarkers = _buildReportMarkers(reports);
    final allMarkers = [..._titikKumpulMarkers, ...reportMarkers];
    
    final status = context.watch<SiagaProvider>().status;

    return Scaffold(
      appBar: const PiAlertAppBar(
        icon: Icons.map,
        title: 'Peta Interaktif',
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: const LatLng(-7.5754, 110.4458),
          initialZoom: 13.0,
          minZoom: 10.0,
          maxZoom: 18.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.pialert.pialert',
          ),
          CircleLayer(
            circles: [
              if (status != null && status.dangerRadius > 0)
                CircleMarker(
                  point: const LatLng(-7.5407, 110.4457),
                  radius: status.dangerRadius * 1000,
                  useRadiusInMeter: true,
                  color: Colors.red.withValues(alpha: 0.15),
                  borderColor: Colors.red,
                  borderStrokeWidth: 2.0,
                ),
            ],
          ),
          PolylineLayer(polylines: _routingLines),
          MarkerLayer(markers: allMarkers),
          if (_currentLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _currentLocation!,
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.my_location, color: AppColors.primary, size: 40),
                ),
              ],
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'report',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.createReport),
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.small(
            heroTag: 'routing',
            backgroundColor: _routingLines.isNotEmpty ? Colors.deepOrange : AppColors.primary,
            foregroundColor: Colors.white,
            onPressed: _isRoutingLoading
                ? null
                : () {
                    if (_routingLines.isNotEmpty) {
                      _clearRoute();
                    } else {
                      _fetchRouteToNearest();
                    }
                  },
            child: _isRoutingLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      color: Colors.white,
                    ),
                  )
                : Icon(_routingLines.isNotEmpty ? Icons.navigation : Icons.directions),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.small(
            heroTag: 'location',
            onPressed: () {
              if (_currentLocation != null) {
                _mapController.move(_currentLocation!, 15.0);
              }
            },
            child: const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }
}
