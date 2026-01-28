class PaymentModel {
  final String id;
  final String? parentId;
  final String? planId;
  final String? serviceId;
  final String? studentId;
  final String? studentName;
  final String status;
  final num amount;
  final String? receiptImage;
  final String createdAt;

  PaymentModel({
    required this.id,
    this.parentId,
    this.planId,
    this.serviceId,
    this.studentId,
    this.studentName,
    required this.status,
    required this.amount,
    this.receiptImage,
    required this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] ?? '',
      parentId: json['parentId'],
      planId: json['planId'],
      serviceId: json['serviceId'],
      studentId: json['studentId'],
      studentName: json['studentName'],
      status: json['status'] ?? '',
      amount: json['amount'] ?? 0,
      receiptImage: json['receiptImage'],
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parentId': parentId,
      'planId': planId,
      'serviceId': serviceId,
      'studentId': studentId,
      'studentName': studentName,
      'status': status,
      'amount': amount,
      'receiptImage': receiptImage,
      'createdAt': createdAt,
    };
  }
}

class PaymentResponse {
  final bool success;
  final PaymentData data;

  PaymentResponse({required this.success, required this.data});

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      success: json['success'] ?? false,
      data: PaymentData.fromJson(json['data'] ?? {}),
    );
  }
}

class PaymentData {
  final String message;
  final List<PaymentModel> payments;
  final List<PaymentModel> orgServicePayments;
  final PaymentModel? payment;

  PaymentData({
    required this.message,
    required this.payments,
    required this.orgServicePayments,
    this.payment,
  });

  factory PaymentData.fromJson(Map<String, dynamic> json) {
    return PaymentData(
      message: json['message'] ?? '',
      payments:
          (json['payments'] as List?)
              ?.map((e) => PaymentModel.fromJson(e))
              .toList() ??
          [],
      orgServicePayments:
          (json['orgServicePayments'] as List?)
              ?.map((e) => PaymentModel.fromJson(e))
              .toList() ??
          [],
      payment: json['payment'] != null
          ? PaymentModel.fromJson(json['payment'])
          : null,
    );
  }
}

class CreatePaymentRequest {
  final String planId;
  final String paymentMethodId;
  final num amount;
  final String receiptImage;

  CreatePaymentRequest({
    required this.planId,
    required this.paymentMethodId,
    required this.amount,
    required this.receiptImage,
  });

  Map<String, dynamic> toJson() {
    return {
      'planId': planId,
      'paymentMethodId': paymentMethodId,
      'amount': amount,
      'receiptImage': receiptImage,
    };
  }
}

class CreateServicePaymentRequest {
  final String serviceId;
  final String paymentMethodId;
  final num amount;
  final String receiptImage;
  final String studentId;

  CreateServicePaymentRequest({
    required this.serviceId,
    required this.paymentMethodId,
    required this.amount,
    required this.receiptImage,
    required this.studentId,
  });

  Map<String, dynamic> toJson() {
    return {
      'ServiceId': serviceId,
      'paymentMethodId': paymentMethodId,
      'amount': amount,
      'receiptImage': receiptImage,
      'studentId': studentId,
    };
  }
}
