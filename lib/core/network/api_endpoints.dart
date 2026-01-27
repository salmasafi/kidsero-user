class ApiEndpoints {
  static const String baseUrl = 'https://Bcknd.Kidsero.com';

  // Auth
  static const String login = '/api/users/auth/parent/login';

  // Rides
  static const String childRidesToday = '/api/users/driver/rides/today';

  // Profile
  static const String profile = '/api/users/profile/me';
  static const String changePassword = '/api/users/profile/change-password';
  static const String children = '/api/users/children/';
  static const String addChild = '/api/users/children/add';

  // Payments
  static const String parentPayments = '/api/users/parentpayments';
  static String parentPaymentDetail(String id) =>
      '/api/users/parentpayments/$id';
  static const String parentPaymentsOrgService =
      '/api/users/parentpayments/org-service';

  static String getImageUrl(String path) {
    if (path.startsWith('http')) return path;
    return '$baseUrl$path';
  }
}
