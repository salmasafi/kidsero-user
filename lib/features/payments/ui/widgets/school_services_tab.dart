import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kidsero_driver/core/network/api_service.dart';
import 'package:kidsero_driver/core/routing/routes.dart';
import 'package:kidsero_driver/core/theme/app_colors.dart';
import 'package:kidsero_driver/core/widgets/custom_empty_state.dart';
import 'package:kidsero_driver/features/payments/ui/widgets/child_filter_bar.dart';
import 'package:kidsero_driver/features/payments/ui/widgets/service_card.dart';
import 'package:kidsero_driver/features/plans/cubit/school_services_cubit.dart';
import 'package:kidsero_driver/features/plans/model/org_service_model.dart';
import 'package:kidsero_driver/features/plans/model/student_subscription_model.dart';
import 'package:kidsero_driver/l10n/app_localizations.dart';
import 'package:kidsero_driver/features/children/model/child_model.dart';

class SchoolServicesTab extends StatelessWidget {
  const SchoolServicesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SchoolServicesCubit(context.read<ApiService>())..loadChildren(),
      child: const _SchoolServicesTabContent(),
    );
  }
}

class _SchoolServicesTabContent extends StatelessWidget {
  const _SchoolServicesTabContent();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<SchoolServicesCubit, SchoolServicesState>(
      builder: (context, state) {
        if (state is SchoolServicesLoading || state is SchoolServicesInitial) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state is SchoolServicesError) {
          return CustomEmptyState(
            icon: Icons.error_outline,
            title: l10n.somethingWentWrong,
            message: state.message,
            onRefresh: () => context.read<SchoolServicesCubit>().loadChildren(),
          );
        }

        if (state is SchoolServicesLoaded) {
          if (state.children.isEmpty) {
            return CustomEmptyState(
              icon: Icons.school_outlined,
              title: l10n.noSchoolServices,
              message: l10n.noServicesAvailable,
              onRefresh: () =>
                  context.read<SchoolServicesCubit>().loadChildren(),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<SchoolServicesCubit>().loadChildren(),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                ChildFilterBar<Child>(
                  label: l10n.filterByChild,
                  options: state.children
                      .map(
                        (child) => ChildFilterOption<Child>(
                          id: child.id,
                          label: child.name,
                          payload: child,
                        ),
                      )
                      .toList(),
                  selectedOptionId: state.selectedChild?.id,
                  onOptionSelected: (option) {
                    final child = option?.payload;
                    if (child != null) {
                      context.read<SchoolServicesCubit>().selectChild(child);
                    }
                  },
                  
                ),
                const SizedBox(height: 20),
                _SubscribedServicesSection(
                  subscriptions: state.activeSubscriptions,
                  servicesLookup: state.availableServices,
                  selectedChild: state.selectedChild,
                ),
                const SizedBox(height: 24),
                _AvailableServicesSection(
                  services: state.availableServices,
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _SubscribedServicesSection extends StatelessWidget {
  final List<StudentServiceSubscription> subscriptions;
  final List<OrgService> servicesLookup;
  final Child? selectedChild;

  const _SubscribedServicesSection({
    required this.subscriptions,
    required this.servicesLookup,
    required this.selectedChild,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filteredSubscriptions = selectedChild == null
        ? subscriptions
        : subscriptions
            .where((subscription) => subscription.studentId == selectedChild!.id)
            .toList();

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.schoolSubscribedServices,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (filteredSubscriptions.isEmpty)
            CustomEmptyState(
              icon: Icons.event_busy,
              title: l10n.noAppSubscriptions,
              message: l10n.chooseServiceToSubscribe,
            )
          else
            ...filteredSubscriptions.map((subscription) {
              final service = _findService(subscription.serviceId);
              final description = service?.serviceDescription ??
                  '${l10n.schoolService} • ${subscription.serviceId}';
              final price = _formatPrice(service?.finalPrice);

              return ServiceCard(
                title: service?.serviceName ?? l10n.schoolService,
                description:
                    '$description\n${l10n.active}: ${subscription.startDate} - ${subscription.endDate}',
                priceLabel: price,
                isSubscribed: true,
                subscriptionStatus: subscription.isActive
                    ? l10n.active.toUpperCase()
                    : l10n.inactive.toUpperCase(),
                accentColor: AppColors.accent,
              );
            }),
        ],
      ),
    );
  }

  OrgService? _findService(String serviceId) {
    try {
      return servicesLookup.firstWhere((service) => service.id == serviceId);
    } catch (_) {
      return null;
    }
  }

  String _formatPrice(num? value) {
    if (value == null) return '--';
    return '${value.toStringAsFixed(2)} AED';
  }
}

class _AvailableServicesSection extends StatelessWidget {
  final List<OrgService> services;

  const _AvailableServicesSection({required this.services});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.availableSchoolServices,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        if (services.isEmpty)
          CustomEmptyState(
            icon: Icons.design_services_outlined,
            title: l10n.noSchoolServices,
            message: l10n.noServicesForChild,
          )
        else
          ...services.map((service) {
            final price = '${service.finalPrice.toStringAsFixed(2)} AED';
            return ServiceCard(
              title: service.serviceName,
              description: service.serviceDescription,
              priceLabel: price,
              accentColor: AppColors.primary,
              buttonText: l10n.subscribeNow,
              onTap: () {
                final state = context.read<SchoolServicesCubit>().state;
                Child? selectedChild;
                if (state is SchoolServicesLoaded) {
                  selectedChild = state.selectedChild;
                }

                context.push(
                  Routes.createServicePayment,
                  extra: {
                    'service': service,
                    'student': selectedChild,
                  },
                );
              },
            );
          }),
      ],
    );
  }
}
