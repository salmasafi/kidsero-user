import 'package:dio/dio.dart';
import 'package:kidsero_driver/core/network/driver_api_helper.dart';
import 'package:kidsero_driver/core/network/error_handler.dart';
import '../models/driver_rides_today_model.dart';
import '../models/start_ride_model.dart';

class DriverRidesRepository {
  final DriverApiHelper _apiHelper;

  DriverRidesRepository(this._apiHelper);

  Future<DriverRidesTodayResponse> getRidesToday() async {
    try {
      final response = await _apiHelper.get(
        '/api/users/driver/rides/today',
      );

      if (response.statusCode == 200) {
        return DriverRidesTodayResponse.fromJson(response.data);
      } else {
        throw Exception(ErrorHandler.handle(response));
      }
    } on DioException catch (e) {
      throw Exception(ErrorHandler.handle(e));
    } catch (e) {
      throw Exception(ErrorHandler.handle(e));
    }
  }

  Future<StartRideResponse> startRide({
    required String occurrenceId,
    required String lat,
    required String lng,
  }) async {
    try {
      final response = await _apiHelper.post(
        '/api/users/driver/rides/occurrence/$occurrenceId/start',
        data: {
          'lat': lat,
          'lng': lng,
        },
      );

      if (response.statusCode == 200) {
        return StartRideResponse.fromJson(response.data);
      } else {
        throw Exception(ErrorHandler.handle(response));
      }
    } on DioException catch (e) {
      throw Exception(ErrorHandler.handle(e));
    } catch (e) {
      throw Exception(ErrorHandler.handle(e));
    }
  }
}
