import 'package:equatable/equatable.dart';

enum RideStatus {
  scheduled,
  inProgress,
  completed,
  cancelled;

  static RideStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return RideStatus.scheduled;
      case 'in_progress':
        return RideStatus.inProgress;
      case 'completed':
        return RideStatus.completed;
      case 'cancelled':
        return RideStatus.cancelled;
      default:
        return RideStatus.scheduled;
    }
  }

  String toJson() {
    switch (this) {
      case RideStatus.scheduled:
        return 'scheduled';
      case RideStatus.inProgress:
        return 'in_progress';
      case RideStatus.completed:
        return 'completed';
      case RideStatus.cancelled:
        return 'cancelled';
    }
  }
}

class DriverRidesTodayResponse extends Equatable {
  final bool success;
  final DriverRidesTodayData data;

  const DriverRidesTodayResponse({
    required this.success,
    required this.data,
  });

  factory DriverRidesTodayResponse.fromJson(Map<String, dynamic> json) {
    return DriverRidesTodayResponse(
      success: json['success'] ?? false,
      data: DriverRidesTodayData.fromJson(json['data'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [success, data];
}

class DriverRidesTodayData extends Equatable {
  final String date;
  final List<RideOccurrence> morning;
  final List<RideOccurrence> afternoon;
  final int total;

  const DriverRidesTodayData({
    required this.date,
    required this.morning,
    required this.afternoon,
    required this.total,
  });

  factory DriverRidesTodayData.fromJson(Map<String, dynamic> json) {
    return DriverRidesTodayData(
      date: json['date'] ?? '',
      morning: (json['morning'] as List<dynamic>?)
              ?.map((item) => RideOccurrence.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      afternoon: (json['afternoon'] as List<dynamic>?)
              ?.map((item) => RideOccurrence.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      total: json['total'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [date, morning, afternoon, total];
}

class RideOccurrence extends Equatable {
  final String occurrenceId;
  final String rideId;
  final String name;
  final String type;
  final RideStatus status;
  final String? startedAt;
  final String? completedAt;
  final RideBus bus;
  final RideRoute route;
  final int studentsCount;

  const RideOccurrence({
    required this.occurrenceId,
    required this.rideId,
    required this.name,
    required this.type,
    required this.status,
    this.startedAt,
    this.completedAt,
    required this.bus,
    required this.route,
    required this.studentsCount,
  });

  factory RideOccurrence.fromJson(Map<String, dynamic> json) {
    return RideOccurrence(
      occurrenceId: json['occurrenceId'] ?? '',
      rideId: json['rideId'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      status: RideStatus.fromString(json['status'] ?? 'scheduled'),
      startedAt: json['startedAt'],
      completedAt: json['completedAt'],
      bus: RideBus.fromJson(json['bus'] ?? {}),
      route: RideRoute.fromJson(json['route'] ?? {}),
      studentsCount: json['studentsCount'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [
    occurrenceId,
    rideId,
    name,
    type,
    status,
    startedAt,
    completedAt,
    bus,
    route,
    studentsCount,
  ];
}

class RideBus extends Equatable {
  final String id;
  final String busNumber;
  final String plateNumber;

  const RideBus({
    required this.id,
    required this.busNumber,
    required this.plateNumber,
  });

  factory RideBus.fromJson(Map<String, dynamic> json) {
    return RideBus(
      id: json['id'] ?? '',
      busNumber: json['busNumber'] ?? '',
      plateNumber: json['plateNumber'] ?? '',
    );
  }

  @override
  List<Object?> get props => [id, busNumber, plateNumber];
}

class RideRoute extends Equatable {
  final String id;
  final String name;

  const RideRoute({
    required this.id,
    required this.name,
  });

  factory RideRoute.fromJson(Map<String, dynamic> json) {
    return RideRoute(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  @override
  List<Object?> get props => [id, name];
}
