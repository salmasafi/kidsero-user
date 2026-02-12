import 'package:flutter/material.dart';
import 'package:kidsero_driver/features/payments/data/models/payment_status.dart';
import 'package:kidsero_driver/core/theme/app_colors.dart';
import 'package:kidsero_driver/l10n/app_localizations.dart';

/// Widget that displays a payment status badge with appropriate color and text
class PaymentStatusBadge extends StatelessWidget {
  final PaymentStatus status;

  const PaymentStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStatusText(localizations),
        style: TextStyle(
          color: _getTextColor(),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Get the background color based on payment status
  Color _getBackgroundColor() {
    switch (status) {
      case PaymentStatus.pending:
        return AppColors.warning.withValues(alpha: 0.1);
      case PaymentStatus.completed:
        return AppColors.success.withValues(alpha: 0.1);
      case PaymentStatus.rejected:
        return AppColors.error.withValues(alpha: 0.1);
    }
  }

  /// Get the text color based on payment status
  Color _getTextColor() {
    switch (status) {
      case PaymentStatus.pending:
        return AppColors.warning;
      case PaymentStatus.completed:
        return AppColors.success;
      case PaymentStatus.rejected:
        return AppColors.error;
    }
  }

  /// Get the localized status text
  String _getStatusText(AppLocalizations localizations) {
    switch (status) {
      case PaymentStatus.pending:
        return localizations.paymentStatusPending;
      case PaymentStatus.completed:
        return localizations.paymentStatusCompleted;
      case PaymentStatus.rejected:
        return localizations.paymentStatusRejected;
    }
  }
}
