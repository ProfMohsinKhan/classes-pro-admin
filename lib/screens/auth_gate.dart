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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFEFF6FF),
                    Color(0xFFF8FAFC),
                    Color(0xFFF1F5F9),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 82,
                  height: 82,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.border, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.12),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/icon/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Mak Tutorials',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.text,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 18),
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.6,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

