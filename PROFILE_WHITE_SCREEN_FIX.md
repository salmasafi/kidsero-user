# إصلاح الشاشة البيضاء في البروفايل

## المشكلة
عند فتح ديالوج الأطفال من صفحة البروفايل والضغط على X للإغلاق، تصبح صفحة البروفايل بيضاء تماماً ولا تعود إلا بإغلاق وفتح التطبيق مجدداً.

## السبب الجذري

الـ `BlocBuilder` في صفحة البروفايل كان يستمع لجميع تغييرات الحالة (states) من `ProfileCubit`:

```dart
BlocBuilder<ProfileCubit, ProfileState>(
  builder: (context, state) {
    if (state is ProfileLoading) { ... }
    else if (state is ProfileLoaded) { ... }
    else if (state is ProfileError) { ... }
    return const SizedBox(); // ← شاشة بيضاء!
  },
)
```

**المشكلة**:
1. عند فتح ديالوج الأطفال، يتم استدعاء `getChildren()`
2. يتم إصدار `ChildrenLoading` state
3. الـ `BlocBuilder` يعيد البناء
4. الحالة ليست `ProfileLoading` ولا `ProfileLoaded` ولا `ProfileError`
5. يتم تنفيذ `return const SizedBox()` ← **شاشة بيضاء!**

## الحل المطبق

### استخدام `buildWhen` لتصفية الحالات
**الملف**: `lib/features/profile/ui/view/profile_view.dart`

**التغيير**:
```dart
BlocBuilder<ProfileCubit, ProfileState>(
  buildWhen: (previous, current) {
    // ✅ إعادة البناء فقط لحالات البروفايل، تجاهل حالات الأطفال
    return current is ProfileLoading ||
           current is ProfileLoaded ||
           current is ProfileError ||
           current is ProfileUpdateSuccess ||
           current is PasswordChangeSuccess;
  },
  builder: (context, state) {
    // الآن لن يتم استدعاء builder عند ChildrenLoading/ChildrenLoaded
    if (state is ProfileLoading) { ... }
    else if (state is ProfileLoaded) { ... }
    // ...
  },
)
```

**كيف يعمل**:
- `buildWhen` يتحقق من نوع الحالة قبل إعادة البناء
- إذا كانت الحالة `ChildrenLoading` أو `ChildrenLoaded` → لا يتم إعادة البناء
- إذا كانت الحالة `ProfileLoaded` → يتم إعادة البناء ✅
- النتيجة: الشاشة تبقى معروضة بشكل طبيعي

### تحديث البروفايل عند إغلاق الديالوج
**الملف**: `lib/features/profile/ui/view/profile_view.dart`

**التغيير**:
```dart
showModalBottomSheet(
  // ...
).whenComplete(() {
  // ✅ تحديث البروفايل عند إغلاق الديالوج
  if (context.mounted) {
    profileCubit.getProfile();
  }
});
```

**الفائدة**:
- يتم تحديث عدد الأطفال في البروفايل بعد إضافة طفل جديد

## كيف يعمل الآن

### السيناريو: فتح وإغلاق ديالوج الأطفال

1. **المستخدم يضغط على "My Children"**
   - يتم فتح الديالوج
   - يتم استدعاء `getChildren()`
   - يتم إصدار `ChildrenLoading` state
   - الـ `BlocBuilder` **لا يعيد البناء** بسبب `buildWhen` ✅
   - صفحة البروفايل تبقى معروضة بشكل طبيعي
   - يتم عرض قائمة الأطفال في الديالوج

2. **المستخدم يضغط على X للإغلاق**
   - يتم إغلاق الديالوج
   - يتم استدعاء `getProfile()` في `whenComplete`
   - يتم إصدار `ProfileLoaded` state
   - الـ `BlocBuilder` **يعيد البناء** ✅
   - الشاشة تعمل بشكل طبيعي

3. **المستخدم يضيف طفل جديد**
   - يتم إضافة الطفل
   - يتم تحديث قائمة الأطفال تلقائياً
   - عند إغلاق الديالوج، يتم تحديث عدد الأطفال في البروفايل ✅

## الملفات المعدلة
1. `lib/features/profile/ui/view/profile_view.dart` - إضافة `buildWhen` وتحديث عند الإغلاق

## الفوائد
✅ لا مزيد من الشاشة البيضاء
✅ فصل واضح بين حالات البروفايل وحالات الأطفال
✅ تحديث تلقائي للبيانات عند الإغلاق
✅ تجربة مستخدم سلسة
✅ كود أنظف وأكثر وضوحاً

## المفهوم الأساسي: `buildWhen`

`buildWhen` هو callback يسمح لك بالتحكم في متى يتم إعادة بناء الـ widget:

```dart
buildWhen: (previous, current) {
  // return true → إعادة البناء
  // return false → تجاهل التغيير
  return current is ProfileLoaded; // مثال
}
```

**الاستخدامات**:
- تحسين الأداء (تقليل عمليات البناء غير الضرورية)
- فصل المسؤوليات (كل widget يستمع فقط للحالات التي تهمه)
- تجنب المشاكل مثل الشاشة البيضاء

## الاختبار
1. افتح صفحة البروفايل ✅
2. اضغط على "My Children" ✅
3. تحقق من أن صفحة البروفايل لا تزال معروضة في الخلفية ✅
4. اضغط على X للإغلاق ✅
5. تحقق من أن الصفحة تعمل بشكل طبيعي ✅
6. افتح الديالوج مرة أخرى ✅
7. أضف طفل جديد ✅
8. أغلق الديالوج ✅
9. تحقق من تحديث عدد الأطفال ✅
