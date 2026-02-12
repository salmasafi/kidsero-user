import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kidsero_driver/core/network/api_service.dart';
import 'package:kidsero_driver/core/theme/app_colors.dart';
import 'package:kidsero_driver/core/theme/app_sizes.dart';
import 'package:kidsero_driver/core/widgets/custom_button.dart';
import 'package:kidsero_driver/core/widgets/custom_snackbar.dart';
import 'package:kidsero_driver/features/payments/data/repositories/payment_repository.dart';
import 'package:kidsero_driver/features/payments/logic/cubit/create_plan_payment_cubit.dart';
import 'package:kidsero_driver/features/payments/logic/cubit/create_plan_payment_state.dart';
import 'package:kidsero_driver/features/payments/ui/widgets/receipt_image_picker.dart';
import 'package:kidsero_driver/features/plans/cubit/plans_cubit.dart';
import 'package:kidsero_driver/features/plans/model/payment_method_model.dart';
import 'package:kidsero_driver/features/plans/model/plans_model.dart';
import 'package:kidsero_driver/l10n/app_localizations.dart';
import 'package:kidsero_driver/core/routing/routes.dart';

/// Screen for creating plan subscription payments
/// 
/// Provides a form to create a new plan payment with:
/// - Plan selection
/// - Payment method selection
/// - Amount input
/// - Optional notes
/// - Receipt image upload
class CreatePlanPaymentScreen extends StatefulWidget {
  const CreatePlanPaymentScreen({super.key});

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

  List<PlanModel> _plans = [];
  List<PaymentMethod> _paymentMethods = [];
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Load plans and payment methods
  Future<void> _loadInitialData() async {
    try {
      final apiService = context.read<ApiService>();

      // Load plans
      final plansCubit = PlansCubit(apiService);
      await plansCubit.fetchPlans();
      final plansState = plansCubit.state;
      if (plansState is PlansLoaded) {
        _plans = plansState.plans;
      }

      // Load payment methods
      final paymentMethodsResponse = await apiService.getPaymentMethods();
      _paymentMethods = paymentMethodsResponse.paymentMethods
          .where((method) => method.isActive)
          .toList();

      setState(() {
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
  void _submitForm() {
    // Validate form fields
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate plan selection
    if (_selectedPlan == null) {
      CustomSnackbar.showError(
        context,
        AppLocalizations.of(context)!.choosePlanToSubscribe,
      );
      return;
    }

    // Validate payment method selection
    if (_selectedPaymentMethod == null) {
      CustomSnackbar.showError(
        context,
        AppLocalizations.of(context)!.selectPaymentMethod,
      );
      return;
    }

    // Validate receipt image
    if (_receiptImageBase64 == null || _receiptImageBase64!.isEmpty) {
      CustomSnackbar.showError(
        context,
        AppLocalizations.of(context)!.uploadReceipt,
      );
      return;
    }

    // Create payment
    context.read<CreatePlanPaymentCubit>().createPayment(
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
    final localizations = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => CreatePlanPaymentCubit(
        context.read<PaymentRepository>(),
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          title: Text(
            localizations.createPayment,
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
          listener: (context, state) {
            if (state is CreatePlanPaymentSuccess) {
              CustomSnackbar.showSuccess(
                context,
                localizations.paymentCreatedSuccessfully,
              );
              // Navigate back to payment history
              context.go(Routes.paymentHistory);
            } else if (state is CreatePlanPaymentError) {
              CustomSnackbar.showError(context, state.message);
            }
          },
          child: _isLoadingData
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: EdgeInsets.all(AppSizes.padding(context)),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Plan selector
                        _buildPlanSelector(localizations),
                        SizedBox(height: AppSizes.spacing(context)),

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
                        BlocBuilder<CreatePlanPaymentCubit,
                            CreatePlanPaymentState>(
                          builder: (context, state) {
                            final isLoading = state is CreatePlanPaymentLoading;
                            return CustomButton(
                              text: localizations.submit,
                              onPressed: isLoading ? () {} : _submitForm,
                              isLoading: isLoading,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  /// Build plan selector dropdown
  Widget _buildPlanSelector(AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.plan,
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
          child: DropdownButtonFormField<PlanModel>(
            value: _selectedPlan,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              prefixIcon: Icon(Icons.card_membership, color: AppColors.textSecondary),
            ),
            hint: Text(
              localizations.choosePlanToSubscribe,
              style: const TextStyle(color: AppColors.textTertiary),
            ),
            items: _plans.map((plan) {
              return DropdownMenuItem<PlanModel>(
                value: plan,
                child: Text(
                  '${plan.name} - ${plan.price} ${localizations.amount}',
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedPlan = value;
                // Auto-fill amount with plan price
                if (value != null) {
                  _amountController.text = value.price.toString();
                }
              });
            },
          ),
        ),
      ],
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
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
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
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
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
}
