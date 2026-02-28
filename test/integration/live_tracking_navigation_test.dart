import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kidsero_parent/core/routing/routes.dart';

void main() {
  group('Live Tracking Navigation Integration Tests', () {
    testWidgets('should navigate to live tracking screen with rideId parameter',
        (WidgetTester tester) async {
      // Arrange
      const testRideId = 'test-ride-123';
      bool navigatedToLiveTracking = false;
      String? capturedRideId;

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  context.go('${Routes.liveTracking}/$testRideId');
                },
                child: const Text('Navigate to Live Tracking'),
              ),
            ),
          ),
          GoRoute(
            path: '${Routes.liveTracking}/:rideId',
            builder: (context, state) {
              navigatedToLiveTracking = true;
              capturedRideId = state.pathParameters['rideId'];
              return Scaffold(
                appBar: AppBar(title: const Text('Live Tracking')),
                body: Text('Ride ID: ${state.pathParameters['rideId']}'),
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      // Act - Tap the navigation button
      await tester.tap(find.text('Navigate to Live Tracking'));
      await tester.pumpAndSettle();

      // Assert
      expect(navigatedToLiveTracking, true);
      expect(capturedRideId, testRideId);
      expect(find.text('Live Tracking'), findsOneWidget);
      expect(find.text('Ride ID: $testRideId'), findsOneWidget);
    });

    testWidgets('should navigate back from live tracking screen',
        (WidgetTester tester) async {
      // Arrange
      const testRideId = 'test-ride-456';
      bool backNavigationSuccessful = false;

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) {
              backNavigationSuccessful = true;
              return Scaffold(
                appBar: AppBar(title: const Text('Home')),
                body: ElevatedButton(
                  onPressed: () {
                    context.go('${Routes.liveTracking}/$testRideId');
                  },
                  child: const Text('Navigate to Live Tracking'),
                ),
              );
            },
          ),
          GoRoute(
            path: '${Routes.liveTracking}/:rideId',
            builder: (context, state) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Live Tracking'),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.go('/'),
                  ),
                ),
                body: Text('Ride ID: ${state.pathParameters['rideId']}'),
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      // Navigate to live tracking
      await tester.tap(find.text('Navigate to Live Tracking'));
      await tester.pumpAndSettle();

      // Verify we're on live tracking screen
      expect(find.text('Live Tracking'), findsOneWidget);

      // Reset flag
      backNavigationSuccessful = false;

      // Act - Navigate back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Assert
      expect(backNavigationSuccessful, true);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Navigate to Live Tracking'), findsOneWidget);
    });

    testWidgets('should handle multiple rideId parameters correctly',
        (WidgetTester tester) async {
      // Arrange
      final rideIds = ['ride-1', 'ride-2', 'ride-3'];
      final capturedRideIds = <String>[];

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: Column(
                children: rideIds
                    .map((id) => ElevatedButton(
                          onPressed: () {
                            context.go('${Routes.liveTracking}/$id');
                          },
                          child: Text('Navigate to $id'),
                        ))
                    .toList(),
              ),
            ),
          ),
          GoRoute(
            path: '${Routes.liveTracking}/:rideId',
            builder: (context, state) {
              final rideId = state.pathParameters['rideId']!;
              capturedRideIds.add(rideId);
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Live Tracking'),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.go('/'),
                  ),
                ),
                body: Text('Ride ID: $rideId'),
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      // Act - Navigate to each ride
      for (final rideId in rideIds) {
        await tester.tap(find.text('Navigate to $rideId'));
        await tester.pumpAndSettle();

        // Assert - Verify correct rideId is displayed
        expect(find.text('Ride ID: $rideId'), findsOneWidget);

        // Navigate back
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
      }

      // Assert - All rideIds were captured correctly
      expect(capturedRideIds, rideIds);
    });

    testWidgets('should preserve rideId in URL path',
        (WidgetTester tester) async {
      // Arrange
      const testRideId = 'ride-with-special-chars-123';
      String? urlPath;

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  context.go('${Routes.liveTracking}/$testRideId');
                },
                child: const Text('Navigate'),
              ),
            ),
          ),
          GoRoute(
            path: '${Routes.liveTracking}/:rideId',
            builder: (context, state) {
              urlPath = state.matchedLocation;
              return Scaffold(
                body: Text('Path: ${state.matchedLocation}'),
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      // Act
      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      // Assert
      expect(urlPath, '${Routes.liveTracking}/$testRideId');
      expect(find.text('Path: ${Routes.liveTracking}/$testRideId'),
          findsOneWidget);
    });

    test('Routes.liveTracking constant is defined correctly', () {
      // Assert
      expect(Routes.liveTracking, '/live-tracking');
    });

    test('Live tracking route path format is correct', () {
      // Arrange
      const rideId = 'test-ride-789';
      
      // Act
      final fullPath = '${Routes.liveTracking}/$rideId';
      
      // Assert
      expect(fullPath, '/live-tracking/$rideId');
      expect(fullPath.startsWith(Routes.liveTracking), true);
      expect(fullPath.contains(rideId), true);
    });
  });
}
