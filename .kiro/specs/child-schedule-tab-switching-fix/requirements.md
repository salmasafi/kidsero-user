# Requirements Document

## Introduction

This specification addresses a critical UI bug in the child schedule screen where tab switching does not update the displayed content. The screen has three tabs (Upcoming, Today, History) but always displays the Upcoming tab content regardless of which tab is selected. The root cause is that the BlocBuilder widget only rebuilds on Cubit state changes, not on local state variable changes.

## Glossary

- **Child_Schedule_Screen**: The screen displaying a child's ride schedule with tabbed navigation
- **Tab_Bar**: The AnimatedTabBar widget that displays three tabs (Upcoming, Today, History)
- **BlocBuilder**: Flutter widget that rebuilds when Bloc/Cubit state changes
- **Local_State**: State managed by StatefulWidget's setState() method
- **Tab_Content**: The widget tree displaying rides for the selected tab
- **Upcoming_Rides**: Future scheduled rides for the child
- **Today_Rides**: Rides scheduled for the current date
- **History_Rides**: Past completed or cancelled rides

## Requirements

### Requirement 1: Tab Selection State Management

**User Story:** As a parent, I want to see different content when I tap different tabs, so that I can view upcoming rides, today's rides, or ride history independently.

#### Acceptance Criteria

1. WHEN a user taps the "Upcoming" tab, THE Child_Schedule_Screen SHALL display all upcoming rides
2. WHEN a user taps the "Today" tab, THE Child_Schedule_Screen SHALL display only today's rides filtered from upcoming rides
3. WHEN a user taps the "History" tab, THE Child_Schedule_Screen SHALL display past rides
4. WHEN a user switches between tabs, THE Tab_Content SHALL rebuild immediately to show the correct content
5. WHEN the Tab_Bar calls onTabSelected callback, THE Child_Schedule_Screen SHALL update the displayed content

### Requirement 2: Widget Rebuild Behavior

**User Story:** As a developer, I want the widget tree to rebuild when tab selection changes, so that the UI reflects the current tab state.

#### Acceptance Criteria

1. WHEN _selectedTabIndex changes via setState(), THE Tab_Content SHALL rebuild to reflect the new selection
2. WHEN BlocBuilder wraps the content, THE system SHALL ensure local state changes trigger rebuilds
3. WHEN tab switching occurs, THE rebuild SHALL happen without requiring Cubit state changes
4. THE Child_Schedule_Screen SHALL maintain proper separation between Bloc state and local UI state

### Requirement 3: Content Filtering and Display

**User Story:** As a parent, I want each tab to show its specific content, so that I can easily find the rides I'm looking for.

#### Acceptance Criteria

1. THE Upcoming_Tab SHALL display all rides from state.upcomingRides
2. THE Today_Tab SHALL filter rides where ride.date equals today's date
3. THE History_Tab SHALL display all rides from state.historyRides
4. WHEN a tab has no rides, THE system SHALL display an appropriate empty state message
5. WHEN switching tabs, THE previous tab's content SHALL not persist or leak into the new tab

### Requirement 4: Existing Functionality Preservation

**User Story:** As a parent, I want all existing features to continue working after the fix, so that I don't lose any functionality.

#### Acceptance Criteria

1. THE Pull_To_Refresh SHALL continue working on all three tabs
2. THE Report_Absence_Dialog SHALL continue to function correctly
3. THE Loading_States SHALL display correctly during data fetching
4. THE Error_States SHALL display correctly when data loading fails
5. THE Summary_Dialog SHALL continue to display ride statistics
6. THE BlocConsumer for ReportAbsenceCubit SHALL continue to handle absence reporting

### Requirement 5: Performance and User Experience

**User Story:** As a parent, I want tab switching to be smooth and responsive, so that the app feels fast and reliable.

#### Acceptance Criteria

1. WHEN switching tabs, THE transition SHALL complete within 200 milliseconds
2. THE Tab_Bar animation SHALL remain smooth during tab selection
3. THE system SHALL not cause unnecessary rebuilds of unchanged widgets
4. THE system SHALL maintain scroll position when returning to a previously viewed tab
5. WHEN data is already loaded, THE tab switch SHALL not trigger network requests
