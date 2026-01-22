import 'package:kidsero_driver/core/network/parent_api_helper.dart';
import 'package:kidsero_driver/core/network/api_endpoints.dart';
import '../models/auth_response_model.dart';

class ParentAuthRepository {
  final ParentApiHelper _apiHelper;

  ParentAuthRepository(this._apiHelper);

  Future<AuthResponseModel> parentLogin(String phone, String password) async {
    try {
      final response = await _apiHelper.post(
        ApiEndpoints.parentLogin,
        data: {'identifier': phone, 'password': password},
      );
      return AuthResponseModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
