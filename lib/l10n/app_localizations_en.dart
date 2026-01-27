// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcome => 'Welcome to Kidsero';

  @override
  String get selectRole => 'Please select your role to continue';

  @override
  String get imParent => 'I\'m a Parent';

  @override
  String get imDriver => 'I\'m a Driver';

  @override
  String get parentLogin => 'Parent Login';

  @override
  String get driverLogin => 'Driver Login';

  @override
  String get enterCredentials =>
      'Enter your credentials to access your account';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get password => 'Password';

  @override
  String get login => 'Login';

  @override
  String get loginSuccessful => 'Login Successful';

  @override
  String get loginFailed => 'Login Failed';

  @override
  String get profile => 'Profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get changePassword => 'Change Password';

  @override
  String get logout => 'Logout';

  @override
  String get fullName => 'Full Name';

  @override
  String get avatarUrl => 'Avatar URL';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get oldPassword => 'Old Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get failedToLoadProfile => 'Failed to load profile';

  @override
  String get updateFailed => 'Update failed';

  @override
  String get profileUpdatedSuccessfully => 'Profile updated successfully';

  @override
  String get passwordChangeFailed => 'Password change failed';

  @override
  String get passwordChangedSuccessfully => 'Password changed successfully';

  @override
  String get somethingWentWrong => 'Something went wrong, please try again';

  @override
  String get safeRides => 'Safe rides for your little ones';

  @override
  String get imParentDesc =>
      'Track your child\'s bus, communicate with drivers, and manage pickups';

  @override
  String get imDriverDesc =>
      'Manage your route, update parents, and ensure safe journeys';

  @override
  String joinParents(Object count) {
    return 'Join $count+ parents';
  }

  @override
  String get trustedDrivers => 'Trusted drivers network';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get contactAdmin => 'Contact Admin';

  @override
  String get trackSafely => 'Track your child safely';

  @override
  String get phoneRequired => 'Phone number is required';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get byContinuing => 'By continuing, you agree to our';

  @override
  String get language => 'Language';

  @override
  String childrenCount(Object count) {
    return '$count Registered Children';
  }

  @override
  String get updateYourInfo => 'Update your information';

  @override
  String get updatePassword => 'Update your password';

  @override
  String get notifications => 'Notifications';

  @override
  String get manageNotifications => 'Manage notifications';

  @override
  String get privacySecurity => 'Privacy & Security';

  @override
  String get controlYourData => 'Control your data';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get getHelp => 'Get help';

  @override
  String get readOnlyFields => 'These fields cannot be changed';

  @override
  String get phone => 'Phone';

  @override
  String get role => 'Role';

  @override
  String get noAddressProvided => 'No address provided';

  @override
  String get tapToViewClearly => 'Tap to view clearly';

  @override
  String get avatarUrlOptional => 'Avatar URL (Optional)';

  @override
  String get children => 'Children';

  @override
  String get myChildren => 'My Children';

  @override
  String get noChildrenFound => 'No Children Found';

  @override
  String get noChildrenDescription => 'You haven\'t added any children yet';

  @override
  String get grade => 'Grade';

  @override
  String get classroom => 'Classroom';

  @override
  String get status => 'Status';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get failedToLoadChildren => 'Failed to load children';

  @override
  String get payments => 'Payments';

  @override
  String get payment => 'Payment';

  @override
  String get paymentsRetrievedSuccessfully => 'Payments retrieved successfully';

  @override
  String get paymentRetrievedSuccessfully => 'Payment retrieved successfully';

  @override
  String get paymentCreatedSuccessfully => 'Payment created successfully';

  @override
  String get amount => 'Amount';

  @override
  String get date => 'Date';

  @override
  String get receiptImage => 'Receipt Image';

  @override
  String get noPaymentsFound => 'No payments found';

  @override
  String get failedToLoadPayments => 'Failed to load payments';

  @override
  String get createPayment => 'Create Payment';

  @override
  String get plan => 'Plan';
}
