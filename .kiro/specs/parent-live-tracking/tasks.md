# Implementation Plan: Parent Live Tracking

## Overview

This implementation plan breaks down the Parent Live Tracking feature into discrete, incremental coding tasks. Each task builds on previous work, with testing integrated throughout to catch errors early. The implementation reuses existing infrastructure (RideTrackingCubit, SocketService) and follows Flutter best practices.

## Tasks

- [ ] 1. Set up project dependencies and assets
  - Add google_maps_flutter package to pubspec.yaml
  - Create marker icon assets (stop_marker.png, child_pickup_marker.png, bus_marker.png)
  - Configure Google Maps API keys for Android and iOS
  - Add localization keys for live tracking to en.json and ar.json
  - _Requirements: Dependencies, Localization_

- [ ] 2. Create LiveTrackingScreen widget structure
  - [ ] 2.1 Create LiveTrackingScreen StatefulWidget with childId and rideId parameters
    - Define widget constructor and required parameters
    - Create _LiveTrackingScreenState class
    - Set up state variables (mapController, currentBusLocation, markers, polylines, isWebSocketConnected)
    - _Requirements: 1.1, 2.1_
  
  - [ ]* 2.2 Write unit test for screen initialization
    - Test that screen accepts childId and rideId parameters
    - Test that state variables are initialized correctly
    - _Requirements: 2.1_

- [ ] 3. Implement map initialization and lifecycle
  - [ ] 3.1 Implement initState to load tracking data and connect WebSocket
    - Call RideTrackingCubit.loadTracking() with childId
    - Initialize SocketService connection with auth token
    - Start auto-refresh on cubit
    - Load marker icon assets
    - _Requirements: 2.1, 3.1_
  
  - [ ] 3.2 Implement dispose to cleanup resources
    - Leave ride channel via SocketService
    - Disconnect SocketService
    - Stop auto-refresh on cubit
    - Dispose map controller
    - Cancel throttle timer
    - _Requirements: 3.5, 3.6, 10.4_
  
  - [ ] 3.3 Implement didChangeAppLifecycleState for background/foreground handling
    - Pause WebSocket and auto-refresh when app is backgrounded
    - Resume WebSocket and auto-refresh when app is foregrounded
    - _Requirements: 10.2, 10.3_
  
  - [ ]* 3.4 Write unit tests for lifecycle methods
    - Test initState calls cubit.loadTracking()
    - Test initState connects to WebSocket
    - Test dispose cleans up all resources
    - Test lifecycle state changes pause/resume updates
    - _Requirements: 2.1, 3.1, 3.5, 3.6, 10.2, 10.3, 10.4_

- [ ] 4. Implement marker icon loading and caching
  - [ ] 4.1 Create _loadMarkerIcons method to load and cache BitmapDescriptors
    - Load stop_marker.png as _stopIcon
    - Load child_pickup_marker.png as _childPickupIcon
    - Load bus_marker.png as _busIcon
    - Handle loading errors gracefully
    - _Requirements: 10.5_
  
  - [ ]* 4.2 Write property test for marker asset caching
    - **Property 16: Marker assets are cached**
    - **Validates: Requirements 10.5**
    - Generate multiple markers of same type
    - Verify asset is loaded once and BitmapDescriptor is reused

- [ ] 5. Implement route polyline creation
  - [ ] 5.1 Create _createRoutePolyline method
    - Accept List<RouteStop> as parameter
    - Sort stops by stopOrder
    - Map sorted stops to LatLng points
    - Create Polyline with primary color, width 4, dashed pattern
    - Return Polyline object
    - _Requirements: 1.2, 4.1, 4.2, 4.3_
  
  - [ ]* 5.2 Write property test for route polyline
    - **Property 1: Route polyline connects all stops in order**
    - **Validates: Requirements 1.2, 4.1, 4.2**
    - Generate random routes with varying stop counts
    - Verify polyline points match stops sorted by stopOrder

- [ ] 6. Implement marker creation methods
  - [ ] 6.1 Create _createStopMarker method
    - Accept RouteStop and isChildPickup boolean
    - Parse lat/lng coordinates with validation
    - Use _childPickupIcon if isChildPickup, else _stopIcon
    - Create InfoWindow with stop name and address
    - Return Marker object
    - _Requirements: 1.3, 1.4, 4.4, 4.5_
  
  - [ ] 6.2 Create _createBusMarker method
    - Accept LatLng position
    - Use _busIcon
    - Create InfoWindow with bus information
    - Return Marker object
    - _Requirements: 1.5_
  
  - [ ]* 6.3 Write property tests for marker creation
    - **Property 2: All route stops are displayed as markers**
    - **Validates: Requirements 1.3, 4.6**
    - Generate random routes, verify marker count equals stop count
    
    - **Property 3: Child's pickup point is visually distinct**
    - **Validates: Requirements 1.4, 4.5**
    - Generate random tracking data, verify child's marker uses different icon
    
    - **Property 4: Bus marker displays at current location**
    - **Validates: Requirements 1.5**
    - Generate random bus locations, verify marker position matches
    
    - **Property 9: Stop markers contain complete information**
    - **Validates: Requirements 4.4**
    - Generate random stops, verify info windows contain name and address

- [ ] 7. Implement coordinate parsing and validation
  - [ ] 7.1 Create _parseCoordinates helper method
    - Accept lat and lng strings
    - Validate non-empty strings
    - Parse to double with try-catch
    - Validate latitude range (-90 to 90)
    - Validate longitude range (-180 to 180)
    - Return LatLng or null if invalid
    - Log warnings for invalid coordinates
    - _Requirements: Error Handling - Invalid Coordinate Data_
  
  - [ ]* 7.2 Write unit tests for coordinate validation
    - Test valid coordinates return LatLng
    - Test empty strings return null
    - Test invalid ranges return null
    - Test non-numeric strings return null

- [ ] 8. Implement camera control methods
  - [ ] 8.1 Create _calculateBounds method
    - Accept List<RouteStop> and optional LatLng busLocation
    - Calculate LatLngBounds encompassing all coordinates
    - Return LatLngBounds
    - _Requirements: 1.6_
  
  - [ ] 8.2 Create _fitMapToRoute method
    - Accept List<RouteStop> and optional LatLng busLocation
    - Calculate bounds using _calculateBounds
    - Animate camera to fit bounds with 50px padding
    - _Requirements: 1.6, 9.6_
  
  - [ ] 8.3 Create _recenterOnBus method
    - Check if _currentBusLocation is not null
    - Animate camera to bus location with zoom 15
    - _Requirements: 9.5_
  
  - [ ]* 8.4 Write property test for camera bounds
    - **Property 5: Camera bounds include all route elements**
    - **Validates: Requirements 1.6**
    - Generate random routes and bus locations
    - Verify calculated bounds encompass all coordinates

- [ ] 9. Implement map data initialization from tracking data
  - [ ] 9.1 Create _initializeMapData method
    - Extract route stops from RideTrackingData
    - Identify child's pickup point from TrackingChild
    - Create stop markers for all stops
    - Highlight child's pickup marker
    - Create bus marker if currentLocation exists
    - Create route polyline
    - Update _markers and _polylines sets
    - Fit camera to show all elements
    - _Requirements: 1.2, 1.3, 1.4, 1.5, 1.6, 2.2, 2.3, 2.4_
  
  - [ ]* 9.2 Write property test for data extraction
    - **Property 6: Tracking data extraction is complete**
    - **Validates: Requirements 2.2, 2.3, 2.4**
    - Generate random RideTrackingData
    - Verify all data fields are extracted correctly

- [ ] 10. Checkpoint - Ensure map displays correctly with static data
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 11. Implement WebSocket integration for real-time updates
  - [ ] 11.1 Create _initializeWebSocket method
    - Get auth token from auth service
    - Call SocketService.connect(token)
    - Call SocketService.joinRide(rideId)
    - Set up onLocationUpdate listener
    - Set _isWebSocketConnected = true on success
    - Handle connection errors with _handleWebSocketError
    - _Requirements: 3.1, 3.2_
  
  - [ ] 11.2 Create _handleLocationUpdate method with throttling
    - Check if throttle timer is active, return if so
    - Create 1-second throttle timer
    - Parse lat/lng from location update data
    - Validate coordinates
    - Update _currentBusLocation
    - Update bus marker position
    - Animate marker movement
    - _Requirements: 3.3, 10.1_
  
  - [ ] 11.3 Create _updateBusMarker method
    - Remove old bus marker from _markers
    - Create new bus marker at updated position
    - Add new marker to _markers
    - Call setState to trigger rebuild
    - _Requirements: 3.3_
  
  - [ ] 11.4 Create _handleWebSocketError method
    - Log error details
    - Set _isWebSocketConnected = false
    - Continue relying on cubit polling
    - Update connection status indicator
    - _Requirements: 6.1, 6.2, 8.3_
  
  - [ ]* 11.5 Write unit tests for WebSocket integration
    - Test WebSocket connects on initState
    - Test joinRide is called after connection
    - Test location updates trigger bus marker update
    - Test WebSocket errors fall back to polling
    - Test dispose leaves ride and disconnects
    - _Requirements: 3.1, 3.2, 3.3, 3.5, 3.6, 6.2, 8.3_
  
  - [ ]* 11.6 Write property test for location update handling
    - **Property 8: Location updates modify bus marker position**
    - **Validates: Requirements 3.3**
    - Generate random location update events
    - Verify bus marker position updates to match coordinates
  
  - [ ]* 11.7 Write property test for update throttling
    - **Property 15: Location updates are throttled**
    - **Validates: Requirements 10.1**
    - Generate rapid location updates (>1 per second)
    - Verify updates are throttled to maximum 1 per second

- [ ] 12. Implement RideInfoCard overlay component
  - [ ] 12.1 Create RideInfoCard widget
    - Accept RideTrackingData and isWebSocketConnected parameters
    - Display ride name with status badge
    - Display bus number and plate number
    - Display driver name and phone
    - Display connection status indicator (real-time vs polling)
    - Apply RTL layout for Arabic locale
    - Use Card with elevation and padding
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 6.5, 7.1, 7.2_
  
  - [ ]* 12.2 Write property tests for RideInfoCard
    - **Property 10: RideInfoCard displays all ride details**
    - **Validates: Requirements 5.2, 5.3, 5.4, 5.5**
    - Generate random tracking data
    - Verify all fields are displayed in card
    
    - **Property 11: Connection status reflects actual state**
    - **Validates: Requirements 6.5**
    - Test with connected and disconnected states
    - Verify correct status indicator is shown

- [ ] 13. Implement main build method with BlocBuilder
  - [ ] 13.1 Create build method structure
    - Wrap with Directionality for RTL support
    - Use BlocBuilder<RideTrackingCubit, RideTrackingState>
    - Handle RideTrackingLoading state → show loading indicator
    - Handle RideTrackingError state → show error view with retry
    - Handle RideTrackingLoaded state → show map with overlay
    - _Requirements: 1.1, 2.5, 7.1, 7.2, 8.1, 8.2_
  
  - [ ] 13.2 Implement loading state UI
    - Display centered CircularProgressIndicator
    - Display "Loading tracking data..." text
    - _Requirements: 8.1_
  
  - [ ] 13.3 Implement error state UI
    - Display error icon
    - Display error message from state
    - Display retry button that calls cubit.loadTracking()
    - _Requirements: 2.5, 8.2, 8.4_
  
  - [ ] 13.4 Implement loaded state UI with map
    - Display GoogleMap widget with markers and polylines
    - Position RideInfoCard overlay at top
    - Add FloatingActionButton for recenter on bus
    - Add FloatingActionButton for fit all markers
    - Call _initializeMapData when state changes to loaded
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 5.1, 9.5, 9.6_
  
  - [ ]* 13.5 Write property tests for state handling
    - **Property 7: Error states display error UI**
    - **Validates: Requirements 2.5, 8.2**
    - Generate random error states
    - Verify error widget is displayed
    
    - **Property 13: Loading state displays loading indicator**
    - **Validates: Requirements 8.1**
    - Test with loading state
    - Verify loading widget is shown

- [ ] 14. Implement localization and RTL support
  - [ ] 14.1 Add localization keys to en.json and ar.json
    - Add all required keys from design document
    - Verify translations are accurate
    - _Requirements: 7.1_
  
  - [ ] 14.2 Apply RTL layout to all text components
    - Use Directionality widget in build method
    - Apply RTL to RideInfoCard
    - Apply RTL to marker info windows
    - Test with Arabic locale
    - _Requirements: 7.2, 7.3_
  
  - [ ]* 14.3 Write property test for RTL support
    - **Property 12: Arabic locale applies RTL layout**
    - **Validates: Requirements 7.1, 7.2, 7.3**
    - Test with Arabic locale
    - Verify RTL layout and Arabic text in all components

- [ ] 15. Implement marker interaction handling
  - [ ] 15.1 Configure marker tap behavior
    - Ensure markers have onTap callbacks (handled by GoogleMap)
    - Verify info windows display on marker tap
    - _Requirements: 9.3, 9.4_
  
  - [ ]* 15.2 Write property test for marker interaction
    - **Property 14: Marker taps show info windows**
    - **Validates: Requirements 9.3**
    - Generate random markers
    - Simulate tap and verify info window is shown

- [ ] 16. Implement empty state and edge case handling
  - [ ] 16.1 Handle no active ride scenario
    - Display empty state message when no tracking data
    - Provide button to return to rides list
    - _Requirements: 8.5_
  
  - [ ] 16.2 Handle missing route data
    - Display error if stops list is empty
    - Show only bus marker if bus location exists
    - Log warning for debugging
    - _Requirements: Error Handling - Missing Route Data_
  
  - [ ]* 16.3 Write unit tests for edge cases
    - Test no active ride shows empty state
    - Test missing route data shows error
    - Test invalid coordinates are skipped
    - _Requirements: 8.5, Error Handling_

- [ ] 17. Checkpoint - Ensure all functionality works end-to-end
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 18. Add navigation integration
  - [ ] 18.1 Create navigation route to LiveTrackingScreen
    - Add route definition in app router
    - Pass childId and rideId as parameters
    - _Requirements: Integration_
  
  - [ ] 18.2 Add navigation from RideTrackingScreen
    - Add "View on Map" button to timeline view
    - Navigate to LiveTrackingScreen with current child and ride
    - _Requirements: Integration_
  
  - [ ]* 18.3 Write integration test for navigation
    - Test navigation from rides list to live tracking
    - Test back navigation preserves state
    - _Requirements: Integration_

- [ ] 19. Performance optimization and final polish
  - [ ] 19.1 Verify marker asset caching is working
    - Check that assets are loaded once in initState
    - Verify BitmapDescriptors are reused
    - _Requirements: 10.5_
  
  - [ ] 19.2 Verify location update throttling is working
    - Test with rapid location updates
    - Confirm max 1 update per second
    - _Requirements: 10.1_
  
  - [ ] 19.3 Verify lifecycle management is working
    - Test pause/resume on app background/foreground
    - Verify resources are disposed properly
    - _Requirements: 10.2, 10.3, 10.4_
  
  - [ ] 19.4 Add error logging for debugging
    - Ensure all error scenarios log appropriately
    - Add performance logging for map operations
    - _Requirements: Error Handling_

- [ ] 20. Final checkpoint - Complete testing and validation
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional testing tasks and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation at key milestones
- Property tests validate universal correctness properties across randomized inputs
- Unit tests validate specific examples, edge cases, and integration points
- The implementation reuses existing RideTrackingCubit and SocketService
- Google Maps API keys must be configured before testing map functionality
- Test with both English and Arabic locales to verify RTL support
