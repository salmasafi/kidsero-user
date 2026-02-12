import 'package:flutter/material.dart';
import 'package:kidsero_driver/l10n/app_localizations.dart';
import '../theme/app_colors.dart';

/// A reusable child card widget for displaying child information
class ChildCard extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final String initials;
  final String? grade;
  final String? classroom;
  final String? schoolName;
  final bool isOnline;
  final VoidCallback? onViewSchedule;
  final Color? avatarColor;

  const ChildCard({
    super.key,
    required this.name,
    this.avatarUrl,
    required this.initials,
    this.grade,
    this.classroom,
    this.schoolName,
    this.isOnline = false,
    this.onViewSchedule,
    this.avatarColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color avColor = avatarColor ?? AppColors.primary;
    final bool hasGradeOrClassroom = 
        (grade != null && grade!.isNotEmpty) || 
        (classroom != null && classroom!.isNotEmpty);

    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                      color: AppColors.success,
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
          // Grade and Classroom or School Name
          if (hasGradeOrClassroom)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.school_outlined, size: 12, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    _buildGradeClassroomText(),
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
          else if (schoolName != null && schoolName!.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.business_outlined, size: 12, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    schoolName!,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
          else
            SizedBox(height: 16), // Maintain spacing when no info available
          
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

  String _buildGradeClassroomText() {
    final hasGrade = grade != null && grade!.isNotEmpty;
    final hasClassroom = classroom != null && classroom!.isNotEmpty;
    
    if (hasGrade && hasClassroom) {
      return '$grade • $classroom';
    } else if (hasGrade) {
      return grade!;
    } else if (hasClassroom) {
      return classroom!;
    }
    return '';
  }
}
