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
}
