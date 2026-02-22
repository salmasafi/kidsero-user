import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/rides_repository.dart';
import '../models/ride_models.dart';

// ============================================================
// STATES
// ============================================================

abstract class ActiveRidesState extends Equatable {
  const ActiveRidesState();

  @override
  List<Object?> get props => [];
}

class ActiveRidesInitial extends ActiveRidesState {}

class ActiveRidesLoading extends ActiveRidesState {}

class ActiveRidesLoaded extends ActiveRidesState {
  final List<ActiveRide> rides;

  const ActiveRidesLoaded(this.rides);

  @override
  List<Object?> get props => [rides];

  /// Get the first active ride (useful for single tracking)
  ActiveRide? get firstRide => rides.isNotEmpty ? rides.first : null;

  /// Check if there are any active rides
  bool get hasActiveRides => rides.isNotEmpty;

  /// Get count of active rides
  int get count => rides.length;

  /// Check if a specific child has an active ride
  bool hasActiveRideForChild(String childId) {
    return rides.any((ride) => ride.childId == childId);
  }

  /// Get active ride for a specific child
  ActiveRide? getActiveRideForChild(String childId) {
    try {
      return rides.firstWhere((ride) => ride.childId == childId);
    } catch (_) {
      return null;
    }
  }
}

class ActiveRidesEmpty extends ActiveRidesState {}

class ActiveRidesError extends ActiveRidesState {
  final String message;

  const ActiveRidesError(this.message);

  @override
  List<Object?> get props => [message];
}

// ============================================================
// CUBIT
// ============================================================

class ActiveRidesCubit extends Cubit<ActiveRidesState> {
  final RidesRepository _repository;
  Timer? _refreshTimer;
  static const _refreshInterval = Duration(seconds: 30);

  ActiveRidesCubit({required RidesRepository repository})
    : _repository = repository,
      super(ActiveRidesInitial());

  /// Load all active rides
  Future<void> loadActiveRides() async {
    emit(ActiveRidesLoading());
    try {
      final rides = await _repository.getActiveRides();
      
      // Debug logging
      print('Active rides loaded: ${rides.length} rides');
      for (final ride in rides) {
        print('Ride: ${ride.rideId}, Child: ${ride.childName}, Status: ${ride.status}');
      }

      if (rides.isEmpty) {
        emit(ActiveRidesEmpty());
      } else {
        emit(ActiveRidesLoaded(rides));
      }
    } catch (e) {
      print('Error loading active rides: $e');
      emit(ActiveRidesError(e.toString()));
    }
  }

  /// Refresh active rides
  Future<void> refresh() async {
    await loadActiveRides();
  }

  /// Start automatic refresh every 30 seconds
  /// NOTE: Auto-refresh is disabled by default to reduce API calls
  /// Use manual refresh instead with the refresh() method
  void startAutoRefresh() {
    // Cancel any existing timer
    stopAutoRefresh();
    
    // Start new timer
    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      // Only refresh if not already loading
      if (state is! ActiveRidesLoading) {
        loadActiveRides();
      }
    });
    
    print('Auto-refresh started for active rides (every 30 seconds)');
  }

  /// Stop automatic refresh
  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    print('Auto-refresh stopped for active rides');
  }

  @override
  Future<void> close() {
    stopAutoRefresh();
    return super.close();
  }
}
