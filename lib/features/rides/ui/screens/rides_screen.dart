import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidsero_driver/core/widgets/stat_card.dart';
import 'package:kidsero_driver/core/widgets/child_card.dart';
import 'package:kidsero_driver/core/widgets/custom_empty_state.dart';
import 'package:kidsero_driver/l10n/app_localizations.dart';
import 'package:kidsero_driver/core/widgets/language_toggle.dart';

import '../../../../core/network/api_service.dart';
import '../../../track_ride/ui/ride_tracking_screen.dart';
import '../../../track_ride/ui/live_tracking_screen.dart';
import '../../cubit/active_rides_cubit.dart';
import '../../cubit/ride_cubit.dart';
import '../../cubit/upcoming_rides_cubit.dart';
import 'child_schedule_screen.dart';

/// Main Rides Dashboard Screen matching the new UI design
class RidesScreen extends StatelessWidget {
  const RidesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = context.read<ApiService>();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              RideCubit(apiService: apiService)..loadChildrenRides(),
        ),
        BlocProvider(
          create: (context) => ActiveRidesCubit(apiService)..loadActiveRides(),
        ),
        BlocProvider(
          create: (context) =>
              UpcomingRidesCubit(apiService)..loadUpcomingRides(),
        ),
      ],
      child: const _RidesDashboard(),
    );
  }
}

class _RidesDashboard extends StatelessWidget {
  const _RidesDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<RideCubit>().loadChildrenRides();
          context.read<ActiveRidesCubit>().loadActiveRides();
          context.read<UpcomingRidesCubit>().loadUpcomingRides();
        },
        child: CustomScrollView(
          slivers: [
            // Header with user greeting and stats
            SliverToBoxAdapter(child: _buildHeader(context, l10n)),

            // My Children section
            SliverToBoxAdapter(child: _buildMyChildrenSection(context, l10n)),

            // Add some bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF9B59B6), // Purple
            Color(0xFF8E44AD), // Darker purple
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row with greeting and notification
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // User avatar
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00BFA5),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getGreeting(l10n),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                          Text(
                            l10n.welcomeBack,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Language button
                      GestureDetector(
                        onTap: () => showLanguageDialog(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            Localizations.localeOf(context).languageCode == 'ar'
                                ? 'A'
                                : 'E',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Notification bell
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Stats cards
              Row(
                children: [
                  // Children count card
                  BlocBuilder<RideCubit, RideState>(
                    builder: (context, state) {
                      int childrenCount = 0;
                      if (state is ChildrenRidesLoaded) {
                        childrenCount = state.children.length;
                      }
                      return StatCard(
                        icon: Icons.people_outline,
                        value: childrenCount.toString(),
                        label: l10n.children,
                        backgroundColor: Colors.white.withOpacity(0.15),
                      );
                    },
                  ),

                  const SizedBox(width: 12),

                  // Live rides card - expanded
                  Expanded(
                    child: BlocBuilder<ActiveRidesCubit, ActiveRidesState>(
                      builder: (context, state) {
                        int liveCount = 0;
                        if (state is ActiveRidesLoaded) {
                          liveCount = state.rides.length;
                        }
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00BFA5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.sensors,
                                    size: 24,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    liveCount.toString(),
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTrackingButton(
                                      context: context,
                                      label: l10n.liveTracking,
                                      icon: Icons.map_outlined,
                                      onTap: () {
                                        if (state is ActiveRidesLoaded &&
                                            state.rides.isNotEmpty) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  LiveTrackingScreen(
                                                    rideId: state
                                                        .rides
                                                        .first
                                                        .occurrenceId,
                                                  ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildTrackingButton(
                                      context: context,
                                      label: l10n.timelineTracking,
                                      icon: Icons.timeline,
                                      onTap: () {
                                        if (state is ActiveRidesLoaded &&
                                            state.rides.isNotEmpty) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  RideTrackingScreen(
                                                    rideId: state
                                                        .rides
                                                        .first
                                                        .occurrenceId,
                                                  ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
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

  Widget _buildMyChildrenSection(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.myChildren,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          BlocBuilder<RideCubit, RideState>(
            builder: (context, state) {
              if (state is RideLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(color: Color(0xFF9B59B6)),
                  ),
                );
              }

              if (state is RideEmpty) {
                return CustomEmptyState(
                  icon: Icons.child_care,
                  title: l10n.noChildrenFound,
                  message: l10n.addChildrenToTrack,
                  onRefresh: () =>
                      context.read<RideCubit>().loadChildrenRides(),
                );
              }

              if (state is RideError) {
                return CustomEmptyState(
                  icon: Icons.error_outline,
                  title: l10n.failedToLoadChildren,
                  message: state.message,
                  onRefresh: () =>
                      context.read<RideCubit>().loadChildrenRides(),
                );
              }

              if (state is ChildrenRidesLoaded) {
                return SizedBox(
                  height: 190,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.children.length,
                    itemBuilder: (context, index) {
                      final child = state.children[index];
                      final colors = [
                        const Color(0xFF9B59B6),
                        const Color(0xFF00BFA5),
                        const Color(0xFFE91E63),
                        const Color(0xFF3498DB),
                      ];

                      return Padding(
                        padding: EdgeInsets.only(
                          right: index < state.children.length - 1 ? 12 : 0,
                        ),
                        child: ChildCard(
                          name: child.name,
                          avatarUrl: child.avatar,
                          initials: _getInitials(child.name),
                          grade: child.grade ?? 'N/A',
                          classroom: child.classroom ?? 'N/A',
                          isOnline: _hasActiveRide(context, child.id),
                          avatarColor: colors[index % colors.length],
                          onViewSchedule: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) => RepositoryProvider.value(
                                  value: context.read<ApiService>(),
                                  child: ChildScheduleScreen(
                                    childId: child.id,
                                    childName: child.name,
                                    childAvatar: child.avatar,
                                    initials: _getInitials(child.name),
                                    grade: child.grade ?? 'N/A',
                                    classroom: child.classroom ?? 'N/A',
                                    avatarColor: colors[index % colors.length],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              }

              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }

  String _getGreeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return l10n.goodMorning;
    } else if (hour < 17) {
      return l10n.goodAfternoon;
    } else {
      return l10n.goodEvening;
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  bool _hasActiveRide(BuildContext context, String childId) {
    try {
      final activeState = context.read<ActiveRidesCubit>().state;
      if (activeState is ActiveRidesLoaded) {
        // Check if there's an active ride for this child
        return activeState.rides.any(
          (ride) => true,
        ); // Simplified - you can add proper child matching
      }
    } catch (e) {
      // Cubit might not be available
    }
    return false;
  }

  Widget _buildTrackingButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
