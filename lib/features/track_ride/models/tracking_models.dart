// lib/features/track_ride/models/tracking_models.dart

class TrackingResponse {
  final bool success;
  final TrackingData data;

  TrackingResponse({required this.success, required this.data});

  factory TrackingResponse.fromJson(Map<String, dynamic> json) {
    return TrackingResponse(
      success: json['success'],
      data: TrackingData.fromJson(json['data']),
    );
  }
}

class TrackingData {
  final Occurrence occurrence;
  final RideInfo ride;
  final BusInfo bus;
  final DriverInfo driver;
  final RouteInfo route;
  final List<ChildOnRide> children;

  TrackingData({
    required this.occurrence,
    required this.ride,
    required this.bus,
    required this.driver,
    required this.route,
    required this.children,
  });

  factory TrackingData.fromJson(Map<String, dynamic> json) {
    return TrackingData(
      occurrence: Occurrence.fromJson(json['occurrence']),
      ride: RideInfo.fromJson(json['ride']),
      bus: BusInfo.fromJson(json['bus']),
      driver: DriverInfo.fromJson(json['driver']),
      route: RouteInfo.fromJson(json['route']),
      children: (json['children'] as List)
          .map((e) => ChildOnRide.fromJson(e))
          .toList(),
    );
  }
}

class Occurrence {
  final String id;
  final String status; // e.g., "in_progress"
  final String? startedAt;

  Occurrence({required this.id, required this.status, this.startedAt});

  factory Occurrence.fromJson(Map<String, dynamic> json) {
    return Occurrence(
      id: json['id'],
      status: json['status'],
      startedAt: json['startedAt'],
    );
  }
}

class RideInfo {
  final String id;
  final String name;
  final String type;

  RideInfo({required this.id, required this.name, required this.type});

  factory RideInfo.fromJson(Map<String, dynamic> json) {
    return RideInfo(
      id: json['id'],
      name: json['name'],
      type: json['type'],
    );
  }
}

class BusInfo {
  final String busNumber;
  final String plateNumber;
  final LocationInfo currentLocation;

  BusInfo({
    required this.busNumber,
    required this.plateNumber,
    required this.currentLocation,
  });

  factory BusInfo.fromJson(Map<String, dynamic> json) {
    return BusInfo(
      busNumber: json['busNumber'] ?? 'N/A',
      plateNumber: json['plateNumber'] ?? 'N/A',
      currentLocation: LocationInfo.fromJson(json['currentLocation']),
    );
  }
}

class LocationInfo {
  final double lat;
  final double lng;

  LocationInfo({required this.lat, required this.lng});

  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    return LocationInfo(
      lat: double.tryParse(json['lat'].toString()) ?? 0.0,
      lng: double.tryParse(json['lng'].toString()) ?? 0.0,
    );
  }
}

class DriverInfo {
  final String name;
  final String phone;
  final String? avatar;

  DriverInfo({required this.name, required this.phone, this.avatar});

  factory DriverInfo.fromJson(Map<String, dynamic> json) {
    return DriverInfo(
      name: json['name'] ?? 'Unknown',
      phone: json['phone'] ?? '',
      avatar: json['avatar'],
    );
  }
}

class RouteInfo {
  final String name;
  final List<RouteStop> stops;

  RouteInfo({required this.name, required this.stops});

  factory RouteInfo.fromJson(Map<String, dynamic> json) {
    var list = json['stops'] as List;
    List<RouteStop> stopsList = list.map((i) => RouteStop.fromJson(i)).toList();
    // Ensure stops are ordered
    stopsList.sort((a, b) => a.stopOrder.compareTo(b.stopOrder));
    return RouteInfo(
      name: json['name'],
      stops: stopsList,
    );
  }
}

class RouteStop {
  final String id;
  final String name;
  final String address;
  final int stopOrder;

  RouteStop({
    required this.id,
    required this.name,
    required this.address,
    required this.stopOrder,
  });

  factory RouteStop.fromJson(Map<String, dynamic> json) {
    return RouteStop(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      stopOrder: json['stopOrder'] ?? 0,
    );
  }
}

class ChildOnRide {
  final String id;
  final String status; // "picked_up", "dropped_off", etc.
  final String? pickupTime;
  final PickupPoint? pickupPoint;
  final ChildInfo child;

  ChildOnRide({
    required this.id,
    required this.status,
    this.pickupTime,
    this.pickupPoint,
    required this.child,
  });

  factory ChildOnRide.fromJson(Map<String, dynamic> json) {
    return ChildOnRide(
      id: json['id'],
      status: json['status'],
      pickupTime: json['pickupTime'],
      pickupPoint: json['pickupPoint'] != null
          ? PickupPoint.fromJson(json['pickupPoint'])
          : null,
      child: ChildInfo.fromJson(json['child']),
    );
  }
}

class PickupPoint {
  final String id;
  final String name;

  PickupPoint({required this.id, required this.name});

  factory PickupPoint.fromJson(Map<String, dynamic> json) {
    return PickupPoint(id: json['id'], name: json['name']);
  }
}

class ChildInfo {
  final String name;
  final String? avatar;

  ChildInfo({required this.name, this.avatar});

  factory ChildInfo.fromJson(Map<String, dynamic> json) {
    return ChildInfo(name: json['name'], avatar: json['avatar']);
  }
}
