import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidsero_driver/l10n/app_localizations.dart';
import 'package:kidsero_driver/core/widgets/gradient_header.dart';
import 'package:kidsero_driver/core/widgets/ride_card.dart';
import 'package:kidsero_driver/core/widgets/custom_empty_state.dart';
import 'package:kidsero_driver/features/rides/cubit/upcoming_rides_cubit.dart';
import 'package:kidsero_driver/features/rides/data/rides_repository.dart';
import 'package:kidsero_driver/core/theme/app_colors.dart';
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
                    final hasFilter = state is UpcomingRidesLoaded &&
                        (state.startDate != null || state.endDate != null);
                    
                    return IconButton(
                      icon: Stack(
                        children: [
                          const Icon(
                            Icons.filter_list,
                            color: Colors.white,
                            size: 24,
                          ),
                          if (hasFilter)
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
    // Group rides by date
    final ridesByDate = state.ridesByDate;
    
    // Sort dates chronologically
    final sortedDates = ridesByDate.keys.toList()
      ..sort((a, b) {
        try {
          final dateA = DateTime.parse(a);
          final dateB = DateTime.parse(b);
          return dateA.compareTo(dateB);
        } catch (_) {
          // Fallback to string comparison if parsing fails
          return a.compareTo(b);
        }
      });

    return RefreshIndicator(
      onRefresh: () => context.read<UpcomingRidesCubit>().refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: sortedDates.length,
        itemBuilder: (context, index) {
          final date = sortedDates[index];
          final ridesForDate = ridesByDate[date]!;

          // Sort rides by time (morning first, then afternoon, then by pickup time)
          ridesForDate.sort((a, b) {
            // Morning rides come before afternoon rides
            final aPeriod = a.period.toLowerCase();
            final bPeriod = b.period.toLowerCase();
            
            if (aPeriod == 'morning' && bPeriod != 'morning') {
              return -1;
            }
            if (aPeriod != 'morning' && bPeriod == 'morning') {
              return 1;
            }
            
            // If both are same period, sort by pickup time
            if (a.pickupTime != null && b.pickupTime != null) {
              try {
                final timeA = _parseTime(a.pickupTime!);
                final timeB = _parseTime(b.pickupTime!);
                return timeA.compareTo(timeB);
              } catch (_) {
                // Fallback to string comparison if parsing fails
                return a.pickupTime!.compareTo(b.pickupTime!);
              }
            }
            
            // If one has pickup time and other doesn't, prioritize the one with time
            if (a.pickupTime != null && b.pickupTime == null) {
              return -1;
            }
            if (a.pickupTime == null && b.pickupTime != null) {
              return 1;
            }
            
            return 0;
          });

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date header
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(date, l10n),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: Colors.grey[300],
                      ),
                    ),
                  ],
                ),
              ),

              // Rides for this date
              ...ridesForDate.map(
                (ride) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildRideCard(context, ride, l10n),
                ),
              ),

              const SizedBox(height: 12),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRideCard(
    BuildContext context,
    UpcomingRide ride,
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
      case 'in_progress':
        status = RideStatus.live;
        break;
      default:
        status = RideStatus.scheduled;
    }

    // Format pickup time
    final time = ride.pickupTime != null
        ? _formatTime(ride.pickupTime!)
        : '--:--';

    // Determine ride name and route
    final rideName = ride.period.toLowerCase() == 'morning'
        ? l10n.morningRide
        : l10n.afternoonRide;

    final routeDescription = ride.pickupLocation != null &&
            ride.dropoffLocation != null
        ? '${ride.pickupLocation} → ${ride.dropoffLocation}'
        : (ride.period.toLowerCase() == 'morning'
            ? l10n.homeToSchool
            : l10n.schoolToHome);

    return RideCard(
      time: time,
      dateLabel: ride.childName,
      rideName: rideName,
      routeDescription: routeDescription,
      driverName: 'Driver', // TODO: Add driver info to UpcomingRide model
      status: status,
      onTap: () {
        // TODO: Navigate to ride details if needed
      },
    );
  }

  String _formatDate(String dateStr, AppLocalizations l10n) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));
      final dateOnly = DateTime(date.year, date.month, date.day);

      if (dateOnly == today) {
        return l10n.today;
      } else if (dateOnly == tomorrow) {
        return 'Tomorrow'; // TODO: Add to l10n
      } else {
        // Format as "Mon, Jan 15"
        final weekday = _getWeekdayName(date.weekday);
        final month = _getMonthName(date.month);
        return '$weekday, $month ${date.day}';
      }
    } catch (_) {
      return dateStr;
    }
  }

  String _formatTime(String timeStr) {
    try {
      // Handle both time-only format (HH:mm) and ISO datetime format
      DateTime time;
      if (timeStr.contains('T') || timeStr.contains('-')) {
        time = DateTime.parse(timeStr);
      } else {
        // Parse time-only format
        final parts = timeStr.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        time = DateTime(2000, 1, 1, hour, minute);
      }

      final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
      final minute = time.minute.toString().padLeft(2, '0');
      final period = time.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    } catch (_) {
      return timeStr;
    }
  }

  /// Parse time string to DateTime for comparison
  DateTime _parseTime(String timeStr) {
    // Handle both time-only format (HH:mm) and ISO datetime format
    if (timeStr.contains('T') || timeStr.contains('-')) {
      return DateTime.parse(timeStr);
    } else {
      // Parse time-only format
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1].split('.')[0]); // Handle seconds if present
      return DateTime(2000, 1, 1, hour, minute);
    }
  }

  String _getWeekdayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }

  /// Show date filter dialog
  void _showDateFilterDialog(BuildContext context) {
    final cubit = context.read<UpcomingRidesCubit>();
    final state = cubit.state;
    
    DateTime? startDate;
    DateTime? endDate;
    
    if (state is UpcomingRidesLoaded) {
      startDate = state.startDate;
      endDate = state.endDate;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => _DateFilterDialog(
        initialStartDate: startDate,
        initialEndDate: endDate,
        onApply: (start, end) {
          cubit.filterByDateRange(start, end);
        },
        onClear: () {
          cubit.clearFilters();
        },
      ),
    );
  }
}

/// Date filter dialog widget
class _DateFilterDialog extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final Function(DateTime?, DateTime?) onApply;
  final VoidCallback onClear;

  const _DateFilterDialog({
    this.initialStartDate,
    this.initialEndDate,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<_DateFilterDialog> createState() => _DateFilterDialogState();
}

class _DateFilterDialogState extends State<_DateFilterDialog> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.filter_list, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            'Filter by Date', // TODO: Add to l10n
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Start date
          Text(
            'From Date', // TODO: Add to l10n
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _selectStartDate(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _startDate != null
                          ? _formatDateForDisplay(_startDate!)
                          : 'Select start date', // TODO: Add to l10n
                      style: TextStyle(
                        fontSize: 14,
                        color: _startDate != null ? Colors.black87 : Colors.grey[500],
                      ),
                    ),
                  ),
                  if (_startDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        setState(() {
                          _startDate = null;
                        });
                      },
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // End date
          Text(
            'To Date', // TODO: Add to l10n
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _selectEndDate(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _endDate != null
                          ? _formatDateForDisplay(_endDate!)
                          : 'Select end date', // TODO: Add to l10n
                      style: TextStyle(
                        fontSize: 14,
                        color: _endDate != null ? Colors.black87 : Colors.grey[500],
                      ),
                    ),
                  ),
                  if (_endDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        setState(() {
                          _endDate = null;
                        });
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        // Clear button
        TextButton(
          onPressed: () {
            widget.onClear();
            Navigator.of(context).pop();
          },
          child: Text(
            'Clear', // TODO: Add to l10n
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        // Cancel button
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            l10n.cancel,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        // Apply button
        ElevatedButton(
          onPressed: () {
            widget.onApply(_startDate, _endDate);
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text('Apply'), // TODO: Add to l10n
        ),
      ],
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        // If end date is before start date, clear it
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  String _formatDateForDisplay(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
