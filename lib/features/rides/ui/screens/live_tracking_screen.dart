import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/network/api_service.dart';
import '../../cubit/live_tracking_cubit.dart';
import 'package:kidsero_parent/core/theme/app_colors.dart';
import 'package:kidsero_parent/features/rides/data/rides_repository.dart';
import 'package:kidsero_parent/features/rides/data/rides_service.dart';

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
    final dio = context.read<ApiService>().dio;
    final ridesService = RidesService(dio: dio);
    final ridesRepository = RidesRepository(ridesService: ridesService);

    return BlocProvider(
      create: (context) => LiveTrackingCubit(
        rideId: widget.rideId,
        ridesRepository: ridesRepository,
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
                              rotation: state is LiveTrackingActive
                                  ? state.rotation
                                  : 0,
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
    String title = "Bus is on the move";
    String subtitle = "Receiving live updates...";

    if (state is LiveTrackingActive) {
      if (state.eta != null) {
        try {
          final etaDate = DateTime.parse(state.eta!);
          final hour = etaDate.hour > 12 ? etaDate.hour - 12 : etaDate.hour;
          final minute = etaDate.minute.toString().padLeft(2, '0');
          final period = etaDate.hour >= 12 ? 'PM' : 'AM';
          title = "ETA: $hour:$minute $period";
          subtitle = "Arriving at next stop";
        } catch (_) {
          // If parsing fails, just don't show specific ETA
        }
      } else if (state.speed != null && state.speed! > 0) {
        title = "${state.speed!.toStringAsFixed(1)} km/h";
        subtitle = "Current Speed";
      }
    }

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
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.directions_bus, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
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
  final double rotation;

  const _AnimatedBusMarker({
    required this.location,
    this.previousLocation,
    this.rotation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation * (3.14159 / 180), // Convert degrees to radians
      child: TweenAnimationBuilder<Offset>(
        tween: Tween<Offset>(begin: Offset.zero, end: Offset.zero),
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
                      color: AppColors.primary.withOpacity(0.2),
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
                decoration: BoxDecoration(
                  color: AppColors.primary,
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
      ),
    );
  }
}
