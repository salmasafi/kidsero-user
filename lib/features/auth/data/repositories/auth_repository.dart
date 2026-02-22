import 'package:kidsero_parent/core/network/api_endpoints.dart';
import '../../../../core/network/api_helper.dart';
import '../models/auth_response_model.dart';

class AuthRepository {
  final ApiHelper _apiHelper;

  AuthRepository(this._apiHelper);

  Future<AuthResponseModel> login(String phone, String password) async {
    try {
      final response = await _apiHelper.post(
        ApiEndpoints.login,
        data: {'identifier': phone, 'password': password},
      );
      return AuthResponseModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
