// lib/features/rides/models/ride_models.dart

class ChildrenRidesResponse {
  final bool success;
  final ChildrenData data;

  ChildrenRidesResponse({required this.success, required this.data});

  factory ChildrenRidesResponse.fromJson(Map<String, dynamic> json) {
    return ChildrenRidesResponse(
      success: json['success'],
      data: ChildrenData.fromJson(json['data']),
    );
  }
}

class ChildrenData {
  final List<Child> children;
  final int totalChildren;

  ChildrenData({required this.children, required this.totalChildren});

  factory ChildrenData.fromJson(Map<String, dynamic> json) {
    return ChildrenData(
      children: (json['children'] as List)
          .map((i) => Child.fromJson(i))
          .toList(),
      totalChildren: json['totalChildren'] ?? 0,
    );
  }
}

class Child {
  final String id;
  final String name;
  final String? avatar;
  final String? grade;
  final String? classroom;
  final Organization? organization;
  final List<Ride> rides;

  Child({
    required this.id,
    required this.name,
    this.avatar,
    this.grade,
    this.classroom,
    this.organization,
    required this.rides,
  });

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['id'],
      name: json['name'],
      avatar: json['avatar'],
      grade: json['grade'],
      classroom: json['classroom'],
      organization: json['organization'] != null
          ? Organization.fromJson(json['organization'])
          : null,
      rides: json['rides'] != null
          ? (json['rides'] as List).map((i) => Ride.fromJson(i)).toList()
          : [],
    );
  }
}

class Ride {
  final String id;
  final String name;
  final String type; // 'morning' or 'afternoon'
  final String frequency;
  final String pickupTime;
  final PickupPoint? pickupPoint;
  final Bus? bus;
  final Driver? driver;

  Ride({
    required this.id,
    required this.name,
    required this.type,
    required this.frequency,
    required this.pickupTime,
    this.pickupPoint,
    this.bus,
    this.driver,
  });

  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
      id: json['id'],
      name: json['name'],
      type: json['type'] ?? '',
      frequency: json['frequency'] ?? '',
      pickupTime: json['pickupTime'] ?? '',
      pickupPoint: json['pickupPoint'] != null
          ? PickupPoint.fromJson(json['pickupPoint'])
          : null,
      bus: json['bus'] != null ? Bus.fromJson(json['bus']) : null,
      driver: json['driver'] != null ? Driver.fromJson(json['driver']) : null,
    );
  }
}

class Organization {
  final String id;
  final String name;
  final String? logo;

  Organization({required this.id, required this.name, this.logo});

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'],
      name: json['name'],
      logo: json['logo'],
    );
  }
}

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
      id: json['id'],
      name: json['name'],
      address: json['address'],
      lat: double.tryParse(json['location']?['lat']?.toString() ?? '0') ?? 0.0,
      lng: double.tryParse(json['location']?['lng']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class Bus {
  final String id;
  final String busNumber;
  final String plateNumber;

  Bus({required this.id, required this.busNumber, required this.plateNumber});

  factory Bus.fromJson(Map<String, dynamic> json) {
    return Bus(
      id: json['id'],
      busNumber: json['busNumber'] ?? '',
      plateNumber: json['plateNumber'] ?? '',
    );
  }
}

class Driver {
  final String id;
  final String name;
  final String phone;
  final String? avatar;

  Driver({
    required this.id,
    required this.name,
    required this.phone,
    this.avatar,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'],
      name: json['name'],
      phone: json['phone'] ?? '',
      avatar: json['avatar'],
    );
  }
}
// features/rides/models/ride_models.dart

// ... (Keep your existing Child, Ride, Bus, Driver, Organization, PickupPoint models here) ...

// --- NEW MODELS FOR ACTIVE RIDES ---

class ActiveRidesResponse {
  final bool success;
  final List<ActiveRide> activeRides;

  ActiveRidesResponse({required this.success, required this.activeRides});

  factory ActiveRidesResponse.fromJson(Map<String, dynamic> json) {
    return ActiveRidesResponse(
      success: json['success'],
      activeRides: (json['data']['activeRides'] as List)
          .map((i) => ActiveRide.fromJson(i))
          .toList(),
    );
  }
}

class ActiveRide {
  final String occurrenceId;
  final String status;
  final String rideName;
  final String rideType;
  final String busNumber;
  final String driverName;
  final String? driverAvatar;
  final String childName;
  final String? childAvatar;
  final RideBusLocation currentLocation;

  ActiveRide({
    required this.occurrenceId,
    required this.status,
    required this.rideName,
    required this.rideType,
    required this.busNumber,
    required this.driverName,
    this.driverAvatar,
    required this.childName,
    this.childAvatar,
    required this.currentLocation,
  });

  factory ActiveRide.fromJson(Map<String, dynamic> json) {
    return ActiveRide(
      occurrenceId: json['occurrenceId'],
      status: json['child']['status'] ?? 'unknown',
      rideName: json['ride']['name'],
      rideType: json['ride']['type'],
      busNumber: json['bus']['busNumber'],
      currentLocation: RideBusLocation.fromJson(json['bus']['currentLocation']),
      driverName: json['driver']['name'],
      driverAvatar: json['driver']['avatar'],
      childName: json['child']['name'],
      childAvatar: json['child']['avatar'],
    );
  }
}

class RideBusLocation {
  final double lat;
  final double lng;

  RideBusLocation({required this.lat, required this.lng});

  factory RideBusLocation.fromJson(Map<String, dynamic> json) {
    return RideBusLocation(
      lat: double.tryParse(json['lat'].toString()) ?? 0.0,
      lng: double.tryParse(json['lng'].toString()) ?? 0.0,
    );
  }
}

// --- NEW MODELS FOR UPCOMING RIDES ---

class UpcomingRidesResponse {
  final bool success;
  final List<UpcomingDay> upcomingDays;

  UpcomingRidesResponse({required this.success, required this.upcomingDays});

  factory UpcomingRidesResponse.fromJson(Map<String, dynamic> json) {
    return UpcomingRidesResponse(
      success: json['success'],
      upcomingDays: (json['data']['upcomingRides'] as List)
          .map((i) => UpcomingDay.fromJson(i))
          .toList(),
    );
  }
}

class UpcomingDay {
  final String date;
  final String dayName;
  final List<UpcomingRide> rides;

  UpcomingDay({required this.date, required this.dayName, required this.rides});

  factory UpcomingDay.fromJson(Map<String, dynamic> json) {
    return UpcomingDay(
      date: json['date'],
      dayName: json['dayName'],
      rides: (json['rides'] as List).map((i) => UpcomingRide.fromJson(i)).toList(),
    );
  }
}

class UpcomingRide {
  final String occurrenceId;
  final String rideName;
  final String rideType;
  final String pickupTime;
  final String childName;
  final String? pickupPointName;

  UpcomingRide({
    required this.occurrenceId,
    required this.rideName,
    required this.rideType,
    required this.pickupTime,
    required this.childName,
    this.pickupPointName,
  });

  factory UpcomingRide.fromJson(Map<String, dynamic> json) {
    return UpcomingRide(
      occurrenceId: json['occurrenceId'],
      rideName: json['ride']['name'],
      rideType: json['ride']['type'],
      pickupTime: json['pickupTime'],
      childName: json['child']['name'],
      pickupPointName: json['pickupPointName'],
    );
  }
}