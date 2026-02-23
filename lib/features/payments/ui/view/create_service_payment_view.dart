import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kidsero_parent/core/network/api_service.dart';
import 'package:kidsero_parent/core/theme/app_colors.dart';
import 'package:kidsero_parent/core/theme/app_sizes.dart';
import 'package:kidsero_parent/core/widgets/custom_button.dart';
import 'package:kidsero_parent/core/widgets/custom_snackbar.dart';
import 'package:kidsero_parent/features/children/model/child_model.dart';
import 'package:kidsero_parent/features/payments/data/models/payment_type.dart';
import 'package:kidsero_parent/features/payments/data/repositories/payment_repository.dart';
import 'package:kidsero_parent/features/payments/logic/cubit/create_service_payment_cubit.dart';
import 'package:kidsero_parent/features/payments/logic/cubit/create_service_payment_state.dart';
import 'package:kidsero_parent/features/payments/ui/widgets/installment_selector.dart';
import 'package:kidsero_parent/features/payments/ui/widgets/receipt_image_picker.dart';
import 'package:kidsero_parent/features/plans/model/org_service_model.dart';
import 'package:kidsero_parent/features/plans/model/payment_method_model.dart';
import 'package:kidsero_parent/l10n/app_localizations.dart';
import 'package:kidsero_parent/core/routing/routes.dart';

/// Screen for creating organization service payments
///
/// Provides a form to create a new service payment with:
/// - Service selection
/// - Student selection
/// - Payment method selection
/// - Amount input
/// - Payment type (one-time or installment)
/// - Conditional installment number input
/// - Receipt image upload
class CreateServicePaymentScreen extends StatefulWidget {
  final OrgService? preselectedService;
  final Child? preselectedStudent;

  const CreateServicePaymentScreen({
    super.key,
    this.preselectedService,
    this.preselectedStudent,
  });

  @override
  State<CreateServicePaymentScreen> createState() =>
      _CreateServicePaymentScreenState();
}

class _CreateServicePaymentScreenState
    extends State<CreateServicePaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _installmentController = TextEditingController();

  OrgService? _selectedService;
  Child? _selectedStudent;
  PaymentMethod? _selectedPaymentMethod;
  String? _receiptImageBase64;
  PaymentType _selectedPaymentType = PaymentType.onetime;
  String? _installmentError;

  List<PaymentMethod> _paymentMethods = [];
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _selectedService = widget.preselectedService;
    _selectedStudent = widget.preselectedStudent;
    // If the selected service doesn't support installments, force one-time
    if (_selectedService != null && !_selectedService!.supportsInstallments) {
      _selectedPaymentType = PaymentType.onetime;
    }
    _installmentController.addListener(_handleInstallmentChange);
    _updateAmountForPaymentType();
    _loadInitialData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _installmentController.removeListener(_handleInstallmentChange);
    _installmentController.dispose();
    super.dispose();
  }

  /// Load payment methods
  Future<void> _loadInitialData() async {
    try {
      final apiService = context.read<ApiService>();

      final paymentMethodsResponse = await apiService.getPaymentMethods();
      final activeMethods = paymentMethodsResponse.paymentMethods
          .where((method) => method.isActive)
          .toList();

      setState(() {
        _paymentMethods = activeMethods;
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingData = false;
      });
      if (mounted) {
        CustomSnackbar.showError(
          context,
          AppLocalizations.of(context)!.somethingWentWrong,
        );
      }
    }
  }

  /// Validate installment field
  bool _validateInstallmentField() {
    if (_selectedPaymentType == PaymentType.installment) {
      final installmentText = _installmentController.text.trim();
      if (installmentText.isEmpty) {
        setState(() {
          _installmentError = AppLocalizations.of(
            context,
          )!.installmentsRequired;
        });
        return false;
      }

      final installmentNumber = int.tryParse(installmentText);
      if (installmentNumber == null || installmentNumber <= 0) {
        setState(() {
          _installmentError = AppLocalizations.of(
            context,
          )!.installmentsMustBePositive;
        });
        return false;
      }
    }

    setState(() {
      _installmentError = null;
    });
    return true;
  }

  /// Validate and submit the form
  void _submitForm(BuildContext submitContext) {
    final localizations = AppLocalizations.of(submitContext)!;

    // Clear previous installment error
    setState(() {
      _installmentError = null;
    });

    // Validate form fields
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate service selection
    if (_selectedService == null) {
      CustomSnackbar.showError(
        submitContext,
        localizations.chooseServiceToSubscribe,
      );
      return;
    }

    // Validate student selection
    if (_selectedStudent == null) {
      CustomSnackbar.showError(submitContext, localizations.studentRequired);
      return;
    }

    // Validate payment method selection
    if (_selectedPaymentMethod == null) {
      CustomSnackbar.showError(
        submitContext,
        localizations.selectPaymentMethod,
      );
      return;
    }

    // Validate receipt image
    if (_receiptImageBase64 == null || _receiptImageBase64!.isEmpty) {
      CustomSnackbar.showError(submitContext, localizations.uploadReceipt);
      return;
    }

    // Validate installment field if payment type is installment
    if (!_validateInstallmentField()) {
      return;
    }

    // Parse installment number if applicable
    int? numberOfInstallments;
    if (_selectedPaymentType == PaymentType.installment) {
      numberOfInstallments = int.parse(_installmentController.text.trim());
    }

    // Create payment
    submitContext.read<CreateServicePaymentCubit>().createPayment(
      serviceId: _selectedService!.id,
      studentId: _selectedStudent!.id,
      paymentMethodId: _selectedPaymentMethod!.id,
      amount: double.parse(_amountController.text),
      receiptImageBase64: _receiptImageBase64!,
      paymentType: _selectedPaymentType,
      numberOfInstallments: numberOfInstallments,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CreateServicePaymentCubit(context.read<PaymentRepository>()),
      child: Builder(
        builder: (blocContext) {
          final localizations = AppLocalizations.of(blocContext)!;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.primary,
              elevation: 0,
              title: Text(
                localizations.subscribeSchoolPlan,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            body:
                BlocListener<
                  CreateServicePaymentCubit,
                  CreateServicePaymentState
                >(
                  listener: (listenerContext, state) {
                    if (!listenerContext.mounted) return;

                    if (state is CreateServicePaymentSuccess) {
                      CustomSnackbar.showSuccess(
                        listenerContext,
                        localizations.paymentCreatedSuccessfully,
                      );
                      // Navigate back to payment history
                      listenerContext.go(Routes.paymentHistory);
                    } else if (state is CreateServicePaymentError) {
                      CustomSnackbar.showError(listenerContext, state.message);
                    }
                  },
                  child: _isLoadingData
                      ? const Center(child: CircularProgressIndicator())
                      : !_hasRequiredData
                      ? _buildMissingServiceState(localizations)
                      : SingleChildScrollView(
                          padding: EdgeInsets.all(
                            AppSizes.padding(blocContext),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Service summary
                                _buildServiceSummary(localizations),
                                SizedBox(height: AppSizes.spacing(blocContext)),

                                // Student summary
                                _buildStudentSummary(localizations),
                                SizedBox(height: AppSizes.spacing(blocContext)),

                                // Total amount
                                _buildTotalAmountCard(localizations),
                                SizedBox(height: AppSizes.spacing(blocContext)),

                                // Payment method selector
                                _buildPaymentMethodSelector(localizations),
                                SizedBox(height: AppSizes.spacing(context)),
                                // Amount input
                                _buildAmountInput(localizations),
                                SizedBox(height: AppSizes.spacing(context)),

                                // Installment selector (only if service allows it)
                                if (_selectedService?.supportsInstallments ==
                                    true)
                                  InstallmentSelector(
                                    selectedPaymentType: _selectedPaymentType,
                                    onPaymentTypeChanged: (type) {
                                      setState(() {
                                        _selectedPaymentType = type;
                                        _installmentError = null;
                                        if (type == PaymentType.onetime) {
                                          _installmentController.clear();
                                        }
                                        _updateAmountForPaymentType();
                                      });
                                    },
                                    installmentController:
                                        _installmentController,
                                    errorMessage: _installmentError,
                                  ),
                                SizedBox(height: AppSizes.spacing(context)),

                                // Installment preview
                                _buildInstallmentPreview(localizations),
                                SizedBox(height: AppSizes.spacing(context)),

                                // Receipt image picker
                                ReceiptImagePicker(
                                  onImageSelected: (base64Image) {
                                    setState(() {
                                      _receiptImageBase64 = base64Image;
                                    });
                                  },
                                  onImageRemoved: () {
                                    setState(() {
                                      _receiptImageBase64 = null;
                                    });
                                  },
                                ),
                                SizedBox(height: AppSizes.spacing(context) * 2),

                                // Submit button
                                BlocBuilder<
                                  CreateServicePaymentCubit,
                                  CreateServicePaymentState
                                >(
                                  builder: (context, state) {
                                    final isLoading =
                                        state is CreateServicePaymentLoading;
                                    return CustomButton(
                                      text: localizations.submit,
                                      onPressed: isLoading
                                          ? () {}
                                          : () => _submitForm(blocContext),
                                      isLoading: isLoading,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
          );
        },
      ),
    );
  }

  /// Build payment method selector dropdown
  Widget _buildPaymentMethodSelector(AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.selectPaymentMethod,
          style: TextStyle(
            fontSize: AppSizes.bodySize(context),
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: AppSizes.spacingSmall(context)),
        Container(
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonFormField<PaymentMethod>(
            value: _selectedPaymentMethod,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              prefixIcon: Icon(Icons.payment, color: AppColors.textSecondary),
            ),
            hint: Text(
              localizations.selectPaymentMethod,
              style: const TextStyle(color: AppColors.textTertiary),
            ),
            items: _paymentMethods.map((method) {
              return DropdownMenuItem<PaymentMethod>(
                value: method,
                child: Text(
                  method.name,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedPaymentMethod = value;
              });
            },
          ),
        ),
      ],
    );
  }

  /// Build amount input field
  Widget _buildAmountInput(AppLocalizations localizations) {
    final isInstallment = _selectedPaymentType == PaymentType.installment;
    final minInstallmentAmount = _minimumInstallmentAmount;
    final remainingAmount = _remainingAmount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isInstallment
              ? '${localizations.amount} (${localizations.installmentPayment})'
              : localizations.amount,
          style: TextStyle(
            fontSize: AppSizes.bodySize(context),
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: AppSizes.spacingSmall(context)),
        Container(
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            border: Border.all(color: AppColors.border),
          ),
          child: TextFormField(
            controller: _amountController,
            readOnly: !isInstallment,
            enableInteractiveSelection: isInstallment,
            keyboardType: isInstallment
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.number,
            inputFormatters: isInstallment
                ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
                : null,
            style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.attach_money,
                color: AppColors.textSecondary,
              ),
              hintText: localizations.amount,
              hintStyle: const TextStyle(color: AppColors.textTertiary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
            ),
            onTap: !isInstallment
                ? () => FocusScope.of(context).unfocus()
                : null,
            onChanged: isInstallment
                ? (_) {
                    setState(() {});
                  }
                : null,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return localizations.amountRequired;
              }
              final amount = double.tryParse(value);
              if (amount == null || amount <= 0) {
                return localizations.amountMustBePositive;
              }
              if (isInstallment) {
                if (minInstallmentAmount > 0 && amount < minInstallmentAmount) {
                  return '${localizations.minPayment}: ${minInstallmentAmount.toStringAsFixed(2)} ${localizations.currency}';
                }
                if (amount > _totalAmount) {
                  return '${localizations.totalAmount}: ${_totalAmount.toStringAsFixed(2)} ${localizations.currency}';
                }
              }
              return null;
            },
          ),
        ),
        if (isInstallment && minInstallmentAmount > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              '${localizations.minPayment}: ${minInstallmentAmount.toStringAsFixed(2)} ${localizations.currency}',
              style: TextStyle(
                fontSize: AppSizes.smallSize(context),
                color: AppColors.textSecondary,
              ),
            ),
          ),
        if (isInstallment && _currentPaymentAmount > 0)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              '${localizations.remainingAmount}: ${remainingAmount.toStringAsFixed(2)} ${localizations.currency}',
              style: TextStyle(
                fontSize: AppSizes.smallSize(context),
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }

  bool get _hasRequiredData =>
      _selectedService != null && _selectedStudent != null;

  void _handleInstallmentChange() {
    if (!mounted) return;
    if (_selectedPaymentType == PaymentType.installment) {
      setState(() {
        _updateAmountForPaymentType();
      });
    }
  }

  void _updateAmountForPaymentType() {
    final total = _totalAmount;

    if (_selectedPaymentType == PaymentType.installment) {
      final minAmount = _minimumInstallmentAmount;
      if (minAmount <= 0) {
        _amountController.clear();
        return;
      }

      final currentAmount = double.tryParse(_amountController.text.trim());
      if (currentAmount == null || currentAmount < minAmount) {
        _amountController.text = minAmount.toStringAsFixed(2);
      }
      return;
    }

    if (total <= 0) {
      _amountController.clear();
      return;
    }

    _amountController.text = total.toStringAsFixed(2);
  }

  double get _totalAmount {
    final price = _selectedService?.finalPrice;
    if (price == null) return 0;
    return price.toDouble();
  }

  double get _currentPaymentAmount {
    final value = double.tryParse(_amountController.text.trim());
    if (value == null || value <= 0) {
      return 0;
    }
    return value;
  }

  double get _minimumInstallmentAmount {
    final installments = int.tryParse(_installmentController.text.trim());
    if (installments == null || installments <= 0) {
      return 0;
    }
    final total = _totalAmount;
    if (total <= 0) {
      return 0;
    }
    return total / installments;
  }

  double get _remainingAmount {
    if (_selectedPaymentType != PaymentType.installment) {
      return 0;
    }
    final remaining = _totalAmount - _currentPaymentAmount;
    return remaining < 0 ? 0 : remaining;
  }

  Widget _buildServiceSummary(AppLocalizations localizations) {
    final service = _selectedService;
    if (service == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.school, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.service,
                  style: TextStyle(
                    fontSize: AppSizes.smallSize(context),
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  service.serviceName,
                  style: TextStyle(
                    fontSize: AppSizes.subHeadingSize(context),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  service.serviceDescription,
                  style: TextStyle(
                    fontSize: AppSizes.bodySize(context),
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${service.finalPrice.toStringAsFixed(2)} ${localizations.currency}',
                  style: TextStyle(
                    fontSize: AppSizes.bodySize(context),
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentSummary(AppLocalizations localizations) {
    final student = _selectedStudent;
    if (student == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.child_care,
              color: AppColors.accent,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.student,
                  style: TextStyle(
                    fontSize: AppSizes.smallSize(context),
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  student.name,
                  style: TextStyle(
                    fontSize: AppSizes.subHeadingSize(context),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${student.displayGrade} ${student.displayClassroom}'.trim(),
                  style: TextStyle(
                    fontSize: AppSizes.bodySize(context),
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  student.displaySchoolName,
                  style: TextStyle(
                    fontSize: AppSizes.smallSize(context),
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalAmountCard(AppLocalizations localizations) {
    final total = _totalAmount;
    if (total <= 0) {
      return const SizedBox.shrink();
    }

    final subtitle = _selectedPaymentType == PaymentType.installment
        ? localizations.installmentPayment
        : localizations.oneTimePayment;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.totalAmount,
                style: TextStyle(
                  fontSize: AppSizes.bodySize(context),
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: AppSizes.smallSize(context),
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Text(
            '${total.toStringAsFixed(2)} ${localizations.currency}',
            style: TextStyle(
              fontSize: AppSizes.headingSize(context),
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstallmentPreview(AppLocalizations localizations) {
    if (_selectedPaymentType != PaymentType.installment) {
      return const SizedBox.shrink();
    }

    final installments = int.tryParse(_installmentController.text.trim());
    if (installments == null || installments <= 0) {
      return const SizedBox.shrink();
    }

    final currentPayment = _currentPaymentAmount;
    if (currentPayment <= 0) {
      return const SizedBox.shrink();
    }

    final remaining = _remainingAmount;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.remainingAmount,
            style: TextStyle(
              fontSize: AppSizes.bodySize(context),
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${remaining.toStringAsFixed(2)} ${localizations.currency}',
            style: TextStyle(
              fontSize: AppSizes.headingSize(context),
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            localizations.installmentPayment,
            style: TextStyle(
              fontSize: AppSizes.smallSize(context),
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissingServiceState(AppLocalizations localizations) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline, size: 48, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              localizations.chooseServiceToSubscribe,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppSizes.bodySize(context),
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              localizations.browseSchoolServices,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppSizes.smallSize(context),
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: localizations.close,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
