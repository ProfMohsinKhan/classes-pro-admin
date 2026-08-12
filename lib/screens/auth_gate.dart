import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';
import '../data/sync/offline_startup_coordinator.dart';
import 'access_pending_screen.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';
import 'student_portal_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService.instance.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppTheme.background,
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            ),
          );
        }

        final authUser = snapshot.data;
        if (authUser != null) {
          return FutureBuilder<void>(
            future: UserService.instance.ensureFirstAdminProfile(authUser),
            builder: (context, bootstrapSnapshot) {
              if (bootstrapSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const _AuthLoadingScreen();
              }

              return StreamBuilder(
                stream: UserService.instance.streamUserProfile(authUser.uid),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const _AuthLoadingScreen();
                  }

                  final appUser = userSnapshot.data;
                  if (appUser == null || !appUser.isActive) {
                    return const AccessPendingScreen();
                  }

                  if (appUser.isStudent) {
                    return StudentPortalScreen(appUser: appUser);
                  }

                  OfflineStartupCoordinator.startForActiveUser(authUser.uid);
                  return DashboardScreen(appUser: appUser);
                },
              );
            },
          );
        }

        return const LoginScreen();
      },
    );
  }
}

class _AuthLoadingScreen extends StatelessWidget {
  const _AuthLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
    );
  }
}
