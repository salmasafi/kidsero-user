import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:kidsero_driver/features/home/ui/home_screen.dart';
import 'package:kidsero_driver/features/auth/ui/view/login_view.dart';
import 'package:kidsero_driver/features/profile/ui/view/profile_view.dart';
import 'package:kidsero_driver/features/profile/ui/view/edit_profile_view.dart';
import 'package:kidsero_driver/features/profile/ui/view/change_password_view.dart';
import 'package:kidsero_driver/features/payments/ui/view/payment_history_view.dart';
import 'package:kidsero_driver/features/payments/ui/view/payment_detail_view.dart';
import 'package:kidsero_driver/features/payments/ui/view/create_plan_payment_view.dart';
import 'package:kidsero_driver/features/payments/ui/view/create_service_payment_view.dart';

import 'package:kidsero_driver/features/auth/data/models/user_model.dart';
import 'package:kidsero_driver/core/utils/app_preferences.dart';
import '../../main.dart';
import 'routes.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: Routes.login,
    redirect: (context, state) async {
      // Check if user has a saved token
      final token = await AppPreferences.getToken();
      final isLoggedIn = token != null && token.isNotEmpty;
      
      // If user is on login page but has a token, redirect to home
      if (state.matchedLocation == Routes.login && isLoggedIn) {
        return Routes.home;
      }
      
      // If user is trying to access protected routes without token, redirect to login
      if (!isLoggedIn && state.matchedLocation != Routes.login) {
        return Routes.login;
      }
      
      // No redirect needed
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.login,
        pageBuilder: (context, state) {
          return _buildPageWithTransition(
            child: const LoginView(),
            state: state,
          );
        },
      ),
      GoRoute(
        path: Routes.home,
        pageBuilder: (context, state) =>
            _buildPageWithTransition(child: const HomeScreen(), state: state),
      ),
      GoRoute(
        path: Routes.profile,
        pageBuilder: (context, state) =>
            _buildPageWithTransition(child: const ProfileView(), state: state),
      ),
      GoRoute(
        path: Routes.editProfile,
        pageBuilder: (context, state) {
          final user = state.extra as UserModel;
          return _buildPageWithTransition(
            child: EditProfileView(user: user),
            state: state,
          );
        },
      ),
      GoRoute(
        path: Routes.changePassword,
        pageBuilder: (context, state) => _buildPageWithTransition(
          child: const ChangePasswordView(),
          state: state,
        ),
      ),
      GoRoute(
        path: Routes.paymentHistory,
        pageBuilder: (context, state) => _buildPageWithTransition(
          child: const PaymentHistoryScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: Routes.paymentDetail,
        pageBuilder: (context, state) {
          final params = state.extra as Map<String, dynamic>;
          final paymentId = params['paymentId'] as String;
          final isPlanPayment = params['isPlanPayment'] as bool;
          return _buildPageWithTransition(
            child: PaymentDetailScreen(
              paymentId: paymentId,
              isPlanPayment: isPlanPayment,
            ),
            state: state,
          );
        },
      ),
      GoRoute(
        path: Routes.createPlanPayment,
        pageBuilder: (context, state) => _buildPageWithTransition(
          child: const CreatePlanPaymentScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: Routes.createServicePayment,
        pageBuilder: (context, state) => _buildPageWithTransition(
          child: const CreateServicePaymentScreen(),
          state: state,
        ),
      ),
    ],
  );

  static CustomTransitionPage _buildPageWithTransition({
    required Widget child,
    required GoRouterState state,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
    );
  }
}
