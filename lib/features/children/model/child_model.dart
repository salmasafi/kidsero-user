class ChildResponse {
  final bool success;
  final List<Child> data;

  ChildResponse({required this.success, required this.data});

  factory ChildResponse.fromJson(Map<String, dynamic> json) {
    List<Child> children = [];
    
    try {
      // Case 1: data is directly a list (simple response)
      if (json['data'] is List) {
        children = (json['data'] as List).map((i) => Child.fromJson(i as Map<String, dynamic>)).toList();
      } 
      // Case 2: data is an object with nested structure
      else if (json['data'] is Map) {
        final dataMap = json['data'] as Map<String, dynamic>;
        
        // Check for 'children' field
        if (dataMap['children'] is List) {
          children = (dataMap['children'] as List).map((i) => Child.fromJson(i as Map<String, dynamic>)).toList();
        }
        // Check if data map itself contains child objects
        else if (dataMap.containsKey('id') && dataMap.containsKey('name')) {
          children = [Child.fromJson(dataMap)];
        }
      }
    } catch (e) {
      print('Error parsing children response: $e');
      print('Response data: ${json['data']}');
    }
    
    return ChildResponse(
      success: json['success'] ?? false,
      data: children,
    );
  }
}

class AddChildResponse {
  final bool success;
  final String message;
  final Child? data;

  AddChildResponse({required this.success, required this.message, this.data});

  factory AddChildResponse.fromJson(Map<String, dynamic> json) {
    return AddChildResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? Child.fromJson(json['data']) : null,
    );
  }
}

class Child {
  final String id;
  final String name;
  final String code;
  final String? grade;
  final String? classroom;
  final String? schoolName;
  final String? photoUrl;
  final String status;
  final String? createdAt;
  final String? updatedAt;
  final Organization? organization;

  Child({
    required this.id,
    required this.name,
    required this.code,
    this.grade,
    this.classroom,
    this.schoolName,
    this.photoUrl,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.organization,
  });

  /// Get display grade - returns grade or empty string if not available
  String get displayGrade => grade ?? '';
  
  /// Get display classroom - returns classroom or empty string if not available
  String get displayClassroom => classroom ?? '';
  
  /// Get display school name - returns organization name or schoolName or empty string
  String get displaySchoolName => 
      organization?.name ?? schoolName ?? '';
  
  /// Check if child has complete grade and classroom info
  bool get hasCompleteInfo => 
      (grade != null && grade!.isNotEmpty) || 
      (classroom != null && classroom!.isNotEmpty);

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      grade: json['grade']?.toString(),
      classroom: json['classroom']?.toString(),
      schoolName: json['schoolName']?.toString(),
      photoUrl: json['avatar']?.toString() ?? json['photoUrl']?.toString(),
      status: json['status']?.toString() ?? 'active',
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      organization: json['organization'] != null 
          ? Organization.fromJson(json['organization']) 
          : null,
    );
  }
}

class Organization {
  final String id;
  final String name;
  final String? logo;

  Organization({
    required this.id,
    required this.name,
    this.logo,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      logo: json['logo']?.toString(),
    );
  }
}
