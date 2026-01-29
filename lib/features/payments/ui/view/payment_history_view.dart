import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidsero_driver/core/network/api_service.dart';
import 'package:kidsero_driver/core/widgets/custom_empty_state.dart';
import 'package:kidsero_driver/features/plans/cubit/payment_cubit.dart';
import 'package:kidsero_driver/features/plans/cubit/payment_state.dart';
import 'package:kidsero_driver/features/plans/model/payment_model.dart';
import 'package:kidsero_driver/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          PaymentCubit(context.read<ApiService>())..getPayments(),
      child: const _PaymentHistoryContent(),
    );
  }
}

class _PaymentHistoryContent extends StatelessWidget {
  const _PaymentHistoryContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF9B59B6),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.payments,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF9B59B6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                ),
                tabs: [
                  Tab(text: l10n.appServices),
                  Tab(text: l10n.schoolServices),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<PaymentCubit, PaymentState>(
                builder: (context, state) {
                  if (state is PaymentLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF9B59B6),
                      ),
                    );
                  }

                  if (state is PaymentError) {
                    return CustomEmptyState(
                      icon: Icons.error_outline,
                      title: l10n.failedToLoadPayments,
                      message: state.message,
                      onRefresh: () =>
                          context.read<PaymentCubit>().getPayments(),
                    );
                  }

                  if (state is PaymentsLoaded) {
                    return TabBarView(
                      children: [
                        _buildPaymentList(context, state.payments, l10n, false),
                        _buildPaymentList(
                          context,
                          state.orgServicePayments,
                          l10n,
                          true,
                        ),
                      ],
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentList(
    BuildContext context,
    List<PaymentModel> payments,
    AppLocalizations l10n,
    bool isOrgService,
  ) {
    if (payments.isEmpty) {
      return CustomEmptyState(
        icon: Icons.history,
        title: l10n.noPaymentsFound,
        message: l10n.somethingWentWrong,
        onRefresh: () => context.read<PaymentCubit>().getPayments(),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<PaymentCubit>().getPayments(),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: payments.length,
        itemBuilder: (context, index) {
          final payment = payments[index];
          return _buildPaymentCard(context, payment, l10n, isOrgService);
        },
      ),
    );
  }

  Widget _buildPaymentCard(
    BuildContext context,
    PaymentModel payment,
    AppLocalizations l10n,
    bool isOrgService,
  ) {
    final bool isCompleted =
        payment.status.toLowerCase() == 'completed' ||
        payment.status.toLowerCase() == 'approved';
    final Color statusColor = isCompleted
        ? const Color(0xFF00BFA5)
        : const Color(0xFFFFB300);

    // Formatting date
    String formattedDate = '';
    try {
      final DateTime date = DateTime.parse(payment.createdAt);
      formattedDate = DateFormat('MMM dd, yyyy • hh:mm a').format(date);
    } catch (e) {
      formattedDate = payment.createdAt;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9B59B6).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_outlined,
                        color: Color(0xFF9B59B6),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${payment.amount} AED',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        if (isOrgService && payment.studentName != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            '${l10n.student}: ${payment.studentName}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF00BFA5),
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    payment.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
