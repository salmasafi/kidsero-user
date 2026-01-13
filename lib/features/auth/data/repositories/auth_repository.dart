import 'package:kidsero_driver/core/network/api_helper.dart';
import 'package:kidsero_driver/core/network/api_endpoints.dart';
import '../models/auth_response_model.dart';

class AuthRepository {
  final ApiHelper _apiHelper;

  AuthRepository(this._apiHelper);

  Future<AuthResponseModel> parentLogin(String phone, String password) async {
    try {
      final response = await _apiHelper.post(
        ApiEndpoints.parentLogin,
        data: {
          'phone': phone,
          'password': password,
        },
      );
      return AuthResponseModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponseModel> driverLogin(String phone, String password) async {
    try {
      final response = await _apiHelper.post(
        ApiEndpoints.driverLogin,
        data: {
          'phone': phone,
          'password': password,
        },
      );
      return AuthResponseModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
