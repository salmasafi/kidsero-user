import 'dart:developer' as dev;
import 'package:dio/dio.dart';
import '../models/api_models.dart';

/// Service class for handling all rides-related API calls
class RidesService {
  final Dio dio;

  RidesService({required this.dio});

  /// GET /api/users/rides/children
  /// Get all children for the logged-in parent, with ride info.
  Future<ChildrenWithRidesResponse> getChildrenWithRides() async {
    try {
      dev.log('GET /api/users/rides/children', name: 'RidesService');
      final response = await dio.get('/api/users/rides/children');
      dev.log('Response: ${response.statusCode}', name: 'RidesService');
      return ChildrenWithRidesResponse.fromJson(response.data);
    } catch (e) {
      dev.log('Error getting children with rides: $e', name: 'RidesService');
      rethrow;
    }
  }

  /// GET /api/users/rides/child/{childId}
  /// Get today's rides for a specific child
  Future<ChildTodayRidesResponse> getChildTodayRides(String childId) async {
    try {
      dev.log('GET /api/users/rides/child/$childId', name: 'RidesService');
      final response = await dio.get('/api/users/rides/child/$childId');
      dev.log('Response status: ${response.statusCode}', name: 'RidesService');
      dev.log('Response data: ${response.data}', name: 'RidesService');
      final parsedResponse = ChildTodayRidesResponse.fromJson(response.data);
      dev.log('Parsed child today rides: ${parsedResponse.data.total} rides', name: 'RidesService');
      return parsedResponse;
    } catch (e) {
      dev.log('Error getting child today rides: $e', name: 'RidesService');
      rethrow;
    }
  }

  /// GET /api/users/rides/active
  /// Get currently in-progress rides.
  Future<ActiveRidesResponse> getActiveRides() async {
    try {
      dev.log('GET /api/users/rides/active', name: 'RidesService');
      final response = await dio.get('/api/users/rides/active');
      dev.log('Response status: ${response.statusCode}', name: 'RidesService');
      dev.log('Response data: ${response.data}', name: 'RidesService');
      
      final result = ActiveRidesResponse.fromJson(response.data);
      dev.log('Parsed ${result.data.count} active rides', name: 'RidesService');
      
      return result;
    } catch (e) {
      dev.log('Error getting active rides: $e', name: 'RidesService');
      rethrow;
    }
  }

  /// GET /api/users/rides/upcoming
  /// Get next scheduled rides (future) grouped by date.
  Future<UpcomingRidesResponse> getUpcomingRides() async {
    try {
      dev.log('GET /api/users/rides/upcoming', name: 'RidesService');
      final response = await dio.get('/api/users/rides/upcoming');
      dev.log('Response status: ${response.statusCode}', name: 'RidesService');
      dev.log('Response data: ${response.data}', name: 'RidesService');
      
      final parsedResponse = UpcomingRidesResponse.fromJson(response.data);
      dev.log('Parsed upcoming rides: ${parsedResponse.data.totalDays} days, ${parsedResponse.data.totalRides} rides', name: 'RidesService');
      return parsedResponse;
    } catch (e) {
      dev.log('Error getting upcoming rides: $e', name: 'RidesService');
      rethrow;
    }
  }

  /// GET /api/users/rides/child/{childId}/summary
  /// Get attendance/usage summary for a child.
  Future<RideSummaryResponse> getChildRideSummary(String childId) async {
    try {
      dev.log(
        'GET /api/users/rides/child/$childId/summary',
        name: 'RidesService',
      );
      final response = await dio.get('/api/users/rides/child/$childId/summary');
      dev.log('Response: ${response.statusCode}', name: 'RidesService');
      return RideSummaryResponse.fromJson(response.data);
    } catch (e) {
      dev.log('Error getting child ride summary: $e', name: 'RidesService');
      rethrow;
    }
  }

  /// GET /api/users/rides/tracking/{childId}
  /// Get real-time tracking for a specific child's ride.
  Future<RideTrackingResponse> getRideTrackingByChild(String childId) async {
    try {
      dev.log('GET /api/users/rides/tracking/$childId', name: 'RidesService');
      final response = await dio.get('/api/users/rides/tracking/$childId');
      dev.log('Response: ${response.statusCode}', name: 'RidesService');
      return RideTrackingResponse.fromJson(response.data);
    } catch (e) {
      dev.log('Error getting ride tracking: $e', name: 'RidesService');
      rethrow;
    }
  }

  /// POST /api/users/rides/excuse/:occurrenceId/:studentId
  /// Report absence for a specific ride occurrence.
  Future<ReportAbsenceResponse> reportAbsence({
    required String occurrenceId,
    required String studentId,
    required String reason,
  }) async {
    try {
      dev.log(
        'POST /api/users/rides/excuse/$occurrenceId/$studentId',
        name: 'RidesService',
      );
      final response = await dio.post(
        '/api/users/rides/excuse/$occurrenceId/$studentId',
        data: ReportAbsenceRequest(reason: reason).toJson(),
      );
      dev.log('Response: ${response.statusCode}', name: 'RidesService');
      return ReportAbsenceResponse.fromJson(response.data);
    } catch (e) {
      dev.log('Error reporting absence: $e', name: 'RidesService');
      rethrow;
    }
  }
}
