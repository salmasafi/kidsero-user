import 'package:kidsero_parent/features/payments/data/models/payment_model.dart';
import 'package:kidsero_parent/features/payments/data/models/payment_status.dart';
import 'package:kidsero_parent/features/payments/data/models/service_payment_model.dart';
import 'package:kidsero_parent/features/payments/data/models/payment_type.dart';
import 'package:kidsero_parent/features/plans/model/payment_method_model.dart';

import 'mock_children_data.dart';
import '../mock_config.dart';

/// Mock payments data for testing
class MockPaymentsData {
  static String _generateId(String prefix, int index) =>
      'mock-${prefix}-${index.toString().padLeft(3, '0')}';

  static final _now = DateTime.now();

  /// Mock payment methods
  static List<PaymentMethod> get paymentMethods => [
        PaymentMethod(
          id: _generateId('pm', 1),
          name: 'Cash',
          description: 'Pay with cash at the school office',
          logo: '/images/payments/cash.png',
          isActive: true,
          feeStatus: false,
          feeAmount: 0,
          createdAt: '2024-01-01T00:00:00Z',
          updatedAt: '2024-01-01T00:00:00Z',
        ),
        PaymentMethod(
          id: _generateId('pm', 2),
          name: 'Bank Transfer',
          description: 'Direct bank transfer to school account',
          logo: '/images/payments/bank.png',
          isActive: true,
          feeStatus: false,
          feeAmount: 0,
          createdAt: '2024-01-01T00:00:00Z',
          updatedAt: '2024-01-01T00:00:00Z',
        ),
        PaymentMethod(
          id: _generateId('pm', 3),
          name: 'Credit Card',
          description: 'Pay with Visa or Mastercard',
          logo: '/images/payments/card.png',
          isActive: true,
          feeStatus: true,
          feeAmount: 2.5,
          createdAt: '2024-01-01T00:00:00Z',
          updatedAt: '2024-01-01T00:00:00Z',
        ),
        PaymentMethod(
          id: _generateId('pm', 4),
          name: 'Vodafone Cash',
          description: 'Pay using Vodafone Cash wallet',
          logo: '/images/payments/vodafone.png',
          isActive: true,
          feeStatus: true,
          feeAmount: 1.5,
          createdAt: '2024-01-01T00:00:00Z',
          updatedAt: '2024-01-01T00:00:00Z',
        ),
      ];

  /// Mock payment methods response
  static Map<String, dynamic> get paymentMethodsResponse => {
        'success': true,
        'data': {
          'paymentMethods': paymentMethods.map((pm) => pm.toJson()).toList(),
        },
      };

  /// Mock plan subscription payments
  static List<PaymentModel> get planPayments => [
        PaymentModel(
          id: _generateId('pay', 1),
          parentId: MockConfig.mockParentId,
          amount: 1500.0,
          receiptImage: null,
          status: PaymentStatus.completed,
          rejectedReason: null,
          createdAt: _now.subtract(const Duration(days: 30)),
          updatedAt: _now.subtract(const Duration(days: 28)),
          planId: _generateId('plan', 1),
          notes: 'Monthly subscription - January',
          paymentMethodId: _generateId('pm', 2),
        ),
        PaymentModel(
          id: _generateId('pay', 2),
          parentId: MockConfig.mockParentId,
          amount: 1500.0,
          receiptImage: null,
          status: PaymentStatus.completed,
          rejectedReason: null,
          createdAt: _now.subtract(const Duration(days: 60)),
          updatedAt: _now.subtract(const Duration(days: 58)),
          planId: _generateId('plan', 1),
          notes: 'Monthly subscription - December',
          paymentMethodId: _generateId('pm', 2),
        ),
        PaymentModel(
          id: _generateId('pay', 3),
          parentId: MockConfig.mockParentId,
          amount: 1500.0,
          receiptImage: 'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQ==',
          status: PaymentStatus.pending,
          rejectedReason: null,
          createdAt: _now.subtract(const Duration(days: 2)),
          updatedAt: _now.subtract(const Duration(days: 2)),
          planId: _generateId('plan', 1),
          notes: 'Monthly subscription - February',
          paymentMethodId: _generateId('pm', 1),
        ),
        PaymentModel(
          id: _generateId('pay', 4),
          parentId: MockConfig.mockParentId,
          amount: 800.0,
          receiptImage: null,
          status: PaymentStatus.rejected,
          rejectedReason: 'Insufficient amount paid',
          createdAt: _now.subtract(const Duration(days: 45)),
          updatedAt: _now.subtract(const Duration(days: 43)),
          planId: _generateId('plan', 2),
          notes: 'Partial payment attempt',
          paymentMethodId: _generateId('pm', 3),
        ),
      ];

  /// Mock service payments
  static List<ServicePaymentModel> get servicePayments {
    final children = MockChildrenData.children;
    
    return [
      ServicePaymentModel(
        id: _generateId('spay', 1),
        parentId: MockConfig.mockParentId,
        serviceId: _generateId('service', 1),
        studentId: children[0].id,
        amount: 500.0,
        receiptImage: null,
        status: PaymentStatus.completed,
        rejectedReason: null,
        paymentType: PaymentType.onetime,
        requestedInstallments: null,
        createdAt: _now.subtract(const Duration(days: 15)),
        updatedAt: _now.subtract(const Duration(days: 13)),
        paymentMethodId: _generateId('pm', 2),
        student: Student(
          id: children[0].id,
          name: children[0].name,
        ),
        service: ServiceWithDetails(
          id: _generateId('service', 1),
          name: 'School Trip - Museum Visit',
          useZonePrice: false,
          servicePrice: 500.0,
          studentZoneCost: 0.0,
          finalPrice: 500.0,
        ),
        paymentMethod: paymentMethods[1],
      ),
      ServicePaymentModel(
        id: _generateId('spay', 2),
        parentId: MockConfig.mockParentId,
        serviceId: _generateId('service', 2),
        studentId: children[1].id,
        amount: 1200.0,
        receiptImage: null,
        status: PaymentStatus.completed,
        rejectedReason: null,
        paymentType: PaymentType.installment,
        requestedInstallments: 3,
        createdAt: _now.subtract(const Duration(days: 45)),
        updatedAt: _now.subtract(const Duration(days: 43)),
        paymentMethodId: _generateId('pm', 4),
        student: Student(
          id: children[1].id,
          name: children[1].name,
        ),
        service: ServiceWithDetails(
          id: _generateId('service', 2),
          name: 'After School Activities - Spring Semester',
          useZonePrice: false,
          servicePrice: 1200.0,
          studentZoneCost: 0.0,
          finalPrice: 1200.0,
        ),
        paymentMethod: paymentMethods[3],
      ),
      ServicePaymentModel(
        id: _generateId('spay', 3),
        parentId: MockConfig.mockParentId,
        serviceId: _generateId('service', 3),
        studentId: children[2].id,
        amount: 350.0,
        receiptImage: 'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQ==',
        status: PaymentStatus.pending,
        rejectedReason: null,
        paymentType: PaymentType.onetime,
        requestedInstallments: null,
        createdAt: _now.subtract(const Duration(days: 1)),
        updatedAt: _now.subtract(const Duration(days: 1)),
        paymentMethodId: _generateId('pm', 1),
        student: Student(
          id: children[2].id,
          name: children[2].name,
        ),
        service: ServiceWithDetails(
          id: _generateId('service', 3),
          name: 'Science Lab Materials',
          useZonePrice: false,
          servicePrice: 350.0,
          studentZoneCost: 0.0,
          finalPrice: 350.0,
        ),
        paymentMethod: paymentMethods[0],
      ),
      ServicePaymentModel(
        id: _generateId('spay', 4),
        parentId: MockConfig.mockParentId,
        serviceId: _generateId('service', 4),
        studentId: children[3].id,
        amount: 250.0,
        receiptImage: null,
        status: PaymentStatus.rejected,
        rejectedReason: 'Receipt unclear - please resubmit',
        paymentType: PaymentType.onetime,
        requestedInstallments: null,
        createdAt: _now.subtract(const Duration(days: 10)),
        updatedAt: _now.subtract(const Duration(days: 8)),
        paymentMethodId: _generateId('pm', 1),
        student: Student(
          id: children[3].id,
          name: children[3].name,
        ),
        service: ServiceWithDetails(
          id: _generateId('service', 4),
          name: 'Art Supplies',
          useZonePrice: false,
          servicePrice: 250.0,
          studentZoneCost: 0.0,
          finalPrice: 250.0,
        ),
        paymentMethod: paymentMethods[0],
      ),
    ];
  }

  /// Mock payment history response
  static Map<String, dynamic> get paymentHistoryResponse => {
        'success': true,
        'data': {
          'message': 'Payments retrieved successfully',
          'payments': planPayments.map((p) => p.toJson()).toList(),
          'orgServicePayments': servicePayments.map((p) => p.toJson()).toList(),
        },
      };

  /// Mock create payment response
  static Map<String, dynamic> createPaymentResponse(Map<String, dynamic> request) => {
        'success': true,
        'data': {
          'message': 'Payment created successfully',
          'payment': {
            'id': _generateId('pay', DateTime.now().millisecondsSinceEpoch % 1000),
            'parentId': MockConfig.mockParentId,
            'planId': request['planId'],
            'amount': request['amount'],
            'receiptImage': request['receiptImage'],
            'status': 'pending',
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
          },
        },
      };

  /// Mock create service payment response
  static Map<String, dynamic> createServicePaymentResponse(Map<String, dynamic> request) => {
        'success': true,
        'data': {
          'message': 'Service payment created successfully',
          'payment': {
            'id': _generateId('spay', DateTime.now().millisecondsSinceEpoch % 1000),
            'parentId': MockConfig.mockParentId,
            'serviceId': request['ServiceId'],
            'studentId': request['studentId'],
            'amount': request['amount'],
            'receiptImage': request['receiptImage'],
            'status': 'pending',
            'paymentType': 'onetime',
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
          },
        },
      };

  /// Mock payment by ID response
  static Map<String, dynamic> getPaymentById(String id) {
    // Try to find in plan payments first
    PaymentModel? planPayment;
    try {
      planPayment = planPayments.firstWhere((p) => p.id == id);
    } catch (e) {
      planPayment = null;
    }

    if (planPayment != null) {
      return {
        'success': true,
        'data': {
          'message': 'Payment retrieved successfully',
          'payment': planPayment.toJson(),
        },
      };
    }

    // Try service payments
    ServicePaymentModel? servicePayment;
    try {
      servicePayment = servicePayments.firstWhere((p) => p.id == id);
    } catch (e) {
      servicePayment = null;
    }

    if (servicePayment != null) {
      return {
        'success': true,
        'data': {
          'message': 'Payment retrieved successfully',
          'payment': servicePayment.toJson(),
        },
      };
    }

    // Return first plan payment as default
    return {
      'success': true,
      'data': {
        'message': 'Payment retrieved successfully',
        'payment': planPayments.first.toJson(),
      },
    };
  }
}
