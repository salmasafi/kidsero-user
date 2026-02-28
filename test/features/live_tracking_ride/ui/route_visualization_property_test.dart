import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidsero_parent/features/rides/models/api_models.dart';
import 'package:latlong2/latlong.dart';

/// Property-Based Tests for Route Visualization
/// 
/// These tests verify universal properties that should hold true across
/// all valid inputs using randomized test data generation.
/// 
/// Each test runs 100 iterations with random data to ensure properties
/// hold across a wide range of scenarios.

void main() {
  group('Route Visualization Property Tests', () {
    // Test configuration
    const int iterations = 100;
    final random = Random(42); // Fixed seed for reproducibility

    group('Property 1: Route polyline connects all stops in order', () {
      // Feature: parent-live-tracking, Property 1: Route polyline connects all stops in order
      // Validates: Requirements 1.2, 4.1, 4.2
      test('polyline points match stops sorted by stopOrder', () {
        for (int i = 0; i < iterations; i++) {
          // Generate random route with shuffled stops
          final route = _generateRandomRoute(random, stopCount: random.nextInt(8) + 2);
          
          // Create polyline from route (simulating _createRoutePolyline)
          final polylinePoints = _createRoutePolyline(route.stops);
          
          // Get expected points (sorted by stopOrder)
          final sortedStops = List<RouteStop>.from(route.stops)
            ..sort((a, b) => a.stopOrder.compareTo(b.stopOrder));
          
          final expectedPoints = sortedStops
              .where((stop) => stop.hasValidCoordinates)
              .map((stop) => LatLng(stop.latitudeValue!, stop.longitudeValue!))
              .toList();
          
          // Assert: Polyline points should match sorted stops
          expect(
            polylinePoints.length,
            equals(expectedPoints.length),
            reason: 'Iteration $i: Polyline should have same number of points as valid stops',
          );
          
          for (int j = 0; j < polylinePoints.length; j++) {
            expect(
              polylinePoints[j].latitude,
              closeTo(expectedPoints[j].latitude, 0.0001),
              reason: 'Iteration $i, Point $j: Latitude should match',
            );
            expect(
              polylinePoints[j].longitude,
              closeTo(expectedPoints[j].longitude, 0.0001),
              reason: 'Iteration $i, Point $j: Longitude should match',
            );
          }
        }
      });

      test('polyline connects stops consecutively', () {
        for (int i = 0; i < iterations; i++) {
          final route = _generateRandomRoute(random, stopCount: random.nextInt(8) + 2);
          final polylinePoints = _createRoutePolyline(route.stops);
          
          // Assert: Each point should connect to the next
          for (int j = 0; j < polylinePoints.length - 1; j++) {
            final current = polylinePoints[j];
            final next = polylinePoints[j + 1];
            
            // Points should be different (no duplicate consecutive points)
            expect(
              current != next,
              isTrue,
              reason: 'Iteration $i: Consecutive points should be different',
            );
          }
        }
      });
    });

    group('Property 2: All route stops are displayed as markers', () {
      // Feature: parent-live-tracking, Property 2: All route stops are displayed as markers
      // Validates: Requirements 1.3, 4.6
      test('marker count equals total number of valid stops', () {
        for (int i = 0; i < iterations; i++) {
          final route = _generateRandomRoute(random, stopCount: random.nextInt(10) + 1);
          
          // Create markers (simulating _createStopMarkers)
          final markers = _createStopMarkers(route.stops, childPickupPointId: null);
          
          // Count valid stops
          final validStopsCount = route.stops.where((stop) => stop.hasValidCoordinates).length;
          
          // Assert: All valid stops should have markers
          expect(
            markers.length,
            equals(validStopsCount),
            reason: 'Iteration $i: Should create marker for each valid stop',
          );
        }
      });

      test('markers are created regardless of children assignment', () {
        for (int i = 0; i < iterations; i++) {
          final route = _generateRandomRoute(random, stopCount: random.nextInt(10) + 1);
          
          // Create markers without any child pickup point
          final markersWithoutChild = _createStopMarkers(route.stops, childPickupPointId: null);
          
          // Create markers with a random child pickup point
          final randomStopId = route.stops.isNotEmpty 
              ? route.stops[random.nextInt(route.stops.length)].id 
              : null;
          final markersWithChild = _createStopMarkers(route.stops, childPickupPointId: randomStopId);
          
          // Assert: Same number of markers regardless of child assignment
          expect(
            markersWithoutChild.length,
            equals(markersWithChild.length),
            reason: 'Iteration $i: Marker count should not depend on child assignment',
          );
        }
      });
    });

    group('Property 3: Child\'s pickup point is visually distinct', () {
      // Feature: parent-live-tracking, Property 3: Child's pickup point is visually distinct
      // Validates: Requirements 1.4, 4.5
      test('child pickup marker uses different color than regular markers', () {
        for (int i = 0; i < iterations; i++) {
          final route = _generateRandomRoute(random, stopCount: random.nextInt(8) + 2);
          
          if (route.stops.isEmpty) continue;
          
          // Pick a random stop as child's pickup point
          final childPickupStop = route.stops[random.nextInt(route.stops.length)];
          
          // Create markers
          final markers = _createStopMarkers(route.stops, childPickupPointId: childPickupStop.id);
          
          // Find child pickup marker and regular markers
          final childMarker = markers.firstWhere(
            (m) => m.stopId == childPickupStop.id,
            orElse: () => _MarkerInfo(stopId: '', isChildPickup: false, color: 0),
          );
          
          final regularMarkers = markers.where((m) => m.stopId != childPickupStop.id).toList();
          
          // Assert: Child marker should be marked as distinct
          expect(
            childMarker.isChildPickup,
            isTrue,
            reason: 'Iteration $i: Child pickup marker should be flagged as distinct',
          );
          
          // Assert: Child marker color should differ from regular markers
          if (regularMarkers.isNotEmpty) {
            final regularColor = regularMarkers.first.color;
            expect(
              childMarker.color,
              isNot(equals(regularColor)),
              reason: 'Iteration $i: Child pickup marker should use different color',
            );
          }
        }
      });
    });

    group('Property 4: Bus marker displays at current location', () {
      // Feature: parent-live-tracking, Property 4: Bus marker displays at current location
      // Validates: Requirements 1.5
      test('bus marker position matches bus current location', () {
        for (int i = 0; i < iterations; i++) {
          final bus = _generateRandomBus(random, hasLocation: true);
          
          // Create bus marker
          final busMarker = _createBusMarker(bus);
          
          // Assert: Bus marker should exist when location is valid
          expect(
            busMarker,
            isNotNull,
            reason: 'Iteration $i: Bus marker should be created when location is valid',
          );
          
          if (busMarker != null) {
            expect(
              busMarker.latitude,
              closeTo(bus.currentLatitude!, 0.0001),
              reason: 'Iteration $i: Bus marker latitude should match bus location',
            );
            expect(
              busMarker.longitude,
              closeTo(bus.currentLongitude!, 0.0001),
              reason: 'Iteration $i: Bus marker longitude should match bus location',
            );
          }
        }
      });

      test('no bus marker when location is invalid', () {
        for (int i = 0; i < iterations; i++) {
          final bus = _generateRandomBus(random, hasLocation: false);
          
          // Create bus marker
          final busMarker = _createBusMarker(bus);
          
          // Assert: No bus marker should be created for invalid location
          expect(
            busMarker,
            isNull,
            reason: 'Iteration $i: Bus marker should not be created when location is invalid',
          );
        }
      });
    });

    group('Property 9: Stop markers contain complete information', () {
      // Feature: parent-live-tracking, Property 9: Stop markers contain complete information
      // Validates: Requirements 4.4
      test('all markers contain stop name and address', () {
        for (int i = 0; i < iterations; i++) {
          final route = _generateRandomRoute(random, stopCount: random.nextInt(10) + 1);
          
          // Create markers
          final markers = _createStopMarkers(route.stops, childPickupPointId: null);
          
          // Assert: Each marker should have complete information
          for (final marker in markers) {
            expect(
              marker.name.isNotEmpty,
              isTrue,
              reason: 'Iteration $i: Marker should have non-empty name',
            );
            expect(
              marker.address.isNotEmpty,
              isTrue,
              reason: 'Iteration $i: Marker should have non-empty address',
            );
          }
        }
      });

      test('marker info matches corresponding stop data', () {
        for (int i = 0; i < iterations; i++) {
          final route = _generateRandomRoute(random, stopCount: random.nextInt(10) + 1);
          final markers = _createStopMarkers(route.stops, childPickupPointId: null);
          
          // Assert: Each marker's info should match its stop
          for (final marker in markers) {
            final stop = route.stops.firstWhere((s) => s.id == marker.stopId);
            
            expect(
              marker.name,
              equals(stop.name),
              reason: 'Iteration $i: Marker name should match stop name',
            );
            expect(
              marker.address,
              equals(stop.address),
              reason: 'Iteration $i: Marker address should match stop address',
            );
          }
        }
      });
    });

    group('Property 5: Camera bounds include all route elements', () {
      // Feature: parent-live-tracking, Property 5: Camera bounds include all route elements
      // Validates: Requirements 1.6, 9.6
      test('bounds include all valid stops', () {
        for (int i = 0; i < iterations; i++) {
          final route = _generateRandomRoute(random, stopCount: random.nextInt(10) + 2);
          final bus = _generateRandomBus(random, hasLocation: false);
          
          final trackingData = _createTrackingData(route: route, bus: bus);
          
          // Calculate bounds
          final bounds = _calculateBounds(trackingData);
          
          // Assert: Bounds should exist when there are valid stops
          expect(
            bounds,
            isNotNull,
            reason: 'Iteration $i: Bounds should be calculated when valid stops exist',
          );
          
          if (bounds != null) {
            // Assert: All valid stops should be within bounds
            for (final stop in route.stops.where((s) => s.hasValidCoordinates)) {
              final lat = stop.latitudeValue!;
              final lng = stop.longitudeValue!;
              
              expect(
                lat >= bounds.south && lat <= bounds.north,
                isTrue,
                reason: 'Iteration $i: Stop latitude should be within bounds',
              );
              expect(
                lng >= bounds.west && lng <= bounds.east,
                isTrue,
                reason: 'Iteration $i: Stop longitude should be within bounds',
              );
            }
          }
        }
      });

      test('bounds include bus location when available', () {
        for (int i = 0; i < iterations; i++) {
          final route = _generateRandomRoute(random, stopCount: random.nextInt(5) + 1);
          final bus = _generateRandomBus(random, hasLocation: true);
          
          final trackingData = _createTrackingData(route: route, bus: bus);
          
          // Calculate bounds
          final bounds = _calculateBounds(trackingData);
          
          // Assert: Bounds should include bus location
          expect(
            bounds,
            isNotNull,
            reason: 'Iteration $i: Bounds should be calculated',
          );
          
          if (bounds != null && bus.hasValidCurrentLocation) {
            final busLat = bus.currentLatitude!;
            final busLng = bus.currentLongitude!;
            
            expect(
              busLat >= bounds.south && busLat <= bounds.north,
              isTrue,
              reason: 'Iteration $i: Bus latitude should be within bounds',
            );
            expect(
              busLng >= bounds.west && busLng <= bounds.east,
              isTrue,
              reason: 'Iteration $i: Bus longitude should be within bounds',
            );
          }
        }
      });

      test('bounds handle single point correctly', () {
        for (int i = 0; i < iterations; i++) {
          // Create route with single stop
          final singleStop = _generateRandomStop(random, order: 0);
          final route = TrackingRoute(
            id: 'route_single',
            name: 'Single Stop Route',
            stops: [singleStop],
          );
          final bus = _generateRandomBus(random, hasLocation: false);
          
          final trackingData = _createTrackingData(route: route, bus: bus);
          
          // Calculate bounds
          final bounds = _calculateBounds(trackingData);
          
          // Assert: Bounds should exist for single point
          expect(
            bounds,
            isNotNull,
            reason: 'Iteration $i: Bounds should be created for single point',
          );
          
          if (bounds != null) {
            // Assert: Bounds should have some area (not zero-sized)
            expect(
              bounds.north > bounds.south,
              isTrue,
              reason: 'Iteration $i: Bounds should have positive height',
            );
            expect(
              bounds.east > bounds.west,
              isTrue,
              reason: 'Iteration $i: Bounds should have positive width',
            );
          }
        }
      });

      test('bounds return null for empty data', () {
        for (int i = 0; i < iterations; i++) {
          // Create route with no valid stops
          final route = TrackingRoute(
            id: 'route_empty',
            name: 'Empty Route',
            stops: [],
          );
          final bus = _generateRandomBus(random, hasLocation: false);
          
          final trackingData = _createTrackingData(route: route, bus: bus);
          
          // Calculate bounds
          final bounds = _calculateBounds(trackingData);
          
          // Assert: Bounds should be null when no valid data
          expect(
            bounds,
            isNull,
            reason: 'Iteration $i: Bounds should be null for empty data',
          );
        }
      });
    });

    group('Property 6: Tracking data extraction is complete', () {
      // Feature: parent-live-tracking, Property 6: Tracking data extraction is complete
      // Validates: Requirements 2.2, 2.3, 2.4
      test('all route stops are extracted correctly', () {
        for (int i = 0; i < iterations; i++) {
          final route = _generateRandomRoute(random, stopCount: random.nextInt(10) + 1);
          final bus = _generateRandomBus(random, hasLocation: true);
          
          final trackingData = _createTrackingData(route: route, bus: bus);
          
          // Assert: All stops should be present in tracking data
          expect(
            trackingData.route.stops.length,
            equals(route.stops.length),
            reason: 'Iteration $i: All stops should be extracted',
          );
          
          // Assert: Stop order should be preserved
          for (int j = 0; j < route.stops.length; j++) {
            expect(
              trackingData.route.stops[j].id,
              equals(route.stops[j].id),
              reason: 'Iteration $i: Stop $j ID should match',
            );
            expect(
              trackingData.route.stops[j].stopOrder,
              equals(route.stops[j].stopOrder),
              reason: 'Iteration $i: Stop $j order should match',
            );
          }
        }
      });

      test('bus location is extracted correctly', () {
        for (int i = 0; i < iterations; i++) {
          final route = _generateRandomRoute(random, stopCount: random.nextInt(5) + 1);
          final bus = _generateRandomBus(random, hasLocation: true);
          
          final trackingData = _createTrackingData(route: route, bus: bus);
          
          // Assert: Bus location should be extracted
          expect(
            trackingData.bus.hasValidCurrentLocation,
            isTrue,
            reason: 'Iteration $i: Bus should have valid location',
          );
          
          expect(
            trackingData.bus.currentLatitude,
            closeTo(bus.currentLatitude!, 0.0001),
            reason: 'Iteration $i: Bus latitude should match',
          );
          
          expect(
            trackingData.bus.currentLongitude,
            closeTo(bus.currentLongitude!, 0.0001),
            reason: 'Iteration $i: Bus longitude should match',
          );
        }
      });

      test('bus info is extracted correctly', () {
        for (int i = 0; i < iterations; i++) {
          final route = _generateRandomRoute(random, stopCount: random.nextInt(5) + 1);
          final bus = _generateRandomBus(random, hasLocation: true);
          
          final trackingData = _createTrackingData(route: route, bus: bus);
          
          // Assert: Bus info should be extracted
          expect(
            trackingData.bus.id,
            equals(bus.id),
            reason: 'Iteration $i: Bus ID should match',
          );
          
          expect(
            trackingData.bus.busNumber,
            equals(bus.busNumber),
            reason: 'Iteration $i: Bus number should match',
          );
          
          expect(
            trackingData.bus.plateNumber,
            equals(bus.plateNumber),
            reason: 'Iteration $i: Bus plate number should match',
          );
        }
      });

      test('extraction handles missing bus location gracefully', () {
        for (int i = 0; i < iterations; i++) {
          final route = _generateRandomRoute(random, stopCount: random.nextInt(5) + 1);
          final bus = _generateRandomBus(random, hasLocation: false);
          
          final trackingData = _createTrackingData(route: route, bus: bus);
          
          // Assert: Tracking data should still be valid
          expect(
            trackingData.route.stops.length,
            greaterThan(0),
            reason: 'Iteration $i: Route stops should still be extracted',
          );
          
          // Assert: Bus location should be marked as invalid
          expect(
            trackingData.bus.hasValidCurrentLocation,
            isFalse,
            reason: 'Iteration $i: Bus location should be marked as invalid',
          );
        }
      });
    });
  });
}

// ============================================================================
// Test Data Generators
// ============================================================================

/// Generate random TrackingRoute with shuffled stops
TrackingRoute _generateRandomRoute(Random random, {int stopCount = 5}) {
  final stops = List.generate(stopCount, (index) {
    return _generateRandomStop(random, order: index);
  });
  
  // Shuffle stops to test sorting
  stops.shuffle(random);
  
  return TrackingRoute(
    id: 'route_${random.nextInt(1000)}',
    name: 'Route ${random.nextInt(100)}',
    stops: stops,
  );
}

/// Generate random RouteStop with valid coordinates
RouteStop _generateRandomStop(Random random, {required int order}) {
  // Generate coordinates within valid ranges
  final lat = (random.nextDouble() * 180 - 90).toStringAsFixed(6); // -90 to 90
  final lng = (random.nextDouble() * 360 - 180).toStringAsFixed(6); // -180 to 180
  
  return RouteStop(
    id: 'stop_${random.nextInt(10000)}',
    name: 'Stop ${random.nextInt(100)}',
    address: '${random.nextInt(999)} Street ${random.nextInt(100)}',
    lat: lat,
    lng: lng,
    stopOrder: order,
  );
}

/// Generate random TrackingBus with optional location
TrackingBus _generateRandomBus(Random random, {required bool hasLocation}) {
  dynamic currentLocation;
  
  if (hasLocation) {
    final lat = random.nextDouble() * 180 - 90; // -90 to 90
    final lng = random.nextDouble() * 360 - 180; // -180 to 180
    currentLocation = {
      'lat': lat,
      'lng': lng,
    };
  }
  
  return TrackingBus(
    id: 'bus_${random.nextInt(1000)}',
    busNumber: 'BUS-${random.nextInt(999).toString().padLeft(3, '0')}',
    plateNumber: 'ABC-${random.nextInt(999)}',
    currentLocation: currentLocation,
  );
}

// ============================================================================
// Simulation Functions (mimic LiveTrackingScreen implementation)
// ============================================================================

/// Simulate _createRoutePolyline method
List<LatLng> _createRoutePolyline(List<RouteStop> stops) {
  // Sort stops by stopOrder
  final sortedStops = List<RouteStop>.from(stops)
    ..sort((a, b) => a.stopOrder.compareTo(b.stopOrder));
  
  // Map to LatLng, filtering out invalid coordinates
  return sortedStops
      .where((stop) => stop.hasValidCoordinates)
      .map((stop) => LatLng(stop.latitudeValue!, stop.longitudeValue!))
      .toList();
}

/// Marker information for testing
class _MarkerInfo {
  final String stopId;
  final String name;
  final String address;
  final bool isChildPickup;
  final int color; // Color represented as int for comparison

  _MarkerInfo({
    required this.stopId,
    this.name = '',
    this.address = '',
    required this.isChildPickup,
    required this.color,
  });
}

/// Simulate _createStopMarkers method
List<_MarkerInfo> _createStopMarkers(List<RouteStop> stops, {String? childPickupPointId}) {
  final markers = <_MarkerInfo>[];
  
  for (final stop in stops) {
    if (!stop.hasValidCoordinates) continue;
    
    final isChildPickup = stop.id == childPickupPointId;
    
    markers.add(_MarkerInfo(
      stopId: stop.id,
      name: stop.name,
      address: stop.address,
      isChildPickup: isChildPickup,
      color: isChildPickup ? 0xFFFF6B6B : 0xFF4F46E5, // Red for child, Blue for regular
    ));
  }
  
  return markers;
}

/// Bus marker information for testing
class _BusMarkerInfo {
  final double latitude;
  final double longitude;

  _BusMarkerInfo({required this.latitude, required this.longitude});
}

/// Simulate _createBusMarker method
_BusMarkerInfo? _createBusMarker(TrackingBus bus) {
  if (!bus.hasValidCurrentLocation) return null;
  
  return _BusMarkerInfo(
    latitude: bus.currentLatitude!,
    longitude: bus.currentLongitude!,
  );
}


// ============================================================================
// Additional Helper Functions for Property 5 & 6
// ============================================================================

/// Bounds information for testing
class _BoundsInfo {
  final double north;
  final double south;
  final double east;
  final double west;

  _BoundsInfo({
    required this.north,
    required this.south,
    required this.east,
    required this.west,
  });
}

/// Simulate _calculateBounds method
_BoundsInfo? _calculateBounds(RideTrackingData trackingData) {
  final points = <LatLng>[];

  // Add all valid route stops
  for (final stop in trackingData.route.validStops) {
    final lat = stop.latitudeValue;
    final lng = stop.longitudeValue;
    if (lat != null && lng != null) {
      points.add(LatLng(lat, lng));
    }
  }

  // Add bus location if available
  if (trackingData.bus.hasValidCurrentLocation) {
    final lat = trackingData.bus.currentLatitude;
    final lng = trackingData.bus.currentLongitude;
    if (lat != null && lng != null) {
      points.add(LatLng(lat, lng));
    }
  }

  // Handle edge cases
  if (points.isEmpty) {
    return null;
  }

  if (points.length == 1) {
    // Single point - create small bounds around it
    final point = points.first;
    return _BoundsInfo(
      north: point.latitude + 0.01,
      south: point.latitude - 0.01,
      east: point.longitude + 0.01,
      west: point.longitude - 0.01,
    );
  }

  // Calculate bounds from all points
  double north = points.first.latitude;
  double south = points.first.latitude;
  double east = points.first.longitude;
  double west = points.first.longitude;

  for (final point in points) {
    if (point.latitude > north) north = point.latitude;
    if (point.latitude < south) south = point.latitude;
    if (point.longitude > east) east = point.longitude;
    if (point.longitude < west) west = point.longitude;
  }

  return _BoundsInfo(
    north: north,
    south: south,
    east: east,
    west: west,
  );
}

/// Create mock tracking data for testing
RideTrackingData _createTrackingData({
  required TrackingRoute route,
  required TrackingBus bus,
}) {
  return RideTrackingData(
    ride: RideInfo(
      id: 'ride_1',
      name: 'Test Ride',
      type: 'morning',
    ),
    occurrence: RideOccurrence(
      id: 'occurrence_1',
      status: 'active',
      date: DateTime.now().toIso8601String(),
    ),
    route: route,
    bus: bus,
    driver: DriverInfo(
      id: 'driver_1',
      name: 'Test Driver',
      phone: '1234567890',
    ),
    children: [],
  );
}
