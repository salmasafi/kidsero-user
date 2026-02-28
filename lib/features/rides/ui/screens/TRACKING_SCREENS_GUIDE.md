# Ride Tracking Screens Architecture

## Overview
This document clarifies the purpose of each tracking screen in the application.

## Screens

### 1. RideTrackingScreen (Timeline View)
**Location:** `lib/features/rides/ui/screens/ride_tracking_screen.dart`

**Purpose:** Timeline/list view of ride tracking without a map

**Features:**
- Shows ride header with status badge
- Displays driver and bus information
- Timeline view of pickup points with status indicators
- List of all children on the ride
- Auto-refresh every 10 seconds via polling
- Highlights current user's child

**When to use:**
- When user wants to see detailed timeline of stops
- When user prefers list view over map view
- For users with limited data/bandwidth

**Navigation:**
- Accepts `childId` parameter
- Alternative: `RideTrackingScreenByOccurrence` accepts `occurrenceId`

---

### 2. LiveTrackingScreen (Live Map View)
**Location:** `lib/features/live_tracking_ride/ui/live_tracking_screen.dart`

**Purpose:** Real-time map visualization with WebSocket updates

**Features:**
- **Real-time updates** via WebSocket connection
- Animated bus marker with pulsing effect
- Route polyline connecting all stops
- Stop markers with order numbers
- Child's pickup point highlighted in red
- Camera controls (recenter on bus, fit all markers)
- Fallback to polling if WebSocket fails
- Throttled updates (max 1 per second)
- Lifecycle management (pause/resume on app state changes)

**When to use:**
- When user wants to see live bus location on map
- For active rides with real-time tracking
- Primary tracking experience for parents

**Navigation:**
- Accepts `rideId` (occurrence ID)
- Uses `LiveTrackingCubit` for state management

---

## State Management

### RideTrackingCubit
- Used by: `RideTrackingScreen`
- Polling-based updates every 10 seconds
- Simpler state management for timeline view

### LiveTrackingCubit
- Used by: `LiveTrackingScreen`
- WebSocket connection for real-time updates
- Fallback to polling on connection failure
- Throttling and lifecycle management
- More complex but better UX

---

## Recommended Usage

**For Timeline View:**
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => RideTrackingScreen(childId: childId),
  ),
);
```

**For Live Map View:**
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => LiveTrackingScreen(rideId: occurrenceId),
  ),
);
```

---

## Implementation Status

✅ **Completed:**
- Timeline view with auto-refresh
- Live map view with WebSocket
- Route visualization with polylines
- Stop markers with status indicators
- Camera controls and bounds calculation
- Animated bus marker
- Error handling and fallback mechanisms

🔄 **In Progress:**
- Localization (Arabic/English)
- Marker tap interactions
- Enhanced UI components

---

## Notes

- Both screens use the same `RideTrackingData` model
- Both screens support occurrence-based and child-based queries
- LiveTrackingScreen is the primary implementation for parent live tracking feature
- RideTrackingScreen serves as an alternative view for users who prefer timeline format
