# Design Document: Rides Flow Refactoring

## Overview

This design document outlines the refactoring of the rides flow in the Flutter parent app for school bus tracking. The refactoring will replace the current implementation with a clean architecture that uses the correct API endpoints while maintaining the existing UI design. The system follows a layered architecture with clear separation between data, business logic, and presentation layers.

### Key Design Goals

1. **API Alignment**: Use the correct API endpoints as specified in the requirements
2. **UI Preservation**: Maintain the existing UI design and user experience
3. **Clean Architecture**: Implement proper separation of concerns with Service → Repository → Cubit → UI layers
4. **State Management**: Use the Cubit pattern from the flutter_bloc package
5. **Type Safety**: Implement comprehensive data models for all API responses
6. **Error Handling**: Provide graceful error handling with user-friendly messages
7. **Caching**: Implement intelligent caching to reduce API calls and improve performance
8. **Localization**: Support both Arabic and English with proper RTL layout

## Architecture

### Layer Structure

```
┌─────────────────────────────────────────┐
│           UI Layer (Screens)            │
│  - RidesScreen                          │
│  - ChildScheduleScreen                  │
│  - LiveTrackingScreen                   │
│  - RideTrackingScreen                   │
└──────────────┬──────────────────────────┘
               │ BlocBuilder/BlocConsumer
┌──────────────▼──────────────────────────┐
│      State Management (Cubits)          │
│  - RidesDashboardCubit                  │
│  - ChildRidesCubit                      │
│  - ActiveRidesCubit                     │
│  - RideTrackingCubit                    │
└──────────────┬──────────────────────────┘
               │ Business Logic
┌──────────────▼──────────────────────────┐
│      Repository Layer                   │
│  - RidesRepository                      │
│    • Caching logic                      │
│    • Data transformation                │
│    • Error handling                     │
└──────────────┬──────────────────────────┘
               │ API Calls
┌──────────────▼──────────────────────────┐
│       Service Layer                     │
│  - RidesService                         │
│    • HTTP requests via Dio              │
│    • Response parsing                   │
└──────────────┬──────────────────────────┘
               │ Network
┌──────────────▼──────────────────────────┐
│          Backend API                    │
│  - GET /api/users/rides/children        │
│  - GET /api/users/rides/child/{id}      │
│  - GET /api/users/rides/active          │
│  - GET /api/users/rides/upcoming        │
│  - GET /api/users/rides/tracking/{id}   │
│  - GET /api/users/rides/child/{id}/sum  │
│  - POST /api/users/rides/excuse/{...}   │
└─────────────────────────────────────────┘
```

### Data Flow

1. **UI → Cubit**: User actions trigger cubit methods
2. **Cubit → Repository**: Cubit calls repository methods for data
3. **Repository → Service**: Repository delegates API calls to service
4. **Service → API**: Service makes HTTP requests
5. **API → Service**: Service receives and parses responses
6. **Service → Repository**: Repository receives parsed data
7. **Repository → Cubit**: Repository returns data (with caching)
8. **Cubit → UI**: Cubit emits new state, UI rebuilds

## Components and Interfaces

### 1. Service Layer (RidesService)

The service layer is responsible for making HTTP requests and parsing responses.

```dart
class RidesService {
  final Dio dio;

  RidesService({required this.dio});

  // Get all children with their ride information
  Future<ChildrenWithAllRidesResponse> getChildrenWithAllRides();

  // Get today's rides for a specific child
  Future<SingleChildRidesResponse> getChildTodayRides(String childId);

  // Get currently active rides
  Future<ActiveRidesResponse> getActiveRides();

  // Get upcoming scheduled rides
  Future<UpcomingRidesGroupedResponse> getUpcomingRides();

  // Get ride summary for a child
  Future<NewRideSummaryResponse> getChildRideSummary(String childId);

  // Get real-time tracking data
  Future<NewRideTrackingResponse> getRideTrackingByChild(String childId);

  // Report absence for a ride
  Future<ReportAbsenceResponse> reportAbsence({
    required String occurrenceId,
    required String studentId,
    required String reason,
  });
}
```

### 2. Repository Layer (RidesRepository)

The repository layer adds caching, error handling, and data transformation.

```dart
class RidesRepository {
  final RidesService _ridesService;
  
  // Cache configuration
  static const int _childrenCacheTTL = 300; // 5 minutes
  static const int _activeRidesCacheTTL = 30; // 30 seconds
  static const int _upcomingRidesCacheTTL = 600; // 10 minutes
  static const int _summaryCacheTTL = 1800; // 30 minutes

  RidesRepository({required RidesService ridesService});

  // Get children with rides (with caching)
  Future<List<ChildWithAllRides>> getChildrenWithAllRides({
    bool forceRefresh = false
  });

  // Get child's today rides (with caching)
  Future<ChildRideDetails> getChildTodayRides(
    String childId, {
    bool forceRefresh = false
  });

  // Get active rides (short cache TTL)
  Future<List<ActiveRide>> getActiveRides({
    bool forceRefresh = false
  });

  // Get upcoming rides (with caching)
  Future<List<UpcomingDayRides>> getUpcomingRides({
    bool forceRefresh = false
  });

  // Get ride summary (long cache TTL)
  Future<NewRideSummaryData> getChildRideSummary(
    String childId, {
    bool forceRefresh = false
  });

  // Get ride tracking (no caching - real-time data)
  Future<NewRideTrackingData> getRideTrackingByChild(String childId);

  // Report absence (clears relevant caches)
  Future<AbsenceData> reportAbsence({
    required String occurrenceId,
    required String studentId,
    required String reason,
  });

  // Clear all caches
  Future<void> clearAllCache();
}
```

### 3. State Management (Cubits)

#### RidesDashboardCubit

Manages the state of the main rides dashboard.

```dart
// States
abstract class RidesDashboardState extends Equatable {}
class RidesDashboardInitial extends RidesDashboardState {}
class RidesDashboardLoading extends RidesDashboardState {}
class RidesDashboardLoaded extends RidesDashboardState {
  final List<ChildWithAllRides> children;
  final List<ActiveRide> activeRides;
  
  int get childrenCount;
  int get activeRidesCount;
  bool get hasActiveRides;
  bool hasActiveRideForChild(String childId);
}
class RidesDashboardEmpty extends RidesDashboardState {}
class RidesDashboardError extends RidesDashboardState {
  final String message;
}

// Cubit
class RidesDashboardCubit extends Cubit<RidesDashboardState> {
  final RidesRepository _repository;

  Future<void> loadDashboard();
  Future<void> refreshActiveRides();
}
```

#### ChildRidesCubit

Manages the state of a child's ride schedule.

```dart
// States
abstract class ChildRidesState extends Equatable {}
class ChildRidesInitial extends ChildRidesState {}
class ChildRidesLoading extends ChildRidesState {}
class ChildRidesLoaded extends ChildRidesState {
  final String childId;
  final List<TodayRide> todayRides;
  final List<RideHistoryItem> upcomingRides;
  final List<RideHistoryItem> historyRides;
  final ActiveRide? activeRide;
  final NewRideSummaryData? summary;
  
  bool get hasActiveRide;
}
class ChildRidesEmpty extends ChildRidesState {}
class ChildRidesError extends ChildRidesState {
  final String message;
}

// Cubit
class ChildRidesCubit extends Cubit<ChildRidesState> {
  final RidesRepository _repository;
  final String _childId;

  Future<void> loadRides();
  Future<void> refresh();
  Future<void> loadSummary();
}
```

#### RideTrackingCubit

Manages the state of ride tracking (both live and timeline).

```dart
// States
abstract class RideTrackingState extends Equatable {}
class RideTrackingInitial extends RideTrackingState {}
class RideTrackingLoading extends RideTrackingState {}
class RideTrackingLoaded extends RideTrackingState {
  final NewRideTrackingData trackingData;
}
class RideTrackingError extends RideTrackingState {
  final String message;
}

// Cubit
class RideTrackingCubit extends Cubit<RideTrackingState> {
  final RidesRepository _repository;
  final String _childId;
  Timer? _refreshTimer;

  Future<void> loadTracking();
  void startAutoRefresh(); // Refresh every 10 seconds
  void stopAutoRefresh();
}
```

#### ReportAbsenceCubit

Manages the state of reporting absence for a ride.

```dart
// States
abstract class ReportAbsenceState extends Equatable {}
class ReportAbsenceInitial extends ReportAbsenceState {}
class ReportAbsenceLoading extends ReportAbsenceState {}
class ReportAbsenceSuccess extends ReportAbsenceState {
  final String message;
}
class ReportAbsenceError extends ReportAbsenceState {
  final String message;
}
class ReportAbsenceValidationError extends ReportAbsenceState {
  final String message;
}

// Cubit
class ReportAbsenceCubit extends Cubit<ReportAbsenceState> {
  final RidesRepository _repository;

  Future<void> reportAbsence({
    required String occurrenceId,
    required String studentId,
    required String reason,
  });
}
```

### 4. UI Layer

#### RidesScreen (Main Dashboard)

The main dashboard displays all children with their ride information.

**Components:**
- Gradient header with user greeting and language toggle
- Statistics cards (children count, active rides count)
- Live tracking and timeline tracking buttons
- Horizontally scrolling child cards
- Upcoming notices section
- Pull-to-refresh functionality

**State Handling:**
- Loading: Show circular progress indicator
- Empty: Show empty state with "No children found" message
- Error: Show error message with retry button
- Loaded: Display children cards and statistics

#### ChildScheduleScreen

Displays a child's ride schedule with three tabs: History, Today, and Upcoming.

**Components:**
- Gradient header with child avatar and info
- Summary button (analytics icon)
- Tab bar with three tabs
- Tab content based on selection
- Pull-to-refresh functionality

**Tab Content:**
- **Today Tab**: Shows today's rides and active ride (if any)
- **Upcoming Tab**: Shows future scheduled rides
- **History Tab**: Shows past completed rides

**State Handling:**
- Loading: Show circular progress indicator
- Empty: Show appropriate empty state for each tab
- Error: Show error message with retry button
- Loaded: Display rides in cards

#### LiveTrackingScreen

Displays real-time GPS tracking of a bus during an active ride.

**Components:**
- Map view with bus location marker
- Bus information card (number, plate, driver)
- Child pickup status
- Route information
- Auto-refresh every 10 seconds

#### RideTrackingScreen

Displays a timeline view of ride events and stops.

**Components:**
- Timeline of pickup points
- Children on the ride
- Current child's pickup point highlighted
- Bus and driver information
- Ride status

## Data Models

### Response Models

```dart
// GET /api/users/rides/children
class ChildrenWithAllRidesResponse {
  final bool success;
  final ChildrenWithAllRidesData data;
}

class ChildrenWithAllRidesData {
  final List<ChildWithAllRides> children;
}

class ChildWithAllRides {
  final String id;
  final String name;
  final String? avatar;
  final String grade;
  final String? classroom;
  final OrganizationInfo? organization;
  final ChildRidesInfo rides;
}

class ChildRidesInfo {
  final int todayCount;
  final int upcomingCount;
  final int historyCount;
  final ActiveRide? active;
}

// GET /api/users/rides/active
class ActiveRidesResponse {
  final bool success;
  final List<ActiveRide> data;
}

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
}

// GET /api/users/rides/upcoming
class UpcomingRidesGroupedResponse {
  final bool success;
  final UpcomingRidesGroupedData data;
}

class UpcomingRidesGroupedData {
  final List<UpcomingDayRides> upcomingRides;
}

class UpcomingDayRides {
  final String date;
  final String? dayName;
  final List<UpcomingRideInfo> rides;
}

class UpcomingRideInfo {
  final String id;
  final String name;
  final String type;
  final String? pickupTime;
  final String? pickupPoint;
  final String? pickupPointName;
  final String? dropoffPoint;
  final String? child;
}

// GET /api/users/rides/child/{childId}
class SingleChildRidesResponse {
  final bool success;
  final ChildRideDetails data;
}

class ChildRideDetails {
  final String id;
  final String name;
  final String? grade;
  final String? schoolName;
  final ChildRidesData rides;
}

class ChildRidesData {
  final List<RideHistoryItem> upcoming;
  final List<RideHistoryItem> history;
}

class RideHistoryItem {
  final String rideId;
  final String date;
  final String period;
  final String status;
  final String? pickedUpAt;
  final String? droppedOffAt;
}

// GET /api/users/rides/child/{childId}/summary
class NewRideSummaryResponse {
  final bool success;
  final NewRideSummaryData data;
}

class NewRideSummaryData {
  final String childId;
  final NewRideSummary summary;
}

class NewRideSummary {
  final int total;
  final SummaryByStatus byStatus;
  final SummaryByPeriod byPeriod;
}

class SummaryByStatus {
  final int completed;
  final int cancelled;
  final int absent;
}

class SummaryByPeriod {
  final int morning;
  final int afternoon;
}

// GET /api/users/rides/tracking/{childId}
class NewRideTrackingResponse {
  final bool success;
  final NewRideTrackingData data;
}

class NewRideTrackingData {
  final String childId;
  final TrackingRide? ride;
  final TrackingChild? child;
}

class TrackingRide {
  final String id;
  final String name;
  final String type;
  final String status;
  final TrackingBus bus;
  final TrackingDriver driver;
}

class TrackingChild {
  final String id;
  final String status;
  final String? pickedUpAt;
  final String? droppedOffAt;
  final String pickupTime;
  final String? excuseReason;
  final ChildBasicInfo child;
  final PickupPoint pickupPoint;
}

// POST /api/users/rides/excuse/{occurrenceId}/{studentId}
class ReportAbsenceResponse {
  final bool success;
  final String message;
  final AbsenceData? data;
}

class AbsenceData {
  final String occurrenceId;
  final String studentId;
  final String reason;
  final String status;
  final String createdAt;
}

// Common models
class BusInfo {
  final String id;
  final String? plateNumber;
  final int? capacity;
}

class DriverInfo {
  final String id;
  final String name;
  final String? phone;
  final String? avatar;
}

class LocationInfo {
  final double lat;
  final double lng;
  final String? recordedAt;
}

class OrganizationInfo {
  final String id;
  final String name;
}
```

### Caching Strategy

The repository layer implements intelligent caching with different TTL values based on data volatility:

| Data Type | Cache TTL | Rationale |
|-----------|-----------|-----------|
| Children with rides | 5 minutes | Relatively stable, but needs periodic updates |
| Active rides | 30 seconds | Frequently changing during active rides |
| Upcoming rides | 10 minutes | Stable schedule data |
| Ride summary | 30 minutes | Historical data, rarely changes |
| Ride tracking | No cache | Real-time data, always fetch fresh |

**Cache Invalidation:**
- When reporting absence, clear caches for: today rides, upcoming rides, child rides, child summary
- When refreshing manually, force bypass cache
- Cache is stored using CacheHelper (SharedPreferences)

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Data Completeness in Rendering

*For any* data model (child, ride, tracking data, etc.), when rendered to UI, the output should contain all required fields specified in the requirements (avatar, name, grade, classroom, school, ride period, pickup time, pickup location, status, bus number, plate number, driver information, child name, etc.).

**Validates: Requirements 1.3, 3.6, 4.4, 4.5, 6.4**

### Property 2: Count Accuracy

*For any* list of items (children, active rides), the displayed count should equal the actual number of items in the list.

**Validates: Requirements 2.1, 2.2**

### Property 3: Tracking Button State

*For any* dashboard state, the tracking buttons (live and timeline) should be enabled if and only if there are active rides.

**Validates: Requirements 2.3, 2.4, 2.5**

### Property 4: Active Ride Indicator

*For any* child with an active ride, the child card should display an online status indicator.

**Validates: Requirements 1.4**

### Property 5: Chronological Ordering

*For any* list of ride events in timeline tracking, the events should be ordered chronologically by their timestamp.

**Validates: Requirements 5.3**

### Property 6: Pickup Point Status Completeness

*For any* tracking data with pickup points, each pickup point should have an associated status displayed.

**Validates: Requirements 5.4**

### Property 7: Children List Display

*For any* tracking data, all children on the ride should be displayed in the timeline view.

**Validates: Requirements 5.5**

### Property 8: Current Child Highlighting

*For any* tracking data, the current child's pickup point should be visually distinct (highlighted) from other pickup points.

**Validates: Requirements 5.6**

### Property 9: Date Grouping

*For any* list of upcoming rides, rides should be grouped by date, and all rides within a group should have the same date.

**Validates: Requirements 6.2**

### Property 10: Seven-Day Filter

*For any* list of upcoming rides, only rides within the next 7 days from today should be included.

**Validates: Requirements 6.3**

### Property 11: Summary Data Consistency

*For any* ride summary data, the total count should equal the sum of all status counts (completed + cancelled + absent), and the total should also equal the sum of period counts (morning + afternoon).

**Validates: Requirements 7.2, 7.3, 7.4, 7.6**

### Property 12: Absence Status Update

*For any* successful absence report, the corresponding ride's status should be updated to "excused" in the local state.

**Validates: Requirements 8.4**

### Property 13: Data Refresh Consistency

*For any* refresh operation that completes successfully, the new data should completely replace the old data in the UI state.

**Validates: Requirements 9.4**

### Property 14: Error State Completeness

*For any* error state, the UI should provide both an error message and a retry option.

**Validates: Requirements 10.4, 10.5**

### Property 15: Localization Correctness

*For any* displayable text (ride status, dates, times), the text should be formatted according to the currently selected locale, and Arabic text should use RTL layout direction.

**Validates: Requirements 11.2, 11.3, 11.5**

### Property 16: State Immutability

*For any* state change in a Cubit, the new state object should be a different instance than the previous state object (immutability).

**Validates: Requirements 12.5**

### Property 17: Error State Emission

*For any* error that occurs during data fetching or processing, the Cubit should emit an error state containing a descriptive error message.

**Validates: Requirements 12.6**

### Property 18: JSON Parsing Correctness

*For any* valid JSON response from the API endpoints, parsing should succeed and produce the correct response model (ChildrenWithAllRidesResponse, SingleChildRidesResponse, ActiveRidesResponse, UpcomingRidesGroupedResponse, NewRideSummaryResponse, NewRideTrackingResponse) with all fields correctly mapped.

**Validates: Requirements 15.1, 15.2, 15.3, 15.4, 15.5, 15.6**

## Error Handling

### Error Categories

The application handles errors at multiple layers with specific strategies for each category:

#### 1. Network Errors

**Scenarios:**
- No internet connection
- Request timeout
- DNS resolution failure

**Handling Strategy:**
- Display user-friendly message: "Please check your internet connection"
- Provide retry button
- Retain previous data if available
- Log error details for debugging

**Implementation:**
```dart
try {
  final response = await _ridesService.getChildrenWithAllRides();
  return response.data.children;
} on DioException catch (e) {
  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.connectionError) {
    throw NetworkException('Please check your internet connection');
  }
  rethrow;
}
```

#### 2. Authentication Errors

**Scenarios:**
- Expired token
- Invalid credentials
- Unauthorized access (401, 403)

**Handling Strategy:**
- Clear local authentication data
- Navigate to login screen
- Display message: "Your session has expired. Please log in again"
- Log error for security monitoring

**Implementation:**
```dart
if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
  await _authRepository.clearAuth();
  throw AuthenticationException('Your session has expired');
}
```

#### 3. Server Errors

**Scenarios:**
- Internal server error (500)
- Service unavailable (503)
- Bad gateway (502)

**Handling Strategy:**
- Display message: "The server is temporarily unavailable. Please try again later"
- Provide retry button
- Retain previous data if available
- Log error with request details

**Implementation:**
```dart
if (e.response?.statusCode != null && e.response!.statusCode! >= 500) {
  throw ServerException('The server is temporarily unavailable');
}
```

#### 4. Data Parsing Errors

**Scenarios:**
- Invalid JSON format
- Missing required fields
- Type mismatch

**Handling Strategy:**
- Display message: "Unable to process data. Please try again"
- Log detailed parsing error with context
- Provide retry button
- Do not crash the app

**Implementation:**
```dart
try {
  return ChildrenWithAllRidesResponse.fromJson(response.data);
} catch (e) {
  logger.error('Failed to parse children response', error: e, context: response.data);
  throw DataParsingException('Unable to process data');
}
```

#### 5. Business Logic Errors

**Scenarios:**
- Invalid child ID
- Ride not found
- Cannot report absence for past ride

**Handling Strategy:**
- Display specific error message from API
- Provide appropriate action (go back, refresh, etc.)
- Log error with business context

**Implementation:**
```dart
if (e.response?.statusCode == 404) {
  throw NotFoundException('Ride not found');
}
if (e.response?.statusCode == 400) {
  final message = e.response?.data['message'] ?? 'Invalid request';
  throw BusinessLogicException(message);
}
```

### Error State Management

Each Cubit has a dedicated error state:

```dart
class RidesDashboardError extends RidesDashboardState {
  final String message;
  final bool canRetry;
  final VoidCallback? onRetry;
  
  const RidesDashboardError({
    required this.message,
    this.canRetry = true,
    this.onRetry,
  });
}
```

### Error Logging

All errors are logged with context for debugging:

```dart
void _logError(String operation, dynamic error, StackTrace? stackTrace) {
  logger.error(
    'Rides operation failed: $operation',
    error: error,
    stackTrace: stackTrace,
    context: {
      'timestamp': DateTime.now().toIso8601String(),
      'operation': operation,
    },
  );
}
```

### User-Facing Error Messages

Error messages are localized and user-friendly:

```dart
String getErrorMessage(Exception error, AppLocalizations l10n) {
  if (error is NetworkException) {
    return l10n.errorNoInternet;
  } else if (error is AuthenticationException) {
    return l10n.errorSessionExpired;
  } else if (error is ServerException) {
    return l10n.errorServerUnavailable;
  } else if (error is DataParsingException) {
    return l10n.errorDataProcessing;
  } else if (error is NotFoundException) {
    return l10n.errorNotFound;
  } else if (error is BusinessLogicException) {
    return error.message;
  } else {
    return l10n.errorGeneric;
  }
}
```

## Testing Strategy

### Dual Testing Approach

The testing strategy combines unit tests and property-based tests to ensure comprehensive coverage:

- **Unit tests**: Verify specific examples, edge cases, and error conditions
- **Property tests**: Verify universal properties across all inputs
- Both approaches are complementary and necessary for comprehensive coverage

### Unit Testing

Unit tests focus on:
- Specific examples that demonstrate correct behavior
- Edge cases (empty data, no active rides, parsing errors)
- Error conditions (network failures, authentication errors, server errors)
- Integration points between layers (Service → Repository → Cubit)

**Example Unit Tests:**

```dart
// Test specific example
test('should fetch children with rides successfully', () async {
  // Arrange
  final mockResponse = ChildrenWithAllRidesResponse(...);
  when(() => mockService.getChildrenWithAllRides())
      .thenAnswer((_) async => mockResponse);
  
  // Act
  final result = await repository.getChildrenWithAllRides();
  
  // Assert
  expect(result, equals(mockResponse.data.children));
});

// Test edge case
test('should return empty list when no children', () async {
  // Arrange
  final emptyResponse = ChildrenWithAllRidesResponse(
    success: true,
    data: ChildrenWithAllRidesData(children: []),
  );
  when(() => mockService.getChildrenWithAllRides())
      .thenAnswer((_) async => emptyResponse);
  
  // Act
  final result = await repository.getChildrenWithAllRides();
  
  // Assert
  expect(result, isEmpty);
});

// Test error condition
test('should throw NetworkException on connection error', () async {
  // Arrange
  when(() => mockService.getChildrenWithAllRides())
      .thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionError,
      ));
  
  // Act & Assert
  expect(
    () => repository.getChildrenWithAllRides(),
    throwsA(isA<NetworkException>()),
  );
});
```

### Property-Based Testing

Property-based tests verify universal properties across many generated inputs. We'll use the `test` package with custom generators for property-based testing in Dart.

**Configuration:**
- Minimum 100 iterations per property test
- Each test references its design document property
- Tag format: **Feature: rides-flow-refactoring, Property {number}: {property_text}**

**Property Test Library:**
We'll implement a simple property-based testing framework using Dart's built-in `test` package with custom generators, or use the `fast_check` package if available for Dart.

**Example Property Tests:**

```dart
// Property 2: Count Accuracy
test('Property 2: Count Accuracy - displayed count equals actual count', () {
  // Feature: rides-flow-refactoring, Property 2: Count Accuracy
  
  for (int i = 0; i < 100; i++) {
    // Generate random list of children
    final children = generateRandomChildren(count: Random().nextInt(20));
    
    // Create state with children
    final state = RidesDashboardLoaded(
      children: children,
      activeRides: [],
    );
    
    // Assert count matches
    expect(state.childrenCount, equals(children.length));
  }
});

// Property 11: Summary Data Consistency
test('Property 11: Summary Data Consistency - totals match sums', () {
  // Feature: rides-flow-refactoring, Property 11: Summary Data Consistency
  
  for (int i = 0; i < 100; i++) {
    // Generate random summary data
    final completed = Random().nextInt(50);
    final cancelled = Random().nextInt(20);
    final absent = Random().nextInt(30);
    final morning = Random().nextInt(60);
    final afternoon = Random().nextInt(40);
    
    final summary = NewRideSummary(
      total: completed + cancelled + absent,
      byStatus: SummaryByStatus(
        completed: completed,
        cancelled: cancelled,
        absent: absent,
      ),
      byPeriod: SummaryByPeriod(
        morning: morning,
        afternoon: afternoon,
      ),
    );
    
    // Assert totals match
    expect(
      summary.total,
      equals(summary.byStatus.completed + 
             summary.byStatus.cancelled + 
             summary.byStatus.absent),
    );
    expect(
      summary.total,
      equals(summary.byPeriod.morning + summary.byPeriod.afternoon),
    );
  }
});

// Property 18: JSON Parsing Correctness
test('Property 18: JSON Parsing Correctness - valid JSON parses correctly', () {
  // Feature: rides-flow-refactoring, Property 18: JSON Parsing Correctness
  
  for (int i = 0; i < 100; i++) {
    // Generate random valid JSON for children response
    final json = generateValidChildrenResponseJson();
    
    // Parse JSON
    final response = ChildrenWithAllRidesResponse.fromJson(json);
    
    // Assert all fields are correctly mapped
    expect(response.success, isNotNull);
    expect(response.data, isNotNull);
    expect(response.data.children, isA<List<ChildWithAllRides>>());
    
    // Verify each child has required fields
    for (final child in response.data.children) {
      expect(child.id, isNotEmpty);
      expect(child.name, isNotEmpty);
      expect(child.grade, isNotEmpty);
    }
  }
});
```

### Test Organization

```
test/
├── unit/
│   ├── services/
│   │   └── rides_service_test.dart
│   ├── repositories/
│   │   └── rides_repository_test.dart
│   ├── cubits/
│   │   ├── rides_dashboard_cubit_test.dart
│   │   ├── child_rides_cubit_test.dart
│   │   ├── ride_tracking_cubit_test.dart
│   │   └── report_absence_cubit_test.dart
│   └── models/
│       └── response_models_test.dart
├── property/
│   ├── count_accuracy_test.dart
│   ├── summary_consistency_test.dart
│   ├── json_parsing_test.dart
│   ├── state_immutability_test.dart
│   └── localization_test.dart
├── integration/
│   └── rides_flow_integration_test.dart
└── helpers/
    ├── generators.dart
    └── test_data.dart
```

### Coverage Goals

- Unit test coverage: Minimum 80% for business logic
- Property test coverage: All 18 correctness properties
- Integration test coverage: Critical user flows (dashboard → child schedule → tracking)
- Edge case coverage: All error scenarios and empty states

### Continuous Integration

Tests should run automatically on:
- Every commit (unit tests)
- Pull requests (unit + property tests)
- Pre-release (full test suite including integration tests)

### Test Data Generators

Create reusable generators for property-based tests:

```dart
// Generate random child data
ChildWithAllRides generateRandomChild() {
  return ChildWithAllRides(
    id: generateRandomId(),
    name: generateRandomName(),
    avatar: generateRandomAvatar(),
    grade: generateRandomGrade(),
    classroom: generateRandomClassroom(),
    organization: generateRandomOrganization(),
    rides: generateRandomChildRidesInfo(),
  );
}

// Generate random list of children
List<ChildWithAllRides> generateRandomChildren({required int count}) {
  return List.generate(count, (_) => generateRandomChild());
}

// Generate valid JSON for API responses
Map<String, dynamic> generateValidChildrenResponseJson() {
  return {
    'success': true,
    'data': {
      'children': List.generate(
        Random().nextInt(10) + 1,
        (_) => generateRandomChildJson(),
      ),
    },
  };
}
```

