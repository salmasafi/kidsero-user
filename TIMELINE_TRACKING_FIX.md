# Timeline Tracking Screen - Fix للمشكلة

## المشكلة
عند ترك صفحة Timeline Tracking والعودة إليها، تظهر رسالة "No tracking data found" رغم أن الرحلة لا تزال قيد التقدم (IN PROGRESS).

## السبب
1. الـ BlocProvider كان يُنشأ في `build` method مباشرة
2. عند العودة للصفحة، يتم إعادة استدعاء API
3. إذا فشل الطلب (مشكلة شبكة مؤقتة)، الـ Repository كان يُرجع `null`
4. الـ Cubit يعتبر `null` يعني "لا توجد بيانات" ويُظهر الخطأ

## الحل المطبق

### 1. تحسين معالجة الأخطاء في Repository
```dart
// في rides_repository.dart
Future<RideTrackingData?> getRideTrackingByOccurrence(String occurrenceId) async {
  try {
    final response = await _ridesService.getRideTrackingByOccurrence(occurrenceId);
    if (response.success && response.data != null) {
      return response.data;
    } else {
      return null;
    }
  } catch (e) {
    // Re-throw the error so the Cubit can handle it properly
    rethrow; // بدلاً من return null
  }
}
```

### 2. إضافة آلية Retry في Cubit
```dart
class RideTrackingCubitByOccurrence extends Cubit<RideTrackingState> {
  int _retryCount = 0;
  static const int _maxRetries = 3;
  
  Future<void> loadTracking() async {
    try {
      final trackingData = await _repository.getRideTrackingByOccurrence(_occurrenceId);
      
      if (trackingData != null) {
        _retryCount = 0; // Reset on success
        emit(RideTrackingLoaded(trackingData: trackingData));
      } else {
        // Retry with exponential backoff
        if (_retryCount < _maxRetries) {
          _retryCount++;
          await Future.delayed(Duration(seconds: 2 * _retryCount));
          return loadTracking();
        }
        emit(const RideTrackingError('No tracking data found'));
      }
    } catch (e) {
      // Retry on error
      if (_retryCount < _maxRetries) {
        _retryCount++;
        await Future.delayed(Duration(seconds: 2 * _retryCount));
        return loadTracking();
      }
      emit(RideTrackingError(ErrorHandler.handle(e)));
    }
  }
}
```

### 3. إضافة Lifecycle Management
```dart
class _RideTrackingScreenByOccurrenceState extends State<RideTrackingScreenByOccurrence> 
    with WidgetsBindingObserver {
  late final RideTrackingCubitByOccurrence _cubit;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // إنشاء الـ Cubit مرة واحدة
    _cubit = RideTrackingCubitByOccurrence(...)
      ..loadTracking()
      ..startAutoRefresh();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // عند العودة للتطبيق، إعادة تحميل البيانات
    if (state == AppLifecycleState.resumed) {
      _cubit.loadTracking();
    }
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cubit.close();
    super.dispose();
  }
}
```

### 4. تحسين Auto-Refresh
```dart
void startAutoRefresh() {
  _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
    // Refresh even in loading state
    if (state is RideTrackingLoaded || state is RideTrackingLoading) {
      try {
        final trackingData = await _repository.getRideTrackingByOccurrence(_occurrenceId);
        if (trackingData != null) {
          emit(RideTrackingLoaded(trackingData: trackingData));
        }
      } catch (e) {
        // Don't emit error during auto-refresh
        // Keep current state to prevent showing error on temporary network issues
      }
    }
  });
}
```

## الفوائد
1. ✅ إعادة المحاولة التلقائية عند الفشل (3 محاولات مع exponential backoff)
2. ✅ عدم إظهار خطأ عند مشاكل الشبكة المؤقتة أثناء Auto-refresh
3. ✅ إعادة تحميل البيانات تلقائياً عند العودة للتطبيق
4. ✅ إدارة أفضل لـ lifecycle الـ Cubit
5. ✅ معالجة أفضل للأخطاء مع التمييز بين "لا توجد بيانات" و"خطأ في الشبكة"

## الملفات المعدلة
- `lib/features/rides/ui/screens/ride_tracking_screen.dart`
- `lib/features/rides/data/rides_repository.dart`
