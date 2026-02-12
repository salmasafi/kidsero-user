// lib/features/rides/models/ride_models.dart

/// ============================================================
/// RESPONSE WRAPPERS
/// ============================================================

/// Response for GET /api/users/rides/children
class ChildrenWithRidesResponse {
  final bool success;
  final List<ChildWithRides> data;

  ChildrenWithRidesResponse({required this.success, required this.data});

  factory ChildrenWithRidesResponse.fromJson(Map<String, dynamic> json) {
    dynamic rawData = json['data'];
    List<dynamic> listData = [];

    if (rawData is List) {
      listData = rawData;
    } else if (rawData is Map) {
      // Handle wrapped list scenarios (paginated response or nested data)
      if (rawData['children'] is List) {
        listData = rawData['children'];
      } else if (rawData['data'] is List) {
        listData = rawData['data'];
      } else if (rawData['items'] is List) {
        listData = rawData['items'];
      } else if (rawData['results'] is List) {
        listData = rawData['results'];
      }
      // Removed the fallback that wraps the entire object as a single item
    }

    return ChildrenWithRidesResponse(
      success: json['success'] ?? false,
      data: listData.map((i) => ChildWithRides.fromJson(i)).toList(),
    );
  }
}

/// Response for GET /api/users/rides/children/today
class TodayRidesResponse {
  final bool success;
  final String date;
  final List<TodayRide> data;

  TodayRidesResponse({
    required this.success,
    required this.date,
    required this.data,
  });

  factory TodayRidesResponse.fromJson(Map<String, dynamic> json) {
    dynamic rawData = json['data'];
    List<dynamic> listData = [];
    if (rawData is List) {
      listData = rawData;
    } else if (rawData is Map) {
      if (rawData['todayRides'] is List) {
        listData = rawData['todayRides'];
      } else if (rawData['data'] is List) {
        listData = rawData['data'];
      } else if (rawData['items'] is List) {
        listData = rawData['items'];
      } else if (rawData['results'] is List) {
        listData = rawData['results'];
      }
      // Removed the fallback that wraps the entire object as a single item
    }

    return TodayRidesResponse(
      success: json['success'] ?? false,
      date: json['date'] ?? '',
      data: listData.map((i) => TodayRide.fromJson(i)).toList(),
    );
  }
}

/// Response for GET /api/users/rides/active
class ActiveRidesResponse {
  final bool success;
  final List<ActiveRide> data;

  ActiveRidesResponse({required this.success, required this.data});

  factory ActiveRidesResponse.fromJson(Map<String, dynamic> json) {
    dynamic rawData = json['data'];
    List<dynamic> listData = [];
    
    // Debug logging
    print('=== ActiveRidesResponse Parsing ===');
    print('rawData type: ${rawData.runtimeType}');
    print('rawData: $rawData');
    
    if (rawData is List) {
      listData = rawData;
      print('rawData is List, length: ${listData.length}');
    } else if (rawData is Map) {
      print('rawData is Map, keys: ${rawData.keys}');
      if (rawData['activeRides'] is List) {
        listData = rawData['activeRides'];
        print('Found activeRides list, length: ${listData.length}');
      } else if (rawData['data'] is List) {
        listData = rawData['data'];
        print('Found data list, length: ${listData.length}');
      } else if (rawData['items'] is List) {
        listData = rawData['items'];
        print('Found items list, length: ${listData.length}');
      } else if (rawData['results'] is List) {
        listData = rawData['results'];
        print('Found results list, length: ${listData.length}');
      } else if (rawData['active'] is List) {
        listData = rawData['active'];
        print('Found active list, length: ${listData.length}');
      } else {
        print('No matching list key found in Map');
      }
    }
    
    print('Final listData length: ${listData.length}');
    print('===================================');

    return ActiveRidesResponse(
      success: json['success'] ?? false,
      data: listData.map((i) => ActiveRide.fromJson(i)).toList(),
    );
  }
}

/// Response for GET /api/users/rides/upcoming
class UpcomingRidesResponse {
  final bool success;
  final List<UpcomingRide> data;

  UpcomingRidesResponse({required this.success, required this.data});

  factory UpcomingRidesResponse.fromJson(Map<String, dynamic> json) {
    dynamic rawData = json['data'];
    List<dynamic> listData = [];
    if (rawData is List) {
      listData = rawData;
    } else if (rawData is Map) {
      if (rawData['upcomingRides'] is List) {
        listData = rawData['upcomingRides'];
      } else if (rawData['data'] is List) {
        listData = rawData['data'];
      } else if (rawData['items'] is List) {
        listData = rawData['items'];
      } else if (rawData['results'] is List) {
        listData = rawData['results'];
      } else if (rawData['upcoming'] is List) {
        listData = rawData['upcoming'];
      }
      // Removed the fallback that wraps the entire object as a single item
    }

    return UpcomingRidesResponse(
      success: json['success'] ?? false,
      data: listData.map((i) => UpcomingRide.fromJson(i)).toList(),
    );
  }
}

/// Response for GET /api/users/rides/child/:childId
class SingleChildRidesResponse {
  final bool success;
  final ChildRideDetails data;

  SingleChildRidesResponse({required this.success, required this.data});

  factory SingleChildRidesResponse.fromJson(Map<String, dynamic> json) {
    return SingleChildRidesResponse(
      success: json['success'] ?? false,
      data: ChildRideDetails.fromJson(json['data'] ?? {}),
    );
  }
}

/// Response for GET /api/users/rides/child/:childId/summary
class RideSummaryResponse {
  final bool success;
  final RideSummary data;

  RideSummaryResponse({required this.success, required this.data});

  factory RideSummaryResponse.fromJson(Map<String, dynamic> json) {
    return RideSummaryResponse(
      success: json['success'] ?? false,
      data: RideSummary.fromJson(json['data'] ?? {}),
    );
  }
}

/// Response for GET /api/users/rides/tracking/:rideId
class RideTrackingResponse {
  final bool success;
  final RideTracking data;

  RideTrackingResponse({required this.success, required this.data});

  factory RideTrackingResponse.fromJson(Map<String, dynamic> json) {
    return RideTrackingResponse(
      success: json['success'] ?? false,
      data: RideTracking.fromJson(json['data'] ?? {}),
    );
  }
}

/// Response for POST /api/users/rides/excuse/:occurrenceId/:studentId
class ReportAbsenceResponse {
  final bool success;
  final String message;
  final AbsenceData? data;

  ReportAbsenceResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ReportAbsenceResponse.fromJson(Map<String, dynamic> json) {
    return ReportAbsenceResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? AbsenceData.fromJson(json['data']) : null,
    );
  }
}

/// ============================================================
/// DATA MODELS
/// ============================================================

/// Child with ride information for the main listing
class ChildWithRides {
  final String id;
  final String name;
  final String? grade;
  final String? schoolName;
  final String? photoUrl;
  final ChildRideInfo rides;

  ChildWithRides({
    required this.id,
    required this.name,
    this.grade,
    this.schoolName,
    this.photoUrl,
    required this.rides,
  });

  factory ChildWithRides.fromJson(Map<String, dynamic> json) {
    return ChildWithRides(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      grade: json['grade'],
      schoolName: json['schoolName'],
      photoUrl: json['photoUrl'],
      rides: ChildRideInfo.fromJson(json['rides'] ?? {}),
    );
  }
}

/// Ride info summary for a child
class ChildRideInfo {
  final int todayCount;
  final int upcomingCount;
  final ActiveRide? active;
  final String? lastRideAt;

  ChildRideInfo({
    required this.todayCount,
    required this.upcomingCount,
    this.active,
    this.lastRideAt,
  });

  factory ChildRideInfo.fromJson(Map<String, dynamic> json) {
    return ChildRideInfo(
      todayCount: json['todayCount'] ?? 0,
      upcomingCount: json['upcomingCount'] ?? 0,
      active: json['active'] != null
          ? ActiveRide.fromJson(json['active'])
          : null,
      lastRideAt: json['lastRideAt'],
    );
  }
}

/// Today's ride model
class TodayRide {
  final String childId;
  final String childName;
  final String period;
  final String rideId;
  final String? pickupTime;
  final String? dropoffTime;
  final String status;
  final BusInfo? bus;
  final DriverInfo? driver;

  TodayRide({
    required this.childId,
    required this.childName,
    required this.period,
    required this.rideId,
    this.pickupTime,
    this.dropoffTime,
    required this.status,
    this.bus,
    this.driver,
  });

  factory TodayRide.fromJson(Map<String, dynamic> json) {
    return TodayRide(
      childId: json['childId'] ?? '',
      childName: json['childName'] ?? '',
      period: json['period'] ?? '',
      rideId: json['rideId'] ?? '',
      pickupTime: json['pickupTime'],
      dropoffTime: json['dropoffTime'],
      status: json['status'] ?? 'scheduled',
      bus: json['bus'] != null ? BusInfo.fromJson(json['bus']) : null,
      driver: json['driver'] != null
          ? DriverInfo.fromJson(json['driver'])
          : null,
    );
  }
}

/// Active ride model
class ActiveRide {
  final String rideId;
  final String childId;
  final String childName;
  final String status;
  final String? startedAt;
  final String? estimatedArrival;
  final BusInfo? bus;
  final DriverInfo? driver;
  final LocationInfo? lastLocation;

  ActiveRide({
    required this.rideId,
    required this.childId,
    required this.childName,
    required this.status,
    this.startedAt,
    this.estimatedArrival,
    this.bus,
    this.driver,
    this.lastLocation,
  });

  factory ActiveRide.fromJson(Map<String, dynamic> json) {
    return ActiveRide(
      rideId: json['rideId'] ?? '',
      childId: json['childId'] ?? '',
      childName: json['childName'] ?? '',
      status: json['status'] ?? 'in_progress',
      startedAt: json['startedAt'],
      estimatedArrival: json['estimatedArrival'],
      bus: json['bus'] != null ? BusInfo.fromJson(json['bus']) : null,
      driver: json['driver'] != null
          ? DriverInfo.fromJson(json['driver'])
          : null,
      lastLocation: json['lastLocation'] != null
          ? LocationInfo.fromJson(json['lastLocation'])
          : null,
    );
  }
}

/// Upcoming ride model
class UpcomingRide {
  final String rideId;
  final String childId;
  final String childName;
  final String date;
  final String period;
  final String? pickupTime;
  final String? pickupLocation;
  final String? dropoffLocation;
  final String status;

  UpcomingRide({
    required this.rideId,
    required this.childId,
    required this.childName,
    required this.date,
    required this.period,
    this.pickupTime,
    this.pickupLocation,
    this.dropoffLocation,
    required this.status,
  });

  factory UpcomingRide.fromJson(Map<String, dynamic> json) {
    return UpcomingRide(
      rideId: json['rideId'] ?? '',
      childId: json['childId'] ?? '',
      childName: json['childName'] ?? '',
      date: json['date'] ?? '',
      period: json['period'] ?? '',
      pickupTime: json['pickupTime'],
      pickupLocation: json['pickupLocation'],
      dropoffLocation: json['dropoffLocation'],
      status: json['status'] ?? 'scheduled',
    );
  }
}

/// Child ride details for single child view
class ChildRideDetails {
  final String id;
  final String name;
  final String? grade;
  final String? schoolName;
  final ChildRidesData rides;

  ChildRideDetails({
    required this.id,
    required this.name,
    this.grade,
    this.schoolName,
    required this.rides,
  });

  factory ChildRideDetails.fromJson(Map<String, dynamic> json) {
    return ChildRideDetails(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      grade: json['grade'],
      schoolName: json['schoolName'],
      rides: ChildRidesData.fromJson(json['rides'] ?? {}),
    );
  }
}

/// Rides data containing upcoming and history
class ChildRidesData {
  final List<RideHistoryItem> upcoming;
  final List<RideHistoryItem> history;

  ChildRidesData({required this.upcoming, required this.history});

  factory ChildRidesData.fromJson(Map<String, dynamic> json) {
    return ChildRidesData(
      upcoming:
          (json['upcoming'] as List?)
              ?.map((i) => RideHistoryItem.fromJson(i))
              .toList() ??
          [],
      history:
          (json['history'] as List?)
              ?.map((i) => RideHistoryItem.fromJson(i))
              .toList() ??
          [],
    );
  }
}

/// Ride history item
class RideHistoryItem {
  final String rideId;
  final String date;
  final String period;
  final String status;
  final String? pickedUpAt;
  final String? droppedOffAt;

  RideHistoryItem({
    required this.rideId,
    required this.date,
    required this.period,
    required this.status,
    this.pickedUpAt,
    this.droppedOffAt,
  });

  factory RideHistoryItem.fromJson(Map<String, dynamic> json) {
    return RideHistoryItem(
      rideId: json['rideId'] ?? '',
      date: json['date'] ?? '',
      period: json['period'] ?? '',
      status: json['status'] ?? '',
      pickedUpAt: json['pickedUpAt'],
      droppedOffAt: json['droppedOffAt'],
    );
  }
}

/// Ride summary for a child
class RideSummary {
  final String childId;
  final String childName;
  final SummaryPeriod period;
  final SummaryStats stats;
  final List<AbsenceRecord> lastAbsences;

  RideSummary({
    required this.childId,
    required this.childName,
    required this.period,
    required this.stats,
    required this.lastAbsences,
  });

  factory RideSummary.fromJson(Map<String, dynamic> json) {
    return RideSummary(
      childId: json['childId'] ?? '',
      childName: json['childName'] ?? '',
      period: SummaryPeriod.fromJson(json['period'] ?? {}),
      stats: SummaryStats.fromJson(json['stats'] ?? {}),
      lastAbsences:
          (json['lastAbsences'] as List?)
              ?.map((i) => AbsenceRecord.fromJson(i))
              .toList() ??
          [],
    );
  }
}

/// Summary period range
class SummaryPeriod {
  final String from;
  final String to;

  SummaryPeriod({required this.from, required this.to});

  factory SummaryPeriod.fromJson(Map<String, dynamic> json) {
    return SummaryPeriod(from: json['from'] ?? '', to: json['to'] ?? '');
  }
}

/// Summary statistics
class SummaryStats {
  final int totalScheduled;
  final int attended;
  final int absent;
  final int late;

  SummaryStats({
    required this.totalScheduled,
    required this.attended,
    required this.absent,
    required this.late,
  });

  factory SummaryStats.fromJson(Map<String, dynamic> json) {
    return SummaryStats(
      totalScheduled: json['totalScheduled'] ?? 0,
      attended: json['attended'] ?? 0,
      absent: json['absent'] ?? 0,
      late: json['late'] ?? 0,
    );
  }
}

/// Absence record
class AbsenceRecord {
  final String date;
  final String period;
  final String? reason;

  AbsenceRecord({required this.date, required this.period, this.reason});

  factory AbsenceRecord.fromJson(Map<String, dynamic> json) {
    return AbsenceRecord(
      date: json['date'] ?? '',
      period: json['period'] ?? '',
      reason: json['reason'],
    );
  }
}

/// Ride tracking data
class RideTracking {
  final String rideId;
  final String childId;
  final String status;
  final BusInfo? bus;
  final DriverInfo? driver;
  final CurrentLocation? currentLocation;
  final RouteInfo? route;

  RideTracking({
    required this.rideId,
    required this.childId,
    required this.status,
    this.bus,
    this.driver,
    this.currentLocation,
    this.route,
  });

  factory RideTracking.fromJson(Map<String, dynamic> json) {
    return RideTracking(
      rideId: json['rideId'] ?? '',
      childId: json['childId'] ?? '',
      status: json['status'] ?? '',
      bus: json['bus'] != null ? BusInfo.fromJson(json['bus']) : null,
      driver: json['driver'] != null
          ? DriverInfo.fromJson(json['driver'])
          : null,
      currentLocation: json['currentLocation'] != null
          ? CurrentLocation.fromJson(json['currentLocation'])
          : null,
      route: json['route'] != null ? RouteInfo.fromJson(json['route']) : null,
    );
  }
}

/// Current location with extended info
class CurrentLocation {
  final double lat;
  final double lng;
  final double? speedKmh;
  final double? heading;
  final String? recordedAt;

  CurrentLocation({
    required this.lat,
    required this.lng,
    this.speedKmh,
    this.heading,
    this.recordedAt,
  });

  factory CurrentLocation.fromJson(Map<String, dynamic> json) {
    return CurrentLocation(
      lat: double.tryParse(json['lat']?.toString() ?? '0') ?? 0.0,
      lng: double.tryParse(json['lng']?.toString() ?? '0') ?? 0.0,
      speedKmh: double.tryParse(json['speedKmh']?.toString() ?? ''),
      heading: double.tryParse(json['heading']?.toString() ?? ''),
      recordedAt: json['recordedAt'],
    );
  }
}

/// Route information
class RouteInfo {
  final String? pickupLocation;
  final String? dropoffLocation;
  final String? nextStopEta;

  RouteInfo({this.pickupLocation, this.dropoffLocation, this.nextStopEta});

  factory RouteInfo.fromJson(Map<String, dynamic> json) {
    return RouteInfo(
      pickupLocation: json['pickupLocation'],
      dropoffLocation: json['dropoffLocation'],
      nextStopEta: json['nextStopEta'],
    );
  }
}

/// Absence data from report absence response
class AbsenceData {
  final String occurrenceId;
  final String studentId;
  final String reason;
  final String status;
  final String createdAt;

  AbsenceData({
    required this.occurrenceId,
    required this.studentId,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  factory AbsenceData.fromJson(Map<String, dynamic> json) {
    return AbsenceData(
      occurrenceId: json['occurrenceId'] ?? '',
      studentId: json['studentId'] ?? '',
      reason: json['reason'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
}

/// ============================================================
/// COMMON MODELS
/// ============================================================

/// Bus information
class BusInfo {
  final String id;
  final String? plateNumber;
  final int? capacity;

  BusInfo({required this.id, this.plateNumber, this.capacity});

  factory BusInfo.fromJson(Map<String, dynamic> json) {
    return BusInfo(
      id: json['id'] ?? '',
      plateNumber: json['plateNumber'],
      capacity: json['capacity'],
    );
  }
}

/// Driver information
class DriverInfo {
  final String id;
  final String name;
  final String? phone;
  final String? avatar;

  DriverInfo({required this.id, required this.name, this.phone, this.avatar});

  factory DriverInfo.fromJson(Map<String, dynamic> json) {
    return DriverInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'],
      avatar: json['avatar'],
    );
  }
}

/// Location information
class LocationInfo {
  final double lat;
  final double lng;
  final String? recordedAt;

  LocationInfo({required this.lat, required this.lng, this.recordedAt});

  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    return LocationInfo(
      lat: double.tryParse(json['lat']?.toString() ?? '0') ?? 0.0,
      lng: double.tryParse(json['lng']?.toString() ?? '0') ?? 0.0,
      recordedAt: json['recordedAt'],
    );
  }
}

/// ============================================================
/// REQUEST MODELS
/// ============================================================

/// Request body for report absence
class ReportAbsenceRequest {
  final String reason;

  ReportAbsenceRequest({required this.reason});

  Map<String, dynamic> toJson() {
    return {'reason': reason};
  }
}
