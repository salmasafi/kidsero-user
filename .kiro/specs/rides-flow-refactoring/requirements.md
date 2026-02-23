# Requirements Document: Rides Flow Refactoring

## Introduction

This document specifies the requirements for refactoring the rides flow in the Flutter parent app for school bus tracking. The refactoring aims to replace the current rides implementation with a new implementation that uses the correct API endpoints while maintaining the existing UI design. The system will provide parents with comprehensive visibility into their children's bus rides, including real-time tracking, schedules, and attendance summaries.

## Glossary

- **Parent_App**: The Flutter mobile application used by parents to track their children's school bus rides
- **Rides_Dashboard**: The main screen displaying all children with their ride information and statistics
- **Child_Card**: A UI component displaying a child's information including avatar, name, grade, classroom, and school
- **Active_Ride**: A ride that is currently in progress (bus is en route)
- **Scheduled_Ride**: A ride that is planned for the future
- **Ride_Occurrence**: A specific instance of a ride on a particular date
- **Ride_Status**: The current state of a ride (scheduled, in_progress, completed, pending, absent, excused, cancelled)
- **Pickup_Point**: A designated location where children are picked up for rides
- **Dropoff_Point**: A designated location where children are dropped off after rides
- **Ride_Period**: The time of day for a ride (morning or afternoon)
- **Ride_Summary**: Monthly attendance statistics for a child's rides
- **Live_Tracking**: Real-time GPS tracking of a bus during an active ride
- **Timeline_Tracking**: A chronological view of ride events and stops
- **Rides_Service**: The service layer responsible for making API calls
- **Rides_Repository**: The repository layer that manages data operations and caching
- **Rides_Cubit**: The state management component using the BLoC pattern
- **API_Response**: The data structure returned from API endpoints
- **Data_Model**: The Dart class representing structured data in the application

## Requirements

### Requirement 1: Display Children with Ride Information

**User Story:** As a parent, I want to see all my children with their ride information on the main dashboard, so that I can quickly understand each child's ride status.

#### Acceptance Criteria

1. WHEN the Rides_Dashboard loads, THE Parent_App SHALL fetch all children with their ride information using GET /api/users/rides/children
2. WHEN the API returns children data, THE Parent_App SHALL display each child in a horizontally scrolling Child_Card
3. WHEN displaying a Child_Card, THE Parent_App SHALL show the child's avatar, name, grade, classroom, and school name
4. WHEN a child has an active ride, THE Parent_App SHALL display an online status indicator on their Child_Card
5. WHEN the children data is empty, THE Parent_App SHALL display an empty state message with a refresh option
6. WHEN the API call fails, THE Parent_App SHALL display an error message with a retry option

### Requirement 2: Display Dashboard Statistics

**User Story:** As a parent, I want to see summary statistics about my children and their rides, so that I can quickly understand the overall status.

#### Acceptance Criteria

1. WHEN the Rides_Dashboard loads, THE Parent_App SHALL display the total count of children
2. WHEN the Rides_Dashboard loads, THE Parent_App SHALL display the count of currently active rides
3. WHEN there are active rides, THE Parent_App SHALL enable the live tracking button
4. WHEN there are active rides, THE Parent_App SHALL enable the timeline tracking button
5. WHEN there are no active rides, THE Parent_App SHALL disable the tracking buttons

### Requirement 3: Navigate to Child Schedule

**User Story:** As a parent, I want to view a specific child's ride schedule, so that I can see their upcoming and past rides.

#### Acceptance Criteria

1. WHEN a parent taps "View Schedule" on a Child_Card, THE Parent_App SHALL navigate to the Child_Schedule_Screen
2. WHEN the Child_Schedule_Screen loads, THE Parent_App SHALL fetch the child's rides using GET /api/users/rides/child/{childId}
3. WHEN displaying the child schedule, THE Parent_App SHALL show today's rides in a "Today" tab
4. WHEN displaying the child schedule, THE Parent_App SHALL show upcoming rides in an "Upcoming" tab
5. WHEN displaying the child schedule, THE Parent_App SHALL show past rides in a "History" tab
6. WHEN displaying ride information, THE Parent_App SHALL show the ride period, pickup time, pickup location, and status

### Requirement 4: Track Active Rides in Real-Time

**User Story:** As a parent, I want to track my child's active ride in real-time, so that I can see the bus location and estimated arrival time.

#### Acceptance Criteria

1. WHEN a parent taps the live tracking button, THE Parent_App SHALL navigate to the Live_Tracking_Screen
2. WHEN the Live_Tracking_Screen loads, THE Parent_App SHALL fetch tracking data using GET /api/users/rides/tracking/{childId}
3. WHEN displaying live tracking, THE Parent_App SHALL show the bus location on a map
4. WHEN displaying live tracking, THE Parent_App SHALL show the bus number, plate number, and driver information
5. WHEN displaying live tracking, THE Parent_App SHALL show the child's pickup status
6. WHEN displaying live tracking, THE Parent_App SHALL update the bus location periodically
7. WHEN the ride is not active, THE Parent_App SHALL display a message indicating no active ride

### Requirement 5: View Timeline Tracking

**User Story:** As a parent, I want to view a timeline of ride events, so that I can see the sequence of stops and pickups.

#### Acceptance Criteria

1. WHEN a parent taps the timeline tracking button, THE Parent_App SHALL navigate to the Ride_Tracking_Screen
2. WHEN the Ride_Tracking_Screen loads, THE Parent_App SHALL fetch tracking data using GET /api/users/rides/tracking/{childId}
3. WHEN displaying timeline tracking, THE Parent_App SHALL show a chronological list of ride events
4. WHEN displaying timeline tracking, THE Parent_App SHALL show pickup points with their status
5. WHEN displaying timeline tracking, THE Parent_App SHALL show which children are on the ride
6. WHEN displaying timeline tracking, THE Parent_App SHALL highlight the current child's pickup point

### Requirement 6: View Upcoming Rides

**User Story:** As a parent, I want to see upcoming scheduled rides for all my children, so that I can plan ahead.

#### Acceptance Criteria

1. WHEN a parent navigates to upcoming rides, THE Parent_App SHALL fetch upcoming rides using GET /api/users/rides/upcoming
2. WHEN displaying upcoming rides, THE Parent_App SHALL group rides by date
3. WHEN displaying upcoming rides, THE Parent_App SHALL show the next 7 days of scheduled rides
4. WHEN displaying a ride, THE Parent_App SHALL show the child name, ride period, pickup time, and pickup location
5. WHEN there are no upcoming rides, THE Parent_App SHALL display an empty state message

### Requirement 7: View Ride Attendance Summary

**User Story:** As a parent, I want to see a monthly attendance summary for each child, so that I can track their ride usage and attendance.

#### Acceptance Criteria

1. WHEN viewing a child's schedule, THE Parent_App SHALL fetch the ride summary using GET /api/users/rides/child/{childId}/summary
2. WHEN displaying the ride summary, THE Parent_App SHALL show the total number of scheduled rides
3. WHEN displaying the ride summary, THE Parent_App SHALL show the count of completed rides
4. WHEN displaying the ride summary, THE Parent_App SHALL show the count of absent rides
5. WHEN displaying the ride summary, THE Parent_App SHALL show the count of excused absences
6. WHEN displaying the ride summary, THE Parent_App SHALL show the breakdown by ride period (morning/afternoon)

### Requirement 8: Report Absence for a Ride

**User Story:** As a parent, I want to report my child's absence for a scheduled ride, so that the driver knows not to wait for them.

#### Acceptance Criteria

1. WHEN a parent selects a scheduled ride, THE Parent_App SHALL provide an option to report absence
2. WHEN reporting absence, THE Parent_App SHALL prompt the parent to enter a reason
3. WHEN the parent submits the absence report, THE Parent_App SHALL call POST /api/users/rides/excuse/{occurrenceId}/{studentId}
4. WHEN the absence is reported successfully, THE Parent_App SHALL update the ride status to "excused"
5. WHEN the absence report fails, THE Parent_App SHALL display an error message

### Requirement 9: Refresh Ride Data

**User Story:** As a parent, I want to refresh ride data manually, so that I can see the most current information.

#### Acceptance Criteria

1. WHEN a parent pulls down on the Rides_Dashboard, THE Parent_App SHALL refresh all dashboard data
2. WHEN a parent pulls down on the Child_Schedule_Screen, THE Parent_App SHALL refresh the child's ride data
3. WHEN refreshing, THE Parent_App SHALL display a loading indicator
4. WHEN the refresh completes, THE Parent_App SHALL update the displayed data
5. WHEN the refresh fails, THE Parent_App SHALL display an error message and retain the previous data

### Requirement 10: Handle API Errors Gracefully

**User Story:** As a parent, I want the app to handle errors gracefully, so that I understand what went wrong and can take appropriate action.

#### Acceptance Criteria

1. WHEN an API call fails due to network issues, THE Parent_App SHALL display a user-friendly error message
2. WHEN an API call fails due to authentication issues, THE Parent_App SHALL prompt the parent to log in again
3. WHEN an API call fails due to server errors, THE Parent_App SHALL display a message indicating the server is unavailable
4. WHEN an error occurs, THE Parent_App SHALL provide a retry option
5. WHEN an error occurs, THE Parent_App SHALL log the error details for debugging

### Requirement 11: Support Bilingual Localization

**User Story:** As a parent, I want the app to support both Arabic and English, so that I can use it in my preferred language.

#### Acceptance Criteria

1. WHEN displaying text in the Rides_Dashboard, THE Parent_App SHALL use localized strings from the l10n files
2. WHEN displaying ride status, THE Parent_App SHALL show the status in the selected language
3. WHEN displaying dates and times, THE Parent_App SHALL format them according to the selected locale
4. WHEN the parent changes the language, THE Parent_App SHALL update all displayed text immediately
5. WHEN displaying Arabic text, THE Parent_App SHALL use right-to-left layout direction

### Requirement 12: Implement State Management with Cubit

**User Story:** As a developer, I want to use the Cubit pattern for state management, so that the app has predictable and testable state transitions.

#### Acceptance Criteria

1. WHEN managing rides dashboard state, THE Parent_App SHALL use RidesDashboardCubit
2. WHEN managing child schedule state, THE Parent_App SHALL use ChildRidesCubit
3. WHEN managing active rides state, THE Parent_App SHALL use ActiveRidesCubit
4. WHEN managing ride tracking state, THE Parent_App SHALL use RideTrackingCubit
5. WHEN a state change occurs, THE Parent_App SHALL emit a new state immutably
6. WHEN an error occurs, THE Parent_App SHALL emit an error state with a descriptive message

### Requirement 13: Remove Legacy Code

**User Story:** As a developer, I want to remove all legacy rides code, so that the codebase is clean and maintainable.

#### Acceptance Criteria

1. WHEN refactoring is complete, THE Parent_App SHALL not contain any references to old API endpoints
2. WHEN refactoring is complete, THE Parent_App SHALL not contain any deprecated data models
3. WHEN refactoring is complete, THE Parent_App SHALL not contain any unused service methods
4. WHEN refactoring is complete, THE Parent_App SHALL not contain any orphaned cubit files
5. WHEN refactoring is complete, THE Parent_App SHALL pass all linting checks without warnings

### Requirement 14: Maintain UI Design Consistency

**User Story:** As a parent, I want the app to maintain its current visual design, so that I don't need to relearn the interface.

#### Acceptance Criteria

1. WHEN displaying the Rides_Dashboard, THE Parent_App SHALL maintain the current header design with gradient background
2. WHEN displaying Child_Cards, THE Parent_App SHALL maintain the current card design with avatar, name, and details
3. WHEN displaying ride status, THE Parent_App SHALL use the current color scheme (primary, success, accent, secondary)
4. WHEN displaying buttons, THE Parent_App SHALL maintain the current button styles and layouts
5. WHEN displaying empty states, THE Parent_App SHALL use the CustomEmptyState widget with appropriate icons and messages

### Requirement 15: Implement Data Models for API Responses

**User Story:** As a developer, I want to have well-defined data models for all API responses, so that data parsing is type-safe and reliable.

#### Acceptance Criteria

1. WHEN parsing GET /api/users/rides/children response, THE Parent_App SHALL use ChildrenWithAllRidesResponse model
2. WHEN parsing GET /api/users/rides/child/{childId} response, THE Parent_App SHALL use SingleChildRidesResponse model
3. WHEN parsing GET /api/users/rides/active response, THE Parent_App SHALL use ActiveRidesResponse model
4. WHEN parsing GET /api/users/rides/upcoming response, THE Parent_App SHALL use UpcomingRidesGroupedResponse model
5. WHEN parsing GET /api/users/rides/child/{childId}/summary response, THE Parent_App SHALL use NewRideSummaryResponse model
6. WHEN parsing GET /api/users/rides/tracking/{childId} response, THE Parent_App SHALL use NewRideTrackingResponse model
7. WHEN parsing fails, THE Parent_App SHALL throw a descriptive error with the parsing context
