import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidsero_driver/features/rides/models/ride_models.dart';

import '../../../../core/network/api_service.dart';
import '../../../../core/widgets/custom_empty_state.dart';
import '../../../track_ride/ui/ride_tracking_screen.dart';
import '../../cubit/active_rides_cubit.dart';
import '../../cubit/ride_cubit.dart';
import '../../cubit/upcoming_rides_cubit.dart';

class RidesScreen extends StatelessWidget {
  const RidesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();

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
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: Color(0xFFF5F7FA),
          appBar: AppBar(
            elevation: 0,
            title: Text("Rides", style: TextStyle(color: Colors.white)),
            backgroundColor: Color(0xFF4F46E5),
            bottom: TabBar(
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: [
                Tab(text: "My Children"),
                Tab(text: "Active"),
                Tab(text: "Upcoming"),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              ChildrenRidesView(),
              ActiveRidesView(),
              UpcomingRidesView(),
            ],
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------------
// TAB 1: MY CHILDREN (Refactored to remove static Track button)
// --------------------------------------------------------

class ChildrenRidesView extends StatelessWidget {
  const ChildrenRidesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RideCubit, RideState>(
      builder: (context, state) {
        if (state is RideLoading) {
          return Center(
            child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
          );
        } else if (state is ChildrenRidesLoaded) {
          return RefreshIndicator(
            onRefresh: () => context.read<RideCubit>().loadChildrenRides(),
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: state.children.length,
              itemBuilder: (context, index) =>
                  ChildRidesCard(child: state.children[index]),
            ),
          );
        } else if (state is RideEmpty) {
          return CustomEmptyState(
            icon: Icons.family_restroom_rounded,
            title: "No Rides Configured",
            message: "Your children have no scheduled rides.",
            onRefresh: () => context.read<RideCubit>().loadChildrenRides(),
          );
        }
        return SizedBox();
      },
    );
  }
}

class ChildRidesCard extends StatelessWidget {
  final Child child;

  const ChildRidesCard({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Child Header ---
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Color(0xFF4F46E5).withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 26,
                    backgroundImage: child.avatar != null
                        ? NetworkImage(child.avatar!)
                        : null,
                    backgroundColor: Colors.grey[100],
                    child: child.avatar == null
                        ? Icon(Icons.person, color: Colors.grey[400], size: 28)
                        : null,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        child.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey[900],
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${child.grade ?? 'N/A'} • ${child.organization?.name ?? 'Unknown Org'}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- Divider with Label ---
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            color: Colors.grey[50],
            child: Text(
              "TODAY'S RIDES",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.grey[500],
              ),
            ),
          ),

          // --- Rides List ---
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: child.rides.isEmpty
                  ? [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.directions_bus_outlined,
                                size: 40,
                                color: Colors.grey[300],
                              ),
                              SizedBox(height: 8),
                              Text(
                                "No rides scheduled",
                                style: TextStyle(color: Colors.grey[400]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ]
                  : child.rides
                        .map((ride) => _buildRideTile(context, ride))
                        .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRideTile(BuildContext context, Ride ride) {
    final isMorning = ride.type.toLowerCase().contains('morning');

    // Theme Colors based on Morning/Afternoon
    final primaryColor = isMorning ? Colors.teal[700]! : Color(0xFF6366F1);
    final bgTint = isMorning ? Colors.teal[50]! : Color(0xFFEEF2FF);
    final iconData = isMorning
        ? Icons.wb_sunny_rounded
        : Icons.nights_stay_rounded;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Section: Time and Info
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time Box
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: bgTint,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(iconData, color: primaryColor, size: 20),
                      SizedBox(height: 6),
                      Text(
                        ride.pickupTime.split(
                          " ",
                        )[0], // Assuming "07:00 AM" format, grab "07:00"
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        ride.pickupTime.split(" ").length > 1
                            ? ride.pickupTime.split(" ")[1]
                            : "", // AM/PM
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),

                // Ride Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isMorning ? "Morning Pickup" : "Afternoon Drop-off",
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          // Frequency Chip
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: ride.frequency == 'once'
                                  ? Colors.red[50]
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: ride.frequency == 'once'
                                    ? Colors.red[100]!
                                    : Colors.grey[300]!,
                              ),
                            ),
                            child: Text(
                              ride.frequency.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: ride.frequency == 'once'
                                    ? Colors.red
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        ride.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.grey[900],
                        ),
                      ),
                      SizedBox(height: 4),
                      if (ride.bus != null)
                        Row(
                          children: [
                            Icon(
                              Icons.directions_bus,
                              size: 14,
                              color: Colors.grey[500],
                            ),
                            SizedBox(width: 4),
                            Text(
                              "Bus No: ${ride.bus!.busNumber}",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
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
}

class ActiveRidesView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActiveRidesCubit, ActiveRidesState>(
      builder: (context, state) {
        if (state is ActiveRidesLoading) {
          return Center(
            child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
          );
        } else if (state is ActiveRidesLoaded) {
          return RefreshIndicator(
            onRefresh: () => context.read<ActiveRidesCubit>().loadActiveRides(),
            child: ListView.builder(
              padding: EdgeInsets.all(20), // Increased padding
              itemCount: state.rides.length,
              itemBuilder: (context, index) =>
                  ActiveRideCard(ride: state.rides[index]),
            ),
          );
        } else if (state is ActiveRidesEmpty) {
          return CustomEmptyState(
            icon: Icons.directions_bus_filled_outlined,
            title: "No Active Rides",
            message: "There are no rides happening right now.",
            onRefresh: () => context.read<ActiveRidesCubit>().loadActiveRides(),
          );
        }
        return SizedBox();
      },
    );
  }
}

class ActiveRideCard extends StatelessWidget {
  final ActiveRide ride;
  const ActiveRideCard({Key? key, required this.ride}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine status color (Green for active)
    final statusColor = Colors.green;
    final statusBg = Colors.green[50]!;

    return Container(
      margin: EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // --- Upper Section ---
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Status Badge + Ride Name
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.sensors_rounded,
                            size: 14,
                            color: statusColor,
                          ),
                          SizedBox(width: 6),
                          Text(
                            "LIVE NOW",
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      ride.rideName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Info Row 1: Child
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color(0xFFEEF2FF),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        color: Color(0xFF4F46E5),
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Passenger",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          ride.childName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.grey[900],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Info Row 2: Bus
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.directions_bus_rounded,
                        color: Colors.orange[700],
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Vehicle",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          ride.busNumber,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.grey[900],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- Footer Button (Seamless) ---
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      RideTrackingScreen(rideId: ride.occurrenceId),
                ),
              );
            },
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: Color(0xFF4F46E5),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Track Ride",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------------
// TAB 3: UPCOMING RIDES (Refactored for Beauty)
// --------------------------------------------------------

class UpcomingRidesView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UpcomingRidesCubit, UpcomingRidesState>(
      builder: (context, state) {
        if (state is UpcomingRidesLoading) {
          return Center(
            child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
          );
        } else if (state is UpcomingRidesLoaded) {
          return RefreshIndicator(
            onRefresh: () =>
                context.read<UpcomingRidesCubit>().loadUpcomingRides(),
            child: ListView.builder(
              padding: EdgeInsets.all(20),
              itemCount: state.days.length,
              itemBuilder: (context, index) {
                final day = state.days[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Styled Date Header
                    Container(
                      margin: EdgeInsets.only(top: 8, bottom: 16),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${day.dayName}, ${day.date}".toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Colors.grey[600],
                          fontSize: 12,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    ...day.rides
                        .map((ride) => UpcomingRideTile(ride: ride))
                        .toList(),
                    SizedBox(height: 12),
                  ],
                );
              },
            ),
          );
        } else if (state is UpcomingRidesEmpty) {
          return CustomEmptyState(
            icon: Icons.calendar_month_outlined,
            title: "No Upcoming Rides",
            message: "No rides scheduled for the next few days.",
            onRefresh: () =>
                context.read<UpcomingRidesCubit>().loadUpcomingRides(),
          );
        }
        return SizedBox();
      },
    );
  }
}

class UpcomingRideTile extends StatelessWidget {
  final UpcomingRide ride;
  const UpcomingRideTile({Key? key, required this.ride}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Randomize color logic based on AM/PM if available, or just default purple
    final isMorning = ride.pickupTime.toLowerCase().contains("am");
    final tintColor = isMorning ? Colors.teal[50] : Color(0xFFEEF2FF);
    final iconColor = isMorning ? Colors.teal[700] : Color(0xFF4F46E5);
    final timeIcon = isMorning
        ? Icons.wb_sunny_rounded
        : Icons.nights_stay_rounded;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Time Column
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: tintColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(timeIcon, color: iconColor, size: 20),
                  SizedBox(height: 4),
                  Text(
                    ride.pickupTime.split(" ")[0],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.grey[800],
                    ),
                  ),
                  Text(
                    ride.pickupTime.split(" ").length > 1
                        ? ride.pickupTime.split(" ")[1]
                        : "",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),

            // Details Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ride.rideName,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.grey[900],
                    ),
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        size: 14,
                        color: Colors.grey[400],
                      ),
                      SizedBox(width: 4),
                      Text(
                        ride.childName,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Colors.grey[400],
                      ),
                      SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          ride.pickupPointName ?? 'Standard Pickup',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
