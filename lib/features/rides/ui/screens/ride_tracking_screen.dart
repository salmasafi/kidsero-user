import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidsero_parent/core/network/api_service.dart';
import 'package:kidsero_parent/features/rides/cubit/ride_tracking_cubit.dart';
import 'package:kidsero_parent/features/rides/data/rides_repository.dart';
import 'package:kidsero_parent/features/rides/data/rides_service.dart';
import 'package:kidsero_parent/features/rides/models/ride_models.dart';
import 'package:kidsero_parent/core/theme/app_colors.dart';

// --- CONSTANTS & THEME COLORS ---
const Color kPrimaryColor = AppColors.primary;
const Color kSecondaryColor = AppColors.accent;
const Color kSuccessColor = AppColors.success;
const Color kNeutralColor = AppColors.inputBackground;

class RideTrackingScreen extends StatelessWidget {
  final String rideId;

  const RideTrackingScreen({Key? key, required this.rideId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dio = context.read<ApiService>().dio;
    final ridesService = RidesService(dio: dio);
    final ridesRepository = RidesRepository(ridesService: ridesService);

    return BlocProvider(
      create: (context) =>
          RideTrackingCubit(repository: ridesRepository, rideId: rideId)
            ..loadTracking(),
      child: Scaffold(
        backgroundColor: kNeutralColor,
        appBar: AppBar(
          title: const Text(
            "Track Ride",
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
        body: BlocConsumer<RideTrackingCubit, RideTrackingState>(
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
          builder: (context, state) {
            if (state is RideTrackingLoading) {
              return const Center(
                child: CircularProgressIndicator(color: kPrimaryColor),
              );
            } else if (state is RideTrackingLoaded) {
              return _buildContent(state.tracking);
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
                    const Text("Unable to track ride"),
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
    );
  }

  Widget _buildContent(RideTracking data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRouteHeaderCard(data),
          const SizedBox(height: 20),
          const Text(
            "Ride Details",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoCard(data),
          const SizedBox(height: 24),
          const Text(
            "Route Details",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildRouteInfoList(data),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildRouteHeaderCard(RideTracking data) {
    bool isActive =
        data.status.toLowerCase().contains('in_progress') ||
        data.status.toLowerCase().contains('started');

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
            color: kPrimaryColor.withOpacity(0.3),
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
                      "Current Route",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.route?.pickupLocation ?? 'Ride for Child',
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
                      ? kSuccessColor.withOpacity(0.2)
                      : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
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
                      data.status.replaceAll('_', ' ').toUpperCase(),
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
                "Next Stop ETA",
                data.route?.nextStopEta ?? 'N/A',
              ),
              _buildHeaderStat("Child ID", data.childId),
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

  Widget _buildInfoCard(RideTracking data) {
    final driver = data.driver;
    final bus = data.bus;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Driver Section
          if (driver != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: kPrimaryColor.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: driver.avatar != null
                          ? NetworkImage(driver.avatar!)
                          : null,
                      child: driver.avatar == null
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
                          driver.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (driver.phone != null)
                          Text(
                            driver.phone!,
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
                      // Implement call
                    },
                    icon: const Icon(Icons.phone, color: kSuccessColor),
                    style: IconButton.styleFrom(
                      backgroundColor: kSuccessColor.withOpacity(0.1),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
            ),

          if (driver != null && bus != null)
            const Divider(height: 1, indent: 20, endIndent: 20),

          // Bus Section
          if (bus != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withOpacity(0.05),
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
                        Text(
                          bus.plateNumber ?? 'Bus',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        if (data.currentLocation != null)
                          Text(
                            "Lat: ${data.currentLocation!.lat.toStringAsFixed(4)}, Lng: ${data.currentLocation!.lng.toStringAsFixed(4)}",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
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

  Widget _buildRouteInfoList(RideTracking data) {
    if (data.route == null)
      return const Center(child: Text("No route info available"));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Column(
        children: [
          if (data.route!.pickupLocation != null)
            _buildRoutePoint(data.route!.pickupLocation!, "Pickup Point", true),

          if (data.route!.pickupLocation != null &&
              data.route!.dropoffLocation != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(height: 30, width: 2, color: Colors.grey[200]),
            ),

          if (data.route!.dropoffLocation != null)
            _buildRoutePoint(
              data.route!.dropoffLocation!,
              "Dropoff Point",
              false,
            ),
        ],
      ),
    );
  }

  Widget _buildRoutePoint(String location, String label, bool isStart) {
    return Row(
      children: [
        Icon(
          isStart ? Icons.radio_button_checked : Icons.location_on,
          color: kPrimaryColor,
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              location,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }
}
