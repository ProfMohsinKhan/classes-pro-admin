import 'package:cloud_firestore/cloud_firestore.dart';

import 'default_permissions.dart';
import 'permission_keys.dart';

class AppUserModel {
  const AppUserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    required this.status,
    this.permissions = const {},
    this.mustChangePassword = false,
    this.studentRecordId,
    this.studentId,
    this.studentNumericId,
    this.loginId,
    this.createdAt,
    this.updatedAt,
  });

  final String uid;
  final String email;
  final String name;
  final String role;
  final String status;
  final Map<String, bool> permissions;
  final bool mustChangePassword;
  final String? studentRecordId;
  final String? studentId;
  final int? studentNumericId;
  final String? loginId;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  factory AppUserModel.fromMap(Map<String, dynamic> map) {
    return AppUserModel(
      uid: map['uid']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      role: map['role']?.toString() ?? '',
      status: map['status']?.toString() ?? '',
      permissions: _parsePermissions(map['permissions']),
      mustChangePassword: map['mustChangePassword'] == true,
      studentRecordId: map['studentRecordId']?.toString(),
      studentId: map['studentId']?.toString(),
      studentNumericId: _parseInt(map['studentNumericId']),
      loginId: map['loginId']?.toString(),
      createdAt: map['createdAt'] is Timestamp ? map['createdAt'] : null,
      updatedAt: map['updatedAt'] is Timestamp ? map['updatedAt'] : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
      'status': status,
      'permissions': permissions,
      'mustChangePassword': mustChangePassword,
      'studentRecordId': studentRecordId,
      'studentId': studentId,
      'studentNumericId': studentNumericId,
      'loginId': loginId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  bool get isAdmin => role == 'admin';
  bool get isCoAdmin => role == 'coAdmin';
  bool get isReceptionist => role == 'receptionist';
  bool get isStudentHelper => role == 'studentHelper';
  bool get isStudent => role == 'student';
  bool get isActive => status == 'active';

  bool can(String permissionKey) {
    if (!isActive) return false;
    if (isAdmin) return true;

    return permissions[permissionKey] ??
        DefaultPermissions.forRole(role)[permissionKey] ??
        false;
  }

  Map<String, bool> get effectivePermissions {
    if (isAdmin) return DefaultPermissions.admin;

    final merged = {...DefaultPermissions.forRole(role), ...permissions};

    return {for (final key in PermissionKeys.all) key: merged[key] ?? false};
  }

  bool get canViewStudents => can(PermissionKeys.studentsView);
  bool get canViewDashboard => can(PermissionKeys.dashboardView);
  bool get canCreateStudents => can(PermissionKeys.studentsCreate);
  bool get canEditStudents => can(PermissionKeys.studentsEdit);
  bool get canDeleteStudents => can(PermissionKeys.studentsDelete);
  bool get canManageStudents => canViewStudents;
  bool get canViewAttendance => can(PermissionKeys.attendanceView);
  bool get canMarkAttendance => can(PermissionKeys.attendanceMark);
  bool get canEditPastAttendance => can(PermissionKeys.attendanceEditPast);
  bool get canViewFees => can(PermissionKeys.feesView);
  bool get canCollectFees => can(PermissionKeys.feesCollect);
  bool get canManageFees => canViewFees;
  bool get canEditFeePlan => can(PermissionKeys.feesEditPlan);
  bool get canEditPaymentHistory => can(PermissionKeys.feesEditPaymentHistory);
  bool get canShareReceipt => can(PermissionKeys.feesShareReceipt);
  bool get canViewReports => can(PermissionKeys.reportsView);
  bool get canExportReports => can(PermissionKeys.reportsExport);
  bool get canViewReminders => can(PermissionKeys.remindersView);
  bool get canCreateReminders => can(PermissionKeys.remindersCreate);
  bool get canEditReminders => can(PermissionKeys.remindersEdit);
  bool get canDeleteReminders => can(PermissionKeys.remindersDelete);
  bool get canManageReminders =>
      can(PermissionKeys.remindersCreate) || can(PermissionKeys.remindersEdit);
  bool get canUseMessageTemplates => can(PermissionKeys.templatesUse);
  bool get canManageMessageTemplates => can(PermissionKeys.templatesManage);
  bool get canManageStaff => can(PermissionKeys.staffManage);
  bool get canAccessSettings => can(PermissionKeys.settingsManage);
  bool get canManageInstituteSettings => canAccessSettings;
  bool get canManageBackups => can(PermissionKeys.backupExport);
  bool get canExportBackups => can(PermissionKeys.backupExport);
  bool get canRestoreBackups => can(PermissionKeys.backupRestore);
  bool get canViewBatches => can(PermissionKeys.batchesView);
  bool get canManageBatches => can(PermissionKeys.batchesManage);
  bool get canViewCourses => can(PermissionKeys.coursesView);
  bool get canManageCourses => can(PermissionKeys.coursesManage);
  bool get canViewEnrollments => can(PermissionKeys.enrollmentsView);
  bool get canManageEnrollments => can(PermissionKeys.enrollmentsManage);
  bool get canGenerateStudentPdf => can(PermissionKeys.documentsStudentPdf);
  bool get canGenerateFeeStatementPdf =>
      can(PermissionKeys.documentsFeeStatementPdf);
  bool get canGenerateAttendancePdf =>
      can(PermissionKeys.documentsAttendancePdf);

  static Map<String, bool> _parsePermissions(dynamic value) {
    if (value is! Map) return const {};

    final parsed = <String, bool>{};
    void collect(String prefix, Map map) {
      for (final entry in map.entries) {
        final key = entry.key.toString();
        final permissionKey = prefix.isEmpty ? key : '$prefix.$key';
        final permissionValue = entry.value;

        if (permissionValue is bool) {
          parsed[permissionKey] = permissionValue;
        } else if (permissionValue is Map) {
          collect(permissionKey, permissionValue);
        }
      }
    }

    collect('', value);
    return parsed;
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
