# Implementation Plan: Child Schedule Tab Switching Fix

## Overview

This implementation plan addresses the tab switching bug in the child schedule screen by restructuring the widget tree to ensure local state changes trigger proper rebuilds. The fix involves moving `BlocBuilder` widgets from wrapping the entire content area to being inside individual tab content methods, allowing the outer widget tree to respond to `setState()` calls while maintaining proper Bloc state management.

## Tasks

- [x] 1. Restructure widget tree to fix tab switching
  - [x] 1.1 Modify `_ChildScheduleViewState.build()` method
    - Remove `BlocBuilder<ChildRidesCubit>` from wrapping the content area
    - Keep `BlocConsumer<ReportAbsenceCubit>` wrapper for absence reporting
    - Call `_buildTabContent()` directly without passing state parameter
    - _Requirements: 1.4, 1.5, 2.1, 2.3_
  
  - [x] 1.2 Update `_buildTabContent()` method signature and implementation
    - Remove `ChildRidesLoaded state` parameter from method signature
    - Update method to accept only `BuildContext context` and `AppLocalizations l10n`
    - Update switch statement to call tab methods without state parameter
    - Remove debug print statement
    - _Requirements: 1.1, 1.2, 1.3, 1.4_
  
  - [x] 1.3 Refactor `_buildUpcomingTab()` to handle Bloc state internally
    - Remove `ChildRidesLoaded state` parameter from method signature
    - Wrap entire method body with `BlocBuilder<ChildRidesCubit, ChildRidesState>`
    - Add handling for `ChildRidesLoading` state (return CircularProgressIndicator)
    - Add handling for `ChildRidesError` state (return CustomEmptyState with error)
    - Add handling for `ChildRidesEmpty` state (return CustomEmptyState)
    - Keep existing `ChildRidesLoaded` state handling with ride list
    - Maintain RefreshIndicator and pull-to-refresh functionality
    - _Requirements: 1.1, 3.1, 4.1, 4.3, 4.4_
  
  - [x] 1.4 Refactor `_buildTodayTab()` to handle Bloc state internally
    - Remove `ChildRidesLoaded state` parameter from method signature
    - Wrap entire method body with `BlocBuilder<ChildRidesCubit, ChildRidesState>`
    - Add handling for `ChildRidesLoading` state (return CircularProgressIndicator)
    - Add handling for `ChildRidesError` state (return CustomEmptyState with error)
    - Add handling for `ChildRidesEmpty` state (return CustomEmptyState)
    - Keep existing date filtering logic for today's rides
    - Maintain RefreshIndicator and pull-to-refresh functionality
    - _Requirements: 1.2, 3.2, 3.4, 4.1, 4.3, 4.4_
  
  - [x] 1.5 Refactor `_buildHistoryTab()` to handle Bloc state internally
    - Remove `ChildRidesLoaded state` parameter from method signature
    - Wrap entire method body with `BlocBuilder<ChildRidesCubit, ChildRidesState>`
    - Add handling for `ChildRidesLoading` state (return CircularProgressIndicator)
    - Add handling for `ChildRidesError` state (return CustomEmptyState with error)
    - Add handling for `ChildRidesEmpty` state (return CustomEmptyState)
    - Keep existing `ChildRidesLoaded` state handling with history list
    - Maintain RefreshIndicator and pull-to-refresh functionality
    - _Requirements: 1.3, 3.3, 3.4, 4.1, 4.3, 4.4_

- [ ] 2. Checkpoint - Manual testing
  - Ensure all tests pass, ask the user if questions arise
  - Manually test tab switching on all three tabs
  - Verify loading states display correctly
  - Verify error states display correctly
  - Verify empty states display correctly
  - Verify pull-to-refresh works on all tabs

- [ ] 3. Write widget tests for tab switching behavior
  - [ ] 3.1 Set up test file and mock infrastructure
    - Create `test/features/rides/ui/screens/child_schedule_screen_test.dart`
    - Import necessary testing packages (flutter_test, mocktail, bloc_test)
    - Create `MockChildRidesCubit` class extending Mock
    - Create `MockReportAbsenceCubit` class extending Mock
    - Create helper function to build widget with mocks
    - _Requirements: All testing requirements_
  
  - [ ]* 3.2 Write widget test for Property 1: Tab selection updates content
    - **Property 1: Tab Selection Updates Content**
    - **Validates: Requirements 1.1, 1.2, 1.3, 1.4, 1.5, 2.1, 2.3, 3.5**
    - Test that selecting each tab displays correct content
    - Verify Upcoming tab shows upcoming rides
    - Verify Today tab shows filtered today rides
    - Verify History tab shows history rides
    - Verify previous tab content is not present after switching
  
  - [ ]* 3.3 Write widget test for Property 2: Today tab filters correctly
    - **Property 2: Today Tab Filters Correctly**
    - **Validates: Requirements 3.2**
    - Create rides with yesterday, today, and tomorrow dates
    - Select Today tab
    - Verify only today's rides are displayed
    - Verify count matches expected filtered count
  
  - [ ]* 3.4 Write widget test for Property 3: Tab content displays all data
    - **Property 3: Tab Content Displays All Data**
    - **Validates: Requirements 3.1, 3.3**
    - Create mock data with known ride IDs
    - Test Upcoming tab displays all upcoming rides
    - Test History tab displays all history rides
    - Test with varying list sizes (1, 5, 10 rides)
  
  - [ ]* 3.5 Write widget test for Property 4: Empty states display correctly
    - **Property 4: Empty States Display Correctly**
    - **Validates: Requirements 3.4**
    - Provide empty lists for each ride type
    - Test each tab shows CustomEmptyState
    - Verify correct icon and message for each tab type
  
  - [ ]* 3.6 Write widget test for Property 5: All Cubit states handled
    - **Property 5: All Cubit States Handled**
    - **Validates: Requirements 4.3, 4.4**
    - Mock Cubit to emit Loading state, verify CircularProgressIndicator
    - Mock Cubit to emit Error state, verify CustomEmptyState with error
    - Mock Cubit to emit Empty state, verify CustomEmptyState
    - Mock Cubit to emit Loaded state, verify content displayed
    - Test all states on all three tabs
  
  - [ ]* 3.7 Write widget test for Property 6: Pull-to-refresh works on all tabs
    - **Property 6: Pull-to-Refresh Works on All Tabs**
    - **Validates: Requirements 4.1**
    - Select each tab
    - Simulate pull-to-refresh gesture using tester.drag()
    - Verify loadRides() is called on the Cubit
    - Use verify() from mocktail to check method calls
  
  - [ ]* 3.8 Write widget test for Property 7: Tab switching doesn't trigger data fetching
    - **Property 7: Tab Switching Doesn't Trigger Data Fetching**
    - **Validates: Requirements 5.5**
    - Load data once (Cubit in ChildRidesLoaded state)
    - Switch between all tabs multiple times
    - Verify loadRides() is not called during tab switches
    - Use verifyNever() from mocktail

- [ ] 4. Write example-based tests for dialogs and interactions
  - [ ]* 4.1 Write test for Example 1: Report absence dialog functions
    - **Example 1: Report Absence Dialog Functions**
    - **Validates: Requirements 4.2**
    - Render Upcoming tab with a ride
    - Tap "Report Absence" button
    - Verify dialog is displayed
    - Verify text field and submit button are present
  
  - [ ]* 4.2 Write test for Example 2: Summary dialog displays statistics
    - **Example 2: Summary Dialog Displays Statistics**
    - **Validates: Requirements 4.5**
    - Provide mock summary data
    - Tap summary button in header
    - Verify dialog is displayed with all statistics
    - Verify correct values are displayed
  
  - [ ]* 4.3 Write test for Example 3: BlocConsumer handles absence reporting
    - **Example 3: BlocConsumer Handles Absence Reporting**
    - **Validates: Requirements 4.6**
    - Mock ReportAbsenceCubit to emit success state
    - Verify success snackbar is displayed
    - Verify loadRides() is called on ChildRidesCubit

- [ ] 5. Write unit tests for date filtering logic
  - [ ]* 5.1 Write unit test for today's date filtering
    - Create helper function to filter rides by today's date
    - Test with rides from yesterday, today, and tomorrow
    - Verify only today's rides are returned
    - Test with empty list
    - Test with all rides from today
    - Test with no rides from today
  
  - [ ]* 5.2 Write unit test for date string parsing
    - Test parsing of YYYY-MM-DD format strings
    - Test comparison of date strings
    - Test edge cases (leap years, month boundaries)
  
  - [ ]* 5.3 Write unit test for empty list handling
    - Test filtering empty list returns empty list
    - Test filtering null list returns empty list

- [ ] 6. Final checkpoint - Run all tests and verify
  - Ensure all tests pass, ask the user if questions arise
  - Run `flutter test` to execute all tests
  - Verify test coverage meets 90% threshold
  - Run `flutter analyze` to check for any issues
  - Manually test on device or emulator
  - Verify no regressions in existing functionality

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Widget tests validate UI behavior and user interactions
- Unit tests validate data transformation logic
- The fix is minimal and focused on restructuring the widget tree
- All existing functionality (pull-to-refresh, dialogs, error handling) is preserved
- No changes to data models or Cubit logic are required
