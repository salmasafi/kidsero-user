import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/rides_repository.dart';
import '../models/ride_models.dart';
import 'package:flutter/foundation.dart';

// ============================================================
// STATES
// ============================================================

abstract class UpcomingRidesState extends Equatable {
  const UpcomingRidesState();

  @override
  List<Object?> get props => [];
}

class UpcomingRidesInitial extends UpcomingRidesState {}

class UpcomingRidesLoading extends UpcomingRidesState {}

class UpcomingRidesLoaded extends UpcomingRidesState {
  final UpcomingRidesData data;

  const UpcomingRidesLoaded(this.data);

  @override
  List<Object?> get props => [data];

  /// Get rides for a specific child
  List<UpcomingRideInfo> getRidesForChild(String childId) {
    return data.upcomingRides
        .expand((day) => day.rides)
        .where((ride) => ride.child.id == childId)
        .toList();
  }

  /// Get rides for a specific date
  List<UpcomingRideInfo> getRidesForDate(String date) {
    final dayData = data.upcomingRides.firstWhere(
      (day) => day.date == date,
      orElse: () => UpcomingDayRides(date: date, dayName: '', rides: []),
    );
    return dayData.rides;
  }

  /// Get all rides as flat list
  List<UpcomingRideInfo> get allRides {
    return data.upcomingRides
        .expand((day) => day.rides)
        .toList();
  }

  /// Get count of upcoming rides
  int get count => data.totalRides;

  /// Check if there are any rides
  bool get hasRides => data.totalRides > 0;

  /// Get total days
  int get totalDays => data.totalDays;

  /// Get rides for a specific day
  UpcomingDayRides? getDayRides(String date) {
    try {
      return data.upcomingRides.firstWhere((day) => day.date == date);
    } catch (_) {
      return null;
    }
  }
}

class UpcomingRidesEmpty extends UpcomingRidesState {}

class UpcomingRidesError extends UpcomingRidesState {
  final String message;

  const UpcomingRidesError(this.message);

  @override
  List<Object?> get props => [message];
}

// ============================================================
// CUBIT
// ============================================================

class UpcomingRidesCubit extends Cubit<UpcomingRidesState> {
  final RidesRepository _repository;
  UpcomingRidesData? _allData;

  UpcomingRidesCubit({required RidesRepository repository})
    : _repository = repository,
      super(UpcomingRidesInitial());

  /// Load all upcoming rides
  Future<void> loadUpcomingRides() async {
    debugPrint('UpcomingRidesCubit: Loading upcoming rides...');
    emit(UpcomingRidesLoading());
    try {
      final data = await _repository.getUpcomingRides();
      _allData = data;
      debugPrint('UpcomingRidesCubit: Loaded ${data.totalRides} rides, ${data.totalDays} days');

      if (data.totalRides == 0) {
        debugPrint('UpcomingRidesCubit: No upcoming rides found');
        emit(UpcomingRidesEmpty());
      } else {
        debugPrint('UpcomingRidesCubit: Emitting UpcomingRidesLoaded state');
        emit(UpcomingRidesLoaded(data));
      }
    } catch (e) {
      debugPrint('UpcomingRidesCubit: Error loading upcoming rides: $e');
      emit(UpcomingRidesError(e.toString()));
    }
  }

  /// Refresh upcoming rides
  Future<void> refresh() async {
    await loadUpcomingRides();
  }
}
