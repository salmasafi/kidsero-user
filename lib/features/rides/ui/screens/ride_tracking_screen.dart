import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidsero_parent/core/network/api_service.dart';
import 'package:kidsero_parent/features/rides/cubit/ride_tracking_cubit.dart';
import 'package:kidsero_parent/features/rides/data/rides_repository.dart';
import 'package:kidsero_parent/features/rides/data/rides_service.dart';
import 'package:kidsero_parent/features/rides/models/api_models.dart';
import 'package:kidsero_parent/core/theme/app_colors.dart';
import 'package:intl/intl.dart';

// --- CONSTANTS & THEME COLORS ---
const Color kPrimaryColor = AppColors.primary;
const Color kSecondaryColor = AppColors.accent;
const Color kSuccessColor = AppColors.success;
const Color kNeutralColor = AppColors.inputBackground;

class RideTrackingScreen extends StatefulWidget {
  final String childId;

  const RideTrackingScreen({super.key, required this.childId});

  @override
  State<RideTrackingScreen> createState() => _RideTrackingScreenState();
}

class _RideTrackingScreenState extends State<RideTrackingScreen> {
  @override
  Widget build(BuildContext context) {
    final dio = context.read<ApiService>().dio;
    final ridesService = RidesService(dio: dio);
    final ridesRepository = RidesRepository(ridesService: ridesService);

    return BlocProvider(
      create: (context) =>
          RideTrackingCubit(repository: ridesRepository, childId: widget.childId)
            ..loadTracking()
            ..startAutoRefresh(),
      child: BlocListener<RideTrackingCubit, RideTrackingState>(
        listener: (context, state) {
          if (state is RideTrackingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: kNeutralColor,
          appBar: AppBar(
            title: const Text(
              "Timeline Tracking",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black87,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              // Refresh Button
              BlocBuilder<RideTrackingCubit, RideTrackingState>(
                builder: (context, state) {
                  return IconButton(
                    icon: const Icon(Icons.refresh, color: kPrimaryColor),
                    onPressed: () =>
                        context.read<RideTrackingCubit>().loadTracking(),
                  );
                },
              ),
            ],
          ),
          body: BlocBuilder<RideTrackingCubit, RideTrackingState>(
            builder: (context, state) {
              if (state is RideTrackingLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: kPrimaryColor),
                );
              } else if (state is RideTrackingLoaded) {
                return _buildContent(state.trackingData);
              } else if (state is RideTrackingError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () =>
                            context.read<RideTrackingCubit>().loadTracking(),
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Stop auto-refresh when screen is disposed
    // Note: The cubit will handle this in its close() method
    super.dispose();
  }

  Widget _buildContent(RideTrackingData data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRideHeaderCard(data),
          const SizedBox(height: 20),
          _buildBusAndDriverInfo(data),
          const SizedBox(height: 24),
          const Text(
            "Pickup Points Timeline",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildPickupPointsTimeline(data),
          const SizedBox(height: 24),
          const Text(
            "Children on Ride",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildChildrenList(data),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildRideHeaderCard(RideTrackingData data) {
    bool isActive = data.occurrence.status.toLowerCase() == 'in_progress';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kPrimaryColor, kSecondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Current Ride",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.ride.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
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
                  color: isActive
                      ? kSuccessColor.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.directions_bus_filled,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      data.occurrence.status.replaceAll('_', ' ').toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHeaderStat(
                "Ride Type",
                data.ride.type.toUpperCase(),
              ),
              _buildHeaderStat(
                "Date",
                _formatDate(data.occurrence.date),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBusAndDriverInfo(RideTrackingData data) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Driver Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: kPrimaryColor.withValues(alpha: 0.2),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: data.driver.avatar != null
                        ? NetworkImage(data.driver.avatar!)
                        : null,
                    child: data.driver.avatar == null
                        ? const Icon(Icons.person, color: Colors.grey)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Driver",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        data.driver.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        data.driver.phone,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Implement call functionality
                  },
                  icon: const Icon(Icons.phone, color: kSuccessColor),
                  style: IconButton.styleFrom(
                    backgroundColor: kSuccessColor.withValues(alpha: 0.1),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, indent: 20, endIndent: 20),

          // Bus Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.directions_bus,
                    color: kPrimaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Bus",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        data.bus.plateNumber,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Bus #${data.bus.busNumber}",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupPointsTimeline(RideTrackingData data) {
    // Sort stops chronologically by stopOrder
    final sortedStops = List<RouteStop>.from(data.route.stops)
      ..sort((a, b) => a.stopOrder.compareTo(b.stopOrder));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          for (int i = 0; i < sortedStops.length; i++)
            _buildPickupPointItem(
              sortedStops[i],
              data,
              isFirst: i == 0,
              isLast: i == sortedStops.length - 1,
            ),
        ],
      ),
    );
  }

  Widget _buildPickupPointItem(
    RouteStop stop,
    RideTrackingData data,
    {required bool isFirst, required bool isLast}
  ) {
    // Find children at this pickup point
    final childrenAtStop = data.children.where(
      (child) => child.pickupPoint.id == stop.id
    ).toList();

    // Check if current child is at this stop
    final isCurrentChildStop = childrenAtStop.any(
      (child) => child.child.id == widget.childId
    );

    // Determine status based on children at this stop
    String status = 'pending';
    if (childrenAtStop.isNotEmpty) {
      if (childrenAtStop.every((c) => c.status == 'picked_up')) {
        status = 'completed';
      } else if (childrenAtStop.any((c) => c.status == 'picked_up')) {
        status = 'in_progress';
      }
    }

    Color statusColor = status == 'completed'
        ? kSuccessColor
        : status == 'in_progress'
            ? kSecondaryColor
            : Colors.grey;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline indicator
            Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCurrentChildStop
                        ? kPrimaryColor
                        : statusColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCurrentChildStop ? kPrimaryColor : statusColor,
                      width: isCurrentChildStop ? 3 : 2,
                    ),
                  ),
                  child: Icon(
                    status == 'completed'
                        ? Icons.check
                        : status == 'in_progress'
                            ? Icons.location_on
                            : Icons.radio_button_unchecked,
                    color: isCurrentChildStop ? Colors.white : statusColor,
                    size: 16,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: Colors.grey[300],
                  ),
              ],
            ),
            const SizedBox(width: 16),
            // Stop info
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCurrentChildStop
                      ? kPrimaryColor.withValues(alpha: 0.05)
                      : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCurrentChildStop
                        ? kPrimaryColor.withValues(alpha: 0.3)
                        : Colors.grey[200]!,
                    width: isCurrentChildStop ? 2 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            stop.name,
                            style: TextStyle(
                              fontWeight: isCurrentChildStop
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              fontSize: 15,
                              color: isCurrentChildStop
                                  ? kPrimaryColor
                                  : Colors.black87,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            status.replaceAll('_', ' ').toUpperCase(),
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stop.address,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    if (childrenAtStop.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        "${childrenAtStop.length} ${childrenAtStop.length == 1 ? 'child' : 'children'} at this stop",
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
        if (!isLast) const SizedBox(height: 0),
      ],
    );
  }

  Widget _buildChildrenList(RideTrackingData data) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: data.children.length,
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          indent: 20,
          endIndent: 20,
        ),
        itemBuilder: (context, index) {
          final trackingChild = data.children[index];
          final isCurrentChild = trackingChild.child.id == widget.childId;

          return Container(
            color: isCurrentChild
                ? kPrimaryColor.withValues(alpha: 0.05)
                : Colors.transparent,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: trackingChild.child.avatar != null
                      ? NetworkImage(trackingChild.child.avatar!)
                      : null,
                  child: trackingChild.child.avatar == null
                      ? const Icon(Icons.person, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              trackingChild.child.name,
                              style: TextStyle(
                                fontWeight: isCurrentChild
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                fontSize: 15,
                                color: isCurrentChild
                                    ? kPrimaryColor
                                    : Colors.black87,
                              ),
                            ),
                          ),
                          if (isCurrentChild)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: kPrimaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                "YOU",
                                style: TextStyle(
                                  color: kPrimaryColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        trackingChild.pickupPoint.name,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            trackingChild.status == 'picked_up'
                                ? Icons.check_circle
                                : Icons.schedule,
                            size: 14,
                            color: trackingChild.status == 'picked_up'
                                ? kSuccessColor
                                : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            trackingChild.status == 'picked_up'
                                ? 'Picked up at ${_formatTime(trackingChild.pickedUpAt!)}'
                                : 'Scheduled: ${trackingChild.pickupTime}',
                            style: TextStyle(
                              color: trackingChild.status == 'picked_up'
                                  ? kSuccessColor
                                  : Colors.grey[600],
                              fontSize: 11,
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
        },
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _formatTime(String timeStr) {
    try {
      final time = DateTime.parse(timeStr);
      return DateFormat('h:mm a').format(time);
    } catch (e) {
      return timeStr;
    }
  }
}
