import 'dart:developer' as dev;
import 'package:dio/dio.dart';
import '../models/ride_models.dart';

/// Service class for handling all rides-related API calls
class RidesService {
  final Dio dio;

  RidesService({required this.dio});

  /// GET /api/users/rides/children
  /// Get all children for the logged-in parent, with ride info.
  Future<ChildrenWithAllRidesResponse> getChildrenWithAllRides() async {
    try {
      dev.log('GET /api/users/rides/children', name: 'RidesService');
      final response = await dio.get('/api/users/rides/children');
      dev.log('Response: ${response.statusCode}', name: 'RidesService');
      return ChildrenWithAllRidesResponse.fromJson(response.data);
    } catch (e) {
      dev.log('Error getting children with all rides: $e', name: 'RidesService');
      rethrow;
    }
  }

  /// GET /api/users/rides/child/{childId}
  /// Get single child's today's rides with detailed information.
  Future<ChildTodayRidesResponse> getChildTodayRides(String childId) async {
    try {
      dev.log('GET /api/users/rides/child/$childId', name: 'RidesService');
      final response = await dio.get('/api/users/rides/child/$childId');
      dev.log('Response: ${response.statusCode}', name: 'RidesService');
      return ChildTodayRidesResponse.fromJson(response.data);
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
      dev.log('Parsed ${result.data.length} active rides', name: 'RidesService');
      
      return result;
    } catch (e) {
      dev.log('Error getting active rides: $e', name: 'RidesService');
      rethrow;
    }
  }

  /// GET /api/users/rides/upcoming
  /// Get next scheduled rides (future) grouped by date.
  Future<UpcomingRidesGroupedResponse> getUpcomingRides() async {
    try {
      dev.log('GET /api/users/rides/upcoming', name: 'RidesService');
      final response = await dio.get('/api/users/rides/upcoming');
      dev.log('Response status: ${response.statusCode}', name: 'RidesService');
      dev.log('Response data: ${response.data}', name: 'RidesService');
      
      final parsedResponse = UpcomingRidesGroupedResponse.fromJson(response.data);
      dev.log('Parsed upcoming rides: ${parsedResponse.data.upcomingRides.length} days', name: 'RidesService');
      return parsedResponse;
    } catch (e) {
      dev.log('Error getting upcoming rides: $e', name: 'RidesService');
      rethrow;
    }
  }

  /// GET /api/users/rides/child/{childId}/summary
  /// Get attendance/usage summary for a child.
  Future<NewRideSummaryResponse> getChildRideSummary(String childId) async {
    try {
      dev.log(
        'GET /api/users/rides/child/$childId/summary',
        name: 'RidesService',
      );
      final response = await dio.get('/api/users/rides/child/$childId/summary');
      dev.log('Response: ${response.statusCode}', name: 'RidesService');
      return NewRideSummaryResponse.fromJson(response.data);
    } catch (e) {
      dev.log('Error getting child ride summary: $e', name: 'RidesService');
      rethrow;
    }
  }

  /// GET /api/users/rides/tracking/{childId}
  /// Get real-time tracking for a specific child's ride.
  Future<NewRideTrackingResponse> getRideTrackingByChild(String childId) async {
    try {
      dev.log('GET /api/users/rides/tracking/$childId', name: 'RidesService');
      final response = await dio.get('/api/users/rides/tracking/$childId');
      dev.log('Response: ${response.statusCode}', name: 'RidesService');
      return NewRideTrackingResponse.fromJson(response.data);
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

  // Legacy methods for backward compatibility
  /// GET /api/users/rides/children/today (LEGACY)
  /// Get rides scheduled for today for all children of the parent.
  @deprecated
  Future<TodayRidesResponse> getTodayRides() async {
    try {
      dev.log('GET /api/users/rides/children/today (LEGACY)', name: 'RidesService');
      final response = await dio.get('/api/users/rides/children/today');
      dev.log('Response: ${response.statusCode}', name: 'RidesService');
      return TodayRidesResponse.fromJson(response.data);
    } catch (e) {
      dev.log('Error getting today rides: $e', name: 'RidesService');
      rethrow;
    }
  }

  /// GET /api/users/rides/child/:childId (LEGACY)
  /// Get details of one child, plus ride history.
  @deprecated
  Future<SingleChildRidesResponse> getChildRides(String childId) async {
    try {
      dev.log('GET /api/users/rides/child/$childId (LEGACY)', name: 'RidesService');
      final response = await dio.get('/api/users/rides/child/$childId');
      dev.log('Response status: ${response.statusCode}', name: 'RidesService');
      dev.log('Response data: ${response.data}', name: 'RidesService');
      final parsedResponse = SingleChildRidesResponse.fromJson(response.data);
      dev.log('Parsed child rides: ${parsedResponse.data.rides.upcoming.length} upcoming, ${parsedResponse.data.rides.history.length} history', name: 'RidesService');
      return parsedResponse;
    } catch (e) {
      dev.log('Error getting child rides: $e', name: 'RidesService');
      rethrow;
    }
  }

  /// GET /api/users/rides/tracking/:rideId (LEGACY)
  /// Get real-time tracking for one ride.
  @deprecated
  Future<RideTrackingResponse> getRideTracking(String rideId) async {
    try {
      dev.log('GET /api/users/rides/tracking/$rideId (LEGACY)', name: 'RidesService');
      final response = await dio.get('/api/users/rides/tracking/$rideId');
      dev.log('Response: ${response.statusCode}', name: 'RidesService');
      return RideTrackingResponse.fromJson(response.data);
    } catch (e) {
      dev.log('Error getting ride tracking: $e', name: 'RidesService');
      rethrow;
    }
  }
}
