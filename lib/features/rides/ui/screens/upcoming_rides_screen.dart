import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidsero_parent/l10n/app_localizations.dart';
import 'package:kidsero_parent/core/widgets/gradient_header.dart';
import 'package:kidsero_parent/core/widgets/ride_card.dart';
import 'package:kidsero_parent/core/widgets/custom_empty_state.dart';
import 'package:kidsero_parent/features/rides/cubit/upcoming_rides_cubit.dart';
import 'package:kidsero_parent/features/rides/data/rides_repository.dart';
import 'package:kidsero_parent/core/theme/app_colors.dart';
import '../../models/ride_models.dart';

/// Screen to display all upcoming rides sorted by date and time
class UpcomingRidesScreen extends StatelessWidget {
  const UpcomingRidesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ridesRepository = context.read<RidesRepository>();

    return BlocProvider(
      create: (context) => UpcomingRidesCubit(repository: ridesRepository)
        ..loadUpcomingRides(),
      child: const _UpcomingRidesView(),
    );
  }
}

class _UpcomingRidesView extends StatelessWidget {
  const _UpcomingRidesView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Gradient header
          GradientHeader(
            showBackButton: true,
            gradientColors: const [AppColors.primary, AppColors.accent],
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
            child: Row(
              children: [
                const Icon(
                  Icons.event,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.upcoming,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Filter button
                BlocBuilder<UpcomingRidesCubit, UpcomingRidesState>(
                  builder: (context, state) {
                    // Note: Date filtering functionality removed in new structure
                    // The new API provides grouped data by date automatically
                    
                    return IconButton(
                      icon: Stack(
                        children: [
                          const Icon(
                            Icons.filter_list,
                            color: Colors.white,
                            size: 24,
                          ),
                          if (state is UpcomingRidesLoaded && state.hasRides)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.orange,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                      onPressed: () => _showDateFilterDialog(context),
                    );
                  },
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: BlocBuilder<UpcomingRidesCubit, UpcomingRidesState>(
              builder: (context, state) {
                if (state is UpcomingRidesLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                }

                if (state is UpcomingRidesError) {
                  return CustomEmptyState(
                    icon: Icons.error_outline,
                    title: l10n.errorLoadingRides,
                    message: state.message,
                    onRefresh: () =>
                        context.read<UpcomingRidesCubit>().refresh(),
                  );
                }

                if (state is UpcomingRidesEmpty) {
                  return CustomEmptyState(
                    icon: Icons.event,
                    title: l10n.noUpcomingRides,
                    message: l10n.noUpcomingRidesDesc,
                    onRefresh: () =>
                        context.read<UpcomingRidesCubit>().refresh(),
                  );
                }

                if (state is UpcomingRidesLoaded) {
                  return _buildRidesList(context, state, l10n);
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRidesList(
    BuildContext context,
    UpcomingRidesLoaded state,
    AppLocalizations l10n,
  ) {
    // Use the new grouped data structure
    final dayRides = state.data.upcomingRides;
    
    // Sort dates chronologically
    final sortedDays = dayRides.toList()
      ..sort((a, b) {
        try {
          final dateA = DateTime.parse(a.date);
          final dateB = DateTime.parse(b.date);
          return dateA.compareTo(dateB);
        } catch (_) {
          // Fallback to string comparison if parsing fails
          return a.date.compareTo(b.date);
        }
      });

    return RefreshIndicator(
      onRefresh: () => context.read<UpcomingRidesCubit>().refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: sortedDays.length,
        itemBuilder: (context, index) {
          final dayRide = sortedDays[index];
          final ridesForDate = dayRide.rides;

          // Sort rides by time (morning first, then afternoon, then by pickup time)
          ridesForDate.sort((a, b) {
            // Morning rides come before afternoon rides
            final aPeriod = a.ride.type.toLowerCase();
            final bPeriod = b.ride.type.toLowerCase();
            
            if (aPeriod == 'morning' && bPeriod != 'morning') {
              return -1;
            }
            if (aPeriod != 'morning' && bPeriod == 'morning') {
              return 1;
            }
            
            // If both are same period, sort by pickup time
            return a.pickupTime.compareTo(b.pickupTime);
          });

          return _buildDayRidesCard(context, dayRide, ridesForDate, l10n);
        },
      ),
    );
  }

  Widget _buildDayRidesCard(
    BuildContext context,
    UpcomingDayRides dayRide,
    List<UpcomingRideInfo> rides,
    AppLocalizations l10n,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  dayRide.dayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                Text(
                  dayRide.date,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Rides list
            ...rides.map((ride) => _buildRideCard(context, ride, l10n)),
          ],
        ),
      ),
    );
  }

  Widget _buildRideCard(
    BuildContext context,
    UpcomingRideInfo ride,
    AppLocalizations l10n,
  ) {
    // Determine the ride status
    RideStatus status;
    switch (ride.ride.type.toLowerCase()) {
      case 'morning':
        status = RideStatus.scheduled;
        break;
      case 'afternoon':
        status = RideStatus.scheduled;
        break;
      default:
        status = RideStatus.scheduled;
    }

    // Format pickup time
    final time = ride.pickupTime;

    // Determine ride name
    final rideName = ride.ride.type.toLowerCase() == 'morning'
        ? l10n.morningRide
        : l10n.afternoonRide;

    final routeDescription = ride.pickupPointName;

    return RideCard(
      time: time,
      dateLabel: ride.child.name,
      rideName: rideName,
      routeDescription: routeDescription,
      driverName: 'Driver', // TODO: Add driver info to UpcomingRideInfo model
      status: status,
      onTap: () {
        // Navigate to ride details
        // TODO: Implement navigation
      },
    );
  }

  void _showDateFilterDialog(BuildContext context) {
    // Note: Date filtering functionality removed in new structure
    // The new API provides grouped data by date automatically
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Date filtering is now handled automatically by the API'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
