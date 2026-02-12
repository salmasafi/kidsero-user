import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/payment_repository.dart';
import 'create_plan_payment_state.dart';

/// Cubit for managing plan payment creation state
/// 
/// Handles the creation of plan subscription payments with validation
/// and proper state transitions. Emits appropriate states during the
/// payment creation lifecycle.
class CreatePlanPaymentCubit extends Cubit<CreatePlanPaymentState> {
  final PaymentRepository _repository;

  CreatePlanPaymentCubit(this._repository)
      : super(const CreatePlanPaymentInitial());

  /// Create a plan subscription payment
  /// 
  /// Validates required fields before submission and emits appropriate states:
  /// - [CreatePlanPaymentLoading] before the API call
  /// - [CreatePlanPaymentSuccess] on success with the created payment
  /// - [CreatePlanPaymentError] on validation failure or API error
  /// 
  /// Parameters:
  /// - [planId]: ID of the plan to subscribe to (required)
  /// - [paymentMethodId]: ID of the payment method to use (required)
  /// - [amount]: Payment amount (required, must be positive)
  /// - [receiptImageBase64]: Base64-encoded receipt image (required)
  /// - [notes]: Optional notes for the payment
  /// 
  /// Throws validation errors if required fields are missing or invalid.
  Future<void> createPayment({
    required String planId,
    required String paymentMethodId,
    required double amount,
    required String receiptImageBase64,
    String? notes,
  }) async {
    try {
      // Validate required fields
      final validationError = _validateFields(
        planId: planId,
        paymentMethodId: paymentMethodId,
        amount: amount,
        receiptImageBase64: receiptImageBase64,
      );

      if (validationError != null) {
        emit(CreatePlanPaymentError(validationError));
        return;
      }

      // Emit loading state before API call
      emit(const CreatePlanPaymentLoading());

      // Create payment through repository
      final payment = await _repository.createPlanPayment(
        planId: planId,
        paymentMethodId: paymentMethodId,
        amount: amount,
        receiptImage: receiptImageBase64,
        notes: notes,
      );

      // Emit success state with created payment
      emit(CreatePlanPaymentSuccess(payment));
    } catch (e) {
      // Emit error state on failure
      emit(CreatePlanPaymentError(e.toString()));
    }
  }

  /// Validate required fields for plan payment creation
  /// 
  /// Returns an error message if validation fails, null if all fields are valid.
  String? _validateFields({
    required String planId,
    required String paymentMethodId,
    required double amount,
    required String receiptImageBase64,
  }) {
    if (planId.trim().isEmpty) {
      return 'Plan ID is required';
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

    return null;
  }

  /// Reset the cubit to initial state
  /// 
  /// Useful for clearing the state after successful payment creation
  /// or when navigating away from the payment creation screen.
  void reset() {
    emit(const CreatePlanPaymentInitial());
  }
}
