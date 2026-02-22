import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/rides_repository.dart';
import '../models/ride_models.dart';
import '../../../core/network/api_service.dart';
import '../../../features/children/model/child_model.dart' as child_model;

// ============================================================
// STATES
// ============================================================

abstract class RidesDashboardState extends Equatable {
  const RidesDashboardState();

  @override
  List<Object?> get props => [];
}

class RidesDashboardInitial extends RidesDashboardState {}

class RidesDashboardLoading extends RidesDashboardState {}

class RidesDashboardLoaded extends RidesDashboardState {
  final List<child_model.Child> children;
  final List<ActiveRide> activeRides;
  final List<UpcomingRide> upcomingRides;

  const RidesDashboardLoaded({
    required this.children,
    required this.activeRides,
    required this.upcomingRides,
  });

  @override
  List<Object?> get props => [children, activeRides, upcomingRides];

  /// Get total number of children
  int get childrenCount => children.length;

  /// Get number of active rides
  int get activeRidesCount => activeRides.length;

  /// Check if there are any active rides
  bool get hasActiveRides => activeRides.isNotEmpty;

  /// Check if a specific child has an active ride
  bool hasActiveRideForChild(String childId) {
    return activeRides.any((ride) => ride.childId == childId);
  }

  /// Get active ride for a specific child
  ActiveRide? getActiveRideForChild(String childId) {
    try {
      return activeRides.firstWhere((ride) => ride.childId == childId);
    } catch (_) {
      return null;
    }
  }
}

class RidesDashboardEmpty extends RidesDashboardState {}

class RidesDashboardError extends RidesDashboardState {
  final String message;

  const RidesDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

// ============================================================
// CUBIT
// ============================================================

class RidesDashboardCubit extends Cubit<RidesDashboardState> {
  final RidesRepository _repository;
  final ApiService _apiService;

  RidesDashboardCubit({
    required RidesRepository repository,
    required ApiService apiService,
  })  : _repository = repository,
        _apiService = apiService,
        super(RidesDashboardInitial());

  /// Load all dashboard data (children, active rides, upcoming rides)
  Future<void> loadDashboard() async {
    emit(RidesDashboardLoading());
    try {
      // Fetch all data in parallel for better performance
      final results = await Future.wait([
        _apiService.getChildren(),  // Use children API directly
        _repository.getActiveRides(),
        _repository.getUpcomingRides(),
      ]);

      final children = results[0] as List<child_model.Child>;
      final activeRides = results[1] as List<ActiveRide>;
      final upcomingRidesData = results[2] as UpcomingRidesData;
      
      // Convert UpcomingRidesData to List<UpcomingRide> for dashboard
      final upcomingRides = <UpcomingRide>[];
      for (final dayRide in upcomingRidesData.upcomingRides) {
        for (final rideInfo in dayRide.rides) {
          upcomingRides.add(UpcomingRide(
            rideId: rideInfo.ride.id,
            childId: rideInfo.child.id,
            childName: rideInfo.child.name,
            date: dayRide.date, // Use date from UpcomingDayRides
            period: rideInfo.ride.type,
            pickupTime: rideInfo.pickupTime,
            pickupLocation: rideInfo.pickupPointName,
            dropoffLocation: null, // Not available in UpcomingRideInfo
            status: 'scheduled',
          ));
        }
      }

      if (children.isEmpty) {
        emit(RidesDashboardEmpty());
      } else {
        emit(
          RidesDashboardLoaded(
            children: children,
            activeRides: activeRides,
            upcomingRides: upcomingRides,
          ),
        );
      }
    } catch (e) {
      print('RidesDashboardCubit: Error loading dashboard: $e');
      emit(RidesDashboardError(e.toString()));
    }
  }

  /// Refresh just the active rides
  Future<void> refreshActiveRides() async {
    if (state is RidesDashboardLoaded) {
      final currentState = state as RidesDashboardLoaded;
      try {
        final activeRides = await _repository.getActiveRides();
        emit(
          RidesDashboardLoaded(
            children: currentState.children,
            activeRides: activeRides,
            upcomingRides: currentState.upcomingRides,
          ),
        );
      } catch (e) {
        // Keep current state if refresh fails
      }
    }
  }
}
