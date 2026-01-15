import 'package:dio/dio.dart';
import 'package:kidsero_driver/core/network/api_helper.dart';
import 'package:kidsero_driver/core/network/api_endpoints.dart';
import '../../../../core/models/common_response_model.dart';
import '../models/profile_response_model.dart';
import '../models/children_response_model.dart';

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

  Future<CommonResponseModel> updateProfile({
    required String name,
    String? imagePath,
  }) async {
    try {
      dynamic data;
      
      if (imagePath != null) {
        data = FormData.fromMap({
          'name': name,
          'avatar': await MultipartFile.fromFile(imagePath),
        });
      } else {
        data = {
          'name': name,
        };
      }

      final response = await _apiHelper.put(
        ApiEndpoints.profileMe,
        data: data,
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

  Future<ChildrenResponseModel> getChildren() async {
    try {
      final response = await _apiHelper.get(ApiEndpoints.children);
      return ChildrenResponseModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
