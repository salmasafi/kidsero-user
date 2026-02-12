import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/rides_repository.dart';
import '../models/ride_models.dart';

// ============================================================
// STATES
// ============================================================

abstract class RideTrackingState extends Equatable {
  const RideTrackingState();

  @override
  List<Object?> get props => [];
}

class RideTrackingInitial extends RideTrackingState {}

class RideTrackingLoading extends RideTrackingState {}

class RideTrackingLoaded extends RideTrackingState {
  final RideTracking tracking;

  const RideTrackingLoaded(this.tracking);

  @override
  List<Object?> get props => [tracking];

  /// Get ride ID
  String get rideId => tracking.rideId;

  /// Get child ID
  String get childId => tracking.childId;

  /// Get ride status
  String get status => tracking.status;

  /// Check if ride is in progress
  bool get isInProgress => status.toLowerCase() == 'in_progress';

  /// Get bus info
  BusInfo? get bus => tracking.bus;

  /// Get driver info
  DriverInfo? get driver => tracking.driver;

  /// Get current location
  CurrentLocation? get currentLocation => tracking.currentLocation;

  /// Check if location is available
  bool get hasLocation =>
      currentLocation != null &&
      currentLocation!.lat != 0 &&
      currentLocation!.lng != 0;

  /// Get route info
  RouteInfo? get route => tracking.route;

  /// Get pickup location
  String? get pickupLocation => route?.pickupLocation;

  /// Get dropoff location
  String? get dropoffLocation => route?.dropoffLocation;

  /// Get next stop ETA
  String? get nextStopEta => route?.nextStopEta;
}

class RideTrackingError extends RideTrackingState {
  final String message;

  const RideTrackingError(this.message);

  @override
  List<Object?> get props => [message];
}

// ============================================================
// CUBIT
// ============================================================

class RideTrackingCubit extends Cubit<RideTrackingState> {
  final RidesRepository _repository;
  final String rideId;

  RideTrackingCubit({required RidesRepository repository, required this.rideId})
    : _repository = repository,
      super(RideTrackingInitial());

  /// Load tracking data for the ride
  Future<void> loadTracking() async {
    emit(RideTrackingLoading());
    try {
      final tracking = await _repository.getRideTracking(rideId);
      emit(RideTrackingLoaded(tracking));
    } catch (e) {
      emit(RideTrackingError(e.toString()));
    }
  }

  /// Refresh tracking data
  Future<void> refresh() async {
    // Don't show loading state on refresh to avoid UI flicker
    try {
      final tracking = await _repository.getRideTracking(rideId);
      emit(RideTrackingLoaded(tracking));
    } catch (e) {
      // Keep current state if refresh fails
      if (state is! RideTrackingLoaded) {
        emit(RideTrackingError(e.toString()));
      }
    }
  }

  /// Update location from WebSocket data
  void updateLocation(double lat, double lng) {
    if (state is RideTrackingLoaded) {
      final currentState = state as RideTrackingLoaded;
      final updatedTracking = RideTracking(
        rideId: currentState.tracking.rideId,
        childId: currentState.tracking.childId,
        status: currentState.tracking.status,
        bus: currentState.tracking.bus,
        driver: currentState.tracking.driver,
        currentLocation: CurrentLocation(
          lat: lat,
          lng: lng,
          recordedAt: DateTime.now().toIso8601String(),
        ),
        route: currentState.tracking.route,
      );
      emit(RideTrackingLoaded(updatedTracking));
    }
  }
}
