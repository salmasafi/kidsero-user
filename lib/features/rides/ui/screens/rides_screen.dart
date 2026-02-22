import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidsero_parent/core/widgets/stat_card.dart';
import 'package:kidsero_parent/core/widgets/child_card.dart';
import 'package:kidsero_parent/core/widgets/custom_empty_state.dart';
import 'package:kidsero_parent/features/notes/logic/cubit/upcoming_notes_cubit.dart';
import 'package:kidsero_parent/features/notes/ui/widgets/upcoming_notices_section.dart';
import 'package:kidsero_parent/l10n/app_localizations.dart';
import 'package:kidsero_parent/core/widgets/language_toggle.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/theme/app_colors.dart';
import 'ride_tracking_screen.dart';
import 'live_tracking_screen.dart';
import '../../cubit/rides_dashboard_cubit.dart';
import '../../data/rides_repository.dart';
import '../../../notes/data/notes_repository.dart';
import 'child_schedule_screen.dart';

/// Main Rides Dashboard Screen matching the new UI design
class RidesScreen extends StatefulWidget {
  const RidesScreen({super.key});

  @override
  State<RidesScreen> createState() => _RidesScreenState();
}

class _RidesScreenState extends State<RidesScreen> {
  late final RidesDashboardCubit _ridesDashboardCubit;
  late final UpcomingNotesCubit _upcomingNotesCubit;

  @override
  void initState() {
    super.initState();
    final ridesRepository = context.read<RidesRepository>();
    final notesRepository = context.read<NotesRepository>();
    final apiService = context.read<ApiService>();

    _ridesDashboardCubit = RidesDashboardCubit(
      repository: ridesRepository,
      apiService: apiService,
    )..loadDashboard();

    _upcomingNotesCubit = UpcomingNotesCubit(notesRepository)
      ..loadUpcomingNotes();
  }

  @override
  void dispose() {
    _ridesDashboardCubit.close();
    _upcomingNotesCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _ridesDashboardCubit),
        BlocProvider.value(value: _upcomingNotesCubit),
      ],
      child: const _RidesDashboard(),
    );
  }
}

class _RidesDashboard extends StatefulWidget {
  const _RidesDashboard();

  @override
  State<_RidesDashboard> createState() => _RidesDashboardState();
}

class _RidesDashboardState extends State<_RidesDashboard> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            context.read<RidesDashboardCubit>().loadDashboard(),
            context.read<UpcomingNotesCubit>().refresh(),
          ]);
        },
        child: CustomScrollView(
          slivers: [
            // Header with user greeting and stats
            SliverToBoxAdapter(child: _buildHeader(context, l10n)),

            // My Children section
            SliverToBoxAdapter(child: _buildMyChildrenSection(context, l10n)),

            // Upcoming notices section
            const SliverToBoxAdapter(child: UpcomingNoticesSection()),

            // Add some bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.parentGradient,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row with greeting and notification
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // User avatar
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getGreeting(l10n),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            l10n.welcomeBack,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Language button
                      IconButton(
                        onPressed: () => showLanguageDialog(context),
                        icon: const Icon(
                          Icons.translate,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Stats cards
              BlocBuilder<RidesDashboardCubit, RidesDashboardState>(
                builder: (context, state) {
                  int childrenCount = 0;
                  int liveCount = 0;
                  bool hasActiveRides = false;
                  String? firstActiveRideId;

                  if (state is RidesDashboardLoaded) {
                    childrenCount = state.childrenCount;
                    liveCount = state.activeRidesCount;
                    hasActiveRides = state.hasActiveRides;
                    firstActiveRideId = state.activeRides.isNotEmpty
                        ? state.activeRides.first.rideId
                        : null;
                  }

                  return Row(
                    children: [
                      // Children count card
                      StatCard(
                        icon: Icons.people_outline,
                        value: childrenCount.toString(),
                        label: l10n.children,
                        backgroundColor: Colors.white.withOpacity(0.15),
                      ),

                      const SizedBox(width: 12),

                      // Live rides card - expanded
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.sensors,
                                    size: 24,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    liveCount.toString(),
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTrackingButton(
                                      context: context,
                                      label: l10n.liveTracking,
                                      icon: Icons.map_outlined,
                                      onTap: () {
                                        if (hasActiveRides &&
                                            firstActiveRideId != null) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  LiveTrackingScreen(
                                                    rideId: firstActiveRideId!,
                                                  ),
                                            ),
                                          );
                                        }
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
                                        if (hasActiveRides &&
                                            firstActiveRideId != null) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  RideTrackingScreen(
                                                    rideId: firstActiveRideId!,
                                                  ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyChildrenSection(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.myChildren,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          BlocBuilder<RidesDashboardCubit, RidesDashboardState>(
            builder: (context, state) {
              if (state is RidesDashboardLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }

              if (state is RidesDashboardEmpty) {
                return CustomEmptyState(
                  icon: Icons.child_care,
                  title: l10n.noChildrenFound,
                  message: l10n.addChildrenToTrack,
                  onRefresh: () =>
                      context.read<RidesDashboardCubit>().loadDashboard(),
                );
              }

              if (state is RidesDashboardError) {
                return CustomEmptyState(
                  icon: Icons.error_outline,
                  title: l10n.failedToLoadChildren,
                  message: state.message,
                  onRefresh: () =>
                      context.read<RidesDashboardCubit>().loadDashboard(),
                );
              }

              if (state is RidesDashboardLoaded) {
                return SizedBox(
                  height: 190,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.children.length,
                    itemBuilder: (context, index) {
                      final child = state.children[index];
                      final colors = [
                        AppColors.primary,
                        AppColors.success,
                        AppColors.accent,
                        AppColors.secondary,
                      ];

                      return Padding(
                        padding: EdgeInsets.only(
                          right: index < state.children.length - 1 ? 12 : 0,
                        ),
                        child: ChildCard(
                          name: child.name,
                          avatarUrl: child.photoUrl,
                          initials: _getInitials(child.name),
                          grade: child.displayGrade.isNotEmpty ? child.displayGrade : null,
                          classroom: child.displayClassroom.isNotEmpty ? child.displayClassroom : null,
                          schoolName: child.displaySchoolName.isNotEmpty ? child.displaySchoolName : null,
                          isOnline: state.hasActiveRideForChild(child.id),
                          avatarColor: colors[index % colors.length],
                          onViewSchedule: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) => ChildScheduleScreen(
                                  childId: child.id,
                                  childName: child.name,
                                  childAvatar: child.photoUrl,
                                  initials: _getInitials(child.name),
                                  grade: child.displayGrade.isNotEmpty ? child.displayGrade : null,
                                  classroom: child.displayClassroom.isNotEmpty ? child.displayClassroom : null,
                                  schoolName: child.displaySchoolName.isNotEmpty ? child.displaySchoolName : null,
                                  avatarColor: colors[index % colors.length],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
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

  String _getGreeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return l10n.goodMorning;
    } else if (hour < 17) {
      return l10n.goodAfternoon;
    } else {
      return l10n.goodEvening;
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  Widget _buildTrackingButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
