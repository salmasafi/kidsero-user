class PaymentMethod {
  final String id;
  final String name;
  final String description;
  final String logo;
  final bool isActive;
  final bool feeStatus;
  final num feeAmount;
  final String createdAt;
  final String updatedAt;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.description,
    required this.logo,
    required this.isActive,
    required this.feeStatus,
    required this.feeAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      logo: json['logo'] ?? '',
      isActive: json['isActive'] ?? false,
      feeStatus: json['feeStatus'] ?? false,
      feeAmount: json['feeAmount'] ?? 0,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logo': logo,
      'isActive': isActive,
      'feeStatus': feeStatus,
      'feeAmount': feeAmount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class PaymentMethodResponse {
  final bool success;
  final List<PaymentMethod> paymentMethods;

  PaymentMethodResponse({required this.success, required this.paymentMethods});

  factory PaymentMethodResponse.fromJson(Map<String, dynamic> json) {
    return PaymentMethodResponse(
      success: json['success'] ?? false,
      paymentMethods:
          (json['data']['paymentMethods'] as List?)
              ?.map((e) => PaymentMethod.fromJson(e))
              .toList() ??
          [],
    );
  }
}
