import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Kidsero'**
  String get welcome;

  /// No description provided for @selectRole.
  ///
  /// In en, this message translates to:
  /// **'Please select your role to continue'**
  String get selectRole;

  /// No description provided for @imParent.
  ///
  /// In en, this message translates to:
  /// **'I\'m a Parent'**
  String get imParent;

  /// No description provided for @parentLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get parentLogin;

  /// No description provided for @enterCredentials.
  ///
  /// In en, this message translates to:
  /// **'Enter your credentials to access your account'**
  String get enterCredentials;

  /// No description provided for @emailOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Email/Phone Number'**
  String get emailOrPhone;

  /// No description provided for @enterEmailOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter your email or phone number'**
  String get enterEmailOrPhone;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @loginSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Login Successful'**
  String get loginSuccessful;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login Failed'**
  String get loginFailed;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @avatarUrl.
  ///
  /// In en, this message translates to:
  /// **'Avatar URL'**
  String get avatarUrl;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @oldPassword.
  ///
  /// In en, this message translates to:
  /// **'Old Password'**
  String get oldPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @failedToLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile'**
  String get failedToLoadProfile;

  /// No description provided for @updateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update failed'**
  String get updateFailed;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @passwordChangeFailed.
  ///
  /// In en, this message translates to:
  /// **'Password change failed'**
  String get passwordChangeFailed;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangedSuccessfully;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong, please try again'**
  String get somethingWentWrong;

  /// No description provided for @safeRides.
  ///
  /// In en, this message translates to:
  /// **'Safe rides for your little ones'**
  String get safeRides;

  /// No description provided for @imParentDesc.
  ///
  /// In en, this message translates to:
  /// **'Track your child\'s bus, communicate with drivers, and manage pickups'**
  String get imParentDesc;

  /// No description provided for @joinParents.
  ///
  /// In en, this message translates to:
  /// **'Join {count}+ parents'**
  String joinParents(Object count);

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @contactAdmin.
  ///
  /// In en, this message translates to:
  /// **'Contact Admin'**
  String get contactAdmin;

  /// No description provided for @trackSafely.
  ///
  /// In en, this message translates to:
  /// **'Track your child safely'**
  String get trackSafely;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @byContinuing.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our'**
  String get byContinuing;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @childrenCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Registered Children'**
  String childrenCount(Object count);

  /// No description provided for @updateYourInfo.
  ///
  /// In en, this message translates to:
  /// **'Update your information'**
  String get updateYourInfo;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update your password'**
  String get updatePassword;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @manageNotifications.
  ///
  /// In en, this message translates to:
  /// **'Manage notifications'**
  String get manageNotifications;

  /// No description provided for @privacySecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacySecurity;

  /// No description provided for @controlYourData.
  ///
  /// In en, this message translates to:
  /// **'Control your data'**
  String get controlYourData;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @getHelp.
  ///
  /// In en, this message translates to:
  /// **'Get help'**
  String get getHelp;

  /// No description provided for @readOnlyFields.
  ///
  /// In en, this message translates to:
  /// **'These fields cannot be changed'**
  String get readOnlyFields;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @noAddressProvided.
  ///
  /// In en, this message translates to:
  /// **'No address provided'**
  String get noAddressProvided;

  /// No description provided for @tapToViewClearly.
  ///
  /// In en, this message translates to:
  /// **'Tap to view clearly'**
  String get tapToViewClearly;

  /// No description provided for @avatarUrlOptional.
  ///
  /// In en, this message translates to:
  /// **'Avatar URL (Optional)'**
  String get avatarUrlOptional;

  /// No description provided for @children.
  ///
  /// In en, this message translates to:
  /// **'Children'**
  String get children;

  /// No description provided for @myChildren.
  ///
  /// In en, this message translates to:
  /// **'My Children'**
  String get myChildren;

  /// No description provided for @noChildrenFound.
  ///
  /// In en, this message translates to:
  /// **'No Children Found'**
  String get noChildrenFound;

  /// No description provided for @noChildrenDescription.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t added any children yet'**
  String get noChildrenDescription;

  /// No description provided for @grade.
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get grade;

  /// No description provided for @classroom.
  ///
  /// In en, this message translates to:
  /// **'Classroom'**
  String get classroom;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @failedToLoadChildren.
  ///
  /// In en, this message translates to:
  /// **'Failed to load children'**
  String get failedToLoadChildren;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'de', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
