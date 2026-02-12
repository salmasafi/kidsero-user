import 'package:equatable/equatable.dart';
import '../../data/models/payment_model.dart';
import '../../data/models/service_payment_model.dart';

/// Base class for payment history states
abstract class PaymentHistoryState extends Equatable {
  const PaymentHistoryState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded
class PaymentHistoryInitial extends PaymentHistoryState {
  const PaymentHistoryInitial();
}

/// Loading state while fetching payment data
class PaymentHistoryLoading extends PaymentHistoryState {
  const PaymentHistoryLoading();
}

/// Loaded state with payment data
class PaymentHistoryLoaded extends PaymentHistoryState {
  final List<PaymentModel> planPayments;
  final List<ServicePaymentModel> servicePayments;

  const PaymentHistoryLoaded({
    required this.planPayments,
    required this.servicePayments,
  });

  @override
  List<Object?> get props => [planPayments, servicePayments];
}

/// Error state when payment loading fails
class PaymentHistoryError extends PaymentHistoryState {
  final String message;

  const PaymentHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
