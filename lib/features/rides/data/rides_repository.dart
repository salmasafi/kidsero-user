import 'dart:convert';
import 'dart:developer' as dev;
import 'package:kidsero_parent/core/network/cache_helper.dart';
import '../models/api_models.dart';
import 'rides_service.dart';

/// Repository for rides feature that wraps the service layer
/// and provides business logic abstraction with caching
class RidesRepository {
  final RidesService _ridesService;

  // Cache keys
  static const String _childrenWithRidesCacheKey = 'children_with_rides';
  static const String _childTodayRidesCachePrefix = 'child_today_rides_';
  static const String _activeRidesCacheKey = 'active_rides';
  static const String _upcomingRidesCacheKey = 'upcoming_rides';
  static const String _childSummaryCachePrefix = 'child_summary_';
  
  // Cache timestamp keys
  static const String _childrenWithRidesCacheTimeKey = 'children_with_rides_time';
  static const String _childTodayRidesCacheTimePrefix = 'child_today_rides_time_';
  static const String _activeRidesCacheTimeKey = 'active_rides_time';
  static const String _upcomingRidesCacheTimeKey = 'upcoming_rides_time';
  static const String _childSummaryCacheTimePrefix = 'child_summary_time_';
  
  // Cache TTL (time-to-live) in seconds
  static const int _childrenWithRidesCacheTTL = 300; // 5 minutes
  static const int _childTodayRidesCacheTTL = 300; // 5 minutes
  static const int _activeRidesCacheTTL = 30; // 30 seconds (very frequent)
  static const int _upcomingRidesCacheTTL = 600; // 10 minutes
  static const int _childSummaryCacheTTL = 1800; // 30 minutes (rarely changes)

  RidesRepository({required RidesService ridesService})
    : _ridesService = ridesService;

  /// Check if cached data is still valid based on TTL
  bool _isCacheValid(String timeKey, int ttlSeconds) {
    final cachedTime = CacheHelper.getData(key: timeKey);
    if (cachedTime == null) return false;
    
    final cacheTimestamp = int.tryParse(cachedTime.toString());
    if (cacheTimestamp == null) return false;
    
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return (now - cacheTimestamp) < ttlSeconds;
  }

  /// Save data to cache with timestamp
  Future<void> _saveToCache(String dataKey, String timeKey, String jsonData) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await CacheHelper.saveData(key: dataKey, value: jsonData);
    await CacheHelper.saveData(key: timeKey, value: timestamp);
    dev.log('Cached data for key: $dataKey', name: 'RidesRepository');
  }

  /// Get data from cache
  String? _getFromCache(String dataKey) {
    final cachedData = CacheHelper.getData(key: dataKey);
    return cachedData?.toString();
  }

  /// Clear specific cache entry
  Future<void> _clearCache(String dataKey, String timeKey) async {
    await CacheHelper.removeData(key: dataKey);
    await CacheHelper.removeData(key: timeKey);
    dev.log('Cleared cache for key: $dataKey', name: 'RidesRepository');
  }

  /// Clear all rides-related cache
  Future<void> clearAllCache() async {
    await _clearCache(_childrenWithRidesCacheKey, _childrenWithRidesCacheTimeKey);
    await _clearCache(_activeRidesCacheKey, _activeRidesCacheTimeKey);
    await _clearCache(_upcomingRidesCacheKey, _upcomingRidesCacheTimeKey);
    dev.log('Cleared all rides cache', name: 'RidesRepository');
  }

  /// Get all children with their complete ride information
  Future<ChildrenWithRidesData> getChildrenWithRides({bool forceRefresh = false}) async {
    // Check cache first if not forcing refresh
    if (!forceRefresh && _isCacheValid(_childrenWithRidesCacheTimeKey, _childrenWithRidesCacheTTL)) {
      final cachedData = _getFromCache(_childrenWithRidesCacheKey);
      if (cachedData != null) {
        try {
          final jsonData = jsonDecode(cachedData) as Map<String, dynamic>;
          final response = ChildrenWithRidesResponse.fromJson(jsonData);
          dev.log('Returning cached children with rides', name: 'RidesRepository');
          return response.data;
        } catch (e) {
          dev.log('Error parsing cached data: $e', name: 'RidesRepository');
          // Continue to fetch from API if cache parsing fails
        }
      }
    }

    // Fetch from API
    final response = await _ridesService.getChildrenWithRides();
    if (response.success) {
      // Cache the response
      final jsonData = jsonEncode(response.toJson());
      await _saveToCache(_childrenWithRidesCacheKey, _childrenWithRidesCacheTimeKey, jsonData);
      return response.data;
    }
    throw Exception('Failed to fetch children with rides');
  }

  /// Get single child's today's rides
  Future<ChildTodayRidesData> getChildTodayRides(String childId, {bool forceRefresh = false}) async {
    final cacheKey = '$_childTodayRidesCachePrefix$childId';
    final cacheTimeKey = '$_childTodayRidesCacheTimePrefix$childId';

    // Check cache first if not forcing refresh
    if (!forceRefresh && _isCacheValid(cacheTimeKey, _childTodayRidesCacheTTL)) {
      final cachedData = _getFromCache(cacheKey);
      if (cachedData != null) {
        try {
          final jsonData = jsonDecode(cachedData) as Map<String, dynamic>;
          final response = ChildTodayRidesResponse.fromJson(jsonData);
          dev.log('Returning cached child today rides for $childId', name: 'RidesRepository');
          return response.data;
        } catch (e) {
          dev.log('Error parsing cached data: $e', name: 'RidesRepository');
        }
      }
    }

    try {
      dev.log('Fetching child today rides for $childId from API', name: 'RidesRepository');
      final response = await _ridesService.getChildTodayRides(childId);
      
      // Cache the response
      final jsonData = jsonEncode(response.toJson());
      await _saveToCache(cacheKey, cacheTimeKey, jsonData);
      
      dev.log('Successfully fetched and cached child today rides for $childId', name: 'RidesRepository');
      return response.data;
    } catch (e) {
      dev.log('Error fetching child today rides: $e', name: 'RidesRepository');
      rethrow;
    }
  }

  /// Get active (in-progress) rides
  Future<ActiveRidesData> getActiveRides({bool forceRefresh = false}) async {
    // Check cache first if not forcing refresh
    if (!forceRefresh && _isCacheValid(_activeRidesCacheTimeKey, _activeRidesCacheTTL)) {
      final cachedData = _getFromCache(_activeRidesCacheKey);
      if (cachedData != null) {
        try {
          final jsonData = jsonDecode(cachedData) as Map<String, dynamic>;
          final response = ActiveRidesResponse.fromJson(jsonData);
          dev.log('Returning cached active rides: ${response.data.count}', name: 'RidesRepository');
          return response.data;
        } catch (e) {
          dev.log('Error parsing cached data: $e', name: 'RidesRepository');
        }
      }
    }

    // Fetch from API
    dev.log('Fetching active rides from API', name: 'RidesRepository');
    final response = await _ridesService.getActiveRides();
    dev.log('API response success: ${response.success}, count: ${response.data.count}', name: 'RidesRepository');
    
    if (response.success) {
      // Cache the response
      final jsonData = jsonEncode(response.toJson());
      await _saveToCache(_activeRidesCacheKey, _activeRidesCacheTimeKey, jsonData);
      return response.data;
    }
    throw Exception('Failed to fetch active rides');
  }

  /// Get upcoming scheduled rides (grouped by date)
  Future<UpcomingRidesData> getUpcomingRides({bool forceRefresh = false}) async {
    // Check cache first if not forcing refresh
    if (!forceRefresh && _isCacheValid(_upcomingRidesCacheTimeKey, _upcomingRidesCacheTTL)) {
      final cachedData = _getFromCache(_upcomingRidesCacheKey);
      if (cachedData != null) {
        try {
          final jsonData = jsonDecode(cachedData) as Map<String, dynamic>;
          final response = UpcomingRidesResponse.fromJson(jsonData);
          dev.log('Returning cached upcoming rides', name: 'RidesRepository');
          return response.data;
        } catch (e) {
          dev.log('Error parsing cached data: $e', name: 'RidesRepository');
        }
      }
    }

    // Fetch from API
    dev.log('Fetching upcoming rides from API', name: 'RidesRepository');
    final response = await _ridesService.getUpcomingRides();
    dev.log('API response success: ${response.success}', name: 'RidesRepository');
    if (response.success) {
      // Cache the response
      final jsonData = jsonEncode(response.toJson());
      await _saveToCache(_upcomingRidesCacheKey, _upcomingRidesCacheTimeKey, jsonData);
      dev.log('Returning upcoming rides data: ${response.data.totalDays} days', name: 'RidesRepository');
      return response.data;
    }
    throw Exception('Failed to fetch upcoming rides');
  }

  /// Get ride summary statistics for a specific child
  Future<RideSummaryData> getChildRideSummary(String childId, {bool forceRefresh = false}) async {
    final cacheKey = '$_childSummaryCachePrefix$childId';
    final cacheTimeKey = '$_childSummaryCacheTimePrefix$childId';

    // Check cache first if not forcing refresh
    if (!forceRefresh && _isCacheValid(cacheTimeKey, _childSummaryCacheTTL)) {
      final cachedData = _getFromCache(cacheKey);
      if (cachedData != null) {
        try {
          final jsonData = jsonDecode(cachedData) as Map<String, dynamic>;
          final response = RideSummaryResponse.fromJson(jsonData);
          dev.log('Returning cached child summary for $childId', name: 'RidesRepository');
          return response.data;
        } catch (e) {
          dev.log('Error parsing cached data: $e', name: 'RidesRepository');
        }
      }
    }

    // Fetch from API
    final response = await _ridesService.getChildRideSummary(childId);
    if (response.success) {
      // Cache the response
      final jsonData = jsonEncode(response.toJson());
      await _saveToCache(cacheKey, cacheTimeKey, jsonData);
      return response.data;
    }
    throw Exception('Failed to fetch child ride summary');
  }

  /// Get real-time tracking data for a ride
  /// Note: Tracking data is NOT cached as it's real-time information
  Future<RideTrackingData?> getRideTracking(String childId) async {
    // Always fetch from API - no caching for real-time data
    try {
      final response = await _ridesService.getRideTrackingByChild(childId);
      if (response.success && response.data != null) {
        dev.log('Fetched ride tracking for $childId', name: 'RidesRepository');
        return response.data;
      } else {
        // No active ride tracking
        dev.log('No active ride tracking for $childId', name: 'RidesRepository');
        return null;
      }
    } catch (e) {
      dev.log('Error fetching ride tracking: $e', name: 'RidesRepository');
      return null;
    }
  }

  /// Report absence for a ride occurrence
  Future<ReportAbsenceResponse> reportAbsence({
    required String occurrenceId,
    required String studentId,
    required String reason,
  }) async {
    try {
      dev.log('Reporting absence for occurrence: $occurrenceId, student: $studentId', name: 'RidesRepository');
      final response = await _ridesService.reportAbsence(
        occurrenceId: occurrenceId,
        studentId: studentId,
        reason: reason,
      );
      
      if (response.success) {
        // Clear relevant caches after reporting absence
        await _clearCache('$_childTodayRidesCachePrefix$studentId', '$_childTodayRidesCacheTimePrefix$studentId');
        await _clearCache('$_childSummaryCachePrefix$studentId', '$_childSummaryCacheTimePrefix$studentId');
        await _clearCache(_upcomingRidesCacheKey, _upcomingRidesCacheTimeKey);
        await _clearCache(_childrenWithRidesCacheKey, _childrenWithRidesCacheTimeKey);
        dev.log('Absence reported successfully, cleared relevant caches', name: 'RidesRepository');
      }
      
      return response;
    } catch (e) {
      dev.log('Error reporting absence: $e', name: 'RidesRepository');
      rethrow;
    }
  }
}
