import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:developer' as dev;
import '../../../core/network/error_handler.dart';
import '../data/rides_repository.dart';
import '../models/api_models.dart';

// ============================================================
// STATES
// ============================================================

abstract class AllChildrenRidesState extends Equatable {
  const AllChildrenRidesState();

  @override
  List<Object?> get props => [];
}

class AllChildrenRidesInitial extends AllChildrenRidesState {}

class AllChildrenRidesLoading extends AllChildrenRidesState {}

class AllChildrenRidesLoaded extends AllChildrenRidesState {
  final Map<String, ChildTodayRidesData> childrenRides;
  final Map<String, ChildTodayRidesData> childrenHistoryRides;
  final List<ChildWithRides> children;
  final UpcomingRidesData? upcomingRidesData;

  const AllChildrenRidesLoaded({
    required this.childrenRides,
    required this.childrenHistoryRides,
    required this.children,
    this.upcomingRidesData,
  });

  @override
  List<Object?> get props => [childrenRides, childrenHistoryRides, children, upcomingRidesData];

  /// Get rides for a specific child
  List<TodayRideOccurrence> getRidesForChild(String childId) {
    return childrenRides[childId]?.allRides ?? [];
  }

  /// Get history rides for a specific child
  List<TodayRideOccurrence> getHistoryRidesForChild(String childId) {
    return childrenHistoryRides[childId]?.allRides ?? [];
  }

  /// Get active rides for a specific child
  List<TodayRideOccurrence> getActiveRidesForChild(String childId) {
    return getRidesForChild(childId).where((ride) => ride.isActive).toList();
  }

  /// Get scheduled rides for a specific child
  List<TodayRideOccurrence> getScheduledRidesForChild(String childId) {
    return getRidesForChild(childId).where((ride) => ride.isScheduled).toList();
  }

  /// Get all active rides across all children
  List<TodayRideOccurrence> get allActiveRides {
    final activeRides = <TodayRideOccurrence>[];
    for (final rides in childrenRides.values) {
      activeRides.addAll(rides.allRides.where((ride) => ride.isActive));
    }
    return activeRides;
  }

  /// Get all history rides across all children
  List<TodayRideOccurrence> get allHistoryRides {
    final historyRides = <TodayRideOccurrence>[];
    for (final rides in childrenHistoryRides.values) {
      historyRides.addAll(rides.allRides);
    }
    return historyRides;
  }

  /// Get upcoming rides for a specific child
  List<UpcomingRide> getUpcomingRidesForChild(String childId) {
    if (upcomingRidesData == null) return [];
    
    final upcomingRides = <UpcomingRide>[];
    for (final dayRides in upcomingRidesData!.upcomingRides) {
      final childRides = dayRides.rides.where((ride) => ride.child.id == childId).toList();
      upcomingRides.addAll(childRides);
    }
    return upcomingRides;
  }

  /// Get all upcoming rides across all children
  List<UpcomingRide> get allUpcomingRides {
    if (upcomingRidesData == null) return [];
    
    final upcomingRides = <UpcomingRide>[];
    for (final dayRides in upcomingRidesData!.upcomingRides) {
      upcomingRides.addAll(dayRides.rides);
    }
    return upcomingRides;
  }

  /// Get total count of active rides
  int get activeRidesCount => allActiveRides.length;

  /// Check if a child has any rides today
  bool hasRidesForChild(String childId) {
    return getRidesForChild(childId).isNotEmpty;
  }
}

class AllChildrenRidesEmpty extends AllChildrenRidesState {}

class AllChildrenRidesError extends AllChildrenRidesState {
  final String message;

  const AllChildrenRidesError(this.message);

  @override
  List<Object?> get props => [message];
}

// ============================================================
// CUBIT
// ============================================================

class AllChildrenRidesCubit extends Cubit<AllChildrenRidesState> {
  final RidesRepository _repository;

  AllChildrenRidesCubit({
    required RidesRepository repository,
  })  : _repository = repository,
        super(AllChildrenRidesInitial());

  /// Load today's rides for all children
  Future<void> loadAllChildrenRides() async {
    emit(AllChildrenRidesLoading());
    try {
      dev.log('Loading rides for all children', name: 'AllChildrenRidesCubit');

      // First, get all children
      final childrenData = await _repository.getChildrenWithRides();
      final children = childrenData.children;

      if (children.isEmpty) {
        dev.log('No children found', name: 'AllChildrenRidesCubit');
        emit(AllChildrenRidesEmpty());
        return;
      }

      dev.log('Found ${children.length} children', name: 'AllChildrenRidesCubit');

      // Fetch today's rides for all children in parallel
      final todayRidesFutures = children.map((child) {
        return _repository.getChildTodayRides(child.id);
      }).toList();

      // Fetch history rides for all children in parallel
      final historyRidesFutures = children.map((child) {
        return _repository.getChildHistoryRides(child.id);
      }).toList();

      final todayRidesResults = await Future.wait(todayRidesFutures);
      final historyRidesResults = await Future.wait(historyRidesFutures);

      // Build maps of childId -> rides
      final childrenRidesMap = <String, ChildTodayRidesData>{};
      final childrenHistoryRidesMap = <String, ChildTodayRidesData>{};
      
      for (int i = 0; i < children.length; i++) {
        childrenRidesMap[children[i].id] = todayRidesResults[i];
        childrenHistoryRidesMap[children[i].id] = historyRidesResults[i];
      }

      // Count total rides
      int totalRides = 0;
      int totalHistoryRides = 0;
      for (final rides in childrenRidesMap.values) {
        totalRides += rides.total;
      }
      for (final rides in childrenHistoryRidesMap.values) {
        totalHistoryRides += rides.total;
      }

      dev.log('Loaded rides for ${children.length} children, total today rides: $totalRides, total history rides: $totalHistoryRides',
          name: 'AllChildrenRidesCubit');
      
      // Print all rides for each child
      for (final child in children) {
        final childRides = childrenRidesMap[child.id]?.allRides ?? [];
        final childHistoryRides = childrenHistoryRidesMap[child.id]?.allRides ?? [];
        dev.log('Child: ${child.name} (${child.id}) has ${childRides.length} today rides, ${childHistoryRides.length} history rides', 
                name: 'AllChildrenRidesCubit');
        for (int i = 0; i < childRides.length; i++) {
          final ride = childRides[i];
          dev.log('  Today Ride $i: ID=${ride.occurrenceId}, Name=${ride.ride.name}, Status=${ride.status}, Type=${ride.ride.type}, Time=${ride.pickupTime}, IsCompleted=${ride.isCompleted}, IsActive=${ride.isActive}, IsScheduled=${ride.isScheduled}', 
                  name: 'AllChildrenRidesCubit');
        }
        for (int i = 0; i < childHistoryRides.length; i++) {
          final ride = childHistoryRides[i];
          dev.log('  History Ride $i: ID=${ride.occurrenceId}, Name=${ride.ride.name}, Status=${ride.status}, Type=${ride.ride.type}, Time=${ride.pickupTime}, IsCompleted=${ride.isCompleted}', 
                  name: 'AllChildrenRidesCubit');
        }
      }

      // Load upcoming rides
      UpcomingRidesData? upcomingData;
      try {
        upcomingData = await _repository.getUpcomingRides();
        dev.log('Loaded upcoming rides: ${upcomingData.upcomingRides.length} days, ${upcomingData.totalRides} total rides',
            name: 'AllChildrenRidesCubit');
        
        // Print upcoming rides details
        for (final dayRides in upcomingData.upcomingRides) {
          dev.log('Upcoming Day ${dayRides.date} (${dayRides.dayName}): ${dayRides.rides.length} rides',
                  name: 'AllChildrenRidesCubit');
        }
      } catch (e) {
        dev.log('Error loading upcoming rides: $e', name: 'AllChildrenRidesCubit');
        // Continue without upcoming rides
      }

      if (totalRides == 0 && totalHistoryRides == 0 && (upcomingData == null || upcomingData.totalRides == 0)) {
        emit(AllChildrenRidesEmpty());
      } else {
        emit(
          AllChildrenRidesLoaded(
            childrenRides: childrenRidesMap,
            childrenHistoryRides: childrenHistoryRidesMap,
            children: children,
            upcomingRidesData: upcomingData,
          ),
        );
      }
    } catch (e, stackTrace) {
      dev.log('Error loading all children rides',
          name: 'AllChildrenRidesCubit',
          error: e,
          stackTrace: stackTrace);
      final errorMessage = ErrorHandler.handle(e);
      emit(AllChildrenRidesError(errorMessage));
    }
  }

  /// Refresh all children rides with force refresh
  Future<void> refresh() async {
    try {
      dev.log('Refreshing rides for all children', name: 'AllChildrenRidesCubit');

      // Get all children
      final childrenData = await _repository.getChildrenWithRides(forceRefresh: true);
      final children = childrenData.children;

      if (children.isEmpty) {
        dev.log('No children found', name: 'AllChildrenRidesCubit');
        emit(AllChildrenRidesEmpty());
        return;
      }

      // Fetch today's rides for all children in parallel with force refresh
      final todayRidesFutures = children.map((child) {
        return _repository.getChildTodayRides(child.id, forceRefresh: true);
      }).toList();

      // Fetch history rides for all children in parallel with force refresh
      final historyRidesFutures = children.map((child) {
        return _repository.getChildHistoryRides(child.id, forceRefresh: true);
      }).toList();

      final todayRidesResults = await Future.wait(todayRidesFutures);
      final historyRidesResults = await Future.wait(historyRidesFutures);

      // Build maps of childId -> rides
      final childrenRidesMap = <String, ChildTodayRidesData>{};
      final childrenHistoryRidesMap = <String, ChildTodayRidesData>{};
      
      for (int i = 0; i < children.length; i++) {
        childrenRidesMap[children[i].id] = todayRidesResults[i];
        childrenHistoryRidesMap[children[i].id] = historyRidesResults[i];
      }

      // Count total rides
      int totalRides = 0;
      int totalHistoryRides = 0;
      for (final rides in childrenRidesMap.values) {
        totalRides += rides.total;
      }
      for (final rides in childrenHistoryRidesMap.values) {
        totalHistoryRides += rides.total;
      }

      dev.log('Refreshed rides for ${children.length} children, total today rides: $totalRides, total history rides: $totalHistoryRides',
          name: 'AllChildrenRidesCubit');
      
      // Print all rides for each child
      for (final child in children) {
        final childRides = childrenRidesMap[child.id]?.allRides ?? [];
        final childHistoryRides = childrenHistoryRidesMap[child.id]?.allRides ?? [];
        dev.log('Child: ${child.name} (${child.id}) has ${childRides.length} today rides, ${childHistoryRides.length} history rides', 
                name: 'AllChildrenRidesCubit');
        for (int i = 0; i < childRides.length; i++) {
          final ride = childRides[i];
          dev.log('  Today Ride $i: ID=${ride.occurrenceId}, Name=${ride.ride.name}, Status=${ride.status}, Type=${ride.ride.type}, Time=${ride.pickupTime}, IsCompleted=${ride.isCompleted}, IsActive=${ride.isActive}, IsScheduled=${ride.isScheduled}', 
                  name: 'AllChildrenRidesCubit');
        }
        for (int i = 0; i < childHistoryRides.length; i++) {
          final ride = childHistoryRides[i];
          dev.log('  History Ride $i: ID=${ride.occurrenceId}, Name=${ride.ride.name}, Status=${ride.status}, Type=${ride.ride.type}, Time=${ride.pickupTime}, IsCompleted=${ride.isCompleted}', 
                  name: 'AllChildrenRidesCubit');
        }
      }

      // Load upcoming rides
      UpcomingRidesData? upcomingData;
      try {
        upcomingData = await _repository.getUpcomingRides(forceRefresh: true);
        dev.log('Refreshed upcoming rides: ${upcomingData.upcomingRides.length} days, ${upcomingData.totalRides} total rides',
            name: 'AllChildrenRidesCubit');
        
        // Print upcoming rides details
        for (final dayRides in upcomingData.upcomingRides) {
          dev.log('Upcoming Day ${dayRides.date} (${dayRides.dayName}): ${dayRides.rides.length} rides',
                  name: 'AllChildrenRidesCubit');
        }
      } catch (e) {
        dev.log('Error refreshing upcoming rides: $e', name: 'AllChildrenRidesCubit');
        // Continue without upcoming rides
      }

      if (totalRides == 0 && totalHistoryRides == 0 && (upcomingData == null || upcomingData.totalRides == 0)) {
        emit(AllChildrenRidesEmpty());
      } else {
        emit(
          AllChildrenRidesLoaded(
            childrenRides: childrenRidesMap,
            childrenHistoryRides: childrenHistoryRidesMap,
            children: children,
            upcomingRidesData: upcomingData,
          ),
        );
      }
    } catch (e, stackTrace) {
      dev.log('Error refreshing all children rides',
          name: 'AllChildrenRidesCubit',
          error: e,
          stackTrace: stackTrace);
      final errorMessage = ErrorHandler.handle(e);
      emit(AllChildrenRidesError(errorMessage));
    }
  }
}
