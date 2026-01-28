import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/network/api_service.dart';

// States
abstract class ChildRidesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChildRidesInitial extends ChildRidesState {}

class ChildRidesLoading extends ChildRidesState {}

class ChildRidesLoaded extends ChildRidesState {
  final ChildRideData? liveRide;
  final List<ChildRideData> todayRides;
  final List<ChildRideData> upcomingRides;
  final List<ChildRideData> historyRides;

  ChildRidesLoaded({
    this.liveRide,
    required this.todayRides,
    required this.upcomingRides,
    required this.historyRides,
  });

  @override
  List<Object?> get props => [
    liveRide,
    todayRides,
    upcomingRides,
    historyRides,
  ];
}

class ChildRidesError extends ChildRidesState {
  final String message;
  ChildRidesError(this.message);

  @override
  List<Object?> get props => [message];
}

// Data model for child-specific ride data
class ChildRideData {
  final String occurrenceId;
  final String rideName;
  final String rideType;
  final String? pickupTime;
  final String? amPm;
  final String? dateLabel;
  final String? routeDescription;
  final String? driverName;
  final String? driverAvatar;
  final String? eta;
  final bool isLive;
  final bool isCompleted;
  final bool isCancelled;

  ChildRideData({
    required this.occurrenceId,
    required this.rideName,
    required this.rideType,
    this.pickupTime,
    this.amPm,
    this.dateLabel,
    this.routeDescription,
    this.driverName,
    this.driverAvatar,
    this.eta,
    this.isLive = false,
    this.isCompleted = false,
    this.isCancelled = false,
  });

  factory ChildRideData.fromJson(Map<String, dynamic> json) {
    // Parse pickup time to get time and AM/PM
    String? fullTime = json['pickupTime'] as String?;
    String? time;
    String? amPm;
    if (fullTime != null) {
      final parts = fullTime.split(' ');
      time = parts.isNotEmpty ? parts[0] : fullTime;
      amPm = parts.length > 1 ? parts[1] : null;
    }

    // Determine route description from ride type
    final rideType = json['ride']?['type'] ?? json['type'] ?? '';
    String routeDesc;
    if (rideType.toString().toLowerCase().contains('morning')) {
      routeDesc = 'Home → School';
    } else {
      routeDesc = 'School → Home';
    }

    // Get ride name
    final rideName = json['ride']?['name'] ?? json['name'] ?? 'Unknown Ride';

    return ChildRideData(
      occurrenceId: json['occurrenceId'] ?? json['id'] ?? '',
      rideName: rideName,
      rideType: rideType,
      pickupTime: time,
      amPm: amPm,
      dateLabel: json['dateLabel'],
      routeDescription: json['routeDescription'] ?? routeDesc,
      driverName: json['driver']?['name'] ?? json['driverName'],
      driverAvatar: json['driver']?['avatar'] ?? json['driverAvatar'],
      eta: json['eta'],
      isLive: json['isLive'] ?? false,
      isCompleted: json['status']?.toString().toLowerCase() == 'completed',
      isCancelled: json['status']?.toString().toLowerCase() == 'cancelled',
    );
  }
}

// Cubit
class ChildRidesCubit extends Cubit<ChildRidesState> {
  final ApiService apiService;
  final String childId;

  ChildRidesCubit({required this.apiService, required this.childId})
    : super(ChildRidesInitial());

  Future<void> loadRides() async {
    emit(ChildRidesLoading());
    try {
      // Try to get child-specific rides data
      final response = await apiService.getChildSchedule(childId);

      if (response.success) {
        final data = response.data;

        ChildRideData? liveRide;
        List<ChildRideData> todayRides = [];
        List<ChildRideData> upcomingRides = [];
        List<ChildRideData> historyRides = [];

        // Process live ride
        if (data['liveRide'] != null) {
          liveRide = ChildRideData.fromJson(data['liveRide']);
        }

        // Process today's rides
        if (data['todayRides'] != null) {
          todayRides = (data['todayRides'] as List)
              .map((r) => ChildRideData.fromJson(r))
              .toList();
        }

        // Process upcoming rides
        if (data['upcomingRides'] != null) {
          upcomingRides = (data['upcomingRides'] as List)
              .map((r) => ChildRideData.fromJson(r))
              .toList();
        }

        // Process history rides
        if (data['historyRides'] != null) {
          historyRides = (data['historyRides'] as List)
              .map((r) => ChildRideData.fromJson(r))
              .toList();
        }

        emit(
          ChildRidesLoaded(
            liveRide: liveRide,
            todayRides: todayRides,
            upcomingRides: upcomingRides,
            historyRides: historyRides,
          ),
        );
      } else {
        emit(ChildRidesError('Failed to load rides'));
      }
    } catch (e) {
      // If API doesn't exist yet, use fallback with existing APIs
      await _loadRidesFallback();
    }
  }

  /// Fallback method using existing APIs
  Future<void> _loadRidesFallback() async {
    try {
      // Get children rides data and filter for this child
      final childrenResponse = await apiService.getChildrenRides();
      final activeResponse = await apiService.getActiveRides();
      final upcomingResponse = await apiService.getUpcomingRides();

      ChildRideData? liveRide;
      List<ChildRideData> todayRides = [];
      List<ChildRideData> upcomingRides = [];
      List<ChildRideData> historyRides = [];

      // Find active ride for this child
      for (final activeRide in activeResponse.activeRides) {
        if (activeRide.childName.isNotEmpty) {
          liveRide = ChildRideData(
            occurrenceId: activeRide.occurrenceId,
            rideName: activeRide.rideName,
            rideType: activeRide.rideType,
            pickupTime: null,
            routeDescription:
                activeRide.rideType.toLowerCase().contains('morning')
                ? 'Home → School'
                : 'School → Home',
            driverName: activeRide.driverName,
            driverAvatar: activeRide.driverAvatar,
            eta: '5 min',
            isLive: true,
          );
          break;
        }
      }

      // Process rides from children data
      for (final child in childrenResponse.data.children) {
        if (child.id == childId) {
          for (final ride in child.rides) {
            final rideData = ChildRideData(
              occurrenceId: ride.id,
              rideName: ride.name,
              rideType: ride.type,
              pickupTime: ride.pickupTime.split(' ').first,
              amPm: ride.pickupTime.split(' ').length > 1
                  ? ride.pickupTime.split(' ')[1]
                  : null,
              dateLabel: 'Today',
              routeDescription: ride.type.toLowerCase().contains('morning')
                  ? 'Home → School'
                  : 'School → Home',
              driverName: ride.driver?.name ?? 'Unknown',
              driverAvatar: ride.driver?.avatar,
            );
            todayRides.add(rideData);
          }
          break;
        }
      }

      // Process upcoming rides - filter for this child
      for (final day in upcomingResponse.upcomingDays) {
        for (final ride in day.rides) {
          final rideData = ChildRideData(
            occurrenceId: ride.occurrenceId,
            rideName: ride.rideName,
            rideType: ride.rideType,
            pickupTime: ride.pickupTime.split(' ').first,
            amPm: ride.pickupTime.split(' ').length > 1
                ? ride.pickupTime.split(' ')[1]
                : null,
            dateLabel: day.dayName,
            routeDescription: ride.rideType.toLowerCase().contains('morning')
                ? 'Home → School'
                : 'School → Home',
            driverName: 'Driver',
          );
          upcomingRides.add(rideData);
        }
      }

      emit(
        ChildRidesLoaded(
          liveRide: liveRide,
          todayRides: todayRides,
          upcomingRides: upcomingRides,
          historyRides: historyRides,
        ),
      );
    } catch (e) {
      emit(ChildRidesError(e.toString()));
    }
  }
}
