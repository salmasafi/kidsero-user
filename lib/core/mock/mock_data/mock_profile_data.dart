import 'package:kidsero_parent/features/profile/data/models/profile_response_model.dart';

import '../mock_config.dart';
import 'mock_auth_data.dart';

/// Mock profile data for testing
class MockProfileData {
  /// Mock profile response
  static ProfileResponseModel get profileResponse => ProfileResponseModel(
        success: true,
        profile: MockAuthData.currentUser,
      );

  /// Mock update profile response
  static Map<String, dynamic> updateProfileResponse(Map<String, dynamic> updates) => {
        'success': true,
        'data': {
          'message': 'Profile updated successfully',
          'profile': {
            'id': MockConfig.mockParentId,
            'name': updates['name'] ?? MockAuthData.currentUser.name,
            'phone': updates['phone'] ?? MockAuthData.currentUser.phone,
            'avatar': updates['avatar'] ?? MockAuthData.currentUser.avatar,
            'address': updates['address'] ?? MockAuthData.currentUser.address,
            'role': 'parent',
            'status': 'active',
          },
        },
      };

  /// Mock change password response - success
  static Map<String, dynamic> get changePasswordSuccessResponse => {
        'success': true,
        'data': {
          'message': 'Password changed successfully',
        },
      };

  /// Mock change password response - error
  static Map<String, dynamic> get changePasswordErrorResponse => {
        'success': false,
        'data': {
          'message': 'Current password is incorrect',
        },
      };

  /// Mock profile statistics
  static Map<String, dynamic> get profileStats => {
        'success': true,
        'data': {
          'totalChildren': 4,
          'activeSubscriptions': 3,
          'completedRidesThisMonth': 42,
          'upcomingPayments': 2,
          'pendingPayments': 1,
        },
      };

  /// Mock notification preferences
  static Map<String, dynamic> get notificationPreferences => {
        'success': true,
        'data': {
          'pushNotifications': true,
          'smsNotifications': true,
          'emailNotifications': false,
          'rideUpdates': true,
          'paymentReminders': true,
          'schoolAnnouncements': true,
          'emergencyAlerts': true,
        },
      };
}
