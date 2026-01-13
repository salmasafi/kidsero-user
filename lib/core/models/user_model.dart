class UserModel {
  final String id;
  final String name;
  final String phone;
  final String? avatar;
  final String? address;
  final String? role;
  final String? status;
  final List<dynamic>? children;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.avatar,
    this.address,
    this.role,
    this.status,
    this.children,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      avatar: json['avatar'],
      address: json['address'],
      role: json['role'],
      status: json['status'],
      children: json['children'] != null ? List<dynamic>.from(json['children']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'avatar': avatar,
      'address': address,
      'role': role,
      'status': status,
      'children': children,
    };
  }
}
