import 'package:equatable/equatable.dart';
import '../../data/models/payment_model.dart';
import '../../data/models/service_payment_model.dart';

/// Base class for payment detail states
abstract class PaymentDetailState extends Equatable {
  const PaymentDetailState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any payment is loaded
class PaymentDetailInitial extends PaymentDetailState {
  const PaymentDetailInitial();
}

/// Loading state while fetching payment details
class PaymentDetailLoading extends PaymentDetailState {
  const PaymentDetailLoading();
}

/// Loaded state with payment data
/// 
/// The [payment] can be either a [PaymentModel] (plan payment)
/// or a [ServicePaymentModel] (service payment).
class PaymentDetailLoaded extends PaymentDetailState {
  final dynamic payment;

  const PaymentDetailLoaded(this.payment);

  @override
  List<Object?> get props => [payment];
}

/// Error state when payment loading fails
class PaymentDetailError extends PaymentDetailState {
  final String message;

  const PaymentDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
