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
  final RideSummary? summary;
  final ActiveRide? activeRide;

  const ChildRidesLoaded({
    required this.childDetails,
    this.summary,
    this.activeRide,
  });

  @override
  List<Object?> get props => [childDetails, summary, activeRide];

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

  /// Check if there are upcoming rides
  bool get hasUpcomingRides => upcomingRides.isNotEmpty;

  /// Check if there is history
  bool get hasHistory => historyRides.isNotEmpty;

  /// Check if there's an active ride
  bool get hasActiveRide => activeRide != null;

  /// Get total scheduled rides from summary
  int get totalScheduled => summary?.stats.totalScheduled ?? 0;

  /// Get attended rides from summary
  int get attended => summary?.stats.attended ?? 0;

  /// Get absent count from summary
  int get absent => summary?.stats.absent ?? 0;

  /// Get late count from summary
  int get late => summary?.stats.late ?? 0;

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
    emit(ChildRidesLoading());
    try {
      // Fetch child details
      final childDetails = await _repository.getChildRides(childId);

      // Try to fetch summary, but don't fail if it's not available
      RideSummary? summary;
      try {
        summary = await _repository.getChildRideSummary(childId);
      } catch (_) {
        // Summary is optional, ignore errors
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
          activeRide == null) {
        emit(ChildRidesEmpty());
      } else {
        emit(ChildRidesLoaded(
          childDetails: childDetails,
          summary: summary,
          activeRide: activeRide,
        ));
      }
    } catch (e) {
      emit(ChildRidesError(e.toString()));
    }
  }

  /// Refresh rides
  Future<void> refresh() async {
    await loadRides();
  }
}
