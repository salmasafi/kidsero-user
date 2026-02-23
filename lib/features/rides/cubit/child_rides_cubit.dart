import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:developer' as dev;
import '../../../core/network/error_handler.dart';
import '../data/rides_repository.dart';
import '../models/api_models.dart';

// ============================================================
// STATES
// ============================================================

abstract class ChildRidesState extends Equatable {
  const ChildRidesState();

  @override
  List<Object?> get props => [];
}

class ChildRidesInitial extends ChildRidesState {}

class ChildRidesLoading extends ChildRidesState {}

class ChildRidesLoaded extends ChildRidesState {
  final String childId;
  final List<TodayRideOccurrence> todayRides;
  final List<UpcomingRide> upcomingRides;
  final List<TodayRideOccurrence> historyRides;
  final RideSummaryData? summary;

  const ChildRidesLoaded({
    required this.childId,
    required this.todayRides,
    this.upcomingRides = const [],
    this.historyRides = const [],
    this.summary,
  });

  @override
  List<Object?> get props => [childId, todayRides, upcomingRides, historyRides, summary];

  /// Check if child has an active ride
  bool get hasActiveRide {
    return todayRides.any((ride) => ride.isActive);
  }
}

class ChildRidesEmpty extends ChildRidesState {}

class ChildRidesError extends ChildRidesState {
  final String message;

  const ChildRidesError(this.message);

  @override
  List<Object?> get props => [message];
}

// ============================================================
// CUBIT
// ============================================================

class ChildRidesCubit extends Cubit<ChildRidesState> {
  final RidesRepository _repository;
  final String _childId;

  ChildRidesCubit({
    required RidesRepository repository,
    required String childId,
  })  : _repository = repository,
        _childId = childId,
        super(ChildRidesInitial());

  /// Load child's rides (today's rides, upcoming, and history)
  Future<void> loadRides() async {
    emit(ChildRidesLoading());
    try {
      dev.log('Loading rides for child: $_childId', name: 'ChildRidesCubit');
      
      // Load today's rides
      final todayRidesData = await _repository.getChildTodayRides(_childId);
      final allTodayRides = todayRidesData.allRides;

      dev.log('Loaded ${allTodayRides.length} today rides for child $_childId', 
              name: 'ChildRidesCubit');

      // Load upcoming rides for this child
      List<UpcomingRide> childUpcomingRides = [];
      try {
        final upcomingData = await _repository.getUpcomingRides();
        // Filter upcoming rides for this specific child
        for (final dayRides in upcomingData.upcomingRides) {
          final childRides = dayRides.rides.where((ride) => ride.child.id == _childId).toList();
          childUpcomingRides.addAll(childRides);
        }
        dev.log('Loaded ${childUpcomingRides.length} upcoming rides for child $_childId', 
                name: 'ChildRidesCubit');
      } catch (e) {
        dev.log('Error loading upcoming rides: $e', name: 'ChildRidesCubit');
        // Continue without upcoming rides
      }

      // For history, we'll use completed rides from today as a placeholder
      // TODO: Implement proper history API endpoint when available
      final historyRides = allTodayRides.where((ride) => ride.isCompleted).toList();

      if (allTodayRides.isEmpty && childUpcomingRides.isEmpty && historyRides.isEmpty) {
        emit(ChildRidesEmpty());
      } else {
        emit(
          ChildRidesLoaded(
            childId: _childId,
            todayRides: allTodayRides,
            upcomingRides: childUpcomingRides,
            historyRides: historyRides,
            summary: null,
          ),
        );
      }
    } catch (e, stackTrace) {
      dev.log('Error loading child rides', 
              name: 'ChildRidesCubit', 
              error: e, 
              stackTrace: stackTrace);
      final errorMessage = ErrorHandler.handle(e);
      emit(ChildRidesError(errorMessage));
    }
  }

  /// Refresh child's rides with force refresh
  Future<void> refresh() async {
    try {
      dev.log('Refreshing rides for child: $_childId', name: 'ChildRidesCubit');
      
      // Load today's rides
      final todayRidesData = await _repository.getChildTodayRides(
        _childId,
        forceRefresh: true,
      );
      final allTodayRides = todayRidesData.allRides;

      dev.log('Refreshed ${allTodayRides.length} today rides for child $_childId', 
              name: 'ChildRidesCubit');

      // Load upcoming rides for this child
      List<UpcomingRide> childUpcomingRides = [];
      try {
        final upcomingData = await _repository.getUpcomingRides(forceRefresh: true);
        // Filter upcoming rides for this specific child
        for (final dayRides in upcomingData.upcomingRides) {
          final childRides = dayRides.rides.where((ride) => ride.child.id == _childId).toList();
          childUpcomingRides.addAll(childRides);
        }
        dev.log('Refreshed ${childUpcomingRides.length} upcoming rides for child $_childId', 
                name: 'ChildRidesCubit');
      } catch (e) {
        dev.log('Error refreshing upcoming rides: $e', name: 'ChildRidesCubit');
        // Continue without upcoming rides
      }

      // For history, we'll use completed rides from today as a placeholder
      final historyRides = allTodayRides.where((ride) => ride.isCompleted).toList();

      if (allTodayRides.isEmpty && childUpcomingRides.isEmpty && historyRides.isEmpty) {
        emit(ChildRidesEmpty());
      } else {
        // Preserve summary if it exists
        final currentSummary = state is ChildRidesLoaded 
            ? (state as ChildRidesLoaded).summary 
            : null;
        
        emit(
          ChildRidesLoaded(
            childId: _childId,
            todayRides: allTodayRides,
            upcomingRides: childUpcomingRides,
            historyRides: historyRides,
            summary: currentSummary,
          ),
        );
      }
    } catch (e, stackTrace) {
      dev.log('Error refreshing child rides', 
              name: 'ChildRidesCubit', 
              error: e, 
              stackTrace: stackTrace);
      final errorMessage = ErrorHandler.handle(e);
      emit(ChildRidesError(errorMessage));
    }
  }

  /// Load ride summary for the child
  Future<void> loadSummary() async {
    try {
      dev.log('Loading summary for child: $_childId', name: 'ChildRidesCubit');
      
      final summaryData = await _repository.getChildRideSummary(_childId);
      
      dev.log('Loaded summary for child $_childId', name: 'ChildRidesCubit');

      // Update state with summary if currently loaded
      if (state is ChildRidesLoaded) {
        final currentState = state as ChildRidesLoaded;
        emit(
          ChildRidesLoaded(
            childId: currentState.childId,
            todayRides: currentState.todayRides,
            upcomingRides: currentState.upcomingRides,
            historyRides: currentState.historyRides,
            summary: summaryData,
          ),
        );
      }
    } catch (e, stackTrace) {
      dev.log('Error loading summary', 
              name: 'ChildRidesCubit', 
              error: e, 
              stackTrace: stackTrace);
      // Don't emit error state for summary failure - keep current state
    }
  }
}
