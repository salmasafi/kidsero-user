# إصلاح التنقل عند الضغط على كارت الرحلة

## المشكلة
عند الضغط على كارت الرحلة من أي شاشة، لم يتم فتح شاشة تفاصيل الرحلة (Ride Tracking Screen).

## الحل
تم إضافة `onTap` callback لجميع بطاقات الرحلات في جميع الشاشات للتنقل إلى `RideTrackingScreenByOccurrence`.

## الملفات المعدلة

### 1. `lib/features/rides/ui/screens/child_schedule_screen.dart`
تم إضافة `onTap` في:
- ✅ `_buildTodayRideCard()` - رحلات اليوم
- ✅ `_buildUpcomingRideCard()` - الرحلات القادمة
- ✅ `_buildHistoryRideCard()` - رحلات السجل

### 2. `lib/features/rides/ui/screens/upcoming_rides_screen.dart`
تم إضافة:
- ✅ Import لـ `RideTrackingScreenByOccurrence`
- ✅ `onTap` في `_buildRideCard()`

### 3. `lib/features/home/ui/track_screen.dart`
كان يعمل بالفعل:
- ✅ `_buildActiveRideCard()` - يستخدم `context.go()`
- ✅ `_buildTodayRideCard()` - يستخدم `Navigator.push()`
- ✅ `_buildUpcomingRideCard()` - يستخدم `Navigator.push()`

## الكود المضاف

```dart
onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => RideTrackingScreenByOccurrence(
        occurrenceId: ride.occurrenceId,
      ),
    ),
  );
},
```

## الشاشات المتأثرة

### 1. Child Schedule Screen (عند الضغط على طالب)
- ✅ Today Tab - يفتح ride tracking
- ✅ Upcoming Tab - يفتح ride tracking
- ✅ History Tab - يفتح ride tracking

### 2. Track Screen (من Bottom Navigation)
- ✅ Today Tab - يفتح ride tracking
- ✅ Upcoming Tab - يفتح ride tracking
- ✅ History Tab - يفتح ride tracking

### 3. Upcoming Rides Screen
- ✅ جميع البطاقات - تفتح ride tracking

### 4. Active Ride Card (البطاقة الخضراء)
- ✅ يستخدم `context.go()` للتنقل إلى live tracking

## الاختبار

### اختبار يدوي:
1. ✅ افتح Child Schedule Screen
   - اضغط على أي رحلة في Today
   - اضغط على أي رحلة في Upcoming
   - اضغط على أي رحلة في History
   
2. ✅ افتح Track Screen من Bottom Navigation
   - اضغط على أي رحلة في Today
   - اضغط على أي رحلة في Upcoming
   - اضغط على أي رحلة في History
   
3. ✅ افتح Upcoming Rides Screen
   - اضغط على أي رحلة

4. ✅ اضغط على Active Ride Card (البطاقة الخضراء)
   - يجب أن تفتح Live Tracking

### النتيجة المتوقعة:
- يجب أن تفتح شاشة Ride Tracking Screen
- تعرض تفاصيل الرحلة الكاملة
- Timeline للنقاط
- معلومات السائق والحافلة
- قائمة الأطفال

## ملاحظات

### الفرق بين RideTrackingScreen و RideTrackingScreenByOccurrence:
- `RideTrackingScreen` - يأخذ `childId` ويعرض الرحلة النشطة للطفل
- `RideTrackingScreenByOccurrence` - يأخذ `occurrenceId` ويعرض رحلة محددة

### لماذا نستخدم RideTrackingScreenByOccurrence؟
- لأن كل ride card لديه `occurrenceId` محدد
- يمكن عرض أي رحلة (نشطة، مجدولة، مكتملة)
- أكثر مرونة من استخدام childId

### Active Ride Card:
- يستخدم `context.go('${Routes.liveTracking}/${ride.occurrenceId}')`
- هذا يفتح نفس الشاشة لكن عبر routing مختلف
- كلاهما يعمل بشكل صحيح

## الخلاصة

✅ تم إصلاح جميع بطاقات الرحلات في جميع الشاشات
✅ الآن عند الضغط على أي ride card، تفتح شاشة التفاصيل
✅ يعمل في جميع التبويبات (Today, Upcoming, History)
✅ يعمل في جميع الشاشات (Child Schedule, Track, Upcoming Rides)
