import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/network/api_service.dart';
import '../cubit/live_tracking_cubit.dart';

class LiveTrackingScreen extends StatefulWidget {
  final String rideId;

  const LiveTrackingScreen({Key? key, required this.rideId}) : super(key: key);

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen>
    with TickerProviderStateMixin {
  late final MapController _mapController;
  LatLng? _previousLocation;
  LatLng? _currentLocation;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LiveTrackingCubit(
        rideId: widget.rideId,
        apiService: context.read<ApiService>(),
      )..startTracking(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Live Tracking",
            style: TextStyle(fontWeight: FontWeight.bold),
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
                if (_previousLocation != null) {
                  // Calculate orientation if we wanted to
                }
              });

              // Smoothly move the map to the new location if map is ready
              if (_isMapReady) {
                _mapController.move(
                  state.busLocation,
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
                    onMapReady: () {
                      _isMapReady = true;
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.kidsero.user',
                    ),
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
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                _buildTrackingOverlay(state),
              ],
            );
          },
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
              color: Colors.black.withOpacity(0.1),
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
                color: const Color(0xFF4F46E5).withOpacity(0.1),
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

class _AnimatedBusMarker extends StatelessWidget {
  final LatLng location;
  final LatLng? previousLocation;

  const _AnimatedBusMarker({required this.location, this.previousLocation});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween<Offset>(
        begin: Offset.zero, // This is just for internal widget animation
        end: Offset.zero,
      ),
      duration: const Duration(seconds: 2),
      builder: (context, value, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow
            Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF4F46E5).withOpacity(0.2),
                  ),
                )
                .animate(onPlay: (controller) => controller.repeat())
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.2, 1.2),
                  duration: 1.seconds,
                )
                .fadeOut(duration: 1.seconds),

            // Bus Icon
            Container(
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
          ],
        );
      },
    );
  }
}
