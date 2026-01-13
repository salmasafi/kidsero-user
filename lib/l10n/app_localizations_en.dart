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
}
