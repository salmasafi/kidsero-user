import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
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
  List<TodayRideOccurrence> mockTodayRides = [];
  RideTrackingData? mockTrackingData;

  @override
  Dio get dio => throw UnimplementedError();

  @override
  Future<ChildrenWithRidesResponse> getChildrenWithRides() async {
    if (shouldFail) throw Exception('Network error');
    
    return ChildrenWithRidesResponse(
      success: true,
      data: ChildrenWithRidesData(
        children: mockChildren.isEmpty ? _createMockChildren() : mockChildren,
        byOrganization: [],
        totalChildren: mockChildren.isEmpty ? 2 : mockChildren.length,
      ),
    );
  }

  @override
  Future<ActiveRidesResponse> getActiveRides() async {
    if (shouldFail) throw Exception('Network error');
    
    return ActiveRidesResponse(
      success: true,
      data: ActiveRidesData(
        count: activeRidesCount,
        activeRides: [],
      ),
    );
  }

  @override
  Future<ChildTodayRidesResponse> getChildTodayRides(String childId) async {
    if (shouldFail) throw Exception('Network error');
    
    return ChildTodayRidesResponse(
      success: true,
      data: ChildTodayRidesData(
        child: ChildInfo(
          id: childId,
          name: 'Test Child',
          avatar: null,
          grade: 'Grade 1',
          classroom: 'Class A',
          organization: OrganizationInfo(
            id: 'org1',
            name: 'Test School',
            logo: null,
          ),
        ),
        type: 'today',
        date: DateTime.now().toIso8601String(),
        morning: mockTodayRides.isEmpty ? _createMockTodayRides() : mockTodayRides,
        afternoon: [],
        total: mockTodayRides.isEmpty ? 1 : mockTodayRides.length,
      ),
    );
  }

  @override
  Future<RideTrackingResponse> getRideTrackingByChild(String childId) async {
    if (shouldFail) throw Exception('Network error');
    
    return RideTrackingResponse(
      success: true,
      error: null,
      data: mockTrackingData ?? _createMockTrackingData(childId),
    );
  }

  @override
  Future<RideTrackingResponse> getRideTrackingByOccurrence(String occurrenceId) async {
    if (shouldFail) throw Exception('Network error');
    
    return RideTrackingResponse(
      success: true,
      error: null,
      data: mockTrackingData ?? _createMockTrackingData('child1'),
    );
  }

  @override
  Future<ReportAbsenceResponse> reportAbsence({
    required String occurrenceId,
    required String studentId,
    required String reason,
  }) async {
    if (shouldFail) throw Exception('Network error');
    
    return ReportAbsenceResponse(
      success: true,
      message: 'Absence reported successfully',
    );
  }

  @override
  Future<UpcomingRidesResponse> getUpcomingRides() async {
    if (shouldFail) throw Exception('Network error');
    
    return UpcomingRidesResponse(
      success: true,
      data: UpcomingRidesData(
        upcomingRides: [],
        totalDays: 0,
        totalRides: 0,
      ),
    );
  }

  @override
  Future<RideSummaryResponse> getChildRideSummary(String childId) async {
    if (shouldFail) throw Exception('Network error');
    
    return RideSummaryResponse(
      success: true,
      data: RideSummaryData(
        child: ChildSummaryInfo(
          id: childId,
          name: 'Test Child',
          avatar: null,
          organization: 'Test School',
        ),
        period: SummaryPeriod(
          month: DateTime.now().month,
          year: DateTime.now().year,
          monthName: 'Current Month',
        ),
        summary: SummaryInfo(
          total: 10,
          morning: 5,
          afternoon: 5,
          byStatus: SummaryByStatus(
            completed: 8,
            absent: 1,
            excused: 0,
            pending: 1,
          ),
          attendanceRate: 80,
        ),
      ),
    );
  }

  List<ChildWithRides> _createMockChildren() {
    return [
      ChildWithRides(
        id: 'child1',
        name: 'Ahmed Ali',
        avatar: null,
        grade: 'Grade 1',
        classroom: 'Class A',
        code: 'STU001',
        organization: OrganizationInfo(
          id: 'org1',
          name: 'Test School',
          logo: null,
        ),
        rides: [],
      ),
      ChildWithRides(
        id: 'child2',
        name: 'Sara Mohammed',
        avatar: null,
        grade: 'Grade 2',
        classroom: 'Class B',
        code: 'STU002',
        organization: OrganizationInfo(
          id: 'org1',
          name: 'Test School',
          logo: null,
        ),
        rides: [],
      ),
    ];
  }

  List<TodayRideOccurrence> _createMockTodayRides() {
    return [
      TodayRideOccurrence(
        occurrenceId: 'occ1',
        date: DateTime.now().toIso8601String(),
        status: 'scheduled',
        startedAt: null,
        completedAt: null,
        busLocation: null,
        ride: RideInfo(id: 'ride1', name: 'Morning Route', type: 'morning'),
        studentStatus: StudentStatus(
          id: 'status1',
          status: 'pending',
          pickupTime: '07:30:00',
          pickedUpAt: null,
          droppedOffAt: null,
        ),
        bus: BusInfo(
          id: 'bus1',
          busNumber: 'BUS-101',
          plateNumber: 'ABC-123',
        ),
        driver: DriverInfo(
          id: 'driver1',
          name: 'Driver 1',
          phone: '+966501234567',
          avatar: null,
        ),
        pickupPoint: PickupPoint(
          id: 'stop1',
          name: 'Home',
          address: '123 Main St',
          lat: '24.7136',
          lng: '46.6753',
        ),
      ),
    ];
  }

  RideTrackingData _createMockTrackingData(String childId) {
    return RideTrackingData(
      occurrence: RideOccurrence(
        id: 'occ1',
        date: DateTime.now().toIso8601String(),
        status: 'in_progress',
        startedAt: '07:00:00',
        completedAt: null,
      ),
      ride: RideInfo(id: 'ride1', name: 'Morning Route', type: 'morning'),
      bus: TrackingBus(
        id: 'bus1',
        busNumber: 'BUS-101',
        plateNumber: 'ABC-123',
        currentLocation: {
          'lat': '24.7136',
          'lng': '46.6753',
        },
      ),
      driver: DriverInfo(
        id: 'driver1',
        name: 'Driver 1',
        phone: '+966501234567',
        avatar: null,
      ),
      route: TrackingRoute(
        id: 'route1',
        name: 'Morning Route',
        stops: [
          RouteStop(
            id: 'stop1',
            name: 'Home',
            address: '123 Main St',
            lat: '24.7136',
            lng: '46.6753',
            stopOrder: 1,
          ),
        ],
      ),
      children: [
        TrackingChild(
          id: childId,
          status: 'pending',
          pickupTime: '07:30:00',
          child: ChildInfo(
            id: childId,
            name: 'Test Child',
            avatar: null,
            grade: 'Grade 1',
            classroom: 'Class A',
            organization: OrganizationInfo(
              id: 'org1',
              name: 'Test School',
              logo: null,
            ),
          ),
          pickupPoint: PickupPoint(
            id: 'stop1',
            name: 'Home',
            address: '123 Main St',
            lat: '24.7136',
            lng: '46.6753',
          ),
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
      TestWidgetsFlutterBinding.ensureInitialized();
      mockService = MockRidesService();
      repository = RidesRepository(ridesService: mockService);
    });

    tearDown(() {
      // Note: clearAllCache requires SharedPreferences initialization
      // which is not needed for these unit tests since we're using a mock service
    });

    group('Dashboard → Child Schedule Flow', () {
      test('should load dashboard and navigate to child schedule', () async {
        // Arrange
        final dashboardCubit = RidesDashboardCubit(repository: repository);
        final childRidesCubit = ChildRidesCubit(repository: repository, childId: 'child1');

        // Act - Load dashboard
        await dashboardCubit.loadDashboard();

        // Assert - Dashboard loaded successfully
        expect(dashboardCubit.state, isA<RidesDashboardLoaded>());
        final dashboardState = dashboardCubit.state as RidesDashboardLoaded;
        expect(dashboardState.children.length, 2);
        expect(dashboardState.activeRidesCount, 2);

        // Act - Load child schedule
        await childRidesCubit.loadRides();

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
        final trackingCubit = RideTrackingCubit(repository: repository, childId: 'child1');

        // Act - Load dashboard
        await dashboardCubit.loadDashboard();

        // Assert - Dashboard has active rides
        expect(dashboardCubit.state, isA<RidesDashboardLoaded>());
        final dashboardState = dashboardCubit.state as RidesDashboardLoaded;
        expect(dashboardState.hasActiveRides, true);

        // Act - Load tracking
        await trackingCubit.loadTracking();

        // Assert - Tracking loaded successfully
        expect(trackingCubit.state, isA<RideTrackingLoaded>());
        final trackingState = trackingCubit.state as RideTrackingLoaded;
        expect(trackingState.trackingData.children.isNotEmpty, true);
        expect(trackingState.trackingData.route.stops.isNotEmpty, true);

        // Cleanup
        dashboardCubit.close();
        trackingCubit.close();
      });

      test('should handle tracking error when no active ride', () async {
        // Arrange
        mockService.shouldFail = true;
        final trackingCubit = RideTrackingCubit(repository: repository, childId: 'child1');

        // Act
        await trackingCubit.loadTracking();

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
        final trackingCubit = RideTrackingCubit(repository: repository, childId: 'child1');

        // Act - Load dashboard
        await dashboardCubit.loadDashboard();

        // Assert - Dashboard loaded
        expect(dashboardCubit.state, isA<RidesDashboardLoaded>());

        // Act - Load timeline tracking
        await trackingCubit.loadTracking();

        // Assert - Timeline loaded with route data
        expect(trackingCubit.state, isA<RideTrackingLoaded>());
        final trackingState = trackingCubit.state as RideTrackingLoaded;
        expect(trackingState.trackingData.route.stops.isNotEmpty, true);
        expect(trackingState.trackingData.children.isNotEmpty, true);

        // Cleanup
        dashboardCubit.close();
        trackingCubit.close();
      });
    });

    group('Child Schedule → Absence Reporting Flow', () {
      test('should load child schedule and report absence', () async {
        // Arrange
        final childRidesCubit = ChildRidesCubit(repository: repository, childId: 'child1');
        final absenceCubit = ReportAbsenceCubit(repository: repository);

        // Act - Load child schedule
        await childRidesCubit.loadRides();

        // Assert - Child rides loaded
        expect(childRidesCubit.state, isA<ChildRidesLoaded>());
        final childState = childRidesCubit.state as ChildRidesLoaded;
        expect(childState.todayRides.isNotEmpty, true);

        // Act - Report absence
        final occurrence = childState.todayRides.first;
        await absenceCubit.reportAbsence(
          occurrenceId: occurrence.occurrenceId,
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

        // Change mock data
        mockService.activeRidesCount = 5;

        // Act - Second load (should use cache)
        await cubit.loadDashboard();
        final secondState = cubit.state as RidesDashboardLoaded;

        // Assert - Should still have old count due to cache (2, not 5)
        expect(secondState.activeRidesCount, 2);

        // Cleanup
        cubit.close();
      });

      test('should force refresh when requested', () async {
        // Arrange
        final cubit = ChildRidesCubit(repository: repository, childId: 'child1');

        // Act - First load
        await cubit.loadRides();

        // Change mock data
        mockService.mockTodayRides = [
          TodayRideOccurrence(
            occurrenceId: 'occ2',
            date: DateTime.now().toIso8601String(),
            status: 'scheduled',
            startedAt: null,
            completedAt: null,
            busLocation: null,
            ride: RideInfo(id: 'ride2', name: 'Afternoon Route', type: 'afternoon'),
            studentStatus: StudentStatus(
              id: 'status2',
              status: 'pending',
              pickupTime: '14:30:00',
              pickedUpAt: null,
              droppedOffAt: null,
            ),
            bus: BusInfo(
              id: 'bus2',
              busNumber: 'BUS-102',
              plateNumber: 'XYZ-789',
            ),
            driver: DriverInfo(
              id: 'driver2',
              name: 'Driver 2',
              phone: '+966501234568',
              avatar: null,
            ),
            pickupPoint: PickupPoint(
              id: 'stop2',
              name: 'School',
              address: '456 School St',
              lat: '24.7200',
              lng: '46.6800',
            ),
          ),
        ];

        // Act - Refresh with force
        await cubit.refresh();
        final secondState = cubit.state as ChildRidesLoaded;

        // Assert - Should have new data
        expect(secondState.todayRides.length, 1);
        expect(secondState.todayRides.first.occurrenceId, 'occ2');

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
