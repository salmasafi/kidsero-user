

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidsero_driver/core/network/api_service.dart';
import 'package:kidsero_driver/features/track_ride/cubit/tracking_cubit.dart'; // Import the new Cubit
import 'package:kidsero_driver/features/track_ride/models/tracking_models.dart'; // Import the new Models

// --- CONSTANTS & THEME COLORS ---
const Color kPrimaryColor = Color(0xFF4F46E5); // Indigo
const Color kSecondaryColor = Color(0xFF7C3AED); // Purple
const Color kSuccessColor = Color(0xFF10B981); // Emerald Green
const Color kNeutralColor = Color(0xFFF3F4F6); // Light Grey Background

class RideTrackingScreen extends StatelessWidget {
  final String rideId; // ID passed from the previous screen

  const RideTrackingScreen({Key? key, required this.rideId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TrackingCubit(
        apiService: ApiService(),
        rideId: rideId,
      )..loadTrackingData(),
      child: Scaffold(
        backgroundColor: kNeutralColor,
        appBar: AppBar(
          title: Text(
            "Track Ride",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            // Refresh Button
            BlocBuilder<TrackingCubit, TrackingState>(
              builder: (context, state) {
                return IconButton(
                  icon: Icon(Icons.refresh, color: kPrimaryColor),
                  onPressed: () => context.read<TrackingCubit>().loadTrackingData(),
                );
              },
            )
          ],
        ),
        body: BlocConsumer<TrackingCubit, TrackingState>(
          listener: (context, state) {
            if (state is TrackingError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            if (state is TrackingLoading) {
              return Center(child: CircularProgressIndicator(color: kPrimaryColor));
            } else if (state is TrackingLoaded) {
              return _buildContent(state.data);
            } else if (state is TrackingError) {
               return Center(
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                     SizedBox(height: 16),
                     Text("Unable to track ride"),
                     TextButton(
                       onPressed: () => context.read<TrackingCubit>().loadTrackingData(),
                       child: Text("Retry"),
                     )
                   ],
                 ),
               );
            }
            return SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildContent(TrackingData data) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRouteHeaderCard(data),
          SizedBox(height: 20),
          Text(
            "Ride Details",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[800],
            ),
          ),
          SizedBox(height: 12),
          _buildInfoCard(data),
          SizedBox(height: 24),
          Text(
            "Timeline",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[800],
            ),
          ),
          SizedBox(height: 12),
          _buildTimelineList(data),
          SizedBox(height: 40),
        ],
      ),
    );
  }

  // 1. Top Card with Gradient for Route Info
  Widget _buildRouteHeaderCard(TrackingData data) {
    // Basic status logic
    bool isActive = data.occurrence.status.toLowerCase() == 'in_progress';
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryColor, kSecondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.all(24),
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
                    Text(
                      "Current Route",
                      style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1),
                    ),
                    SizedBox(height: 4),
                    Text(
                      data.route.name,
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive ? kSuccessColor.withOpacity(0.2) : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.3))
                ),
                child: Row(
                  children: [
                    Icon(Icons.directions_bus_filled, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      data.occurrence.status.replaceAll('_', ' ').toUpperCase(),
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 10),
                    ),
                  ],
                ),
              )
            ],
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHeaderStat("Stops", "${data.route.stops.length}"),
              _buildHeaderStat("Ride Type", data.ride.type.toUpperCase()),
              _buildHeaderStat("Kids", "${data.children.length}"), 
            ],
          )
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 11)),
        SizedBox(height: 4),
        Text(value, style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // 2. Driver & Bus Info Card
  Widget _buildInfoCard(TrackingData data) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          // Driver Section
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: kPrimaryColor.withOpacity(0.2), width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: data.driver.avatar != null 
                        ? NetworkImage(data.driver.avatar!) 
                        : null,
                    child: data.driver.avatar == null ? Icon(Icons.person, color: Colors.grey) : null,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Driver", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w600)),
                      Text(data.driver.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(data.driver.phone, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Implement URL Launcher for call
                  },
                  icon: Icon(Icons.phone, color: kSuccessColor),
                  style: IconButton.styleFrom(
                    backgroundColor: kSuccessColor.withOpacity(0.1),
                    padding: EdgeInsets.all(12),
                  ),
                )
              ],
            ),
          ),
          Divider(height: 1, indent: 20, endIndent: 20),
          // Bus Section
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.directions_bus, color: kPrimaryColor),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(data.bus.busNumber, style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(data.bus.plateNumber, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text("Lat: ${data.bus.currentLocation.lat.toStringAsFixed(4)}, Lng: ${data.bus.currentLocation.lng.toStringAsFixed(4)}",
                       style: TextStyle(color: Colors.grey, fontSize: 10)),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. Timeline List
  Widget _buildTimelineList(TrackingData data) {
    // Logic: Identify key stops (Pickup points for my children)
    // Create a Set of Stop IDs that are pickup points for the children on this ride
    final pickupPointIds = data.children
        .where((c) => c.pickupPoint != null)
        .map((c) => c.pickupPoint!.id)
        .toSet();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Column(
        children: List.generate(data.route.stops.length, (index) {
          final stop = data.route.stops[index];
          // Check if this stop is a pickup point for any of the kids
          final isMyPickup = pickupPointIds.contains(stop.id);
          
          return _buildTimelineTile(
            stop,
            isLast: index == data.route.stops.length - 1,
            isFirst: index == 0,
            isTarget: isMyPickup,
          );
        }),
      ),
    );
  }

  Widget _buildTimelineTile(RouteStop stop, {bool isLast = false, bool isFirst = false, bool isTarget = false}) {
    
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Line & Dot Column
          Container(
            width: 30,
            child: Column(
              children: [
                // Top Line
                if (!isFirst)
                  Expanded(
                    flex: 1,
                    child: Container(
                      width: 2,
                      color: Colors.grey[200],
                    ),
                  )
                else
                  Spacer(flex: 1),

                // The Dot/Icon
                Container(
                  width: isTarget ? 24 : 12,
                  height: isTarget ? 24 : 12,
                  decoration: BoxDecoration(
                    color: isTarget ? kPrimaryColor : Colors.white,
                    shape: BoxShape.circle,
                    border: isTarget
                        ? null
                        : Border.all(color: Colors.grey[300]!, width: 2),
                    boxShadow: isTarget
                        ? [BoxShadow(color: kPrimaryColor.withOpacity(0.4), blurRadius: 8, spreadRadius: 2)]
                        : null,
                  ),
                  child: isTarget
                      ? Icon(Icons.location_on, size: 14, color: Colors.white)
                      : null,
                ),

                // Bottom Line
                if (!isLast)
                  Expanded(
                    flex: 4,
                    child: Container(
                      width: 2,
                      color: Colors.grey[200],
                    ),
                  )
                else
                  Spacer(flex: 4),
              ],
            ),
          ),
          SizedBox(width: 16),
          // Content Column
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0, top: 0),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                padding: isTarget ? EdgeInsets.all(12) : EdgeInsets.zero,
                decoration: isTarget
                    ? BoxDecoration(
                        color: kPrimaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kPrimaryColor.withOpacity(0.1)),
                      )
                    : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          stop.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        if (isTarget)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: kPrimaryColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "Pickup Point",
                              style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      stop.address,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
