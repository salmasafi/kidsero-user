import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidsero_parent/l10n/app_localizations.dart';
import 'package:kidsero_parent/core/theme/app_colors.dart';
import 'package:kidsero_parent/core/widgets/custom_empty_state.dart';
import 'package:kidsero_parent/core/widgets/custom_loading.dart';
import 'package:kidsero_parent/features/rides/cubit/child_rides_cubit.dart';
import 'package:kidsero_parent/features/rides/models/ride_models.dart';
import 'package:kidsero_parent/features/rides/cubit/report_absence_cubit.dart';
import 'package:intl/intl.dart';

/// Screen to display comprehensive ride history for a specific child
class ChildRideHistoryScreen extends StatefulWidget {
  final String childId;
  final String childName;
  final String? childAvatar;
  final String initials;
  final Color avatarColor;

  const ChildRideHistoryScreen({
    super.key,
    required this.childId,
    required this.childName,
    this.childAvatar,
    required this.initials,
    this.avatarColor = AppColors.primary,
  });

  @override
  State<ChildRideHistoryScreen> createState() => _ChildRideHistoryScreenState();
}

class _ChildRideHistoryScreenState extends State<ChildRideHistoryScreen> {
  @override
  void initState() {
    super.initState();
    _loadRides();
  }

  void _loadRides() {
    context.read<ChildRidesCubit>().loadRides();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(context, l10n),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _loadRides(),
              color: AppColors.primary,
              child: BlocBuilder<ChildRidesCubit, ChildRidesState>(
                builder: (context, state) {
                  if (state is ChildRidesLoading) {
                    return const Center(child: CustomLoading());
                  }

                  if (state is ChildRidesError) {
                    return CustomEmptyState(
                      icon: Icons.error_outline,
                      title: l10n.errorLoadingRides,
                      message: state.message,
                      actionLabel: l10n.login,
                      onAction: _loadRides,
                    );
                  }

                  if (state is ChildRidesEmpty) {
                    return CustomEmptyState(
                      icon: Icons.directions_bus_outlined,
                      title: l10n.noRideHistory,
                      message: l10n.noRideHistoryDesc,
                    );
                  }

                  if (state is ChildRidesLoaded) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (state.summary != null) ...[
                            _buildSummaryCard(context, l10n, state.summary!),
                            const SizedBox(height: 16),
                          ],
                          if (state.hasActiveRide) ...[
                            _buildActiveRideCard(context, l10n, state.activeRide!),
                            const SizedBox(height: 16),
                          ],
                          if (state.hasUpcomingRides) ...[
                            _buildSectionTitle(l10n.upcoming),
                            const SizedBox(height: 12),
                            _buildRidesList(context, l10n, state.upcomingRides, true),
                            const SizedBox(height: 16),
                          ],
                          if (state.hasHistory) ...[
                            _buildSectionTitle(l10n.history),
                            const SizedBox(height: 12),
                            _buildRidesList(context, l10n, state.historyRides, false),
                          ],
                        ],
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 24,
                backgroundColor: widget.avatarColor.withOpacity(0.3),
                backgroundImage: widget.childAvatar != null
                    ? NetworkImage(widget.childAvatar!)
                    : null,
                child: widget.childAvatar == null
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
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.childName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      l10n.history,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    AppLocalizations l10n,
    RideSummaryData summary,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.rideSummary,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    l10n.totalScheduled,
                    summary.summary.total.toString(),
                    Icons.directions_bus,
                    AppColors.primary,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    l10n.attended,
                    summary.summary.byStatus.completed.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    l10n.absent,
                    summary.summary.byStatus.absent.toString(),
                    Icons.cancel,
                    Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    l10n.attendanceRate,
                    _calculateAttendanceRate(summary.summary),
                    Icons.trending_up,
                    AppColors.accent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _calculateAttendanceRate(RideSummaryStats stats) {
    if (stats.total == 0) return '0%';
    final rate = (stats.byStatus.completed / stats.total) * 100;
    return '${rate.toStringAsFixed(1)}%';
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActiveRideCard(
    BuildContext context,
    AppLocalizations l10n,
    ActiveRide activeRide,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.accent.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    l10n.liveNow,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    // Navigate to live tracking
                  },
                  icon: const Icon(Icons.location_on, size: 18),
                  label: Text(l10n.trackLive),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (activeRide.driver != null)
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    '${l10n.driver}: ${activeRide.driver!.name}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            if (activeRide.bus != null && activeRide.bus!.plateNumber != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(Icons.directions_bus, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      activeRide.bus!.plateNumber!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            if (activeRide.estimatedArrival != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      '${l10n.eta}: ${activeRide.estimatedArrival}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildRidesList(
    BuildContext context,
    AppLocalizations l10n,
    List<RideHistoryItem> rides,
    bool isUpcoming,
  ) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rides.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildRideCard(context, l10n, rides[index], isUpcoming);
      },
    );
  }

  Widget _buildRideCard(
    BuildContext context,
    AppLocalizations l10n,
    RideHistoryItem ride,
    bool isUpcoming,
  ) {
    final statusColor = _getStatusColor(ride.status);
    final statusIcon = _getStatusIcon(ride.status);
    final canReportAbsence = isUpcoming && ride.status == 'scheduled';

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showRideDetails(context, l10n, ride),
        borderRadius: BorderRadius.circular(12),
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
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDate(ride.date),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getStatusText(l10n, ride.status),
                          style: TextStyle(
                            fontSize: 12,
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (canReportAbsence)
                    IconButton(
                      icon: const Icon(Icons.event_busy, color: AppColors.error),
                      onPressed: () => _showAbsenceDialog(context, l10n, ride),
                      tooltip: l10n.reportAbsence,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildRideInfo(
                      ride.period,
                      Icons.schedule,
                    ),
                  ),
                  if (ride.pickedUpAt != null)
                    Expanded(
                      child: _buildRideInfo(
                        _formatTime(ride.pickedUpAt!),
                        Icons.login,
                      ),
                    ),
                  if (ride.droppedOffAt != null)
                    Expanded(
                      child: _buildRideInfo(
                        _formatTime(ride.droppedOffAt!),
                        Icons.logout,
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

  Widget _buildRideInfo(String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return AppColors.primary;
      case 'in_progress':
      case 'inprogress':
        return AppColors.accent;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return AppColors.error;
      case 'excused':
      case 'absent':
        return Colors.orange;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return Icons.schedule;
      case 'in_progress':
      case 'inprogress':
        return Icons.directions_bus;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      case 'excused':
      case 'absent':
        return Icons.event_busy;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusText(AppLocalizations l10n, String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return l10n.scheduled;
      case 'in_progress':
      case 'inprogress':
        return l10n.liveNow;
      case 'completed':
        return l10n.completed;
      case 'cancelled':
        return l10n.cancelled;
      case 'excused':
      case 'absent':
        return l10n.absent;
      default:
        return status;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('EEEE, dd MMMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _formatTime(String timeStr) {
    try {
      final time = DateTime.parse(timeStr);
      return DateFormat('HH:mm').format(time);
    } catch (e) {
      return timeStr;
    }
  }

  void _showRideDetails(
    BuildContext context,
    AppLocalizations l10n,
    RideHistoryItem ride,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.history,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                _buildDetailRow(
                  l10n.date,
                  _formatDate(ride.date),
                  Icons.calendar_today,
                ),
                _buildDetailRow(
                  l10n.status,
                  _getStatusText(l10n, ride.status),
                  _getStatusIcon(ride.status),
                  valueColor: _getStatusColor(ride.status),
                ),
                _buildDetailRow(
                  l10n.payment,
                  ride.period,
                  Icons.schedule,
                ),
                if (ride.pickedUpAt != null)
                  _buildDetailRow(
                    'Picked Up',
                    _formatTime(ride.pickedUpAt!),
                    Icons.login,
                  ),
                if (ride.droppedOffAt != null)
                  _buildDetailRow(
                    'Dropped Off',
                    _formatTime(ride.droppedOffAt!),
                    Icons.logout,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAbsenceDialog(
    BuildContext context,
    AppLocalizations l10n,
    RideHistoryItem ride,
  ) {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<ReportAbsenceCubit>(),
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(l10n.reportAbsence),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.reportAbsenceDescription,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: reasonController,
                  decoration: InputDecoration(
                    labelText: l10n.reason,
                    hintText: l10n.enterReasonHint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.edit_note),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Reason is required';
                    }
                    if (value.trim().length < 3) {
                      return 'Reason is too short';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            BlocConsumer<ReportAbsenceCubit, ReportAbsenceState>(
              listener: (context, state) {
                if (state is ReportAbsenceSuccess) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadRides();
                } else if (state is ReportAbsenceError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is ReportAbsenceLoading) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                return ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      context.read<ReportAbsenceCubit>().reportAbsence(
                            occurrenceId: ride.rideId,
                            studentId: widget.childId,
                            reason: reasonController.text.trim(),
                          );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(l10n.submit),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
