import 'package:equatable/equatable.dart';
import '../model/payment_model.dart';
import '../model/payment_method_model.dart';

abstract class PaymentState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentsLoaded extends PaymentState {
  final List<PaymentModel> payments;
  final List<PaymentModel> orgServicePayments;

  PaymentsLoaded({required this.payments, required this.orgServicePayments});

  @override
  List<Object?> get props => [payments, orgServicePayments];
}

class PaymentDetailLoaded extends PaymentState {
  final PaymentModel payment;

  PaymentDetailLoaded(this.payment);

  @override
  List<Object?> get props => [payment];
}

class PaymentSuccess extends PaymentState {
  final String message;

  PaymentSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class PaymentError extends PaymentState {
  final String message;

  PaymentError(this.message);

  @override
  List<Object?> get props => [message];
}

class PaymentMethodsLoaded extends PaymentState {
  final List<PaymentMethod> paymentMethods;

  PaymentMethodsLoaded(this.paymentMethods);

  @override
  List<Object?> get props => [paymentMethods];
}
