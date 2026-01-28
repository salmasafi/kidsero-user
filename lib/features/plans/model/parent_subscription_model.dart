class ParentSubscription {
  final String id;
  final String parentId;
  final String parentPlanId;
  final String parentPaymentId;
  final bool isActive;
  final String startDate;
  final String endDate;
  final String createdAt;
  final String updatedAt;

  ParentSubscription({
    required this.id,
    required this.parentId,
    required this.parentPlanId,
    required this.parentPaymentId,
    required this.isActive,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ParentSubscription.fromJson(Map<String, dynamic> json) {
    return ParentSubscription(
      id: json['id'] ?? '',
      parentId: json['parentId'] ?? '',
      parentPlanId: json['parentPlanId'] ?? '',
      parentPaymentId: json['parentPaymentId'] ?? '',
      isActive: json['isActive'] ?? false,
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class ParentSubscriptionResponse {
  final bool success;
  final String message;
  final List<ParentSubscription> subscriptions;

  ParentSubscriptionResponse({
    required this.success,
    required this.message,
    required this.subscriptions,
  });

  factory ParentSubscriptionResponse.fromJson(Map<String, dynamic> json) {
    return ParentSubscriptionResponse(
      success: json['success'] ?? false,
      message: json['data']['message'] ?? '',
      subscriptions:
          (json['data']['parentSubscription'] as List<dynamic>?)
              ?.map((e) => ParentSubscription.fromJson(e))
              .toList() ??
          [],
    );
  }
}
