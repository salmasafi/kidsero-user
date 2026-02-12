# Rides Empty Data Display Fix

## Problem
When the API returned empty ride arrays (e.g., `{"activeRides": [], "count": 0}`), the app was displaying "1 ride" with empty/default values instead of showing "0 rides" or an empty state.

## Root Cause
The JSON parsing logic in the ride response models had a problematic fallback:

```dart
} else {
  listData = [rawData];  // This wraps the entire response object as a single item!
}
```

When the API returned:
```json
{
  "success": true,
  "data": {
    "activeRides": [],
    "count": 0
  }
}
```

The parser would:
1. Extract `rawData` = `{"activeRides": [], "count": 0}`
2. Check for known list keys (`data`, `items`, `results`, `active`)
3. Find none of them
4. Fall back to wrapping the entire object: `[{"activeRides": [], "count": 0}]`
5. Try to parse this as an `ActiveRide` object, creating one ride with empty values

## Solution
Removed the problematic fallback `listData = [rawData]` from all ride response models. Now when the API returns an empty array or a response without the expected list keys, the parser correctly returns an empty list instead of creating phantom rides.

## Files Modified
- `lib/features/rides/models/ride_models.dart`
  - Fixed `ActiveRidesResponse.fromJson()` - Added check for `activeRides` key
  - Fixed `ChildrenWithRidesResponse.fromJson()` - Removed fallback
  - Fixed `TodayRidesResponse.fromJson()` - Added check for `todayRides` key
  - Fixed `UpcomingRidesResponse.fromJson()` - Added check for `upcomingRides` key

## Expected Behavior Now
- When API returns `{"activeRides": []}` → App shows 0 active rides
- When API returns `{"todayRides": []}` → App shows 0 today rides
- When API returns `{"upcomingRides": []}` → App shows 0 upcoming rides
- Empty states are properly displayed in the UI
- No phantom rides with empty data

## Testing
To verify the fix:
1. Open the rides screen when there are no active rides
2. Check that it shows "0" in the live tracking card
3. Verify no empty ride cards are displayed
4. Check child schedule screens show proper empty states
