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
  String get paymentStatusPending => 'قيد الانتظار';

  @override
  String get paymentStatusCompleted => 'مكتملة';

  @override
  String get paymentStatusRejected => 'مرفوضة';

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
  String get tomorrow => 'Tomorrow';

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
  String get inProgress => 'قيد التنفيذ';

  @override
  String get pending => 'قيد الانتظار';

  @override
  String get excused => 'معذور';

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
  String get appSubscriptionsTitle => 'اشتراكات التطبيق';

  @override
  String get noAppSubscriptions => 'لا توجد لديك اشتراكات في التطبيق بعد.';

  @override
  String get browseParentPlans => 'استعرض خطط التطبيق أدناه للبدء.';

  @override
  String get parentPlansTitle => 'خطط التطبيق';

  @override
  String get subscribeAppPlan => 'اشترك في خطة التطبيق';

  @override
  String get subscribeSchoolPlan => 'اشترك في خطة المدرسة';

  @override
  String get activeServices => 'الخدمات النشطة';

  @override
  String get availableServices => 'الخدمات المتاحة';

  @override
  String get schoolSubscribedServices => 'اشتراكات المدرسة الحالية';

  @override
  String get availableSchoolServices => 'خدمات المدرسة المتاحة';

  @override
  String get filterByChild => 'تصفية حسب الطفل';

  @override
  String get noSchoolSubscriptions => 'لا توجد لديك اشتراكات مدرسية حالياً.';

  @override
  String get browseSchoolServices => 'استعرض الخدمات المدرسية المتاحة أدناه.';

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
  String get noActiveSubscriptions => 'لا توجد خدمات مدرسية نشطة';

  @override
  String get choosePlanToSubscribe => 'يرجى اختيار خدمة للاشتراك';

  @override
  String get chooseServiceToSubscribe => 'يرجى اختيار خدمة للاشتراك';

  @override
  String get student => 'الطالب';

  @override
  String get all => 'الكل';

  @override
  String get subscriptionFees => 'Service Fees';

  @override
  String get minPayment => 'Min. Payment';

  @override
  String get liveTracking => 'تتبع مباشر';

  @override
  String get timelineTracking => 'الجدول الزمني';

  @override
  String get morningRide => 'رحلة صباحية';

  @override
  String get afternoonRide => 'رحلة مسائية';

  @override
  String get reportAbsence => 'إبلاغ عن غياب';

  @override
  String get reportAbsenceDescription => 'يرجى تقديم سبب للغياب.';

  @override
  String get rideAlreadyStartedError =>
      'لا يمكن الإبلاغ عن غياب لرحلة بدأت بالفعل';

  @override
  String get reason => 'السبب';

  @override
  String get enterReasonHint => 'أدخل سبب الغياب...';

  @override
  String get cancel => 'إلغاء';

  @override
  String get submit => 'إرسال';

  @override
  String get rideSummary => 'ملخص الرحلات';

  @override
  String get totalScheduled => 'إجمالي المجدولة';

  @override
  String get attended => 'حضور';

  @override
  String get absent => 'غياب';

  @override
  String get lateLabel => 'متأخر';

  @override
  String get attendanceRate => 'نسبة الحضور';

  @override
  String get absenceReportedSuccessfully => 'تم الإبلاغ عن الغياب بنجاح';

  @override
  String get reasonRequired => 'السبب مطلوب';

  @override
  String get noActiveRides => 'لا رحلات نشطة';

  @override
  String get noActiveRidesDesc => 'لا توجد رحلات نشطة في الوقت الحالي.';

  @override
  String get close => 'إغلاق';

  @override
  String get paymentType => 'نوع الدفع';

  @override
  String get paymentMethod => 'طريقة الدفع';

  @override
  String get oneTimePayment => 'دفعة واحدة';

  @override
  String get installmentPayment => 'دفع بالتقسيط';

  @override
  String get numberOfInstallments => 'عدد الأقساط';

  @override
  String get perInstallmentAmount => 'قيمة كل قسط';

  @override
  String get remainingAmount => 'المبلغ المتبقي';

  @override
  String get installmentsRequired => 'عدد الأقساط مطلوب';

  @override
  String get installmentsMustBePositive =>
      'يجب أن يكون عدد الأقساط رقماً موجباً';

  @override
  String get selectFromGallery => 'اختر من المعرض';

  @override
  String get takePhoto => 'التقط صورة';

  @override
  String imageSizeError(String maxSize, String actualSize) {
    return 'حجم الصورة يتجاوز $maxSize ميجابايت. الصورة المحددة $actualSize.';
  }

  @override
  String get imagePickerError => 'فشل اختيار الصورة. يرجى المحاولة مرة أخرى.';

  @override
  String get changeImage => 'تغيير الصورة';

  @override
  String get planPayments => 'مدفوعات الخطط';

  @override
  String get servicePayments => 'مدفوعات الخدمات';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get noPlanPayments => 'لا توجد مدفوعات خطط';

  @override
  String get noPlanPaymentsDesc => 'لم تقم بأي مدفوعات خطط بعد.';

  @override
  String get noServicePayments => 'لا توجد مدفوعات خدمات';

  @override
  String get noServicePaymentsDesc => 'لم تقم بأي مدفوعات خدمات بعد.';

  @override
  String get paymentHistory => 'سجل المدفوعات';

  @override
  String get createPlanPayment => 'إنشاء دفعة خطة';

  @override
  String get createServicePayment => 'إنشاء دفعة خدمة';

  @override
  String get totalAmount => 'إجمالي المبلغ';

  @override
  String get notes => 'ملاحظات';

  @override
  String get upcomingNotices => 'Upcoming Notices';

  @override
  String get upcomingNoticesSubtitle => 'Stay informed about school events.';

  @override
  String get noUpcomingNotices => 'No Upcoming Notices';

  @override
  String get noUpcomingNoticesDesc =>
      'There are no events or holidays in the next few days.';

  @override
  String get noticeTypeHoliday => 'Holiday';

  @override
  String get noticeTypeEvent => 'Event';

  @override
  String get noticeTypeOther => 'Notice';

  @override
  String get ridesAffected => 'Rides affected';

  @override
  String get ridesNotAffected => 'Rides not affected';

  @override
  String inDays(int days) {
    return 'in $days days';
  }

  @override
  String get rejectionReason => 'سبب الرفض';

  @override
  String get service => 'خدمة';

  @override
  String get planRequired => 'الخطة مطلوبة';

  @override
  String get serviceRequired => 'الخدمة مطلوبة';

  @override
  String get studentRequired => 'الطالب مطلوب';

  @override
  String get paymentMethodRequired => 'طريقة الدفع مطلوبة';

  @override
  String get amountRequired => 'المبلغ مطلوب';

  @override
  String get amountMustBePositive => 'يجب أن يكون المبلغ أكبر من الصفر';

  @override
  String get receiptRequired => 'صورة الإيصال مطلوبة';

  @override
  String get optional => 'اختياري';

  @override
  String get errorNoInternet => 'يرجى التحقق من اتصالك بالإنترنت';

  @override
  String get errorSessionExpired =>
      'انتهت صلاحية جلستك. يرجى تسجيل الدخول مرة أخرى';

  @override
  String get errorServerUnavailable =>
      'الخادم غير متاح مؤقتاً. يرجى المحاولة لاحقاً';

  @override
  String get errorDataProcessing =>
      'تعذر معالجة البيانات. يرجى المحاولة مرة أخرى';

  @override
  String get errorNotFound => 'المورد المطلوب غير موجود';

  @override
  String get errorGeneric => 'حدث خطأ. يرجى المحاولة مرة أخرى';
}
