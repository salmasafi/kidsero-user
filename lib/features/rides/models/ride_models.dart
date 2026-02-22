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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plateNumber': plateNumber,
      'capacity': capacity,
    };
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'avatar': avatar,
    };
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
/// NEW API RESPONSE MODELS
/// ============================================================

/// Response for GET /api/users/rides/child/{childId} - Single child today's rides
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

/// Data structure for single child today's rides
class ChildTodayRidesData {
  final ChildInfo child;
  final String type; // "today"
  final String date;
  final List<RideOccurrence> morning;
  final List<RideOccurrence> afternoon;
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
      morning: (json['morning'] as List<dynamic>?)
          ?.map((i) => RideOccurrence.fromJson(i))
          .toList() ?? [],
      afternoon: (json['afternoon'] as List<dynamic>?)
          ?.map((i) => RideOccurrence.fromJson(i))
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
}

/// Response for GET /api/users/rides/children - Children with all rides
class ChildrenWithAllRidesResponse {
  final bool success;
  final ChildrenWithAllRidesData data;

  ChildrenWithAllRidesResponse({required this.success, required this.data});

  factory ChildrenWithAllRidesResponse.fromJson(Map<String, dynamic> json) {
    return ChildrenWithAllRidesResponse(
      success: json['success'] ?? false,
      data: ChildrenWithAllRidesData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
    };
  }
}

/// Data structure for children with all rides
class ChildrenWithAllRidesData {
  final List<ChildWithAllRides> children;
  final List<OrganizationWithChildren> byOrganization;
  final int totalChildren;

  ChildrenWithAllRidesData({
    required this.children,
    required this.byOrganization,
    required this.totalChildren,
  });

  factory ChildrenWithAllRidesData.fromJson(Map<String, dynamic> json) {
    return ChildrenWithAllRidesData(
      children: (json['children'] as List<dynamic>?)
          ?.map((i) => ChildWithAllRides.fromJson(i))
          .toList() ?? [],
      byOrganization: (json['byOrganization'] as List<dynamic>?)
          ?.map((i) => OrganizationWithChildren.fromJson(i))
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

/// Child with complete ride information
class ChildWithAllRides {
  final String id;
  final String name;
  final String avatar;
  final String grade;
  final String classroom;
  final String code;
  final OrganizationInfo organization;
  final List<ChildRide> rides;

  ChildWithAllRides({
    required this.id,
    required this.name,
    required this.avatar,
    required this.grade,
    required this.classroom,
    required this.code,
    required this.organization,
    required this.rides,
  });

  factory ChildWithAllRides.fromJson(Map<String, dynamic> json) {
    return ChildWithAllRides(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      avatar: json['avatar'] ?? '',
      grade: json['grade'] ?? '',
      classroom: json['classroom'] ?? '',
      code: json['code'] ?? '',
      organization: OrganizationInfo.fromJson(json['organization'] ?? {}),
      rides: (json['rides'] as List<dynamic>?)
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

/// Organization with children
class OrganizationWithChildren {
  final OrganizationInfo organization;
  final List<ChildWithAllRides> children;

  OrganizationWithChildren({
    required this.organization,
    required this.children,
  });

  factory OrganizationWithChildren.fromJson(Map<String, dynamic> json) {
    return OrganizationWithChildren(
      organization: OrganizationInfo.fromJson(json['organization'] ?? {}),
      children: (json['children'] as List<dynamic>?)
          ?.map((i) => ChildWithAllRides.fromJson(i))
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

/// Response for GET /api/users/rides/upcoming - Upcoming rides grouped by date
class UpcomingRidesGroupedResponse {
  final bool success;
  final UpcomingRidesData data;

  UpcomingRidesGroupedResponse({required this.success, required this.data});

  factory UpcomingRidesGroupedResponse.fromJson(Map<String, dynamic> json) {
    return UpcomingRidesGroupedResponse(
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

/// Data structure for upcoming rides
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
      upcomingRides: (json['upcomingRides'] as List<dynamic>?)
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

/// Rides for a specific day
class UpcomingDayRides {
  final String date;
  final String dayName;
  final List<UpcomingRideInfo> rides;

  UpcomingDayRides({
    required this.date,
    required this.dayName,
    required this.rides,
  });

  factory UpcomingDayRides.fromJson(Map<String, dynamic> json) {
    return UpcomingDayRides(
      date: json['date'] ?? '',
      dayName: json['dayName'] ?? '',
      rides: (json['rides'] as List<dynamic>?)
          ?.map((i) => UpcomingRideInfo.fromJson(i))
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

/// Basic upcoming ride information
class UpcomingRideInfo {
  final String occurrenceId;
  final RideBasicInfo ride;
  final ChildBasicInfo child;
  final String pickupTime;
  final String pickupPointName;

  UpcomingRideInfo({
    required this.occurrenceId,
    required this.ride,
    required this.child,
    required this.pickupTime,
    required this.pickupPointName,
  });

  factory UpcomingRideInfo.fromJson(Map<String, dynamic> json) {
    return UpcomingRideInfo(
      occurrenceId: json['occurrenceId'] ?? '',
      ride: RideBasicInfo.fromJson(json['ride'] ?? {}),
      child: ChildBasicInfo.fromJson(json['child'] ?? {}),
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

/// Response for GET /api/users/rides/child/{childId}/summary - NEW API
class NewRideSummaryResponse {
  final bool success;
  final RideSummaryData data;

  NewRideSummaryResponse({required this.success, required this.data});

  factory NewRideSummaryResponse.fromJson(Map<String, dynamic> json) {
    return NewRideSummaryResponse(
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

/// Ride summary data
class RideSummaryData {
  final ChildBasicInfo child;
  final NewSummaryPeriod period;
  final RideSummaryStats summary;

  RideSummaryData({
    required this.child,
    required this.period,
    required this.summary,
  });

  factory RideSummaryData.fromJson(Map<String, dynamic> json) {
    return RideSummaryData(
      child: ChildBasicInfo.fromJson(json['child'] ?? {}),
      period: NewSummaryPeriod.fromJson(json['period'] ?? {}),
      summary: RideSummaryStats.fromJson(json['summary'] ?? {}),
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

/// Summary period information - NEW API
class NewSummaryPeriod {
  final int month;
  final int year;
  final String monthName;

  NewSummaryPeriod({
    required this.month,
    required this.year,
    required this.monthName,
  });

  factory NewSummaryPeriod.fromJson(Map<String, dynamic> json) {
    return NewSummaryPeriod(
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

/// Ride summary statistics
class RideSummaryStats {
  final int total;
  final int morning;
  final int afternoon;
  final StatusBreakdown byStatus;
  final int attendanceRate;

  RideSummaryStats({
    required this.total,
    required this.morning,
    required this.afternoon,
    required this.byStatus,
    required this.attendanceRate,
  });

  factory RideSummaryStats.fromJson(Map<String, dynamic> json) {
    return RideSummaryStats(
      total: json['total'] ?? 0,
      morning: json['morning'] ?? 0,
      afternoon: json['afternoon'] ?? 0,
      byStatus: StatusBreakdown.fromJson(json['byStatus'] ?? {}),
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

/// Status breakdown for rides
class StatusBreakdown {
  final int completed;
  final int absent;
  final int excused;
  final int pending;

  StatusBreakdown({
    required this.completed,
    required this.absent,
    required this.excused,
    required this.pending,
  });

  factory StatusBreakdown.fromJson(Map<String, dynamic> json) {
    return StatusBreakdown(
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

/// Response for GET /api/users/rides/tracking/{childId} - NEW API
class NewRideTrackingResponse {
  final bool success;
  final RideTrackingData data;

  NewRideTrackingResponse({required this.success, required this.data});

  factory NewRideTrackingResponse.fromJson(Map<String, dynamic> json) {
    return NewRideTrackingResponse(
      success: json['success'] ?? false,
      data: RideTrackingData.fromJson(json['data'] ?? {}),
    );
  }
}

/// Ride tracking data
class RideTrackingData {
  final RideOccurrence occurrence;
  final RideBasicInfo ride;
  final BusInfo bus;
  final DriverInfo driver;
  final NewRouteInfo route;
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
      ride: RideBasicInfo.fromJson(json['ride'] ?? {}),
      bus: BusInfo.fromJson(json['bus'] ?? {}),
      driver: DriverInfo.fromJson(json['driver'] ?? {}),
      route: NewRouteInfo.fromJson(json['route'] ?? {}),
      children: (json['children'] as List<dynamic>?)
          ?.map((i) => TrackingChild.fromJson(i))
          .toList() ?? [],
    );
  }
}

/// ============================================================
/// ENHANCED MODELS
/// ============================================================

/// Child information
class ChildInfo {
  final String id;
  final String name;
  final String avatar;
  final String grade;
  final String classroom;
  final OrganizationInfo organization;

  ChildInfo({
    required this.id,
    required this.name,
    required this.avatar,
    required this.grade,
    required this.classroom,
    required this.organization,
  });

  factory ChildInfo.fromJson(Map<String, dynamic> json) {
    return ChildInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      avatar: json['avatar'] ?? '',
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

/// Basic child information
class ChildBasicInfo {
  final String id;
  final String name;
  final String avatar;

  ChildBasicInfo({
    required this.id,
    required this.name,
    required this.avatar,
  });

  factory ChildBasicInfo.fromJson(Map<String, dynamic> json) {
    return ChildBasicInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      avatar: json['avatar'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
    };
  }
}

/// Organization information
class OrganizationInfo {
  final String id;
  final String name;
  final String? logo;

  OrganizationInfo({
    required this.id,
    required this.name,
    this.logo,
  });

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

/// Ride occurrence (specific instance of a ride)
class RideOccurrence {
  final String occurrenceId;
  final String date;
  final String status;
  final String? startedAt;
  final String? completedAt;
  final String? busLocation;
  final RideBasicInfo ride;
  final StudentStatus studentStatus;
  final BusInfo bus;
  final DriverInfo driver;
  final PickupPoint pickupPoint;

  RideOccurrence({
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

  factory RideOccurrence.fromJson(Map<String, dynamic> json) {
    return RideOccurrence(
      occurrenceId: json['occurrenceId'] ?? '',
      date: json['date'] ?? '',
      status: json['status'] ?? '',
      startedAt: json['startedAt'],
      completedAt: json['completedAt'],
      busLocation: json['busLocation'],
      ride: RideBasicInfo.fromJson(json['ride'] ?? {}),
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
}

/// Student status for ride occurrence
class StudentStatus {
  final String id;
  final String status;
  final String? pickedUpAt;
  final String? droppedOffAt;
  final String pickupTime;
  final String? excuseReason;

  StudentStatus({
    required this.id,
    required this.status,
    this.pickedUpAt,
    this.droppedOffAt,
    required this.pickupTime,
    this.excuseReason,
  });

  factory StudentStatus.fromJson(Map<String, dynamic> json) {
    return StudentStatus(
      id: json['id'] ?? '',
      status: json['status'] ?? '',
      pickedUpAt: json['pickedUpAt'],
      droppedOffAt: json['droppedOffAt'],
      pickupTime: json['pickupTime'] ?? '',
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

/// Basic ride information
class RideBasicInfo {
  final String id;
  final String name;
  final String type;

  RideBasicInfo({
    required this.id,
    required this.name,
    required this.type,
  });

  factory RideBasicInfo.fromJson(Map<String, dynamic> json) {
    return RideBasicInfo(
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

/// Child ride (from children with all rides)
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

/// Pickup point information
class PickupPoint {
  final String id;
  final String name;
  final String address;
  final double lat;
  final double lng;

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
      lat: double.tryParse(json['lat']?.toString() ?? '0') ?? 0.0,
      lng: double.tryParse(json['lng']?.toString() ?? '0') ?? 0.0,
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

/// Route information for tracking - NEW API
class NewRouteInfo {
  final String id;
  final String name;
  final List<RouteStop> stops;

  NewRouteInfo({
    required this.id,
    required this.name,
    required this.stops,
  });

  factory NewRouteInfo.fromJson(Map<String, dynamic> json) {
    return NewRouteInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      stops: (json['stops'] as List<dynamic>?)
          ?.map((i) => RouteStop.fromJson(i))
          .toList() ?? [],
    );
  }
}

/// Route stop
class RouteStop {
  final String id;
  final String name;
  final String address;
  final double lat;
  final double lng;
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
      lat: double.tryParse(json['lat']?.toString() ?? '0') ?? 0.0,
      lng: double.tryParse(json['lng']?.toString() ?? '0') ?? 0.0,
      stopOrder: json['stopOrder'] ?? 0,
    );
  }
}

/// Tracking child information
class TrackingChild {
  final String id;
  final String status;
  final String? pickedUpAt;
  final String? droppedOffAt;
  final String pickupTime;
  final String? excuseReason;
  final ChildBasicInfo child;
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
      child: ChildBasicInfo.fromJson(json['child'] ?? {}),
      pickupPoint: PickupPoint.fromJson(json['pickupPoint'] ?? {}),
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
