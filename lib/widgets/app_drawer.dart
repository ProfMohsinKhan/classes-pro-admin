import 'package:classes_pro_admin/screens/batch_screen.dart';
import 'package:classes_pro_admin/screens/backup_center_screen.dart';
import 'package:classes_pro_admin/screens/course_screen.dart';
import 'package:classes_pro_admin/screens/enquiries_screen.dart';
import 'package:classes_pro_admin/screens/enrollment_screen.dart';
import 'package:classes_pro_admin/screens/fees_screen.dart';
import 'package:classes_pro_admin/screens/institute_settings_screen.dart';
import 'package:classes_pro_admin/screens/reports_screen.dart';
import 'package:classes_pro_admin/screens/reminders_screen.dart';
import 'package:classes_pro_admin/screens/staff_roles_screen.dart';
import 'package:classes_pro_admin/services/auth_service.dart';
import 'package:flutter/material.dart';

import '../models/app_user_model.dart';
import '../screens/dashboard_screen.dart';
import '../theme/app_theme.dart';
// Screens ko import karna zaroori hai
import '../screens/student_list_screen.dart';
import '../screens/attendance_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.appUser});

  final AppUserModel appUser;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.surface,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: AppTheme.primarySoft,
                    child: Icon(
                      Icons.school,
                      color: AppTheme.primary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Mak Tutorials",
                    style: TextStyle(
                      color: AppTheme.text,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primarySoft,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _roleLabel(appUser.role),
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Menu Items Section
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                if (appUser.canViewDashboard)
                  _drawerItem(Icons.dashboard_outlined, "Dashboard", () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DashboardScreen(appUser: appUser),
                      ),
                    );
                  }),
                if (appUser.canViewStudents)
                  _drawerItem(Icons.group_outlined, "Students", () {
                    Navigator.pop(context); // Drawer band karo
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StudentListScreen(),
                      ),
                    );
                  }),
                if (appUser.canViewAttendance)
                  _drawerItem(Icons.calendar_month_outlined, "Attendance", () {
                    Navigator.pop(context); // Drawer band karo
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AttendanceScreen(),
                      ),
                    );
                  }),

                if (appUser.canViewBatches || appUser.canManageBatches)
                  _drawerItem(Icons.layers_outlined, "Batches", () {
                    Navigator.pop(context); // Drawer band karo
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BatchScreen(),
                      ),
                    );
                  }),

                if (appUser.canViewCourses || appUser.canManageCourses)
                  _drawerItem(Icons.book_outlined, "Course", () {
                    Navigator.pop(context); // Drawer band karo
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CourseScreen(),
                      ),
                    );
                  }),

                if (appUser.canViewStudents)
                  _drawerItem(Icons.question_answer_outlined, "Enquiries", () {
                    Navigator.pop(context); // Drawer band karo
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EnquiriesScreen(),
                      ),
                    );
                  }),

                if (appUser.canViewEnrollments || appUser.canManageEnrollments)
                  _drawerItem(Icons.assignment_ind_outlined, "Enrollment", () {
                    Navigator.pop(context); // Drawer band karo
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EnrollmentScreen(),
                      ),
                    );
                  }),

                if (appUser.canViewFees)
                  _drawerItem(Icons.payments_outlined, "Fee Payments", () {
                    Navigator.pop(context); // Drawer band karo
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FeesScreen(),
                      ),
                    );
                  }),
                if (appUser.canViewReports)
                  _drawerItem(Icons.analytics_outlined, "Reports", () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReportsScreen(),
                      ),
                    );
                  }),
                if (appUser.canViewReminders)
                  _drawerItem(Icons.notifications_outlined, "Reminders", () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RemindersScreen(),
                      ),
                    );
                  }),
                if (appUser.canManageStaff)
                  _drawerItem(
                    Icons.admin_panel_settings_outlined,
                    "Staff/Roles",
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StaffRolesScreen(),
                        ),
                      );
                    },
                  ),
                if (appUser.canExportBackups || appUser.canRestoreBackups)
                  _drawerItem(Icons.backup_outlined, "Backup & Safety", () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BackupCenterScreen(),
                      ),
                    );
                  }),
                if (appUser.canAccessSettings)
                  _drawerItem(Icons.settings_outlined, "Settings", () {
                    Navigator.pop(context); // Drawer band karo
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InstituteSettingsScreen(),
                      ),
                    );
                  }),
              ],
            ),
          ),

          // Bottom Section
          const Divider(color: AppTheme.border, indent: 20, endIndent: 20),
          _drawerItem(Icons.logout, "Logout", () async {
            Navigator.pop(context);
            await AuthService.instance.signOut();
          }, color: AppTheme.danger),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Reusable Drawer Item Widget
  Widget _drawerItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color color = AppTheme.text,
  }) {
    final isLogout = color == AppTheme.danger;
    return ListTile(
      leading: Icon(
        icon,
        color: isLogout ? AppTheme.danger : AppTheme.primary,
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      tileColor: isLogout ? AppTheme.dangerSoft : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap,
    );
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'admin':
        return 'Admin';
      case 'coAdmin':
        return 'Co Admin';
      case 'receptionist':
        return 'Receptionist';
      case 'studentHelper':
        return 'Student Helper';
      default:
        return 'Pending Role';
    }
  }
}
