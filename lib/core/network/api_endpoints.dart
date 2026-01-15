class ApiEndpoints {
  static const String baseUrl = 'https://Bcknd.Kidsero.com';

  // Auth
  static const String parentLogin = '/api/users/auth/parent/login';
  static const String driverLogin = '/api/users/auth/login';

  // Profile
  static const String profileMe = '/api/users/profile/me';
  static const String changePassword = '/api/users/profile/change-password';
  static const String children = '/api/users/children/';

  static String getImageUrl(String path) {
    if (path.startsWith('http')) return path;
    return '$baseUrl$path';
  }
}
