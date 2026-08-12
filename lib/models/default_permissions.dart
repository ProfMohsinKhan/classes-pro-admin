import 'permission_keys.dart';

class DefaultPermissions {
  const DefaultPermissions._();

  static Map<String, bool> forRole(String role) {
    switch (role) {
      case 'admin':
        return admin;
      case 'coAdmin':
        return coAdmin;
      case 'receptionist':
        return receptionist;
      case 'studentHelper':
        return studentHelper;
      default:
        return none;
    }
  }

  static Map<String, bool> get admin => {
    for (final key in PermissionKeys.all) key: true,
  };

  static Map<String, bool> get coAdmin => {
    ...none,
    PermissionKeys.dashboardView: true,
    PermissionKeys.studentsView: true,
    PermissionKeys.studentsCreate: true,
    PermissionKeys.studentsEdit: true,
    PermissionKeys.attendanceView: true,
    PermissionKeys.attendanceMark: true,
    PermissionKeys.attendanceEditPast: true,
    PermissionKeys.feesView: true,
    PermissionKeys.feesCollect: true,
    PermissionKeys.feesEditPlan: true,
    PermissionKeys.feesViewHistory: true,
    PermissionKeys.feesEditPaymentHistory: true,
    PermissionKeys.feesShareReceipt: true,
    PermissionKeys.reportsView: true,
    PermissionKeys.reportsExport: true,
    PermissionKeys.remindersView: true,
    PermissionKeys.remindersCreate: true,
    PermissionKeys.remindersEdit: true,
    PermissionKeys.templatesUse: true,
    PermissionKeys.templatesManage: true,
    PermissionKeys.batchesView: true,
    PermissionKeys.batchesManage: true,
    PermissionKeys.coursesView: true,
    PermissionKeys.coursesManage: true,
    PermissionKeys.enrollmentsView: true,
    PermissionKeys.enrollmentsManage: true,
    PermissionKeys.documentsStudentPdf: true,
    PermissionKeys.documentsFeeStatementPdf: true,
    PermissionKeys.documentsAttendancePdf: true,
  };

  static Map<String, bool> get receptionist => {
    ...none,
    PermissionKeys.dashboardView: true,
    PermissionKeys.studentsView: true,
    PermissionKeys.studentsCreate: true,
    PermissionKeys.studentsEdit: true,
    PermissionKeys.attendanceView: true,
    PermissionKeys.attendanceMark: true,
    PermissionKeys.feesView: true,
    PermissionKeys.feesCollect: true,
    PermissionKeys.feesViewHistory: true,
    PermissionKeys.feesShareReceipt: true,
    PermissionKeys.reportsView: true,
    PermissionKeys.remindersView: true,
    PermissionKeys.remindersCreate: true,
    PermissionKeys.remindersEdit: true,
    PermissionKeys.templatesUse: true,
    PermissionKeys.batchesView: true,
    PermissionKeys.coursesView: true,
    PermissionKeys.enrollmentsView: true,
    PermissionKeys.documentsStudentPdf: true,
    PermissionKeys.documentsFeeStatementPdf: true,
    PermissionKeys.documentsAttendancePdf: true,
  };

  static Map<String, bool> get studentHelper => {
    ...none,
    PermissionKeys.dashboardView: true,
    PermissionKeys.attendanceView: true,
    PermissionKeys.attendanceMark: true,
  };

  static Map<String, bool> get none => {
    for (final key in PermissionKeys.all) key: false,
  };
}
