import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/rides_repository.dart';
import '../models/ride_models.dart';

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
  final List<UpcomingRide> rides;
  final DateTime? startDate;
  final DateTime? endDate;

  const UpcomingRidesLoaded(
    this.rides, {
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [rides, startDate, endDate];

  /// Get rides for a specific child
  List<UpcomingRide> getRidesForChild(String childId) {
    return rides.where((ride) => ride.childId == childId).toList();
  }

  /// Get rides for a specific date
  List<UpcomingRide> getRidesForDate(String date) {
    return rides.where((ride) => ride.date == date).toList();
  }

  /// Get morning rides
  List<UpcomingRide> get morningRides =>
      rides.where((ride) => ride.period.toLowerCase() == 'morning').toList();

  /// Get afternoon rides
  List<UpcomingRide> get afternoonRides =>
      rides.where((ride) => ride.period.toLowerCase() == 'afternoon').toList();

  /// Get count of upcoming rides
  int get count => rides.length;

  /// Check if there are any rides
  bool get hasRides => rides.isNotEmpty;

  /// Group rides by date
  Map<String, List<UpcomingRide>> get ridesByDate {
    final Map<String, List<UpcomingRide>> grouped = {};
    for (final ride in rides) {
      if (!grouped.containsKey(ride.date)) {
        grouped[ride.date] = [];
      }
      grouped[ride.date]!.add(ride);
    }
    return grouped;
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
  List<UpcomingRide> _allRides = [];
  DateTime? _startDate;
  DateTime? _endDate;

  UpcomingRidesCubit({required RidesRepository repository})
    : _repository = repository,
      super(UpcomingRidesInitial());

  /// Load all upcoming rides
  Future<void> loadUpcomingRides() async {
    emit(UpcomingRidesLoading());
    try {
      final rides = await _repository.getUpcomingRides();
      _allRides = rides;

      if (rides.isEmpty) {
        emit(UpcomingRidesEmpty());
      } else {
        _applyFilters();
      }
    } catch (e) {
      emit(UpcomingRidesError(e.toString()));
    }
  }

  /// Apply date range filter
  void filterByDateRange(DateTime? startDate, DateTime? endDate) {
    _startDate = startDate;
    _endDate = endDate;
    _applyFilters();
  }

  /// Clear date filters
  void clearFilters() {
    _startDate = null;
    _endDate = null;
    _applyFilters();
  }

  /// Apply current filters to rides
  void _applyFilters() {
    List<UpcomingRide> filteredRides = _allRides;

    // Apply date range filter if set
    if (_startDate != null || _endDate != null) {
      filteredRides = _allRides.where((ride) {
        try {
          final rideDate = DateTime.parse(ride.date);
          final rideDateOnly = DateTime(rideDate.year, rideDate.month, rideDate.day);

          if (_startDate != null && _endDate != null) {
            final start = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
            final end = DateTime(_endDate!.year, _endDate!.month, _endDate!.day);
            return !rideDateOnly.isBefore(start) && !rideDateOnly.isAfter(end);
          } else if (_startDate != null) {
            final start = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
            return !rideDateOnly.isBefore(start);
          } else if (_endDate != null) {
            final end = DateTime(_endDate!.year, _endDate!.month, _endDate!.day);
            return !rideDateOnly.isAfter(end);
          }
        } catch (_) {
          // If date parsing fails, exclude the ride
          return false;
        }
        return true;
      }).toList();
    }

    if (filteredRides.isEmpty) {
      emit(UpcomingRidesEmpty());
    } else {
      emit(UpcomingRidesLoaded(
        filteredRides,
        startDate: _startDate,
        endDate: _endDate,
      ));
    }
  }

  /// Refresh upcoming rides
  Future<void> refresh() async {
    await loadUpcomingRides();
  }
}
