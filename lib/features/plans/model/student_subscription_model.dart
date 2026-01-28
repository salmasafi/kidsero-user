class StudentServiceSubscription {
  final String id;
  final String parentId;
  final String studentId;
  final String serviceId;
  final String parentServicePaymentId;
  final bool isActive;
  final String startDate;
  final String endDate;
  final String createdAt;
  final String updatedAt;

  StudentServiceSubscription({
    required this.id,
    required this.parentId,
    required this.studentId,
    required this.serviceId,
    required this.parentServicePaymentId,
    required this.isActive,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StudentServiceSubscription.fromJson(Map<String, dynamic> json) {
    return StudentServiceSubscription(
      id: json['id'] ?? '',
      parentId: json['parentId'] ?? '',
      studentId: json['studentId'] ?? '',
      serviceId: json['serviceId'] ?? '',
      parentServicePaymentId: json['parentServicePaymentId'] ?? '',
      isActive: json['isActive'] ?? false,
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class StudentServiceResponse {
  final bool success;
  final String message;
  final List<StudentServiceSubscription> subscriptions;

  StudentServiceResponse({
    required this.success,
    required this.message,
    required this.subscriptions,
  });

  factory StudentServiceResponse.fromJson(Map<String, dynamic> json) {
    return StudentServiceResponse(
      success: json['success'] ?? false,
      message: json['data']['message'] ?? '',
      subscriptions:
          (json['data']['currentSubscribedServicesForStudent']
                  as List<dynamic>?)
              ?.map((e) => StudentServiceSubscription.fromJson(e))
              .toList() ??
          [],
    );
  }
}
