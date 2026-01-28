import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidsero_driver/core/network/api_service.dart';
import 'package:kidsero_driver/core/widgets/custom_empty_state.dart';
import 'package:kidsero_driver/features/plans/cubit/app_services_cubit.dart';
import 'package:kidsero_driver/features/payments/ui/widgets/service_card.dart';
import 'package:kidsero_driver/features/payments/ui/widgets/subscription_dialog.dart';
import 'package:kidsero_driver/l10n/app_localizations.dart';

class AppServicesTab extends StatelessWidget {
  const AppServicesTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AppServicesCubit(context.read<ApiService>())..loadAppServices(),
      child: const _AppServicesTabContent(),
    );
  }
}

class _AppServicesTabContent extends StatelessWidget {
  const _AppServicesTabContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Placeholder localization for service titles until added to ARB
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<AppServicesCubit, AppServicesState>(
      builder: (context, state) {
        if (state is AppServicesLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF9B59B6)),
          );
        }

        if (state is AppServicesError) {
          return CustomEmptyState(
            icon: Icons.error_outline,
            title: l10n.somethingWentWrong,
            message: state.message,
            onRefresh: () => context.read<AppServicesCubit>().loadAppServices(),
          );
        }

        if (state is AppServicesLoaded) {
          final hasSubscriptions = state.activeSubscriptions.isNotEmpty;
          final hasPlans = state.availablePlans.isNotEmpty;

          if (!hasSubscriptions && !hasPlans) {
            return CustomEmptyState(
              icon: Icons.design_services_outlined,
              title: l10n.noServicesAvailable,
              message: l10n.checkBackLater,
              onRefresh: () =>
                  context.read<AppServicesCubit>().loadAppServices(),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<AppServicesCubit>().loadAppServices(),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  l10n.activeServices,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 12),
                if (!hasSubscriptions)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.amber),
                        const SizedBox(height: 8),
                        Text(
                          l10n.noActiveSubscriptions,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.choosePlanToSubscribe,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber[900],
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...state.activeSubscriptions.map((sub) {
                    return ServiceCard(
                      title: l10n.servicePlan,
                      description: '${l10n.active} ${l10n.date} ${sub.endDate}',
                      priceLabel: l10n.active,
                      isSubscribed: true,
                      subscriptionStatus: sub.isActive
                          ? l10n.active.toUpperCase()
                          : l10n.inactive.toUpperCase(),
                      accentColor: const Color(0xFF9B59B6),
                    );
                  }).toList(),
                const SizedBox(height: 24),

                if (hasPlans) ...[
                  Text(
                    l10n.availableServices,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...state.availablePlans.map((plan) {
                    return ServiceCard(
                      title: plan.name,
                      description: 'Premium service plan',
                      priceLabel: '${plan.price} AED',
                      isSubscribed: false,
                      accentColor: const Color(0xFF9B59B6),
                      onTap: () async {
                        final result = await showDialog<bool>(
                          context: context,
                          builder: (_) => SubscriptionDialog(
                            title: plan.name,
                            amount: plan.price,
                            planId: plan.id,
                          ),
                        );
                        if (result == true) {
                          if (context.mounted) {
                            context.read<AppServicesCubit>().loadAppServices();
                          }
                        }
                      },
                    );
                  }).toList(),
                ],
              ],
            ),
          );
        }

        return const SizedBox();
      },
    );
  }
}
