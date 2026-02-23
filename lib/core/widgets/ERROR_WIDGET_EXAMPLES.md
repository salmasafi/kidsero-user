# Error Widget Usage Examples

This document provides examples of how to use the error handling widgets in different scenarios.

## Example 1: Using ErrorDisplay in a BlocBuilder

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/widgets/error_display.dart';
import '../../../core/widgets/loading_widget.dart';

class RidesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rides')),
      body: BlocBuilder<RidesDashboardCubit, RidesDashboardState>(
        builder: (context, state) {
          if (state is RidesDashboardLoading) {
            return const LoadingWidget();
          }
          
          if (state is RidesDashboardError) {
            return ErrorDisplay(
              error: state.message,
              onRetry: () => context.read<RidesDashboardCubit>().loadDashboard(),
            );
          }
          
          if (state is RidesDashboardLoaded) {
            return _buildContent(state);
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
```

## Example 2: Using CustomErrorWidget Directly

```dart
import 'package:flutter/material.dart';
import '../../../core/widgets/custom_error_widget.dart';
import '../../../core/network/exceptions.dart';

class MyWidget extends StatelessWidget {
  final dynamic error;
  
  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      message: 'Failed to load data',
      error: error, // Pass the actual error for proper icon/button handling
      onRetry: () {
        // Retry logic here
      },
    );
  }
}
```

## Example 3: Handling Different Error Types

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/widgets/error_display.dart';
import '../../../core/network/exceptions.dart';

class DataScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DataCubit, DataState>(
      listener: (context, state) {
        if (state is DataError) {
          // Show different snackbar colors based on error type
          final error = state.error;
          Color backgroundColor = Colors.red;
          
          if (error is NetworkException) {
            backgroundColor = Colors.orange;
          } else if (error is AuthenticationException) {
            backgroundColor = Colors.purple;
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: backgroundColor,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is DataError) {
          return ErrorDisplay(
            error: state.error,
            onRetry: () => context.read<DataCubit>().loadData(),
          );
        }
        // ... other states
      },
    );
  }
}
```

## Example 4: Error Handling with Pull-to-Refresh

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/widgets/error_display.dart';

class RefreshableScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<DataCubit, DataState>(
        builder: (context, state) {
          if (state is DataError) {
            // Allow pull-to-refresh even in error state
            return RefreshIndicator(
              onRefresh: () async {
                await context.read<DataCubit>().loadData();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - 100,
                  child: ErrorDisplay(
                    error: state.message,
                    onRetry: () => context.read<DataCubit>().loadData(),
                  ),
                ),
              ),
            );
          }
          
          if (state is DataLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                await context.read<DataCubit>().refresh();
              },
              child: _buildContent(state),
            );
          }
          
          return const LoadingWidget();
        },
      ),
    );
  }
}
```

## Example 5: Inline Error Messages

```dart
import 'package:flutter/material.dart';
import '../../../core/network/error_handler.dart';

class InlineErrorExample extends StatelessWidget {
  final dynamic error;
  final VoidCallback onRetry;
  
  @override
  Widget build(BuildContext context) {
    final errorMessage = ErrorHandler.handle(error);
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              errorMessage,
              style: TextStyle(color: Colors.red.shade900),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }
}
```

## Example 6: Error Handling in Forms

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/error_handler.dart';

class FormScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FormCubit, FormState>(
      listener: (context, state) {
        if (state is FormError) {
          // Show error dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Error'),
              content: Text(ErrorHandler.handle(state.error)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.read<FormCubit>().retry();
                  },
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }
        
        if (state is FormSuccess) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Success!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      builder: (context, state) {
        return Form(
          child: Column(
            children: [
              // Form fields here
              
              if (state is FormError)
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    ErrorHandler.handle(state.error),
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              
              ElevatedButton(
                onPressed: state is FormLoading 
                    ? null 
                    : () => context.read<FormCubit>().submit(),
                child: state is FormLoading
                    ? CircularProgressIndicator()
                    : Text('Submit'),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

## Example 7: Handling Authentication Errors

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/widgets/error_display.dart';
import '../../../core/network/exceptions.dart';

class ProtectedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<DataCubit, DataState>(
      listener: (context, state) {
        if (state is DataError && state.error is AuthenticationException) {
          // Automatically navigate to login on auth errors
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        }
      },
      child: BlocBuilder<DataCubit, DataState>(
        builder: (context, state) {
          if (state is DataError) {
            return ErrorDisplay(
              error: state.error,
              onRetry: () => context.read<DataCubit>().loadData(),
            );
          }
          // ... other states
        },
      ),
    );
  }
}
```

## Best Practices

1. **Always provide a retry option** when displaying errors
2. **Use ErrorDisplay for full-screen errors** in main content areas
3. **Use inline error messages** for form validation or small components
4. **Show snackbars for transient errors** that don't block the UI
5. **Handle authentication errors specially** by navigating to login
6. **Keep error states** when possible to allow users to see what went wrong
7. **Log errors** for debugging while showing user-friendly messages
8. **Test error scenarios** to ensure proper handling
