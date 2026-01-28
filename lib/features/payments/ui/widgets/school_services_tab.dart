import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidsero_driver/core/network/api_service.dart';
import 'package:kidsero_driver/core/widgets/custom_empty_state.dart';
import 'package:kidsero_driver/features/plans/cubit/school_services_cubit.dart';
import 'package:kidsero_driver/features/payments/ui/widgets/service_card.dart';
import 'package:kidsero_driver/features/payments/ui/widgets/subscription_dialog.dart';
import 'package:kidsero_driver/l10n/app_localizations.dart';

class SchoolServicesTab extends StatelessWidget {
  const SchoolServicesTab({Key? key}) : super(key: key);

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
  const _SchoolServicesTabContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<SchoolServicesCubit, SchoolServicesState>(
      builder: (context, state) {
        if (state is SchoolServicesLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF00BFA5)),
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
              title: l10n.noChildrenFound,
              message: l10n.addChildrenToTrack,
            );
          }

          final hasSubscriptions = state.activeSubscriptions.isNotEmpty;
          final hasServices = state.availableServices.isNotEmpty;

          return Column(
            children: [
              // Child Selector
              if (state.children.length > 1)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  color: Colors.white,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: state.children.map((child) {
                        final isSelected = child.id == state.selectedChild?.id;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: ChoiceChip(
                            label: Text(child.name),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                context.read<SchoolServicesCubit>().selectChild(
                                  child,
                                );
                              }
                            },
                            selectedColor: const Color(
                              0xFF00BFA5,
                            ).withOpacity(0.2),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF00BFA5)
                                  : Colors.black,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

              Expanded(
                child: !hasSubscriptions && !hasServices
                    ? CustomEmptyState(
                        icon: Icons.school_outlined,
                        title: l10n.noSchoolServices,
                        message: l10n.noServicesForChild,
                        onRefresh: () =>
                            context.read<SchoolServicesCubit>().loadChildren(),
                      )
                    : RefreshIndicator(
                        onRefresh: () => context
                            .read<SchoolServicesCubit>()
                            .loadServicesForChild(
                              state.children,
                              state.selectedChild!,
                            ),
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
                                  border: Border.all(
                                    color: Colors.amber.withOpacity(0.3),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.info_outline,
                                      color: Colors.amber,
                                    ),
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
                                      l10n.chooseServiceToSubscribe,
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
                                  title: l10n.schoolService,
                                  description:
                                      '${l10n.active} ${l10n.date} ${sub.endDate}',
                                  priceLabel: l10n.active,
                                  isSubscribed: true,
                                  subscriptionStatus: sub.isActive
                                      ? l10n.active.toUpperCase()
                                      : l10n.inactive.toUpperCase(),
                                  accentColor: const Color(0xFF00BFA5),
                                );
                              }).toList(),
                            const SizedBox(height: 24),

                            if (hasServices) ...[
                              Text(
                                l10n.availableServices,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...state.availableServices.map((service) {
                                return ServiceCard(
                                  title: service.serviceName,
                                  description: service.serviceDescription,
                                  priceLabel: '${service.finalPrice} AED',
                                  isSubscribed: false,
                                  accentColor: const Color(0xFF00BFA5),
                                  onTap: () async {
                                    final result = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => SubscriptionDialog(
                                        title: service.serviceName,
                                        amount: service.finalPrice,
                                        serviceId: service.id,
                                        studentId: state.selectedChild?.id,
                                      ),
                                    );
                                    if (result == true) {
                                      if (context.mounted) {
                                        context
                                            .read<SchoolServicesCubit>()
                                            .loadServicesForChild(
                                              state.children,
                                              state.selectedChild!,
                                            );
                                      }
                                    }
                                  },
                                );
                              }).toList(),
                            ],
                          ],
                        ),
                      ),
              ),
            ],
          );
        }

        return const SizedBox();
      },
    );
  }
}
