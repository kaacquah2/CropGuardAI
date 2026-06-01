import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/remote/firestore_service.dart';
import '../../components/cropguard_card.dart';

/// Ghana centre — default map viewport when reports lack coordinates.
const _kGhanaCenter = LatLng(7.9465, -1.0232);

class OutbreakMapScreen extends StatefulWidget {
  const OutbreakMapScreen({super.key});

  @override
  State<OutbreakMapScreen> createState() => _OutbreakMapScreenState();
}

class _OutbreakMapScreenState extends State<OutbreakMapScreen> {
  final _firestore = sl<FirestoreService>();
  List<Map<String, dynamic>> _reports = [];
  bool _loading = true;
  String? _error;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  LatLng? _parseLatLng(Map<String, dynamic> r) {
    final lat = (r['latitude'] ?? r['lat']) as num?;
    final lng = (r['longitude'] ?? r['lng'] ?? r['lon']) as num?;
    if (lat == null || lng == null) return null;
    return LatLng(lat.toDouble(), lng.toDouble());
  }

  void _buildMarkers() {
    final markers = <Marker>{};
    var index = 0;
    for (final r in _reports) {
      final position = _parseLatLng(r);
      if (position == null) continue;
      final disease = r['disease'] as String? ??
          r['diseaseName'] as String? ??
          'Outbreak';
      markers.add(
        Marker(
          markerId: MarkerId(r['id'] as String? ?? 'report_$index'),
          position: position,
          infoWindow: InfoWindow(title: disease),
        ),
      );
      index++;
    }
    _markers = markers;
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _firestore.getOutbreakReports();
      if (mounted) {
        setState(() {
          _reports = data;
          _buildMarkers();
          _loading = false;
        });
        if (_markers.isNotEmpty && _mapController != null) {
          await _fitMarkers();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Could not load outbreak reports.';
          _loading = false;
        });
      }
    }
  }

  Future<void> _fitMarkers() async {
    if (_mapController == null || _markers.isEmpty) return;
    final bounds = LatLngBounds(
      southwest: LatLng(
        _markers.map((m) => m.position.latitude).reduce((a, b) => a < b ? a : b),
        _markers.map((m) => m.position.longitude).reduce((a, b) => a < b ? a : b),
      ),
      northeast: LatLng(
        _markers.map((m) => m.position.latitude).reduce((a, b) => a > b ? a : b),
        _markers.map((m) => m.position.longitude).reduce((a, b) => a > b ? a : b),
      ),
    );
    await _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 48),
    );
  }

  String _formatDate(dynamic ts) {
    if (ts == null) return 'Unknown date';
    DateTime dt;
    if (ts is DateTime) {
      dt = ts;
    } else if (ts is int) {
      dt = DateTime.fromMillisecondsSinceEpoch(ts);
    } else {
      return ts.toString();
    }
    return DateFormat('MMM d, yyyy').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        title: Text('Outbreak Map',
            style: Theme.of(context).textTheme.titleLarge),
        leading: BackButton(onPressed: () => context.pop()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 220,
            width: double.infinity,
            child: _loading
                ? Container(
                    color: colors.surfaceVariant,
                    child: const Center(child: CircularProgressIndicator()),
                  )
                : GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: _kGhanaCenter,
                      zoom: 6.5,
                    ),
                    markers: _markers,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    onMapCreated: (controller) async {
                      _mapController = controller;
                      if (_markers.isNotEmpty) {
                        await _fitMarkers();
                      }
                    },
                  ),
          ),
          if (!_loading && _markers.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Reports without map coordinates appear in the list below.',
                style: TextStyle(color: colors.muted, fontSize: 12),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Recent Disease Reports',
                style: Theme.of(context).textTheme.titleMedium),
          ),
          Expanded(
            child: _loading
                ? const SizedBox.shrink()
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_error!,
                                style: TextStyle(color: colors.muted)),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: _load,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _reports.isEmpty
                        ? Center(
                            child: Text(
                              'No outbreak reports yet.',
                              style: TextStyle(color: colors.muted),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView.separated(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _reports.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (_, i) {
                                final r = _reports[i];
                                final disease = r['disease'] as String? ??
                                    r['diseaseName'] as String? ??
                                    'Unknown disease';
                                final region = r['region'] as String? ??
                                    r['location'] as String? ??
                                    'Ghana';
                                final cases = (r['cases'] as num?)?.toInt() ??
                                    (r['reportCount'] as num?)?.toInt() ??
                                    1;
                                final date = _formatDate(
                                    r['timestamp'] ?? r['date']);
                                return CropGuardCard(
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: colors.diseaseBg,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Icon(Icons.warning_amber,
                                            color: colors.diseaseRed,
                                            size: 20),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(disease,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w600)),
                                            Text('$region • $date',
                                                style: TextStyle(
                                                    color: colors.muted,
                                                    fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: colors.diseaseBg,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text('$cases reports',
                                            style: TextStyle(
                                                color: colors.diseaseRed,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
