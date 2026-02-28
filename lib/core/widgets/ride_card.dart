import 'package:flutter/material.dart';
import 'package:kidsero_parent/l10n/app_localizations.dart';
import '../theme/app_colors.dart';

/// Status enum for ride cards
enum RideStatus { live, scheduled, completed, cancelled }

/// A reusable ride card widget for displaying ride information
class RideCard extends StatelessWidget {
  final String time;
  final String? amPm;
  final String dateLabel;
  final String rideName;
  final String routeDescription;
  final String driverName;
  final String? driverAvatar;
  final RideStatus status;
  final String? eta;
  final VoidCallback? onTrackLive; // For live map tracking
  final VoidCallback? onTrackTimeline; // For timeline tracking
  final VoidCallback? onTap;
  final VoidCallback? onReportAbsence; // For reporting absence

  const RideCard({
    super.key,
    required this.time,
    this.amPm,
    required this.dateLabel,
    required this.rideName,
    required this.routeDescription,
    required this.driverName,
    this.driverAvatar,
    required this.status,
    this.eta,
    this.onTrackLive,
    this.onTrackTimeline,
    this.onTap,
    this.onReportAbsence,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (status == RideStatus.live) {
      return _buildLiveCard(context, l10n);
    }
    return _buildScheduledCard(context, l10n);
  }

  Widget _buildLiveCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.success, AppColors.success],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.3),
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
            // Ride name
            Row(
              children: [
                const Icon(Icons.location_on, size: 18, color: Colors.white70),
                const SizedBox(width: 6),
                Text(
                  rideName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Route
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Text(
                routeDescription,
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
                      driverName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                if (eta != null)
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
                        eta!,
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
            // Track Live button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTrackLive,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.success,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.navigation_rounded, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      l10n.trackLive,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduledCard(BuildContext context, AppLocalizations l10n) {
    final statusConfig = _getStatusConfig(l10n);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time and status row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
                    const SizedBox(width: 6),
                    Text(
                      '$time ${amPm ?? ''}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '• $dateLabel',
                      style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusConfig['bgColor'] as Color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (statusConfig['icon'] != null)
                        Icon(
                          statusConfig['icon'] as IconData,
                          size: 12,
                          color: statusConfig['color'] as Color,
                        ),
                      if (statusConfig['icon'] != null)
                        const SizedBox(width: 4),
                      Text(
                        statusConfig['label'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusConfig['color'] as Color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Ride name
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    rideName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Text(
                routeDescription,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ),
            if (driverName.isNotEmpty) ...[
              const SizedBox(height: 12),
              // Driver info
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    backgroundImage:
                        driverAvatar != null && driverAvatar!.isNotEmpty
                        ? NetworkImage(driverAvatar!)
                        : null,
                    child: driverAvatar == null || driverAvatar!.isEmpty
                        ? Icon(Icons.person, size: 16, color: AppColors.primary)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driverName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        l10n.driver,
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusConfig(AppLocalizations l10n) {
    switch (status) {
      case RideStatus.live:
        return {
          'label': l10n.liveNow,
          'color': AppColors.success,
          'bgColor': AppColors.success.withValues(alpha: 0.1),
          'icon': Icons.sensors,
        };
      case RideStatus.scheduled:
        return {
          'label': l10n.scheduled,
          'color': const Color(0xFF4A90E2), // Blue color for scheduled
          'bgColor': const Color(0xFF4A90E2).withValues(alpha: 0.1),
          'icon': null,
        };
      case RideStatus.completed:
        return {
          'label': l10n.completed,
          'color': Colors.grey[600],
          'bgColor': Colors.grey.withValues(alpha: 0.1),
          'icon': Icons.check,
        };
      case RideStatus.cancelled:
        return {
          'label': l10n.cancelled,
          'color': AppColors.error,
          'bgColor': AppColors.error.withValues(alpha: 0.1),
          'icon': Icons.close,
        };
    }
  }
}
