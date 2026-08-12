import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../core/auth/student_login.dart';
import '../firebase_options.dart';
import '../models/app_user_model.dart';
import '../models/default_permissions.dart';
import '../models/permission_keys.dart';
import '../models/student_model.dart';

class PermissionBackfillResult {
  const PermissionBackfillResult({
    required this.updatedCount,
    required this.skippedCount,
    required this.totalCount,
    required this.errors,
  });

  final int updatedCount;
  final int skippedCount;
  final int totalCount;
  final List<String> errors;
}

class CreateStaffInput {
  const CreateStaffInput({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.applyDefaultPermissions,
    required this.createdBy,
  });

  final String name;
  final String email;
  final String password;
  final String role;
  final bool applyDefaultPermissions;
  final AppUserModel createdBy;
}

class ExistingAuthProfileInput {
  const ExistingAuthProfileInput({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.createdBy,
  });

  final String uid;
  final String name;
  final String email;
  final String role;
  final AppUserModel createdBy;
}

class CreateStudentLoginInput {
  const CreateStudentLoginInput({
    required this.student,
    required this.createdBy,
  });

  final StudentModel student;
  final AppUserModel createdBy;
}

class StudentLoginCredentials {
  const StudentLoginCredentials({required this.loginId});

  final String loginId;
  String get initialPassword => loginId;
}

class UserService {
  UserService._();

  static final UserService instance = UserService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static const _staffCreationAppName = 'staffCreation';

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  Future<AppUserModel?> getCurrentUserProfile() async {
    final authUser = _firebaseAuth.currentUser;
    if (authUser == null) return null;

    final doc = await _usersCollection.doc(authUser.uid).get();
    if (!doc.exists || doc.data() == null) return null;

    return AppUserModel.fromMap(doc.data()!);
  }

  Stream<AppUserModel?> streamCurrentUserProfile() {
    final authUser = _firebaseAuth.currentUser;
    if (authUser == null) return Stream.value(null);

    return streamUserProfile(authUser.uid);
  }

  Stream<AppUserModel?> streamUserProfile(String uid) {
    return _usersCollection.doc(uid).snapshots().map((doc) {
      final data = doc.data();
      if (!doc.exists || data == null) return null;

      return AppUserModel.fromMap(data);
    });
  }

  Future<void> createOrUpdateUserProfile(AppUserModel user) async {
    final data = user.toMap()
      ..['updatedAt'] = FieldValue.serverTimestamp()
      ..removeWhere((key, value) => value == null);

    if (user.permissions.isEmpty) {
      data.remove('permissions');
    }

    await _usersCollection.doc(user.uid).set(data, SetOptions(merge: true));
  }

  Future<AppUserModel> createStaffAccount(CreateStaffInput input) async {
    final secondaryAuth = await _secondaryStaffCreationAuth();
    UserCredential? credential;

    try {
      credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: input.email.trim(),
        password: input.password,
      );
    } finally {
      await secondaryAuth.signOut();
    }

    final authUser = credential.user;
    if (authUser == null) {
      throw FirebaseAuthException(
        code: 'user-create-failed',
        message: 'Firebase Auth did not return a staff account.',
      );
    }

    try {
      return await createExistingAuthUserProfile(
        ExistingAuthProfileInput(
          uid: authUser.uid,
          name: input.name,
          email: input.email,
          role: input.role,
          createdBy: input.createdBy,
        ),
        mustChangePassword: true,
        applyDefaultPermissions: input.applyDefaultPermissions,
      );
    } catch (_) {
      throw StateError(
        'Auth account was created but staff profile failed. Please check Firestore users collection.',
      );
    }
  }

  Future<StudentLoginCredentials> createStudentLogin(
    CreateStudentLoginInput input,
  ) async {
    final student = input.student;
    if (student.id.trim().isEmpty) {
      throw StateError('Save the student before creating a login.');
    }

    final loginId = StudentLogin.contactId(student.primaryPhone);
    final existing = await _usersCollection
        .where('studentRecordId', isEqualTo: student.id)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      throw StateError('A login already exists for this student.');
    }

    final secondaryAuth = await _secondaryStaffCreationAuth();
    UserCredential? credential;
    try {
      credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: StudentLogin.emailForContact(loginId),
        password: loginId,
      );
      final authUser = credential.user;
      if (authUser == null) {
        throw FirebaseAuthException(
          code: 'user-create-failed',
          message: 'Firebase Auth did not return a student account.',
        );
      }

      await _usersCollection.doc(authUser.uid).set({
        'uid': authUser.uid,
        'email': StudentLogin.emailForContact(loginId),
        'name': student.displayName,
        'role': 'student',
        'status': 'active',
        'permissions': DefaultPermissions.none,
        'mustChangePassword': true,
        'studentRecordId': student.id,
        'studentId': student.studentId,
        if (student.numericId != null) 'studentNumericId': student.numericId,
        'loginId': loginId,
        'createdBy': input.createdBy.uid,
        'createdByName': input.createdBy.name.trim().isNotEmpty
            ? input.createdBy.name.trim()
            : input.createdBy.email.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Do not leave an Auth account that cannot access the student portal.
      try {
        await credential?.user?.delete();
      } catch (_) {}
      throw StateError(
        'Student login could not be created. Please try again or contact an admin.',
      );
    } finally {
      await secondaryAuth.signOut();
    }

    return StudentLoginCredentials(loginId: loginId);
  }

  Future<AppUserModel> createExistingAuthUserProfile(
    ExistingAuthProfileInput input, {
    bool mustChangePassword = false,
    bool applyDefaultPermissions = true,
  }) async {
    final docRef = _usersCollection.doc(input.uid.trim());
    final existing = await docRef.get();
    if (existing.exists) {
      throw StateError('A Firestore profile already exists for this UID.');
    }

    final now = FieldValue.serverTimestamp();
    final permissions = input.role == 'admin' || applyDefaultPermissions
        ? DefaultPermissions.forRole(input.role)
        : DefaultPermissions.none;
    final createdByLabel = input.createdBy.name.trim().isNotEmpty
        ? input.createdBy.name.trim()
        : input.createdBy.email.trim();

    await docRef.set({
      'uid': input.uid.trim(),
      'email': input.email.trim(),
      'name': input.name.trim(),
      'role': input.role,
      'status': 'active',
      'permissions': permissions,
      'mustChangePassword': mustChangePassword,
      'createdBy': input.createdBy.uid,
      'createdByName': createdByLabel,
      'createdAt': now,
      'updatedAt': now,
    });

    return AppUserModel(
      uid: input.uid.trim(),
      email: input.email.trim(),
      name: input.name.trim(),
      role: input.role,
      status: 'active',
      permissions: permissions,
      mustChangePassword: mustChangePassword,
    );
  }

  Stream<List<AppUserModel>> streamAllUsers() {
    return _usersCollection.snapshots().map((snapshot) {
      final users = snapshot.docs
          .map((doc) => AppUserModel.fromMap(doc.data()))
          .toList();
      users.sort((a, b) => a.email.compareTo(b.email));
      return users;
    });
  }

  Future<void> updateRole(String uid, String role) {
    return _usersCollection.doc(uid).update({
      'role': role,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateStatus(String uid, String status) async {
    final currentUid = _firebaseAuth.currentUser?.uid;
    if (uid == currentUid && status != 'active') {
      throw StateError('You cannot disable your own account.');
    }

    if (status != 'active') {
      final targetDoc = await _usersCollection.doc(uid).get();
      final target = targetDoc.data();
      if (target != null && target['role'] == 'admin') {
        final otherAdmins = await _usersCollection
            .where('role', isEqualTo: 'admin')
            .where('status', isEqualTo: 'active')
            .get();
        final hasOtherActiveAdmin = otherAdmins.docs.any(
          (doc) => doc.id != uid,
        );
        if (!hasOtherActiveAdmin) {
          throw StateError('At least one active admin is required.');
        }
      }
    }

    return _usersCollection.doc(uid).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _firebaseAuth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> markCurrentPasswordChanged() async {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null) return;
    await _usersCollection.doc(uid).update({
      'mustChangePassword': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateUserPermissions(
    String uid,
    Map<String, bool> permissions,
  ) {
    return _usersCollection.doc(uid).update({
      'permissions': permissions,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> resetPermissionsToRoleDefault(String uid, String role) {
    return updateUserPermissions(uid, DefaultPermissions.forRole(role));
  }

  Map<String, bool> mergeMissingPermissions({
    required String role,
    required Map<String, bool> existingPermissions,
  }) {
    if (role == 'admin') return DefaultPermissions.admin;

    final defaults = DefaultPermissions.forRole(role);
    return {
      for (final key in PermissionKeys.all)
        key: existingPermissions[key] ?? defaults[key] ?? false,
    };
  }

  Future<PermissionBackfillResult>
  backfillMissingPermissionsForAllUsers() async {
    final snapshot = await _usersCollection.get();
    var updatedCount = 0;
    var skippedCount = 0;
    final errors = <String>[];

    WriteBatch batch = _firestore.batch();
    var batchWrites = 0;

    Future<void> commitBatchIfNeeded({bool force = false}) async {
      if (batchWrites == 0 || (!force && batchWrites < 450)) return;
      await batch.commit();
      batch = _firestore.batch();
      batchWrites = 0;
    }

    for (final doc in snapshot.docs) {
      try {
        final user = AppUserModel.fromMap(doc.data());
        final merged = mergeMissingPermissions(
          role: user.role,
          existingPermissions: user.permissions,
        );
        final isComplete = PermissionKeys.all.every(
          (key) => user.permissions.containsKey(key),
        );
        final needsAdminFullMap =
            user.isAdmin &&
            PermissionKeys.all.any((key) => user.permissions[key] != true);

        if (isComplete && !needsAdminFullMap) {
          skippedCount++;
          continue;
        }

        batch.update(doc.reference, {
          'permissions': merged,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        batchWrites++;
        updatedCount++;
        await commitBatchIfNeeded();
      } catch (error) {
        errors.add('${doc.id}: $error');
      }
    }

    await commitBatchIfNeeded(force: true);

    return PermissionBackfillResult(
      updatedCount: updatedCount,
      skippedCount: skippedCount,
      totalCount: snapshot.docs.length,
      errors: errors,
    );
  }

  Future<void> ensureFirstAdminProfile(User authUser) async {
    final userDoc = await _usersCollection.doc(authUser.uid).get();
    if (userDoc.exists) return;

    final firstUserSnapshot = await _usersCollection.limit(1).get();
    if (firstUserSnapshot.docs.isNotEmpty) return;

    final email = authUser.email ?? '';
    final name = _nameFromEmail(email);

    await _usersCollection.doc(authUser.uid).set({
      'uid': authUser.uid,
      'email': email,
      'name': name,
      'role': 'admin',
      'status': 'active',
      'permissions': DefaultPermissions.admin,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  String _nameFromEmail(String email) {
    if (email.isEmpty) return 'Admin';
    return email.split('@').first;
  }

  Future<FirebaseAuth> _secondaryStaffCreationAuth() async {
    FirebaseApp app;
    try {
      app = Firebase.app(_staffCreationAppName);
    } on FirebaseException {
      app = await Firebase.initializeApp(
        name: _staffCreationAppName,
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    return FirebaseAuth.instanceFor(app: app);
  }
}
