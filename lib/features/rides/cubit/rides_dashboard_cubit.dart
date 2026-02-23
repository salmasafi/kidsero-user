import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:developer' as dev;
import '../../../core/network/error_handler.dart';
import '../data/rides_repository.dart';
import '../models/api_models.dart';

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
  final List<ChildWithRides> children;
  final int activeRidesCount;
  final List<dynamic> activeRides;

  const RidesDashboardLoaded({
    required this.children,
    required this.activeRidesCount,
    this.activeRides = const [],
  });

  @override
  List<Object?> get props => [children, activeRidesCount, activeRides];

  /// Get total number of children
  int get childrenCount => children.length;

  /// Check if there are any active rides
  bool get hasActiveRides => activeRidesCount > 0;

  /// Check if a specific child has an active ride
  bool hasActiveRideForChild(String childId) {
    final child = children.where((c) => c.id == childId).firstOrNull;
    if (child == null) return false;
    
    // Check if any of the child's rides are active (in_progress status)
    // Note: The API doesn't provide active ride status in children endpoint
    // This would need to be determined from today's rides or tracking data
    return false; // Placeholder - will be enhanced when integrating with today's rides
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

  RidesDashboardCubit({
    required RidesRepository repository,
  })  : _repository = repository,
        super(RidesDashboardInitial());

  /// Load all dashboard data (children with rides and active rides count)
  Future<void> loadDashboard() async {
    emit(RidesDashboardLoading());
    try {
      dev.log('Loading dashboard data', name: 'RidesDashboardCubit');
      
      // Fetch children with rides and active rides in parallel
      final results = await Future.wait([
        _repository.getChildrenWithRides(),
        _repository.getActiveRides(),
      ]);

      final childrenData = results[0] as ChildrenWithRidesData;
      final activeRidesData = results[1] as ActiveRidesData;

      dev.log('Loaded ${childrenData.children.length} children, ${activeRidesData.count} active rides', 
              name: 'RidesDashboardCubit');

      if (childrenData.children.isEmpty) {
        emit(RidesDashboardEmpty());
      } else {
        emit(
          RidesDashboardLoaded(
            children: childrenData.children,
            activeRidesCount: activeRidesData.count,
            activeRides: activeRidesData.activeRides,
          ),
        );
      }
    } catch (e, stackTrace) {
      dev.log('Error loading dashboard', 
              name: 'RidesDashboardCubit', 
              error: e, 
              stackTrace: stackTrace);
      final errorMessage = ErrorHandler.handle(e);
      emit(RidesDashboardError(errorMessage));
    }
  }

  /// Refresh just the active rides count
  Future<void> refreshActiveRides() async {
    if (state is RidesDashboardLoaded) {
      final currentState = state as RidesDashboardLoaded;
      try {
        dev.log('Refreshing active rides', name: 'RidesDashboardCubit');
        final activeRidesData = await _repository.getActiveRides(forceRefresh: true);
        
        emit(
          RidesDashboardLoaded(
            children: currentState.children,
            activeRidesCount: activeRidesData.count,
            activeRides: activeRidesData.activeRides,
          ),
        );
        
        dev.log('Refreshed active rides: ${activeRidesData.count}', 
                name: 'RidesDashboardCubit');
      } catch (e) {
        dev.log('Error refreshing active rides: $e', 
                name: 'RidesDashboardCubit', 
                error: e);
        // Keep current state if refresh fails
      }
    }
  }
}
