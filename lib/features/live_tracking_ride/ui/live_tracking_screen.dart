import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:kidsero_parent/features/rides/data/rides_service.dart';
import 'package:kidsero_parent/features/rides/models/api_models.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kidsero_parent/l10n/app_localizations.dart';
import 'dart:developer' as dev;
import '../cubit/live_tracking_cubit.dart';

class LiveTrackingScreen extends StatefulWidget {
  final String rideId;

  const LiveTrackingScreen({super.key, required this.rideId});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final MapController _mapController;
  LatLng? _previousLocation;
  LatLng? _currentLocation;
  bool _isMapReady = false;
  List<Marker> _stopMarkers = [];
  List<Polyline> _routePolylines = [];
  String? _childPickupPointId;
  double _busRotation = 0.0;
  
  // Cache for marker widgets to avoid recreation
  final Map<String, Widget> _markerWidgetCache = {};
  
  // Track if markers have been initialized to avoid recreation
  bool _markersInitialized = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    WidgetsBinding.instance.addObserver(this);
    dev.log('LiveTrackingScreen initialized for ride: ${widget.rideId}', name: 'LiveTrackingScreen');
  }

  @override
  void dispose() {
    dev.log('LiveTrackingScreen disposing, cleaning up resources', name: 'LiveTrackingScreen');
    _markerWidgetCache.clear();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final cubit = context.read<LiveTrackingCubit>();
    
    dev.log('App lifecycle state changed to: $state', name: 'LiveTrackingScreen');
    
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // App going to background
        dev.log('Pausing tracking due to app lifecycle', name: 'LiveTrackingScreen');
        cubit.pauseTracking();
        break;
      case AppLifecycleState.resumed:
        // App coming to foreground
        dev.log('Resuming tracking due to app lifecycle', name: 'LiveTrackingScreen');
        cubit.resumeTracking();
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  /// Calculate bounds from route stops and bus location
  LatLngBounds? _calculateBounds(RideTrackingData trackingData) {
    final startTime = DateTime.now();
    final points = <LatLng>[];

    // Add all valid route stops
    for (final stop in trackingData.route.validStops) {
      final lat = stop.latitudeValue;
      final lng = stop.longitudeValue;
      if (lat != null && lng != null) {
        points.add(LatLng(lat, lng));
      }
    }

    // Add bus location if available
    if (trackingData.bus.hasValidCurrentLocation) {
      final lat = trackingData.bus.currentLatitude;
      final lng = trackingData.bus.currentLongitude;
      if (lat != null && lng != null) {
        points.add(LatLng(lat, lng));
      }
    }

    // Handle edge cases
    if (points.isEmpty) {
      dev.log('No valid points for bounds calculation', name: 'LiveTrackingScreen', level: 900);
      return null;
    }

    if (points.length == 1) {
      // Single point - create small bounds around it
      final point = points.first;
      return LatLngBounds(
        LatLng(point.latitude - 0.01, point.longitude - 0.01),
        LatLng(point.latitude + 0.01, point.longitude + 0.01),
      );
    }

    final duration = DateTime.now().difference(startTime);
    dev.log('Calculated bounds for ${points.length} points in ${duration.inMilliseconds}ms', 
      name: 'LiveTrackingScreen');

    return LatLngBounds.fromPoints(points);
  }

  /// Fit map camera to show all route elements
  void _fitMapToRoute(RideTrackingData trackingData) {
    if (!_isMapReady) {
      dev.log('Map not ready, skipping fit to route', name: 'LiveTrackingScreen', level: 500);
      return;
    }

    final bounds = _calculateBounds(trackingData);
    if (bounds == null) {
      dev.log('No bounds available, skipping fit to route', name: 'LiveTrackingScreen', level: 900);
      return;
    }

    try {
      final startTime = DateTime.now();
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(50.0),
        ),
      );
      final duration = DateTime.now().difference(startTime);
      dev.log('Fitted camera to route in ${duration.inMilliseconds}ms', name: 'LiveTrackingScreen');
    } catch (e, stackTrace) {
      dev.log('Error fitting camera to route', 
        name: 'LiveTrackingScreen', 
        error: e, 
        stackTrace: stackTrace,
        level: 1000);
    }
  }

  /// Recenter camera on bus location
  void _recenterOnBus() {
    if (!_isMapReady) {
      dev.log('Map not ready, skipping recenter', name: 'LiveTrackingScreen', level: 500);
      return;
    }
    
    if (_currentLocation == null) {
      dev.log('No current bus location, skipping recenter', name: 'LiveTrackingScreen', level: 900);
      return;
    }

    try {
      _mapController.move(_currentLocation!, 15.0);
      dev.log('Recentered camera on bus location: ${_currentLocation!.latitude}, ${_currentLocation!.longitude}', 
        name: 'LiveTrackingScreen');
    } catch (e, stackTrace) {
      dev.log('Error recentering camera', 
        name: 'LiveTrackingScreen', 
        error: e, 
        stackTrace: stackTrace,
        level: 1000);
    }
  }

  /// Initialize map data with route, stops, and markers
  void _initializeMapData(RideTrackingData trackingData) {
    // Skip if already initialized to avoid recreation
    if (_markersInitialized) {
      dev.log('Markers already initialized, skipping', name: 'LiveTrackingScreen');
      return;
    }
    
    dev.log('Initializing map data with ${trackingData.route.validStops.length} stops', 
      name: 'LiveTrackingScreen');
    final startTime = DateTime.now();
    
    // Create route polyline
    final routePoints = <LatLng>[];
    for (final stop in trackingData.route.sortedValidStops) {
      final lat = stop.latitudeValue;
      final lng = stop.longitudeValue;
      if (lat != null && lng != null) {
        routePoints.add(LatLng(lat, lng));
      }
    }

    if (routePoints.isNotEmpty) {
      _routePolylines = [
        Polyline(
          points: routePoints,
          color: const Color(0xFF4F46E5),
          strokeWidth: 4.0,
          pattern: StrokePattern.dashed(segments: [10, 5]),
        ),
      ];
      dev.log('Created route polyline with ${routePoints.length} points', name: 'LiveTrackingScreen');
    } else {
      dev.log('No valid route points for polyline', name: 'LiveTrackingScreen', level: 900);
    }

    // Create stop markers with caching
    final markers = <Marker>[];
    int cachedCount = 0;
    int createdCount = 0;
    
    for (final stop in trackingData.route.validStops) {
      final lat = stop.latitudeValue;
      final lng = stop.longitudeValue;
      if (lat == null || lng == null) {
        dev.log('Skipping stop ${stop.id} with invalid coordinates', 
          name: 'LiveTrackingScreen', level: 900);
        continue;
      }

      final isChildPickup = stop.id == _childPickupPointId;
      
      // Create cached marker widget if not exists
      if (!_markerWidgetCache.containsKey(stop.id)) {
        _markerWidgetCache[stop.id] = GestureDetector(
          onTap: () => _showStopDetails(context, stop, isChildPickup, trackingData),
          child: Container(
            decoration: BoxDecoration(
              color: isChildPickup
                  ? const Color(0xFFFF6B6B)
                  : const Color(0xFF4F46E5),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '${stop.stopOrder}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
        createdCount++;
      } else {
        cachedCount++;
      }

      markers.add(
        Marker(
          point: LatLng(lat, lng),
          width: 40,
          height: 40,
          child: _markerWidgetCache[stop.id]!,
        ),
      );
    }

    setState(() {
      _stopMarkers = markers;
      _markersInitialized = true;
    });

    final duration = DateTime.now().difference(startTime);
    dev.log('Map initialization complete: ${markers.length} markers (${createdCount} created, ${cachedCount} cached) in ${duration.inMilliseconds}ms', 
      name: 'LiveTrackingScreen');

    // Fit camera to show all elements
    _fitMapToRoute(trackingData);
  }

  /// Show stop details in a bottom sheet when marker is tapped
  void _showStopDetails(BuildContext context, RouteStop stop, bool isChildPickup, RideTrackingData trackingData) {
    final l10n = AppLocalizations.of(context);
    
    // Find children assigned to this stop
    final childrenAtStop = trackingData.children.where((child) => child.pickupPoint.id == stop.id).toList();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with stop order badge
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isChildPickup ? const Color(0xFFFF6B6B) : const Color(0xFF4F46E5),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${stop.stopOrder}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stop.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isChildPickup)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B6B).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            l10n != null && l10n.yourChildPickupPoint.isNotEmpty 
                                ? l10n.yourChildPickupPoint 
                                : "Your Child's Pickup Point",
                            style: const TextStyle(
                              color: Color(0xFFFF6B6B),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Stop address
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, color: Colors.grey, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    stop.address,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            
            // Children at this stop
            if (childrenAtStop.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.people, color: Color(0xFF4F46E5), size: 20),
                  const SizedBox(width: 12),
                  Text(
                    l10n != null && l10n.childrenAtThisStop.isNotEmpty 
                        ? l10n.childrenAtThisStop 
                        : "Children at this stop",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...childrenAtStop.map((child) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const SizedBox(width: 32),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4F46E5),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      child.child.name,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              )),
            ],
            
            const SizedBox(height: 16),
            
            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(l10n != null && l10n.close.isNotEmpty ? l10n.close : "Close"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine text direction based on locale
    final locale = Localizations.localeOf(context);
    final isRTL = locale.languageCode == 'ar';
    
    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: BlocProvider(
        create: (context) => LiveTrackingCubit(
          rideId: widget.rideId,
          ridesService: context.read<RidesService>(),
        )..startTracking(),
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context)?.liveTracking ?? "Live Tracking",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          body: BlocConsumer<LiveTrackingCubit, LiveTrackingState>(
          listener: (context, state) {
            if (state is LiveTrackingActive) {
              setState(() {
                _previousLocation = _currentLocation;
                _currentLocation = state.busLocation;
                _busRotation = state.rotation;
              });

              // Initialize map data on first load only
              if (!_markersInitialized && state.trackingData.route.validStops.isNotEmpty) {
                _initializeMapData(state.trackingData);
              }

              // Smoothly move the map to the new location if map is ready
              if (_isMapReady && _currentLocation != null) {
                _mapController.move(
                  _currentLocation!,
                  _mapController.camera.zoom,
                );
              }
            }
          },
          builder: (context, state) {
            if (state is LiveTrackingLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is LiveTrackingError) {
              return Center(child: Text(state.message));
            }

            return Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentLocation ?? const LatLng(0, 0),
                    initialZoom: 15.0,
                    minZoom: 5.0,
                    maxZoom: 18.0,
                    onMapReady: () {
                      setState(() {
                        _isMapReady = true;
                      });
                      dev.log('Map ready for interaction', name: 'LiveTrackingScreen');
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.kidsero.user',
                      maxNativeZoom: 18,
                      maxZoom: 18,
                      tileProvider: NetworkTileProvider(),
                    ),
                    // Route polyline layer
                    if (_routePolylines.isNotEmpty)
                      PolylineLayer(
                        polylines: _routePolylines,
                        simplificationTolerance: 0.5,
                      ),
                    // Stop markers layer
                    if (_stopMarkers.isNotEmpty)
                      MarkerLayer(
                        markers: _stopMarkers,
                      ),
                    // Bus marker layer (on top)
                    if (_currentLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _currentLocation!,
                            width: 80,
                            height: 80,
                            child: _AnimatedBusMarker(
                              location: _currentLocation!,
                              previousLocation: _previousLocation,
                              rotation: _busRotation,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                // Camera control buttons
                if (state is LiveTrackingActive)
                  Positioned(
                    right: 16,
                    bottom: 120,
                    child: Column(
                      children: [
                        // Fit all markers button
                        FloatingActionButton(
                          heroTag: 'fit_all',
                          mini: true,
                          backgroundColor: Colors.white,
                          onPressed: () => _fitMapToRoute(state.trackingData),
                          child: const Icon(
                            Icons.zoom_out_map,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Recenter on bus button
                        FloatingActionButton(
                          heroTag: 'recenter',
                          mini: true,
                          backgroundColor: Colors.white,
                          onPressed: _recenterOnBus,
                          child: const Icon(
                            Icons.my_location,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                      ],
                    ),
                  ),
                _buildTrackingOverlay(state),
              ],
            );
          },
        ),
      ),
    ),
    );
  }

  Widget _buildTrackingOverlay(LiveTrackingState state) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.directions_bus, color: Color(0xFF4F46E5)),
            ),
            const SizedBox(width: 16),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Bus is on the move",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  "Receiving live updates...",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn().slideY(begin: 1),
    );
  }
}

/// Animated bus marker with smooth rotation and pulsing effect
class _AnimatedBusMarker extends StatefulWidget {
  final LatLng location;
  final LatLng? previousLocation;
  final double rotation;

  const _AnimatedBusMarker({
    required this.location,
    this.previousLocation,
    this.rotation = 0.0,
  });

  @override
  State<_AnimatedBusMarker> createState() => _AnimatedBusMarkerState();
}

class _AnimatedBusMarkerState extends State<_AnimatedBusMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  double _currentRotation = 0.0;

  @override
  void initState() {
    super.initState();
    _currentRotation = widget.rotation;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: _currentRotation,
      end: widget.rotation,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(_AnimatedBusMarker oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Animate rotation change smoothly
    if (oldWidget.rotation != widget.rotation) {
      _rotationAnimation = Tween<double>(
        begin: _currentRotation,
        end: widget.rotation,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));
      _animationController.forward(from: 0.0).then((_) {
        setState(() {
          _currentRotation = widget.rotation;
        });
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer pulsing glow
            Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.2),
                  ),
                )
                .animate(onPlay: (controller) => controller.repeat())
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.2, 1.2),
                  duration: 1.seconds,
                )
                .fadeOut(duration: 1.seconds),

            // Bus Icon with smooth rotation
            Transform.rotate(
              angle: _rotationAnimation.value * (3.14159 / 180), // Convert degrees to radians
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF4F46E5),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.directions_bus_filled,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
