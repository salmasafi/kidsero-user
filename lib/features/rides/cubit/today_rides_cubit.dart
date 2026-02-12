import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/rides_repository.dart';
import '../models/ride_models.dart';

// ============================================================
// STATES
// ============================================================

abstract class TodayRidesState extends Equatable {
  const TodayRidesState();

  @override
  List<Object?> get props => [];
}

class TodayRidesInitial extends TodayRidesState {}

class TodayRidesLoading extends TodayRidesState {}

class TodayRidesLoaded extends TodayRidesState {
  final String date;
  final List<TodayRide> rides;

  const TodayRidesLoaded({required this.date, required this.rides});

  @override
  List<Object?> get props => [date, rides];

  /// Get rides for a specific child
  List<TodayRide> getRidesForChild(String childId) {
    return rides.where((ride) => ride.childId == childId).toList();
  }

  /// Get morning rides
  List<TodayRide> get morningRides =>
      rides.where((ride) => ride.period.toLowerCase() == 'morning').toList();

  /// Get afternoon rides
  List<TodayRide> get afternoonRides =>
      rides.where((ride) => ride.period.toLowerCase() == 'afternoon').toList();

  /// Check if there are any rides
  bool get hasRides => rides.isNotEmpty;
}

class TodayRidesEmpty extends TodayRidesState {}

class TodayRidesError extends TodayRidesState {
  final String message;

  const TodayRidesError(this.message);

  @override
  List<Object?> get props => [message];
}

// ============================================================
// CUBIT
// ============================================================

class TodayRidesCubit extends Cubit<TodayRidesState> {
  final RidesRepository _repository;
  Timer? _refreshTimer;

  TodayRidesCubit({required RidesRepository repository})
    : _repository = repository,
      super(TodayRidesInitial());

  /// Load today's rides for all children
  Future<void> loadTodayRides() async {
    emit(TodayRidesLoading());
    try {
      final response = await _repository.getTodayRides();

      if (response.data.isEmpty) {
        emit(TodayRidesEmpty());
      } else {
        emit(TodayRidesLoaded(date: response.date, rides: response.data));
      }
    } catch (e) {
      emit(TodayRidesError(e.toString()));
    }
  }

  /// Refresh today's rides
  Future<void> refresh() async {
    await loadTodayRides();
  }

  /// Start automatic refresh every 5 minutes
  /// Call this method when the screen becomes active (e.g., in initState or onResume)
  /// Example usage:
  /// ```dart
  /// @override
  /// void initState() {
  ///   super.initState();
  ///   context.read<TodayRidesCubit>().startAutoRefresh();
  /// }
  /// ```
  void startAutoRefresh() {
    // Cancel any existing timer
    _refreshTimer?.cancel();
    
    // Create a new timer that fires every 5 minutes
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => loadTodayRides(),
    );
  }

  /// Stop automatic refresh
  /// Call this method when the screen becomes inactive (e.g., in dispose or onPause)
  /// Example usage:
  /// ```dart
  /// @override
  /// void dispose() {
  ///   context.read<TodayRidesCubit>().stopAutoRefresh();
  ///   super.dispose();
  /// }
  /// ```
  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  @override
  Future<void> close() {
    // Clean up timer when cubit is closed
    _refreshTimer?.cancel();
    return super.close();
  }
}
