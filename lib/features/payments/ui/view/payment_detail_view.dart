import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kidsero_driver/core/network/api_service.dart';
import 'package:kidsero_driver/core/theme/app_colors.dart';
import 'package:kidsero_driver/core/widgets/custom_loading.dart';
import 'package:kidsero_driver/features/payments/data/models/payment_model.dart';
import 'package:kidsero_driver/features/payments/data/models/payment_status.dart';
import 'package:kidsero_driver/features/payments/data/models/payment_type.dart';
import 'package:kidsero_driver/features/payments/data/models/service_payment_model.dart';
import 'package:kidsero_driver/features/payments/data/repositories/payment_repository.dart';
import 'package:kidsero_driver/features/payments/logic/cubit/payment_detail_cubit.dart';
import 'package:kidsero_driver/features/payments/logic/cubit/payment_detail_state.dart';
import 'package:kidsero_driver/features/payments/ui/widgets/payment_status_badge.dart';
import 'package:kidsero_driver/features/payments/utils/image_utils.dart';
import 'package:kidsero_driver/features/payments/services/payment_lookup_service.dart';
import 'package:kidsero_driver/l10n/app_localizations.dart';

/// Payment Detail Screen
/// 
/// Displays detailed information about a specific payment.
/// Supports both plan payments and service payments.
/// Shows receipt images, payment status, and rejection reasons.
class PaymentDetailScreen extends StatelessWidget {
  final String paymentId;
  final bool isPlanPayment;

  const PaymentDetailScreen({
    super.key,
    required this.paymentId,
    required this.isPlanPayment,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = PaymentDetailCubit(
          PaymentRepository(context.read<ApiService>()),
        );
        
        // Load the appropriate payment type
        if (isPlanPayment) {
          cubit.loadPlanPayment(paymentId);
        } else {
          cubit.loadServicePayment(paymentId);
        }
        
        return cubit;
      },
      child: const _PaymentDetailContent(),
    );
  }
}

class _PaymentDetailContent extends StatelessWidget {
  const _PaymentDetailContent();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.payment,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
      ),
      body: BlocBuilder<PaymentDetailCubit, PaymentDetailState>(
        builder: (context, state) {
          // Loading state
          if (state is PaymentDetailLoading) {
            return const CustomLoading();
          }

          // Error state
          if (state is PaymentDetailError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.somethingWentWrong,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        l10n.close,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Loaded state
          if (state is PaymentDetailLoaded) {
            final payment = state.payment;
            
            if (payment is PaymentModel) {
              return _buildPlanPaymentDetail(context, payment);
            } else if (payment is ServicePaymentModel) {
              return _buildServicePaymentDetail(context, payment);
            }
          }

          // Initial state
          return const SizedBox.shrink();
        },
      ),
    );
  }

  /// Build plan payment detail view
  Widget _buildPlanPaymentDetail(BuildContext context, PaymentModel payment) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('MMM dd, yyyy - hh:mm a');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Badge
          Center(
            child: PaymentStatusBadge(status: payment.status),
          ),
          const SizedBox(height: 24),

          // Rejection Reason (if rejected)
          if (payment.status == PaymentStatus.rejected && 
              payment.rejectedReason != null) ...[
            _buildRejectionReasonCard(context, l10n, payment.rejectedReason!),
            const SizedBox(height: 24),
          ],

          // Payment Information Card
          _buildInfoCard(
            context,
            children: [
              _buildInfoRow(l10n.amount, '\$${payment.amount.toStringAsFixed(2)}'),
              const Divider(height: 24),
              _buildInfoRow(l10n.appServices, payment.planId != null 
                  ? PaymentLookupService().getPlanName(payment.planId!)
                  : 'N/A'),
              const Divider(height: 24),
              if (payment.paymentMethodId != null) ...[
                _buildInfoRow(l10n.paymentMethod, PaymentLookupService().getPaymentMethodName(payment.paymentMethodId!)),
                const Divider(height: 24),
              ],
              _buildInfoRow(l10n.date, dateFormat.format(payment.createdAt)),
              if (payment.notes != null) ...[
                const Divider(height: 24),
                _buildInfoRow(l10n.notes, payment.notes!),
              ],
            ],
          ),
          const SizedBox(height: 24),

          // Receipt Image
          if (payment.receiptImage != null) ...[
            _buildReceiptImage(context, payment.receiptImage!),
          ],
        ],
      ),
    );
  }

  /// Build service payment detail view
  Widget _buildServicePaymentDetail(
    BuildContext context,
    ServicePaymentModel payment,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('MMM dd, yyyy - hh:mm a');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Badge
          Center(
            child: PaymentStatusBadge(status: payment.status),
          ),
          const SizedBox(height: 24),

          // Rejection Reason (if rejected)
          if (payment.status == PaymentStatus.rejected && 
              payment.rejectedReason != null) ...[
            _buildRejectionReasonCard(context, l10n, payment.rejectedReason!),
            const SizedBox(height: 24),
          ],

          // Payment Information Card
          _buildInfoCard(
            context,
            children: [
              _buildInfoRow(l10n.amount, '\$${payment.amount.toStringAsFixed(2)}'),
              const Divider(height: 24),
              _buildInfoRow(l10n.paymentType, _getPaymentTypeLabel(l10n, payment.paymentType)),
              if (payment.paymentType == PaymentType.installment && 
                  payment.requestedInstallments != null) ...[
                const Divider(height: 24),
                _buildInfoRow(
                  l10n.numberOfInstallments,
                  payment.requestedInstallments.toString(),
                ),
              ],
              const Divider(height: 24),
              _buildInfoRow(l10n.student, payment.student?.name ?? payment.studentId),
              const Divider(height: 24),
              _buildInfoRow(l10n.schoolServices, payment.service?.name ?? payment.serviceId),
              const Divider(height: 24),
              _buildInfoRow(l10n.paymentMethod, payment.paymentMethod?.name ?? payment.paymentMethodId ?? 'N/A'),
              const Divider(height: 24),
              _buildInfoRow(l10n.date, dateFormat.format(payment.createdAt)),
            ],
          ),
          const SizedBox(height: 24),

          // Receipt Image
          if (payment.receiptImage != null) ...[
            _buildReceiptImage(context, payment.receiptImage!),
          ],
        ],
      ),
    );
  }

  /// Build rejection reason card with prominent styling
  Widget _buildRejectionReasonCard(
    BuildContext context,
    AppLocalizations l10n,
    String reason,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.rejectionReason,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            reason,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  /// Build information card
  Widget _buildInfoCard(BuildContext context, {required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  /// Build information row
  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  /// Build receipt image section
  Widget _buildReceiptImage(BuildContext context, String receiptImage) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.receiptImage,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _showFullScreenImage(context, receiptImage),
          child: Container(
            width: double.infinity,
            height: 200,
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _buildReceiptImageWidget(receiptImage),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            l10n.tapToViewClearly,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ),
      ],
    );
  }

  /// Build receipt image widget based on image type (URL or base64)
  Widget _buildReceiptImageWidget(String receiptImage) {
    // Check if it's a URL or base64
    if (receiptImage.startsWith('http://') || receiptImage.startsWith('https://')) {
      // It's a URL, use NetworkImage
      return Image.network(
        receiptImage,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildImageErrorWidget();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                  : null,
            ),
          );
        },
      );
    } else {
      // It's base64, use Image.memory
      return Image.memory(
        ImageUtils.base64ToImage(receiptImage),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildImageErrorWidget();
        },
      );
    }
  }

  /// Build error widget for failed image loading
  Widget _buildImageErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            'Failed to load image',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// Show full screen image dialog
  void _showFullScreenImage(BuildContext context, String imageString) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: imageString.startsWith('http://') || imageString.startsWith('https://')
                    ? Image.network(imageString, fit: BoxFit.contain)
                    : Image.memory(ImageUtils.base64ToImage(imageString), fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get localized payment type label
  String _getPaymentTypeLabel(AppLocalizations l10n, PaymentType type) {
    switch (type) {
      case PaymentType.onetime:
        return l10n.oneTimePayment;
      case PaymentType.installment:
        return l10n.installmentPayment;
    }
  }
}
