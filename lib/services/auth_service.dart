import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/auth/student_login.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  static const _prefRememberMe = 'pref_remember_me';
  static const _prefSavedLoginId = 'pref_saved_login_id';
  static const _prefSavedPassword = 'pref_saved_password';
  static const _prefJustLoggedOut = 'pref_just_logged_out';

  FirebaseAuth get _firebaseAuth => FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> signInWithIdentifier({
    required String identifier,
    required String password,
  }) {
    final cleanIdentifier = identifier.trim();
    final email = StudentLogin.isContactIdentifier(cleanIdentifier)
        ? StudentLogin.emailForContact(cleanIdentifier)
        : cleanIdentifier;
    return signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _firebaseAuth.currentUser;
    final email = user?.email;
    if (user == null || email == null || email.isEmpty) {
      throw StateError('Your session has expired. Please sign in again.');
    }

    await user.reauthenticateWithCredential(
      EmailAuthProvider.credential(email: email, password: currentPassword),
    );
    await user.updatePassword(newPassword);
  }

  Future<void> saveSavedCredentials({
    required String loginId,
    required String password,
    required bool rememberMe,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefRememberMe, rememberMe);
      if (rememberMe) {
        await prefs.setString(_prefSavedLoginId, loginId.trim());
        await prefs.setString(_prefSavedPassword, password);
      } else {
        await prefs.remove(_prefSavedLoginId);
        await prefs.remove(_prefSavedPassword);
      }
      await prefs.setBool(_prefJustLoggedOut, false);
    } catch (_) {}
  }

  Future<({String? loginId, String? password, bool rememberMe, bool justLoggedOut})>
      loadSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool(_prefRememberMe) ?? true;
      final loginId = prefs.getString(_prefSavedLoginId);
      final password = prefs.getString(_prefSavedPassword);
      final justLoggedOut = prefs.getBool(_prefJustLoggedOut) ?? false;
      return (
        loginId: loginId,
        password: password,
        rememberMe: rememberMe,
        justLoggedOut: justLoggedOut,
      );
    } catch (_) {
      return (
        loginId: null,
        password: null,
        rememberMe: true,
        justLoggedOut: false,
      );
    }
  }

  Future<void> clearSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefSavedLoginId);
      await prefs.remove(_prefSavedPassword);
      await prefs.setBool(_prefRememberMe, false);
    } catch (_) {}
  }

  Future<void> clearJustLoggedOutFlag() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefJustLoggedOut, false);
    } catch (_) {}
  }

  Future<void> signOut({bool isExplicitLogout = true}) async {
    if (isExplicitLogout) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_prefJustLoggedOut, true);
      } catch (_) {}
    }
    return _firebaseAuth.signOut();
  }
}

