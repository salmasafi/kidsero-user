import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidsero_parent/l10n/app_localizations.dart';
import 'package:kidsero_parent/core/widgets/custom_empty_state.dart';
import 'package:kidsero_parent/core/widgets/language_toggle.dart';
import 'package:kidsero_parent/features/rides/cubit/rides_dashboard_cubit.dart';
import 'package:kidsero_parent/features/rides/data/rides_repository.dart';

import '../../../core/theme/app_colors.dart';

/// Track screen - shows active rides that can be tracked
class TrackScreen extends StatelessWidget {
  const TrackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RidesDashboardCubit(
        repository: context.read<RidesRepository>(),
      )..loadDashboard(),
      child: const _TrackScreenContent(),
    );
  }
}

class _TrackScreenContent extends StatefulWidget {
  const _TrackScreenContent();

  @override
  State<_TrackScreenContent> createState() => _TrackScreenContentState();
}

class _TrackScreenContentState extends State<_TrackScreenContent> {
  @override
  void initState() {
    super.initState();
    // Auto-refresh is disabled - only manual refresh available
  }

  @override
  void dispose() {
    // No auto-refresh to stop
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<RidesDashboardCubit, RidesDashboardState>(
        builder: (context, state) {
          if (state is RidesDashboardLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is RidesDashboardError) {
            return Column(
              children: [
                _buildHeader(context, l10n),
                Expanded(
                  child: CustomEmptyState(
                    icon: Icons.error_outline,
                    title: l10n.errorLoadingRides,
                    message: state.message,
                    onRefresh: () =>
                        context.read<RidesDashboardCubit>().loadDashboard(),
                  ),
                ),
              ],
            );
          }

          if (state is RidesDashboardEmpty) {
            return Column(
              children: [
                _buildHeader(context, l10n),
                Expanded(
                  child: CustomEmptyState(
                    icon: Icons.location_off_outlined,
                    title: l10n.noRidesToday,
                    message: l10n.noRidesTodayDesc,
                    onRefresh: () =>
                        context.read<RidesDashboardCubit>().loadDashboard(),
                  ),
                ),
              ],
            );
          }

          if (state is RidesDashboardLoaded) {
            if (state.activeRidesCount == 0) {
              return Column(
                children: [
                  _buildHeader(context, l10n),
                  Expanded(
                    child: CustomEmptyState(
                      icon: Icons.location_off_outlined,
                      title: l10n.noRidesToday,
                      message: l10n.noRidesTodayDesc,
                      onRefresh: () =>
                          context.read<RidesDashboardCubit>().loadDashboard(),
                    ),
                  ),
                ],
              );
            }

            return RefreshIndicator(
              onRefresh: () =>
                  context.read<RidesDashboardCubit>().loadDashboard(),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader(context, l10n)),
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverToBoxAdapter(
                      child: CustomEmptyState(
                        icon: Icons.directions_bus,
                        title: 'Active Rides',
                        message: 'You have ${state.activeRidesCount} active ride(s). Tracking coming soon.',
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.parentGradient,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.track,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  // Refresh button
                  IconButton(
                    onPressed: () {
                      context.read<RidesDashboardCubit>().refreshActiveRides();
                    },
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Language button
                  IconButton(
                    onPressed: () => showLanguageDialog(context),
                    icon: const Icon(
                      Icons.translate,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
