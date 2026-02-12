import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kidsero_driver/core/network/api_service.dart';
import 'package:kidsero_driver/core/theme/app_colors.dart';
import 'package:kidsero_driver/core/theme/app_sizes.dart';
import 'package:kidsero_driver/core/widgets/custom_button.dart';
import 'package:kidsero_driver/core/widgets/custom_snackbar.dart';
import 'package:kidsero_driver/features/children/model/child_model.dart';
import 'package:kidsero_driver/features/payments/data/models/payment_type.dart';
import 'package:kidsero_driver/features/payments/data/repositories/payment_repository.dart';
import 'package:kidsero_driver/features/payments/logic/cubit/create_service_payment_cubit.dart';
import 'package:kidsero_driver/features/payments/logic/cubit/create_service_payment_state.dart';
import 'package:kidsero_driver/features/payments/ui/widgets/installment_selector.dart';
import 'package:kidsero_driver/features/payments/ui/widgets/receipt_image_picker.dart';
import 'package:kidsero_driver/features/plans/model/org_service_model.dart';
import 'package:kidsero_driver/features/plans/model/payment_method_model.dart';
import 'package:kidsero_driver/l10n/app_localizations.dart';
import 'package:kidsero_driver/core/routing/routes.dart';

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
  const CreateServicePaymentScreen({super.key});

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

  List<OrgService> _services = [];
  List<Child> _students = [];
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
    _installmentController.dispose();
    super.dispose();
  }

  /// Load students, services, and payment methods
  Future<void> _loadInitialData() async {
    try {
      final apiService = context.read<ApiService>();

      // Load students (children)
      _students = await apiService.getChildren();

      // Load payment methods
      final paymentMethodsResponse = await apiService.getPaymentMethods();
      _paymentMethods = paymentMethodsResponse.paymentMethods
          .where((method) => method.isActive)
          .toList();

      // If there's at least one student, load services for the first student
      if (_students.isNotEmpty) {
        _selectedStudent = _students.first;
        await _loadServicesForStudent(_selectedStudent!.id);
      }

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

  /// Load services for a specific student
  Future<void> _loadServicesForStudent(String studentId) async {
    try {
      final apiService = context.read<ApiService>();
      final servicesResponse = await apiService.getOrgServices(studentId);
      setState(() {
        _services = servicesResponse.services;
        // Reset selected service when student changes
        _selectedService = null;
        _amountController.clear();
      });
    } catch (e) {
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
          _installmentError =
              AppLocalizations.of(context)!.installmentsRequired;
        });
        return false;
      }

      final installmentNumber = int.tryParse(installmentText);
      if (installmentNumber == null || installmentNumber <= 0) {
        setState(() {
          _installmentError =
              AppLocalizations.of(context)!.installmentsMustBePositive;
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
  void _submitForm() {
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
        context,
        AppLocalizations.of(context)!.chooseServiceToSubscribe,
      );
      return;
    }

    // Validate student selection
    if (_selectedStudent == null) {
      CustomSnackbar.showError(
        context,
        '${AppLocalizations.of(context)!.student} ${AppLocalizations.of(context)!.amountRequired.toLowerCase()}',
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
    context.read<CreateServicePaymentCubit>().createPayment(
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
    final localizations = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => CreateServicePaymentCubit(
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
        body: BlocListener<CreateServicePaymentCubit,
            CreateServicePaymentState>(
          listener: (context, state) {
            if (state is CreateServicePaymentSuccess) {
              CustomSnackbar.showSuccess(
                context,
                localizations.paymentCreatedSuccessfully,
              );
              // Navigate back to payment history
              context.go(Routes.paymentHistory);
            } else if (state is CreateServicePaymentError) {
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
                        // Student selector
                        _buildStudentSelector(localizations),
                        SizedBox(height: AppSizes.spacing(context)),

                        // Service selector
                        _buildServiceSelector(localizations),
                        SizedBox(height: AppSizes.spacing(context)),

                        // Payment method selector
                        _buildPaymentMethodSelector(localizations),
                        SizedBox(height: AppSizes.spacing(context)),

                        // Amount input
                        _buildAmountInput(localizations),
                        SizedBox(height: AppSizes.spacing(context)),

                        // Installment selector
                        InstallmentSelector(
                          selectedPaymentType: _selectedPaymentType,
                          onPaymentTypeChanged: (type) {
                            setState(() {
                              _selectedPaymentType = type;
                              _installmentError = null;
                              if (type == PaymentType.onetime) {
                                _installmentController.clear();
                              }
                            });
                          },
                          installmentController: _installmentController,
                          errorMessage: _installmentError,
                        ),
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
                        BlocBuilder<CreateServicePaymentCubit,
                            CreateServicePaymentState>(
                          builder: (context, state) {
                            final isLoading =
                                state is CreateServicePaymentLoading;
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

  /// Build student selector dropdown
  Widget _buildStudentSelector(AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.student,
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
          child: DropdownButtonFormField<Child>(
            value: _selectedStudent,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              prefixIcon: Icon(Icons.person, color: AppColors.textSecondary),
            ),
            hint: Text(
              localizations.student,
              style: const TextStyle(color: AppColors.textTertiary),
            ),
            items: _students.map((student) {
              return DropdownMenuItem<Child>(
                value: student,
                child: Text(
                  student.name,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              );
            }).toList(),
            onChanged: (value) async {
              if (value != null) {
                setState(() {
                  _selectedStudent = value;
                });
                // Load services for the selected student
                await _loadServicesForStudent(value.id);
              }
            },
          ),
        ),
      ],
    );
  }

  /// Build service selector dropdown
  Widget _buildServiceSelector(AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.service,
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
          child: DropdownButtonFormField<OrgService>(
            value: _selectedService,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              prefixIcon:
                  Icon(Icons.room_service, color: AppColors.textSecondary),
            ),
            hint: Text(
              _services.isEmpty
                  ? localizations.noServicesAvailable
                  : localizations.service,
              style: const TextStyle(color: AppColors.textTertiary),
            ),
            items: _services.map((service) {
              return DropdownMenuItem<OrgService>(
                value: service,
                child: Text(
                  '${service.serviceName} - ${service.finalPrice} ${localizations.amount}',
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              );
            }).toList(),
            onChanged: _services.isEmpty
                ? null
                : (value) {
                    setState(() {
                      _selectedService = value;
                      // Auto-fill amount with service price
                      if (value != null) {
                        _amountController.text = value.finalPrice.toString();
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
}
