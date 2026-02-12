import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kidsero_driver/core/network/api_service.dart';
import 'package:kidsero_driver/core/theme/app_colors.dart';
import 'package:kidsero_driver/core/widgets/custom_empty_state.dart';
import 'package:kidsero_driver/core/widgets/custom_loading.dart';
import 'package:kidsero_driver/features/payments/data/models/service_payment_model.dart';
import 'package:kidsero_driver/features/payments/data/repositories/payment_repository.dart';
import 'package:kidsero_driver/features/payments/logic/cubit/payment_history_cubit.dart';
import 'package:kidsero_driver/features/payments/logic/cubit/payment_history_state.dart';
import 'package:kidsero_driver/features/payments/ui/widgets/payment_list_item.dart';
import 'package:kidsero_driver/l10n/app_localizations.dart';
import 'package:kidsero_driver/core/routing/routes.dart';

/// Payment History Screen
/// 
/// Displays a list of all parent payments organized into tabs
/// for app services and school services. Supports pull-to-refresh,
/// loading states, error states, and navigation to payment details.
class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PaymentHistoryCubit(
        PaymentRepository(context.read<ApiService>()),
      )..loadPayments(),
      child: const _PaymentHistoryContent(),
    );
  }
}

class _PaymentHistoryContent extends StatefulWidget {
  const _PaymentHistoryContent();

  @override
  State<_PaymentHistoryContent> createState() => _PaymentHistoryContentState();
}

class _PaymentHistoryContentState extends State<_PaymentHistoryContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedStudentId;
  List<String> _uniqueStudents = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _extractUniqueStudents(List<ServicePaymentModel> servicePayments) {
    final students = <String>{};
    for (final payment in servicePayments) {
      if (payment.student?.name != null) {
        students.add(payment.student!.name);
      } else if (payment.studentId.isNotEmpty) {
        students.add(payment.studentId);
      }
    }
    _uniqueStudents = students.toList()..sort();
  }

  List<ServicePaymentModel> _filterServicePayments(List<ServicePaymentModel> payments) {
    if (_selectedStudentId == null || _selectedStudentId!.isEmpty) {
      return payments;
    }
    
    return payments.where((payment) {
      final studentName = payment.student?.name ?? payment.studentId;
      return studentName == _selectedStudentId;
    }).toList();
  }

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
          l10n.paymentHistory,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 15,
              ),
              tabs: [
                Tab(text: l10n.appServices),
                Tab(text: l10n.schoolServices),
              ],
            ),
          ),
        ),
      ),
      body: BlocBuilder<PaymentHistoryCubit, PaymentHistoryState>(
        builder: (context, state) {
          // Loading state
          if (state is PaymentHistoryLoading) {
            return const CustomLoading();
          }

          // Error state
          if (state is PaymentHistoryError) {
            return Center(
              child: CustomEmptyState(
                icon: Icons.error_outline,
                title: l10n.failedToLoadPayments,
                message: state.message,
                actionLabel: l10n.retry,
                onRefresh: () => context.read<PaymentHistoryCubit>().refresh(),
              ),
            );
          }

          // Loaded state
          if (state is PaymentHistoryLoaded) {
            final hasAnyPayments = state.planPayments.isNotEmpty || 
                                   state.servicePayments.isNotEmpty;

            // Extract unique students for filtering
            _extractUniqueStudents(state.servicePayments);

            // Empty state - no payments at all
            if (!hasAnyPayments) {
              return RefreshIndicator(
                onRefresh: () => context.read<PaymentHistoryCubit>().refresh(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height - 200,
                    child: CustomEmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: l10n.noPaymentsFound,
                      message: l10n.somethingWentWrong,
                      onRefresh: () => context.read<PaymentHistoryCubit>().refresh(),
                    ),
                  ),
                ),
              );
            }

            // Display payments in tabs
            return TabBarView(
              controller: _tabController,
              children: [
                // App Services Tab (Plan Payments)
                _buildPaymentsList(
                  context,
                  state.planPayments,
                  l10n.noPlanPayments,
                  l10n.noPlanPaymentsDesc,
                  isPlanPayment: true,
                ),
                // School Services Tab (Service Payments) with student filter
                _buildSchoolServicesTab(
                  context,
                  state.servicePayments,
                  l10n.noServicePayments,
                  l10n.noServicePaymentsDesc,
                ),
              ],
            );
          }

          // Initial state
          return const SizedBox.shrink();
        },
      ),
    );
  }

  /// Build school services tab with student filter
  Widget _buildSchoolServicesTab(
    BuildContext context,
    List<ServicePaymentModel> servicePayments,
    String emptyTitle,
    String emptyDescription,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final filteredPayments = _filterServicePayments(servicePayments);
    
    if (filteredPayments.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => context.read<PaymentHistoryCubit>().refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 200,
            child: _buildEmptySection(emptyTitle, emptyDescription),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Student Filter Chips
        Container(
          margin: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
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
            children: [
              Text(
                l10n.student,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // "All" chip
                  FilterChip(
                    label: Text(
                      'All',
                      style: TextStyle(
                        color: _selectedStudentId == null ? Colors.white : Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    selected: _selectedStudentId == null,
                    onSelected: (selected) {
                      setState(() {
                        _selectedStudentId = null;
                      });
                    },
                    backgroundColor: _selectedStudentId == null ? AppColors.primary : Colors.grey.shade100,
                    selectedColor: AppColors.primary,
                    checkmarkColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: _selectedStudentId == null ? AppColors.primary : Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                  ),
                  
                  // Student chips
                  ..._uniqueStudents.map((student) => FilterChip(
                    label: Text(
                      student,
                      style: TextStyle(
                        color: _selectedStudentId == student ? Colors.white : Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    selected: _selectedStudentId == student,
                    onSelected: (selected) {
                      setState(() {
                        _selectedStudentId = selected ? student : null;
                      });
                    },
                    backgroundColor: _selectedStudentId == student ? AppColors.primary : Colors.grey.shade100,
                    selectedColor: AppColors.primary,
                    checkmarkColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: _selectedStudentId == student ? AppColors.primary : Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                  )),
                ],
              ),
            ],
          ),
        ),
        
        // Payments List
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => context.read<PaymentHistoryCubit>().refresh(),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: filteredPayments.map((payment) => PaymentListItem(
                payment: payment,
                onTap: () {
                  context.push(
                    Routes.paymentDetail,
                    extra: {
                      'paymentId': payment.id,
                      'isPlanPayment': false,
                    },
                  );
                },
              )).toList(),
            ),
          ),
        ),
      ],
    );
  }

  /// Build payments list for a tab
  Widget _buildPaymentsList(
    BuildContext context,
    List<dynamic> payments,
    String emptyTitle,
    String emptyDescription, {
    required bool isPlanPayment,
  }) {
    if (payments.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => context.read<PaymentHistoryCubit>().refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 200,
            child: _buildEmptySection(emptyTitle, emptyDescription),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<PaymentHistoryCubit>().refresh(),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: payments.map((payment) => PaymentListItem(
          payment: payment,
          onTap: () {
            context.push(
              Routes.paymentDetail,
              extra: {
                'paymentId': payment.id,
                'isPlanPayment': isPlanPayment,
              },
            );
          },
        )).toList(),
      ),
    );
  }

  /// Build empty section widget
  Widget _buildEmptySection(String title, String description) {
    return Container(
      padding: const EdgeInsets.all(24),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
