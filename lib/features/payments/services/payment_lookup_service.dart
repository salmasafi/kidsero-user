import 'package:kidsero_driver/features/plans/model/payment_method_model.dart';
import 'package:kidsero_driver/features/plans/model/plans_model.dart';

/// Service for caching and looking up payment methods and plans by ID
/// This service maintains in-memory caches of payment methods and plans
/// to avoid repeated API calls when displaying payment details
class PaymentLookupService {
  static final PaymentLookupService _instance = PaymentLookupService._internal();
  factory PaymentLookupService() => _instance;
  PaymentLookupService._internal();

  // In-memory caches
  List<PaymentMethod> _paymentMethods = [];
  List<PlanModel> _plans = [];

  /// Initialize the service with payment methods and plans data
  /// Call this when you load the payment methods and plans data
  void initialize({
    required List<PaymentMethod> paymentMethods,
    required List<PlanModel> plans,
  }) {
    _paymentMethods = paymentMethods;
    _plans = plans;
  }

  /// Get payment method name by ID
  /// Returns the payment method name if found, otherwise returns the ID
  String getPaymentMethodName(String paymentMethodId) {
    try {
      final paymentMethod = _paymentMethods.firstWhere(
        (method) => method.id == paymentMethodId,
      );
      return paymentMethod.name;
    } catch (e) {
      // If not found, return the ID as fallback
      return paymentMethodId;
    }
  }

  /// Get plan name by ID
  /// Returns the plan name if found, otherwise returns the ID
  String getPlanName(String planId) {
    try {
      final plan = _plans.firstWhere(
        (plan) => plan.id == planId,
      );
      return plan.name;
    } catch (e) {
      // If not found, return the ID as fallback
      return planId;
    }
  }

  /// Get payment method by ID
  /// Returns the full PaymentMethod object if found
  PaymentMethod? getPaymentMethod(String paymentMethodId) {
    try {
      return _paymentMethods.firstWhere(
        (method) => method.id == paymentMethodId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get plan by ID
  /// Returns the full PlanModel object if found
  PlanModel? getPlan(String planId) {
    try {
      return _plans.firstWhere(
        (plan) => plan.id == planId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if payment methods are loaded
  bool get arePaymentMethodsLoaded => _paymentMethods.isNotEmpty;

  /// Check if plans are loaded
  bool get arePlansLoaded => _plans.isNotEmpty;

  /// Clear all cached data
  void clear() {
    _paymentMethods.clear();
    _plans.clear();
  }
}
