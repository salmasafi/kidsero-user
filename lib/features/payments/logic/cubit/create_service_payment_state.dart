import 'package:equatable/equatable.dart';
import '../../data/models/service_payment_model.dart';

/// Base state for create service payment operations
abstract class CreateServicePaymentState extends Equatable {
  const CreateServicePaymentState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any payment creation attempt
class CreateServicePaymentInitial extends CreateServicePaymentState {
  const CreateServicePaymentInitial();
}

/// Loading state while payment creation is in progress
class CreateServicePaymentLoading extends CreateServicePaymentState {
  const CreateServicePaymentLoading();
}

/// Success state after payment is created successfully
class CreateServicePaymentSuccess extends CreateServicePaymentState {
  final ServicePaymentModel payment;

  const CreateServicePaymentSuccess(this.payment);

  @override
  List<Object?> get props => [payment];
}

/// Error state when payment creation fails
class CreateServicePaymentError extends CreateServicePaymentState {
  final String message;

  const CreateServicePaymentError(this.message);

  @override
  List<Object?> get props => [message];
}
