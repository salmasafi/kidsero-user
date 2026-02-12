import 'package:equatable/equatable.dart';
import '../../data/models/payment_model.dart';

/// Base state for create plan payment operations
abstract class CreatePlanPaymentState extends Equatable {
  const CreatePlanPaymentState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any payment creation attempt
class CreatePlanPaymentInitial extends CreatePlanPaymentState {
  const CreatePlanPaymentInitial();
}

/// Loading state while payment creation is in progress
class CreatePlanPaymentLoading extends CreatePlanPaymentState {
  const CreatePlanPaymentLoading();
}

/// Success state after payment is created successfully
class CreatePlanPaymentSuccess extends CreatePlanPaymentState {
  final PaymentModel payment;

  const CreatePlanPaymentSuccess(this.payment);

  @override
  List<Object?> get props => [payment];
}

/// Error state when payment creation fails
class CreatePlanPaymentError extends CreatePlanPaymentState {
  final String message;

  const CreatePlanPaymentError(this.message);

  @override
  List<Object?> get props => [message];
}
