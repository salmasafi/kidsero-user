import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kidsero_driver/features/auth/ui/view/role_selection_view.dart';
import 'package:kidsero_driver/features/auth/ui/view/login_view.dart';
import 'package:kidsero_driver/features/profile/ui/view/profile_view.dart';
import 'package:kidsero_driver/features/profile/ui/view/edit_profile_view.dart';
import 'package:kidsero_driver/features/profile/ui/view/change_password_view.dart';
import '../utils/enums.dart';
import 'package:kidsero_driver/features/auth/data/models/user_model.dart';
import '../../main.dart';
import 'routes.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: Routes.roleSelection,
    routes: [
      GoRoute(
        path: Routes.roleSelection,
        pageBuilder: (context, state) => _buildPageWithTransition(
          child: const RoleSelectionView(),
          state: state,
        ),
      ),
      GoRoute(
        path: Routes.login,
        pageBuilder: (context, state) {
          final role = state.extra as UserRole;
          return _buildPageWithTransition(
            child: LoginView(role: role),
            state: state,
          );
        },
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
