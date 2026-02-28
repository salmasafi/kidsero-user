// Commented out for App Store submission - Firebase not connected to iOS
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/network/cache_helper.dart';
import 'core/network/api_helper.dart';
import 'core/network/api_service.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_strings.dart';
import 'core/logic/locale_cubit.dart';
import 'core/services/auth_service.dart';
import 'features/rides/data/rides_repository.dart';
import 'features/rides/data/rides_service.dart';
import 'features/payments/data/repositories/payment_repository.dart';
import 'features/notice/data/notes_repository.dart';
import 'l10n/app_localizations.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Commented out for App Store submission - Firebase not connected to iOS
// Background message handler must be a top-level function
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   log("Handling a background message: ${message.messageId}");
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Commented out for App Store submission - Firebase not connected to iOS
  // await Firebase.initializeApp();
  await CacheHelper.init();

  // Commented out for App Store submission - Firebase not connected to iOS
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final ApiHelper _apiHelper;
  late final ApiService _apiService;
  late final RidesService _ridesService;
  late final RidesRepository _ridesRepository;
  late final PaymentRepository _paymentRepository;
  late final NotesRepository _notesRepository;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    // Commented out for App Store submission - Firebase not connected to iOS
    // _setupFCM();
  }

  Future<void> _initializeServices() async {
    _apiHelper = ApiHelper();
    _apiService = ApiService();
    _ridesService = RidesService(dio: _apiService.dio);
    _ridesRepository = RidesRepository(
      ridesService: _ridesService,
    );
    _paymentRepository = PaymentRepository(_apiService);
    _notesRepository = NotesRepository(_apiService);
    
    // Initialize AuthService with API instances
    AuthService().initialize(
      apiHelper: _apiHelper,
      apiService: _apiService,
    );
    
    // Ensure tokens are loaded before the app renders
    await _apiHelper.refreshToken();
    await _apiService.refreshToken();
    
    setState(() {
      _isInitialized = true;
    });
  }

  // Commented out for App Store submission - Firebase not connected to iOS
  // Future<void> _setupFCM() async {
  //   FirebaseMessaging messaging = FirebaseMessaging.instance;
  //
  //   NotificationSettings settings = await messaging.requestPermission(
  //     alert: true,
  //     announcement: false,
  //     badge: true,
  //     carPlay: false,
  //     criticalAlert: false,
  //     provisional: false,
  //     sound: true,
  //   );
  //
  //   log('User granted permission: ${settings.authorizationStatus}');
  //
  //   // Get the token
  //   String? token = await messaging.getToken();
  //   log("FCM Token: $token");
  //
  //   // Listen to foreground messages
  //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //     log('Got a message whilst in the foreground!');
  //     log('Message data: ${message.data}');
  //
  //     if (message.notification != null) {
  //       log('Message also contained a notification: ${message.notification}');
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
    
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _apiHelper),
        RepositoryProvider.value(value: _apiService),
        RepositoryProvider.value(value: _ridesService),
        RepositoryProvider.value(value: _ridesRepository),
        RepositoryProvider.value(value: _paymentRepository),
        RepositoryProvider.value(value: _notesRepository),
      ],
      child: BlocProvider(
        create: (context) => LocaleCubit(),
        child: BlocBuilder<LocaleCubit, Locale>(
          builder: (context, locale) {
            return MaterialApp.router(
              routerConfig: AppRouter.router,
              title: AppStrings.appName,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              locale: locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en'),
                Locale('ar'),
                Locale('fr'),
                Locale('de'),
              ],
            );
          },
        ),
      ),
    );
  }
}
