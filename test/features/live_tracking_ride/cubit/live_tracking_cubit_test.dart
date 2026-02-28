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
  int callCount = 0;

  @override
  Future<RideTrackingResponse> getRideTrackingByOccurrence(String occurrenceId) async {
    callCount++;
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
          name: 'Morning Pickup',
          type: 'pickup',
        ),
        bus: TrackingBus(
          id: 'bus1',
          busNumber: 'BUS-001',
          plateNumber: 'ABC-123',
          currentLocation: {
            'lat': 30.0444,
            'lng': 31.2357,
          },
        ),
        driver: DriverInfo(
          id: 'driver1',
          name: 'John Doe',
          phone: '1234567890',
          avatar: null,
        ),
        route: TrackingRoute(
          id: 'route1',
          name: 'Route A',
          stops: [
            RouteStop(
              id: 'stop1',
              name: 'Stop 1',
              address: 'Address 1',
              lat: '30.0444',
              lng: '31.2357',
              stopOrder: 1,
            ),
          ],
        ),
        children: [],
      ),
    );
  }
}

void main() {
  late LiveTrackingCubit cubit;
  late MockRidesService mockRidesService;

  setUp(() {
    mockRidesService = MockRidesService();
    cubit = LiveTrackingCubit(
      rideId: 'test-ride-id',
      ridesService: mockRidesService,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('LiveTrackingCubit - Throttling Tests', () {
    test('should throttle location updates to max 1 per second', () async {
      // Arrange: Start tracking to get into active state
      await cubit.startTracking();
      
      // Wait for initial state
      await Future.delayed(const Duration(milliseconds: 200));
      
      expect(cubit.state, isA<LiveTrackingActive>());
      final initialState = cubit.state as LiveTrackingActive;
      final initialLocation = initialState.busLocation;

      // Act: Send first location update
      cubit.handleLocationUpdate({
        'rideId': 'test-ride-id',
        'lat': 30.0555,
        'lng': 31.2468,
        'heading': 45.0,
      });

      await Future.delayed(const Duration(milliseconds: 100));

      // Assert: First update should be processed
      final stateAfterFirstUpdate = cubit.state as LiveTrackingActive;
      expect(stateAfterFirstUpdate.busLocation, isNot(equals(initialLocation)));
      expect(stateAfterFirstUpdate.busLocation.latitude, closeTo(30.0555, 0.0001));
      expect(stateAfterFirstUpdate.busLocation.longitude, closeTo(31.2468, 0.0001));

      // Act: Send multiple rapid updates (should be throttled)
      for (int i = 0; i < 5; i++) {
        cubit.handleLocationUpdate({
          'rideId': 'test-ride-id',
          'lat': 30.0666 + (i * 0.001),
          'lng': 31.2579 + (i * 0.001),
          'heading': 90.0,
        });
        await Future.delayed(const Duration(milliseconds: 20));
      }

      await Future.delayed(const Duration(milliseconds: 100));

      // Assert: Location should still be from first update (rapid updates throttled)
      final stateAfterRapidUpdates = cubit.state as LiveTrackingActive;
      expect(stateAfterRapidUpdates.busLocation.latitude, closeTo(30.0555, 0.0001));
      expect(stateAfterRapidUpdates.busLocation.longitude, closeTo(31.2468, 0.0001));

      // Wait for throttle duration to pass
      await Future.delayed(const Duration(milliseconds: 1100));

      // Send another update - this should be processed
      cubit.handleLocationUpdate({
        'rideId': 'test-ride-id',
        'lat': 30.0777,
        'lng': 31.2690,
        'heading': 135.0,
      });

      await Future.delayed(const Duration(milliseconds: 100));

      // Assert: The new update should be processed after throttle period
      final finalState = cubit.state as LiveTrackingActive;
      expect(finalState.busLocation.latitude, closeTo(30.0777, 0.0001));
      expect(finalState.busLocation.longitude, closeTo(31.2690, 0.0001));
    });

    test('should allow updates after 1 second throttle period', () async {
      // Arrange
      await cubit.startTracking();
      await Future.delayed(const Duration(milliseconds: 100));

      // Act: Send first update
      cubit.handleLocationUpdate({
        'rideId': 'test-ride-id',
        'lat': 30.0444,
        'lng': 31.2357,
        'heading': 0.0,
      });

      await Future.delayed(const Duration(milliseconds: 100));
      final firstState = cubit.state as LiveTrackingActive;
      final firstLocation = firstState.busLocation;

      // Wait for throttle period
      await Future.delayed(const Duration(milliseconds: 1000));

      // Send second update
      cubit.handleLocationUpdate({
        'rideId': 'test-ride-id',
        'lat': 30.0555,
        'lng': 31.2468,
        'heading': 45.0,
      });

      await Future.delayed(const Duration(milliseconds: 100));

      // Assert: Second update should be processed
      final secondState = cubit.state as LiveTrackingActive;
      expect(secondState.busLocation, isNot(equals(firstLocation)));
      expect(secondState.busLocation.latitude, closeTo(30.0555, 0.0001));
      expect(secondState.busLocation.longitude, closeTo(31.2468, 0.0001));
    });
  });

  group('LiveTrackingCubit - Pause/Resume Tests', () {
    test('pauseTracking should set paused flag and stop polling', () async {
      // Arrange: Start tracking
      await cubit.startTracking();
      await Future.delayed(const Duration(milliseconds: 200));

      expect(cubit.state, isA<LiveTrackingActive>());

      // Send an update before pausing to establish baseline
      cubit.handleLocationUpdate({
        'rideId': 'test-ride-id',
        'lat': 30.0444,
        'lng': 31.2357,
        'heading': 0.0,
      });

      await Future.delayed(const Duration(milliseconds: 100));
      final stateBefore = cubit.state as LiveTrackingActive;
      final locationBefore = stateBefore.busLocation;

      // Act: Pause tracking
      cubit.pauseTracking();

      // Wait for pause to take effect
      await Future.delayed(const Duration(milliseconds: 100));

      // Wait for throttle to reset
      await Future.delayed(const Duration(milliseconds: 1100));

      // Try to send update while paused
      cubit.handleLocationUpdate({
        'rideId': 'test-ride-id',
        'lat': 30.0555,
        'lng': 31.2468,
        'heading': 45.0,
      });

      await Future.delayed(const Duration(milliseconds: 100));

      final stateAfter = cubit.state as LiveTrackingActive;
      
      // Location should not change when paused
      expect(stateAfter.busLocation.latitude, equals(locationBefore.latitude));
      expect(stateAfter.busLocation.longitude, equals(locationBefore.longitude));
    });

    test('resumeTracking should allow location updates again', () async {
      // Arrange: Start and pause tracking
      await cubit.startTracking();
      await Future.delayed(const Duration(milliseconds: 100));
      cubit.pauseTracking();

      // Act: Resume tracking
      cubit.resumeTracking();

      // Wait a bit for resume to take effect
      await Future.delayed(const Duration(milliseconds: 100));

      final stateBefore = cubit.state as LiveTrackingActive;
      final locationBefore = stateBefore.busLocation;

      // Send location update
      cubit.handleLocationUpdate({
        'rideId': 'test-ride-id',
        'lat': 30.0555,
        'lng': 31.2468,
        'heading': 45.0,
      });

      await Future.delayed(const Duration(milliseconds: 100));

      // Assert: Location should update after resume
      final stateAfter = cubit.state as LiveTrackingActive;
      expect(stateAfter.busLocation, isNot(equals(locationBefore)));
      expect(stateAfter.busLocation.latitude, closeTo(30.0555, 0.0001));
    });

    test('pause and resume should work multiple times', () async {
      // Arrange
      await cubit.startTracking();
      await Future.delayed(const Duration(milliseconds: 200));

      // Act & Assert: Multiple pause/resume cycles
      for (int i = 0; i < 3; i++) {
        // Send an update before pausing
        cubit.handleLocationUpdate({
          'rideId': 'test-ride-id',
          'lat': 30.0 + i * 0.01,
          'lng': 31.0 + i * 0.01,
          'heading': 0.0,
        });

        await Future.delayed(const Duration(milliseconds: 100));
        final stateBeforePause = cubit.state as LiveTrackingActive;
        final locationBeforePause = stateBeforePause.busLocation;

        // Pause
        cubit.pauseTracking();
        await Future.delayed(const Duration(milliseconds: 100));

        // Wait for throttle to reset
        await Future.delayed(const Duration(milliseconds: 1100));

        // Try to update while paused
        cubit.handleLocationUpdate({
          'rideId': 'test-ride-id',
          'lat': 30.0 + i * 0.01 + 0.05,
          'lng': 31.0 + i * 0.01 + 0.05,
          'heading': 0.0,
        });

        await Future.delayed(const Duration(milliseconds: 100));
        final stateWhilePaused = cubit.state as LiveTrackingActive;
        
        // Location should not change while paused
        expect(stateWhilePaused.busLocation.latitude, equals(locationBeforePause.latitude));
        expect(stateWhilePaused.busLocation.longitude, equals(locationBeforePause.longitude));

        // Resume
        cubit.resumeTracking();
        await Future.delayed(const Duration(milliseconds: 100));

        // Send update after resume
        cubit.handleLocationUpdate({
          'rideId': 'test-ride-id',
          'lat': 30.0 + i * 0.01 + 0.1,
          'lng': 31.0 + i * 0.01 + 0.1,
          'heading': 0.0,
        });

        await Future.delayed(const Duration(milliseconds: 100));
        final stateAfterResume = cubit.state as LiveTrackingActive;
        
        // Location should update after resume
        expect(stateAfterResume.busLocation.latitude, closeTo(30.0 + i * 0.01 + 0.1, 0.0001));
        expect(stateAfterResume.busLocation.longitude, closeTo(31.0 + i * 0.01 + 0.1, 0.0001));
      }
    });
  });

  group('LiveTrackingCubit - Error Handling and Fallback Tests', () {
    test('should emit error state when initial data fetch fails', () async {
      // Arrange: Set up mock to throw exception
      mockRidesService.mockException = Exception('Network error');

      // Act
      await cubit.startTracking();

      // Assert
      expect(cubit.state, isA<LiveTrackingError>());
      final errorState = cubit.state as LiveTrackingError;
      expect(errorState.message, contains('Network error'));
      expect(errorState.errorType, equals('INITIALIZATION_ERROR'));
    });

    test('should emit error when no tracking data is available', () async {
      // Arrange: Set up mock to return null data
      mockRidesService.mockResponse = RideTrackingResponse(
        success: true,
        data: null,
      );

      // Act
      await cubit.startTracking();

      // Assert
      expect(cubit.state, isA<LiveTrackingError>());
      final errorState = cubit.state as LiveTrackingError;
      expect(errorState.message, equals('No tracking data available'));
      expect(errorState.errorType, equals('NO_DATA'));
    });

    test('should handle missing bus location by using first stop', () async {
      // Arrange: Set up mock with no current location
      mockRidesService.mockResponse = RideTrackingResponse(
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
            name: 'Morning Pickup',
            type: 'pickup',
          ),
          bus: TrackingBus(
            id: 'bus1',
            busNumber: 'BUS-001',
            plateNumber: 'ABC-123',
            currentLocation: null,
          ),
          driver: DriverInfo(
            id: 'driver1',
            name: 'John Doe',
            phone: '1234567890',
            avatar: null,
          ),
          route: TrackingRoute(
            id: 'route1',
            name: 'Route A',
            stops: [
              RouteStop(
                id: 'stop1',
                name: 'Stop 1',
                address: 'Address 1',
                lat: '30.0666',
                lng: '31.2579',
                stopOrder: 1,
              ),
            ],
          ),
          children: [],
        ),
      );

      // Act
      await cubit.startTracking();

      // Assert: Should use first stop location
      expect(cubit.state, isA<LiveTrackingActive>());
      final activeState = cubit.state as LiveTrackingActive;
      expect(activeState.busLocation.latitude, closeTo(30.0666, 0.0001));
      expect(activeState.busLocation.longitude, closeTo(31.2579, 0.0001));
    });

    test('should emit error when no location data is available', () async {
      // Arrange: Set up mock with no location and no stops
      mockRidesService.mockResponse = RideTrackingResponse(
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
            name: 'Morning Pickup',
            type: 'pickup',
          ),
          bus: TrackingBus(
            id: 'bus1',
            busNumber: 'BUS-001',
            plateNumber: 'ABC-123',
            currentLocation: null,
          ),
          driver: DriverInfo(
            id: 'driver1',
            name: 'John Doe',
            phone: '1234567890',
            avatar: null,
          ),
          route: TrackingRoute(
            id: 'route1',
            name: 'Route A',
            stops: [],
          ),
          children: [],
        ),
      );

      // Act
      await cubit.startTracking();

      // Assert
      expect(cubit.state, isA<LiveTrackingError>());
      final errorState = cubit.state as LiveTrackingError;
      expect(errorState.message, equals('No location data available'));
      expect(errorState.errorType, equals('NO_LOCATION'));
    });

    test('should handle invalid location update data gracefully', () async {
      // Arrange
      await cubit.startTracking();
      await Future.delayed(const Duration(milliseconds: 100));

      final stateBefore = cubit.state as LiveTrackingActive;
      final locationBefore = stateBefore.busLocation;

      // Act: Send invalid location updates
      cubit.handleLocationUpdate({
        'rideId': 'test-ride-id',
        'lat': 'invalid',
        'lng': 'invalid',
      });

      await Future.delayed(const Duration(milliseconds: 100));

      // Assert: State should remain unchanged
      final stateAfter = cubit.state as LiveTrackingActive;
      expect(stateAfter.busLocation, equals(locationBefore));
    });

    test('should ignore location updates for different ride IDs', () async {
      // Arrange
      await cubit.startTracking();
      await Future.delayed(const Duration(milliseconds: 100));

      final stateBefore = cubit.state as LiveTrackingActive;
      final locationBefore = stateBefore.busLocation;

      // Act: Send update for different ride
      cubit.handleLocationUpdate({
        'rideId': 'different-ride-id',
        'lat': 30.0555,
        'lng': 31.2468,
        'heading': 45.0,
      });

      await Future.delayed(const Duration(milliseconds: 100));

      // Assert: Location should not change
      final stateAfter = cubit.state as LiveTrackingActive;
      expect(stateAfter.busLocation, equals(locationBefore));
    });

    test('should handle location updates with occurrenceId', () async {
      // Arrange
      await cubit.startTracking();
      await Future.delayed(const Duration(milliseconds: 100));

      // Act: Send update with occurrenceId instead of rideId
      cubit.handleLocationUpdate({
        'occurrenceId': 'test-ride-id',
        'lat': 30.0555,
        'lng': 31.2468,
        'heading': 45.0,
      });

      await Future.delayed(const Duration(milliseconds: 100));

      // Assert: Update should be processed
      final state = cubit.state as LiveTrackingActive;
      expect(state.busLocation.latitude, closeTo(30.0555, 0.0001));
      expect(state.busLocation.longitude, closeTo(31.2468, 0.0001));
    });
  });

  group('LiveTrackingCubit - Connection Status Tests', () {
    test('should start with disconnected status', () async {
      // Act
      await cubit.startTracking();
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert: Initial state should show not connected (WebSocket not available in tests)
      expect(cubit.state, isA<LiveTrackingActive>());
      final state = cubit.state as LiveTrackingActive;
      expect(state.isConnected, isFalse);
    });

    test('should update rotation from location updates', () async {
      // Arrange
      await cubit.startTracking();
      await Future.delayed(const Duration(milliseconds: 100));

      // Act: Send update with heading
      cubit.handleLocationUpdate({
        'rideId': 'test-ride-id',
        'lat': 30.0444,
        'lng': 31.2357,
        'heading': 135.5,
      });

      await Future.delayed(const Duration(milliseconds: 100));

      // Assert: Rotation should be updated
      final state = cubit.state as LiveTrackingActive;
      expect(state.rotation, equals(135.5));
    });
  });
}
