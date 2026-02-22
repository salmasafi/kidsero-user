import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/rides_repository.dart';
import '../models/ride_models.dart';

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
  final ChildRideDetails childDetails;
  final RideSummaryData? summary;
  final ActiveRide? activeRide;
  final List<TodayRide> todayRides;

  const ChildRidesLoaded({
    required this.childDetails,
    this.summary,
    this.activeRide,
    this.todayRides = const [],
  });

  @override
  List<Object?> get props => [childDetails, summary, activeRide, todayRides];

  /// Get child name
  String get childName => childDetails.name;

  /// Get child grade
  String? get grade => childDetails.grade;

  /// Get school name
  String? get schoolName => childDetails.schoolName;

  /// Get upcoming rides
  List<RideHistoryItem> get upcomingRides => childDetails.rides.upcoming;

  /// Get ride history
  List<RideHistoryItem> get historyRides => childDetails.rides.history;

  /// Get today rides
  List<TodayRide> get todayRidesList => todayRides;

  /// Check if there are upcoming rides
  bool get hasUpcomingRides => upcomingRides.isNotEmpty;

  /// Check if there is history
  bool get hasHistory => historyRides.isNotEmpty;

  /// Check if there are today rides
  bool get hasTodayRides => todayRides.isNotEmpty;

  /// Check if there's an active ride
  bool get hasActiveRide => activeRide != null;

  /// Get total scheduled rides from summary
  int get totalScheduled => summary?.summary.total ?? 0;

  /// Get attended rides from summary
  int get attended => summary?.summary.byStatus.completed ?? 0;

  /// Get absent count from summary
  int get absent => summary?.summary.byStatus.absent ?? 0;

  /// Get late count from summary
  int get late => 0; // Not available in new structure

  /// Get attendance percentage
  double get attendancePercentage {
    if (totalScheduled == 0) return 0;
    return (attended / totalScheduled) * 100;
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
  final String childId;

  ChildRidesCubit({required RidesRepository repository, required this.childId})
    : _repository = repository,
      super(ChildRidesInitial());

  /// Load child rides and summary
  Future<void> loadRides() async {
    print('ChildRidesCubit: Loading rides for child $childId...');
    emit(ChildRidesLoading());
    try {
      // Fetch child details
      print('ChildRidesCubit: Fetching child details...');
      final childDetails = await _repository.getChildRides(childId, forceRefresh: true);
      print('ChildRidesCubit: Child details loaded - ${childDetails.rides.upcoming.length} upcoming, ${childDetails.rides.history.length} history');

      // Try to fetch summary, but don't fail if it's not available
      RideSummaryData? summary;
      try {
        print('ChildRidesCubit: Fetching child summary...');
        summary = await _repository.getChildRideSummary(childId);
        print('ChildRidesCubit: Summary loaded');
      } catch (_) {
        print('ChildRidesCubit: Summary failed, continuing without it');
        // Summary is optional, ignore errors
      }

      // Fetch today rides for this child
      List<TodayRide> todayRides = [];
      try {
        final todayResponse = await _repository.getTodayRides(forceRefresh: true);
        print('ChildRidesCubit: Response type: ${todayResponse.runtimeType}');
        print('ChildRidesCubit: Today rides response loaded: ${todayResponse.data.length} rides');
        // Filter today rides for this specific child
        final allTodayRides = todayResponse.data;
        todayRides = allTodayRides.where((ride) => ride.childId == childId).toList();
        print('ChildRidesCubit: Filtered ${todayRides.length} rides for child $childId');
      } catch (e) {
        print('ChildRidesCubit: Error loading today rides: $e');
        // Today rides failed, continue without them
        todayRides = [];
      }

      // Check for active rides for this child
      ActiveRide? activeRide;
      try {
        final activeRides = await _repository.getActiveRides();
        // Find active ride for this specific child
        activeRide = activeRides.firstWhere(
          (ride) => ride.childId == childId,
          orElse: () => throw Exception('No active ride'),
        );
      } catch (_) {
        // No active ride for this child, that's okay
        activeRide = null;
      }

      if (childDetails.rides.upcoming.isEmpty &&
          childDetails.rides.history.isEmpty &&
          todayRides.isEmpty &&
          activeRide == null) {
        print('ChildRidesCubit: No rides found, emitting empty state');
        emit(ChildRidesEmpty());
      } else {
        print('ChildRidesCubit: Emitting loaded state - ${childDetails.rides.upcoming.length} upcoming, ${childDetails.rides.history.length} history, ${todayRides.length} today');
        emit(ChildRidesLoaded(
          childDetails: childDetails,
          summary: summary,
          activeRide: activeRide,
          todayRides: todayRides,
        ));
      }
    } catch (e) {
      print('ChildRidesCubit: Error loading rides: $e');
      emit(ChildRidesError(e.toString()));
    }
  }

  /// Refresh rides
  Future<void> refresh() async {
    await loadRides();
  }
}
