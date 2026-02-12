# Design Document: Child Schedule Tab Switching Fix

## Overview

This design addresses a critical bug in the `ChildScheduleScreen` where tab switching does not update the displayed content. The root cause is that the `BlocBuilder` widget only rebuilds when the Cubit emits new state, but not when the local `_selectedTabIndex` state variable changes via `setState()`.

The fix involves restructuring the widget tree to ensure that local state changes trigger proper rebuilds of the tab content. We will move the `BlocBuilder` inside the tab content methods rather than wrapping the entire content area, allowing the outer widget tree to rebuild on local state changes while still maintaining proper Bloc state management for data loading.

### Key Insight

The current structure has `BlocBuilder` wrapping the entire content area, which means the widget tree only rebuilds when `ChildRidesState` changes. When `_selectedTabIndex` changes via `setState()`, the `BlocBuilder` doesn't rebuild because the Bloc state hasn't changed. The `_buildTabContent` method is called, but since it's inside a `BlocBuilder` that hasn't detected a state change, the UI doesn't update.

### Solution Approach

We will restructure the widget tree to separate concerns:
1. The outer widget tree will respond to local state changes (`_selectedTabIndex`)
2. Individual tab content widgets will use `BlocBuilder` internally for data loading states
3. This ensures both local state changes and Bloc state changes trigger appropriate rebuilds

## Architecture

### Current Architecture (Problematic)

```
Scaffold
└── Column
    ├── Header
    ├── AnimatedTabBar (updates _selectedTabIndex)
    └── Expanded
        └── BlocConsumer<ReportAbsenceCubit>
            └── BlocBuilder<ChildRidesCubit> ← Only rebuilds on Cubit state changes
                └── _buildTabContent() ← Never rebuilds when _selectedTabIndex changes
```

### New Architecture (Fixed)

```
Scaffold
└── Column
    ├── Header
    ├── AnimatedTabBar (updates _selectedTabIndex)
    └── Expanded
        └── BlocConsumer<ReportAbsenceCubit>
            └── _buildTabContent() ← Rebuilds on setState()
                ├── Upcoming Tab
                │   └── BlocBuilder<ChildRidesCubit> ← Handles loading states
                ├── Today Tab
                │   └── BlocBuilder<ChildRidesCubit> ← Handles loading states
                └── History Tab
                    └── BlocBuilder<ChildRidesCubit> ← Handles loading states
```

## Components and Interfaces

### Modified Components

#### 1. `_ChildScheduleViewState.build()`

**Current Behavior:**
- Wraps entire content area with `BlocBuilder`
- Tab content is built inside the `BlocBuilder`
- Local state changes don't trigger rebuilds

**New Behavior:**
- Moves `BlocBuilder` into individual tab content methods
- Outer widget tree responds to `setState()` calls
- Each tab independently handles Bloc state

**Interface Changes:**
- No public interface changes
- Internal restructuring only

#### 2. `_ChildScheduleViewState._buildTabContent()`

**Current Signature:**
```dart
Widget _buildTabContent(
  BuildContext context,
  ChildRidesLoaded state,
  AppLocalizations l10n,
)
```

**New Signature:**
```dart
Widget _buildTabContent(
  BuildContext context,
  AppLocalizations l10n,
)
```

**Changes:**
- Remove `state` parameter (will be obtained via `BlocBuilder` inside each tab)
- Return widget that rebuilds on local state changes
- Delegate to tab-specific methods that use `BlocBuilder` internally

#### 3. Tab Content Methods

**Current Signature:**
```dart
Widget _buildUpcomingTab(
  BuildContext context,
  ChildRidesLoaded state,
  AppLocalizations l10n,
)
```

**New Signature:**
```dart
Widget _buildUpcomingTab(
  BuildContext context,
  AppLocalizations l10n,
)
```

**Changes:**
- Remove `state` parameter
- Add `BlocBuilder<ChildRidesCubit, ChildRidesState>` wrapper inside method
- Handle all loading, error, and empty states internally
- Return appropriate content based on Cubit state

### Component Responsibilities

#### `_ChildScheduleViewState`
- Manage `_selectedTabIndex` local state
- Handle tab selection callbacks
- Coordinate between tab bar and content area
- Maintain BlocConsumer for absence reporting

#### `_buildTabContent()`
- Switch on `_selectedTabIndex`
- Return appropriate tab widget
- Rebuild when `_selectedTabIndex` changes

#### Tab Content Methods (`_buildUpcomingTab`, `_buildTodayTab`, `_buildHistoryTab`)
- Wrap content in `BlocBuilder<ChildRidesCubit, ChildRidesState>`
- Handle loading states (show CircularProgressIndicator)
- Handle error states (show CustomEmptyState with error)
- Handle empty states (show CustomEmptyState with no data message)
- Handle loaded states (show ride list)
- Provide pull-to-refresh functionality

## Data Models

No changes to existing data models. The fix is purely a widget tree restructuring.

### Existing Models Used

- `ChildRidesState` (abstract base)
  - `ChildRidesInitial`
  - `ChildRidesLoading`
  - `ChildRidesLoaded`
  - `ChildRidesEmpty`
  - `ChildRidesError`

- `ChildRidesLoaded` properties:
  - `upcomingRides: List<RideHistoryItem>`
  - `historyRides: List<RideHistoryItem>`
  - `summary: RideSummary?`

- `RideHistoryItem` properties:
  - `rideId: String`
  - `date: String` (format: YYYY-MM-DD)
  - `period: String` (morning/afternoon)
  - `status: String`
  - `pickedUpAt: String?`
  - `droppedOffAt: String?`

### Data Flow

1. User taps tab → `onTabSelected(index)` called
2. `setState(() { _selectedTabIndex = index; })` executed
3. Widget tree rebuilds (outer tree responds to setState)
4. `_buildTabContent()` called with new `_selectedTabIndex`
5. Appropriate tab method called
6. Tab method's `BlocBuilder` reads current `ChildRidesState`
7. Content rendered based on both tab selection and Cubit state


## Correctness Properties

A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.

### Property Reflection

After analyzing the acceptance criteria, I identified several areas of redundancy:

1. **Tab Content Display Properties (3.1, 3.3)**: Both test that tabs display their respective data. These can be combined into a single property that validates correct data display for any tab.

2. **State Handling Properties (4.3, 4.4)**: Both test that different Cubit states are handled correctly. These can be combined into a single property that validates all state types are handled properly.

3. **Tab Switching Properties (1.4, 1.5, 2.1, 2.3)**: All test that tab switching causes proper rebuilds. These are all validating the same core behavior and can be combined into a single comprehensive property.

4. **Content Isolation (3.5)**: This is implicitly validated by the tab switching property - if the correct content is displayed after switching, then previous content hasn't leaked.

### Core Properties

#### Property 1: Tab Selection Updates Content

*For any* tab index (0, 1, or 2), when the tab is selected via `onTabSelected`, the displayed content should match the expected content for that tab index (Upcoming for 0, Today for 1, History for 2).

**Validates: Requirements 1.1, 1.2, 1.3, 1.4, 1.5, 2.1, 2.3, 3.5**

**Testing Approach:**
- Use Flutter widget testing
- Create mock `ChildRidesLoaded` state with known data
- Simulate tab selection for each index
- Verify correct content is displayed using widget finders
- Verify previous tab content is not present

#### Property 2: Today Tab Filters Correctly

*For any* set of upcoming rides with various dates, the Today tab should display only rides where `ride.date` equals today's date in YYYY-MM-DD format.

**Validates: Requirements 3.2**

**Testing Approach:**
- Generate rides with dates: yesterday, today, tomorrow
- Select Today tab
- Verify only today's rides are displayed
- Verify count matches expected filtered count

#### Property 3: Tab Content Displays All Data

*For any* non-empty list of rides, when displaying that list in a tab, all rides from the list should be present in the rendered widget tree.

**Validates: Requirements 3.1, 3.3**

**Testing Approach:**
- Create mock data with known ride IDs
- Render each tab with its respective data
- Verify all ride IDs are present in the widget tree
- Test with varying list sizes (1, 5, 10 rides)

#### Property 4: Empty States Display Correctly

*For any* tab with an empty ride list, the tab should display a `CustomEmptyState` widget with an appropriate message for that tab type.

**Validates: Requirements 3.4**

**Testing Approach:**
- Provide empty lists for each ride type
- Select each tab
- Verify `CustomEmptyState` widget is present
- Verify correct icon and message for each tab

#### Property 5: All Cubit States Handled

*For any* `ChildRidesState` (Loading, Error, Empty, Loaded), each tab should handle the state appropriately by displaying the correct widget (loading indicator, error message, empty state, or content).

**Validates: Requirements 4.3, 4.4**

**Testing Approach:**
- Mock Cubit to emit each state type
- Select each tab
- Verify correct widget is displayed for each state
- Verify loading shows CircularProgressIndicator
- Verify error shows CustomEmptyState with error message

#### Property 6: Pull-to-Refresh Works on All Tabs

*For any* tab, when pull-to-refresh is triggered, the system should call `context.read<ChildRidesCubit>().loadRides()`.

**Validates: Requirements 4.1**

**Testing Approach:**
- Select each tab
- Simulate pull-to-refresh gesture
- Verify `loadRides()` is called on the Cubit
- Use mock Cubit to track method calls

#### Property 7: Tab Switching Doesn't Trigger Data Fetching

*For any* tab switch operation when data is already loaded, the system should not call `loadRides()` on the Cubit.

**Validates: Requirements 5.5**

**Testing Approach:**
- Load data once (Cubit in ChildRidesLoaded state)
- Switch between all tabs
- Verify `loadRides()` is not called during tab switches
- Use mock Cubit to track method calls

### Example-Based Tests

These are specific scenarios that should be tested with concrete examples rather than property-based testing:

#### Example 1: Report Absence Dialog Functions

When the "Report Absence" button is tapped on an upcoming ride card, the system should display the report absence dialog with a text field for the reason.

**Validates: Requirements 4.2**

**Testing Approach:**
- Render Upcoming tab with a ride
- Tap "Report Absence" button
- Verify dialog is displayed
- Verify text field is present
- Verify submit button is present

#### Example 2: Summary Dialog Displays Statistics

When the summary button in the header is tapped, the system should display a dialog with ride statistics (total scheduled, attended, absent, late, attendance rate).

**Validates: Requirements 4.5**

**Testing Approach:**
- Provide mock summary data
- Tap summary button
- Verify dialog is displayed
- Verify all statistics are present
- Verify correct values are displayed

#### Example 3: BlocConsumer Handles Absence Reporting

When an absence is reported successfully, the system should show a success snackbar and refresh the rides.

**Validates: Requirements 4.6**

**Testing Approach:**
- Mock ReportAbsenceCubit to emit success state
- Verify success snackbar is displayed
- Verify `loadRides()` is called on ChildRidesCubit

## Error Handling

### Current Error Handling (Preserved)

The fix maintains all existing error handling:

1. **Cubit Error State**: When `ChildRidesCubit` emits `ChildRidesError`, display `CustomEmptyState` with error message and retry button
2. **Absence Reporting Error**: When `ReportAbsenceCubit` emits `ReportAbsenceError`, display error snackbar
3. **Empty Data**: When no rides exist, display appropriate empty state for each tab

### Error Scenarios

| Scenario | Current Behavior | After Fix |
|----------|------------------|-----------|
| Network error loading rides | Show error state with retry | Same (preserved) |
| Empty upcoming rides | Show empty state | Same (preserved) |
| Empty history | Show empty state | Same (preserved) |
| Empty today rides | Show empty state | Same (preserved) |
| Absence reporting fails | Show error snackbar | Same (preserved) |
| Tab switch during loading | Show loading indicator | Same (preserved) |

### Edge Cases

1. **Switching tabs during loading**: Each tab will independently show loading state
2. **Switching tabs during error**: Each tab will independently show error state
3. **Today's date changes**: Today tab will filter based on current date at render time
4. **No rides for today**: Today tab shows empty state with appropriate message

## Testing Strategy

### Dual Testing Approach

We will use both unit tests and widget tests to ensure comprehensive coverage:

- **Widget tests**: Verify UI behavior, widget tree structure, and user interactions
- **Unit tests**: Verify data filtering logic (e.g., today's date filtering)

Both approaches are complementary and necessary for comprehensive coverage. Widget tests handle the UI interactions and rebuilds, while unit tests verify the data transformation logic.

### Widget Testing

**Framework**: Flutter's `flutter_test` package with `testWidgets`

**Test Structure**:
```dart
testWidgets('Property 1: Tab selection updates content', (tester) async {
  // Feature: child-schedule-tab-switching-fix, Property 1
  // For any tab index, selecting it should display correct content
  
  // Setup mock data
  // Pump widget
  // For each tab index:
  //   - Tap tab
  //   - Verify correct content displayed
  //   - Verify previous content not present
});
```

**Key Testing Utilities**:
- `tester.pumpWidget()`: Render widget tree
- `tester.tap()`: Simulate user taps
- `tester.pump()`: Trigger rebuild
- `find.byType()`: Find widgets by type
- `find.text()`: Find widgets by text
- `find.byKey()`: Find widgets by key

**Mock Strategy**:
- Use `MockChildRidesCubit` extending `Mock` with `mocktail`
- Stub `state` getter to return desired states
- Stub `loadRides()` to track calls
- Use `BlocProvider.value` to inject mock

### Unit Testing

**Framework**: Standard Dart `test` package

**Test Cases**:
1. Today date filtering logic
2. Date string parsing and comparison
3. Empty list handling

**Test Structure**:
```dart
test('Today tab filters rides by current date', () {
  // Feature: child-schedule-tab-switching-fix, Property 2
  // For any set of rides, only today's rides should be included
  
  // Create rides with various dates
  // Filter using today's date
  // Verify only today's rides remain
});
```

### Test Configuration

- **Minimum test coverage**: 90% for modified files
- **Widget test count**: Minimum 7 tests (one per property)
- **Unit test count**: Minimum 3 tests (date filtering logic)
- **Example test count**: 3 tests (dialogs and BlocConsumer)

### Integration Testing

While not part of this spec, the following integration tests should be performed manually:

1. Test on real device with actual API data
2. Test with slow network to verify loading states
3. Test with network errors to verify error handling
4. Test pull-to-refresh on all tabs
5. Test absence reporting end-to-end

### Test Tags

All tests should be tagged for easy filtering:

```dart
@Tags(['child-schedule', 'tab-switching', 'widget-test'])
testWidgets('...', (tester) async { ... });

@Tags(['child-schedule', 'tab-switching', 'unit-test'])
test('...', () { ... });
```

### Continuous Integration

Tests should run on:
- Every pull request
- Every commit to main branch
- Nightly builds

**CI Configuration**:
```yaml
test:
  script:
    - flutter test --coverage
    - flutter test --tags=child-schedule
  coverage: '/lines\.*: \d+\.\d+%/'
```
