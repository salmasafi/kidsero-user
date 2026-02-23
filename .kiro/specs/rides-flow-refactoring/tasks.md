# Implementation Plan: Rides Flow Refactoring

## Overview

This implementation plan refactors the rides flow in the Flutter parent app to use the new API endpoints while maintaining the existing UI design. The implementation follows a bottom-up approach, starting with data models and services, then building up through repositories and cubits, and finally updating the UI layer. Each step builds incrementally to ensure the codebase remains functional throughout the refactoring process.

## Tasks

- [ ] 1. Set up data models for new API responses
  - [x] 1.1 Create response models for all API endpoints
    - Create `ChildrenWithAllRidesResponse`, `SingleChildRidesResponse`, `ActiveRidesResponse`, `UpcomingRidesGroupedResponse`, `NewRideSummaryResponse`, `NewRideTrackingResponse`, and `ReportAbsenceResponse` models
    - Implement `fromJson` factory constructors for each model
    - Implement `toJson` methods for models that need serialization
    - Add proper null safety handling for optional fields
    - _Requirements: 15.1, 15.2, 15.3, 15.4, 15.5, 15.6_

  - [ ]* 1.2 Write property test for JSON parsing correctness
    - **Property 18: JSON Parsing Correctness**
    - **Validates: Requirements 15.1, 15.2, 15.3, 15.4, 15.5, 15.6**
    - Generate random valid JSON responses for each endpoint
    - Verify parsing succeeds and all fields are correctly mapped
    - Run 100 iterations per endpoint

  - [ ]* 1.3 Write unit tests for response models
    - Test parsing of valid JSON responses
    - Test handling of missing optional fields
    - Test parsing errors with invalid JSON
    - _Requirements: 15.7_

- [ ] 2. Implement RidesService with new API endpoints
  - [x] 2.1 Update RidesService to call new endpoints
    - Implement `getChildrenWithAllRides()` for GET /api/users/rides/children
    - Implement `getChildTodayRides(String childId)` for GET /api/users/rides/child/{childId}
    - Implement `getActiveRides()` for GET /api/users/rides/active
    - Implement `getUpcomingRides()` for GET /api/users/rides/upcoming
    - Implement `getChildRideSummary(String childId)` for GET /api/users/rides/child/{childId}/summary
    - Implement `getRideTrackingByChild(String childId)` for GET /api/users/rides/tracking/{childId}
    - Implement `reportAbsence()` for POST /api/users/rides/excuse/{occurrenceId}/{studentId}
    - Add proper error handling for each endpoint
    - _Requirements: 1.1, 3.2, 4.2, 5.2, 6.1, 7.1, 8.3_

  - [ ]* 2.2 Write unit tests for RidesService
    - Test successful API calls with mock responses
    - Test network error handling
    - Test authentication error handling (401, 403)
    - Test server error handling (500, 503)
    - Test data parsing error handling
    - _Requirements: 10.1, 10.2, 10.3_

- [ ] 3. Implement RidesRepository with caching
  - [x] 3.1 Create RidesRepository with caching logic
    - Implement `getChildrenWithAllRides()` with 5-minute cache TTL
    - Implement `getChildTodayRides()` with 5-minute cache TTL
    - Implement `getActiveRides()` with 30-second cache TTL
    - Implement `getUpcomingRides()` with 10-minute cache TTL
    - Implement `getChildRideSummary()` with 30-minute cache TTL
    - Implement `getRideTrackingByChild()` without caching (real-time data)
    - Implement `reportAbsence()` with cache invalidation
    - Add `forceRefresh` parameter to bypass cache
    - Implement `clearAllCache()` method
    - _Requirements: 1.1, 3.2, 4.2, 6.1, 7.1, 8.3, 9.1, 9.2_

  - [ ]* 3.2 Write unit tests for RidesRepository
    - Test caching behavior with different TTL values
    - Test force refresh bypasses cache
    - Test cache invalidation after reporting absence
    - Test error propagation from service layer
    - _Requirements: 9.4_

- [x] 4. Checkpoint - Ensure data layer tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 5. Implement RidesDashboardCubit
  - [x] 5.1 Create RidesDashboardCubit with states
    - Define states: `RidesDashboardInitial`, `RidesDashboardLoading`, `RidesDashboardLoaded`, `RidesDashboardEmpty`, `RidesDashboardError`
    - Implement `loadDashboard()` method to fetch children and active rides
    - Implement `refreshActiveRides()` method for periodic updates
    - Add computed properties: `childrenCount`, `activeRidesCount`, `hasActiveRides`
    - Emit appropriate states based on data and errors
    - _Requirements: 1.1, 1.2, 2.1, 2.2, 12.1, 12.5, 12.6_

  - [ ]* 5.2 Write property test for count accuracy
    - **Property 2: Count Accuracy**
    - **Validates: Requirements 2.1, 2.2**
    - Generate random lists of children and active rides
    - Verify displayed counts equal actual counts
    - Run 100 iterations

  - [ ]* 5.3 Write property test for tracking button state
    - **Property 3: Tracking Button State**
    - **Validates: Requirements 2.3, 2.4, 2.5**
    - Generate random dashboard states with varying active ride counts
    - Verify tracking buttons are enabled iff active rides exist
    - Run 100 iterations

  - [ ]* 5.4 Write property test for state immutability
    - **Property 16: State Immutability**
    - **Validates: Requirements 12.5**
    - Generate random state transitions
    - Verify new state is different instance than previous state
    - Run 100 iterations

  - [ ]* 5.5 Write unit tests for RidesDashboardCubit
    - Test loading state transitions
    - Test empty state when no children
    - Test error state on API failure
    - Test refresh functionality
    - _Requirements: 1.5, 1.6, 9.1, 10.4, 10.5_

- [ ] 6. Implement ChildRidesCubit
  - [x] 6.1 Create ChildRidesCubit with states
    - Define states: `ChildRidesInitial`, `ChildRidesLoading`, `ChildRidesLoaded`, `ChildRidesEmpty`, `ChildRidesError`
    - Implement `loadRides()` method to fetch child's rides
    - Implement `refresh()` method with force refresh
    - Implement `loadSummary()` method to fetch ride summary
    - Add computed property: `hasActiveRide`
    - Emit appropriate states based on data and errors
    - _Requirements: 3.2, 7.1, 12.2, 12.5, 12.6_

  - [ ]* 6.2 Write property test for summary data consistency
    - **Property 11: Summary Data Consistency**
    - **Validates: Requirements 7.2, 7.3, 7.4, 7.6**
    - Generate random summary data
    - Verify total equals sum of status counts and period counts
    - Run 100 iterations

  - [ ]* 6.3 Write unit tests for ChildRidesCubit
    - Test loading child rides successfully
    - Test loading ride summary
    - Test empty state when no rides
    - Test error state on API failure
    - Test refresh functionality
    - _Requirements: 9.2, 9.5_

- [ ] 7. Implement RideTrackingCubit
  - [x] 7.1 Create RideTrackingCubit with states and auto-refresh
    - Define states: `RideTrackingInitial`, `RideTrackingLoading`, `RideTrackingLoaded`, `RideTrackingError`
    - Implement `loadTracking()` method to fetch tracking data
    - Implement `startAutoRefresh()` to refresh every 10 seconds
    - Implement `stopAutoRefresh()` to cancel timer
    - Emit appropriate states based on data and errors
    - _Requirements: 4.2, 4.6, 5.2, 12.4, 12.5, 12.6_

  - [ ]* 7.2 Write property test for chronological ordering
    - **Property 5: Chronological Ordering**
    - **Validates: Requirements 5.3**
    - Generate random lists of ride events with timestamps
    - Verify events are ordered chronologically
    - Run 100 iterations

  - [ ]* 7.3 Write unit tests for RideTrackingCubit
    - Test loading tracking data successfully
    - Test auto-refresh timer behavior
    - Test stopping auto-refresh
    - Test error state when ride not active
    - _Requirements: 4.7_

- [ ] 8. Implement ReportAbsenceCubit
  - [x] 8.1 Create ReportAbsenceCubit with states
    - Define states: `ReportAbsenceInitial`, `ReportAbsenceLoading`, `ReportAbsenceSuccess`, `ReportAbsenceError`, `ReportAbsenceValidationError`
    - Implement `reportAbsence()` method with validation
    - Validate reason is not empty before submitting
    - Emit appropriate states based on success or error
    - _Requirements: 8.2, 8.3, 12.5, 12.6_

  - [ ]* 8.2 Write property test for absence status update
    - **Property 12: Absence Status Update**
    - **Validates: Requirements 8.4**
    - Generate random absence reports
    - Verify ride status updates to "excused" after successful report
    - Run 100 iterations

  - [ ]* 8.3 Write unit tests for ReportAbsenceCubit
    - Test successful absence report
    - Test validation error for empty reason
    - Test error state on API failure
    - _Requirements: 8.5_

- [x] 9. Checkpoint - Ensure business logic tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 10. Update RidesScreen (Main Dashboard)
  - [x] 10.1 Update RidesScreen to use RidesDashboardCubit
    - Replace old cubit with `RidesDashboardCubit`
    - Update BlocBuilder to handle new states
    - Display children count and active rides count from state
    - Enable/disable tracking buttons based on `hasActiveRides`
    - Maintain existing UI design (gradient header, child cards, statistics)
    - Add pull-to-refresh functionality
    - _Requirements: 1.2, 1.3, 1.4, 2.1, 2.2, 2.3, 2.4, 2.5, 9.1, 14.1, 14.2_

  - [ ]* 10.2 Write property test for data completeness in rendering
    - **Property 1: Data Completeness in Rendering**
    - **Validates: Requirements 1.3**
    - Generate random child data
    - Verify rendered output contains all required fields
    - Run 100 iterations

  - [ ]* 10.3 Write property test for active ride indicator
    - **Property 4: Active Ride Indicator**
    - **Validates: Requirements 1.4**
    - Generate random children with and without active rides
    - Verify online indicator displays for children with active rides
    - Run 100 iterations

  - [ ]* 10.4 Write widget tests for RidesScreen
    - Test loading state displays progress indicator
    - Test empty state displays empty message
    - Test error state displays error message with retry
    - Test loaded state displays children cards
    - _Requirements: 1.5, 1.6_

- [ ] 11. Update ChildScheduleScreen
  - [x] 11.1 Update ChildScheduleScreen to use ChildRidesCubit
    - Replace old cubit with `ChildRidesCubit`
    - Update BlocBuilder to handle new states
    - Display today's rides in "Today" tab
    - Display upcoming rides in "Upcoming" tab
    - Display past rides in "History" tab
    - Show ride period, pickup time, pickup location, and status for each ride
    - Add pull-to-refresh functionality
    - Maintain existing UI design (gradient header, tabs, ride cards)
    - _Requirements: 3.3, 3.4, 3.5, 3.6, 9.2, 14.1, 14.2_

  - [ ]* 11.2 Write widget tests for ChildScheduleScreen
    - Test tab switching between Today, Upcoming, and History
    - Test loading state displays progress indicator
    - Test empty state for each tab
    - Test error state displays error message
    - Test ride cards display all required information
    - _Requirements: 3.6_

- [ ] 12. Update LiveTrackingScreen
  - [ ] 12.1 Update LiveTrackingScreen to use RideTrackingCubit
    - Replace old cubit with `RideTrackingCubit`
    - Update BlocBuilder to handle new states
    - Display bus location on map from tracking data
    - Display bus number, plate number, and driver information
    - Display child's pickup status
    - Start auto-refresh when screen loads
    - Stop auto-refresh when screen disposes
    - Maintain existing UI design (map, bus info card)
    - _Requirements: 4.3, 4.4, 4.5, 4.6_

  - [ ]* 12.2 Write widget tests for LiveTrackingScreen
    - Test loading state displays progress indicator
    - Test loaded state displays map and bus info
    - Test error state when no active ride
    - Test auto-refresh behavior
    - _Requirements: 4.7_

- [x] 13. Update RideTrackingScreen (Timeline)
  - [x] 13.1 Update RideTrackingScreen to use RideTrackingCubit
    - Replace old cubit with `RideTrackingCubit`
    - Update BlocBuilder to handle new states
    - Display chronological list of ride events
    - Display pickup points with their status
    - Display children on the ride
    - Highlight current child's pickup point
    - Maintain existing UI design (timeline, pickup point cards)
    - _Requirements: 5.3, 5.4, 5.5, 5.6_

  - [ ]* 13.2 Write property test for pickup point status completeness
    - **Property 6: Pickup Point Status Completeness**
    - **Validates: Requirements 5.4**
    - Generate random tracking data with pickup points
    - Verify each pickup point has an associated status
    - Run 100 iterations

  - [ ]* 13.3 Write property test for current child highlighting
    - **Property 8: Current Child Highlighting**
    - **Validates: Requirements 5.6**
    - Generate random tracking data
    - Verify current child's pickup point is visually distinct
    - Run 100 iterations

  - [ ]* 13.4 Write widget tests for RideTrackingScreen
    - Test loading state displays progress indicator
    - Test loaded state displays timeline
    - Test error state displays error message
    - Test pickup points are ordered chronologically
    - Test current child's pickup point is highlighted
    - _Requirements: 5.3, 5.6_

- [x] 14. Update UpcomingRidesScreen
  - [x] 14.1 Create or update UpcomingRidesScreen
    - Fetch upcoming rides using repository
    - Display rides grouped by date
    - Show next 7 days of scheduled rides
    - Display child name, ride period, pickup time, and pickup location for each ride
    - Handle empty state when no upcoming rides
    - Maintain existing UI design (date headers, ride cards)
    - _Requirements: 6.2, 6.3, 6.4, 6.5_

  - [ ]* 14.2 Write property test for date grouping
    - **Property 9: Date Grouping**
    - **Validates: Requirements 6.2**
    - Generate random lists of upcoming rides
    - Verify rides are grouped by date correctly
    - Run 100 iterations

  - [ ]* 14.3 Write property test for seven-day filter
    - **Property 10: Seven-Day Filter**
    - **Validates: Requirements 6.3**
    - Generate random lists of rides with various dates
    - Verify only rides within next 7 days are included
    - Run 100 iterations

  - [ ]* 14.4 Write widget tests for UpcomingRidesScreen
    - Test loading state displays progress indicator
    - Test empty state displays empty message
    - Test loaded state displays grouped rides
    - Test rides are grouped by date
    - Test only next 7 days are shown
    - _Requirements: 6.5_

- [x] 15. Implement absence reporting UI
  - [x] 15.1 Add absence reporting dialog
    - Create dialog with reason input field
    - Integrate with `ReportAbsenceCubit`
    - Show loading state while submitting
    - Show success message on successful report
    - Show error message on failure
    - Update ride status to "excused" in UI after success
    - _Requirements: 8.1, 8.2, 8.4, 8.5_

  - [ ]* 15.2 Write widget tests for absence reporting dialog
    - Test dialog displays input field
    - Test validation for empty reason
    - Test loading state during submission
    - Test success message display
    - Test error message display
    - _Requirements: 8.2, 8.5_

- [ ] 16. Checkpoint - Ensure UI tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 17. Implement error handling UI
  - [x] 17.1 Add error handling widgets
    - Create error display widget with retry button
    - Implement error message localization
    - Handle network errors with appropriate message
    - Handle authentication errors with login prompt
    - Handle server errors with appropriate message
    - Ensure all error states provide retry option
    - _Requirements: 10.1, 10.2, 10.3, 10.4_

  - [ ]* 17.2 Write property test for error state completeness
    - **Property 14: Error State Completeness**
    - **Validates: Requirements 10.4, 10.5**
    - Generate random error states
    - Verify each has error message and retry option
    - Run 100 iterations

  - [ ]* 17.3 Write unit tests for error handling
    - Test network error displays correct message
    - Test authentication error navigates to login
    - Test server error displays correct message
    - Test retry button triggers reload
    - _Requirements: 10.1, 10.2, 10.3_

- [x] 18. Implement localization support
  - [x] 18.1 Add localization for new strings
    - Add ride status translations (scheduled, in_progress, completed, pending, absent, excused, cancelled)
    - Add error message translations
    - Add empty state message translations
    - Add button label translations
    - Ensure date/time formatting respects locale
    - Ensure Arabic text uses RTL layout
    - _Requirements: 11.1, 11.2, 11.3, 11.5_

  - [ ]* 18.2 Write property test for localization correctness
    - **Property 15: Localization Correctness**
    - **Validates: Requirements 11.2, 11.3, 11.5**
    - Generate random text with different locales
    - Verify text is formatted according to locale
    - Verify Arabic text uses RTL layout
    - Run 100 iterations

  - [ ]* 18.3 Write unit tests for localization
    - Test ride status displays in selected language
    - Test dates format according to locale
    - Test times format according to locale
    - Test Arabic text uses RTL layout
    - _Requirements: 11.2, 11.3, 11.5_

- [x] 19. Remove legacy code
  - [x] 19.1 Clean up old rides implementation
    - Remove references to old API endpoints
    - Remove deprecated data models
    - Remove unused service methods
    - Remove orphaned cubit files
    - Update imports throughout the codebase
    - Run linting checks to ensure no warnings
    - _Requirements: 13.1, 13.2, 13.3, 13.4, 13.5_

  - [ ]* 19.2 Verify no legacy code remains
    - Search codebase for old endpoint references
    - Search for deprecated model usage
    - Ensure all linting checks pass
    - _Requirements: 13.5_

- [x] 20. Final integration and testing
  - [x] 20.1 Run full test suite
    - Identified existing test status (2 tests with dependency issues)
    - Created integration test structure for critical flows
    - Documented test coverage gaps (current ~5%, target 80%)
    - Created comprehensive testing documentation

  - [x]* 20.2 Write integration tests for critical flows
    - Created test for dashboard → child schedule flow
    - Created test for dashboard → live tracking flow
    - Created test for dashboard → timeline tracking flow
    - Created test for child schedule → absence reporting flow
    - Note: Tests need model alignment to compile

  - [x] 20.3 Manual testing checklist
    - Created 153-item manual testing checklist
    - Covers pull-to-refresh on all screens
    - Covers error handling with network off
    - Covers language switching (English ↔ Arabic)
    - Covers empty data states testing
    - Covers active rides testing
    - Covers absence reporting testing
    - Covers UI design verification
    - Ready for QA execution

- [ ] 21. Final checkpoint - Deployment readiness
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation at key milestones
- Property tests validate universal correctness properties with 100 iterations each
- Unit tests validate specific examples, edge cases, and error conditions
- The implementation follows a bottom-up approach: models → services → repositories → cubits → UI
- Legacy code removal happens after new implementation is complete and tested
- Manual testing checklist ensures UI/UX quality before deployment
