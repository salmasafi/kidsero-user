import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidsero_parent/features/rides/cubit/rides_dashboard_cubit.dart';
import 'package:kidsero_parent/features/rides/cubit/child_rides_cubit.dart';
import 'package:kidsero_parent/features/rides/cubit/ride_tracking_cubit.dart';
import 'package:kidsero_parent/features/rides/cubit/report_absence_cubit.dart';
import 'package:kidsero_parent/features/rides/data/rides_repository.dart';
import 'package:kidsero_parent/features/rides/data/rides_service.dart';
import 'package:kidsero_parent/features/rides/models/api_models.dart';

/// Mock implementation of RidesService for testing
class MockRidesService implements RidesService {
  bool shouldFail = false;
  int activeRidesCount = 2;
  List<ChildWithRides> mockChildren = [];
  List<RideOccurrence> mockTodayRides = [];
  TrackingData? mockTrackingData;

  @override
  Future<ChildrenWithRidesData> getChildrenWithRides() async {
    if (shouldFail) throw Exception('Network error');
    
    return ChildrenWithRidesData(
      children: mockChildren.isEmpty ? _createMockChildren() : mockChildren,
    );
  }

  @override
  Future<ActiveRidesData> getActiveRides() async {
    if (shouldFail) throw Exception('Network error');
    
    return ActiveRidesData(
      count: activeRidesCount,
      activeRides: [],
    );
  }

  @override
  Future<ChildRidesData> getChildTodayRides(String childId) async {
    if (shouldFail) throw Exception('Network error');
    
    return ChildRidesData(
      childId: childId,
      childName: 'Test Child',
      todayRides: mockTodayRides.isEmpty ? _createMockTodayRides() : mockTodayRides,
    );
  }

  @override
  Future<TrackingData> getRideTrackingByChild(String childId) async {
    if (shouldFail) throw Exception('Network error');
    
    return mockTrackingData ?? _createMockTrackingData(childId);
  }

  @override
  Future<AbsenceReportData> reportAbsence({
    required String occurrenceId,
    required String studentId,
    required String reason,
  }) async {
    if (shouldFail) throw Exception('Network error');
    
    return AbsenceReportData(
      success: true,
      message: 'Absence reported successfully',
    );
  }

  @override
  Future<UpcomingRidesData> getUpcomingRides() async {
    if (shouldFail) throw Exception('Network error');
    
    return UpcomingRidesData(groupedRides: {});
  }

  @override
  Future<RideSummaryData> getChildRideSummary(String childId) async {
    if (shouldFail) throw Exception('Network error');
    
    return RideSummaryData(
      childId: childId,
      childName: 'Test Child',
      totalRides: 10,
      completedRides: 8,
      pendingRides: 1,
      absentRides: 1,
      excusedRides: 0,
      cancelledRides: 0,
      morningRides: 5,
      afternoonRides: 5,
    );
  }

  List<ChildWithRides> _createMockChildren() {
    return [
      ChildWithRides(
        id: 'child1',
        name: 'Ahmed Ali',
        profilePicture: null,
        totalRides: 10,
        completedRides: 8,
        pendingRides: 1,
        absentRides: 1,
      ),
      ChildWithRides(
        id: 'child2',
        name: 'Sara Mohammed',
        profilePicture: null,
        totalRides: 8,
        completedRides: 6,
        pendingRides: 1,
        absentRides: 1,
      ),
    ];
  }

  List<RideOccurrence> _createMockTodayRides() {
    return [
      RideOccurrence(
        id: 'occ1',
        rideId: 'ride1',
        date: DateTime.now().toIso8601String(),
        period: 'morning',
        pickupTime: '07:30:00',
        pickupLocation: 'Home',
        status: 'scheduled',
        busNumber: 'BUS-101',
        driverName: 'Driver 1',
      ),
    ];
  }

  TrackingData _createMockTrackingData(String childId) {
    return TrackingData(
      rideId: 'ride1',
      childId: childId,
      busNumber: 'BUS-101',
      driverName: 'Driver 1',
      currentLocation: Location(latitude: 24.7136, longitude: 46.6753),
      pickupPoints: [
        PickupPoint(
          id: 'pp1',
          name: 'Home',
          location: Location(latitude: 24.7136, longitude: 46.6753),
          estimatedTime: '07:30:00',
          status: 'pending',
          children: [
            ChildInfo(id: childId, name: 'Test Child', status: 'pending'),
          ],
        ),
      ],
      events: [
        RideEvent(
          id: 'event1',
          type: 'ride_started',
          timestamp: DateTime.now().toIso8601String(),
          description: 'Ride started',
        ),
      ],
    );
  }
}

void main() {
  group('Rides Flow Integration Tests', () {
    late MockRidesService mockService;
    late RidesRepository repository;

    setUp(() {
      mockService = MockRidesService();
      repository = RidesRepository(service: mockService);
    });

    tearDown(() {
      repository.clearAllCache();
    });

    group('Dashboard → Child Schedule Flow', () {
      test('should load dashboard and navigate to child schedule', () async {
        // Arrange
        final dashboardCubit = RidesDashboardCubit(repository: repository);
        final childRidesCubit = ChildRidesCubit(repository: repository);

        // Act - Load dashboard
        await dashboardCubit.loadDashboard();

        // Assert - Dashboard loaded successfully
        expect(dashboardCubit.state, isA<RidesDashboardLoaded>());
        final dashboardState = dashboardCubit.state as RidesDashboardLoaded;
        expect(dashboardState.children.length, 2);
        expect(dashboardState.activeRidesCount, 2);

        // Act - Load child schedule
        final childId = dashboardState.children.first.id;
        await childRidesCubit.loadRides(childId);

        // Assert - Child rides loaded successfully
        expect(childRidesCubit.state, isA<ChildRidesLoaded>());
        final childState = childRidesCubit.state as ChildRidesLoaded;
        expect(childState.todayRides.isNotEmpty, true);

        // Cleanup
        dashboardCubit.close();
        childRidesCubit.close();
      });

      test('should handle empty dashboard state', () async {
        // Arrange
        mockService.mockChildren = [];
        final dashboardCubit = RidesDashboardCubit(repository: repository);

        // Act
        await dashboardCubit.loadDashboard();

        // Assert
        expect(dashboardCubit.state, isA<RidesDashboardEmpty>());

        // Cleanup
        dashboardCubit.close();
      });

      test('should handle dashboard error state', () async {
        // Arrange
        mockService.shouldFail = true;
        final dashboardCubit = RidesDashboardCubit(repository: repository);

        // Act
        await dashboardCubit.loadDashboard();

        // Assert
        expect(dashboardCubit.state, isA<RidesDashboardError>());

        // Cleanup
        dashboardCubit.close();
      });
    });

    group('Dashboard → Live Tracking Flow', () {
      test('should load dashboard and start tracking', () async {
        // Arrange
        final dashboardCubit = RidesDashboardCubit(repository: repository);
        final trackingCubit = RideTrackingCubit(repository: repository);

        // Act - Load dashboard
        await dashboardCubit.loadDashboard();

        // Assert - Dashboard has active rides
        expect(dashboardCubit.state, isA<RidesDashboardLoaded>());
        final dashboardState = dashboardCubit.state as RidesDashboardLoaded;
        expect(dashboardState.hasActiveRides, true);

        // Act - Load tracking
        final childId = dashboardState.children.first.id;
        await trackingCubit.loadTracking(childId);

        // Assert - Tracking loaded successfully
        expect(trackingCubit.state, isA<RideTrackingLoaded>());
        final trackingState = trackingCubit.state as RideTrackingLoaded;
        expect(trackingState.trackingData.childId, childId);
        expect(trackingState.trackingData.pickupPoints.isNotEmpty, true);

        // Cleanup
        dashboardCubit.close();
        trackingCubit.close();
      });

      test('should handle tracking error when no active ride', () async {
        // Arrange
        mockService.shouldFail = true;
        final trackingCubit = RideTrackingCubit(repository: repository);

        // Act
        await trackingCubit.loadTracking('child1');

        // Assert
        expect(trackingCubit.state, isA<RideTrackingError>());

        // Cleanup
        trackingCubit.close();
      });
    });

    group('Dashboard → Timeline Tracking Flow', () {
      test('should load dashboard and view timeline', () async {
        // Arrange
        final dashboardCubit = RidesDashboardCubit(repository: repository);
        final trackingCubit = RideTrackingCubit(repository: repository);

        // Act - Load dashboard
        await dashboardCubit.loadDashboard();

        // Assert - Dashboard loaded
        expect(dashboardCubit.state, isA<RidesDashboardLoaded>());

        // Act - Load timeline tracking
        final childId = (dashboardCubit.state as RidesDashboardLoaded).children.first.id;
        await trackingCubit.loadTracking(childId);

        // Assert - Timeline loaded with events
        expect(trackingCubit.state, isA<RideTrackingLoaded>());
        final trackingState = trackingCubit.state as RideTrackingLoaded;
        expect(trackingState.trackingData.events.isNotEmpty, true);
        expect(trackingState.trackingData.pickupPoints.isNotEmpty, true);

        // Cleanup
        dashboardCubit.close();
        trackingCubit.close();
      });
    });

    group('Child Schedule → Absence Reporting Flow', () {
      test('should load child schedule and report absence', () async {
        // Arrange
        final childRidesCubit = ChildRidesCubit(repository: repository);
        final absenceCubit = ReportAbsenceCubit(repository: repository);

        // Act - Load child schedule
        await childRidesCubit.loadRides('child1');

        // Assert - Child rides loaded
        expect(childRidesCubit.state, isA<ChildRidesLoaded>());
        final childState = childRidesCubit.state as ChildRidesLoaded;
        expect(childState.todayRides.isNotEmpty, true);

        // Act - Report absence
        final occurrence = childState.todayRides.first;
        await absenceCubit.reportAbsence(
          occurrenceId: occurrence.id,
          studentId: 'child1',
          reason: 'Sick',
        );

        // Assert - Absence reported successfully
        expect(absenceCubit.state, isA<ReportAbsenceSuccess>());

        // Cleanup
        childRidesCubit.close();
        absenceCubit.close();
      });

      test('should validate absence reason', () async {
        // Arrange
        final absenceCubit = ReportAbsenceCubit(repository: repository);

        // Act - Report absence with empty reason
        await absenceCubit.reportAbsence(
          occurrenceId: 'occ1',
          studentId: 'child1',
          reason: '',
        );

        // Assert - Validation error
        expect(absenceCubit.state, isA<ReportAbsenceValidationError>());

        // Cleanup
        absenceCubit.close();
      });

      test('should handle absence reporting error', () async {
        // Arrange
        mockService.shouldFail = true;
        final absenceCubit = ReportAbsenceCubit(repository: repository);

        // Act
        await absenceCubit.reportAbsence(
          occurrenceId: 'occ1',
          studentId: 'child1',
          reason: 'Sick',
        );

        // Assert
        expect(absenceCubit.state, isA<ReportAbsenceError>());

        // Cleanup
        absenceCubit.close();
      });
    });

    group('Caching Behavior', () {
      test('should cache dashboard data', () async {
        // Arrange
        final cubit = RidesDashboardCubit(repository: repository);

        // Act - First load
        await cubit.loadDashboard();
        final firstState = cubit.state as RidesDashboardLoaded;

        // Change mock data
        mockService.activeRidesCount = 5;

        // Act - Second load (should use cache)
        await cubit.loadDashboard();
        final secondState = cubit.state as RidesDashboardLoaded;

        // Assert - Should still have old count due to cache
        expect(secondState.activeRidesCount, firstState.activeRidesCount);

        // Cleanup
        cubit.close();
      });

      test('should force refresh when requested', () async {
        // Arrange
        final cubit = ChildRidesCubit(repository: repository);

        // Act - First load
        await cubit.loadRides('child1');
        final firstState = cubit.state as ChildRidesLoaded;

        // Change mock data
        mockService.mockTodayRides = [
          RideOccurrence(
            id: 'occ2',
            rideId: 'ride2',
            date: DateTime.now().toIso8601String(),
            period: 'afternoon',
            pickupTime: '14:30:00',
            pickupLocation: 'School',
            status: 'scheduled',
            busNumber: 'BUS-102',
            driverName: 'Driver 2',
          ),
        ];

        // Act - Refresh with force
        await cubit.refresh('child1');
        final secondState = cubit.state as ChildRidesLoaded;

        // Assert - Should have new data
        expect(secondState.todayRides.length, 1);
        expect(secondState.todayRides.first.id, 'occ2');

        // Cleanup
        cubit.close();
      });
    });

    group('Error Recovery', () {
      test('should recover from network error on retry', () async {
        // Arrange
        mockService.shouldFail = true;
        final cubit = RidesDashboardCubit(repository: repository);

        // Act - First attempt (should fail)
        await cubit.loadDashboard();
        expect(cubit.state, isA<RidesDashboardError>());

        // Fix network
        mockService.shouldFail = false;

        // Act - Retry
        await cubit.loadDashboard();

        // Assert - Should succeed
        expect(cubit.state, isA<RidesDashboardLoaded>());

        // Cleanup
        cubit.close();
      });
    });

    group('State Transitions', () {
      test('should transition through correct states during load', () async {
        // Arrange
        final cubit = RidesDashboardCubit(repository: repository);
        final states = <RidesDashboardState>[];
        
        // Listen to state changes
        final subscription = cubit.stream.listen(states.add);

        // Act
        await cubit.loadDashboard();
        await Future.delayed(Duration(milliseconds: 100)); // Wait for stream

        // Assert
        expect(states.length, greaterThanOrEqualTo(2));
        expect(states.first, isA<RidesDashboardLoading>());
        expect(states.last, isA<RidesDashboardLoaded>());

        // Cleanup
        await subscription.cancel();
        cubit.close();
      });
    });
  });
}
