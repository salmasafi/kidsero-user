# Error Handling Guide

This guide explains how to use the error handling system in the Kidsero app.

## Overview

The error handling system provides:
- Custom exception types for different error scenarios
- Automatic error message localization
- User-friendly error display widgets
- Proper error categorization (network, auth, server, etc.)

## Exception Types

### NetworkException
Thrown when there's a network connectivity issue (no internet, timeout, etc.)

### AuthenticationException
Thrown when authentication fails or session expires (401, 403 errors)

### ServerException
Thrown when the server returns an error (500, 503, etc.)

### DataParsingException
Thrown when data parsing fails

### NotFoundException
Thrown when a resource is not found (404 errors)

### BusinessLogicException
Thrown for business logic errors or generic errors

## Usage in Services/Repositories

```dart
import 'package:dio/dio.dart';
import '../../../core/network/error_handler.dart';
import '../../../core/network/exceptions.dart';

class RidesService {
  Future<ChildrenWithAllRidesResponse> getChildrenWithAllRides() async {
    try {
      final response = await dio.get('/api/users/rides/children');
      return ChildrenWithAllRidesResponse.fromJson(response.data);
    } on DioException catch (e) {
      // Convert DioException to AppException
      throw ErrorHandler.toAppException(e);
    } catch (e) {
      // Handle parsing errors
      throw DataParsingException(
        'Failed to parse children data',
        originalError: e,
      );
    }
  }
}
```

## Usage in Cubits

```dart
import '../../../core/network/error_handler.dart';

class RidesDashboardCubit extends Cubit<RidesDashboardState> {
  Future<void> loadDashboard() async {
    emit(RidesDashboardLoading());
    try {
      final data = await _repository.getChildrenWithRides();
      emit(RidesDashboardLoaded(data));
    } catch (e) {
      // Convert error to user-friendly message
      final errorMessage = ErrorHandler.handle(e);
      emit(RidesDashboardError(errorMessage));
    }
  }
}
```

## Usage in UI

### Using ErrorDisplay Widget

```dart
import '../../../core/widgets/error_display.dart';

class RidesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RidesDashboardCubit, RidesDashboardState>(
      builder: (context, state) {
        if (state is RidesDashboardError) {
          return ErrorDisplay(
            error: state.message,
            onRetry: () => context.read<RidesDashboardCubit>().loadDashboard(),
          );
        }
        // ... other states
      },
    );
  }
}
```

### Using CustomErrorWidget Directly

```dart
import '../../../core/widgets/custom_error_widget.dart';
import '../../../core/network/exceptions.dart';

CustomErrorWidget(
  message: 'Failed to load data',
  error: NetworkException('No internet connection'),
  onRetry: () {
    // Retry logic
  },
)
```

## Error Message Localization

All error messages are automatically localized based on the user's selected language:

- `errorNoInternet`: Network connectivity errors
- `errorSessionExpired`: Authentication errors
- `errorServerUnavailable`: Server errors
- `errorDataProcessing`: Data parsing errors
- `errorNotFound`: Resource not found errors
- `errorGeneric`: Generic errors

## Special Handling for Authentication Errors

When an `AuthenticationException` is thrown, the `CustomErrorWidget` automatically:
1. Displays a lock icon instead of an error icon
2. Shows a "Login" button instead of "Retry"
3. Navigates to the login screen when the button is pressed

## Error Icons

Different error types display different icons:
- NetworkException: WiFi off icon
- AuthenticationException: Lock icon
- ServerException: Cloud off icon
- NotFoundException: Search off icon
- Other errors: Error outline icon

## Best Practices

1. **Always use ErrorHandler.handle()** to convert errors to user-friendly messages
2. **Log errors** with context for debugging
3. **Provide retry options** whenever possible
4. **Use specific exception types** instead of generic exceptions
5. **Don't expose technical details** to users in error messages
6. **Test error scenarios** to ensure proper handling

## Example: Complete Error Handling Flow

```dart
// 1. Service layer - throw specific exceptions
class RidesService {
  Future<Data> fetchData() async {
    try {
      final response = await dio.get('/api/data');
      return Data.fromJson(response.data);
    } on DioException catch (e) {
      throw ErrorHandler.toAppException(e);
    } catch (e) {
      throw DataParsingException('Failed to parse data', originalError: e);
    }
  }
}

// 2. Repository layer - pass through exceptions
class RidesRepository {
  Future<Data> getData() async {
    return await _service.fetchData();
  }
}

// 3. Cubit layer - convert to user message
class DataCubit extends Cubit<DataState> {
  Future<void> loadData() async {
    emit(DataLoading());
    try {
      final data = await _repository.getData();
      emit(DataLoaded(data));
    } catch (e) {
      final message = ErrorHandler.handle(e);
      emit(DataError(message));
    }
  }
}

// 4. UI layer - display error
class DataScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataCubit, DataState>(
      builder: (context, state) {
        if (state is DataError) {
          return ErrorDisplay(
            error: state.message,
            onRetry: () => context.read<DataCubit>().loadData(),
          );
        }
        // ... other states
      },
    );
  }
}
```
