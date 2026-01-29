// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get welcome => 'مرحباً بك في كيدسيرو';

  @override
  String get selectRole => 'يرجى اختيار دورك للمتابعة';

  @override
  String get imParent => 'أنا ولي أمر';

  @override
  String get imDriver => 'أنا سائق';

  @override
  String get parentLogin => 'تسجيل الدخول';

  @override
  String get driverLogin => 'تسجيل دخول السائق';

  @override
  String get enterCredentials =>
      'أدخل بيانات الاعتماد الخاصة بك للوصول إلى حسابك';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get emailOrPhone => 'البريد الإلكتروني / رقم الهاتف';

  @override
  String get password => 'كلمة المرور';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get loginSuccessful => 'تم تسجيل الدخول بنجاح';

  @override
  String get loginFailed => 'فشل تسجيل الدخول';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get avatarUrl => 'رابط الصورة الشخصية';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get oldPassword => 'كلمة المرور القديمة';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get failedToLoadProfile => 'فشل تحميل الملف الشخصي';

  @override
  String get updateFailed => 'فشل التحديث';

  @override
  String get profileUpdatedSuccessfully => 'تم تحديث الملف الشخصي بنجاح';

  @override
  String get passwordChangeFailed => 'فشل تغيير كلمة المرور';

  @override
  String get passwordChangedSuccessfully => 'تم تغيير كلمة المرور بنجاح';

  @override
  String get somethingWentWrong => 'حدث خطأ ما، يرجى المحاولة مرة أخرى';

  @override
  String get safeRides => 'رحلات آمنة لأطفالكم';

  @override
  String get imParentDesc =>
      'تتبع حافلة طفلك، تواصل مع السائقين، وأدر عمليات التوصيل';

  @override
  String get imDriverDesc => 'أدر مسارك، أبلغ أولياء الأمور، واضمن رحلات آمنة';

  @override
  String joinParents(Object count) {
    return 'انضم لأكثر من $count ولي أمر';
  }

  @override
  String get trustedDrivers => 'شبكة سائقين موثوقين';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟';

  @override
  String get contactAdmin => 'تواصل مع المسؤول';

  @override
  String get trackSafely => 'تتبع طفلك بأمان';

  @override
  String get phoneRequired => 'رقم الهاتف مطلوب';

  @override
  String get passwordRequired => 'كلمة المرور مطلوبة';

  @override
  String get termsOfService => 'شروط الخدمة';

  @override
  String get byContinuing => 'بالمتابعة، أنت توافق على';

  @override
  String get language => 'اللغة';

  @override
  String childrenCount(Object count) {
    return '$count أطفال مسجلين';
  }

  @override
  String get updateYourInfo => 'تحديث معلوماتك';

  @override
  String get updatePassword => 'تحديث كلمة المرور';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get manageNotifications => 'إدارة الإشعارات';

  @override
  String get privacySecurity => 'الخصوصية والأمان';

  @override
  String get controlYourData => 'تحكم في بياناتك';

  @override
  String get helpSupport => 'المساعدة والدعم';

  @override
  String get getHelp => 'احصل على المساعدة';

  @override
  String get readOnlyFields => 'هذه الحقول لا يمكن تغييرها';

  @override
  String get phone => 'الهاتف';

  @override
  String get role => 'الدور';

  @override
  String get noAddressProvided => 'لا يوجد عنوان';

  @override
  String get tapToViewClearly => 'انقر للعرض بوضوح';

  @override
  String get avatarUrlOptional => 'رابط الصورة (اختياري)';

  @override
  String get children => 'أطفال';

  @override
  String get myChildren => 'أطفالي';

  @override
  String get noChildrenFound => 'لم يتم العثور على أطفال';

  @override
  String get noChildrenDescription => 'لم تقم بإضافة أي أطفال بعد';

  @override
  String get grade => 'الصف';

  @override
  String get classroom => 'الفصل';

  @override
  String get status => 'الحالة';

  @override
  String get active => 'نشط';

  @override
  String get inactive => 'غير نشط';

  @override
  String get failedToLoadChildren => 'فشل في تحميل الأطفال';

  @override
  String get payments => 'المدفوعات';

  @override
  String get payment => 'الدفعة';

  @override
  String get paymentsRetrievedSuccessfully => 'تم استرداد المدفوعات بنجاح';

  @override
  String get paymentRetrievedSuccessfully => 'تم استرداد الدفعة بنجاح';

  @override
  String get paymentCreatedSuccessfully => 'تم إنشاء الدفعة بنجاح';

  @override
  String get amount => 'المبلغ';

  @override
  String get date => 'التاريخ';

  @override
  String get receiptImage => 'صورة الإيصال';

  @override
  String get noPaymentsFound => 'لم يتم العثور على مدفوعات';

  @override
  String get failedToLoadPayments => 'فشل تحميل المدفوعات';

  @override
  String get createPayment => 'إنشاء دفعة';

  @override
  String get plan => 'الخطة';

  @override
  String get home => 'الرئيسية';

  @override
  String get track => 'تتبع';

  @override
  String get alerts => 'التنبيهات';

  @override
  String get goodMorning => 'صباح الخير';

  @override
  String get goodAfternoon => 'مساء الخير';

  @override
  String get goodEvening => 'مساء الخير';

  @override
  String get welcomeBack => 'مرحباً بعودتك';

  @override
  String get liveRides => 'رحلات مباشرة';

  @override
  String get viewSchedule => 'عرض الجدول';

  @override
  String get today => 'اليوم';

  @override
  String get upcoming => 'القادمة';

  @override
  String get history => 'السجل';

  @override
  String get liveNow => 'مباشر الآن';

  @override
  String get trackLive => 'تتبع مباشر';

  @override
  String get scheduled => 'مجدولة';

  @override
  String get completed => 'مكتملة';

  @override
  String get cancelled => 'ملغاة';

  @override
  String get driver => 'السائق';

  @override
  String get eta => 'الوقت المتوقع';

  @override
  String get noRidesToday => 'لا رحلات اليوم';

  @override
  String get noRidesTodayDesc => 'لا توجد رحلات مجدولة لهذا اليوم.';

  @override
  String get noUpcomingRides => 'لا رحلات قادمة';

  @override
  String get noUpcomingRidesDesc => 'لا توجد رحلات مجدولة قادمة.';

  @override
  String get noRideHistory => 'لا سجل رحلات';

  @override
  String get noRideHistoryDesc => 'لم يتم العثور على رحلات سابقة.';

  @override
  String get scheduledRides => 'الرحلات المجدولة';

  @override
  String get morningTrip => 'الرحلة الصباحية';

  @override
  String get returnTrip => 'رحلة العودة';

  @override
  String get homeToSchool => 'المنزل ← المدرسة';

  @override
  String get schoolToHome => 'المدرسة ← المنزل';

  @override
  String get errorLoadingRides => 'خطأ في تحميل الرحلات';

  @override
  String get noChildrenFoundRides => 'لم يتم العثور على أطفال';

  @override
  String get addChildrenToTrack => 'أضف أطفالك للبدء في تتبع رحلاتهم.';

  @override
  String get appServices => 'خدمات التطبيق';

  @override
  String get schoolServices => 'خدمات المدرسة';

  @override
  String get activeServices => 'الخدمات النشطة';

  @override
  String get availableServices => 'الخدمات المتاحة';

  @override
  String get noServicesAvailable => 'لا توجد خدمات متاحة';

  @override
  String get checkBackLater => 'تحقق لاحقاً من وجود خدمات جديدة.';

  @override
  String get noSchoolServices => 'لا توجد خدمات مدرسية';

  @override
  String get noServicesForChild => 'لا توجد خدمات متاحة لهذا الطفل.';

  @override
  String get price => 'السعر';

  @override
  String get servicePlan => 'خطة الخدمة';

  @override
  String get schoolService => 'خدمة مدرسية';

  @override
  String get selectPaymentMethod => 'اختر طريقة الدفع';

  @override
  String get uploadReceipt => 'تحميل الإيصال';

  @override
  String get tapToChooseReceipt => 'انقر لاختيار الإيصال';

  @override
  String get subscribeNow => 'اشترك الآن';

  @override
  String get noActiveSubscriptions => 'لا توجد اشتراكات نشطة';

  @override
  String get choosePlanToSubscribe => 'يرجى اختيار خطة للاشتراك';

  @override
  String get chooseServiceToSubscribe => 'يرجى اختيار خدمة للاشتراك';

  @override
  String get student => 'الطالب';

  @override
  String get liveTracking => 'تتبع مباشر';

  @override
  String get timelineTracking => 'الجدول الزمني';
}
