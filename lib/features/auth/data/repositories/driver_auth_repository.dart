import 'package:kidsero_driver/core/network/driver_api_helper.dart';
import 'package:kidsero_driver/core/network/api_endpoints.dart';
import '../models/driver_login_response_model.dart';

class DriverAuthRepository {
  final DriverApiHelper _apiHelper;

  DriverAuthRepository(this._apiHelper);

  Future<DriverLoginResponseModel> driverLogin(String phone, String password) async {
    try {
      final response = await _apiHelper.post(
        ApiEndpoints.driverLogin,
        data: {
          'phone': phone,
          'password': password,
        },
      );
      return DriverLoginResponseModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
