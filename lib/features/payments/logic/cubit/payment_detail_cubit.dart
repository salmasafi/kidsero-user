import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/payment_repository.dart';
import 'payment_detail_state.dart';

/// Cubit for managing payment detail state
/// 
/// Handles loading of individual payment details for both plan payments
/// and service payments. Emits appropriate states during the loading lifecycle.
class PaymentDetailCubit extends Cubit<PaymentDetailState> {
  final PaymentRepository _repository;

  PaymentDetailCubit(this._repository) : super(const PaymentDetailInitial());

  /// Load a plan payment by ID
  /// 
  /// Emits [PaymentDetailLoading] before the API call,
  /// [PaymentDetailLoaded] on success with the payment data,
  /// or [PaymentDetailError] on failure.
  /// 
  /// Parameters:
  /// - [id]: The ID of the plan payment to load
  Future<void> loadPlanPayment(String id) async {
    try {
      // Emit loading state before API call
      emit(const PaymentDetailLoading());

      // Fetch plan payment from repository
      final payment = await _repository.getPaymentById(id);

      // Emit success state with data
      emit(PaymentDetailLoaded(payment));
    } catch (e) {
      // Emit error state on failure
      emit(PaymentDetailError(e.toString()));
    }
  }

  /// Load a service payment by ID
  /// 
  /// Emits [PaymentDetailLoading] before the API call,
  /// [PaymentDetailLoaded] on success with the payment data,
  /// or [PaymentDetailError] on failure.
  /// 
  /// Parameters:
  /// - [id]: The ID of the service payment to load
  Future<void> loadServicePayment(String id) async {
    try {
      // Emit loading state before API call
      emit(const PaymentDetailLoading());

      // Fetch service payment from repository
      final payment = await _repository.getServicePaymentById(id);

      // Emit success state with data
      emit(PaymentDetailLoaded(payment));
    } catch (e) {
      // Emit error state on failure
      emit(PaymentDetailError(e.toString()));
    }
  }
}
