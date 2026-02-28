import 'package:flutter_test/flutter_test.dart';
import 'package:kidsero_parent/features/live_tracking_ride/cubit/live_tracking_cubit.dart';
import 'package:kidsero_parent/features/rides/data/rides_service.dart';
import 'package:kidsero_parent/features/rides/models/api_models.dart';
import 'package:dio/dio.dart';

// Manual mock for RidesService
class MockRidesService extends RidesService {
  MockRidesService() : super(dio: Dio());

  RideTrackingResponse? mockResponse;
  Exception? mockException;

  @override
  Future<RideTrackingResponse> getRideTrackingByOccurrence(String occurrenceId) async {
    if (mockException != null) {
      throw mockException!;
    }
    return mockResponse ?? _createDefaultResponse();
  }

  RideTrackingResponse _createDefaultResponse() {
    return RideTrackingResponse(
      success: true,
      data: RideTrackingData(
        occurrence: RideOccurrence(
          id: 'occ1',
          date: '2024-01-01',
          status: 'active',
          startedAt: '08:00',
          completedAt: null,
        ),
        ride: RideInfo(
          id: 'ride1',
          name: 'Morning Route',
          type: 'pickup',
        ),
        bus: TrackingBus(
          id: 'bus1',
          busNumber: 'B-101',
          plateNumber: 'ABC-1234',
          currentLocation: {
            'lat': 30.0444,
            'lng': 31.2357,
          },
        ),
        driver: DriverInfo(
          id: 'driver1',
          name: 'John Doe',
          phone: '+1234567890',
          avatar: null,
        ),
        route: TrackingRoute(
          id: 'route1',
          name: 'Route A',
          stops: [
            RouteStop(
              id: 'stop1',
              name: 'Stop 1',
              address: '123 Main St',
              lat: '30.0444',
              lng: '31.2357',
              stopOrder: 1,
            ),
            RouteStop(
              id: 'stop2',
              name: 'Stop 2',
              address: '456 Oak Ave',
              lat: '30.0555',
              lng: '31.2468',
              stopOrder: 2,
            ),
          ],
        ),
        children: [],
      ),
    );
  }
}

void main() {
  group('Real-time Update Handling - Property Tests', () {
    late MockRidesService mockRidesService;
    late LiveTrackingCubit cubit;

    setUp(() {
      mockRidesService = MockRidesService();
    });

    tearDown(() {
      cubit.close();
    });

    /// Property 8: Location updates modify bus marker position
    /// This property verifies that when location updates are received,
    /// the bus marker position is updated in the state
    test('Property 8: Location updates modify bus marker position', () async {
      // Arrange
      const rideId = 'test-ride-123';
      cubit = LiveTrackingCubit(
        rideId: rideId,
        ridesService: mockRidesService,
      );

      // Act - Start tracking
      await cubit.startTracking();
      await Future.delayed(const Duration(milliseconds: 200));

      // Get initial state
      expect(cubit.state, isA<LiveTrackingActive>());
      final initialState = cubit.state as LiveTrackingActive;
      final initialLocation = initialState.busLocation;

      // Simulate location update
      final newLocationData = {
        'rideId': rideId,
        'lat': '30.1234',
        'lng': '31.5678',
        'heading': '45.0',
      };

      cubit.handleLocationUpdate(newLocationData);
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert - Bus location should be updated
      final updatedState = cubit.state as LiveTrackingActive;
      expect(updatedState.busLocation, isNot(equals(initialLocation)));
      expect(updatedState.busLocation.latitude, closeTo(30.1234, 0.0001));
      expect(updatedState.busLocation.longitude, closeTo(31.5678, 0.0001));
      expect(updatedState.rotation, equals(45.0));
    });

    /// Property 15: Location updates are throttled
    /// This property verifies that rapid location updates are throttled
    /// to a maximum of 1 update per second
    test('Property 15: Location updates are throttled to 1 per second', () async {
      // Arrange
      const rideId = 'test-ride-123';
      cubit = LiveTrackingCubit(
        rideId: rideId,
        ridesService: mockRidesService,
      );

      // Act - Start tracking
      await cubit.startTracking();
      await Future.delayed(const Duration(milliseconds: 200));

      expect(cubit.state, isA<LiveTrackingActive>());

      // Send first update
      cubit.handleLocationUpdate({
        'rideId': rideId,
        'lat': '30.1000',
        'lng': '31.2000',
        'heading': '0.0',
      });

      await Future.delayed(const Duration(milliseconds: 100));
      
      final firstState = cubit.state as LiveTrackingActive;
      expect(firstState.busLocation.latitude, closeTo(30.1000, 0.0001));

      // Send multiple rapid updates within 1 second (should be throttled)
      for (int i = 1; i < 5; i++) {
        cubit.handleLocationUpdate({
          'rideId': rideId,
          'lat': '30.${1000 + i}',
          'lng': '31.${2000 + i}',
          'heading': '${i * 10}.0',
        });
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Assert - Location should still be from first update (rapid updates throttled)
      final throttledState = cubit.state as LiveTrackingActive;
      expect(throttledState.busLocation.latitude, closeTo(30.1000, 0.0001),
        reason: 'Rapid updates should be throttled');
      
      // Wait for throttle duration to pass
      await Future.delayed(const Duration(milliseconds: 1100));
      
      // Send another update after throttle period
      cubit.handleLocationUpdate({
        'rideId': rideId,
        'lat': '30.9999',
        'lng': '31.9999',
        'heading': '90.0',
      });
      
      await Future.delayed(const Duration(milliseconds: 100));
      
      // This update should be processed
      final finalState = cubit.state as LiveTrackingActive;
      expect(finalState.busLocation.latitude, closeTo(30.9999, 0.0001));
      expect(finalState.busLocation.longitude, closeTo(31.9999, 0.0001));
    });

    test('Location updates with invalid data are ignored', () async {
      // Arrange
      const rideId = 'test-ride-123';
      cubit = LiveTrackingCubit(
        rideId: rideId,
        ridesService: mockRidesService,
      );

      await cubit.startTracking();
      await Future.delayed(const Duration(milliseconds: 200));

      final initialState = cubit.state as LiveTrackingActive;
      final initialLocation = initialState.busLocation;

      // Act - Send invalid location data (zeros)
      final invalidData = {
        'rideId': rideId,
        'lat': '0.0',
        'lng': '0.0',
        'heading': '0.0',
      };

      cubit.handleLocationUpdate(invalidData);
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert - Location should not change
      final finalState = cubit.state as LiveTrackingActive;
      expect(finalState.busLocation, equals(initialLocation));
    });

    test('Location updates for different ride are ignored', () async {
      // Arrange
      const rideId = 'test-ride-123';
      cubit = LiveTrackingCubit(
        rideId: rideId,
        ridesService: mockRidesService,
      );

      await cubit.startTracking();
      await Future.delayed(const Duration(milliseconds: 200));

      final initialState = cubit.state as LiveTrackingActive;
      final initialLocation = initialState.busLocation;

      // Act - Send update for different ride
      final differentRideData = {
        'rideId': 'different-ride-456',
        'lat': '30.5555',
        'lng': '31.6666',
        'heading': '180.0',
      };

      cubit.handleLocationUpdate(differentRideData);
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert - Location should not change
      final finalState = cubit.state as LiveTrackingActive;
      expect(finalState.busLocation, equals(initialLocation));
    });

    test('Rotation is updated smoothly with location', () async {
      // Arrange
      const rideId = 'test-ride-123';
      cubit = LiveTrackingCubit(
        rideId: rideId,
        ridesService: mockRidesService,
      );

      await cubit.startTracking();
      await Future.delayed(const Duration(milliseconds: 200));

      // Act - Send updates with different headings
      final rotations = <double>[];
      
      for (int i = 0; i < 3; i++) {
        await Future.delayed(const Duration(seconds: 1, milliseconds: 100));
        
        final locationData = {
          'rideId': rideId,
          'lat': '30.${1000 + i}',
          'lng': '31.${2000 + i}',
          'heading': '${i * 45}.0',
        };
        
        cubit.handleLocationUpdate(locationData);
        await Future.delayed(const Duration(milliseconds: 100));
        
        if (cubit.state is LiveTrackingActive) {
          rotations.add((cubit.state as LiveTrackingActive).rotation);
        }
      }

      // Assert - Rotations should be updated
      expect(rotations.length, equals(3));
      expect(rotations[0], equals(0.0));
      expect(rotations[1], equals(45.0));
      expect(rotations[2], equals(90.0));
    });

    test('Bus marker animates between positions smoothly', () async {
      // Arrange
      const rideId = 'test-ride-123';
      cubit = LiveTrackingCubit(
        rideId: rideId,
        ridesService: mockRidesService,
      );

      await cubit.startTracking();
      await Future.delayed(const Duration(milliseconds: 200));

      // Act - Send multiple location updates with delays
      final positions = <Map<String, double>>[];
      
      for (int i = 0; i < 3; i++) {
        await Future.delayed(const Duration(seconds: 1, milliseconds: 100));
        
        cubit.handleLocationUpdate({
          'rideId': rideId,
          'lat': '30.${i}000',
          'lng': '31.${i}000',
          'heading': '${i * 30}.0',
        });
        
        await Future.delayed(const Duration(milliseconds: 100));
        
        if (cubit.state is LiveTrackingActive) {
          final state = cubit.state as LiveTrackingActive;
          positions.add({
            'lat': state.busLocation.latitude,
            'lng': state.busLocation.longitude,
            'rotation': state.rotation,
          });
        }
      }

      // Assert - All positions should be captured and different
      expect(positions.length, equals(3));
      expect(positions[0]['lat'], closeTo(30.0, 0.0001));
      expect(positions[1]['lat'], closeTo(30.1, 0.0001));
      expect(positions[2]['lat'], closeTo(30.2, 0.0001));
      
      // Rotations should also be different
      expect(positions[0]['rotation'], equals(0.0));
      expect(positions[1]['rotation'], equals(30.0));
      expect(positions[2]['rotation'], equals(60.0));
    });
  });
}
