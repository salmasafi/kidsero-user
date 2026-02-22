import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kidsero_parent/core/network/api_service.dart';
import 'package:kidsero_parent/core/theme/app_colors.dart';
import 'package:kidsero_parent/core/theme/app_sizes.dart';
import 'package:kidsero_parent/core/widgets/custom_button.dart';
import 'package:kidsero_parent/core/widgets/custom_snackbar.dart';
import 'package:kidsero_parent/features/payments/data/repositories/payment_repository.dart';
import 'package:kidsero_parent/features/payments/logic/cubit/create_plan_payment_cubit.dart';
import 'package:kidsero_parent/features/payments/logic/cubit/create_plan_payment_state.dart';
import 'package:kidsero_parent/features/payments/ui/widgets/receipt_image_picker.dart';
import 'package:kidsero_parent/features/plans/model/payment_method_model.dart';
import 'package:kidsero_parent/features/plans/model/plans_model.dart';
import 'package:kidsero_parent/l10n/app_localizations.dart';
import 'package:kidsero_parent/core/utils/price_utils.dart';
import 'package:kidsero_parent/core/routing/routes.dart';

/// Screen for creating plan subscription payments
///
/// Provides a form to create a new plan payment with:
/// - Selected plan summary
/// - Payment method selection
/// - Amount input
/// - Optional notes
/// - Receipt image upload
class CreatePlanPaymentScreen extends StatefulWidget {
  final PlanModel? preselectedPlan;

  const CreatePlanPaymentScreen({super.key, this.preselectedPlan});

  @override
  State<CreatePlanPaymentScreen> createState() =>
      _CreatePlanPaymentScreenState();
}

class _CreatePlanPaymentScreenState extends State<CreatePlanPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  PlanModel? _selectedPlan;
  PaymentMethod? _selectedPaymentMethod;
  String? _receiptImageBase64;

  List<PaymentMethod> _paymentMethods = [];
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _selectedPlan = widget.preselectedPlan;
    _prefillAmount();
    _loadInitialData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _prefillAmount() {
    if (_selectedPlan != null) {
      _amountController.text = _selectedPlan!.price.toString();
    }
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

  /// Validate and submit the form
  void _submitForm(BuildContext submitContext) {
    final localizations = AppLocalizations.of(submitContext)!;

    // Validate form fields
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate plan selection
    if (_selectedPlan == null) {
      CustomSnackbar.showError(submitContext, localizations.planRequired);
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

    // Create payment
    submitContext.read<CreatePlanPaymentCubit>().createPayment(
      planId: _selectedPlan!.id,
      paymentMethodId: _selectedPaymentMethod!.id,
      amount: double.parse(_amountController.text),
      receiptImageBase64: _receiptImageBase64!,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CreatePlanPaymentCubit(context.read<PaymentRepository>()),
      child: Builder(
        builder: (blocContext) {
          final localizations = AppLocalizations.of(blocContext)!;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.primary,
              elevation: 0,
              title: Text(
                localizations.subscribeAppPlan,
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
            body: BlocListener<CreatePlanPaymentCubit, CreatePlanPaymentState>(
              listener: (listenerContext, state) {
                if (state is CreatePlanPaymentSuccess) {
                  CustomSnackbar.showSuccess(
                    listenerContext,
                    localizations.paymentCreatedSuccessfully,
                  );
                  // Navigate back to payment history
                  listenerContext.go(Routes.paymentHistory);
                } else if (state is CreatePlanPaymentError) {
                  CustomSnackbar.showError(listenerContext, state.message);
                }
              },
              child: _selectedPlan == null
                  ? _buildMissingPlanState(localizations)
                  : _isLoadingData
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(AppSizes.padding(blocContext)),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Selected plan summary
                            _buildPlanSummary(localizations),
                            SizedBox(height: AppSizes.spacing(blocContext)),

                            // Total amount summary
                            _buildTotalAmountCard(localizations),
                            SizedBox(height: AppSizes.spacing(blocContext)),

                            // Payment method selector
                            _buildPaymentMethodSelector(localizations),
                            SizedBox(height: AppSizes.spacing(context)),

                            // Amount input
                            _buildAmountInput(localizations),
                            SizedBox(height: AppSizes.spacing(context)),

                            // Notes input (optional)
                            _buildNotesInput(localizations),
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
                              CreatePlanPaymentCubit,
                              CreatePlanPaymentState
                            >(
                              builder: (context, state) {
                                final isLoading =
                                    state is CreatePlanPaymentLoading;
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

  /// Build selected plan summary card
  Widget _buildPlanSummary(AppLocalizations localizations) {
    final plan = _selectedPlan;
    if (plan == null) {
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
            child: const Icon(
              Icons.workspace_premium,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.plan,
                  style: TextStyle(
                    fontSize: AppSizes.smallSize(context),
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  plan.name,
                  style: TextStyle(
                    fontSize: AppSizes.subHeadingSize(context),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  formatPrice(plan.price),
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

  /// Build total amount summary card
  Widget _buildTotalAmountCard(AppLocalizations localizations) {
    final plan = _selectedPlan;
    if (plan == null) {
      return const SizedBox.shrink();
    }

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
                localizations.oneTimePayment,
                style: TextStyle(
                  fontSize: AppSizes.smallSize(context),
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Text(
            formatPrice(plan.price),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.amount,
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
            readOnly: true,
            enableInteractiveSelection: false,
            keyboardType: TextInputType.number,
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
            onTap: () => FocusScope.of(context).unfocus(),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return localizations.amountRequired;
              }
              final amount = double.tryParse(value);
              if (amount == null || amount <= 0) {
                return localizations.amountMustBePositive;
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  /// Build notes input field (optional)
  Widget _buildNotesInput(AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${localizations.notes} (${localizations.optional})',
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
            controller: _notesController,
            maxLines: 3,
            style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.note,
                color: AppColors.textSecondary,
              ),
              hintText: localizations.notes,
              hintStyle: const TextStyle(color: AppColors.textTertiary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMissingPlanState(AppLocalizations localizations) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline, size: 48, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              localizations.choosePlanToSubscribe,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppSizes.bodySize(context),
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              localizations.browseParentPlans,
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