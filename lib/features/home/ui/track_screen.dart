import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as dev;
import 'package:kidsero_parent/l10n/app_localizations.dart';
import 'package:kidsero_parent/core/widgets/custom_empty_state.dart';
import 'package:kidsero_parent/core/widgets/language_toggle.dart';
import 'package:kidsero_parent/core/widgets/gradient_header.dart';
import 'package:kidsero_parent/core/widgets/tab_bar_widget.dart';
import 'package:kidsero_parent/core/widgets/ride_card.dart';
import 'package:kidsero_parent/features/rides/cubit/all_children_rides_cubit.dart';
import 'package:kidsero_parent/features/rides/data/rides_repository.dart';
import 'package:kidsero_parent/features/rides/models/api_models.dart';
import 'package:kidsero_parent/features/rides/ui/screens/ride_tracking_screen.dart';
import 'package:kidsero_parent/features/payments/ui/widgets/child_filter_bar.dart';
import 'package:kidsero_parent/core/routing/routes.dart';

import '../../../core/theme/app_colors.dart';

/// Track screen - shows rides for all children with filtering
class TrackScreen extends StatelessWidget {
  const TrackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AllChildrenRidesCubit(repository: context.read<RidesRepository>())
            ..loadAllChildrenRides(),
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
  String? _selectedChildId;
  int _selectedTabIndex = 1; // Default to Today tab

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<AllChildrenRidesCubit, AllChildrenRidesState>(
        builder: (context, state) {
          if (state is AllChildrenRidesLoading) {
            return Column(
              children: [
                _buildHeader(context, l10n, []),
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
              ],
            );
          }

          if (state is AllChildrenRidesError) {
            return Column(
              children: [
                _buildHeader(context, l10n, []),
                Expanded(
                  child: CustomEmptyState(
                    icon: Icons.error_outline,
                    title: l10n.errorLoadingRides,
                    message: state.message,
                    onRefresh: () =>
                        context.read<AllChildrenRidesCubit>().loadAllChildrenRides(),
                  ),
                ),
              ],
            );
          }

          if (state is AllChildrenRidesEmpty) {
            return Column(
              children: [
                _buildHeader(context, l10n, []),
                Expanded(
                  child: CustomEmptyState(
                    icon: Icons.location_off_outlined,
                    title: l10n.noRidesToday,
                    message: l10n.noRidesTodayDesc,
                    onRefresh: () =>
                        context.read<AllChildrenRidesCubit>().loadAllChildrenRides(),
                  ),
                ),
              ],
            );
          }

          if (state is AllChildrenRidesLoaded) {
            return _buildLoadedContent(context, state, l10n);
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildLoadedContent(
    BuildContext context,
    AllChildrenRidesLoaded state,
    AppLocalizations l10n,
  ) {
    final tabs = _getTabs(l10n);

    return Column(
      children: [
        // Header with child filter
        _buildHeader(context, l10n, state.children),
        
        // Tab bar
        AnimatedTabBar(
          tabs: tabs,
          selectedIndex: _selectedTabIndex,
          onTabSelected: (index) {
            setState(() {
              _selectedTabIndex = index;
            });
          },
        ),

        // Tab content
        Expanded(
          child: _buildTabContent(context, state, l10n),
        ),
      ],
    );
  }

  List<String> _getTabs(AppLocalizations l10n) => [
    l10n.history,
    l10n.today,
    l10n.upcoming,
  ];

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l10n,
    List<ChildWithRides> children,
  ) {
    return GradientHeader(
      showBackButton: false,
      gradientColors: const [AppColors.primary, AppColors.accent],
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                  IconButton(
                    onPressed: () {
                      context.read<AllChildrenRidesCubit>().refresh();
                    },
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 8),
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
          if (children.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildChildFilter(context, children, l10n),
          ],
        ],
      ),
    );
  }

  Widget _buildChildFilter(
    BuildContext context,
    List<ChildWithRides> children,
    AppLocalizations l10n,
  ) {
    return ChildFilterBar<ChildWithRides>(
      label: l10n.filterByChild,
      options: children
          .map(
            (child) => ChildFilterOption<ChildWithRides>(
              id: child.id,
              label: child.name,
              payload: child,
            ),
          )
          .toList(),
      selectedOptionId: _selectedChildId,
      onOptionSelected: (option) {
        setState(() {
          _selectedChildId = option?.id;
        });
      },
      showAllOption: true,
      allChipLabel: l10n.all,
    );
  }

  Widget _buildTabContent(
    BuildContext context,
    AllChildrenRidesLoaded state,
    AppLocalizations l10n,
  ) {
    switch (_selectedTabIndex) {
      case 0:
        return _buildHistoryTab(context, state, l10n);
      case 1:
        return _buildTodayTab(context, state, l10n);
      case 2:
        return _buildUpcomingTab(context, state, l10n);
      default:
        return const SizedBox();
    }
  }

  Widget _buildTodayTab(
    BuildContext context,
    AllChildrenRidesLoaded state,
    AppLocalizations l10n,
  ) {
    // Get all today rides for filtered children
    final allTodayRides = <TodayRideOccurrence>[];
    
    if (_selectedChildId == null) {
      // Show all children's rides
      for (final child in state.children) {
        allTodayRides.addAll(state.getRidesForChild(child.id));
      }
    } else {
      // Show only selected child's rides
      allTodayRides.addAll(state.getRidesForChild(_selectedChildId!));
    }

    dev.log('Today tab - Total rides: ${allTodayRides.length}', name: 'TrackScreen');
    
    // Print all rides in today tab
    for (int i = 0; i < allTodayRides.length; i++) {
      final ride = allTodayRides[i];
      dev.log('Today Ride $i: ID=${ride.occurrenceId}, Name=${ride.ride.name}, Status=${ride.status}, Type=${ride.ride.type}, Time=${ride.pickupTime}, IsActive=${ride.isActive}', 
              name: 'TrackScreen');
    }

    if (allTodayRides.isEmpty) {
      return CustomEmptyState(
        icon: Icons.today,
        title: l10n.noRidesToday,
        message: l10n.noRidesTodayDesc,
        onRefresh: () => context.read<AllChildrenRidesCubit>().refresh(),
      );
    }

    // Get active and non-active rides
    final activeRides = allTodayRides.where((ride) => ride.isActive).toList();
    final nonActiveRides = allTodayRides.where((ride) => !ride.isActive).toList();

    dev.log('Active: ${activeRides.length}, Non-active: ${nonActiveRides.length}', 
            name: 'TrackScreen');
    
    // Print active rides
    dev.log('=== ACTIVE RIDES ===', name: 'TrackScreen');
    for (int i = 0; i < activeRides.length; i++) {
      final ride = activeRides[i];
      dev.log('Active $i: ID=${ride.occurrenceId}, Name=${ride.ride.name}, Status=${ride.status}', 
              name: 'TrackScreen');
    }
    
    // Print non-active rides
    dev.log('=== NON-ACTIVE RIDES ===', name: 'TrackScreen');
    for (int i = 0; i < nonActiveRides.length; i++) {
      final ride = nonActiveRides[i];
      dev.log('Non-Active $i: ID=${ride.occurrenceId}, Name=${ride.ride.name}, Status=${ride.status}', 
              name: 'TrackScreen');
    }

    return RefreshIndicator(
      onRefresh: () => context.read<AllChildrenRidesCubit>().refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active ride cards (green) - show all active rides
            if (activeRides.isNotEmpty) ...[
              ...activeRides.map(
                (ride) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildActiveRideCard(context, ride, state, l10n),
                ),
              ),
              const SizedBox(height: 8),
            ],
            
            // Today's Scheduled Rides (non-active rides only)
            if (nonActiveRides.isNotEmpty) ...[
              Text(
                activeRides.isNotEmpty ? 'Scheduled Rides' : l10n.today,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
              ...nonActiveRides.map(
                (ride) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildTodayRideCard(context, ride, state, l10n),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab(
    BuildContext context,
    AllChildrenRidesLoaded state,
    AppLocalizations l10n,
  ) {
    // Get history rides
    final allHistoryRides = <TodayRideOccurrence>[];
    
    dev.log('=== HISTORY TAB DEBUG ===', name: 'TrackScreen');
    dev.log('Selected child ID: $_selectedChildId', name: 'TrackScreen');
    
    if (_selectedChildId == null) {
      dev.log('Checking all children for history rides', name: 'TrackScreen');
      for (final child in state.children) {
        final rides = state.getHistoryRidesForChild(child.id);
        dev.log('Child ${child.name} (${child.id}) has ${rides.length} history rides', 
                name: 'TrackScreen');
        
        for (int i = 0; i < rides.length; i++) {
          final ride = rides[i];
          dev.log('  Ride $i: Status=${ride.status}, IsCompleted=${ride.isCompleted}', 
                  name: 'TrackScreen');
        }
        
        allHistoryRides.addAll(rides);
      }
    } else {
      dev.log('Checking selected child $_selectedChildId for history rides', 
              name: 'TrackScreen');
      final rides = state.getHistoryRidesForChild(_selectedChildId!);
      dev.log('Selected child has ${rides.length} history rides', name: 'TrackScreen');
      
      for (int i = 0; i < rides.length; i++) {
        final ride = rides[i];
        dev.log('  Ride $i: Status=${ride.status}, IsCompleted=${ride.isCompleted}', 
                name: 'TrackScreen');
      }
      
      allHistoryRides.addAll(rides);
    }

    dev.log('Total history rides to display: ${allHistoryRides.length}', 
            name: 'TrackScreen');

    if (allHistoryRides.isEmpty) {
      dev.log('No history rides found - showing empty state', name: 'TrackScreen');
      return CustomEmptyState(
        icon: Icons.history,
        title: 'No History',
        message: 'Completed rides will appear here',
        onRefresh: () => context.read<AllChildrenRidesCubit>().refresh(),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<AllChildrenRidesCubit>().refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: allHistoryRides.length,
        itemBuilder: (context, index) {
          final ride = allHistoryRides[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildHistoryRideCard(context, ride, state, l10n),
          );
        },
      ),
    );
  }

  Widget _buildUpcomingTab(
    BuildContext context,
    AllChildrenRidesLoaded state,
    AppLocalizations l10n,
  ) {
    dev.log('=== UPCOMING TAB DEBUG ===', name: 'TrackScreen');
    
    if (state.upcomingRidesData == null) {
      dev.log('No upcoming rides data available', name: 'TrackScreen');
      return CustomEmptyState(
        icon: Icons.calendar_today,
        title: l10n.upcoming,
        message: 'No upcoming rides data available',
        onRefresh: () => context.read<AllChildrenRidesCubit>().refresh(),
      );
    }

    // Get upcoming rides for filtered children
    final allUpcomingRides = <UpcomingRide>[];
    
    if (_selectedChildId == null) {
      // Show all children's upcoming rides
      dev.log('Showing all children upcoming rides', name: 'TrackScreen');
      allUpcomingRides.addAll(state.allUpcomingRides);
    } else {
      // Show only selected child's upcoming rides
      dev.log('Showing upcoming rides for child: $_selectedChildId', name: 'TrackScreen');
      allUpcomingRides.addAll(state.getUpcomingRidesForChild(_selectedChildId!));
    }

    dev.log('Total upcoming rides to display: ${allUpcomingRides.length}', name: 'TrackScreen');

    if (allUpcomingRides.isEmpty) {
      return CustomEmptyState(
        icon: Icons.calendar_today,
        title: l10n.noUpcomingRides,
        message: l10n.noUpcomingRidesDesc,
        onRefresh: () => context.read<AllChildrenRidesCubit>().refresh(),
      );
    }

    // Group rides by date
    final ridesByDate = <String, List<UpcomingRide>>{};
    for (final dayRides in state.upcomingRidesData!.upcomingRides) {
      final dayRidesForFilter = dayRides.rides.where((ride) {
        if (_selectedChildId == null) return true;
        return ride.child.id == _selectedChildId;
      }).toList();
      
      if (dayRidesForFilter.isNotEmpty) {
        ridesByDate[dayRides.date] = dayRidesForFilter;
      }
    }

    return RefreshIndicator(
      onRefresh: () => context.read<AllChildrenRidesCubit>().refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: ridesByDate.length,
        itemBuilder: (context, index) {
          final date = ridesByDate.keys.elementAt(index);
          final rides = ridesByDate[date]!;
          final dayData = state.upcomingRidesData!.upcomingRides
              .firstWhere((d) => d.date == date);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date header
              Padding(
                padding: EdgeInsets.only(bottom: 12, top: index == 0 ? 0 : 8),
                child: Text(
                  '${dayData.dayName} - $date',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              // Rides for this date
              ...rides.map((ride) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildUpcomingRideCard(context, ride, state, l10n),
              )),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActiveRideCard(
    BuildContext context,
    TodayRideOccurrence ride,
    AllChildrenRidesLoaded state,
    AppLocalizations l10n,
  ) {
    // Find the child for this ride
    final child = _findChildForRide(ride, state);
    
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF10B981),
            Color(0xFF059669),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.3),
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
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
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
            
            // Child name if showing all children
            if (_selectedChildId == null && child != null) ...[
              Text(
                child.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
            ],
            
            // Ride name
            Row(
              children: [
                const Icon(Icons.location_on, size: 18, color: Colors.white70),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    ride.ride.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            
            // Route
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Text(
                ride.ride.type == 'morning'
                    ? '${l10n.home} → ${l10n.school}'
                    : '${l10n.school} → ${l10n.home}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Driver info and ETA
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.driver,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    Text(
                      ride.driver.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      l10n.eta,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    Text(
                      '5 min',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Tracking buttons
            Row(
              children: [
                Expanded(
                  child: _buildTrackingButton(
                    context: context,
                    label: l10n.liveTracking,
                    icon: Icons.navigation,
                    onTap: () {
                      context.push('${Routes.liveTracking}/${ride.occurrenceId}');
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RideTrackingScreenByOccurrence(
                            occurrenceId: ride.occurrenceId,
                          ),
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
    );
  }

  Widget _buildTodayRideCard(
    BuildContext context,
    TodayRideOccurrence ride,
    AllChildrenRidesLoaded state,
    AppLocalizations l10n,
  ) {
    return RideCard(
      time: ride.pickupTime,
      dateLabel: ride.ride.type == 'morning' ? l10n.morningRide : l10n.afternoonRide,
      rideName: ride.ride.name,
      routeDescription: ride.ride.type == 'morning'
          ? '${l10n.home} → ${l10n.school}'
          : '${l10n.school} → ${l10n.home}',
      driverName: ride.driver.name,
      driverAvatar: ride.driver.avatar,
      status: _mapStatus(ride.status),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RideTrackingScreenByOccurrence(
              occurrenceId: ride.occurrenceId,
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryRideCard(
    BuildContext context,
    TodayRideOccurrence ride,
    AllChildrenRidesLoaded state,
    AppLocalizations l10n,
  ) {
    return RideCard(
      time: ride.pickupTime,
      dateLabel: ride.ride.type == 'morning' ? l10n.morningRide : l10n.afternoonRide,
      rideName: ride.ride.name,
      routeDescription: ride.ride.type == 'morning'
          ? '${l10n.home} → ${l10n.school}'
          : '${l10n.school} → ${l10n.home}',
      driverName: ride.driver.name,
      driverAvatar: ride.driver.avatar,
      status: _mapStatus(ride.status),
      onTap: () {
        // Show error message for history rides - tracking not available
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.trackingNotAvailableForPastRides),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      },
    );
  }

  Widget _buildUpcomingRideCard(
    BuildContext context,
    UpcomingRide ride,
    AllChildrenRidesLoaded state,
    AppLocalizations l10n,
  ) {
    return RideCard(
      time: ride.pickupTime,
      dateLabel: ride.ride.type == 'morning' ? l10n.morningRide : l10n.afternoonRide,
      rideName: ride.ride.name,
      routeDescription: ride.ride.type == 'morning'
          ? '${l10n.home} → ${l10n.school}'
          : '${l10n.school} → ${l10n.home}',
      driverName: '', // Driver info not available in upcoming rides
      status: RideStatus.scheduled,
      onTap: () {
        // Navigate to ride details if needed
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RideTrackingScreenByOccurrence(
              occurrenceId: ride.occurrenceId,
            ),
          ),
        );
      },
    );
  }

  RideStatus _mapStatus(String status) {
    switch (status) {
      case 'in_progress':
      case 'started':
        return RideStatus.live;
      case 'scheduled':
        return RideStatus.scheduled;
      case 'completed':
        return RideStatus.completed;
      case 'cancelled':
        return RideStatus.cancelled;
      default:
        return RideStatus.scheduled;
    }
  }

  ChildWithRides? _findChildForRide(
    TodayRideOccurrence ride,
    AllChildrenRidesLoaded state,
  ) {
    for (final child in state.children) {
      final childRides = state.getRidesForChild(child.id);
      if (childRides.any((r) => r.occurrenceId == ride.occurrenceId)) {
        return child;
      }
    }
    return null;
  }

  Widget _buildTrackingButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: const Color(0xFF10B981),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
