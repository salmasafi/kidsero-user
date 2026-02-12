import 'dart:convert';
import 'dart:developer' as dev;
import '../models/ride_models.dart';
import 'rides_service.dart';
import '../../../core/network/cache_helper.dart';

/// Repository for rides feature that wraps the service layer
/// and provides business logic abstraction with caching
class RidesRepository {
  final RidesService _ridesService;

  // Cache keys
  static const String _todayRidesCacheKey = 'rides_today';
  static const String _activeRidesCacheKey = 'rides_active';
  static const String _upcomingRidesCacheKey = 'rides_upcoming';
  static const String _childrenWithRidesCacheKey = 'children_with_rides';
  static const String _childRidesCachePrefix = 'child_rides_';
  static const String _childSummaryCachePrefix = 'child_summary_';
  
  // Cache timestamp keys
  static const String _todayRidesCacheTimeKey = 'rides_today_time';
  static const String _activeRidesCacheTimeKey = 'rides_active_time';
  static const String _upcomingRidesCacheTimeKey = 'rides_upcoming_time';
  static const String _childrenWithRidesCacheTimeKey = 'children_with_rides_time';
  static const String _childRidesCacheTimePrefix = 'child_rides_time_';
  static const String _childSummaryCacheTimePrefix = 'child_summary_time_';
  
  // Cache TTL (time-to-live) in seconds
  static const int _todayRidesCacheTTL = 300; // 5 minutes
  static const int _activeRidesCacheTTL = 30; // 30 seconds (frequently changing)
  static const int _upcomingRidesCacheTTL = 600; // 10 minutes
  static const int _childrenWithRidesCacheTTL = 300; // 5 minutes
  static const int _childRidesCacheTTL = 600; // 10 minutes
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
    await _clearCache(_todayRidesCacheKey, _todayRidesCacheTimeKey);
    await _clearCache(_activeRidesCacheKey, _activeRidesCacheTimeKey);
    await _clearCache(_upcomingRidesCacheKey, _upcomingRidesCacheTimeKey);
    await _clearCache(_childrenWithRidesCacheKey, _childrenWithRidesCacheTimeKey);
    dev.log('Cleared all rides cache', name: 'RidesRepository');
  }


  /// Get all children with their ride information
  Future<List<ChildWithRides>> getChildrenWithRides({bool forceRefresh = false}) async {
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
      final jsonData = jsonEncode({
        'success': response.success,
        'data': response.data.map((child) => {
          'id': child.id,
          'name': child.name,
          'grade': child.grade,
          'schoolName': child.schoolName,
          'photoUrl': child.photoUrl,
          'rides': {
            'todayCount': child.rides.todayCount,
            'upcomingCount': child.rides.upcomingCount,
            'active': child.rides.active != null ? {
              'rideId': child.rides.active!.rideId,
              'childId': child.rides.active!.childId,
              'childName': child.rides.active!.childName,
              'status': child.rides.active!.status,
              'startedAt': child.rides.active!.startedAt,
              'estimatedArrival': child.rides.active!.estimatedArrival,
            } : null,
            'lastRideAt': child.rides.lastRideAt,
          }
        }).toList(),
      });
      await _saveToCache(_childrenWithRidesCacheKey, _childrenWithRidesCacheTimeKey, jsonData);
      return response.data;
    }
    throw Exception('Failed to fetch children with rides');
  }

  /// Get today's rides for all children
  Future<TodayRidesResponse> getTodayRides({bool forceRefresh = false}) async {
    // Check cache first if not forcing refresh
    if (!forceRefresh && _isCacheValid(_todayRidesCacheTimeKey, _todayRidesCacheTTL)) {
      final cachedData = _getFromCache(_todayRidesCacheKey);
      if (cachedData != null) {
        try {
          final jsonData = jsonDecode(cachedData) as Map<String, dynamic>;
          final response = TodayRidesResponse.fromJson(jsonData);
          dev.log('Returning cached today rides', name: 'RidesRepository');
          return response;
        } catch (e) {
          dev.log('Error parsing cached data: $e', name: 'RidesRepository');
          // Continue to fetch from API if cache parsing fails
        }
      }
    }

    // Fetch from API
    final response = await _ridesService.getTodayRides();
    if (response.success) {
      // Cache the response - store the raw JSON
      final jsonData = jsonEncode({
        'success': response.success,
        'date': response.date,
        'data': response.data.map((ride) => {
          'childId': ride.childId,
          'childName': ride.childName,
          'period': ride.period,
          'rideId': ride.rideId,
          'pickupTime': ride.pickupTime,
          'dropoffTime': ride.dropoffTime,
          'status': ride.status,
          'bus': ride.bus != null ? {
            'id': ride.bus!.id,
            'plateNumber': ride.bus!.plateNumber,
            'capacity': ride.bus!.capacity,
          } : null,
          'driver': ride.driver != null ? {
            'id': ride.driver!.id,
            'name': ride.driver!.name,
            'phone': ride.driver!.phone,
            'avatar': ride.driver!.avatar,
          } : null,
        }).toList(),
      });
      await _saveToCache(_todayRidesCacheKey, _todayRidesCacheTimeKey, jsonData);
      return response;
    }
    throw Exception('Failed to fetch today rides');
  }

  /// Get active (in-progress) rides
  Future<List<ActiveRide>> getActiveRides({bool forceRefresh = false}) async {
    // Always force refresh for debugging - remove this later
    forceRefresh = true;
    
    // Check cache first if not forcing refresh
    if (!forceRefresh && _isCacheValid(_activeRidesCacheTimeKey, _activeRidesCacheTTL)) {
      final cachedData = _getFromCache(_activeRidesCacheKey);
      if (cachedData != null) {
        try {
          final jsonData = jsonDecode(cachedData) as Map<String, dynamic>;
          final response = ActiveRidesResponse.fromJson(jsonData);
          dev.log('Returning cached active rides: ${response.data.length}', name: 'RidesRepository');
          return response.data;
        } catch (e) {
          dev.log('Error parsing cached data: $e', name: 'RidesRepository');
          // Continue to fetch from API if cache parsing fails
        }
      }
    }

    // Fetch from API
    dev.log('Fetching active rides from API', name: 'RidesRepository');
    final response = await _ridesService.getActiveRides();
    dev.log('API response success: ${response.success}, data length: ${response.data.length}', name: 'RidesRepository');
    
    if (response.success) {
      // Cache the response
      final jsonData = jsonEncode({
        'success': response.success,
        'data': response.data.map((ride) => {
          'rideId': ride.rideId,
          'childId': ride.childId,
          'childName': ride.childName,
          'status': ride.status,
          'startedAt': ride.startedAt,
          'estimatedArrival': ride.estimatedArrival,
          'bus': ride.bus != null ? {
            'id': ride.bus!.id,
            'plateNumber': ride.bus!.plateNumber,
            'capacity': ride.bus!.capacity,
          } : null,
          'driver': ride.driver != null ? {
            'id': ride.driver!.id,
            'name': ride.driver!.name,
            'phone': ride.driver!.phone,
            'avatar': ride.driver!.avatar,
          } : null,
          'lastLocation': ride.lastLocation != null ? {
            'lat': ride.lastLocation!.lat,
            'lng': ride.lastLocation!.lng,
            'recordedAt': ride.lastLocation!.recordedAt,
          } : null,
        }).toList(),
      });
      await _saveToCache(_activeRidesCacheKey, _activeRidesCacheTimeKey, jsonData);
      return response.data;
    }
    throw Exception('Failed to fetch active rides');
  }

  /// Get upcoming scheduled rides
  Future<List<UpcomingRide>> getUpcomingRides({bool forceRefresh = false}) async {
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
          // Continue to fetch from API if cache parsing fails
        }
      }
    }

    // Fetch from API
    final response = await _ridesService.getUpcomingRides();
    if (response.success) {
      // Cache the response
      final jsonData = jsonEncode({
        'success': response.success,
        'data': response.data.map((ride) => {
          'rideId': ride.rideId,
          'childId': ride.childId,
          'childName': ride.childName,
          'date': ride.date,
          'period': ride.period,
          'pickupTime': ride.pickupTime,
          'pickupLocation': ride.pickupLocation,
          'dropoffLocation': ride.dropoffLocation,
          'status': ride.status,
        }).toList(),
      });
      await _saveToCache(_upcomingRidesCacheKey, _upcomingRidesCacheTimeKey, jsonData);
      return response.data;
    }
    throw Exception('Failed to fetch upcoming rides');
  }

  /// Get ride details for a specific child
  Future<ChildRideDetails> getChildRides(String childId, {bool forceRefresh = false}) async {
    final cacheKey = '$_childRidesCachePrefix$childId';
    final cacheTimeKey = '$_childRidesCacheTimePrefix$childId';

    // Check cache first if not forcing refresh
    if (!forceRefresh && _isCacheValid(cacheTimeKey, _childRidesCacheTTL)) {
      final cachedData = _getFromCache(cacheKey);
      if (cachedData != null) {
        try {
          final jsonData = jsonDecode(cachedData) as Map<String, dynamic>;
          final response = SingleChildRidesResponse.fromJson(jsonData);
          dev.log('Returning cached child rides for $childId', name: 'RidesRepository');
          return response.data;
        } catch (e) {
          dev.log('Error parsing cached data: $e', name: 'RidesRepository');
          // Continue to fetch from API if cache parsing fails
        }
      }
    }

    // Fetch from API
    final response = await _ridesService.getChildRides(childId);
    if (response.success) {
      // Cache the response
      final jsonData = jsonEncode({
        'success': response.success,
        'data': {
          'id': response.data.id,
          'name': response.data.name,
          'grade': response.data.grade,
          'schoolName': response.data.schoolName,
          'rides': {
            'upcoming': response.data.rides.upcoming.map((ride) => {
              'rideId': ride.rideId,
              'date': ride.date,
              'period': ride.period,
              'status': ride.status,
              'pickedUpAt': ride.pickedUpAt,
              'droppedOffAt': ride.droppedOffAt,
            }).toList(),
            'history': response.data.rides.history.map((ride) => {
              'rideId': ride.rideId,
              'date': ride.date,
              'period': ride.period,
              'status': ride.status,
              'pickedUpAt': ride.pickedUpAt,
              'droppedOffAt': ride.droppedOffAt,
            }).toList(),
          }
        }
      });
      await _saveToCache(cacheKey, cacheTimeKey, jsonData);
      return response.data;
    }
    throw Exception('Failed to fetch child rides');
  }

  /// Get ride summary statistics for a specific child
  Future<RideSummary> getChildRideSummary(String childId, {bool forceRefresh = false}) async {
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
          // Continue to fetch from API if cache parsing fails
        }
      }
    }

    // Fetch from API
    final response = await _ridesService.getChildRideSummary(childId);
    if (response.success) {
      // Cache the response
      final jsonData = jsonEncode({
        'success': response.success,
        'data': {
          'childId': response.data.childId,
          'childName': response.data.childName,
          'period': {
            'from': response.data.period.from,
            'to': response.data.period.to,
          },
          'stats': {
            'totalScheduled': response.data.stats.totalScheduled,
            'attended': response.data.stats.attended,
            'absent': response.data.stats.absent,
            'late': response.data.stats.late,
          },
          'lastAbsences': response.data.lastAbsences.map((absence) => {
            'date': absence.date,
            'period': absence.period,
            'reason': absence.reason,
          }).toList(),
        }
      });
      await _saveToCache(cacheKey, cacheTimeKey, jsonData);
      return response.data;
    }
    throw Exception('Failed to fetch child ride summary');
  }

  /// Get real-time tracking data for a ride
  /// Note: Tracking data is not cached as it's real-time information
  Future<RideTracking> getRideTracking(String rideId) async {
    final response = await _ridesService.getRideTracking(rideId);
    if (response.success) {
      return response.data;
    }
    throw Exception('Failed to fetch ride tracking');
  }

  /// Report absence for a specific ride occurrence
  /// Note: This is a write operation, so it clears relevant caches
  Future<AbsenceData> reportAbsence({
    required String occurrenceId,
    required String studentId,
    required String reason,
  }) async {
    final response = await _ridesService.reportAbsence(
      occurrenceId: occurrenceId,
      studentId: studentId,
      reason: reason,
    );
    if (response.success && response.data != null) {
      // Clear caches that might be affected by this absence report
      await _clearCache(_todayRidesCacheKey, _todayRidesCacheTimeKey);
      await _clearCache(_upcomingRidesCacheKey, _upcomingRidesCacheTimeKey);
      await _clearCache('$_childRidesCachePrefix$studentId', '$_childRidesCacheTimePrefix$studentId');
      await _clearCache('$_childSummaryCachePrefix$studentId', '$_childSummaryCacheTimePrefix$studentId');
      
      return response.data!;
    }
    throw Exception(
      response.message.isNotEmpty
          ? response.message
          : 'Failed to report absence',
    );
  }
}
