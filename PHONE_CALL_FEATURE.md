# ميزة الاتصال بالسائق

## الوصف
تم إضافة ميزة الاتصال بالسائق مباشرة من التطبيق عند الضغط على أيقونة الهاتف.

## الملفات المضافة/المعدلة

### 1. ملف جديد: `lib/core/utils/phone_utils.dart`
**الوظيفة**: Helper class للتعامل مع المكالمات الهاتفية

**الميزات**:
- `makePhoneCall(phoneNumber)` - فتح تطبيق الهاتف للاتصال برقم محدد
- `formatPhoneNumber(phoneNumber)` - تنسيق رقم الهاتف للعرض
- دعم كامل لـ Android و iOS
- تنظيف الرقم تلقائياً (إزالة المسافات والشرطات)
- Logging تفصيلي للتتبع

**مثال الاستخدام**:
```dart
final success = await PhoneUtils.makePhoneCall('+966501234567');
if (!success) {
  // عرض رسالة خطأ
}
```

### 2. ملف معدل: `lib/features/rides/ui/screens/ride_tracking_screen.dart`
**التعديلات**:
- إضافة import لـ `PhoneUtils`
- إضافة helper method `_handlePhoneCall()` في كلا الـ classes:
  - `_RideTrackingScreenState`
  - `_RideTrackingScreenByOccurrenceState`
- تحديث أزرار الاتصال (2 أزرار) لاستدعاء `_handlePhoneCall()`

**الكود**:
```dart
// Helper method
Future<void> _handlePhoneCall(BuildContext context, String phoneNumber) async {
  final success = await PhoneUtils.makePhoneCall(phoneNumber);
  if (!success && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Unable to make phone call'),
        backgroundColor: AppColors.error,
      ),
    );
  }
}

// استخدام في الزر
IconButton(
  onPressed: () => _handlePhoneCall(context, data.driver.phone),
  icon: const Icon(Icons.phone, color: kSuccessColor),
  ...
)
```

## كيفية العمل

1. **عند الضغط على أيقونة الهاتف**:
   - يتم استدعاء `_handlePhoneCall()` مع رقم هاتف السائق
   
2. **PhoneUtils.makePhoneCall()**:
   - تنظيف الرقم من المسافات والشرطات
   - إنشاء URI بصيغة `tel:+966501234567`
   - التحقق من إمكانية فتح تطبيق الهاتف
   - فتح تطبيق الهاتف مع الرقم

3. **في حالة الفشل**:
   - عرض SnackBar بالخطأ
   - Logging للخطأ في console

## الدعم

### Android
- ✅ يعمل بشكل كامل
- يفتح تطبيق الهاتف الافتراضي
- لا يحتاج permissions إضافية

### iOS
- ✅ يعمل بشكل كامل
- يفتح تطبيق Phone
- لا يحتاج permissions إضافية

## البيانات المطلوبة

رقم الهاتف موجود في:
```dart
data.driver.phone  // من DriverInfo model
```

**DriverInfo Model**:
```dart
class DriverInfo {
  final String id;
  final String name;
  final String phone;  // ✅ متوفر
  final String? avatar;
}
```

## الاختبار

### اختبار يدوي:
1. افتح التطبيق
2. اذهب إلى ride tracking screen
3. اضغط على أيقونة الهاتف بجانب معلومات السائق
4. يجب أن يفتح تطبيق الهاتف مع رقم السائق

### اختبار الأخطاء:
- رقم فارغ: لن يفتح التطبيق وسيظهر log
- رقم غير صحيح: سيحاول الفتح وقد يفشل
- تطبيق الهاتف غير متوفر: سيظهر SnackBar بالخطأ

## Logs للتتبع

```
[PhoneUtils] Attempting to call: +966501234567
[PhoneUtils] Phone app launched: true
```

أو في حالة الخطأ:
```
[PhoneUtils] Phone number is empty
[PhoneUtils] Cannot launch phone app for: +966501234567
[PhoneUtils] Error launching phone app: ...
```

## الحزم المستخدمة

- `url_launcher: ^6.3.2` - موجودة مسبقاً في pubspec.yaml

## ملاحظات

- الميزة تعمل على Android و iOS بدون تعديلات إضافية
- لا تحتاج permissions في AndroidManifest أو Info.plist
- الرقم يتم تنظيفه تلقائياً قبل الاتصال
- يتم عرض رسالة خطأ واضحة للمستخدم في حالة الفشل
