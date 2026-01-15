import 'package:dio/dio.dart';
import 'package:kidsero_driver/core/network/parent_api_helper.dart';
import 'package:kidsero_driver/core/network/driver_api_helper.dart';
import 'package:kidsero_driver/core/network/api_endpoints.dart';
import 'package:kidsero_driver/core/utils/app_preferences.dart';
import '../../../../core/models/common_response_model.dart';
import '../models/profile_response_model.dart';
import '../models/children_response_model.dart';

class ProfileRepository {
  final ParentApiHelper _parentApiHelper;
  final DriverApiHelper _driverApiHelper;

  ProfileRepository(
    this._parentApiHelper,
    this._driverApiHelper,
  );

  Future<ProfileResponseModel> getProfile() async {
    try {
      final isParent = await AppPreferences.isParent();
      final response = isParent
          ? await _parentApiHelper.get(ApiEndpoints.profileMe)
          : await _driverApiHelper.get(ApiEndpoints.profileMe);
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

      final isParent = await AppPreferences.isParent();
      final response = isParent
          ? await _parentApiHelper.put(ApiEndpoints.profileMe, data: data)
          : await _driverApiHelper.put(ApiEndpoints.profileMe, data: data);
      return CommonResponseModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<CommonResponseModel> changePassword(String oldPassword, String newPassword) async {
    try {
      final isParent = await AppPreferences.isParent();
      final response = isParent
          ? await _parentApiHelper.post(
              ApiEndpoints.changePassword,
              data: {
                'oldPassword': oldPassword,
                'newPassword': newPassword,
              },
            )
          : await _driverApiHelper.post(
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
      final isParent = await AppPreferences.isParent();
      if (!isParent) {
        throw Exception('Children are only available for parent users');
      }
      final response = await _parentApiHelper.get(ApiEndpoints.children);
      return ChildrenResponseModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
