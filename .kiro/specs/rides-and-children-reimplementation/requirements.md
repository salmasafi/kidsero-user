# Requirements Document

## Introduction

This document specifies the requirements for re-implementing the children and rides modules in a Flutter-based school bus tracking application. The previous implementation was broken due to incorrect API integration. This re-implementation will restore full functionality including children management, rides management, and real-time bus tracking via WebSocket.

## Glossary

- **Parent_App**: The Flutter mobile application used by parents to track their children's school bus rides
- **Children_Module**: The component responsible for managing child profiles linked to a parent account
- **Rides_Module**: The component responsible for managing and displaying ride information and schedules
- **Live_Tracking_Service**: The WebSocket-based service that provides real-time bus location updates
- **API_Service**: The backend REST API that provides data for children and rides
- **Child_Code**: A unique identifier provided by the school to link a child to a parent account
- **Ride_Occurrence**: A specific instance of a scheduled ride (e.g., morning pickup on Jan 15, 2024)
- **Active_Ride**: A ride that is currently in progress (bus is en route)
- **BLoC_Pattern**: Business Logic Component pattern used for state management in Flutter
- **Repository_Pattern**: A design pattern that abstracts data sources from business logic

## Requirements

### Requirement 1: Children Profile Management

**User Story:** As a parent, I want to view and manage my children's profiles, so that I can track their bus rides and school information.

#### Acceptance Criteria

1. WHEN a parent opens the children list screen, THE Children_Module SHALL fetch all children from the API endpoint `/api/users/children/`
2. WHEN children data is received, THE Children_Module SHALL display each child's name, grade, school, and photo
3. WHEN the API returns an empty list, THE Children_Module SHALL display a message indicating no children are linked
4. WHEN a network error occurs during fetch, THE Children_Module SHALL display an error message in Arabic and provide a retry option
5. WHEN the API returns a 401 status, THE Children_Module SHALL trigger re-authentication

### Requirement 2: Add Child by Code

**User Story:** As a parent, I want to add a new child to my account using their unique code, so that I can start tracking their bus rides.

#### Acceptance Criteria

1. WHEN a parent enters a child code and submits, THE Children_Module SHALL send a POST request to `/api/users/children/add` with the code
2. WHEN the child is successfully added, THE Children_Module SHALL refresh the children list and display a success message
3. WHEN an invalid code is provided, THE Children_Module SHALL display an error message indicating the code is invalid
4. WHEN the code is already used, THE Children_Module SHALL display an error message indicating the child is already linked
5. WHILE the add request is processing, THE Children_Module SHALL display a loading indicator and disable the submit button

### Requirement 3: Today's Rides Display

**User Story:** As a parent, I want to see today's scheduled rides for all my children, so that I can plan my day accordingly.

#### Acceptance Criteria

1. WHEN a parent opens the today's rides screen, THE Rides_Module SHALL fetch data from `/api/users/rides/children/today`
2. WHEN ride data is received, THE Rides_Module SHALL display rides grouped by child with morning and afternoon periods
3. WHEN displaying each ride, THE Rides_Module SHALL show pickup time, dropoff time, pickup location, dropoff location, driver name, and bus number
4. WHEN no rides are scheduled for today, THE Rides_Module SHALL display a message indicating no rides today
5. WHEN a ride status is "cancelled", THE Rides_Module SHALL display the ride with a cancelled indicator

### Requirement 4: Active Rides Monitoring

**User Story:** As a parent, I want to see which rides are currently in progress, so that I know when my child is on the bus.

#### Acceptance Criteria

1. WHEN a parent opens the active rides screen, THE Rides_Module SHALL fetch data from `/api/users/rides/active`
2. WHEN active rides are received, THE Rides_Module SHALL display each ride with current status, estimated arrival time, and child information
3. WHEN a ride transitions from scheduled to in_progress, THE Rides_Module SHALL update the display to show it as active
4. WHEN no rides are currently active, THE Rides_Module SHALL display a message indicating no active rides
5. WHEN an active ride is displayed, THE Rides_Module SHALL provide a button to access live tracking

### Requirement 5: Upcoming Rides View

**User Story:** As a parent, I want to view upcoming scheduled rides, so that I can prepare for future bus pickups and dropoffs.

#### Acceptance Criteria

1. WHEN a parent opens the upcoming rides screen, THE Rides_Module SHALL fetch data from `/api/users/rides/upcoming`
2. WHEN upcoming rides are received, THE Rides_Module SHALL display rides sorted by date and time
3. WHEN displaying each upcoming ride, THE Rides_Module SHALL show the scheduled date, time, child name, and route information
4. WHEN no upcoming rides exist, THE Rides_Module SHALL display a message indicating no upcoming rides
5. WHILE fetching upcoming rides, THE Rides_Module SHALL display a loading indicator

### Requirement 6: Child Ride History and Summary

**User Story:** As a parent, I want to view detailed ride history and attendance summary for each child, so that I can track their bus usage patterns.

#### Acceptance Criteria

1. WHEN a parent selects a child to view details, THE Rides_Module SHALL fetch data from `/api/users/rides/child/{childId}`
2. WHEN child details are received, THE Rides_Module SHALL display the complete ride history with dates, times, and statuses
3. WHEN a parent requests attendance summary, THE Rides_Module SHALL fetch data from `/api/users/rides/child/{childId}/summary`
4. WHEN summary data is received, THE Rides_Module SHALL display total rides, attended rides, missed rides, and attendance percentage
5. WHEN displaying ride history, THE Rides_Module SHALL allow filtering by date range and ride status

### Requirement 7: Real-Time Bus Tracking

**User Story:** As a parent, I want to track the bus location in real-time when my child is on an active ride, so that I know exactly when to expect them.

#### Acceptance Criteria

1. WHEN a parent opens live tracking for an active ride, THE Live_Tracking_Service SHALL establish a WebSocket connection for that ride
2. WHEN location updates are received via WebSocket, THE Live_Tracking_Service SHALL update the bus marker position on the map
3. WHEN displaying bus location, THE Parent_App SHALL show bus speed, heading direction, and estimated time of arrival
4. WHEN the WebSocket connection fails, THE Live_Tracking_Service SHALL attempt to reconnect automatically up to 3 times
5. WHEN the parent leaves the tracking screen, THE Live_Tracking_Service SHALL close the WebSocket connection properly
6. WHILE waiting for location updates, THE Parent_App SHALL display the last known location with a timestamp
7. WHEN the ride is completed, THE Live_Tracking_Service SHALL close the WebSocket connection and display a completion message

### Requirement 8: Absence Reporting

**User Story:** As a parent, I want to report my child's absence for a scheduled ride with a reason, so that the school and driver are informed.

#### Acceptance Criteria

1. WHEN a parent selects a scheduled ride to report absence, THE Rides_Module SHALL display a form to enter the absence reason
2. WHEN the parent submits the absence report, THE Rides_Module SHALL send a POST request to `/api/users/rides/excuse/{occurrenceId}/{studentId}` with the reason
3. WHEN the absence is successfully reported, THE Rides_Module SHALL update the ride status to "excused" and display a confirmation message
4. WHEN the absence reason is empty, THE Rides_Module SHALL prevent submission and display a validation message
5. WHEN the ride has already started, THE Rides_Module SHALL prevent absence reporting and display an appropriate message

### Requirement 9: Data Layer Architecture

**User Story:** As a developer, I want a clean separation between data sources and business logic, so that the code is maintainable and testable.

#### Acceptance Criteria

1. THE Parent_App SHALL implement the Repository_Pattern to abstract API calls from business logic
2. THE Parent_App SHALL use the BLoC_Pattern for state management in all feature modules
3. WHEN making API calls, THE API_Service SHALL include authentication tokens from cache in request headers
4. WHEN API responses are received, THE Parent_App SHALL parse them into strongly-typed Dart models
5. WHEN parsing fails, THE Parent_App SHALL log the error and return a user-friendly error state

### Requirement 10: Error Handling and User Feedback

**User Story:** As a parent, I want clear feedback when errors occur, so that I understand what went wrong and what to do next.

#### Acceptance Criteria

1. WHEN a network error occurs, THE Parent_App SHALL display an error message in Arabic with a retry button
2. WHEN the API returns a 401 Unauthorized status, THE Parent_App SHALL redirect to the login screen
3. WHEN the API returns a 404 Not Found status, THE Parent_App SHALL display a message indicating the resource was not found
4. WHEN the API returns a 500 Server Error status, THE Parent_App SHALL display a message indicating a server problem and suggest trying again later
5. WHILE any async operation is in progress, THE Parent_App SHALL display a loading indicator
6. WHEN an operation completes successfully, THE Parent_App SHALL display a success message in Arabic for 2 seconds

### Requirement 11: Localization Support

**User Story:** As a parent, I want the app to display content in Arabic, so that I can use it in my native language.

#### Acceptance Criteria

1. THE Parent_App SHALL use the existing l10n system for all user-facing text
2. WHEN displaying error messages, THE Parent_App SHALL show them in Arabic
3. WHEN displaying success messages, THE Parent_App SHALL show them in Arabic
4. WHEN displaying dates and times, THE Parent_App SHALL format them according to Arabic locale conventions
5. THE Parent_App SHALL support right-to-left (RTL) layout for Arabic text

### Requirement 12: State Management and UI Updates

**User Story:** As a parent, I want the app to update immediately when data changes, so that I always see current information.

#### Acceptance Criteria

1. WHEN new data is fetched from the API, THE Parent_App SHALL update the UI immediately without requiring manual refresh
2. WHEN a child is added successfully, THE Children_Module SHALL automatically refresh the children list
3. WHEN an absence is reported, THE Rides_Module SHALL update the ride status in the UI immediately
4. WHEN switching between screens, THE Parent_App SHALL preserve the current state and avoid unnecessary API calls
5. WHEN the app returns from background, THE Parent_App SHALL refresh data if more than 5 minutes have passed

