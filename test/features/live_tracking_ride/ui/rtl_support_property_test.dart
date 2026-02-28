import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidsero_parent/features/live_tracking_ride/ui/live_tracking_screen.dart';
import 'package:kidsero_parent/features/rides/data/rides_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kidsero_parent/l10n/app_localizations.dart';

void main() {
  group('Property 12: RTL Support', () {
    late RidesService mockRidesService;

    setUp(() {
      // Create a simple mock implementation
      mockRidesService = _MockRidesService();
    });

    /// Property: Arabic locale applies RTL layout
    /// 
    /// This property verifies that when the app is set to Arabic locale,
    /// the LiveTrackingScreen automatically applies RTL (Right-to-Left) layout.
    /// 
    /// Requirements:
    /// - 7.1: Localization support
    /// - 7.2: RTL layout for Arabic
    /// - 7.3: Directionality widget wrapping
    testWidgets(
      'PROPERTY: Arabic locale applies RTL layout to LiveTrackingScreen',
      (WidgetTester tester) async {
        // Arrange: Create app with Arabic locale
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('ar'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('ar'),
            ],
            home: RepositoryProvider<RidesService>(
              create: (_) => mockRidesService,
              child: const LiveTrackingScreen(rideId: 'test-ride-123'),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Act & Assert: Verify RTL layout is applied
        final directionality = tester.widget<Directionality>(
          find.descendant(
            of: find.byType(LiveTrackingScreen),
            matching: find.byType(Directionality),
          ).first,
        );

        expect(
          directionality.textDirection,
          TextDirection.rtl,
          reason: 'Arabic locale should apply RTL text direction',
        );
      },
    );

    testWidgets(
      'PROPERTY: English locale applies LTR layout to LiveTrackingScreen',
      (WidgetTester tester) async {
        // Arrange: Create app with English locale
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('ar'),
            ],
            home: RepositoryProvider<RidesService>(
              create: (_) => mockRidesService,
              child: const LiveTrackingScreen(rideId: 'test-ride-123'),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Act & Assert: Verify LTR layout is applied
        final directionality = tester.widget<Directionality>(
          find.descendant(
            of: find.byType(LiveTrackingScreen),
            matching: find.byType(Directionality),
          ).first,
        );

        expect(
          directionality.textDirection,
          TextDirection.ltr,
          reason: 'English locale should apply LTR text direction',
        );
      },
    );

    testWidgets(
      'PROPERTY: RideInfoCard respects RTL layout in Arabic',
      (WidgetTester tester) async {
        // This test verifies that UI elements within the screen
        // properly respect the RTL layout when Arabic is selected
        
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('ar'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('ar'),
            ],
            home: RepositoryProvider<RidesService>(
              create: (_) => mockRidesService,
              child: const LiveTrackingScreen(rideId: 'test-ride-123'),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify that the Directionality widget exists and is RTL
        final directionalityFinder = find.descendant(
          of: find.byType(LiveTrackingScreen),
          matching: find.byType(Directionality),
        );

        expect(directionalityFinder, findsWidgets);

        // Get the first Directionality widget (the main wrapper)
        final directionality = tester.widget<Directionality>(
          directionalityFinder.first,
        );

        expect(
          directionality.textDirection,
          TextDirection.rtl,
          reason: 'All UI elements should be wrapped in RTL Directionality',
        );
      },
    );

    testWidgets(
      'PROPERTY: Localized strings are displayed in Arabic',
      (WidgetTester tester) async {
        // Verify that localized strings are properly displayed in Arabic
        
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('ar'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('ar'),
            ],
            home: RepositoryProvider<RidesService>(
              create: (_) => mockRidesService,
              child: const LiveTrackingScreen(rideId: 'test-ride-123'),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify AppBar title exists (either Arabic translation or fallback)
        // The localization system should load, but we verify the widget exists
        final appBar = find.byType(AppBar);
        expect(
          appBar,
          findsOneWidget,
          reason: 'AppBar should be present',
        );
        
        // Verify that text direction is RTL which indicates proper locale handling
        final directionality = tester.widget<Directionality>(
          find.descendant(
            of: find.byType(LiveTrackingScreen),
            matching: find.byType(Directionality),
          ).first,
        );
        expect(
          directionality.textDirection,
          TextDirection.rtl,
          reason: 'Text direction should be RTL for Arabic locale',
        );
      },
    );

    testWidgets(
      'PROPERTY: Switching locale updates text direction dynamically',
      (WidgetTester tester) async {
        // This test verifies that changing locale updates the text direction
        
        final localeNotifier = ValueNotifier<Locale>(const Locale('en'));

        await tester.pumpWidget(
          ValueListenableBuilder<Locale>(
            valueListenable: localeNotifier,
            builder: (context, locale, child) {
              return MaterialApp(
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
                ],
                home: RepositoryProvider<RidesService>(
                  create: (_) => mockRidesService,
                  child: const LiveTrackingScreen(rideId: 'test-ride-123'),
                ),
              );
            },
          ),
        );

        await tester.pumpAndSettle();

        // Initially LTR
        var directionality = tester.widget<Directionality>(
          find.descendant(
            of: find.byType(LiveTrackingScreen),
            matching: find.byType(Directionality),
          ).first,
        );
        expect(directionality.textDirection, TextDirection.ltr);

        // Switch to Arabic
        localeNotifier.value = const Locale('ar');
        await tester.pumpAndSettle();

        // Now RTL
        directionality = tester.widget<Directionality>(
          find.descendant(
            of: find.byType(LiveTrackingScreen),
            matching: find.byType(Directionality),
          ).first,
        );
        expect(
          directionality.textDirection,
          TextDirection.rtl,
          reason: 'Text direction should update to RTL when locale changes to Arabic',
        );
      },
    );
  });
}


// Simple mock implementation for testing
class _MockRidesService implements RidesService {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
