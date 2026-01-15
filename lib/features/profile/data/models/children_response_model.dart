import 'package:equatable/equatable.dart';

class ChildrenResponseModel extends Equatable {
  final bool success;
  final ChildrenData data;

  const ChildrenResponseModel({
    required this.success,
    required this.data,
  });

  factory ChildrenResponseModel.fromJson(Map<String, dynamic> json) {
    return ChildrenResponseModel(
      success: json['success'] ?? false,
      data: ChildrenData.fromJson(json['data'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [success, data];
}

class ChildrenData extends Equatable {
  final List<ChildModel> children;

  const ChildrenData({
    required this.children,
  });

  factory ChildrenData.fromJson(Map<String, dynamic> json) {
    final childrenList = json['children'] as List? ?? [];
    return ChildrenData(
      children: childrenList
          .map((child) => ChildModel.fromJson(child as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [children];
}

class ChildModel extends Equatable {
  final String id;
  final String name;
  final String? avatar;
  final String grade;
  final String classroom;
  final String status;

  const ChildModel({
    required this.id,
    required this.name,
    this.avatar,
    required this.grade,
    required this.classroom,
    required this.status,
  });

  factory ChildModel.fromJson(Map<String, dynamic> json) {
    return ChildModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      avatar: json['avatar'],
      grade: json['grade'] ?? '',
      classroom: json['classroom'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'grade': grade,
      'classroom': classroom,
      'status': status,
    };
  }

  @override
  List<Object?> get props => [id, name, avatar, grade, classroom, status];
}
