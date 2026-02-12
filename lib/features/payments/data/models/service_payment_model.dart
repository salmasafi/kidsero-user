import 'payment_status.dart';
import 'payment_type.dart';
import '../../../plans/model/payment_method_model.dart';

/// Model representing a student
class Student {
  final String id;
  final String name;

  Student({
    required this.id,
    required this.name,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

/// Model representing a service with pricing details
class ServiceWithDetails {
  final String id;
  final String name;
  final bool useZonePrice;
  final double servicePrice;
  final double studentZoneCost;
  final double finalPrice;

  ServiceWithDetails({
    required this.id,
    required this.name,
    required this.useZonePrice,
    required this.servicePrice,
    required this.studentZoneCost,
    required this.finalPrice,
  });

  factory ServiceWithDetails.fromJson(Map<String, dynamic> json) {
    return ServiceWithDetails(
      id: json['id'] as String,
      name: json['name'] as String,
      useZonePrice: json['useZonePrice'] as bool,
      servicePrice: (json['servicePrice'] as num).toDouble(),
      studentZoneCost: (json['studentZoneCost'] as num).toDouble(),
      finalPrice: (json['finalPrice'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'useZonePrice': useZonePrice,
      'servicePrice': servicePrice,
      'studentZoneCost': studentZoneCost,
      'finalPrice': finalPrice,
    };
  }
}

/// Model representing an organization service payment
class ServicePaymentModel {
  final String id;
  final String parentId;
  final String serviceId;
  final String studentId; // Made optional with default empty string
  final double amount;
  final String? receiptImage; // base64 encoded
  final PaymentStatus status;
  final String? rejectedReason;
  final PaymentType paymentType; // onetime or installment
  final int? requestedInstallments;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? paymentMethodId;
  
  // Nested objects from API response
  final Student? student;
  final ServiceWithDetails? service;
  final PaymentMethod? paymentMethod;

  ServicePaymentModel({
    required this.id,
    required this.parentId,
    required this.serviceId,
    required this.studentId,
    required this.amount,
    this.receiptImage,
    required this.status,
    this.rejectedReason,
    required this.paymentType,
    this.requestedInstallments,
    required this.createdAt,
    required this.updatedAt,
    this.paymentMethodId,
    this.student,
    this.service,
    this.paymentMethod,
  });

  /// Create ServicePaymentModel from JSON
  factory ServicePaymentModel.fromJson(Map<String, dynamic> json) {
    return ServicePaymentModel(
      id: json['id'] as String,
      parentId: json['parentId'] as String,
      serviceId: json['serviceId'] as String,
      studentId: json['studentId'] as String? ?? '',
      amount: (json['amount'] as num).toDouble(),
      receiptImage: json['receiptImage'] as String?,
      status: PaymentStatus.fromString(json['status'] as String? ?? 'pending'),
      rejectedReason: json['rejectedReason'] as String?,
      paymentType: json['paymentType'] != null 
          ? PaymentType.fromString(json['paymentType'] as String)
          : PaymentType.onetime, // Default to onetime if not provided
      requestedInstallments: json['requestedInstallments'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      paymentMethodId: json['paymentMethodId'] as String?,
      // Parse nested objects if available
      student: json['student'] != null ? Student.fromJson(json['student'] as Map<String, dynamic>) : null,
      service: json['service'] != null ? ServiceWithDetails.fromJson(json['service'] as Map<String, dynamic>) : null,
      paymentMethod: json['paymentMethod'] != null ? PaymentMethod.fromJson(json['paymentMethod'] as Map<String, dynamic>) : null,
    );
  }

  /// Convert ServicePaymentModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parentId': parentId,
      'serviceId': serviceId,
      'studentId': studentId,
      'amount': amount,
      'receiptImage': receiptImage,
      'status': status.toJson(),
      'rejectedReason': rejectedReason,
      'paymentType': paymentType.toJson(),
      'requestedInstallments': requestedInstallments,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'paymentMethodId': paymentMethodId,
      'student': student?.toJson(),
      'service': service?.toJson(),
      'paymentMethod': paymentMethod?.toJson(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ServicePaymentModel &&
        other.id == id &&
        other.parentId == parentId &&
        other.serviceId == serviceId &&
        other.studentId == studentId &&
        other.amount == amount &&
        other.receiptImage == receiptImage &&
        other.status == status &&
        other.rejectedReason == rejectedReason &&
        other.paymentType == paymentType &&
        other.requestedInstallments == requestedInstallments &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.paymentMethodId == paymentMethodId &&
        other.student == student &&
        other.service == service &&
        other.paymentMethod == paymentMethod;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      parentId,
      serviceId,
      studentId,
      amount,
      receiptImage,
      status,
      rejectedReason,
      paymentType,
      requestedInstallments,
      createdAt,
      updatedAt,
      paymentMethodId,
      student,
      service,
      paymentMethod,
    );
  }
}
