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
  String get parentLogin => 'تسجيل دخول ولي الأمر';

  @override
  String get driverLogin => 'تسجيل دخول السائق';

  @override
  String get enterCredentials =>
      'أدخل بيانات الاعتماد الخاصة بك للوصول إلى حسابك';

  @override
  String get phoneNumber => 'رقم الهاتف';

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
}
