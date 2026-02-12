# Child Schedule Tabs Fix

## Issues Fixed

### 1. Missing "Today" Tab
**Problem**: The child schedule screen only had "Upcoming" and "History" tabs, but no "Today" tab to show today's rides.

**Solution**: Added a "Today" tab as the first tab that filters and displays only today's rides from the upcoming rides list.

### 2. Tab Switching
**Problem**: When clicking "History" tab, it was still showing upcoming rides content.

**Solution**: Fixed the tab index mapping in `_buildTabContent` method to correctly show:
- Tab 0: Today's rides
- Tab 1: Upcoming rides  
- Tab 2: History rides

## Changes Made

### lib/features/rides/ui/screens/child_schedule_screen.dart

1. **Updated tab list**:
```dart
// Before
List<String> _getTabs(AppLocalizations l10n) => [l10n.upcoming, l10n.history];

// After
List<String> _getTabs(AppLocalizations l10n) => [l10n.today, l10n.upcoming, l10n.history];
```

2. **Fixed tab content mapping**:
```dart
Widget _buildTabContent(BuildContext context, ChildRidesLoaded state, AppLocalizations l10n) {
  switch (_selectedTabIndex) {
    case 0:
      return _buildTodayTab(context, state, l10n);  // NEW: Today tab
    case 1:
      return _buildUpcomingTab(context, state, l10n);  // Was case 0
    case 2:
      return _buildHistoryTab(context, state, l10n);  // Was case 1
    default:
      return const SizedBox();
  }
}
```

3. **Added Today tab implementation**:
```dart
Widget _buildTodayTab(BuildContext context, ChildRidesLoaded state, AppLocalizations l10n) {
  // Filter today's rides from upcoming rides
  final today = DateTime.now();
  final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
  
  final todayRides = state.upcomingRides.where((ride) {
    return ride.date == todayStr;
  }).toList();

  if (todayRides.isEmpty) {
    return CustomEmptyState(
      icon: Icons.today,
      title: l10n.noRidesToday,
      message: l10n.noRidesTodayDesc,
      onRefresh: () => context.read<ChildRidesCubit>().loadRides(),
    );
  }

  return RefreshIndicator(
    onRefresh: () => context.read<ChildRidesCubit>().loadRides(),
    child: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(l10n.today, style: TextStyle(...)),
        const SizedBox(height: 12),
        ...todayRides.map((ride) => Padding(...)),
      ],
    ),
  );
}
```

## Result

Now the child schedule screen has three working tabs:

1. ✅ **Today**: Shows only today's rides (filtered from upcoming)
2. ✅ **Upcoming**: Shows all future rides
3. ✅ **History**: Shows past completed/cancelled rides

Each tab now displays the correct content when selected!

## Testing

After restarting the app:
1. Navigate to a child's schedule
2. You should see three tabs: "اليوم" (Today), "القادمة" (Upcoming), "السجل" (History)
3. Clicking each tab should show different content
4. Today tab shows only today's rides
5. Upcoming tab shows future rides
6. History tab shows past rides
