import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kidsero_parent/features/payments/data/models/payment_model.dart';
import 'package:kidsero_parent/features/payments/data/models/service_payment_model.dart';
import 'package:kidsero_parent/features/payments/ui/widgets/payment_status_badge.dart';
import 'package:kidsero_parent/features/payments/services/payment_lookup_service.dart';
import 'package:kidsero_parent/core/theme/app_colors.dart';
import 'package:kidsero_parent/l10n/app_localizations.dart';

/// Widget that displays a payment item in a list
/// Supports both PaymentModel (plan payments) and ServicePaymentModel (service payments)
class PaymentListItem extends StatelessWidget {
  final dynamic payment; // PaymentModel or ServicePaymentModel
  final VoidCallback? onTap;

  const PaymentListItem({
    super.key,
    required this.payment,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    // Extract common properties from either payment type
    final amount = _getAmount();
    final status = _getStatus();
    final createdAt = _getCreatedAt();
    final paymentType = _getPaymentTypeLabel(localizations);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Amount section with icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.receipt_long,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            // Payment details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Payment type and status row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          paymentType,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      PaymentStatusBadge(status: status),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Amount
                  Text(
                    '${localizations.amount}: ${amount.toStringAsFixed(2)} ${localizations.currency}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Payment method
                  Text(
                    '${localizations.paymentMethod}: ${_getPaymentMethodName()}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Date
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Arrow icon
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  /// Get amount from either payment type
  double _getAmount() {
    if (payment is PaymentModel) {
      return (payment as PaymentModel).amount;
    } else if (payment is ServicePaymentModel) {
      return (payment as ServicePaymentModel).amount;
    }
    return 0.0;
  }

  /// Get status from either payment type
  dynamic _getStatus() {
    if (payment is PaymentModel) {
      return (payment as PaymentModel).status;
    } else if (payment is ServicePaymentModel) {
      return (payment as ServicePaymentModel).status;
    }
    throw Exception('Invalid payment type');
  }

  /// Get creation date from either payment type
  DateTime _getCreatedAt() {
    if (payment is PaymentModel) {
      return (payment as PaymentModel).createdAt;
    } else if (payment is ServicePaymentModel) {
      return (payment as ServicePaymentModel).createdAt;
    }
    return DateTime.now();
  }

  /// Get payment type label
  String _getPaymentTypeLabel(AppLocalizations localizations) {
    // For service payments, use nested objects if available
    if (payment is ServicePaymentModel) {
      final servicePayment = payment as ServicePaymentModel;
      
      // Build a more descriptive label with student and service info
      final parts = <String>[];
      
      // Add service name if available
      if (servicePayment.service != null) {
        parts.add(servicePayment.service!.name);
      } else {
        parts.add(localizations.schoolServices);
      }
      
      // Add student name if available
      if (servicePayment.student != null) {
        parts.add('(${servicePayment.student!.name})');
      }
      
      return parts.join(' ');
    }
    
    // For plan payments, use lookup service to get plan name
    if (payment is PaymentModel) {
      final planPayment = payment as PaymentModel;
      if (planPayment.planId != null) {
        return PaymentLookupService().getPlanName(planPayment.planId!);
      }
      return localizations.appServices;
    }
    
    return localizations.payment;
  }

  /// Get payment method name
  String _getPaymentMethodName() {
    // For service payments, use nested payment method if available
    if (payment is ServicePaymentModel) {
      final servicePayment = payment as ServicePaymentModel;
      
      // Use nested payment method name if available
      if (servicePayment.paymentMethod != null) {
        return servicePayment.paymentMethod!.name;
      }
      
      // Fallback to payment method ID if nested object not available
      if (servicePayment.paymentMethodId != null) {
        return servicePayment.paymentMethodId!;
      }
    }
    
    // For plan payments, use lookup service
    if (payment is PaymentModel) {
      final planPayment = payment as PaymentModel;
      if (planPayment.paymentMethodId != null) {
        return PaymentLookupService().getPaymentMethodName(planPayment.paymentMethodId!);
      }
    }
    
    return 'N/A';
  }

  /// Format date to readable string
  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
}
