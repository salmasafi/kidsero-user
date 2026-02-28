import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidsero_parent/features/rides/data/rides_service.dart';
import 'package:kidsero_parent/features/rides/models/api_models.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/network/socket_service.dart';
import '../../../core/utils/app_preferences.dart';

abstract class LiveTrackingState {}

class LiveTrackingInitial extends LiveTrackingState {}

class LiveTrackingLoading extends LiveTrackingState {}

class LiveTrackingActive extends LiveTrackingState {
  final LatLng busLocation;
  final double rotation;
  final RideTrackingData trackingData;
  final bool isConnected;
  final bool isPolling;

  LiveTrackingActive({
    required this.busLocation,
    required this.trackingData,
    this.rotation = 0,
    this.isConnected = true,
    this.isPolling = false,
  });

  LiveTrackingActive copyWith({
    LatLng? busLocation,
    double? rotation,
    RideTrackingData? trackingData,
    bool? isConnected,
    bool? isPolling,
  }) {
    return LiveTrackingActive(
      busLocation: busLocation ?? this.busLocation,
      rotation: rotation ?? this.rotation,
      trackingData: trackingData ?? this.trackingData,
      isConnected: isConnected ?? this.isConnected,
      isPolling: isPolling ?? this.isPolling,
    );
  }
}

class LiveTrackingError extends LiveTrackingState {
  final String message;
  final String? errorType;
  LiveTrackingError(this.message, {this.errorType});
}

class LiveTrackingCubit extends Cubit<LiveTrackingState> {
  final String rideId;
  final RidesService ridesService;
  final SocketService _socketService = SocketService();
  
  // Throttling
  DateTime? _lastUpdateTime;
  static const _updateThrottleDuration = Duration(seconds: 1);
  
  // Lifecycle management
  bool _isPaused = false;
  Timer? _pollingTimer;
  
  // Connection tracking
  bool _isWebSocketConnected = false;
  int _reconnectAttempts = 0;
  static const _maxReconnectAttempts = 3;
  static const _pollingInterval = Duration(seconds: 5);

  LiveTrackingCubit({required this.rideId, required this.ridesService})
      : super(LiveTrackingInitial());

  Future<void> startTracking() async {
    if (_isPaused) {
      log("Tracking is paused, skipping start", name: "LiveTrackingCubit");
      return;
    }
    
    log("Starting tracking for ride: $rideId", name: "LiveTrackingCubit");
    emit(LiveTrackingLoading());
    
    try {
      // 1. Fetch initial tracking data from REST API
      final startTime = DateTime.now();
      final response = await ridesService.getRideTrackingByOccurrence(rideId);
      final fetchDuration = DateTime.now().difference(startTime);
      log("Fetched tracking data in ${fetchDuration.inMilliseconds}ms", name: "LiveTrackingCubit");
      
      if (response.data == null) {
        log("No tracking data available for ride: $rideId", name: "LiveTrackingCubit", level: 900);
        emit(LiveTrackingError(
          "No tracking data available",
          errorType: "NO_DATA",
        ));
        return;
      }
      
      final trackingData = response.data!;
      log("Tracking data loaded: ${trackingData.route.stops.length} stops, bus: ${trackingData.bus.busNumber}", 
        name: "LiveTrackingCubit");

      // Parse initial bus location
      final currentLocation = trackingData.bus.currentLocation;
      LatLng initialLocation;
      
      if (currentLocation is Map) {
        final lat = double.tryParse(currentLocation['lat']?.toString() ?? '0') ?? 0.0;
        final lng = double.tryParse(currentLocation['lng']?.toString() ?? '0') ?? 0.0;
        initialLocation = LatLng(lat, lng);
        log("Initial bus location: $lat, $lng", name: "LiveTrackingCubit");
      } else {
        // Fallback: use first stop location if bus location not available
        if (trackingData.route.stops.isNotEmpty) {
          final firstStop = trackingData.route.stops.first;
          final lat = double.tryParse(firstStop.lat) ?? 0.0;
          final lng = double.tryParse(firstStop.lng) ?? 0.0;
          initialLocation = LatLng(lat, lng);
          log("Using first stop as initial location: $lat, $lng", name: "LiveTrackingCubit", level: 500);
        } else {
          log("No location data available for ride: $rideId", name: "LiveTrackingCubit", level: 1000);
          emit(LiveTrackingError(
            "No location data available",
            errorType: "NO_LOCATION",
          ));
          return;
        }
      }

      // Emit initial state with full tracking data
      emit(LiveTrackingActive(
        busLocation: initialLocation,
        trackingData: trackingData,
        isConnected: false,
        isPolling: false,
      ));

      // 2. Try to connect to WebSocket for live updates
      await _connectWebSocket();
    } catch (e, stackTrace) {
      log("Error starting tracking", name: "LiveTrackingCubit", error: e, stackTrace: stackTrace);
      if (state is! LiveTrackingActive) {
        emit(LiveTrackingError(
          e.toString(),
          errorType: "INITIALIZATION_ERROR",
        ));
      } else {
        // If we already have data, fall back to polling
        log("Falling back to polling after initialization error", name: "LiveTrackingCubit", level: 900);
        _startPolling();
      }
    }
  }

  Future<void> _connectWebSocket() async {
    try {
      log("Attempting WebSocket connection", name: "LiveTrackingCubit");
      final token = await AppPreferences.getToken();
      if (token == null) {
        log("No auth token, falling back to polling", name: "LiveTrackingCubit", level: 900);
        _startPolling();
        return;
      }

      _socketService.connect(token);
      await Future.delayed(const Duration(seconds: 1));
      
      _socketService.joinRide(rideId);
      _isWebSocketConnected = true;
      _reconnectAttempts = 0;

      log("WebSocket connected successfully for ride: $rideId", name: "LiveTrackingCubit");

      // Update state to show WebSocket connection
      if (state is LiveTrackingActive) {
        final currentState = state as LiveTrackingActive;
        emit(currentState.copyWith(isConnected: true, isPolling: false));
      }

      _socketService.onLocationUpdate((dynamic dataRaw) {
        if (_isPaused) return;
        handleLocationUpdate(dataRaw);
      });
    } catch (e, stackTrace) {
      log("WebSocket connection failed", name: "LiveTrackingCubit", error: e, stackTrace: stackTrace);
      _isWebSocketConnected = false;
      _reconnectAttempts++;
      
      if (_reconnectAttempts < _maxReconnectAttempts) {
        log("Retrying WebSocket connection (attempt $_reconnectAttempts/$_maxReconnectAttempts)", 
          name: "LiveTrackingCubit", level: 500);
        await Future.delayed(Duration(seconds: _reconnectAttempts * 2));
        await _connectWebSocket();
      } else {
        log("Max reconnect attempts reached ($_maxReconnectAttempts), falling back to polling", 
          name: "LiveTrackingCubit", level: 900);
        _startPolling();
      }
    }
  }

  @visibleForTesting
  void handleLocationUpdate(dynamic dataRaw) {
    // Check if paused
    if (_isPaused) return;
    
    // Throttle updates to max 1 per second
    final now = DateTime.now();
    if (_lastUpdateTime != null && 
        now.difference(_lastUpdateTime!) < _updateThrottleDuration) {
      return;
    }
    _lastUpdateTime = now;

    try {
      Map<String, dynamic> data;
      if (dataRaw is String) {
        data = Map<String, dynamic>.from(jsonDecode(dataRaw));
      } else if (dataRaw is Map) {
        data = Map<String, dynamic>.from(dataRaw);
      } else {
        log(
          "Received unknown data type for locationUpdate: ${dataRaw.runtimeType}",
          name: "LiveTrackingCubit",
        );
        return;
      }

      if (data['rideId'] == rideId || data['occurrenceId'] == rideId) {
        final lat = double.tryParse(data['lat']?.toString() ?? '0') ?? 0.0;
        final lng = double.tryParse(data['lng']?.toString() ?? '0') ?? 0.0;
        final heading = double.tryParse(data['heading']?.toString() ?? '0') ?? 0.0;

        if (lat != 0.0 && lng != 0.0) {
          if (state is LiveTrackingActive) {
            final currentState = state as LiveTrackingActive;
            emit(currentState.copyWith(
              busLocation: LatLng(lat, lng),
              rotation: heading,
            ));
          }
        }
      }
    } catch (e) {
      log("Error parsing location update: $e", name: "LiveTrackingCubit");
    }
  }

  void _startPolling() {
    if (_pollingTimer != null && _pollingTimer!.isActive) {
      log("Polling already active, skipping start", name: "LiveTrackingCubit");
      return;
    }

    log("Starting polling mode with ${_pollingInterval.inSeconds}s interval", name: "LiveTrackingCubit");
    
    // Update state to show polling mode
    if (state is LiveTrackingActive) {
      final currentState = state as LiveTrackingActive;
      emit(currentState.copyWith(isConnected: false, isPolling: true));
    }

    int pollCount = 0;
    _pollingTimer = Timer.periodic(_pollingInterval, (timer) async {
      if (_isPaused) return;
      
      pollCount++;
      try {
        final startTime = DateTime.now();
        final response = await ridesService.getRideTrackingByOccurrence(rideId);
        final fetchDuration = DateTime.now().difference(startTime);
        
        if (response.data != null) {
          final trackingData = response.data!;
          final currentLocation = trackingData.bus.currentLocation;
          
          if (currentLocation is Map) {
            final lat = double.tryParse(currentLocation['lat']?.toString() ?? '0') ?? 0.0;
            final lng = double.tryParse(currentLocation['lng']?.toString() ?? '0') ?? 0.0;
            
            if (lat != 0.0 && lng != 0.0 && state is LiveTrackingActive) {
              final currentState = state as LiveTrackingActive;
              emit(currentState.copyWith(
                busLocation: LatLng(lat, lng),
                trackingData: trackingData,
              ));
              log("Polling update #$pollCount: location updated in ${fetchDuration.inMilliseconds}ms", 
                name: "LiveTrackingCubit");
            }
          }
        }
      } catch (e, stackTrace) {
        log("Polling error on attempt #$pollCount", 
          name: "LiveTrackingCubit", 
          error: e, 
          stackTrace: stackTrace,
          level: 1000);
      }
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    log("Polling stopped", name: "LiveTrackingCubit");
  }

  /// Pause tracking when app goes to background
  void pauseTracking() {
    log("Pausing tracking", name: "LiveTrackingCubit");
    _isPaused = true;
    _stopPolling();
    // Keep WebSocket connected but ignore updates
  }

  /// Resume tracking when app comes to foreground
  void resumeTracking() {
    log("Resuming tracking", name: "LiveTrackingCubit");
    _isPaused = false;
    
    if (state is LiveTrackingActive) {
      if (!_isWebSocketConnected) {
        _startPolling();
      }
    }
  }

  @override
  Future<void> close() {
    _stopPolling();
    _socketService.leaveRide(rideId);
    return super.close();
  }
}
