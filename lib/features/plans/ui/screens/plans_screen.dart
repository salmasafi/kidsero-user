import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidsero_parent/core/network/api_service.dart';
import 'package:kidsero_parent/features/plans/cubit/plans_cubit.dart';
import 'package:kidsero_parent/features/plans/model/plans_model.dart';
import 'package:kidsero_parent/l10n/app_localizations.dart';
import 'package:kidsero_parent/core/utils/price_utils.dart';
import '../../../../core/theme/app_colors.dart';

class PlansScreen extends StatelessWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Inject the Cubit here
    return BlocProvider(
      create: (context) => PlansCubit(context.read<ApiService>())..fetchPlans(),
      child: Scaffold(
        backgroundColor: Colors.grey[50], // Light background makes cards pop
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 60,
                floating: false,
                pinned: true,

                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    l10n.appServices,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                    ),
                  ),
                ),
              ),
            ];
          },
          body: BlocBuilder<PlansCubit, PlansState>(
            builder: (context, state) {
              final l10n = AppLocalizations.of(context)!;
              if (state is PlansLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is PlansError) {
                return Center(
                  child: Text(
                    state.message,
                    style: const TextStyle(color: AppColors.error),
                  ),
                );
              } else if (state is PlansLoaded) {
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  itemCount: state.plans.length,
                  separatorBuilder: (c, i) => const SizedBox(height: 20),
                  itemBuilder: (context, index) {
                    return _buildPlanCard(context, state.plans[index], l10n);
                  },
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context,
    PlanModel plan,
    AppLocalizations l10n,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // Decorative Top Strip
            Container(
              height: 6,
              width: double.infinity,
              color: AppColors.primary,
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Plan Name
                  Text(
                    plan.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Price with RichText for emphasis
                  Text(
                    formatPrice(plan.price),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Divider(color: AppColors.border, thickness: 1),
                  const SizedBox(height: 24),

                  // Info Rows with Icons
                  _infoRow(
                    icon: Icons.receipt_long_rounded,
                    label: l10n.subscriptionFees,
                    value: formatPrice(plan.subscriptionFees),
                  ),
                  const SizedBox(height: 16),
                  _infoRow(
                    icon: Icons.savings_outlined,
                    label: l10n.minPayment,
                    value: formatPrice(plan.minSubscriptionFeesPay),
                  ),

                  const SizedBox(height: 32),

                  // Call to Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle Subscribe Action
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "Choose Plan",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}