import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidsero_parent/l10n/app_localizations.dart';
import 'package:kidsero_parent/core/network/api_service.dart';
import 'package:kidsero_parent/core/widgets/gradient_header.dart';
import 'package:kidsero_parent/core/widgets/tab_bar_widget.dart';
import 'package:kidsero_parent/core/widgets/ride_card.dart';
import 'package:kidsero_parent/core/widgets/custom_empty_state.dart';
import 'package:kidsero_parent/features/rides/cubit/child_rides_cubit.dart';
import 'package:kidsero_parent/features/rides/cubit/report_absence_cubit.dart';
import 'package:kidsero_parent/features/rides/ui/widgets/report_absence_dialog.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/rides_repository.dart';
import '../../data/rides_service.dart';
import 'package:kidsero_parent/features/rides/models/api_models.dart';

/// Screen to display a child's ride schedule with Today/Upcoming/History tabs
class ChildScheduleScreen extends StatelessWidget {
  final String childId;
  final String childName;
  final String? childAvatar;
  final String initials;
  final String? grade;
  final String? classroom;
  final String? schoolName;
  final Color avatarColor;

  const ChildScheduleScreen({
    super.key,
    required this.childId,
    required this.childName,
    this.childAvatar,
    required this.initials,
    this.grade,
    this.classroom,
    this.schoolName,
    this.avatarColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    final apiService = context.read<ApiService>();
    final ridesService = RidesService(dio: apiService.dio);
    final ridesRepository = RidesRepository(ridesService: ridesService);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              ChildRidesCubit(repository: ridesRepository, childId: childId)
                ..loadRides()
                ..loadSummary(),
        ),
        BlocProvider(
          create: (context) => ReportAbsenceCubit(repository: ridesRepository),
        ),
      ],
      child: _ChildScheduleView(
        childId: childId,
        childName: childName,
        childAvatar: childAvatar,
        initials: initials,
        grade: grade,
        classroom: classroom,
        schoolName: schoolName,
        avatarColor: avatarColor,
      ),
    );
  }
}

class _ChildScheduleView extends StatefulWidget {
  final String childId;
  final String childName;
  final String? childAvatar;
  final String initials;
  final String? grade;
  final String? classroom;
  final String? schoolName;
  final Color avatarColor;

  const _ChildScheduleView({
    required this.childId,
    required this.childName,
    this.childAvatar,
    required this.initials,
    this.grade,
    this.classroom,
    this.schoolName,
    required this.avatarColor,
  });

  @override
  State<_ChildScheduleView> createState() => _ChildScheduleViewState();
}

class _ChildScheduleViewState extends State<_ChildScheduleView> {
  int _selectedTabIndex = 1; // Default to Today tab (index 1)

  List<String> _getTabs(AppLocalizations l10n) => [l10n.history, l10n.today, l10n.upcoming];

  String _buildChildInfoText() {
    final hasGrade = widget.grade != null && widget.grade!.isNotEmpty;
    final hasClassroom = widget.classroom != null && widget.classroom!.isNotEmpty;
    final hasSchool = widget.schoolName != null && widget.schoolName!.isNotEmpty;
    
    if (hasGrade && hasClassroom) {
      return '${widget.grade} • ${widget.classroom}';
    } else if (hasGrade) {
      return widget.grade!;
    } else if (hasClassroom) {
      return widget.classroom!;
    } else if (hasSchool) {
      return widget.schoolName!;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tabs = _getTabs(l10n);

    return Scaffold(
      backgroundColor: AppColors.background,
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
            selectedColor: AppColors.primary,
          ),

          // Content based on selected tab
          Expanded(
            child: BlocConsumer<ReportAbsenceCubit, ReportAbsenceState>(
              listener: (context, absenceState) {
                if (absenceState is ReportAbsenceSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(absenceState.message),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  // Refresh rides after reporting absence
                  context.read<ChildRidesCubit>().loadRides();
                } else if (absenceState is ReportAbsenceError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(absenceState.message),
                      backgroundColor: AppColors.error,
                    ),
                  );
                } else if (absenceState is ReportAbsenceValidationError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(absenceState.message),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              builder: (context, absenceState) {
                return _buildTabContent(context, l10n);
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
      gradientColors: const [AppColors.primary, AppColors.accent],
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
                if (widget.grade != null || widget.classroom != null || widget.schoolName != null)
                  Row(
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _buildChildInfoText(),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          // Summary button
          BlocBuilder<ChildRidesCubit, ChildRidesState>(
            builder: (context, state) {
              if (state is ChildRidesLoaded && state.summary != null) {
                return GestureDetector(
                  onTap: () => _showSummaryDialog(context, state, l10n),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.analytics_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
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

  Widget _buildTabContent(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    switch (_selectedTabIndex) {
      case 0:
        return _buildHistoryTab(context, l10n);
      case 1:
        return _buildTodayTab(context, l10n);
      case 2:
        return _buildUpcomingTab(context, l10n);
      default:
        return const SizedBox();
    }
  }

  Widget _buildTodayTab(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return BlocBuilder<ChildRidesCubit, ChildRidesState>(
      builder: (context, state) {
        if (state is ChildRidesLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        }

        if (state is ChildRidesError) {
          return CustomEmptyState(
            icon: Icons.error_outline,
            title: l10n.errorLoadingRides,
            message: state.message,
            onRefresh: () => context.read<ChildRidesCubit>().loadRides(),
          );
        }

        if (state is ChildRidesEmpty) {
          return CustomEmptyState(
            icon: Icons.today,
            title: l10n.noRidesToday,
            message: l10n.noRidesTodayDesc,
            onRefresh: () => context.read<ChildRidesCubit>().loadRides(),
          );
        }

        if (state is ChildRidesLoaded) {
          // Get today rides from the cubit
          final todayRides = state.todayRides;
          
          // Check if there's an active ride for this child
          final hasActiveRide = state.hasActiveRide;
          
          // Find active ride if any
          final activeRide = todayRides.firstWhere(
            (ride) => ride.isActive,
            orElse: () => todayRides.first,
          );

          if (todayRides.isEmpty) {
            return CustomEmptyState(
              icon: Icons.today,
              title: l10n.noRidesToday,
              message: l10n.noRidesTodayDesc,
              onRefresh: () => context.read<ChildRidesCubit>().loadRides(),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<ChildRidesCubit>().refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Active ride card (green) - if there's an active ride
                  if (hasActiveRide) ...[
                    _buildActiveRideCard(context, activeRide, l10n),
                    const SizedBox(height: 24),
                  ],
                  
                  // Today's Scheduled Rides
                  if (todayRides.isNotEmpty) ...[
                    Text(
                      hasActiveRide ? 'Other Rides Today' : l10n.today, // TODO: Add to l10n
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...todayRides.map(
                      (ride) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildTodayRideCard(context, ride, l10n),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildActiveRideCard(
    BuildContext context,
    TodayRideOccurrence ride,
    AppLocalizations l10n,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.success, AppColors.success.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Navigate to live tracking
            // TODO: Implement navigation to live tracking screen
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.directions_bus,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ride in Progress', // TODO: Add to l10n
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ride.status == 'in_progress' || ride.status == 'started'
                                ? 'On the way' // TODO: Add to l10n
                                : ride.status,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.sensors,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'LIVE', // TODO: Add to l10n
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Colors.white.withValues(alpha: 0.8),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      ride.startedAt != null 
                          ? 'Started: ${_formatTime(ride.startedAt!)}'
                          : 'Just started', // TODO: Add to l10n
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.location_on,
                      color: Colors.white.withValues(alpha: 0.8),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        ride.pickupPoint.name,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Track Live Location', // TODO: Add to l10n
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingTab(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return BlocBuilder<ChildRidesCubit, ChildRidesState>(
      builder: (context, state) {
        if (state is ChildRidesLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        }

        if (state is ChildRidesError) {
          return CustomEmptyState(
            icon: Icons.error_outline,
            title: l10n.errorLoadingRides,
            message: state.message,
            onRefresh: () => context.read<ChildRidesCubit>().loadRides(),
          );
        }

        if (state is ChildRidesLoaded) {
          final upcomingRides = state.upcomingRides;

          if (upcomingRides.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => context.read<ChildRidesCubit>().refresh(),
              child: CustomEmptyState(
                icon: Icons.event,
                title: l10n.noUpcomingRides,
                message: l10n.noUpcomingRidesDesc,
                onRefresh: () => context.read<ChildRidesCubit>().loadRides(),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<ChildRidesCubit>().refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: upcomingRides.length,
              itemBuilder: (context, index) {
                final ride = upcomingRides[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildUpcomingRideCard(context, ride, l10n),
                );
              },
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => context.read<ChildRidesCubit>().refresh(),
          child: CustomEmptyState(
            icon: Icons.event,
            title: l10n.noUpcomingRides,
            message: l10n.noUpcomingRidesDesc,
            onRefresh: () => context.read<ChildRidesCubit>().loadRides(),
          ),
        );
      },
    );
  }

  Widget _buildTodayRideCard(
    BuildContext context,
    TodayRideOccurrence ride,
    AppLocalizations l10n,
  ) {
    // Determine the ride status based on the status field
    RideStatus status;
    switch (ride.status.toLowerCase()) {
      case 'completed':
        status = RideStatus.completed;
        break;
      case 'cancelled':
      case 'excused':
        status = RideStatus.cancelled;
        break;
      case 'in_progress':
      case 'started':
        status = RideStatus.live;
        break;
      case 'scheduled':
      default:
        status = RideStatus.scheduled;
    }

    return RideCard(
      time: ride.pickupTime,
      dateLabel: ride.ride.type == 'morning'
          ? l10n.morningRide
          : l10n.afternoonRide,
      rideName: ride.ride.name,
      routeDescription: ride.ride.type == 'morning'
          ? 'Home → School'
          : 'School → Home',
      driverName: ride.driver.name,
      status: status,
      onReportAbsence: ride.canReportAbsence
          ? () => _showReportAbsenceDialogForToday(context, ride, l10n)
          : null,
    );
  }

  Widget _buildHistoryTab(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return BlocBuilder<ChildRidesCubit, ChildRidesState>(
      builder: (context, state) {
        if (state is ChildRidesLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        }

        if (state is ChildRidesError) {
          return CustomEmptyState(
            icon: Icons.error_outline,
            title: l10n.errorLoadingRides,
            message: state.message,
            onRefresh: () => context.read<ChildRidesCubit>().loadRides(),
          );
        }

        if (state is ChildRidesLoaded) {
          final historyRides = state.historyRides;

          if (historyRides.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => context.read<ChildRidesCubit>().refresh(),
              child: CustomEmptyState(
                icon: Icons.history,
                title: l10n.noRideHistory,
                message: l10n.noRideHistoryDesc,
                onRefresh: () => context.read<ChildRidesCubit>().loadRides(),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<ChildRidesCubit>().refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: historyRides.length,
              itemBuilder: (context, index) {
                final ride = historyRides[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildHistoryRideCard(context, ride, l10n),
                );
              },
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => context.read<ChildRidesCubit>().refresh(),
          child: CustomEmptyState(
            icon: Icons.history,
            title: l10n.noRideHistory,
            message: l10n.noRideHistoryDesc,
            onRefresh: () => context.read<ChildRidesCubit>().loadRides(),
          ),
        );
      },
    );
  }

  void _showReportAbsenceDialogForToday(
    BuildContext context,
    TodayRideOccurrence ride,
    AppLocalizations l10n,
  ) {
    showReportAbsenceDialog(
      context: context,
      occurrenceId: ride.occurrenceId,
      studentId: widget.childId,
      onSuccess: () {
        // Refresh rides after reporting absence
        context.read<ChildRidesCubit>().loadRides();
      },
    );
  }

  void _showSummaryDialog(
    BuildContext context,
    ChildRidesLoaded state,
    AppLocalizations l10n,
  ) {
    final summary = state.summary;
    if (summary == null) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.rideSummary),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSummaryRow(
              l10n.totalScheduled,
              summary.summary.total.toString(),
            ),
            _buildSummaryRow(
              l10n.attended,
              summary.summary.byStatus.completed.toString(),
              color: AppColors.success,
            ),
            _buildSummaryRow(
              l10n.absent,
              summary.summary.byStatus.absent.toString(),
              color: AppColors.error,
            ),
            _buildSummaryRow(
              'Excused', // TODO: Add to l10n
              summary.summary.byStatus.excused.toString(),
              color: Colors.orange,
            ),
            const Divider(),
            _buildSummaryRow(
              l10n.attendanceRate,
              '${summary.summary.attendanceRate}%',
              color: AppColors.primary,
              isBold: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingRideCard(
    BuildContext context,
    UpcomingRide ride,
    AppLocalizations l10n,
  ) {
    return RideCard(
      time: ride.pickupTime,
      dateLabel: ride.ride.type == 'morning'
          ? l10n.morningRide
          : l10n.afternoonRide,
      rideName: ride.ride.name,
      routeDescription: ride.ride.type == 'morning'
          ? 'Home → School'
          : 'School → Home',
      driverName: '', // Driver info not available in upcoming rides
      status: RideStatus.scheduled,
      onReportAbsence: () => _showReportAbsenceDialogForUpcoming(context, ride, l10n),
    );
  }

  Widget _buildHistoryRideCard(
    BuildContext context,
    TodayRideOccurrence ride,
    AppLocalizations l10n,
  ) {
    // Determine the ride status
    RideStatus status;
    switch (ride.status.toLowerCase()) {
      case 'completed':
        status = RideStatus.completed;
        break;
      case 'cancelled':
      case 'excused':
        status = RideStatus.cancelled;
        break;
      case 'absent':
        status = RideStatus.cancelled;
        break;
      default:
        status = RideStatus.completed;
    }

    return RideCard(
      time: ride.pickupTime,
      dateLabel: ride.ride.type == 'morning'
          ? l10n.morningRide
          : l10n.afternoonRide,
      rideName: ride.ride.name,
      routeDescription: ride.ride.type == 'morning'
          ? 'Home → School'
          : 'School → Home',
      driverName: ride.driver.name,
      status: status,
      onReportAbsence: null, // Cannot report absence for past rides
    );
  }

  void _showReportAbsenceDialogForUpcoming(
    BuildContext context,
    UpcomingRide ride,
    AppLocalizations l10n,
  ) {
    showReportAbsenceDialog(
      context: context,
      occurrenceId: ride.occurrenceId,
      studentId: widget.childId,
      onSuccess: () {
        // Refresh rides after reporting absence
        context.read<ChildRidesCubit>().loadRides();
      },
    );
  }

  String _formatTime(String? isoTime) {
    if (isoTime == null) return '--:--';
    try {
      final dateTime = DateTime.parse(isoTime);
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } catch (e) {
      return '--:--';
    }
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    Color? color,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
