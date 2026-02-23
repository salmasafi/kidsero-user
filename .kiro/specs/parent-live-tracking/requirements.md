# Requirements Document: Parent Live Tracking

## Introduction

This feature enhances the parent tracking experience by providing a real-time map-based view of their child's bus location. The system integrates with existing tracking infrastructure (RideTrackingCubit, SocketService) to display the complete route, pickup points, and live bus location on an interactive map. Parents can monitor their child's ride progress visually while receiving real-time location updates via WebSocket.

## Glossary

- **LiveTrackingScreen**: The new map-based screen for real-time bus tracking
- **RideTrackingCubit**: Existing cubit that manages ride tracking data and state
- **SocketService**: Existing service that handles WebSocket connections for real-time updates
- **RideTrackingData**: Model containing occurrence, ride, bus, driver, route, and children information
- **TrackingRoute**: Model containing route information with ordered stops
- **RouteStop**: Model representing a pickup/drop-off point with coordinates
- **TrackingBus**: Model containing bus information and current location
- **TrackingChild**: Model containing child information, pickup point, and status
- **LocationUpdate**: Real-time event from WebSocket containing updated bus coordinates
- **RidesRepository**: Repository that fetches tracking data from API
- **MapView**: The Google Maps component displaying route, markers, and bus location
- **RideInfoCard**: Overlay component showing ride details on the map

## Requirements

### Requirement 1: Map Initialization and Display

**User Story:** As a parent, I want to see an interactive map when I open the live tracking screen, so that I can visualize my child's bus route and location.

#### Acceptance Criteria

1. WHEN the LiveTrackingScreen is opened, THE System SHALL initialize the MapView with appropriate zoom and center
2. WHEN the MapView is initialized, THE System SHALL display the complete route as a polyline connecting all stops in order
3. WHEN the MapView is initialized, THE System SHALL display markers for all pickup points from the route
4. WHEN the MapView is initialized, THE System SHALL highlight the child's pickup point with a distinct marker style
5. WHEN the MapView is initialized, THE System SHALL display the bus marker at its current location
6. WHEN the MapView is initialized, THE System SHALL adjust the camera bounds to show all route stops and the bus location

### Requirement 2: Data Integration with Existing Infrastructure

**User Story:** As a developer, I want to reuse existing data infrastructure, so that the implementation is consistent and maintainable.

#### Acceptance Criteria

1. WHEN the LiveTrackingScreen is mounted, THE System SHALL use RideTrackingCubit to load initial tracking data
2. WHEN RideTrackingCubit emits RideTrackingLoaded state, THE System SHALL extract route stops from TrackingRoute
3. WHEN RideTrackingCubit emits RideTrackingLoaded state, THE System SHALL extract bus location from TrackingBus
4. WHEN RideTrackingCubit emits RideTrackingLoaded state, THE System SHALL identify the child's pickup point from TrackingChild
5. WHEN RideTrackingCubit emits RideTrackingError state, THE System SHALL display an error message to the user
6. THE System SHALL NOT create a new cubit for tracking data management

### Requirement 3: Real-Time Location Updates via WebSocket

**User Story:** As a parent, I want to see the bus location update automatically in real-time, so that I have accurate information about when my child will arrive.

#### Acceptance Criteria

1. WHEN the LiveTrackingScreen is mounted, THE System SHALL connect to SocketService using the authentication token
2. WHEN SocketService is connected, THE System SHALL join the ride channel using the ride ID
3. WHEN a locationUpdate event is received, THE System SHALL update the bus marker position on the MapView
4. WHEN a locationUpdate event is received, THE System SHALL animate the bus marker movement smoothly
5. WHEN the LiveTrackingScreen is disposed, THE System SHALL leave the ride channel
6. WHEN the LiveTrackingScreen is disposed, THE System SHALL disconnect from SocketService

### Requirement 4: Route Visualization

**User Story:** As a parent, I want to see the complete bus route with all pickup points, so that I understand the full journey and my child's position in the sequence.

#### Acceptance Criteria

1. WHEN displaying the route, THE System SHALL sort RouteStop items by stopOrder before drawing
2. WHEN displaying the route, THE System SHALL draw a polyline connecting consecutive stops
3. WHEN displaying the route, THE System SHALL use a distinct color for the route polyline
4. WHEN displaying pickup point markers, THE System SHALL show the stop name and address in the marker info window
5. WHEN displaying the child's pickup point, THE System SHALL use a different marker color or icon
6. THE System SHALL display all route stops regardless of whether children are assigned to them

### Requirement 5: Ride Information Display

**User Story:** As a parent, I want to see ride details while viewing the map, so that I have context about the driver, bus, and ride status.

#### Acceptance Criteria

1. WHEN the MapView is displayed, THE System SHALL show a RideInfoCard overlay
2. WHEN displaying the RideInfoCard, THE System SHALL show the ride name
3. WHEN displaying the RideInfoCard, THE System SHALL show the bus number and plate number
4. WHEN displaying the RideInfoCard, THE System SHALL show the driver name
5. WHEN displaying the RideInfoCard, THE System SHALL show the ride status
6. THE RideInfoCard SHALL be positioned to not obstruct critical map areas

### Requirement 6: WebSocket Connection Resilience

**User Story:** As a parent, I want the tracking to continue working even if the connection is temporarily lost, so that I don't lose visibility of my child's location.

#### Acceptance Criteria

1. IF the WebSocket connection is lost, THEN THE System SHALL continue displaying the last known bus location
2. IF the WebSocket connection is lost, THEN THE System SHALL fall back to RideTrackingCubit's polling mechanism
3. WHEN the WebSocket connection is restored, THE System SHALL resume real-time updates
4. WHEN falling back to polling, THE System SHALL use the existing 10-second refresh interval
5. WHEN displaying connection status, THE System SHALL indicate whether updates are real-time or polling-based

### Requirement 7: Localization and RTL Support

**User Story:** As an Arabic-speaking parent, I want the interface to display correctly in my language, so that I can use the feature comfortably.

#### Acceptance Criteria

1. WHEN the app locale is Arabic, THE System SHALL display all text in Arabic
2. WHEN the app locale is Arabic, THE System SHALL apply RTL layout to the RideInfoCard
3. WHEN the app locale is Arabic, THE System SHALL apply RTL layout to marker info windows
4. THE System SHALL use existing localization keys from the app's localization system
5. THE System SHALL follow existing RTL patterns used in other screens

### Requirement 8: Error Handling and Loading States

**User Story:** As a parent, I want clear feedback when data is loading or when errors occur, so that I understand what's happening with the tracking.

#### Acceptance Criteria

1. WHEN RideTrackingCubit is in RideTrackingLoading state, THE System SHALL display a loading indicator
2. WHEN RideTrackingCubit emits RideTrackingError, THE System SHALL display an error message with retry option
3. WHEN SocketService fails to connect, THE System SHALL log the error and fall back to polling
4. WHEN the MapView fails to initialize, THE System SHALL display an error message
5. WHEN no tracking data is available, THE System SHALL display an appropriate empty state message

### Requirement 9: Map Interaction and Camera Control

**User Story:** As a parent, I want to interact with the map to zoom and pan, so that I can examine specific areas of the route in detail.

#### Acceptance Criteria

1. WHEN the user pinches the map, THE System SHALL allow zoom in and zoom out
2. WHEN the user drags the map, THE System SHALL allow panning to different areas
3. WHEN the user taps a pickup point marker, THE System SHALL display the stop information
4. WHEN the user taps the bus marker, THE System SHALL display the current bus information
5. THE System SHALL provide a button to recenter the map on the bus location
6. THE System SHALL provide a button to fit all route stops and bus location in view

### Requirement 10: Performance and Resource Management

**User Story:** As a user, I want the tracking screen to perform smoothly without draining my battery, so that I can monitor the ride efficiently.

#### Acceptance Criteria

1. WHEN updating the bus location, THE System SHALL throttle updates to a maximum of one per second
2. WHEN the screen is not visible, THE System SHALL pause WebSocket updates
3. WHEN the screen becomes visible again, THE System SHALL resume WebSocket updates
4. THE System SHALL dispose of map resources when the screen is disposed
5. THE System SHALL reuse existing marker assets rather than loading them repeatedly
