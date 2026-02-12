import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/payment_repository.dart';
import 'payment_history_state.dart';

/// Cubit for managing payment history state
/// 
/// Handles loading and refreshing of both plan payments and service payments.
/// Emits appropriate states during the loading lifecycle.
class PaymentHistoryCubit extends Cubit<PaymentHistoryState> {
  final PaymentRepository _repository;

  PaymentHistoryCubit(this._repository) : super(const PaymentHistoryInitial());

  /// Load all payments (both plan and service payments)
  /// 
  /// Emits [PaymentHistoryLoading] before the API call,
  /// [PaymentHistoryLoaded] on success with the payment data,
  /// or [PaymentHistoryError] on failure.
  Future<void> loadPayments() async {
    try {
      print('[PaymentHistoryCubit] Loading payments...');
      // Emit loading state before API call
      emit(const PaymentHistoryLoading());

      // Fetch payments from repository
      final response = await _repository.getAllPayments();

      print('[PaymentHistoryCubit] Loaded ${response.payments.length} plan payments and ${response.orgServicePayments.length} service payments');
      // Emit success state with data
      emit(PaymentHistoryLoaded(
        planPayments: response.payments,
        servicePayments: response.orgServicePayments,
      ));
    } catch (e) {
      print('[PaymentHistoryCubit] Error loading payments: $e');
      // Emit error state on failure
      emit(PaymentHistoryError(e.toString()));
    }
  }

  /// Refresh payment data
  /// 
  /// This is a convenience method that calls [loadPayments].
  /// Useful for pull-to-refresh functionality.
  Future<void> refresh() async {
    await loadPayments();
  }
}
