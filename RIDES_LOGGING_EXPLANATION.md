# شرح Logs الرحلات في التطبيق

## الحالتان المختلفتان لعرض الرحلات

### 1️⃣ الحالة الأولى: عند الضغط على الطالب (Child Schedule Screen)
- **المكان**: `lib/features/rides/ui/screens/child_schedule_screen.dart`
- **Cubit المستخدم**: `ChildRidesCubit`
- **البيانات المعروضة**:
  - ✅ Today's Rides (رحلات اليوم)
  - ✅ Upcoming Rides (الرحلات القادمة) - يتم تحميلها من API
  - ✅ History (السجل) - الرحلات المكتملة من today rides

**Logs ستظهر في**:
```
[ChildRidesCubit] Loading rides for child: {childId}
[ChildRidesCubit] Loaded X today rides for child {childId}
[ChildRidesCubit] Ride 0: ID=..., Name=..., Status=..., Type=..., Time=...
[ChildRidesCubit] Total upcoming days: X
[ChildRidesCubit] Day 2024-01-15 (Monday): X total rides
[ChildRidesCubit]   Filtered for child {childId}: X rides
[ChildRidesCubit]     Ride 0: OccurrenceID=..., Name=..., Type=..., Time=..., ChildID=...
[ChildRidesCubit] Total loaded upcoming rides for child {childId}: X
```

---

### 2️⃣ الحالة الثانية: من Bottom Navigation Bar (Track Screen)
- **المكان**: `lib/features/home/ui/track_screen.dart`
- **Cubit المستخدم**: `AllChildrenRidesCubit`
- **البيانات المعروضة**:
  - ✅ Today's Rides (رحلات اليوم لجميع الأطفال)
  - ✅ History (السجل) - الرحلات المكتملة
  - ✅ Upcoming Rides - **تم التطبيق الآن!**

**Logs ستظهر في**:
```
[AllChildrenRidesCubit] Loading rides for all children
[AllChildrenRidesCubit] Found X children
[AllChildrenRidesCubit] Loaded rides for X children, total rides: X
[AllChildrenRidesCubit] Child: {name} ({id}) has X rides
[AllChildrenRidesCubit]   Ride 0: ID=..., Name=..., Status=..., Type=..., Time=..., IsCompleted=..., IsActive=..., IsScheduled=...
[TrackScreen] Today tab - Total rides: X
[TrackScreen] Today Ride 0: ID=..., Name=..., Status=..., Type=..., Time=..., IsActive=...
[TrackScreen] === ACTIVE RIDES ===
[TrackScreen] Active 0: ID=..., Name=..., Status=...
[TrackScreen] === NON-ACTIVE RIDES ===
[TrackScreen] Non-Active 0: ID=..., Name=..., Status=...
```

**عند الضغط على History Tab**:
```
[TrackScreen] === HISTORY TAB DEBUG ===
[TrackScreen] Selected child ID: null (or childId)
[TrackScreen] Checking all children for completed rides
[TrackScreen] Child {name} ({id}) has X total rides
[TrackScreen]   Ride 0: Status=..., IsCompleted=...
[TrackScreen] Child {name} has X completed rides
[TrackScreen] Total history rides to display: X
```

---

## ✅ تم إصلاح مشكلة Upcoming في Track Screen!

**التحديثات**:
1. إضافة `upcomingRidesData` في `AllChildrenRidesLoaded` state
2. تحميل upcoming rides في `loadAllChildrenRides()` و `refresh()`
3. إضافة getters:
   - `getUpcomingRidesForChild(childId)` - للحصول على رحلات طفل محدد
   - `allUpcomingRides` - للحصول على جميع الرحلات القادمة
4. تطبيق `_buildUpcomingTab()` في TrackScreen لعرض الرحلات مجموعة حسب التاريخ
5. إضافة `_buildUpcomingRideCard()` لعرض بطاقة الرحلة القادمة

**الميزات**:
- ✅ عرض الرحلات القادمة مجموعة حسب التاريخ
- ✅ دعم الفلترة حسب الطفل
- ✅ عرض اسم اليوم والتاريخ
- ✅ Logs تفصيلية للتتبع

---

## كيفية قراءة الـ Logs

### 1. للتحقق من History:
ابحث عن:
- `IsCompleted=true` أو `IsCompleted=false`
- `Status=completed` (هذا هو المطلوب لظهور الرحلة في History)

### 2. للتحقق من Active Rides:
ابحث عن:
- `Status=in_progress` أو `Status=started`
- `IsActive=true`

### 3. للتحقق من Upcoming Rides:
- في **Child Schedule Screen**: ابحث عن `Upcoming Ride X:`
- في **Track Screen**: لن تجد لأنها غير مطبقة

---

## الخلاصة

| الميزة | Child Schedule Screen | Track Screen |
|--------|----------------------|--------------|
| Today Rides | ✅ مع logs تفصيلية | ✅ مع logs تفصيلية |
| History | ✅ مع logs تفصيلية | ✅ مع logs تفصيلية |
| Upcoming | ✅ مع logs تفصيلية | ✅ مع logs تفصيلية |
| Filter by Child | N/A (طفل واحد فقط) | ✅ متاح |

---

## الخطوات التالية

1. شغل التطبيق
2. افتح الـ logs/console
3. جرب الحالتين:
   - اضغط على طالب من الصفحة الرئيسية
   - اذهب لـ Track من Bottom Navigation
4. شارك الـ logs لنحلل المشكلة
