import 'package:kidsero_parent/features/plans/model/org_service_model.dart';
import 'package:kidsero_parent/features/plans/model/parent_subscription_model.dart';
import 'package:kidsero_parent/features/plans/model/payment_model.dart';
import 'package:kidsero_parent/features/plans/model/plans_model.dart';
import 'package:kidsero_parent/features/plans/model/student_subscription_model.dart';

import '../mock_config.dart';

/// Mock plans and subscriptions data for testing
class MockPlansData {
  static String _generateId(String prefix, int index) =>
      'mock-${prefix}-${index.toString().padLeft(3, '0')}';

  /// Mock parent subscription plans
  static List<PlanModel> get parentPlans => [
        PlanModel(
          id: _generateId('plan', 1),
          name: 'Standard Transportation',
          price: 1500,
          minSubscriptionFeesPay: 500,
          subscriptionFees: 1500,
        ),
        PlanModel(
          id: _generateId('plan', 2),
          name: 'Premium Transportation',
          price: 2500,
          minSubscriptionFeesPay: 1000,
          subscriptionFees: 2500,
        ),
        PlanModel(
          id: _generateId('plan', 3),
          name: 'Basic Morning Only',
          price: 800,
          minSubscriptionFeesPay: 400,
          subscriptionFees: 800,
        ),
      ];

  /// Mock plans response
  static Map<String, dynamic> get plansResponse => {
        'success': true,
        'data': {
          'parentPlans': parentPlans.map((p) => {
            'id': p.id,
            'name': p.name,
            'price': p.price,
            'minSubscriptionFeesPay': p.minSubscriptionFeesPay,
            'subscriptionFees': p.subscriptionFees,
          }).toList(),
        },
      };

  /// Mock organization services
  static List<OrgService> get orgServices => [
    OrgService(
      id: _generateId('service', 1),
      serviceName: 'School Trip - Museum Visit',
      serviceDescription: 'Educational trip to the National Museum including transportation and entry fees',
      baseServicePrice: 500,
      useZonePricing: false,
      studentZoneCost: 0,
      finalPrice: 500,
      supportsInstallments: false,
    ),
    OrgService(
      id: _generateId('service', 2),
      serviceName: 'After School Activities - Spring Semester',
      serviceDescription: 'Sports, arts, and STEM activities for the spring semester (3 months)',
      baseServicePrice: 1200,
      useZonePricing: false,
      studentZoneCost: 0,
      finalPrice: 1200,
      supportsInstallments: true,
    ),
    OrgService(
      id: _generateId('service', 3),
      serviceName: 'Science Lab Materials',
      serviceDescription: 'Materials and equipment for hands-on science experiments',
      baseServicePrice: 350,
      useZonePricing: false,
      studentZoneCost: 0,
      finalPrice: 350,
      supportsInstallments: false,
    ),
    OrgService(
      id: _generateId('service', 4),
      serviceName: 'Art Supplies Package',
      serviceDescription: 'Complete art supplies kit for the semester including paints, brushes, and canvas',
      baseServicePrice: 250,
      useZonePricing: false,
      studentZoneCost: 0,
      finalPrice: 250,
      supportsInstallments: false,
    ),
    OrgService(
      id: _generateId('service', 5),
      serviceName: 'Music Lessons - Group',
      serviceDescription: 'Weekly group music lessons with professional instructor',
      baseServicePrice: 800,
      useZonePricing: false,
      studentZoneCost: 0,
      finalPrice: 800,
      supportsInstallments: true,
    ),
    OrgService(
      id: _generateId('service', 6),
      serviceName: 'Swimming Classes',
      serviceDescription: 'Weekly swimming classes at affiliated sports center',
      baseServicePrice: 600,
      useZonePricing: true,
      studentZoneCost: 100,
      finalPrice: 700,
      supportsInstallments: true,
    ),
  ];

  /// Mock organization services response
  static Map<String, dynamic> orgServicesResponse(String studentId) => {
        'success': true,
        'data': {
          'message': 'Organization services retrieved successfully',
          'orgServices': orgServices.map((s) => {
            'id': s.id,
            'serviceName': s.serviceName,
            'serviceDescription': s.serviceDescription,
            'baseServicePrice': s.baseServicePrice,
            'useZonePricing': s.useZonePricing,
            'studentZoneCost': s.studentZoneCost,
            'finalPrice': s.finalPrice,
            'supportsInstallments': s.supportsInstallments,
          }).toList(),
        },
      };

  /// Mock parent subscriptions
  static List<ParentSubscription> get parentSubscriptions {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    return [
      ParentSubscription(
        id: _generateId('sub', 1),
        parentId: MockConfig.mockParentId,
        parentPlanId: parentPlans[0].id,
        parentPaymentId: _generateId('pay', 1),
        isActive: true,
        startDate: startOfMonth.toIso8601String(),
        endDate: endOfMonth.toIso8601String(),
        createdAt: startOfMonth.toIso8601String(),
        updatedAt: startOfMonth.toIso8601String(),
      ),
      ParentSubscription(
        id: _generateId('sub', 2),
        parentId: MockConfig.mockParentId,
        parentPlanId: parentPlans[0].id,
        parentPaymentId: _generateId('pay', 2),
        isActive: false,
        startDate: DateTime(now.year, now.month - 1, 1).toIso8601String(),
        endDate: DateTime(now.year, now.month, 0).toIso8601String(),
        createdAt: DateTime(now.year, now.month - 1, 1).toIso8601String(),
        updatedAt: DateTime(now.year, now.month - 1, 1).toIso8601String(),
      ),
    ];
  }

  /// Mock parent subscriptions response
  static Map<String, dynamic> get parentSubscriptionsResponse => {
        'success': true,
        'data': {
          'message': 'Parent subscriptions retrieved successfully',
          'parentSubscription': parentSubscriptions.map((s) => {
            'id': s.id,
            'parentId': s.parentId,
            'parentPlanId': s.parentPlanId,
            'parentPaymentId': s.parentPaymentId,
            'isActive': s.isActive,
            'startDate': s.startDate,
            'endDate': s.endDate,
            'createdAt': s.createdAt,
            'updatedAt': s.updatedAt,
          }).toList(),
        },
      };

  /// Mock student service subscriptions
  static List<StudentServiceSubscription> getStudentActiveServices(String studentId) {
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 20));
    final endDate = now.add(const Duration(days: 70));

    return [
      StudentServiceSubscription(
        id: _generateId('ssub', 1),
        parentId: MockConfig.mockParentId,
        studentId: studentId,
        serviceId: orgServices[0].id,
        parentServicePaymentId: _generateId('spay', 1),
        isActive: true,
        startDate: startDate.toIso8601String(),
        endDate: endDate.toIso8601String(),
        createdAt: startDate.toIso8601String(),
        updatedAt: startDate.toIso8601String(),
      ),
      StudentServiceSubscription(
        id: _generateId('ssub', 2),
        parentId: MockConfig.mockParentId,
        studentId: studentId,
        serviceId: orgServices[2].id,
        parentServicePaymentId: _generateId('spay', 3),
        isActive: true,
        startDate: now.subtract(const Duration(days: 5)).toIso8601String(),
        endDate: now.add(const Duration(days: 85)).toIso8601String(),
        createdAt: now.subtract(const Duration(days: 5)).toIso8601String(),
        updatedAt: now.subtract(const Duration(days: 5)).toIso8601String(),
      ),
    ];
  }

  /// Mock student active services response
  static Map<String, dynamic> studentActiveServicesResponse(String studentId) => {
        'success': true,
        'data': {
          'message': 'Student active services retrieved successfully',
          'currentSubscribedServicesForStudent': getStudentActiveServices(studentId).map((s) => {
            'id': s.id,
            'parentId': s.parentId,
            'studentId': s.studentId,
            'serviceId': s.serviceId,
            'parentServicePaymentId': s.parentServicePaymentId,
            'isActive': s.isActive,
            'startDate': s.startDate,
            'endDate': s.endDate,
            'createdAt': s.createdAt,
            'updatedAt': s.updatedAt,
          }).toList(),
        },
      };

  /// Mock payments for plans feature
  static List<PaymentModel> get planFeaturePayments => [
        PaymentModel(
          id: _generateId('pay', 1),
          parentId: MockConfig.mockParentId,
          planId: parentPlans[0].id,
          serviceId: null,
          studentId: null,
          studentName: null,
          status: 'completed',
          amount: 1500,
          receiptImage: null,
          createdAt: DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        ),
        PaymentModel(
          id: _generateId('pay', 2),
          parentId: MockConfig.mockParentId,
          planId: parentPlans[0].id,
          serviceId: null,
          studentId: null,
          studentName: null,
          status: 'completed',
          amount: 1500,
          receiptImage: null,
          createdAt: DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
        ),
        PaymentModel(
          id: _generateId('pay', 3),
          parentId: MockConfig.mockParentId,
          planId: parentPlans[0].id,
          serviceId: null,
          studentId: null,
          studentName: null,
          status: 'pending',
          amount: 1500,
          receiptImage: 'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQ==',
          createdAt: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        ),
      ];

  /// Mock payments response for plans feature
  static Map<String, dynamic> get paymentsResponse => {
        'success': true,
        'data': {
          'message': 'Payments retrieved successfully',
          'payments': planFeaturePayments.map((p) => p.toJson()).toList(),
          'orgServicePayments': [],
        },
      };
}
