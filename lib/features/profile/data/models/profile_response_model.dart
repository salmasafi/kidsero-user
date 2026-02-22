import 'package:kidsero_parent/features/auth/data/models/user_model.dart';

class ProfileResponseModel {
  final bool success;
  final UserModel? profile;

  ProfileResponseModel({
    required this.success,
    this.profile,
  });

  factory ProfileResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return ProfileResponseModel(
      success: json['success'] ?? false,
      profile: data != null && data['profile'] != null ? UserModel.fromJson(data['profile']) : null,
    );
  }
}
