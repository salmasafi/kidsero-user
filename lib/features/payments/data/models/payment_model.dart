import 'payment_status.dart';

/// Model representing a plan subscription payment
class PaymentModel {
  final String id;
  final String parentId;
  final double amount;
  final String? receiptImage; // base64 encoded
  final PaymentStatus status;
  final String? rejectedReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? planId;
  final String? notes;
  final String? paymentMethodId;

  PaymentModel({
    required this.id,
    required this.parentId,
    required this.amount,
    this.receiptImage,
    required this.status,
    this.rejectedReason,
    required this.createdAt,
    required this.updatedAt,
    this.planId,
    this.notes,
    this.paymentMethodId,
  });

  /// Create PaymentModel from JSON
  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      parentId: json['parentId'] as String,
      amount: (json['amount'] as num).toDouble(),
      receiptImage: json['receiptImage'] as String?,
      status: PaymentStatus.fromString(json['status'] as String),
      rejectedReason: json['rejectedReason'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      planId: json['planId'] as String?,
      notes: json['notes'] as String?,
      paymentMethodId: json['paymentMethodId'] as String?,
    );
  }

  /// Convert PaymentModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parentId': parentId,
      'amount': amount,
      'receiptImage': receiptImage,
      'status': status.toJson(),
      'rejectedReason': rejectedReason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'planId': planId,
      'notes': notes,
      'paymentMethodId': paymentMethodId,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PaymentModel &&
        other.id == id &&
        other.parentId == parentId &&
        other.amount == amount &&
        other.receiptImage == receiptImage &&
        other.status == status &&
        other.rejectedReason == rejectedReason &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.planId == planId &&
        other.notes == notes &&
        other.paymentMethodId == paymentMethodId;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      parentId,
      amount,
      receiptImage,
      status,
      rejectedReason,
      createdAt,
      updatedAt,
      planId,
      notes,
      paymentMethodId,
    );
  }
}
