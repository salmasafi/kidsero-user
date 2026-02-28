# History Rides Fix

## المشكلة
كانت صفحة History في Track Screen لا تعرض أي رحلات لأن الكود كان يبحث عن الرحلات المكتملة (completed) في رحلات اليوم فقط، بينما الـ API يوفر endpoint منفصل لجلب رحلات الـ history.

## الحل
تم تعديل الكود لاستخدام endpoint الصحيح مع parameter `type` لجلب أنواع مختلفة من الرحلات:
- `type=today` - رحلات اليوم
- `type=history` - رحلات الماضي (المكتملة)
- `type=upcoming` - رحلات المستقبل

## التعديلات

### 1. RidesService (`lib/features/rides/data/rides_service.dart`)
- أضفنا method جديدة `getChildRides()` تقبل parameter `type`
- عدلنا `getChildTodayRides()` لتستخدم `getChildRides()` مع `type='today'`
- الـ endpoint الآن: `GET /api/users/rides/child/{childId}?type={type}`

### 2. RidesRepository (`lib/features/rides/data/rides_repository.dart`)
- أضفنا method جديدة `getChildRides()` تقبل parameter `type`
- أضفنا method `getChildHistoryRides()` لجلب رحلات الـ history
- عدلنا `getChildTodayRides()` لتستخدم `getChildRides()` مع `type='today'`
- تم تحديث الـ cache keys لتشمل نوع الرحلة

### 3. AllChildrenRidesCubit (`lib/features/rides/cubit/all_children_rides_cubit.dart`)
- أضفنا `childrenHistoryRides` في `AllChildrenRidesLoaded` state
- أضفنا method `getHistoryRidesForChild()` لجلب history rides لطفل معين
- أضفنا property `allHistoryRides` لجلب جميع history rides
- عدلنا `loadAllChildrenRides()` لجلب today و history rides معاً
- عدلنا `refresh()` لتحديث today و history rides معاً

### 4. TrackScreen (`lib/features/home/ui/track_screen.dart`)
- عدلنا `_buildHistoryTab()` لاستخدام `getHistoryRidesForChild()` بدلاً من البحث عن completed rides في today rides

## API Response Format
```json
{
  "success": true,
  "data": {
    "child": {
      "id": "81790d4b-e627-4365-b7cc-3d3bd394b393",
      "name": "Seif",
      "avatar": "...",
      "grade": "11",
      "classroom": "1B",
      "organization": {
        "id": "...",
        "name": "KGC"
      }
    },
    "type": "history",
    "date": "2026-02-26",
    "morning": [...],
    "afternoon": [...],
    "total": 2
  }
}
```

## النتيجة
الآن عند فتح صفحة Track والضغط على تبويب History، سيتم عرض جميع الرحلات المكتملة من الـ API بشكل صحيح.
