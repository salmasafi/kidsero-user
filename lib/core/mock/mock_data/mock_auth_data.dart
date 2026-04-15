import 'package:kidsero_parent/features/auth/data/models/auth_response_model.dart';
import 'package:kidsero_parent/features/auth/data/models/user_model.dart';
import '../mock_config.dart';

/// Mock authentication data for testing
class MockAuthData {
  /// Mock login response
  static AuthResponseModel get loginResponse => AuthResponseModel(
        success: true,
        message: 'Login successful',
        token: MockConfig.mockToken,
        user: currentUser,
      );

  /// Mock current user
  static UserModel get currentUser => UserModel(
        id: MockConfig.mockParentId,
        name: 'Ahmed Hassan',
        phone: '+201234567890',
        avatar: null,
        address: 'Cairo, Egypt',
        role: 'parent',
        status: 'active',
        children: [],
      );

  /// Mock users list for testing different scenarios
  static List<UserModel> get mockParents => [
        currentUser,
        UserModel(
          id: 'mock-parent-002',
          name: 'Fatima Ali',
          phone: '+201112223344',
          avatar: null,
          address: 'Alexandria, Egypt',
          role: 'parent',
          status: 'active',
          children: [],
        ),
        UserModel(
          id: 'mock-parent-003',
          name: 'Mohamed Ibrahim',
          phone: '+209998887766',
          avatar: null,
          address: 'Giza, Egypt',
          role: 'parent',
          status: 'active',
          children: [],
        ),
      ];

  /// Invalid credentials error
  static Map<String, dynamic> get invalidCredentialsError => {
        'success': false,
        'message': 'Invalid phone number or password',
        'data': null,
      };

  /// Account locked error
  static Map<String, dynamic> get accountLockedError => {
        'success': false,
        'message': 'Account is locked. Please contact support.',
        'data': null,
      };
}
