import '../../../../core/network/api_service.dart';
import '../../../../core/network/error_handler.dart';
import '../models/payment_model.dart';
import '../models/payment_response_model.dart';
import '../models/service_payment_model.dart';
import '../models/payment_type.dart';

/// Repository for handling payment-related API operations
class PaymentRepository {
  final ApiService _apiService;

  PaymentRepository(this._apiService);

  /// Get all parent payments (both plan and service payments)
  /// 
  /// Returns a [PaymentResponseModel] containing lists of plan payments
  /// and organization service payments.
  /// 
  /// Throws an exception if the API call fails.
  Future<PaymentResponseModel> getAllPayments() async {
    try {
      print('[PaymentRepository] Fetching all payments from API');
      final response = await _apiService.dio.get('/api/users/parentpayments');
      
      print('[PaymentRepository] Response status: ${response.statusCode}');
      print('[PaymentRepository] Response data: ${response.data}');
      
      if (response.data['success'] == true && response.data['data'] != null) {
        final result = PaymentResponseModel.fromJson(response.data['data']);
        print('[PaymentRepository] Parsed ${result.payments.length} plan payments and ${result.orgServicePayments.length} service payments');
        return result;
      } else {
        print('[PaymentRepository] API response indicates failure');
        throw Exception('Failed to load payments: ${response.data}');
      }
    } catch (e) {
      print('[PaymentRepository] Error fetching payments: $e');
      throw Exception(ErrorHandler.handle(e));
    }
  }

  /// Get a specific plan payment by ID
  /// 
  /// Returns a [PaymentModel] for the requested payment.
  /// 
  /// Throws an exception if the payment is not found or the API call fails.
  Future<PaymentModel> getPaymentById(String id) async {
    try {
      final response = await _apiService.dio.get('/api/users/parentpayments/$id');
      
      if (response.data['success'] == true && response.data['data'] != null) {
        // The payment object is nested under response.data['data']['payment']
        final paymentData = response.data['data']['payment'];
        if (paymentData != null) {
          return PaymentModel.fromJson(paymentData);
        } else {
          throw Exception('Payment data not found in response');
        }
      } else {
        throw Exception('Payment not found');
      }
    } catch (e) {
      print('[PaymentRepository] Error in getPaymentById: $e');
      throw Exception(ErrorHandler.handle(e));
    }
  }

  /// Get a specific service payment by ID
  /// 
  /// Returns a [ServicePaymentModel] for the requested payment.
  /// 
  /// Throws an exception if the payment is not found or the API call fails.
  Future<ServicePaymentModel> getServicePaymentById(String id) async {
    try {
      final response = await _apiService.dio.get('/api/users/parentpayments/org-service/$id');
      
      if (response.data['success'] == true && response.data['data'] != null) {
        // The payment object is nested under response.data['data']['payment']
        final paymentData = response.data['data']['payment'];
        if (paymentData != null) {
          return ServicePaymentModel.fromJson(paymentData);
        } else {
          throw Exception('Service payment data not found in response');
        }
      } else {
        throw Exception('Service payment not found');
      }
    } catch (e) {
      print('[PaymentRepository] Error in getServicePaymentById: $e');
      throw Exception(ErrorHandler.handle(e));
    }
  }

  /// Create a plan subscription payment
  /// 
  /// Parameters:
  /// - [planId]: ID of the plan to subscribe to
  /// - [paymentMethodId]: ID of the payment method to use
  /// - [amount]: Payment amount
  /// - [receiptImage]: Base64-encoded receipt image
  /// - [notes]: Optional notes for the payment
  /// 
  /// Returns the created [PaymentModel].
  /// 
  /// Throws an exception if validation fails or the API call fails.
  Future<PaymentModel> createPlanPayment({
    required String planId,
    required String paymentMethodId,
    required double amount,
    required String receiptImage,
    String? notes,
  }) async {
    try {
      final requestData = {
        'planId': planId,
        'paymentMethodId': paymentMethodId,
        'amount': amount,
        'receiptImage': receiptImage,
        if (notes != null) 'notes': notes,
      };

      final response = await _apiService.dio.post(
        '/api/users/parentpayments',
        data: requestData,
      );
      
      if (response.data['success'] == true && response.data['data'] != null) {
        return PaymentModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to create payment');
      }
    } catch (e) {
      throw Exception(ErrorHandler.handle(e));
    }
  }

  /// Create an organization service payment
  /// 
  /// Parameters:
  /// - [serviceId]: ID of the service to pay for
  /// - [studentId]: ID of the student
  /// - [paymentMethodId]: ID of the payment method to use
  /// - [amount]: Payment amount
  /// - [receiptImage]: Base64-encoded receipt image
  /// - [paymentType]: Type of payment (onetime or installment)
  /// - [numberOfInstallments]: Number of installments (required if paymentType is installment)
  /// 
  /// Returns the created [ServicePaymentModel].
  /// 
  /// Throws an exception if validation fails or the API call fails.
  Future<ServicePaymentModel> createServicePayment({
    required String serviceId,
    required String studentId,
    required String paymentMethodId,
    required double amount,
    required String receiptImage,
    required PaymentType paymentType,
    int? numberOfInstallments,
  }) async {
    try {
      // Validate installment requirements
      if (paymentType == PaymentType.installment && numberOfInstallments == null) {
        throw Exception('Number of installments is required for installment payments');
      }

      final requestData = {
        'ServiceId': serviceId,
        'studentId': studentId,
        'paymentMethodId': paymentMethodId,
        'amount': amount,
        'receiptImage': receiptImage,
        'paymentType': paymentType.toJson(),
        if (numberOfInstallments != null) 'numberOfInstallments': numberOfInstallments,
      };

      final response = await _apiService.dio.post(
        '/api/users/parentpayments/org-service',
        data: requestData,
      );
      
      if (response.data['success'] == true && response.data['data'] != null) {
        return ServicePaymentModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to create service payment');
      }
    } catch (e) {
      throw Exception(ErrorHandler.handle(e));
    }
  }
}
