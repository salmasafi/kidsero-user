# Rides Dashboard Error Fix

## Error
```
[RidesService] Error getting children with rides: type 'List<dynamic>' is not a subtype of type 'Map<String, dynamic>'
```

## Root Cause
The `RidesDashboardCubit` was trying to call `/api/users/rides/children` endpoint which doesn't return children data in the expected format. Instead, it returns ride data like `upcomingRides`.

The API response showed:
```json
{
  "success": true,
  "data": {
    "upcomingRides": [...]  // This is rides data, not children!
  }
}
```

But the code expected:
```json
{
  "success": true,
  "data": [
    { "id": "...", "name": "...", "rides": {...} }  // Children objects
  ]
}
```

## Solution
Changed the `RidesDashboardCubit` to use the correct `/api/users/children` endpoint for fetching children data instead of the non-existent `/api/users/rides/children` endpoint.

### Changes Made

1. **Updated `RidesDashboardCubit`**:
   - Added `ApiService` dependency
   - Changed from `ChildWithRides` to `child_model.Child` for children data
   - Use `_apiService.getChildren()` instead of `_repository.getChildrenWithRides()`

2. **Updated `RidesScreen`**:
   - Pass `ApiService` to the cubit constructor

### Code Changes

**lib/features/rides/cubit/rides_dashboard_cubit.dart**:
```dart
class RidesDashboardCubit extends Cubit<RidesDashboardState> {
  final RidesRepository _repository;
  final ApiService _apiService;  // Added

  RidesDashboardCubit({
    required RidesRepository repository,
    required ApiService apiService,  // Added
  })  : _repository = repository,
        _apiService = apiService,
        super(RidesDashboardInitial());

  Future<void> loadDashboard() async {
    emit(RidesDashboardLoading());
    try {
      final results = await Future.wait([
        _apiService.getChildren(),  // Changed from getChildrenWithRides()
        _repository.getActiveRides(),
        _repository.getUpcomingRides(),
      ]);

      final children = results[0] as List<child_model.Child>;  // Changed type
      // ...
    }
  }
}
```

**lib/features/rides/ui/screens/rides_screen.dart**:
```dart
return BlocProvider(
  create: (context) =>
      RidesDashboardCubit(
        repository: ridesRepository,
        apiService: apiService,  // Added
      )..loadDashboard(),
  child: const _RidesDashboard(),
);
```

## Result
The rides dashboard now correctly:
1. Fetches children from `/api/users/children` ✅
2. Fetches active rides from `/api/users/rides/active` ✅
3. Fetches upcoming rides from `/api/users/rides/upcoming` ✅

The error should be resolved and children should display correctly!
