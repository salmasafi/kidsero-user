/// Mock Data System for Kidsero Parent App
/// 
/// This library exports all mock data and services for testing the app
/// without a backend connection.
/// 
/// To enable mock data:
/// 1. Set [MockConfig.enableMockData] to true in `mock_config.dart`
/// 2. Add [MockInterceptor] to your Dio instance
/// 
/// Example usage:
/// ```dart
/// import 'package:kidsero_parent/core/mock/mock_data.dart';
/// 
/// // In your main.dart or where you initialize Dio:
/// final dio = Dio();
/// if (MockConfig.enableMockData) {
///   dio.interceptors.add(MockInterceptor());
/// }
/// ```

// Configuration
export 'mock_config.dart';

// Interceptor
export 'mock_interceptor.dart';

// API Service
export 'mock_api_service.dart';

// Mock Data
export 'mock_data/mock_auth_data.dart';
export 'mock_data/mock_children_data.dart';
export 'mock_data/mock_notices_data.dart';
export 'mock_data/mock_payments_data.dart';
export 'mock_data/mock_plans_data.dart';
export 'mock_data/mock_profile_data.dart';
export 'mock_data/mock_rides_data.dart';
