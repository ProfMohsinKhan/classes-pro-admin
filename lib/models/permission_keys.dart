class PermissionKeys {
  const PermissionKeys._();

  static const dashboardView = 'dashboard.view';

  static const studentsView = 'students.view';
  static const studentsCreate = 'students.create';
  static const studentsEdit = 'students.edit';
  static const studentsDelete = 'students.delete';
  static const studentsExportPdf = 'students.exportPdf';

  static const attendanceView = 'attendance.view';
  static const attendanceMark = 'attendance.mark';
  static const attendanceEditPast = 'attendance.editPast';
  static const attendanceExport = 'attendance.export';

  static const feesView = 'fees.view';
  static const feesCollect = 'fees.collect';
  static const feesEditPlan = 'fees.editPlan';
  static const feesViewHistory = 'fees.viewHistory';
  static const feesEditPaymentHistory = 'fees.editPaymentHistory';
  static const feesShareReceipt = 'fees.shareReceipt';
  static const feesDeletePayment = 'fees.deletePayment';

  static const reportsView = 'reports.view';
  static const reportsExport = 'reports.export';

  static const remindersView = 'reminders.view';
  static const remindersCreate = 'reminders.create';
  static const remindersEdit = 'reminders.edit';
  static const remindersDelete = 'reminders.delete';

  static const templatesUse = 'templates.use';
  static const templatesManage = 'templates.manage';

  static const batchesView = 'batches.view';
  static const batchesManage = 'batches.manage';
  static const coursesView = 'courses.view';
  static const coursesManage = 'courses.manage';
  static const enrollmentsView = 'enrollments.view';
  static const enrollmentsManage = 'enrollments.manage';

  static const staffManage = 'staff.manage';
  static const settingsManage = 'settings.manage';
  static const backupExport = 'backup.export';
  static const backupRestore = 'backup.restore';

  static const documentsStudentPdf = 'documents.studentPdf';
  static const documentsFeeStatementPdf = 'documents.feeStatementPdf';
  static const documentsAttendancePdf = 'documents.attendancePdf';

  static const all = <String>[
    dashboardView,
    studentsView,
    studentsCreate,
    studentsEdit,
    studentsDelete,
    studentsExportPdf,
    attendanceView,
    attendanceMark,
    attendanceEditPast,
    attendanceExport,
    feesView,
    feesCollect,
    feesEditPlan,
    feesViewHistory,
    feesEditPaymentHistory,
    feesShareReceipt,
    feesDeletePayment,
    reportsView,
    reportsExport,
    remindersView,
    remindersCreate,
    remindersEdit,
    remindersDelete,
    templatesUse,
    templatesManage,
    batchesView,
    batchesManage,
    coursesView,
    coursesManage,
    enrollmentsView,
    enrollmentsManage,
    staffManage,
    settingsManage,
    backupExport,
    backupRestore,
    documentsStudentPdf,
    documentsFeeStatementPdf,
    documentsAttendancePdf,
  ];
}
