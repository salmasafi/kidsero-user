import 'dart:async';
import 'dart:developer' as dev;

import 'package:dio/dio.dart';

import '../network/api_endpoints.dart';
import 'mock_config.dart';
import 'mock_data/mock_auth_data.dart';
import 'mock_data/mock_children_data.dart';
import 'mock_data/mock_notices_data.dart';
import 'mock_data/mock_payments_data.dart';
import 'mock_data/mock_plans_data.dart';
import 'mock_data/mock_profile_data.dart';
import 'mock_data/mock_rides_data.dart';

/// Mock API Service that intercepts API calls and returns mock data
/// 
/// This service simulates all backend API responses for testing purposes.
/// Enable it by setting [MockConfig.enableMockData] to true.
class MockApiService {
  /// Simulate network delay
  static Future<void> _simulateDelay() async {
    if (MockConfig.mockDelayMs > 0) {
      await Future.delayed(Duration(milliseconds: MockConfig.mockDelayMs));
    }
  }

  /// Log mock request
  static void _logRequest(String method, String path, {dynamic data}) {
    if (MockConfig.enableLogging) {
      dev.log(
        'MOCK [$method] $path${data != null ? ' | Data: $data' : ''}',
        name: 'MockApiService',
      );
    }
  }

  /// Log mock response
  static void _logResponse(String path, dynamic response) {
    if (MockConfig.enableLogging) {
      dev.log(
        'MOCK RESPONSE [$path]: ${response.toString().substring(0, response.toString().length > 200 ? 200 : response.toString().length)}...',
        name: 'MockApiService',
      );
    }
  }

  /// Handle login request
  static Future<Response> handleLogin(String path, dynamic data) async {
    _logRequest('POST', path, data: data);
    await _simulateDelay();

    // Support both 'identifier' and 'phone' field names
    final phone = data['identifier']?.toString() ?? data['phone']?.toString() ?? '';
    final password = data['password']?.toString() ?? '';

    // Simulate validation
    if (phone.isEmpty || password.isEmpty) {
      final errorResponse = {
        'success': false,
        'message': 'Phone and password are required',
      };
      _logResponse(path, errorResponse);
      return Response(
        requestOptions: RequestOptions(path: path),
        data: errorResponse,
        statusCode: 400,
      );
    }

    // Accept any valid-looking phone number (starts with + or digits)
    if (phone.startsWith('+') || RegExp(r'^\d+$').hasMatch(phone)) {
      if (password.length >= 4) {
        final response = {
          'success': true,
          'data': {
            'message': 'Login successful',
            'token': MockConfig.mockToken,
            'user': {
              'id': MockConfig.mockParentId,
              'name': 'Ahmed Hassan',
              'phone': phone,
              'avatar': null,
              'address': 'Cairo, Egypt',
              'role': 'parent',
              'status': 'active',
            },
          },
        };
        _logResponse(path, response);
        return Response(
          requestOptions: RequestOptions(path: path),
          data: response,
          statusCode: 200,
        );
      }
    }

    final errorResponse = MockAuthData.invalidCredentialsError;
    _logResponse(path, errorResponse);
    return Response(
      requestOptions: RequestOptions(path: path),
      data: errorResponse,
      statusCode: 401,
    );
  }

  /// Handle GET requests
  static Future<Response> handleGet(String path, {Map<String, dynamic>? queryParameters}) async {
    _logRequest('GET', path);
    await _simulateDelay();

    // Auth/User
    if (path == ApiEndpoints.profile) {
      final response = {
        'success': true,
        'data': {
          'profile': {
            'id': MockConfig.mockParentId,
            'name': 'Ahmed Hassan',
            'phone': '+201234567890',
            'avatar': null,
            'address': 'Cairo, Egypt',
            'role': 'parent',
            'status': 'active',
          },
        },
      };
      _logResponse(path, response);
      return Response(requestOptions: RequestOptions(path: path), data: response, statusCode: 200);
    }

    // Children
    if (path == ApiEndpoints.children || path == '/api/users/children') {
      _logResponse(path, MockChildrenData.childResponse);
      return Response(
        requestOptions: RequestOptions(path: path),
        data: MockChildrenData.childResponse,
        statusCode: 200,
      );
    }

    // Rides
    if (path == ApiEndpoints.ridesChildren) {
      _logResponse(path, MockChildrenData.childrenWithRidesResponse);
      return Response(
        requestOptions: RequestOptions(path: path),
        data: MockChildrenData.childrenWithRidesResponse,
        statusCode: 200,
      );
    }

    if (path == ApiEndpoints.ridesActive) {
      _logResponse(path, MockRidesData.activeRides);
      return Response(
        requestOptions: RequestOptions(path: path),
        data: MockRidesData.activeRides,
        statusCode: 200,
      );
    }

    if (path == ApiEndpoints.ridesUpcoming) {
      _logResponse(path, MockRidesData.upcomingRides);
      return Response(
        requestOptions: RequestOptions(path: path),
        data: MockRidesData.upcomingRides,
        statusCode: 200,
      );
    }

    // Child rides (today/history/upcoming)
    if (path.contains('/api/users/rides/child/')) {
      final type = queryParameters?['type'] ?? 'today';
      final childId = path.split('/').last;
      
      if (type == 'history') {
        final response = MockRidesData.getChildHistoryRides(childId);
        _logResponse(path, response);
        return Response(requestOptions: RequestOptions(path: path), data: response, statusCode: 200);
      } else {
        final response = MockRidesData.getChildTodayRides(childId);
        _logResponse(path, response);
        return Response(requestOptions: RequestOptions(path: path), data: response, statusCode: 200);
      }
    }

    // Child ride summary
    if (path.contains('/api/users/rides/child/') && path.contains('/summary')) {
      final childId = path.split('/')[5]; // /api/users/rides/child/{id}/summary
      final response = MockRidesData.getChildRideSummary(childId);
      _logResponse(path, response);
      return Response(requestOptions: RequestOptions(path: path), data: response, statusCode: 200);
    }

    // Ride tracking
    if (path.contains('/api/users/rides/tracking/')) {
      final id = path.split('/').last;
      final response = MockRidesData.getRideTracking(id);
      _logResponse(path, response);
      return Response(requestOptions: RequestOptions(path: path), data: response, statusCode: 200);
    }

    // Payments
    if (path == ApiEndpoints.parentPayments) {
      _logResponse(path, MockPaymentsData.paymentHistoryResponse);
      return Response(
        requestOptions: RequestOptions(path: path),
        data: MockPaymentsData.paymentHistoryResponse,
        statusCode: 200,
      );
    }

    if (path == '/api/users/paymentmethods') {
      _logResponse(path, MockPaymentsData.paymentMethodsResponse);
      return Response(
        requestOptions: RequestOptions(path: path),
        data: MockPaymentsData.paymentMethodsResponse,
        statusCode: 200,
      );
    }

    // Payment detail
    if (path.startsWith('/api/users/parentpayments/') && !path.endsWith('/org-service')) {
      final id = path.split('/').last;
      final response = MockPaymentsData.getPaymentById(id);
      _logResponse(path, response);
      return Response(requestOptions: RequestOptions(path: path), data: response, statusCode: 200);
    }

    // Plans & Subscriptions
    if (path == ApiEndpoints.parentPlans) {
      _logResponse(path, MockPlansData.plansResponse);
      return Response(
        requestOptions: RequestOptions(path: path),
        data: MockPlansData.plansResponse,
        statusCode: 200,
      );
    }

    if (path == ApiEndpoints.parentSubscriptions) {
      _logResponse(path, MockPlansData.parentSubscriptionsResponse);
      return Response(
        requestOptions: RequestOptions(path: path),
        data: MockPlansData.parentSubscriptionsResponse,
        statusCode: 200,
      );
    }

    // Org Services
    if (path.contains('/api/users/organizationservices/')) {
      final parts = path.split('/');
      if (parts.length > 4 && parts[4] == 'organizationservices') {
        final studentId = parts[5];
        final response = MockPlansData.orgServicesResponse(studentId);
        _logResponse(path, response);
        return Response(requestOptions: RequestOptions(path: path), data: response, statusCode: 200);
      }
    }

    // Student active services
    if (path.contains('/api/users/organizationservices/current-subscribed/')) {
      final studentId = path.split('/').last;
      final response = MockPlansData.studentActiveServicesResponse(studentId);
      _logResponse(path, response);
      return Response(requestOptions: RequestOptions(path: path), data: response, statusCode: 200);
    }

    // Notes
    if (path == ApiEndpoints.notes) {
      _logResponse(path, MockNoticesData.allNotesResponse);
      return Response(
        requestOptions: RequestOptions(path: path),
        data: MockNoticesData.allNotesResponse,
        statusCode: 200,
      );
    }

    if (path == ApiEndpoints.upcomingNotes) {
      _logResponse(path, MockNoticesData.upcomingNotesResponse);
      return Response(
        requestOptions: RequestOptions(path: path),
        data: MockNoticesData.upcomingNotesResponse,
        statusCode: 200,
      );
    }

    // Note detail
    if (path.startsWith('/api/users/notes/') && !path.endsWith('/upcoming')) {
      final id = path.split('/').last;
      final response = MockNoticesData.getNoteById(id);
      _logResponse(path, response);
      return Response(requestOptions: RequestOptions(path: path), data: response, statusCode: 200);
    }

    // Default response for unhandled endpoints
    dev.log('MOCK: Unhandled GET endpoint: $path', name: 'MockApiService');
    return Response(
      requestOptions: RequestOptions(path: path),
      data: {'success': false, 'message': 'Endpoint not implemented in mock'},
      statusCode: 404,
    );
  }

  /// Handle POST requests
  static Future<Response> handlePost(String path, dynamic data) async {
    _logRequest('POST', path, data: data);
    await _simulateDelay();

    // Login
    if (path == ApiEndpoints.login || path == '/api/users/auth/parent/login') {
      return handleLogin(path, data);
    }

    // Add child
    if (path == ApiEndpoints.addChild || path == '/api/users/children/add') {
      final code = data['code']?.toString() ?? '';
      final response = MockChildrenData.addChildResponse(code);
      _logResponse(path, response);
      return Response(requestOptions: RequestOptions(path: path), data: response, statusCode: 200);
    }

    // Report absence
    if (path.contains('/api/users/rides/excuse/')) {
      final parts = path.split('/');
      final occurrenceId = parts[parts.length - 2];
      final reason = data['reason']?.toString() ?? '';
      final response = MockRidesData.reportAbsence(occurrenceId, reason);
      _logResponse(path, response);
      return Response(requestOptions: RequestOptions(path: path), data: response, statusCode: 200);
    }

    // Create payment
    if (path == ApiEndpoints.parentPayments) {
      final response = MockPaymentsData.createPaymentResponse(data);
      _logResponse(path, response);
      return Response(requestOptions: RequestOptions(path: path), data: response, statusCode: 201);
    }

    // Create service payment
    if (path == ApiEndpoints.parentPaymentsOrgService) {
      final response = MockPaymentsData.createServicePaymentResponse(data);
      _logResponse(path, response);
      return Response(requestOptions: RequestOptions(path: path), data: response, statusCode: 201);
    }

    // Change password
    if (path == ApiEndpoints.changePassword) {
      final currentPassword = data['currentPassword']?.toString() ?? '';
      // Simulate password validation
      if (currentPassword.length >= 4) {
        _logResponse(path, MockProfileData.changePasswordSuccessResponse);
        return Response(
          requestOptions: RequestOptions(path: path),
          data: MockProfileData.changePasswordSuccessResponse,
          statusCode: 200,
        );
      } else {
        _logResponse(path, MockProfileData.changePasswordErrorResponse);
        return Response(
          requestOptions: RequestOptions(path: path),
          data: MockProfileData.changePasswordErrorResponse,
          statusCode: 400,
        );
      }
    }

    // Default response for unhandled endpoints
    dev.log('MOCK: Unhandled POST endpoint: $path', name: 'MockApiService');
    return Response(
      requestOptions: RequestOptions(path: path),
      data: {'success': false, 'message': 'Endpoint not implemented in mock'},
      statusCode: 404,
    );
  }

  /// Handle PUT requests
  static Future<Response> handlePut(String path, dynamic data) async {
    _logRequest('PUT', path, data: data);
    await _simulateDelay();

    // Update profile
    if (path == ApiEndpoints.profile) {
      final response = MockProfileData.updateProfileResponse(data);
      _logResponse(path, response);
      return Response(requestOptions: RequestOptions(path: path), data: response, statusCode: 200);
    }

    // Default response
    dev.log('MOCK: Unhandled PUT endpoint: $path', name: 'MockApiService');
    return Response(
      requestOptions: RequestOptions(path: path),
      data: {'success': false, 'message': 'Endpoint not implemented in mock'},
      statusCode: 404,
    );
  }

  /// Handle DELETE requests
  static Future<Response> handleDelete(String path) async {
    _logRequest('DELETE', path);
    await _simulateDelay();

    // Default response for unhandled endpoints
    dev.log('MOCK: Unhandled DELETE endpoint: $path', name: 'MockApiService');
    return Response(
      requestOptions: RequestOptions(path: path),
      data: {'success': true, 'message': 'Deleted successfully'},
      statusCode: 200,
    );
  }
}
