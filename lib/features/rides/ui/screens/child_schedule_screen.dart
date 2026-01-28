import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidsero_driver/l10n/app_localizations.dart';
import 'package:kidsero_driver/core/network/api_service.dart';
import 'package:kidsero_driver/core/widgets/gradient_header.dart';
import 'package:kidsero_driver/core/widgets/tab_bar_widget.dart';
import 'package:kidsero_driver/core/widgets/ride_card.dart';
import 'package:kidsero_driver/core/widgets/custom_empty_state.dart';
import 'package:kidsero_driver/features/rides/cubit/child_rides_cubit.dart';
import 'package:kidsero_driver/features/track_ride/ui/ride_tracking_screen.dart';

/// Screen to display a child's ride schedule with Today/Upcoming/History tabs
class ChildScheduleScreen extends StatelessWidget {
  final String childId;
  final String childName;
  final String? childAvatar;
  final String initials;
  final String grade;
  final String classroom;
  final Color avatarColor;

  const ChildScheduleScreen({
    Key? key,
    required this.childId,
    required this.childName,
    this.childAvatar,
    required this.initials,
    required this.grade,
    required this.classroom,
    this.avatarColor = const Color(0xFF9B59B6),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChildRidesCubit(
        apiService: context.read<ApiService>(),
        childId: childId,
      )..loadRides(),
      child: _ChildScheduleView(
        childName: childName,
        childAvatar: childAvatar,
        initials: initials,
        grade: grade,
        classroom: classroom,
        avatarColor: avatarColor,
      ),
    );
  }
}

class _ChildScheduleView extends StatefulWidget {
  final String childName;
  final String? childAvatar;
  final String initials;
  final String grade;
  final String classroom;
  final Color avatarColor;

  const _ChildScheduleView({
    Key? key,
    required this.childName,
    this.childAvatar,
    required this.initials,
    required this.grade,
    required this.classroom,
    required this.avatarColor,
  }) : super(key: key);

  @override
  State<_ChildScheduleView> createState() => _ChildScheduleViewState();
}

class _ChildScheduleViewState extends State<_ChildScheduleView> {
  int _selectedTabIndex = 0;

  List<String> _getTabs(AppLocalizations l10n) => [
    l10n.today,
    l10n.upcoming,
    l10n.history,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tabs = _getTabs(l10n);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // Gradient header with child info
          _buildHeader(context, l10n),

          // Tab bar
          const SizedBox(height: 16),
          AnimatedTabBar(
            tabs: tabs,
            selectedIndex: _selectedTabIndex,
            onTabSelected: (index) {
              setState(() {
                _selectedTabIndex = index;
              });
            },
            selectedColor: const Color(0xFF9B59B6),
          ),

          // Content based on selected tab
          Expanded(
            child: BlocBuilder<ChildRidesCubit, ChildRidesState>(
              builder: (context, state) {
                if (state is ChildRidesLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF9B59B6)),
                  );
                }

                if (state is ChildRidesError) {
                  return CustomEmptyState(
                    icon: Icons.error_outline,
                    title: l10n.errorLoadingRides,
                    message: state.message,
                    onRefresh: () =>
                        context.read<ChildRidesCubit>().loadRides(),
                  );
                }

                if (state is ChildRidesLoaded) {
                  return _buildTabContent(context, state, l10n);
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return GradientHeader(
      showBackButton: true,
      gradientColors: const [Color(0xFF9B59B6), Color(0xFF8E44AD)],
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
      child: Row(
        children: [
          // Child avatar
          CircleAvatar(
            radius: 28,
            backgroundColor: widget.avatarColor,
            backgroundImage:
                widget.childAvatar != null && widget.childAvatar!.isNotEmpty
                ? NetworkImage(widget.childAvatar!)
                : null,
            child: widget.childAvatar == null || widget.childAvatar!.isEmpty
                ? Text(
                    widget.initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          // Child info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.childName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.grade} • ${widget.classroom}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(
    BuildContext context,
    ChildRidesLoaded state,
    AppLocalizations l10n,
  ) {
    switch (_selectedTabIndex) {
      case 0:
        return _buildTodayTab(context, state, l10n);
      case 1:
        return _buildUpcomingTab(context, state, l10n);
      case 2:
        return _buildHistoryTab(context, state, l10n);
      default:
        return const SizedBox();
    }
  }

  Widget _buildTodayTab(
    BuildContext context,
    ChildRidesLoaded state,
    AppLocalizations l10n,
  ) {
    final hasLiveRide = state.liveRide != null;
    final todayRides = state.todayRides;

    if (!hasLiveRide && todayRides.isEmpty) {
      return CustomEmptyState(
        icon: Icons.today,
        title: l10n.noRidesToday,
        message: l10n.noRidesTodayDesc,
        onRefresh: () => context.read<ChildRidesCubit>().loadRides(),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<ChildRidesCubit>().loadRides(),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Live ride card if exists
          if (hasLiveRide) ...[
            RideCard(
              time: state.liveRide!.pickupTime ?? '--:--',
              dateLabel: l10n.today,
              rideName: state.liveRide!.rideName,
              routeDescription:
                  state.liveRide!.routeDescription ?? 'Home → School',
              driverName: state.liveRide!.driverName ?? 'Unknown',
              driverAvatar: state.liveRide!.driverAvatar,
              status: RideStatus.live,
              eta: state.liveRide!.eta,
              onTrackLive: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RideTrackingScreen(
                      rideId: state.liveRide!.occurrenceId,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],

          // Scheduled rides section
          if (todayRides.isNotEmpty) ...[
            Text(
              l10n.scheduledRides,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            ...todayRides.map(
              (ride) => RideCard(
                time: ride.pickupTime ?? '--:--',
                amPm: ride.amPm,
                dateLabel: l10n.today,
                rideName: ride.rideName,
                routeDescription: ride.routeDescription ?? 'School → Home',
                driverName: ride.driverName ?? 'Unknown',
                driverAvatar: ride.driverAvatar,
                status: RideStatus.scheduled,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUpcomingTab(
    BuildContext context,
    ChildRidesLoaded state,
    AppLocalizations l10n,
  ) {
    final upcomingRides = state.upcomingRides;

    if (upcomingRides.isEmpty) {
      return CustomEmptyState(
        icon: Icons.event,
        title: l10n.noUpcomingRides,
        message: l10n.noUpcomingRidesDesc,
        onRefresh: () => context.read<ChildRidesCubit>().loadRides(),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<ChildRidesCubit>().loadRides(),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            l10n.upcoming,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          ...upcomingRides.map(
            (ride) => RideCard(
              time: ride.pickupTime ?? '--:--',
              amPm: ride.amPm,
              dateLabel: ride.dateLabel ?? 'Tomorrow',
              rideName: ride.rideName,
              routeDescription: ride.routeDescription ?? 'Home → School',
              driverName: ride.driverName ?? 'Unknown',
              driverAvatar: ride.driverAvatar,
              status: RideStatus.scheduled,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(
    BuildContext context,
    ChildRidesLoaded state,
    AppLocalizations l10n,
  ) {
    final historyRides = state.historyRides;

    if (historyRides.isEmpty) {
      return CustomEmptyState(
        icon: Icons.history,
        title: l10n.noRideHistory,
        message: l10n.noRideHistoryDesc,
        onRefresh: () => context.read<ChildRidesCubit>().loadRides(),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<ChildRidesCubit>().loadRides(),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            l10n.history,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          ...historyRides.map(
            (ride) => RideCard(
              time: ride.pickupTime ?? '--:--',
              amPm: ride.amPm,
              dateLabel: ride.dateLabel ?? 'Yesterday',
              rideName: ride.rideName,
              routeDescription: ride.routeDescription ?? 'Home → School',
              driverName: ride.driverName ?? 'Unknown',
              driverAvatar: ride.driverAvatar,
              status: ride.isCancelled
                  ? RideStatus.cancelled
                  : RideStatus.completed,
            ),
          ),
        ],
      ),
    );
  }
}
