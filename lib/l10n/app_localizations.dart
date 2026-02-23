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

  /// No description provided for @imDriver.
  ///
  /// In en, this message translates to:
  /// **'I\'m a Driver'**
  String get imDriver;

  /// No description provided for @parentLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get parentLogin;

  /// No description provided for @driverLogin.
  ///
  /// In en, this message translates to:
  /// **'Driver Login'**
  String get driverLogin;

  /// No description provided for @enterCredentials.
  ///
  /// In en, this message translates to:
  /// **'Enter your credentials to access your account'**
  String get enterCredentials;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @emailOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Email/Phone Number'**
  String get emailOrPhone;

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

  /// No description provided for @imDriverDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage your route, update parents, and ensure safe journeys'**
  String get imDriverDesc;

  /// No description provided for @joinParents.
  ///
  /// In en, this message translates to:
  /// **'Join {count}+ parents'**
  String joinParents(Object count);

  /// No description provided for @trustedDrivers.
  ///
  /// In en, this message translates to:
  /// **'Trusted drivers network'**
  String get trustedDrivers;

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

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @paymentsRetrievedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Payments retrieved successfully'**
  String get paymentsRetrievedSuccessfully;

  /// No description provided for @paymentRetrievedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Payment retrieved successfully'**
  String get paymentRetrievedSuccessfully;

  /// No description provided for @paymentCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Payment created successfully'**
  String get paymentCreatedSuccessfully;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @receiptImage.
  ///
  /// In en, this message translates to:
  /// **'Receipt Image'**
  String get receiptImage;

  /// No description provided for @noPaymentsFound.
  ///
  /// In en, this message translates to:
  /// **'No payments found'**
  String get noPaymentsFound;

  /// No description provided for @failedToLoadPayments.
  ///
  /// In en, this message translates to:
  /// **'Failed to load payments'**
  String get failedToLoadPayments;

  /// No description provided for @createPayment.
  ///
  /// In en, this message translates to:
  /// **'Create Payment'**
  String get createPayment;

  /// No description provided for @paymentStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get paymentStatusPending;

  /// No description provided for @paymentStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get paymentStatusCompleted;

  /// No description provided for @paymentStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get paymentStatusRejected;

  /// No description provided for @plan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get plan;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @track.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get track;

  /// No description provided for @alerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alerts;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @liveRides.
  ///
  /// In en, this message translates to:
  /// **'Live Rides'**
  String get liveRides;

  /// No description provided for @viewSchedule.
  ///
  /// In en, this message translates to:
  /// **'View Schedule'**
  String get viewSchedule;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @liveNow.
  ///
  /// In en, this message translates to:
  /// **'LIVE NOW'**
  String get liveNow;

  /// No description provided for @trackLive.
  ///
  /// In en, this message translates to:
  /// **'Track Live'**
  String get trackLive;

  /// No description provided for @scheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get scheduled;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @excused.
  ///
  /// In en, this message translates to:
  /// **'Excused'**
  String get excused;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @driver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driver;

  /// No description provided for @eta.
  ///
  /// In en, this message translates to:
  /// **'ETA'**
  String get eta;

  /// No description provided for @noRidesToday.
  ///
  /// In en, this message translates to:
  /// **'No Rides Today'**
  String get noRidesToday;

  /// No description provided for @noRidesTodayDesc.
  ///
  /// In en, this message translates to:
  /// **'There are no rides scheduled for today.'**
  String get noRidesTodayDesc;

  /// No description provided for @noUpcomingRides.
  ///
  /// In en, this message translates to:
  /// **'No Upcoming Rides'**
  String get noUpcomingRides;

  /// No description provided for @noUpcomingRidesDesc.
  ///
  /// In en, this message translates to:
  /// **'There are no upcoming rides scheduled.'**
  String get noUpcomingRidesDesc;

  /// No description provided for @noRideHistory.
  ///
  /// In en, this message translates to:
  /// **'No Ride History'**
  String get noRideHistory;

  /// No description provided for @noRideHistoryDesc.
  ///
  /// In en, this message translates to:
  /// **'No past rides found.'**
  String get noRideHistoryDesc;

  /// No description provided for @scheduledRides.
  ///
  /// In en, this message translates to:
  /// **'Scheduled Rides'**
  String get scheduledRides;

  /// No description provided for @morningTrip.
  ///
  /// In en, this message translates to:
  /// **'Morning Trip'**
  String get morningTrip;

  /// No description provided for @returnTrip.
  ///
  /// In en, this message translates to:
  /// **'Return Trip'**
  String get returnTrip;

  /// No description provided for @homeToSchool.
  ///
  /// In en, this message translates to:
  /// **'Home → School'**
  String get homeToSchool;

  /// No description provided for @schoolToHome.
  ///
  /// In en, this message translates to:
  /// **'School → Home'**
  String get schoolToHome;

  /// No description provided for @errorLoadingRides.
  ///
  /// In en, this message translates to:
  /// **'Error Loading Rides'**
  String get errorLoadingRides;

  /// No description provided for @noChildrenFoundRides.
  ///
  /// In en, this message translates to:
  /// **'No Children Found'**
  String get noChildrenFoundRides;

  /// No description provided for @addChildrenToTrack.
  ///
  /// In en, this message translates to:
  /// **'Add your children to start tracking their rides.'**
  String get addChildrenToTrack;

  /// No description provided for @appServices.
  ///
  /// In en, this message translates to:
  /// **'App Services'**
  String get appServices;

  /// No description provided for @schoolServices.
  ///
  /// In en, this message translates to:
  /// **'School Services'**
  String get schoolServices;

  /// No description provided for @appSubscriptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'App Subscriptions'**
  String get appSubscriptionsTitle;

  /// No description provided for @noAppSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'You have no app subscriptions yet.'**
  String get noAppSubscriptions;

  /// No description provided for @browseParentPlans.
  ///
  /// In en, this message translates to:
  /// **'Browse the parent plans below to get started.'**
  String get browseParentPlans;

  /// No description provided for @parentPlansTitle.
  ///
  /// In en, this message translates to:
  /// **'Parent Plans'**
  String get parentPlansTitle;

  /// No description provided for @subscribeAppPlan.
  ///
  /// In en, this message translates to:
  /// **'Subscribe App Plan'**
  String get subscribeAppPlan;

  /// No description provided for @subscribeSchoolPlan.
  ///
  /// In en, this message translates to:
  /// **'Subscribe School Plan'**
  String get subscribeSchoolPlan;

  /// No description provided for @activeServices.
  ///
  /// In en, this message translates to:
  /// **'Active Services'**
  String get activeServices;

  /// No description provided for @availableServices.
  ///
  /// In en, this message translates to:
  /// **'Available Services'**
  String get availableServices;

  /// No description provided for @schoolSubscribedServices.
  ///
  /// In en, this message translates to:
  /// **'Subscribed School Services'**
  String get schoolSubscribedServices;

  /// No description provided for @availableSchoolServices.
  ///
  /// In en, this message translates to:
  /// **'Available School Services'**
  String get availableSchoolServices;

  /// No description provided for @filterByChild.
  ///
  /// In en, this message translates to:
  /// **'Filter by child'**
  String get filterByChild;

  /// No description provided for @noSchoolSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'You have no school service subscriptions yet.'**
  String get noSchoolSubscriptions;

  /// No description provided for @browseSchoolServices.
  ///
  /// In en, this message translates to:
  /// **'Browse the available school services below.'**
  String get browseSchoolServices;

  /// No description provided for @noServicesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Services Available'**
  String get noServicesAvailable;

  /// No description provided for @checkBackLater.
  ///
  /// In en, this message translates to:
  /// **'Check back later for new services.'**
  String get checkBackLater;

  /// No description provided for @noSchoolServices.
  ///
  /// In en, this message translates to:
  /// **'No School Services'**
  String get noSchoolServices;

  /// No description provided for @noServicesForChild.
  ///
  /// In en, this message translates to:
  /// **'No services available for this child.'**
  String get noServicesForChild;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @servicePlan.
  ///
  /// In en, this message translates to:
  /// **'Service Plan'**
  String get servicePlan;

  /// No description provided for @schoolService.
  ///
  /// In en, this message translates to:
  /// **'School Service'**
  String get schoolService;

  /// No description provided for @selectPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Select Payment Method'**
  String get selectPaymentMethod;

  /// No description provided for @uploadReceipt.
  ///
  /// In en, this message translates to:
  /// **'Upload Receipt'**
  String get uploadReceipt;

  /// No description provided for @tapToChooseReceipt.
  ///
  /// In en, this message translates to:
  /// **'Tap to choose receipt'**
  String get tapToChooseReceipt;

  /// No description provided for @subscribeNow.
  ///
  /// In en, this message translates to:
  /// **'Subscribe Now'**
  String get subscribeNow;

  /// No description provided for @noActiveSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'No active school services'**
  String get noActiveSubscriptions;

  /// No description provided for @choosePlanToSubscribe.
  ///
  /// In en, this message translates to:
  /// **'Please choose a service to subscribe'**
  String get choosePlanToSubscribe;

  /// No description provided for @chooseServiceToSubscribe.
  ///
  /// In en, this message translates to:
  /// **'Please choose a service to subscribe'**
  String get chooseServiceToSubscribe;

  /// No description provided for @student.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get student;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @subscriptionFees.
  ///
  /// In en, this message translates to:
  /// **'Service Fees'**
  String get subscriptionFees;

  /// No description provided for @minPayment.
  ///
  /// In en, this message translates to:
  /// **'Min. Payment'**
  String get minPayment;

  /// No description provided for @liveTracking.
  ///
  /// In en, this message translates to:
  /// **'Live Tracking'**
  String get liveTracking;

  /// No description provided for @timelineTracking.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timelineTracking;

  /// No description provided for @morningRide.
  ///
  /// In en, this message translates to:
  /// **'Morning Ride'**
  String get morningRide;

  /// No description provided for @afternoonRide.
  ///
  /// In en, this message translates to:
  /// **'Afternoon Ride'**
  String get afternoonRide;

  /// No description provided for @reportAbsence.
  ///
  /// In en, this message translates to:
  /// **'Report Absence'**
  String get reportAbsence;

  /// No description provided for @reportAbsenceDescription.
  ///
  /// In en, this message translates to:
  /// **'Please provide a reason for the absence.'**
  String get reportAbsenceDescription;

  /// No description provided for @rideAlreadyStartedError.
  ///
  /// In en, this message translates to:
  /// **'Cannot report absence for a ride that has already started'**
  String get rideAlreadyStartedError;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @enterReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Enter reason for absence...'**
  String get enterReasonHint;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @rideSummary.
  ///
  /// In en, this message translates to:
  /// **'Ride Summary'**
  String get rideSummary;

  /// No description provided for @totalScheduled.
  ///
  /// In en, this message translates to:
  /// **'Total Scheduled'**
  String get totalScheduled;

  /// No description provided for @attended.
  ///
  /// In en, this message translates to:
  /// **'Attended'**
  String get attended;

  /// No description provided for @absent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get absent;

  /// No description provided for @lateLabel.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get lateLabel;

  /// No description provided for @attendanceRate.
  ///
  /// In en, this message translates to:
  /// **'Attendance Rate'**
  String get attendanceRate;

  /// No description provided for @absenceReportedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Absence reported successfully'**
  String get absenceReportedSuccessfully;

  /// No description provided for @reasonRequired.
  ///
  /// In en, this message translates to:
  /// **'Reason is required'**
  String get reasonRequired;

  /// No description provided for @noActiveRides.
  ///
  /// In en, this message translates to:
  /// **'No Active Rides'**
  String get noActiveRides;

  /// No description provided for @noActiveRidesDesc.
  ///
  /// In en, this message translates to:
  /// **'There are no active rides at the moment.'**
  String get noActiveRidesDesc;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @paymentType.
  ///
  /// In en, this message translates to:
  /// **'Payment Type'**
  String get paymentType;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @oneTimePayment.
  ///
  /// In en, this message translates to:
  /// **'One-Time Payment'**
  String get oneTimePayment;

  /// No description provided for @installmentPayment.
  ///
  /// In en, this message translates to:
  /// **'Installment Payment'**
  String get installmentPayment;

  /// No description provided for @numberOfInstallments.
  ///
  /// In en, this message translates to:
  /// **'Number of Installments'**
  String get numberOfInstallments;

  /// No description provided for @perInstallmentAmount.
  ///
  /// In en, this message translates to:
  /// **'Per Installment'**
  String get perInstallmentAmount;

  /// No description provided for @remainingAmount.
  ///
  /// In en, this message translates to:
  /// **'Remaining Amount'**
  String get remainingAmount;

  /// No description provided for @installmentsRequired.
  ///
  /// In en, this message translates to:
  /// **'Number of installments is required'**
  String get installmentsRequired;

  /// No description provided for @installmentsMustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Number of installments must be a positive number'**
  String get installmentsMustBePositive;

  /// No description provided for @selectFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Select from Gallery'**
  String get selectFromGallery;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @imageSizeError.
  ///
  /// In en, this message translates to:
  /// **'Image size exceeds {maxSize} MB. Selected image is {actualSize}.'**
  String imageSizeError(String maxSize, String actualSize);

  /// No description provided for @imagePickerError.
  ///
  /// In en, this message translates to:
  /// **'Failed to select image. Please try again.'**
  String get imagePickerError;

  /// No description provided for @changeImage.
  ///
  /// In en, this message translates to:
  /// **'Change Image'**
  String get changeImage;

  /// No description provided for @planPayments.
  ///
  /// In en, this message translates to:
  /// **'Plan Payments'**
  String get planPayments;

  /// No description provided for @servicePayments.
  ///
  /// In en, this message translates to:
  /// **'Service Payments'**
  String get servicePayments;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noPlanPayments.
  ///
  /// In en, this message translates to:
  /// **'No Plan Payments'**
  String get noPlanPayments;

  /// No description provided for @noPlanPaymentsDesc.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t made any plan payments yet.'**
  String get noPlanPaymentsDesc;

  /// No description provided for @noServicePayments.
  ///
  /// In en, this message translates to:
  /// **'No Service Payments'**
  String get noServicePayments;

  /// No description provided for @noServicePaymentsDesc.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t made any service payments yet.'**
  String get noServicePaymentsDesc;

  /// No description provided for @paymentHistory.
  ///
  /// In en, this message translates to:
  /// **'Payment History'**
  String get paymentHistory;

  /// No description provided for @createPlanPayment.
  ///
  /// In en, this message translates to:
  /// **'Create Plan Payment'**
  String get createPlanPayment;

  /// No description provided for @createServicePayment.
  ///
  /// In en, this message translates to:
  /// **'Create Service Payment'**
  String get createServicePayment;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @upcomingNotices.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Notices'**
  String get upcomingNotices;

  /// No description provided for @upcomingNoticesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stay informed about school events.'**
  String get upcomingNoticesSubtitle;

  /// No description provided for @noUpcomingNotices.
  ///
  /// In en, this message translates to:
  /// **'No Upcoming Notices'**
  String get noUpcomingNotices;

  /// No description provided for @noUpcomingNoticesDesc.
  ///
  /// In en, this message translates to:
  /// **'There are no events or holidays in the next few days.'**
  String get noUpcomingNoticesDesc;

  /// No description provided for @noticeTypeHoliday.
  ///
  /// In en, this message translates to:
  /// **'Holiday'**
  String get noticeTypeHoliday;

  /// No description provided for @noticeTypeEvent.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get noticeTypeEvent;

  /// No description provided for @noticeTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Notice'**
  String get noticeTypeOther;

  /// No description provided for @ridesAffected.
  ///
  /// In en, this message translates to:
  /// **'Rides affected'**
  String get ridesAffected;

  /// No description provided for @ridesNotAffected.
  ///
  /// In en, this message translates to:
  /// **'Rides not affected'**
  String get ridesNotAffected;

  /// No description provided for @inDays.
  ///
  /// In en, this message translates to:
  /// **'in {days} days'**
  String inDays(int days);

  /// No description provided for @rejectionReason.
  ///
  /// In en, this message translates to:
  /// **'Rejection Reason'**
  String get rejectionReason;

  /// No description provided for @service.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get service;

  /// No description provided for @planRequired.
  ///
  /// In en, this message translates to:
  /// **'Plan is required'**
  String get planRequired;

  /// No description provided for @serviceRequired.
  ///
  /// In en, this message translates to:
  /// **'Service is required'**
  String get serviceRequired;

  /// No description provided for @studentRequired.
  ///
  /// In en, this message translates to:
  /// **'Student is required'**
  String get studentRequired;

  /// No description provided for @paymentMethodRequired.
  ///
  /// In en, this message translates to:
  /// **'Payment method is required'**
  String get paymentMethodRequired;

  /// No description provided for @amountRequired.
  ///
  /// In en, this message translates to:
  /// **'Amount is required'**
  String get amountRequired;

  /// No description provided for @amountMustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Amount must be greater than zero'**
  String get amountMustBePositive;

  /// No description provided for @receiptRequired.
  ///
  /// In en, this message translates to:
  /// **'Receipt image is required'**
  String get receiptRequired;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @errorNoInternet.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection'**
  String get errorNoInternet;

  /// No description provided for @errorSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please log in again'**
  String get errorSessionExpired;

  /// No description provided for @errorServerUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The server is temporarily unavailable. Please try again later'**
  String get errorServerUnavailable;

  /// No description provided for @errorDataProcessing.
  ///
  /// In en, this message translates to:
  /// **'Unable to process data. Please try again'**
  String get errorDataProcessing;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'The requested resource was not found'**
  String get errorNotFound;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again'**
  String get errorGeneric;
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
