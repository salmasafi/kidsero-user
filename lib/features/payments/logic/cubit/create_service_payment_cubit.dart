import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/payment_type.dart';
import '../../data/repositories/payment_repository.dart';
import 'create_service_payment_state.dart';

/// Cubit for managing service payment creation state
/// 
/// Handles the creation of organization service payments with validation
/// and proper state transitions. Supports both one-time and installment
/// payment types with conditional validation.
class CreateServicePaymentCubit extends Cubit<CreateServicePaymentState> {
  final PaymentRepository _repository;

  CreateServicePaymentCubit(this._repository)
      : super(const CreateServicePaymentInitial());

  /// Create an organization service payment
  /// 
  /// Validates required fields before submission and emits appropriate states:
  /// - [CreateServicePaymentLoading] before the API call
  /// - [CreateServicePaymentSuccess] on success with the created payment
  /// - [CreateServicePaymentError] on validation failure or API error
  /// 
  /// Parameters:
  /// - [serviceId]: ID of the service to pay for (required)
  /// - [studentId]: ID of the student (required)
  /// - [paymentMethodId]: ID of the payment method to use (required)
  /// - [amount]: Payment amount (required, must be positive)
  /// - [receiptImageBase64]: Base64-encoded receipt image (required)
  /// - [paymentType]: Type of payment - onetime or installment (required)
  /// - [numberOfInstallments]: Number of installments (required if paymentType is installment)
  /// 
  /// Throws validation errors if required fields are missing or invalid.
  Future<void> createPayment({
    required String serviceId,
    required String studentId,
    required String paymentMethodId,
    required double amount,
    required String receiptImageBase64,
    required PaymentType paymentType,
    int? numberOfInstallments,
  }) async {
    try {
      // Validate required fields
      final validationError = _validateFields(
        serviceId: serviceId,
        studentId: studentId,
        paymentMethodId: paymentMethodId,
        amount: amount,
        receiptImageBase64: receiptImageBase64,
        paymentType: paymentType,
        numberOfInstallments: numberOfInstallments,
      );

      if (validationError != null) {
        emit(CreateServicePaymentError(validationError));
        return;
      }

      // Emit loading state before API call
      emit(const CreateServicePaymentLoading());

      // Create payment through repository
      final payment = await _repository.createServicePayment(
        serviceId: serviceId,
        studentId: studentId,
        paymentMethodId: paymentMethodId,
        amount: amount,
        receiptImage: receiptImageBase64,
        paymentType: paymentType,
        numberOfInstallments: numberOfInstallments,
      );

      // Emit success state with created payment
      emit(CreateServicePaymentSuccess(payment));
    } catch (e) {
      // Emit error state on failure
      emit(CreateServicePaymentError(e.toString()));
    }
  }

  /// Validate required fields for service payment creation
  /// 
  /// Performs conditional validation based on payment type:
  /// - For installment payments: numberOfInstallments is required and must be positive
  /// - For onetime payments: numberOfInstallments is optional
  /// 
  /// Returns an error message if validation fails, null if all fields are valid.
  String? _validateFields({
    required String serviceId,
    required String studentId,
    required String paymentMethodId,
    required double amount,
    required String receiptImageBase64,
    required PaymentType paymentType,
    int? numberOfInstallments,
  }) {
    if (serviceId.trim().isEmpty) {
      return 'Service ID is required';
    }

    if (studentId.trim().isEmpty) {
      return 'Student ID is required';
    }

    if (paymentMethodId.trim().isEmpty) {
      return 'Payment method is required';
    }

    if (amount <= 0) {
      return 'Amount must be greater than zero';
    }

    if (receiptImageBase64.trim().isEmpty) {
      return 'Receipt image is required';
    }

    // Conditional validation for installment payments
    if (paymentType == PaymentType.installment) {
      if (numberOfInstallments == null) {
        return 'Number of installments is required for installment payments';
      }

      if (numberOfInstallments <= 0) {
        return 'Number of installments must be greater than zero';
      }
    }

    return null;
  }

  /// Reset the cubit to initial state
  /// 
  /// Useful for clearing the state after successful payment creation
  /// or when navigating away from the payment creation screen.
  void reset() {
    emit(const CreateServicePaymentInitial());
  }
}
