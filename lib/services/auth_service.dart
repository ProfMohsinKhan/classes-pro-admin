import 'package:firebase_auth/firebase_auth.dart';

import '../core/auth/student_login.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

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

  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }
}
