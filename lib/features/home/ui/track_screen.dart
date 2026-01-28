import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidsero_driver/l10n/app_localizations.dart';
import 'package:kidsero_driver/core/network/api_service.dart';
import 'package:kidsero_driver/core/widgets/custom_empty_state.dart';
import 'package:kidsero_driver/features/rides/cubit/active_rides_cubit.dart';
import 'package:kidsero_driver/features/track_ride/ui/ride_tracking_screen.dart';

/// Track screen - shows active rides that can be tracked
class TrackScreen extends StatelessWidget {
  const TrackScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ActiveRidesCubit(context.read<ApiService>())..loadActiveRides(),
      child: const _TrackScreenContent(),
    );
  }
}

class _TrackScreenContent extends StatelessWidget {
  const _TrackScreenContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF9B59B6),
        elevation: 0,
        title: Text(
          l10n.track,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF9B59B6), Color(0xFF8E44AD)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: BlocBuilder<ActiveRidesCubit, ActiveRidesState>(
        builder: (context, state) {
          if (state is ActiveRidesLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF9B59B6)),
            );
          }

          if (state is ActiveRidesError) {
            return CustomEmptyState(
              icon: Icons.error_outline,
              title: l10n.errorLoadingRides,
              message: state.message,
              onRefresh: () =>
                  context.read<ActiveRidesCubit>().loadActiveRides(),
            );
          }

          if (state is ActiveRidesLoaded) {
            if (state.rides.isEmpty) {
              return CustomEmptyState(
                icon: Icons.location_off_outlined,
                title: l10n.noRidesToday, // Reusing appropriate key
                message: l10n.noRidesTodayDesc,
                onRefresh: () =>
                    context.read<ActiveRidesCubit>().loadActiveRides(),
              );
            }

            return RefreshIndicator(
              onRefresh: () =>
                  context.read<ActiveRidesCubit>().loadActiveRides(),
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: state.rides.length,
                itemBuilder: (context, index) {
                  final ride = state.rides[index];
                  return _buildActiveRideCard(context, ride, l10n);
                },
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildActiveRideCard(
    BuildContext context,
    dynamic ride,
    AppLocalizations l10n,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00BFA5), Color(0xFF00897B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00BFA5).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LIVE NOW badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.sensors, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        l10n.liveNow,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Child and ride info
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 18,
                  color: Colors.white70,
                ),
                const SizedBox(width: 6),
                Text(
                  ride.childName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Text(
                ride.rideName,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Driver info
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  backgroundImage:
                      ride.driverAvatar != null && ride.driverAvatar.isNotEmpty
                      ? NetworkImage(ride.driverAvatar)
                      : null,
                  child: ride.driverAvatar == null || ride.driverAvatar.isEmpty
                      ? const Icon(Icons.person, size: 18, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ride.driverName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      l10n.driver,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Track Live button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          RideTrackingScreen(rideId: ride.occurrenceId),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF00897B),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.navigation_rounded, size: 18),
                label: Text(
                  l10n.trackLive,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
