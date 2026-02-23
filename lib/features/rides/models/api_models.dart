// lib/features/rides/models/api_models.dart

/// API models for rides feature
library;

/// ============================================================
/// TODAY RIDE MODELS
/// ============================================================

/// Response for GET /api/users/rides/child/{childId}
class ChildTodayRidesResponse {
  final bool success;
  final ChildTodayRidesData data;

  ChildTodayRidesResponse({required this.success, required this.data});

  factory ChildTodayRidesResponse.fromJson(Map<String, dynamic> json) {
    return ChildTodayRidesResponse(
      success: json['success'] ?? false,
      data: ChildTodayRidesData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
    };
  }
}

class ChildTodayRidesData {
  final ChildInfo child;
  final String type;
  final String date;
  final List<TodayRideOccurrence> morning;
  final List<TodayRideOccurrence> afternoon;
  final int total;

  ChildTodayRidesData({
    required this.child,
    required this.type,
    required this.date,
    required this.morning,
    required this.afternoon,
    required this.total,
  });

  factory ChildTodayRidesData.fromJson(Map<String, dynamic> json) {
    return ChildTodayRidesData(
      child: ChildInfo.fromJson(json['child'] ?? {}),
      type: json['type'] ?? '',
      date: json['date'] ?? '',
      morning: (json['morning'] as List?)
          ?.map((i) => TodayRideOccurrence.fromJson(i))
          .toList() ?? [],
      afternoon: (json['afternoon'] as List?)
          ?.map((i) => TodayRideOccurrence.fromJson(i))
          .toList() ?? [],
      total: json['total'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'child': child.toJson(),
      'type': type,
      'date': date,
      'morning': morning.map((i) => i.toJson()).toList(),
      'afternoon': afternoon.map((i) => i.toJson()).toList(),
      'total': total,
    };
  }

  /// Get all rides (morning + afternoon)
  List<TodayRideOccurrence> get allRides => [...morning, ...afternoon];
}

class ChildInfo {
  final String id;
  final String name;
  final String? avatar;
  final String grade;
  final String classroom;
  final OrganizationInfo organization;

  ChildInfo({
    required this.id,
    required this.name,
    this.avatar,
    required this.grade,
    required this.classroom,
    required this.organization,
  });

  factory ChildInfo.fromJson(Map<String, dynamic> json) {
    return ChildInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      avatar: json['avatar'],
      grade: json['grade'] ?? '',
      classroom: json['classroom'] ?? '',
      organization: OrganizationInfo.fromJson(json['organization'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'grade': grade,
      'classroom': classroom,
      'organization': organization.toJson(),
    };
  }
}

class TodayRideOccurrence {
  final String occurrenceId;
  final String date;
  final String status;
  final String? startedAt;
  final String? completedAt;
  final dynamic busLocation;
  final RideInfo ride;
  final StudentStatus studentStatus;
  final BusInfo bus;
  final DriverInfo driver;
  final PickupPoint pickupPoint;

  TodayRideOccurrence({
    required this.occurrenceId,
    required this.date,
    required this.status,
    this.startedAt,
    this.completedAt,
    this.busLocation,
    required this.ride,
    required this.studentStatus,
    required this.bus,
    required this.driver,
    required this.pickupPoint,
  });

  factory TodayRideOccurrence.fromJson(Map<String, dynamic> json) {
    return TodayRideOccurrence(
      occurrenceId: json['occurrenceId'] ?? '',
      date: json['date'] ?? '',
      status: json['status'] ?? '',
      startedAt: json['startedAt'],
      completedAt: json['completedAt'],
      busLocation: json['busLocation'],
      ride: RideInfo.fromJson(json['ride'] ?? {}),
      studentStatus: StudentStatus.fromJson(json['studentStatus'] ?? {}),
      bus: BusInfo.fromJson(json['bus'] ?? {}),
      driver: DriverInfo.fromJson(json['driver'] ?? {}),
      pickupPoint: PickupPoint.fromJson(json['pickupPoint'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'occurrenceId': occurrenceId,
      'date': date,
      'status': status,
      'startedAt': startedAt,
      'completedAt': completedAt,
      'busLocation': busLocation,
      'ride': ride.toJson(),
      'studentStatus': studentStatus.toJson(),
      'bus': bus.toJson(),
      'driver': driver.toJson(),
      'pickupPoint': pickupPoint.toJson(),
    };
  }

  /// Get pickup time from student status
  String get pickupTime => studentStatus.pickupTime ?? '--:--';

  /// Check if ride is active
  bool get isActive => status == 'in_progress' || status == 'started';

  /// Check if ride is completed
  bool get isCompleted => status == 'completed';

  /// Check if ride is scheduled
  bool get isScheduled => status == 'scheduled';

  /// Check if student can report absence
  bool get canReportAbsence => isScheduled;
}

class RideInfo {
  final String id;
  final String name;
  final String type;

  RideInfo({required this.id, required this.name, required this.type});

  factory RideInfo.fromJson(Map<String, dynamic> json) {
    return RideInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
    };
  }
}

class StudentStatus {
  final String id;
  final String status;
  final String? pickedUpAt;
  final String? droppedOffAt;
  final String? pickupTime;
  final String? excuseReason;

  StudentStatus({
    required this.id,
    required this.status,
    this.pickedUpAt,
    this.droppedOffAt,
    this.pickupTime,
    this.excuseReason,
  });

  factory StudentStatus.fromJson(Map<String, dynamic> json) {
    return StudentStatus(
      id: json['id'] ?? '',
      status: json['status'] ?? '',
      pickedUpAt: json['pickedUpAt'],
      droppedOffAt: json['droppedOffAt'],
      pickupTime: json['pickupTime'],
      excuseReason: json['excuseReason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'pickedUpAt': pickedUpAt,
      'droppedOffAt': droppedOffAt,
      'pickupTime': pickupTime,
      'excuseReason': excuseReason,
    };
  }
}

/// ============================================================
/// CHILDREN WITH RIDES MODELS
/// ============================================================

/// Response for GET /api/users/rides/children
class ChildrenWithRidesResponse {
  final bool success;
  final ChildrenWithRidesData data;

  ChildrenWithRidesResponse({required this.success, required this.data});

  factory ChildrenWithRidesResponse.fromJson(Map<String, dynamic> json) {
    return ChildrenWithRidesResponse(
      success: json['success'] ?? false,
      data: ChildrenWithRidesData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
    };
  }
}

class ChildrenWithRidesData {
  final List<ChildWithRides> children;
  final List<OrganizationRides> byOrganization;
  final int totalChildren;

  ChildrenWithRidesData({
    required this.children,
    required this.byOrganization,
    required this.totalChildren,
  });

  factory ChildrenWithRidesData.fromJson(Map<String, dynamic> json) {
    return ChildrenWithRidesData(
      children: (json['children'] as List?)
          ?.map((i) => ChildWithRides.fromJson(i))
          .toList() ?? [],
      byOrganization: (json['byOrganization'] as List?)
          ?.map((i) => OrganizationRides.fromJson(i))
          .toList() ?? [],
      totalChildren: json['totalChildren'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'children': children.map((i) => i.toJson()).toList(),
      'byOrganization': byOrganization.map((i) => i.toJson()).toList(),
      'totalChildren': totalChildren,
    };
  }
}

class ChildWithRides {
  final String id;
  final String name;
  final String? avatar;
  final String grade;
  final String classroom;
  final String code;
  final OrganizationInfo organization;
  final List<ChildRide> rides;

  ChildWithRides({
    required this.id,
    required this.name,
    this.avatar,
    required this.grade,
    required this.classroom,
    required this.code,
    required this.organization,
    required this.rides,
  });

  factory ChildWithRides.fromJson(Map<String, dynamic> json) {
    return ChildWithRides(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      avatar: json['avatar'],
      grade: json['grade'] ?? '',
      classroom: json['classroom'] ?? '',
      code: json['code'] ?? '',
      organization: OrganizationInfo.fromJson(json['organization'] ?? {}),
      rides: (json['rides'] as List?)
          ?.map((i) => ChildRide.fromJson(i))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'grade': grade,
      'classroom': classroom,
      'code': code,
      'organization': organization.toJson(),
      'rides': rides.map((i) => i.toJson()).toList(),
    };
  }
}

class ChildRide {
  final String id;
  final String name;
  final String type;
  final String frequency;
  final String pickupTime;
  final PickupPoint pickupPoint;
  final BusInfo bus;
  final DriverInfo driver;

  ChildRide({
    required this.id,
    required this.name,
    required this.type,
    required this.frequency,
    required this.pickupTime,
    required this.pickupPoint,
    required this.bus,
    required this.driver,
  });

  factory ChildRide.fromJson(Map<String, dynamic> json) {
    return ChildRide(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      frequency: json['frequency'] ?? '',
      pickupTime: json['pickupTime'] ?? '',
      pickupPoint: PickupPoint.fromJson(json['pickupPoint'] ?? {}),
      bus: BusInfo.fromJson(json['bus'] ?? {}),
      driver: DriverInfo.fromJson(json['driver'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'frequency': frequency,
      'pickupTime': pickupTime,
      'pickupPoint': pickupPoint.toJson(),
      'bus': bus.toJson(),
      'driver': driver.toJson(),
    };
  }
}

class OrganizationRides {
  final OrganizationInfo organization;
  final List<ChildWithRides> children;

  OrganizationRides({required this.organization, required this.children});

  factory OrganizationRides.fromJson(Map<String, dynamic> json) {
    return OrganizationRides(
      organization: OrganizationInfo.fromJson(json['organization'] ?? {}),
      children: (json['children'] as List?)
          ?.map((i) => ChildWithRides.fromJson(i))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'organization': organization.toJson(),
      'children': children.map((i) => i.toJson()).toList(),
    };
  }
}

/// ============================================================
/// ACTIVE RIDES MODELS
/// ============================================================

/// Response for GET /api/users/rides/active
class ActiveRidesResponse {
  final bool success;
  final ActiveRidesData data;

  ActiveRidesResponse({required this.success, required this.data});

  factory ActiveRidesResponse.fromJson(Map<String, dynamic> json) {
    return ActiveRidesResponse(
      success: json['success'] ?? false,
      data: ActiveRidesData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
    };
  }
}

class ActiveRidesData {
  final List<dynamic> activeRides;
  final int count;

  ActiveRidesData({required this.activeRides, required this.count});

  factory ActiveRidesData.fromJson(Map<String, dynamic> json) {
    return ActiveRidesData(
      activeRides: json['activeRides'] ?? [],
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activeRides': activeRides,
      'count': count,
    };
  }
}

/// ============================================================
/// UPCOMING RIDES MODELS
/// ============================================================

/// Response for GET /api/users/rides/upcoming
class UpcomingRidesResponse {
  final bool success;
  final UpcomingRidesData data;

  UpcomingRidesResponse({required this.success, required this.data});

  factory UpcomingRidesResponse.fromJson(Map<String, dynamic> json) {
    return UpcomingRidesResponse(
      success: json['success'] ?? false,
      data: UpcomingRidesData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
    };
  }
}

class UpcomingRidesData {
  final List<UpcomingDayRides> upcomingRides;
  final int totalDays;
  final int totalRides;

  UpcomingRidesData({
    required this.upcomingRides,
    required this.totalDays,
    required this.totalRides,
  });

  factory UpcomingRidesData.fromJson(Map<String, dynamic> json) {
    return UpcomingRidesData(
      upcomingRides: (json['upcomingRides'] as List?)
          ?.map((i) => UpcomingDayRides.fromJson(i))
          .toList() ?? [],
      totalDays: json['totalDays'] ?? 0,
      totalRides: json['totalRides'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'upcomingRides': upcomingRides.map((i) => i.toJson()).toList(),
      'totalDays': totalDays,
      'totalRides': totalRides,
    };
  }
}

class UpcomingDayRides {
  final String date;
  final String dayName;
  final List<UpcomingRide> rides;

  UpcomingDayRides({
    required this.date,
    required this.dayName,
    required this.rides,
  });

  factory UpcomingDayRides.fromJson(Map<String, dynamic> json) {
    return UpcomingDayRides(
      date: json['date'] ?? '',
      dayName: json['dayName'] ?? '',
      rides: (json['rides'] as List?)
          ?.map((i) => UpcomingRide.fromJson(i))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'dayName': dayName,
      'rides': rides.map((i) => i.toJson()).toList(),
    };
  }
}

class UpcomingRide {
  final String occurrenceId;
  final RideInfo ride;
  final ChildInfo child;
  final String pickupTime;
  final String pickupPointName;

  UpcomingRide({
    required this.occurrenceId,
    required this.ride,
    required this.child,
    required this.pickupTime,
    required this.pickupPointName,
  });

  factory UpcomingRide.fromJson(Map<String, dynamic> json) {
    return UpcomingRide(
      occurrenceId: json['occurrenceId'] ?? '',
      ride: RideInfo.fromJson(json['ride'] ?? {}),
      child: ChildInfo.fromJson(json['child'] ?? {}),
      pickupTime: json['pickupTime'] ?? '',
      pickupPointName: json['pickupPointName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'occurrenceId': occurrenceId,
      'ride': ride.toJson(),
      'child': child.toJson(),
      'pickupTime': pickupTime,
      'pickupPointName': pickupPointName,
    };
  }
}

/// ============================================================
/// RIDE SUMMARY MODELS
/// ============================================================

/// Response for GET /api/users/rides/child/{childId}/summary
class RideSummaryResponse {
  final bool success;
  final RideSummaryData data;

  RideSummaryResponse({required this.success, required this.data});

  factory RideSummaryResponse.fromJson(Map<String, dynamic> json) {
    return RideSummaryResponse(
      success: json['success'] ?? false,
      data: RideSummaryData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
    };
  }
}

class RideSummaryData {
  final ChildInfo child;
  final SummaryPeriod period;
  final SummaryInfo summary;

  RideSummaryData({
    required this.child,
    required this.period,
    required this.summary,
  });

  factory RideSummaryData.fromJson(Map<String, dynamic> json) {
    return RideSummaryData(
      child: ChildInfo.fromJson(json['child'] ?? {}),
      period: SummaryPeriod.fromJson(json['period'] ?? {}),
      summary: SummaryInfo.fromJson(json['summary'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'child': child.toJson(),
      'period': period.toJson(),
      'summary': summary.toJson(),
    };
  }
}

class SummaryPeriod {
  final int month;
  final int year;
  final String monthName;

  SummaryPeriod({
    required this.month,
    required this.year,
    required this.monthName,
  });

  factory SummaryPeriod.fromJson(Map<String, dynamic> json) {
    return SummaryPeriod(
      month: json['month'] ?? 0,
      year: json['year'] ?? 0,
      monthName: json['monthName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'year': year,
      'monthName': monthName,
    };
  }
}

class SummaryInfo {
  final int total;
  final int morning;
  final int afternoon;
  final SummaryByStatus byStatus;
  final int attendanceRate;

  SummaryInfo({
    required this.total,
    required this.morning,
    required this.afternoon,
    required this.byStatus,
    required this.attendanceRate,
  });

  factory SummaryInfo.fromJson(Map<String, dynamic> json) {
    return SummaryInfo(
      total: json['total'] ?? 0,
      morning: json['morning'] ?? 0,
      afternoon: json['afternoon'] ?? 0,
      byStatus: SummaryByStatus.fromJson(json['byStatus'] ?? {}),
      attendanceRate: json['attendanceRate'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'morning': morning,
      'afternoon': afternoon,
      'byStatus': byStatus.toJson(),
      'attendanceRate': attendanceRate,
    };
  }
}

class SummaryByStatus {
  final int completed;
  final int absent;
  final int excused;
  final int pending;

  SummaryByStatus({
    required this.completed,
    required this.absent,
    required this.excused,
    required this.pending,
  });

  factory SummaryByStatus.fromJson(Map<String, dynamic> json) {
    return SummaryByStatus(
      completed: json['completed'] ?? 0,
      absent: json['absent'] ?? 0,
      excused: json['excused'] ?? 0,
      pending: json['pending'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'completed': completed,
      'absent': absent,
      'excused': excused,
      'pending': pending,
    };
  }
}

/// ============================================================
/// RIDE TRACKING MODELS
/// ============================================================

/// Response for GET /api/users/rides/tracking/{childId}
class RideTrackingResponse {
  final bool success;
  final dynamic error;
  final RideTrackingData? data;

  RideTrackingResponse({required this.success, this.error, this.data});

  factory RideTrackingResponse.fromJson(Map<String, dynamic> json) {
    return RideTrackingResponse(
      success: json['success'] ?? false,
      error: json['error'],
      data: json['data'] != null ? RideTrackingData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'error': error,
      'data': data?.toJson(),
    };
  }
}

class RideTrackingData {
  final RideOccurrence occurrence;
  final RideInfo ride;
  final TrackingBus bus;
  final DriverInfo driver;
  final TrackingRoute route;
  final List<TrackingChild> children;

  RideTrackingData({
    required this.occurrence,
    required this.ride,
    required this.bus,
    required this.driver,
    required this.route,
    required this.children,
  });

  factory RideTrackingData.fromJson(Map<String, dynamic> json) {
    return RideTrackingData(
      occurrence: RideOccurrence.fromJson(json['occurrence'] ?? {}),
      ride: RideInfo.fromJson(json['ride'] ?? {}),
      bus: TrackingBus.fromJson(json['bus'] ?? {}),
      driver: DriverInfo.fromJson(json['driver'] ?? {}),
      route: TrackingRoute.fromJson(json['route'] ?? {}),
      children: (json['children'] as List?)
          ?.map((i) => TrackingChild.fromJson(i))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'occurrence': occurrence.toJson(),
      'ride': ride.toJson(),
      'bus': bus.toJson(),
      'driver': driver.toJson(),
      'route': route.toJson(),
      'children': children.map((i) => i.toJson()).toList(),
    };
  }
}

class RideOccurrence {
  final String id;
  final String date;
  final String status;
  final String? startedAt;
  final String? completedAt;

  RideOccurrence({
    required this.id,
    required this.date,
    required this.status,
    this.startedAt,
    this.completedAt,
  });

  factory RideOccurrence.fromJson(Map<String, dynamic> json) {
    return RideOccurrence(
      id: json['id'] ?? '',
      date: json['date'] ?? '',
      status: json['status'] ?? '',
      startedAt: json['startedAt'],
      completedAt: json['completedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'status': status,
      'startedAt': startedAt,
      'completedAt': completedAt,
    };
  }
}

class TrackingBus {
  final String id;
  final String busNumber;
  final String plateNumber;
  final dynamic currentLocation;

  TrackingBus({
    required this.id,
    required this.busNumber,
    required this.plateNumber,
    this.currentLocation,
  });

  factory TrackingBus.fromJson(Map<String, dynamic> json) {
    return TrackingBus(
      id: json['id'] ?? '',
      busNumber: json['busNumber'] ?? '',
      plateNumber: json['plateNumber'] ?? '',
      currentLocation: json['currentLocation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'busNumber': busNumber,
      'plateNumber': plateNumber,
      'currentLocation': currentLocation,
    };
  }
}

class TrackingRoute {
  final String id;
  final String name;
  final List<RouteStop> stops;

  TrackingRoute({required this.id, required this.name, required this.stops});

  factory TrackingRoute.fromJson(Map<String, dynamic> json) {
    return TrackingRoute(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      stops: (json['stops'] as List?)
          ?.map((i) => RouteStop.fromJson(i))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'stops': stops.map((i) => i.toJson()).toList(),
    };
  }
}

class RouteStop {
  final String id;
  final String name;
  final String address;
  final String lat;
  final String lng;
  final int stopOrder;

  RouteStop({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.stopOrder,
  });

  factory RouteStop.fromJson(Map<String, dynamic> json) {
    return RouteStop(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      lat: json['lat']?.toString() ?? '',
      lng: json['lng']?.toString() ?? '',
      stopOrder: json['stopOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'lat': lat,
      'lng': lng,
      'stopOrder': stopOrder,
    };
  }
}

class TrackingChild {
  final String id;
  final String status;
  final String? pickedUpAt;
  final String? droppedOffAt;
  final String pickupTime;
  final String? excuseReason;
  final ChildInfo child;
  final PickupPoint pickupPoint;

  TrackingChild({
    required this.id,
    required this.status,
    this.pickedUpAt,
    this.droppedOffAt,
    required this.pickupTime,
    this.excuseReason,
    required this.child,
    required this.pickupPoint,
  });

  factory TrackingChild.fromJson(Map<String, dynamic> json) {
    return TrackingChild(
      id: json['id'] ?? '',
      status: json['status'] ?? '',
      pickedUpAt: json['pickedUpAt'],
      droppedOffAt: json['droppedOffAt'],
      pickupTime: json['pickupTime'] ?? '',
      excuseReason: json['excuseReason'],
      child: ChildInfo.fromJson(json['child'] ?? {}),
      pickupPoint: PickupPoint.fromJson(json['pickupPoint'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'pickedUpAt': pickedUpAt,
      'droppedOffAt': droppedOffAt,
      'pickupTime': pickupTime,
      'excuseReason': excuseReason,
      'child': child.toJson(),
      'pickupPoint': pickupPoint.toJson(),
    };
  }
}

/// ============================================================
/// COMMON MODELS
/// ============================================================

class OrganizationInfo {
  final String id;
  final String name;
  final String? logo;

  OrganizationInfo({required this.id, required this.name, this.logo});

  factory OrganizationInfo.fromJson(Map<String, dynamic> json) {
    return OrganizationInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      logo: json['logo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo': logo,
    };
  }
}

class BusInfo {
  final String id;
  final String busNumber;
  final String plateNumber;

  BusInfo({required this.id, required this.busNumber, required this.plateNumber});

  factory BusInfo.fromJson(Map<String, dynamic> json) {
    return BusInfo(
      id: json['id'] ?? '',
      busNumber: json['busNumber'] ?? '',
      plateNumber: json['plateNumber'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'busNumber': busNumber,
      'plateNumber': plateNumber,
    };
  }
}

class DriverInfo {
  final String id;
  final String name;
  final String phone;
  final String? avatar;

  DriverInfo({required this.id, required this.name, required this.phone, this.avatar});

  factory DriverInfo.fromJson(Map<String, dynamic> json) {
    return DriverInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'avatar': avatar,
    };
  }
}

class PickupPoint {
  final String id;
  final String name;
  final String address;
  final String lat;
  final String lng;

  PickupPoint({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
  });

  factory PickupPoint.fromJson(Map<String, dynamic> json) {
    return PickupPoint(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      lat: json['lat']?.toString() ?? '',
      lng: json['lng']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'lat': lat,
      'lng': lng,
    };
  }
}

/// ============================================================
/// REQUEST MODELS
/// ============================================================

class ReportAbsenceRequest {
  final String reason;

  ReportAbsenceRequest({required this.reason});

  Map<String, dynamic> toJson() {
    return {'reason': reason};
  }
}

/// Response for POST /api/users/rides/excuse/:occurrenceId/:studentId
class ReportAbsenceResponse {
  final bool success;
  final String message;
  final dynamic data;

  ReportAbsenceResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ReportAbsenceResponse.fromJson(Map<String, dynamic> json) {
    return ReportAbsenceResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
    };
  }
}
