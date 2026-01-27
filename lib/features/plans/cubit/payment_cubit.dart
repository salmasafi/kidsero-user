import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidsero_driver/core/network/api_service.dart';
import 'package:kidsero_driver/features/plans/cubit/payment_state.dart';
import 'package:kidsero_driver/features/plans/model/payment_model.dart';

class PaymentCubit extends Cubit<PaymentState> {
  final ApiService _apiService;

  PaymentCubit(this._apiService) : super(PaymentInitial());

  Future<void> getPayments() async {
    emit(PaymentLoading());
    try {
      final response = await _apiService.getPayments();
      if (response.success) {
        emit(
          PaymentsLoaded(
            payments: response.data.payments,
            orgServicePayments: response.data.orgServicePayments,
          ),
        );
      } else {
        emit(PaymentError(response.data.message));
      }
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }

  Future<void> getPaymentById(String id) async {
    emit(PaymentLoading());
    try {
      final response = await _apiService.getPaymentById(id);
      if (response.success && response.data.payment != null) {
        emit(PaymentDetailLoaded(response.data.payment!));
      } else {
        emit(PaymentError(response.data.message));
      }
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }

  Future<void> createPayment(CreatePaymentRequest request) async {
    emit(PaymentLoading());
    try {
      final response = await _apiService.createPayment(request);
      if (response.success) {
        emit(PaymentSuccess(response.data.message));
      } else {
        emit(PaymentError(response.data.message));
      }
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }

  Future<void> createServicePayment(CreateServicePaymentRequest request) async {
    emit(PaymentLoading());
    try {
      final response = await _apiService.createServicePayment(request);
      if (response.success) {
        emit(PaymentSuccess(response.data.message));
      } else {
        emit(PaymentError(response.data.message));
      }
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }
}
