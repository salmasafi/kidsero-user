import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kidsero_driver/features/payments/data/models/payment_type.dart';
import 'package:kidsero_driver/core/theme/app_colors.dart';
import 'package:kidsero_driver/l10n/app_localizations.dart';

/// Widget for selecting payment type (one-time or installment) and number of installments
class InstallmentSelector extends StatelessWidget {
  final PaymentType selectedPaymentType;
  final ValueChanged<PaymentType> onPaymentTypeChanged;
  final TextEditingController installmentController;
  final String? errorMessage;

  const InstallmentSelector({
    super.key,
    required this.selectedPaymentType,
    required this.onPaymentTypeChanged,
    required this.installmentController,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final showError = errorMessage != null && errorMessage!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Payment Type Label
        Text(
          localizations.paymentType,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            fontFamily: 'Cairo',
          ),
        ),
        const SizedBox(height: 12),

        // Payment Type Radio Buttons
        Container(
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              // One-Time Payment Radio
              RadioListTile<PaymentType>(
                title: Text(
                  localizations.oneTimePayment,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontFamily: 'Cairo',
                  ),
                ),
                value: PaymentType.onetime,
                groupValue: selectedPaymentType,
                onChanged: (PaymentType? value) {
                  if (value != null) {
                    onPaymentTypeChanged(value);
                  }
                },
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
              ),

              // Installment Payment Radio
              RadioListTile<PaymentType>(
                title: Text(
                  localizations.installmentPayment,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontFamily: 'Cairo',
                  ),
                ),
                value: PaymentType.installment,
                groupValue: selectedPaymentType,
                onChanged: (PaymentType? value) {
                  if (value != null) {
                    onPaymentTypeChanged(value);
                  }
                },
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),

        // Conditional Installment Number Field
        if (selectedPaymentType == PaymentType.installment) ...[
          const SizedBox(height: 16),
          Text(
            localizations.numberOfInstallments,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: showError ? AppColors.error : AppColors.border,
                width: showError ? 2 : 1,
              ),
            ),
            child: TextField(
              controller: installmentController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
                fontFamily: 'Cairo',
              ),
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.payment,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                hintText: localizations.numberOfInstallments,
                hintStyle: const TextStyle(
                  color: AppColors.textTertiary,
                  fontFamily: 'Cairo',
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
              ),
            ),
          ),
          if (showError)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                errorMessage!,
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 12,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
        ],
      ],
    );
  }
}
