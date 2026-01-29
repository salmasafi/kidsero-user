import 'package:flutter/material.dart';
import 'package:kidsero_driver/l10n/app_localizations.dart';
import '../theme/app_colors.dart';

/// A reusable child card widget for displaying child information
class ChildCard extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final String initials;
  final String grade;
  final String classroom;
  final bool isOnline;
  final VoidCallback? onViewSchedule;
  final Color? avatarColor;

  const ChildCard({
    Key? key,
    required this.name,
    this.avatarUrl,
    required this.initials,
    required this.grade,
    required this.classroom,
    this.isOnline = false,
    this.onViewSchedule,
    this.avatarColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color avColor = avatarColor ?? AppColors.primary;

    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar with online indicator
          Stack(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: avColor,
                backgroundImage: const AssetImage(
                  'assets/images/child_default.png',
                ),
                // Commented out for App Store submission - using default avatar
                // backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty
                //     ? NetworkImage(avatarUrl!)
                //     : const AssetImage('assets/images/child_default.png'),
                onBackgroundImageError: (exception, stackTrace) {
                  // Fallback handled by default image
                },
                // child: avatarUrl == null || avatarUrl!.isEmpty
                //     ? Text(
                //         initials,
                //         style: const TextStyle(
                //           color: Colors.white,
                //           fontSize: 20,
                //           fontWeight: FontWeight.bold,
                //         ),
                //       )
                //     : null,
              ),
              if (isOnline)
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00BFA5),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Name
          Text(
            name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Grade and Classroom
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school_outlined, size: 12, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  '$grade • $classroom',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // View Schedule link
          GestureDetector(
            onTap: onViewSchedule,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.viewSchedule,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
