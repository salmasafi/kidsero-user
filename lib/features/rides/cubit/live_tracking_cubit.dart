import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:kidsero_driver/features/rides/data/rides_repository.dart';
import '../../../core/network/socket_service.dart';
import '../../../core/utils/app_preferences.dart';

abstract class LiveTrackingState {}

class LiveTrackingInitial extends LiveTrackingState {}

class LiveTrackingLoading extends LiveTrackingState {}

class LiveTrackingActive extends LiveTrackingState {
  final LatLng busLocation;
  final double rotation;
  final String? eta;
  final double? speed;

  LiveTrackingActive({
    required this.busLocation,
    this.rotation = 0,
    this.eta,
    this.speed,
  });
}

class LiveTrackingError extends LiveTrackingState {
  final String message;
  LiveTrackingError(this.message);
}

class LiveTrackingCubit extends Cubit<LiveTrackingState> {
  final String rideId;
  final RidesRepository ridesRepository;
  final SocketService _socketService = SocketService();

  LiveTrackingCubit({required this.rideId, required this.ridesRepository})
    : super(LiveTrackingInitial());

  Future<void> startTracking() async {
    emit(LiveTrackingLoading());
    try {
      // 1. Fetch initial location from REST API
      final trackingData = await ridesRepository.getRideTracking(rideId);

      if (trackingData.currentLocation != null) {
        final initialLocation = LatLng(
          trackingData.currentLocation!.lat,
          trackingData.currentLocation!.lng,
        );
        emit(
          LiveTrackingActive(
            busLocation: initialLocation,
            rotation: trackingData.currentLocation!.heading ?? 0,
            eta: trackingData.route?.nextStopEta,
            speed: trackingData.currentLocation!.speedKmh,
          ),
        );
      } else {
        // Fallback or just stay loading/waiting for socket
      }

      // 2. Connect to WebSocket for live updates
      final token = await AppPreferences.getToken();
      if (token == null) {
        emit(LiveTrackingError("Authentication required"));
        return;
      }

      _socketService.connect(token);

      // Delay slightly to ensure connection is established
      await Future.delayed(const Duration(seconds: 1));

      _socketService.joinRide(rideId);

      _socketService.onLocationUpdate((dynamic dataRaw) {
        try {
          Map<String, dynamic> data;
          if (dataRaw is String) {
            data = Map<String, dynamic>.from(jsonDecode(dataRaw));
          } else if (dataRaw is Map) {
            data = Map<String, dynamic>.from(dataRaw);
          } else {
            log(
              "Received unknown data type for locationUpdate: ${dataRaw.runtimeType}",
            );
            return;
          }

          if (data['rideId'] == rideId) {
            final lat = double.tryParse(data['lat'].toString()) ?? 0.0;
            final lng = double.tryParse(data['lng'].toString()) ?? 0.0;

            if (lat != 0.0 && lng != 0.0) {
              final heading =
                  double.tryParse(data['heading']?.toString() ?? '0') ?? 0.0;
              final speed = double.tryParse(data['speed']?.toString() ?? '0');

              // Preserve ETA from previous state if not in socket data
              String? eta;
              if (state is LiveTrackingActive) {
                eta = (state as LiveTrackingActive).eta;
              }

              emit(
                LiveTrackingActive(
                  busLocation: LatLng(lat, lng),
                  rotation: heading,
                  eta: eta,
                  speed: speed,
                ),
              );
            }
          }
        } catch (e) {
          log("Error parsing location update: $e");
        }
      });
    } catch (e) {
      if (state is! LiveTrackingActive) {
        emit(LiveTrackingError(e.toString()));
      }
    }
  }

  @override
  Future<void> close() {
    _socketService.leaveRide(rideId);
    return super.close();
  }
}
