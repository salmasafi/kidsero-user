import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidsero_parent/core/network/api_service.dart';
import 'package:kidsero_parent/features/plans/cubit/payment_cubit.dart';
import 'package:kidsero_parent/features/plans/cubit/payment_state.dart';
import 'package:kidsero_parent/features/plans/model/payment_method_model.dart';
import 'package:kidsero_parent/features/plans/model/payment_model.dart';
import 'package:kidsero_parent/l10n/app_localizations.dart';
import 'package:kidsero_parent/core/utils/price_utils.dart';
import 'package:kidsero_parent/core/widgets/custom_button.dart';
import 'package:kidsero_parent/core/widgets/custom_snackbar.dart';

class SubscriptionDialog extends StatefulWidget {
  final String title;
  final num amount;
  final String? planId;
  final String? serviceId;
  final String? studentId;

  const SubscriptionDialog({
    Key? key,
    required this.title,
    required this.amount,
    this.planId,
    this.serviceId,
    this.studentId,
  }) : super(key: key);

  @override
  State<SubscriptionDialog> createState() => _SubscriptionDialogState();
}

class _SubscriptionDialogState extends State<SubscriptionDialog> {
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  String? _selectedPaymentMethodId;
  List<PaymentMethod> _paymentMethods = [];

  @override
  void initState() {
    super.initState();
    // Payment methods will be loaded via PaymentCubit
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );
      if (image != null) {
        setState(() {
          _imageFile = image;
        });
        if (mounted) {
          CustomSnackbar.showSuccess(context, 'Image selected successfully');
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        CustomSnackbar.showError(context, 'Failed to pick image: $e');
      }
    }
  }

  Future<String> _convertToBase64(File file) async {
    final bytes = await file.readAsBytes();
    String extension = file.path.split('.').last.toLowerCase();
    if (extension == 'jpg') extension = 'jpeg';
    return 'data:image/$extension;base64,${base64Encode(bytes)}';
  }

  Widget _buildPaymentMethodLogo(String logoUrl) {
    // Handle empty or invalid URLs
    if (logoUrl.isEmpty) {
      return const Icon(Icons.payment, size: 40);
    }

    // If the URL doesn't start with http/https, it's likely a relative path
    // In this case, just show the payment icon instead of trying to load an invalid URL
    if (!logoUrl.startsWith('http://') && !logoUrl.startsWith('https://')) {
      return const Icon(Icons.payment, size: 40);
    }

    return Image.network(
      logoUrl,
      width: 40,
      height: 40,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Show icon if image fails to load
        return const Icon(Icons.payment, size: 40);
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleSubscription(BuildContext context) async {
    if (_imageFile == null || _selectedPaymentMethodId == null) return;

    final base64Image = await _convertToBase64(File(_imageFile!.path));

    if (!context.mounted) return;

    if (widget.planId != null) {
      final request = CreatePaymentRequest(
        planId: widget.planId!,
        paymentMethodId: _selectedPaymentMethodId!,
        amount: widget.amount,
        receiptImage: base64Image,
      );
      context.read<PaymentCubit>().createPayment(request);
    } else if (widget.serviceId != null && widget.studentId != null) {
      final request = CreateServicePaymentRequest(
        serviceId: widget.serviceId!,
        paymentMethodId: _selectedPaymentMethodId!,
        amount: widget.amount,
        receiptImage: base64Image,
        studentId: widget.studentId!,
      );
      context.read<PaymentCubit>().createServicePayment(request);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) =>
          PaymentCubit(context.read<ApiService>())..getPaymentMethods(),
      child: BlocConsumer<PaymentCubit, PaymentState>(
        listener: (context, state) {
          if (state is PaymentSuccess) {
            CustomSnackbar.showSuccess(context, state.message);
            Navigator.of(context).pop(true);
          } else if (state is PaymentError) {
            CustomSnackbar.showError(context, state.message);
          } else if (state is PaymentMethodsLoaded) {
            setState(() {
              _paymentMethods = state.paymentMethods;
              if (_paymentMethods.isNotEmpty) {
                _selectedPaymentMethodId = _paymentMethods.first.id;
              }
            });
          }
        },
        builder: (context, state) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${l10n.amount}: ${formatPrice(widget.amount)}',
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Payment Methods List
                  Text(
                    l10n.selectPaymentMethod,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (state is PaymentLoading && _paymentMethods.isEmpty)
                    const Center(child: CircularProgressIndicator())
                  else
                    Column(
                      children: _paymentMethods.map((method) {
                        return RadioListTile<String>(
                          value: method.id,
                          groupValue: _selectedPaymentMethodId,
                          onChanged: (value) {
                            setState(() {
                              _selectedPaymentMethodId = value;
                            });
                          },
                          title: Text(method.name),
                          subtitle: Text(method.description),
                          secondary: method.logo.isNotEmpty
                              ? _buildPaymentMethodLogo(method.logo)
                              : const Icon(Icons.payment),
                          contentPadding: EdgeInsets.zero,
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 24),

                  // Receipt Upload
                  Text(
                    l10n.uploadReceipt,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => _pickImage(),
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: _imageFile == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.add_a_photo_outlined,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.tapToChooseReceipt,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(_imageFile!.path),
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  CustomButton(
                    text: l10n.subscribeNow,
                    isLoading:
                        state is PaymentLoading && _paymentMethods.isNotEmpty,
                    onPressed:
                        _selectedPaymentMethodId == null || _imageFile == null
                        ? () {}
                        : () {
                            _handleSubscription(context);
                          },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}