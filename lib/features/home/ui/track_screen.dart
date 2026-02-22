import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidsero_parent/l10n/app_localizations.dart';
import 'package:kidsero_parent/core/widgets/custom_empty_state.dart';
import 'package:kidsero_parent/core/widgets/language_toggle.dart';
import 'package:kidsero_parent/core/widgets/ride_card.dart';
import 'package:kidsero_parent/features/rides/cubit/active_rides_cubit.dart';
import 'package:kidsero_parent/features/rides/data/rides_repository.dart';
import 'package:kidsero_parent/features/rides/models/ride_models.dart';
import 'package:kidsero_parent/features/rides/ui/screens/ride_tracking_screen.dart';
import 'package:kidsero_parent/features/rides/ui/screens/live_tracking_screen.dart';

import '../../../core/theme/app_colors.dart';

/// Track screen - shows active rides that can be tracked
class TrackScreen extends StatelessWidget {
  const TrackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ActiveRidesCubit(
        repository: context.read<RidesRepository>(),
      )..loadActiveRides(),
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
    // Stop auto-refresh when screen is disposed
    context.read<ActiveRidesCubit>().stopAutoRefresh();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<ActiveRidesCubit, ActiveRidesState>(
        builder: (context, state) {
          if (state is ActiveRidesLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is ActiveRidesError) {
            return Column(
              children: [
                _buildHeader(context, l10n),
                Expanded(
                  child: CustomEmptyState(
                    icon: Icons.error_outline,
                    title: l10n.errorLoadingRides,
                    message: state.message,
                    onRefresh: () =>
                        context.read<ActiveRidesCubit>().loadActiveRides(),
                  ),
                ),
              ],
            );
          }

          if (state is ActiveRidesEmpty) {
            return Column(
              children: [
                _buildHeader(context, l10n),
                Expanded(
                  child: CustomEmptyState(
                    icon: Icons.location_off_outlined,
                    title: l10n.noRidesToday,
                    message: l10n.noRidesTodayDesc,
                    onRefresh: () =>
                        context.read<ActiveRidesCubit>().loadActiveRides(),
                  ),
                ),
              ],
            );
          }

          if (state is ActiveRidesLoaded) {
            if (state.rides.isEmpty) {
              return Column(
                children: [
                  _buildHeader(context, l10n),
                  Expanded(
                    child: CustomEmptyState(
                      icon: Icons.location_off_outlined,
                      title: l10n.noRidesToday,
                      message: l10n.noRidesTodayDesc,
                      onRefresh: () =>
                          context.read<ActiveRidesCubit>().loadActiveRides(),
                    ),
                  ),
                ],
              );
            }

            return RefreshIndicator(
              onRefresh: () =>
                  context.read<ActiveRidesCubit>().loadActiveRides(),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader(context, l10n)),
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final ride = state.rides[index];
                        return _buildActiveRideCard(context, ride, l10n);
                      }, childCount: state.rides.length),
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
                      context.read<ActiveRidesCubit>().refresh();
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

  Widget _buildActiveRideCard(
    BuildContext context,
    ActiveRide ride,
    AppLocalizations l10n,
  ) {
    return RideCard(
      time: '--:--',
      dateLabel: l10n.today,
      rideName: ride.childName,
      routeDescription: ride.bus?.plateNumber ?? 'Bus',
      driverName: ride.driver?.name ?? l10n.driver,
      driverAvatar: ride.driver?.avatar,
      status: RideStatus.live,
      eta: ride.estimatedArrival,
      onTrackLive: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LiveTrackingScreen(rideId: ride.rideId),
          ),
        );
      },
      onTrackTimeline: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RideTrackingScreen(rideId: ride.rideId),
          ),
        );
      },
    );
  }
}
