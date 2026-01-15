import 'package:equatable/equatable.dart';

class DriverLoginResponseModel extends Equatable {
  final bool success;
  final DriverLoginData data;

  const DriverLoginResponseModel({
    required this.success,
    required this.data,
  });

  factory DriverLoginResponseModel.fromJson(Map<String, dynamic> json) {
    return DriverLoginResponseModel(
      success: json['success'] ?? false,
      data: DriverLoginData.fromJson(json['data'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [success, data];
}

class DriverLoginData extends Equatable {
  final String message;
  final String token;
  final DriverUser user;

  const DriverLoginData({
    required this.message,
    required this.token,
    required this.user,
  });

  factory DriverLoginData.fromJson(Map<String, dynamic> json) {
    return DriverLoginData(
      message: json['message'] ?? '',
      token: json['token'] ?? '',
      user: DriverUser.fromJson(json['user'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [message, token, user];
}

class DriverUser extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String? avatar;
  final String role;

  const DriverUser({
    required this.id,
    required this.name,
    required this.phone,
    this.avatar,
    required this.role,
  });

  factory DriverUser.fromJson(Map<String, dynamic> json) {
    return DriverUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      avatar: json['avatar'],
      role: json['role'] ?? '',
    );
  }

  @override
  List<Object?> get props => [id, name, phone, avatar, role];
}
