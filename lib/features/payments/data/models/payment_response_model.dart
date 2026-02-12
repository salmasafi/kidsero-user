import 'payment_model.dart';
import 'service_payment_model.dart';

/// Model wrapping the API response for payment history
class PaymentResponseModel {
  final List<PaymentModel> payments;
  final List<ServicePaymentModel> orgServicePayments;

  PaymentResponseModel({
    required this.payments,
    required this.orgServicePayments,
  });

  /// Create PaymentResponseModel from JSON
  factory PaymentResponseModel.fromJson(Map<String, dynamic> json) {
    return PaymentResponseModel(
      payments: (json['payments'] as List<dynamic>?)
              ?.map((e) => PaymentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      orgServicePayments: (json['orgServicePayments'] as List<dynamic>?)
              ?.map((e) =>
                  ServicePaymentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Convert PaymentResponseModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'payments': payments.map((e) => e.toJson()).toList(),
      'orgServicePayments': orgServicePayments.map((e) => e.toJson()).toList(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PaymentResponseModel &&
        _listEquals(other.payments, payments) &&
        _listEquals(other.orgServicePayments, orgServicePayments);
  }

  @override
  int get hashCode {
    return Object.hash(
      Object.hashAll(payments),
      Object.hashAll(orgServicePayments),
    );
  }

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
