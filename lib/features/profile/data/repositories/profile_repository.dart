import '../../../../core/network/api_helper.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/models/profile_response_model.dart';
import '../../../../core/models/common_response_model.dart';

class ProfileRepository {
  final ApiHelper _apiHelper;

  ProfileRepository(this._apiHelper);

  Future<ProfileResponseModel> getProfile() async {
    try {
      final response = await _apiHelper.get(ApiEndpoints.profileMe);
      return ProfileResponseModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<CommonResponseModel> updateProfile(String name, String avatar) async {
    try {
      final response = await _apiHelper.put(
        ApiEndpoints.profileMe,
        data: {
          'name': name,
          'avatar': avatar,
        },
      );
      return CommonResponseModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<CommonResponseModel> changePassword(String oldPassword, String newPassword) async {
    try {
      final response = await _apiHelper.post(
        ApiEndpoints.changePassword,
        data: {
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        },
      );
      return CommonResponseModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
