# Implementation Tasks: Rides and Children Re-implementation

## 1. Data Layer - Children Module

### 1.1 Create Child Model
- [x] 1.1.1 Create `child_model.dart` with fields: id, name, grade, school, photo, code, parentId
- [x] 1.1.2 Implement `fromJson` factory constructor for API response parsing
- [ ] 1.1.3 Implement `toJson` method for serialization
- [x] 1.1.4 Add null safety handling for optional fields

### 1.2 Create Children API Service
- [x] 1.2.1 Create `children_api_service.dart` in `lib/features/children/data/services/`
- [x] 1.2.2 Implement `fetchChildren()` method calling `/api/users/children/`
- [x] 1.2.3 Implement `addChildByCode(String code)` method calling `/api/users/children/add`
- [x] 1.2.4 Add authentication token handling using existing `CacheHelper`
- [x] 1.2.5 Add error handling for network failures and HTTP error codes

### 1.3 Create Children Repository
- [x] 1.3.1 Create `children_repository.dart` in `lib/features/children/data/repositories/`
- [x] 1.3.2 Implement `getChildren()` method that calls API service and returns List<ChildModel>
- [x] 1.3.3 Implement `addChild(String code)` method that calls API service
- [x] 1.3.4 Add error transformation from API exceptions to user-friendly messages
- [x] 1.3.5 Add logging for debugging purposes

## 2. Business Logic - Children Module

### 2.1 Create Children Cubit States
- [x] 2.1.1 Define `ChildrenState` sealed class with states: Initial, Loading, Success, Error
- [x] 2.1.2 Add `ChildrenSuccess` state with `List<ChildModel> children` field
- [x] 2.1.3 Add `ChildrenError` state with `String message` field
- [x] 2.1.4 Add `ChildrenAddingChild` state for add operation loading

### 2.2 Implement Children Cubit
- [x] 2.2.1 Create `children_cubit.dart` in `lib/features/children/logic/`
- [x] 2.2.2 Implement `fetchChildren()` method that calls repository and emits states
- [x] 2.2.3 Implement `addChild(String code)` method that calls repository and refreshes list
- [x] 2.2.4 Add error handling that emits appropriate error states
- [ ] 2.2.5 Add automatic retry logic for network failures (max 3 attempts)

## 3. UI Layer - Children Module

### 3.1 Update Children List Screen
- [x] 3.1.1 Update `children_screen.dart` to use new `ChildrenCubit`
- [x] 3.1.2 Implement BlocBuilder to handle all cubit states
- [x] 3.1.3 Display loading indicator for Loading state
- [x] 3.1.4 Display children list using existing `ChildCard` widget for Success state
- [x] 3.1.5 Display error message with retry button for Error state
- [x] 3.1.6 Display empty state message when children list is empty
- [x] 3.1.7 Add pull-to-refresh functionality

### 3.2 Create Add Child Dialog/Screen
- [x] 3.2.1 Create add child UI with text field for child code input
- [x] 3.2.2 Add form validation for child code (non-empty, alphanumeric)
- [x] 3.2.3 Implement submit button that calls `addChild()` on cubit
- [x] 3.2.4 Display loading indicator during add operation
- [x] 3.2.5 Show success snackbar and close dialog on successful add
- [x] 3.2.6 Show error message in dialog on failure

## 4. Data Layer - Rides Module

### 4.1 Create Ride Models
- [x] 4.1.1 Create `ride_model.dart` with fields: id, childId, date, pickupTime, dropoffTime, status, driverName, busNumber
- [x] 4.1.2 Create `ride_occurrence_model.dart` for specific ride instances
- [x] 4.1.3 Create `ride_summary_model.dart` with fields: totalRides, attendedRides, missedRides, attendancePercentage
- [x] 4.1.4 Implement `fromJson` factory constructors for all models
- [x] 4.1.5 Add enum for ride status: scheduled, in_progress, completed, cancelled, excused

### 4.2 Create Rides API Service
- [x] 4.2.1 Create `rides_api_service.dart` in `lib/features/rides/data/services/`
- [x] 4.2.2 Implement `fetchTodayRides()` calling `/api/users/rides/children/today`
- [x] 4.2.3 Implement `fetchActiveRides()` calling `/api/users/rides/active`
- [x] 4.2.4 Implement `fetchUpcomingRides()` calling `/api/users/rides/upcoming`
- [x] 4.2.5 Implement `fetchChildRides(String childId)` calling `/api/users/rides/child/{childId}`
- [x] 4.2.6 Implement `fetchChildSummary(String childId)` calling `/api/users/rides/child/{childId}/summary`
- [x] 4.2.7 Implement `reportAbsence(String occurrenceId, String studentId, String reason)` calling `/api/users/rides/excuse/{occurrenceId}/{studentId}`
- [x] 4.2.8 Add authentication token handling and error handling

### 4.3 Create Rides Repository
- [x] 4.3.1 Create `rides_repository.dart` in `lib/features/rides/data/repositories/`
- [x] 4.3.2 Implement methods for all API service calls with proper error handling
- [x] 4.3.3 Add data transformation and validation logic
- [x] 4.3.4 Add caching strategy for frequently accessed data
- [x] 4.3.5 Add logging for debugging

## 5. Business Logic - Rides Module

### 5.1 Create Today Rides Cubit
- [x] 5.1.1 Create `today_rides_cubit.dart` with states: Initial, Loading, Success, Error
- [x] 5.1.2 Implement `fetchTodayRides()` method
- [x] 5.1.3 Add automatic refresh every 5 minutes when screen is active
- [x] 5.1.4 Handle error states with retry capability

### 5.2 Create Active Rides Cubit
- [x] 5.2.1 Create `active_rides_cubit.dart` with appropriate states
- [x] 5.2.2 Implement `fetchActiveRides()` method
- [x] 5.2.3 Add automatic refresh every 30 seconds for active rides
- [x] 5.2.4 Handle ride status transitions

### 5.3 Create Upcoming Rides Cubit
- [x] 5.3.1 Create `upcoming_rides_cubit.dart` with appropriate states
- [x] 5.3.2 Implement `fetchUpcomingRides()` method
- [x] 5.3.3 Add date filtering and sorting logic

### 5.4 Create Child Rides Cubit
- [x] 5.4.1 Create `child_rides_cubit.dart` for individual child ride history
- [x] 5.4.2 Implement `fetchChildRides(String childId)` method
- [x] 5.4.3 Implement `fetchChildSummary(String childId)` method
- [x] 5.4.4 Add filtering by date range and status

### 5.5 Create Absence Reporting Cubit
- [x] 5.5.1 Create `report_absence_cubit.dart` with states for absence reporting
- [x] 5.5.2 Implement `reportAbsence(String occurrenceId, String studentId, String reason)` method
- [x] 5.5.3 Add validation for absence reason (non-empty)
- [x] 5.5.4 Add check to prevent reporting for rides that have already started

## 6. UI Layer - Rides Module

### 6.1 Update Today Rides Screen
- [x] 6.1.1 Update `rides_screen.dart` to use new `TodayRidesCubit`
- [x] 6.1.2 Implement BlocBuilder to handle all states
- [x] 6.1.3 Display rides grouped by child using existing `RideCard` widget
- [x] 6.1.4 Add pull-to-refresh functionality
- [x] 6.1.5 Display empty state when no rides today
- [x] 6.1.6 Show cancelled indicator for cancelled rides

### 6.2 Create Active Rides Screen
- [x] 6.2.1 Create or update active rides screen UI
- [x] 6.2.2 Integrate with `ActiveRidesCubit`
- [x] 6.2.3 Display active rides with current status and ETA
- [x] 6.2.4 Add "Track Live" button for each active ride
- [x] 6.2.5 Implement auto-refresh every 30 seconds

### 6.3 Create Upcoming Rides Screen
- [x] 6.3.1 Create or update upcoming rides screen UI
- [x] 6.3.2 Integrate with `UpcomingRidesCubit`
- [x] 6.3.3 Display rides sorted by date and time
- [x] 6.3.4 Add date filtering UI
- [x] 6.3.5 Display empty state when no upcoming rides

### 6.4 Create Child Ride Details Screen
- [x] 6.4.1 Create screen to display individual child ride history
- [x] 6.4.2 Integrate with `ChildRidesCubit`
- [x] 6.4.3 Display ride history list with dates and statuses
- [x] 6.4.4 Display attendance summary card with statistics
- [x] 6.4.5 Add date range filter UI (using upcoming/history sections)

### 6.5 Create Absence Reporting Dialog
- [x] 6.5.1 Create dialog/bottom sheet for absence reporting
- [x] 6.5.2 Add text field for absence reason
- [x] 6.5.3 Integrate with `ReportAbsenceCubit`
- [x] 6.5.4 Add validation and error display
- [x] 6.5.5 Show success message and refresh rides on successful report

## 7. Real-Time Tracking - WebSocket Integration

### 7.1 Create Tracking Models
- [x] 7.1.1 Create `bus_location_model.dart` with fields: latitude, longitude, speed, heading, timestamp
- [x] 7.1.2 Create `tracking_update_model.dart` for WebSocket messages
- [x] 7.1.3 Implement JSON parsing for WebSocket messages

### 7.2 Update WebSocket Service
- [x] 7.2.1 Review existing `socket_service.dart` in `lib/core/network/`
- [x] 7.2.2 Add method `connectToRideTracking(String rideId)` for ride-specific tracking
- [ ] 7.2.3 Implement automatic reconnection logic (max 3 attempts)
- [x] 7.2.4 Add method `disconnectFromRideTracking()` for cleanup
- [x] 7.2.5 Implement message parsing and error handling
- [x] 7.2.6 Add connection state management (connected, disconnected, reconnecting)

### 7.3 Create Live Tracking Cubit
- [x] 7.3.1 Create `live_tracking_cubit.dart` with states: Initial, Connecting, Connected, LocationUpdate, Disconnected, Error
- [x] 7.3.2 Implement `startTracking(String rideId)` method
- [x] 7.3.3 Implement `stopTracking()` method
- [x] 7.3.4 Handle location updates from WebSocket and emit new states
- [x] 7.3.5 Calculate and update ETA based on location updates
- [x] 7.3.6 Handle connection errors and reconnection

### 7.4 Create Live Tracking Screen
- [x] 7.4.1 Create or update `live_tracking_screen.dart`
- [x] 7.4.2 Integrate with `LiveTrackingCubit`
- [x] 7.4.3 Display map with bus marker using existing map widget
- [x] 7.4.4 Update bus marker position on location updates
- [x] 7.4.5 Display bus speed, heading, and ETA
- [x] 7.4.6 Show last known location with timestamp when no updates
- [x] 7.4.7 Display connection status indicator
- [x] 7.4.8 Implement proper cleanup on screen disposal

## 8. Error Handling and User Feedback

### 8.1 Implement Error Handler Utility
- [x] 8.1.1 Review existing `error_handler.dart` in `lib/core/network/`
- [ ] 8.1.2 Add method to convert HTTP status codes to Arabic error messages
- [ ] 8.1.3 Add method to handle network connectivity errors
- [ ] 8.1.4 Add method to handle parsing errors
- [ ] 8.1.5 Ensure all error messages use l10n system

### 8.2 Implement Success Feedback
- [x] 8.2.1 Review existing `custom_snackbar.dart` in `lib/core/widgets/`
- [x] 8.2.2 Ensure success messages are displayed in Arabic
- [ ] 8.2.3 Add 2-second auto-dismiss for success messages
- [x] 8.2.4 Add appropriate icons for success/error states

### 8.3 Add Loading Indicators
- [x] 8.3.1 Review existing `custom_loading.dart` widget
- [x] 8.3.2 Ensure loading indicators are used consistently across all screens
- [ ] 8.3.3 Add loading overlay for blocking operations
- [ ] 8.3.4 Add shimmer loading for list items

## 9. Localization and RTL Support

### 9.1 Add Arabic Translations
- [ ] 9.1.1 Add all new error messages to `lib/l10n/app_ar.arb`
- [ ] 9.1.2 Add all new success messages to `lib/l10n/app_ar.arb`
- [ ] 9.1.3 Add all new UI labels to `lib/l10n/app_ar.arb`
- [ ] 9.1.4 Add ride status labels to `lib/l10n/app_ar.arb`

### 9.2 Verify RTL Layout
- [ ] 9.2.1 Test all new screens with RTL layout
- [ ] 9.2.2 Verify text alignment is correct for Arabic
- [ ] 9.2.3 Verify icons and buttons are positioned correctly in RTL
- [ ] 9.2.4 Test date and time formatting with Arabic locale

## 10. Integration and Testing

### 10.1 Dependency Injection Setup
- [ ] 10.1.1 Register all new repositories in dependency injection container
- [ ] 10.1.2 Register all new cubits in dependency injection container
- [ ] 10.1.3 Register all new services in dependency injection container
- [ ] 10.1.4 Verify proper lifecycle management for cubits

### 10.2 Navigation Integration
- [x] 10.2.1 Update routing configuration to include new screens
- [x] 10.2.2 Add navigation from children list to child details
- [x] 10.2.3 Add navigation from active rides to live tracking
- [x] 10.2.4 Verify back navigation works correctly

### 10.3 Manual Testing
- [ ] 10.3.1 Test children list fetch and display
- [ ] 10.3.2 Test add child by code with valid and invalid codes
- [ ] 10.3.3 Test today's rides display with various scenarios
- [ ] 10.3.4 Test active rides display and refresh
- [ ] 10.3.5 Test upcoming rides display and filtering
- [ ] 10.3.6 Test child ride history and summary
- [ ] 10.3.7 Test absence reporting with validation
- [ ] 10.3.8 Test live tracking WebSocket connection and updates
- [ ] 10.3.9 Test error scenarios (network failure, 401, 404, 500)
- [ ] 10.3.10 Test app behavior when returning from background

### 10.4 Performance Testing
- [ ] 10.4.1 Verify no memory leaks from WebSocket connections
- [ ] 10.4.2 Verify cubits are properly disposed
- [ ] 10.4.3 Test app performance with large lists of children/rides
- [ ] 10.4.4 Verify smooth scrolling and animations

## 11. Documentation and Cleanup

### 11.1 Code Documentation
- [ ] 11.1.1 Add dartdoc comments to all public APIs
- [ ] 11.1.2 Document complex business logic
- [ ] 11.1.3 Add inline comments for non-obvious code

### 11.2 Cleanup
- [ ] 11.2.1 Remove any old/unused children and rides code
- [ ] 11.2.2 Remove debug print statements
- [ ] 11.2.3 Verify no TODO comments remain
- [ ] 11.2.4 Run dart format on all new/modified files
- [ ] 11.2.5 Run dart analyze and fix any warnings

### 11.3 Final Verification
- [ ] 11.3.1 Verify all requirements are met
- [ ] 11.3.2 Verify all acceptance criteria are satisfied
- [ ] 11.3.3 Create summary document of changes
- [ ] 11.3.4 Update README if necessary
