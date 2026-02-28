import 'package:flutter_test/flutter_test.dart';
import 'package:kidsero_parent/features/rides/models/api_models.dart';

void main() {
  group('RouteStop', () {
    test('should parse valid coordinates correctly', () {
      final stop = RouteStop(
        id: '1',
        name: 'Stop 1',
        address: 'Address 1',
        lat: '30.0444',
        lng: '31.2357',
        stopOrder: 1,
      );

      expect(stop.latitudeValue, 30.0444);
      expect(stop.longitudeValue, 31.2357);
      expect(stop.hasValidCoordinates, true);
    });

    test('should return null for invalid latitude', () {
      final stop = RouteStop(
        id: '1',
        name: 'Stop 1',
        address: 'Address 1',
        lat: 'invalid',
        lng: '31.2357',
        stopOrder: 1,
      );

      expect(stop.latitudeValue, null);
      expect(stop.hasValidCoordinates, false);
    });

    test('should return null for out of range latitude', () {
      final stop = RouteStop(
        id: '1',
        name: 'Stop 1',
        address: 'Address 1',
        lat: '91.0',
        lng: '31.2357',
        stopOrder: 1,
      );

      expect(stop.latitudeValue, null);
      expect(stop.hasValidCoordinates, false);
    });

    test('should return null for out of range longitude', () {
      final stop = RouteStop(
        id: '1',
        name: 'Stop 1',
        address: 'Address 1',
        lat: '30.0444',
        lng: '181.0',
        stopOrder: 1,
      );

      expect(stop.longitudeValue, null);
      expect(stop.hasValidCoordinates, false);
    });

    test('should parse from JSON correctly', () {
      final json = {
        'id': '1',
        'name': 'Stop 1',
        'address': 'Address 1',
        'lat': 30.0444,
        'lng': 31.2357,
        'stopOrder': 1,
      };

      final stop = RouteStop.fromJson(json);

      expect(stop.id, '1');
      expect(stop.name, 'Stop 1');
      expect(stop.latitudeValue, 30.0444);
      expect(stop.longitudeValue, 31.2357);
    });
  });

  group('PickupPoint', () {
    test('should parse valid coordinates correctly', () {
      final point = PickupPoint(
        id: '1',
        name: 'Pickup 1',
        address: 'Address 1',
        lat: '30.0444',
        lng: '31.2357',
      );

      expect(point.latitudeValue, 30.0444);
      expect(point.longitudeValue, 31.2357);
      expect(point.hasValidCoordinates, true);
    });

    test('should return null for invalid coordinates', () {
      final point = PickupPoint(
        id: '1',
        name: 'Pickup 1',
        address: 'Address 1',
        lat: 'invalid',
        lng: 'invalid',
      );

      expect(point.latitudeValue, null);
      expect(point.longitudeValue, null);
      expect(point.hasValidCoordinates, false);
    });
  });

  group('TrackingBus', () {
    test('should parse valid current location', () {
      final bus = TrackingBus(
        id: '1',
        busNumber: 'BUS-001',
        plateNumber: 'ABC-123',
        currentLocation: {
          'lat': 30.0444,
          'lng': 31.2357,
        },
      );

      expect(bus.currentLatitude, 30.0444);
      expect(bus.currentLongitude, 31.2357);
      expect(bus.hasValidCurrentLocation, true);
    });

    test('should handle latitude/longitude keys', () {
      final bus = TrackingBus(
        id: '1',
        busNumber: 'BUS-001',
        plateNumber: 'ABC-123',
        currentLocation: {
          'latitude': 30.0444,
          'longitude': 31.2357,
        },
      );

      expect(bus.currentLatitude, 30.0444);
      expect(bus.currentLongitude, 31.2357);
      expect(bus.hasValidCurrentLocation, true);
    });

    test('should return null for missing location', () {
      final bus = TrackingBus(
        id: '1',
        busNumber: 'BUS-001',
        plateNumber: 'ABC-123',
        currentLocation: null,
      );

      expect(bus.currentLatitude, null);
      expect(bus.currentLongitude, null);
      expect(bus.hasValidCurrentLocation, false);
    });

    test('should return null for invalid coordinates', () {
      final bus = TrackingBus(
        id: '1',
        busNumber: 'BUS-001',
        plateNumber: 'ABC-123',
        currentLocation: {
          'lat': 'invalid',
          'lng': 'invalid',
        },
      );

      expect(bus.currentLatitude, null);
      expect(bus.currentLongitude, null);
      expect(bus.hasValidCurrentLocation, false);
    });

    test('should validate coordinate ranges', () {
      final bus = TrackingBus(
        id: '1',
        busNumber: 'BUS-001',
        plateNumber: 'ABC-123',
        currentLocation: {
          'lat': 91.0,
          'lng': 181.0,
        },
      );

      expect(bus.currentLatitude, null);
      expect(bus.currentLongitude, null);
      expect(bus.hasValidCurrentLocation, false);
    });
  });

  group('TrackingRoute', () {
    test('should sort stops by stopOrder', () {
      final route = TrackingRoute(
        id: '1',
        name: 'Route 1',
        stops: [
          RouteStop(
            id: '3',
            name: 'Stop 3',
            address: 'Address 3',
            lat: '30.0444',
            lng: '31.2357',
            stopOrder: 3,
          ),
          RouteStop(
            id: '1',
            name: 'Stop 1',
            address: 'Address 1',
            lat: '30.0444',
            lng: '31.2357',
            stopOrder: 1,
          ),
          RouteStop(
            id: '2',
            name: 'Stop 2',
            address: 'Address 2',
            lat: '30.0444',
            lng: '31.2357',
            stopOrder: 2,
          ),
        ],
      );

      final sorted = route.sortedStops;
      expect(sorted[0].stopOrder, 1);
      expect(sorted[1].stopOrder, 2);
      expect(sorted[2].stopOrder, 3);
    });

    test('should filter valid stops', () {
      final route = TrackingRoute(
        id: '1',
        name: 'Route 1',
        stops: [
          RouteStop(
            id: '1',
            name: 'Stop 1',
            address: 'Address 1',
            lat: '30.0444',
            lng: '31.2357',
            stopOrder: 1,
          ),
          RouteStop(
            id: '2',
            name: 'Stop 2',
            address: 'Address 2',
            lat: 'invalid',
            lng: 'invalid',
            stopOrder: 2,
          ),
        ],
      );

      final valid = route.validStops;
      expect(valid.length, 1);
      expect(valid[0].id, '1');
    });

    test('should get sorted valid stops', () {
      final route = TrackingRoute(
        id: '1',
        name: 'Route 1',
        stops: [
          RouteStop(
            id: '3',
            name: 'Stop 3',
            address: 'Address 3',
            lat: '30.0444',
            lng: '31.2357',
            stopOrder: 3,
          ),
          RouteStop(
            id: '2',
            name: 'Stop 2',
            address: 'Address 2',
            lat: 'invalid',
            lng: 'invalid',
            stopOrder: 2,
          ),
          RouteStop(
            id: '1',
            name: 'Stop 1',
            address: 'Address 1',
            lat: '30.0444',
            lng: '31.2357',
            stopOrder: 1,
          ),
        ],
      );

      final sortedValid = route.sortedValidStops;
      expect(sortedValid.length, 2);
      expect(sortedValid[0].stopOrder, 1);
      expect(sortedValid[1].stopOrder, 3);
    });
  });

  group('RideTrackingData', () {
    test('should check if has valid route', () {
      final data = RideTrackingData(
        occurrence: RideOccurrence(id: '1', date: '2024-01-01', status: 'active'),
        ride: RideInfo(id: '1', name: 'Ride 1', type: 'pickup'),
        bus: TrackingBus(
          id: '1',
          busNumber: 'BUS-001',
          plateNumber: 'ABC-123',
        ),
        driver: DriverInfo(id: '1', name: 'Driver 1', phone: '1234567890'),
        route: TrackingRoute(
          id: '1',
          name: 'Route 1',
          stops: [
            RouteStop(
              id: '1',
              name: 'Stop 1',
              address: 'Address 1',
              lat: '30.0444',
              lng: '31.2357',
              stopOrder: 1,
            ),
          ],
        ),
        children: [],
      );

      expect(data.hasValidRoute, true);
    });

    test('should return false for empty route', () {
      final data = RideTrackingData(
        occurrence: RideOccurrence(id: '1', date: '2024-01-01', status: 'active'),
        ride: RideInfo(id: '1', name: 'Ride 1', type: 'pickup'),
        bus: TrackingBus(
          id: '1',
          busNumber: 'BUS-001',
          plateNumber: 'ABC-123',
        ),
        driver: DriverInfo(id: '1', name: 'Driver 1', phone: '1234567890'),
        route: TrackingRoute(id: '1', name: 'Route 1', stops: []),
        children: [],
      );

      expect(data.hasValidRoute, false);
    });

    test('should check if has bus location', () {
      final data = RideTrackingData(
        occurrence: RideOccurrence(id: '1', date: '2024-01-01', status: 'active'),
        ride: RideInfo(id: '1', name: 'Ride 1', type: 'pickup'),
        bus: TrackingBus(
          id: '1',
          busNumber: 'BUS-001',
          plateNumber: 'ABC-123',
          currentLocation: {
            'lat': 30.0444,
            'lng': 31.2357,
          },
        ),
        driver: DriverInfo(id: '1', name: 'Driver 1', phone: '1234567890'),
        route: TrackingRoute(id: '1', name: 'Route 1', stops: []),
        children: [],
      );

      expect(data.hasBusLocation, true);
    });

    test('should get valid pickup points', () {
      final data = RideTrackingData(
        occurrence: RideOccurrence(id: '1', date: '2024-01-01', status: 'active'),
        ride: RideInfo(id: '1', name: 'Ride 1', type: 'pickup'),
        bus: TrackingBus(
          id: '1',
          busNumber: 'BUS-001',
          plateNumber: 'ABC-123',
        ),
        driver: DriverInfo(id: '1', name: 'Driver 1', phone: '1234567890'),
        route: TrackingRoute(id: '1', name: 'Route 1', stops: []),
        children: [
          TrackingChild(
            id: '1',
            status: 'pending',
            pickupTime: '08:00',
            child: ChildInfo(
              id: 'child1',
              name: 'Child 1',
              grade: 'Grade 1',
              classroom: 'Class A',
              organization: OrganizationInfo(id: '1', name: 'Org 1'),
            ),
            pickupPoint: PickupPoint(
              id: '1',
              name: 'Pickup 1',
              address: 'Address 1',
              lat: '30.0444',
              lng: '31.2357',
            ),
          ),
          TrackingChild(
            id: '2',
            status: 'pending',
            pickupTime: '08:00',
            child: ChildInfo(
              id: 'child2',
              name: 'Child 2',
              grade: 'Grade 1',
              classroom: 'Class A',
              organization: OrganizationInfo(id: '1', name: 'Org 1'),
            ),
            pickupPoint: PickupPoint(
              id: '2',
              name: 'Pickup 2',
              address: 'Address 2',
              lat: 'invalid',
              lng: 'invalid',
            ),
          ),
        ],
      );

      final validPoints = data.validPickupPoints;
      expect(validPoints.length, 1);
      expect(validPoints[0].id, '1');
    });

    test('should find child pickup point by ID', () {
      final data = RideTrackingData(
        occurrence: RideOccurrence(id: '1', date: '2024-01-01', status: 'active'),
        ride: RideInfo(id: '1', name: 'Ride 1', type: 'pickup'),
        bus: TrackingBus(
          id: '1',
          busNumber: 'BUS-001',
          plateNumber: 'ABC-123',
        ),
        driver: DriverInfo(id: '1', name: 'Driver 1', phone: '1234567890'),
        route: TrackingRoute(id: '1', name: 'Route 1', stops: []),
        children: [
          TrackingChild(
            id: '1',
            status: 'pending',
            pickupTime: '08:00',
            child: ChildInfo(
              id: 'child1',
              name: 'Child 1',
              grade: 'Grade 1',
              classroom: 'Class A',
              organization: OrganizationInfo(id: '1', name: 'Org 1'),
            ),
            pickupPoint: PickupPoint(
              id: '1',
              name: 'Pickup 1',
              address: 'Address 1',
              lat: '30.0444',
              lng: '31.2357',
            ),
          ),
        ],
      );

      final point = data.getChildPickupPoint('child1');
      expect(point, isNotNull);
      expect(point!.id, '1');
    });

    test('should return null for non-existent child', () {
      final data = RideTrackingData(
        occurrence: RideOccurrence(id: '1', date: '2024-01-01', status: 'active'),
        ride: RideInfo(id: '1', name: 'Ride 1', type: 'pickup'),
        bus: TrackingBus(
          id: '1',
          busNumber: 'BUS-001',
          plateNumber: 'ABC-123',
        ),
        driver: DriverInfo(id: '1', name: 'Driver 1', phone: '1234567890'),
        route: TrackingRoute(id: '1', name: 'Route 1', stops: []),
        children: [],
      );

      final point = data.getChildPickupPoint('nonexistent');
      expect(point, isNull);
    });
  });
}
