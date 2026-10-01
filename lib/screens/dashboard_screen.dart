import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/app_user_model.dart';
import '../services/institute_settings_service.dart';
import '../services/attendance_reminder_service.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_ui.dart';
import 'attendance_screen.dart';
import 'batch_screen.dart';
import 'fees_screen.dart';
import 'reminders_screen.dart';
import 'reports_screen.dart';
import 'staff_roles_screen.dart';
import 'student_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.appUser});

  final AppUserModel appUser;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<_DashboardData> _dashboardFuture;
  final Set<String> _expandedSections = {'feesDue'};
  bool _isSendingPasswordReset = false;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _loadDashboardData();
    AttendanceReminderService.instance.bindAttendanceNavigation(
      _openAttendanceFromReminder,
    );
    unawaited(_setupAttendanceReminders());
  }

  @override
  void dispose() {
    AttendanceReminderService.instance.clearAttendanceNavigationHandler();
    super.dispose();
  }

  Future<void> _openAttendanceFromReminder() async {
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => const AttendanceScreen()),
    );
  }

  Future<void> _setupAttendanceReminders() async {
    if (!widget.appUser.canMarkAttendance) return;
    final result = await AttendanceReminderService.instance
        .scheduleForActiveAdmin();
    if (!mounted || !result.isSupported || result.notificationsAllowed) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Enable notifications to receive the daily attendance reminder.',
        ),
        backgroundColor: AppTheme.warning,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _refreshDashboard() {
    setState(() {
      _dashboardFuture = _loadDashboardData();
    });
  }

  void _toggleSection(String sectionId) {
    setState(() {
      if (_expandedSections.contains(sectionId)) {
        _expandedSections.remove(sectionId);
      } else {
        _expandedSections.add(sectionId);
      }
    });
  }

  Future<void> _sendOwnPasswordReset() async {
    final email = widget.appUser.email.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email not available.'),
          backgroundColor: AppTheme.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSendingPasswordReset = true);
    try {
      await UserService.instance.sendPasswordResetEmail(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset email sent to $email'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset failed: $error'),
          backgroundColor: AppTheme.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSendingPasswordReset = false);
    }
  }

  Future<_DashboardData> _loadDashboardData() async {
    final firestore = FirebaseFirestore.instance;
    final settings = await InstituteSettingsService.instance.loadSettings();
    final today = DateTime.now();
    final todayKey = _dateKey(today);
    final weekEnd = DateTime(today.year, today.month, today.day + 7);

    final results = await Future.wait<QuerySnapshot<Map<String, dynamic>>>([
      firestore
          .collection('students')
          .where('deleted_at', isNull: true)
          .limit(20)
          .get(),
      firestore
          .collection('fee_payments')
          .where('deleted_at', isNull: true)
          .limit(20)
          .get(),
      firestore
          .collection('fee_payments')
          .where('status', isEqualTo: 'pending')
          .where('deleted_at', isNull: true)
          .limit(20)
          .get(),
      firestore
          .collection('fee_payments')
          .where('status', isEqualTo: 'paid')
          .where('deleted_at', isNull: true)
          .limit(20)
          .get(),
      firestore
          .collection('attendances')
          .where('date', isGreaterThanOrEqualTo: todayKey)
          .where('date', isLessThanOrEqualTo: '$todayKey\uf8ff')
          .limit(100)
          .get(),
      firestore
          .collection('batches')
          .where('deleted_at', isNull: true)
          .limit(5)
          .get(),
    ]);

    final studentsSnapshot = results[0];
    final recentFeesSnapshot = results[1];
    final pendingFeesSnapshot = results[2];
    final paidFeesSnapshot = results[3];
    final attendanceSnapshot = results[4];
    final batchesSnapshot = results[5];

    final totalStudents = await _safeCountStudents(studentsSnapshot.size);
    final studentNames = _studentNamesByNumericId(studentsSnapshot.docs);
    final birthdays = _upcomingBirthdays(studentsSnapshot.docs, today);
    final pendingFees = _pendingFeeItems(
      pendingFeesSnapshot.docs,
      studentNames,
      today,
      weekEnd,
    );

    return _DashboardData(
      totalStudents: totalStudents,
      presentToday: attendanceSnapshot.docs
          .where((doc) => doc.data()['status'] == 'present')
          .length,
      pendingFeesTotal: pendingFees.fold<double>(
        0,
        (total, item) => total + item.amount,
      ),
      collectedThisMonth: _paidThisMonth(paidFeesSnapshot.docs, today),
      birthdays: birthdays,
      dueToday: pendingFees.where((item) => item.isDueToday).toList(),
      dueThisWeek: pendingFees.where((item) => item.isDueThisWeek).toList(),
      pendingInstallments: pendingFees
          .where((item) => item.monthYear.toLowerCase().startsWith('inst.'))
          .toList(),
      batches: batchesSnapshot.docs
          .map((doc) => _BatchItem.fromMap(doc.data()))
          .toList(),
      recentActivities: widget.appUser.isStudentHelper
          ? _attendanceActivities(attendanceSnapshot.docs, studentNames)
          : _feeActivities(recentFeesSnapshot.docs, studentNames),
      instituteName: settings.instituteName,
    );
  }

  Future<int> _safeCountStudents(int fallback) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('students')
          .where('deleted_at', isNull: true)
          .count()
          .get();
      return snapshot.count ?? fallback;
    } catch (_) {
      return fallback;
    }
  }

  Map<int, String> _studentNamesByNumericId(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final names = <int, String>{};
    for (final doc in docs) {
      final data = doc.data();
      final id = (data['id'] as num?)?.toInt();
      if (id != null) {
        names[id] = data['name']?.toString() ?? 'Unknown Student';
      }
    }
    return names;
  }

  List<_BirthdayItem> _upcomingBirthdays(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    DateTime today,
  ) {
    final todayOnly = DateTime(today.year, today.month, today.day);
    final items = <_BirthdayItem>[];

    for (final doc in docs) {
      final data = doc.data();
      final dob = _parseDate(
        data['dob'] ?? data['dateOfBirth'] ?? data['birthDate'],
      );
      if (dob == null) continue;

      var nextBirthday = DateTime(today.year, dob.month, dob.day);
      if (nextBirthday.isBefore(todayOnly)) {
        nextBirthday = DateTime(today.year + 1, dob.month, dob.day);
      }

      final daysLeft = nextBirthday.difference(todayOnly).inDays;
      if (daysLeft >= 0 && daysLeft <= 7) {
        items.add(
          _BirthdayItem(
            name: data['name']?.toString() ?? 'Unknown Student',
            batch: (data['batch'] ?? data['batch_name'] ?? data['class'])
                ?.toString(),
            birthday: nextBirthday,
            daysLeft: daysLeft,
          ),
        );
      }
    }

    items.sort((a, b) => a.daysLeft.compareTo(b.daysLeft));
    return items.take(5).toList();
  }

  List<_FeeDueItem> _pendingFeeItems(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    Map<int, String> studentNames,
    DateTime today,
    DateTime weekEnd,
  ) {
    final todayOnly = DateTime(today.year, today.month, today.day);
    final weekEndOnly = DateTime(weekEnd.year, weekEnd.month, weekEnd.day);

    return docs.map((doc) {
      final data = doc.data();
      final studentId = (data['student_id'] as num?)?.toInt();
      final dueDate = _parseDate(
        data['dueDate'] ??
            data['due_date'] ??
            data['nextDueDate'] ??
            data['next_due_date'],
      );
      final amount = _parseAmount(
        data['dueAmount'] ??
            data['pendingAmount'] ??
            data['balance'] ??
            data['remaining'] ??
            data['total_amount'],
      );

      return _FeeDueItem(
        studentName: studentNames[studentId] ?? 'Unknown Student',
        amount: amount,
        dueDate: dueDate,
        monthYear: data['month_year']?.toString() ?? '',
        isDueToday: dueDate != null && _isSameDate(dueDate, todayOnly),
        isDueThisWeek:
            dueDate != null &&
            !dueDate.isBefore(todayOnly) &&
            !dueDate.isAfter(weekEndOnly),
      );
    }).toList()..sort((a, b) {
      final aDate = a.dueDate ?? DateTime(2099);
      final bDate = b.dueDate ?? DateTime(2099);
      return aDate.compareTo(bDate);
    });
  }

  double _paidThisMonth(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    DateTime today,
  ) {
    double total = 0;
    for (final doc in docs) {
      final data = doc.data();
      final paidDate = _parseDate(data['payment_date'] ?? data['updated_at']);
      if (paidDate == null ||
          paidDate.year != today.year ||
          paidDate.month != today.month) {
        continue;
      }
      total += _parseAmount(data['amount_paid']);
    }
    return total;
  }

  List<_ActivityItem> _feeActivities(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    Map<int, String> studentNames,
  ) {
    final items = docs.map((doc) {
      final data = doc.data();
      final studentId = (data['student_id'] as num?)?.toInt();
      final isPaid = data['status'] == 'paid';
      return _ActivityItem(
        title: studentNames[studentId] ?? 'Fee Activity',
        subtitle: isPaid
            ? 'Collected ${_formatCurrency(_parseAmount(data['amount_paid']))}'
            : 'Pending ${_formatCurrency(_parseAmount(data['total_amount']))}',
        icon: isPaid ? Icons.check_circle_rounded : Icons.receipt_long_rounded,
        color: isPaid ? AppTheme.success : AppTheme.warning,
      );
    }).toList();

    return items.take(5).toList();
  }

  List<_ActivityItem> _attendanceActivities(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    Map<int, String> studentNames,
  ) {
    final items = docs.map((doc) {
      final data = doc.data();
      final studentId = (data['student_id'] as num?)?.toInt();
      final status = data['status']?.toString() ?? 'marked';
      return _ActivityItem(
        title: studentNames[studentId] ?? 'Student #${studentId ?? '--'}',
        subtitle: 'Attendance $status today',
        icon: Icons.fact_check_rounded,
        color: status == 'present' ? AppTheme.success : AppTheme.warning,
      );
    }).toList();

    return items.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      drawer: AppDrawer(appUser: widget.appUser),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primary,
          backgroundColor: AppTheme.surface,
          onRefresh: () async => _refreshDashboard(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
            child: FutureBuilder<_DashboardData>(
              future: _dashboardFuture,
              builder: (context, snapshot) {
                final data = snapshot.data;
                final isLoading =
                    snapshot.connectionState == ConnectionState.waiting;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Header(
                      appUser: widget.appUser,
                      instituteName: data?.instituteName ?? 'Mak Tutorials',
                      isLoading: isLoading,
                      onRefresh: _refreshDashboard,
                    ),
                    if (widget.appUser.mustChangePassword) ...[
                      const SizedBox(height: 12),
                      _TemporaryPasswordBanner(
                        isSending: _isSendingPasswordReset,
                        onSendReset: _sendOwnPasswordReset,
                      ),
                    ],
                    const SizedBox(height: 18),
                    if (snapshot.hasError)
                      _SectionCard(
                        child: _EmptyState(
                          icon: Icons.cloud_off_rounded,
                          message:
                              'Dashboard data could not be loaded. Pull to refresh.',
                        ),
                      )
                    else ...[
                      AnimatedFadeSlide(
                        child: _StatsGrid(
                          appUser: widget.appUser,
                          data: data,
                          isLoading: isLoading,
                        ),
                      ),
                      const SizedBox(height: 18),
                      AnimatedFadeSlide(
                        delay: const Duration(milliseconds: 40),
                        child: _QuickActions(appUser: widget.appUser),
                      ),
                      const SizedBox(height: 18),
                      if (widget.appUser.canViewFees) ...[
                        AnimatedFadeSlide(
                          delay: const Duration(milliseconds: 80),
                          child: _FeeOverviewCard(
                            data: data,
                            isLoading: isLoading,
                            isExpanded: _expandedSections.contains(
                              'feeOverview',
                            ),
                            onToggle: () => _toggleSection('feeOverview'),
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],
                      AnimatedFadeSlide(
                        delay: const Duration(milliseconds: 120),
                        child: _ExpandableDashboardSections(
                          appUser: widget.appUser,
                          data: data,
                          isLoading: isLoading,
                          expandedSections: _expandedSections,
                          onToggle: _toggleSection,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.appUser,
    required this.instituteName,
    required this.isLoading,
    required this.onRefresh,
  });

  final AppUserModel appUser;
  final String instituteName;
  final bool isLoading;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final name = appUser.name.trim().isEmpty ? 'Admin' : appUser.name.trim();
    final initial = name.substring(0, 1).toUpperCase();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Builder(
          builder: (innerContext) => _RoundIconButton(
            tooltip: 'Menu',
            icon: Icons.menu_rounded,
            color: AppTheme.text,
            onPressed: () => Scaffold.of(innerContext).openDrawer(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_greeting()}, \u{1F44B}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.text,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      '$instituteName Dashboard',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.muted,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _RoleBadge(role: appUser.role),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _RoundIconButton(
          tooltip: 'Refresh',
          icon: Icons.refresh_rounded,
          color: isLoading ? AppTheme.mutedLight : AppTheme.primary,
          onPressed: isLoading ? null : onRefresh,
        ),
        const SizedBox(width: 8),
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppTheme.primarySoft,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
          ),
          child: Text(
            initial,
            style: const TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}

class _TemporaryPasswordBanner extends StatelessWidget {
  const _TemporaryPasswordBanner({
    required this.isSending,
    required this.onSendReset,
  });

  final bool isSending;
  final VoidCallback onSendReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.warningSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.warning.withValues(alpha: 0.2)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 520;
          final message = const Row(
            children: [
              Icon(Icons.lock_reset_rounded, color: AppTheme.warning, size: 22),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Please change your temporary password.',
                  style: TextStyle(
                    color: AppTheme.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          );
          final action = OutlinedButton.icon(
            onPressed: isSending ? null : onSendReset,
            icon: isSending
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.mail_outline_rounded, size: 18),
            label: Text(isSending ? 'Sending' : 'Send reset link'),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [message, const SizedBox(height: 10), action],
            );
          }

          return Row(
            children: [
              Expanded(child: message),
              const SizedBox(width: 10),
              action,
            ],
          );
        },
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.appUser,
    required this.data,
    required this.isLoading,
  });

  final AppUserModel appUser;
  final _DashboardData? data;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final cards = <_StatCardData>[
      if (appUser.canViewStudents)
        _StatCardData(
          title: 'Total Students',
          value: isLoading ? '...' : '${data?.totalStudents ?? 0}',
          subtitle: 'Active student records',
          icon: Icons.groups_rounded,
          color: AppTheme.primary,
          trendLabel: '2 this month',
        ),
      if (appUser.canViewAttendance)
        _StatCardData(
          title: 'Present Today',
          value: isLoading ? '...' : '${data?.presentToday ?? 0}',
          subtitle: 'Attendance marked present',
          icon: Icons.how_to_reg_rounded,
          color: AppTheme.success,
          trendLabel: '0% attendance',
        ),
      if (appUser.canViewFees)
        _StatCardData(
          title: 'Pending Fees',
          value: isLoading
              ? '...'
              : _formatCurrency(data?.pendingFeesTotal ?? 0),
          subtitle: 'From pending fee records',
          icon: Icons.pending_actions_rounded,
          color: AppTheme.warning,
          trendLabel: 'Pending',
        ),
      if (appUser.canViewFees)
        _StatCardData(
          title: 'Collected This Month',
          value: isLoading
              ? '...'
              : _formatCurrency(data?.collectedThisMonth ?? 0),
          subtitle: DateFormat('MMMM yyyy').format(DateTime.now()),
          icon: Icons.account_balance_wallet_rounded,
          color: const Color(0xFF8B5CF6),
          trendLabel: 'This Month',
        ),
      if (!appUser.canViewStudents &&
          !appUser.canViewAttendance &&
          !appUser.canViewFees)
        _StatCardData(
          title: 'Access',
          value: 'Limited',
          subtitle: 'No dashboard metrics enabled',
          icon: Icons.verified_user_rounded,
          color: AppTheme.primary,
          trendLabel: 'Role',
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760 ? 4 : 2;
        final gap = constraints.maxWidth < 360 ? 10.0 : 12.0;
        final width = (constraints.maxWidth - (gap * (columns - 1))) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: cards
              .map((card) => SizedBox(width: width, child: _StatCard(card)))
              .toList(),
        );
      },
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.appUser});

  final AppUserModel appUser;

  @override
  Widget build(BuildContext context) {
    final actions = <_ActionData>[
      if (appUser.canCreateStudents)
        _ActionData(
          title: 'Add Student',
          icon: Icons.person_add_alt_1_rounded,
          color: AppTheme.primary,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StudentListScreen()),
          ),
        ),
      if (appUser.canManageBatches)
        _ActionData(
          title: 'Add Batch',
          icon: Icons.add_business_rounded,
          color: AppTheme.primary,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BatchScreen()),
          ),
        ),
      if (appUser.canViewAttendance || appUser.canMarkAttendance)
        _ActionData(
          title: 'Mark Attendance',
          icon: Icons.fact_check_rounded,
          color: AppTheme.success,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AttendanceScreen()),
          ),
        ),
      if (appUser.canCollectFees)
        _ActionData(
          title: 'Collect Fee',
          icon: Icons.currency_rupee_rounded,
          color: AppTheme.warning,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FeesScreen()),
          ),
        ),
      if (appUser.canViewReports)
        _ActionData(
          title: 'Reports',
          icon: Icons.analytics_rounded,
          color: AppTheme.success,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ReportsScreen()),
          ),
        ),
      if (appUser.canViewReminders)
        _ActionData(
          title: 'Reminders',
          icon: Icons.notifications_active_rounded,
          color: AppTheme.primary,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RemindersScreen()),
          ),
        ),
      if (appUser.canManageStaff)
        _ActionData(
          title: 'Staff & Roles',
          icon: Icons.admin_panel_settings_rounded,
          color: AppTheme.primary,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StaffRolesScreen()),
          ),
        ),
    ];

    return _SectionCard(
      title: 'Quick Actions',
      icon: Icons.flash_on_rounded,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 430 ? 4 : 2;
          final gap = constraints.maxWidth >= 430 ? 10.0 : 12.0;
          final width =
              (constraints.maxWidth - (gap * (columns - 1))) / columns;

          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: actions
                .map(
                  (action) => SizedBox(
                    width: width,
                    child: _QuickActionCard(action: action),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}

class _FeeOverviewCard extends StatelessWidget {
  const _FeeOverviewCard({
    required this.data,
    required this.isLoading,
    required this.isExpanded,
    required this.onToggle,
  });

  final _DashboardData? data;
  final bool isLoading;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final collected = data?.collectedThisMonth ?? 0;
    final pending = data?.pendingFeesTotal ?? 0;
    final total = collected + pending;
    final progress = total <= 0 ? 0.0 : (collected / total).clamp(0.0, 1.0);
    final weeklyBars = _buildWeeklyFeeBars(collected, pending);

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onToggle,
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Fee Overview',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.text,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'This Month',
                        style: TextStyle(
                          color: AppTheme.text,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppTheme.muted,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: isLoading
                  ? const _LoadingRows()
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final isTiny = constraints.maxWidth < 340;
                        final summary = Row(
                          children: [
                            Expanded(
                              child: _FeeMetric(
                                label: 'Collected',
                                value: _formatCurrency(collected),
                                color: AppTheme.success,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _FeeMetric(
                                label: 'Pending',
                                value: _formatCurrency(pending),
                                color: AppTheme.danger,
                              ),
                            ),
                          ],
                        );

                        final progressWidget = _FeeCircularProgress(
                          progress: progress,
                          percentLabel: '${(progress * 100).round()}%',
                        );

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isTiny)
                              Column(
                                children: [
                                  summary,
                                  const SizedBox(height: 10),
                                  Center(child: progressWidget),
                                ],
                              )
                            else
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(flex: 2, child: summary),
                                  const SizedBox(width: 12),
                                  progressWidget,
                                ],
                              ),
                            const SizedBox(height: 12),
                            _WeeklyFeeChart(items: weeklyBars),
                            const SizedBox(height: 6),
                            const _FeeLegend(),
                            const SizedBox(height: 12),
                            const _FeeTrendStrip(
                              message: 'Fee overview for this month',
                            ),
                          ],
                        );
                      },
                    ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 190),
            sizeCurve: Curves.easeOutCubic,
          ),
        ],
      ),
    );
  }

  List<_WeeklyFeeBarData> _buildWeeklyFeeBars(
    double collected,
    double pending,
  ) {
    const collectedWeights = [0.16, 0.21, 0.18, 0.25, 0.20];
    const pendingWeights = [0.22, 0.18, 0.24, 0.16, 0.20];

    return List.generate(5, (index) {
      return _WeeklyFeeBarData(
        label: 'Week ${index + 1}',
        collected: collected * collectedWeights[index],
        pending: pending * pendingWeights[index],
      );
    });
  }
}

class _ExpandableDashboardSections extends StatelessWidget {
  const _ExpandableDashboardSections({
    required this.appUser,
    required this.data,
    required this.isLoading,
    required this.expandedSections,
    required this.onToggle,
  });

  final AppUserModel appUser;
  final _DashboardData? data;
  final bool isLoading;
  final Set<String> expandedSections;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final showFees = appUser.canViewFees;
    final cards = <Widget>[
      if (showFees)
        _DashboardExpandableCard(
          id: 'feesDue',
          title: 'Fees Due Today / This Week',
          subtitle:
              '${(data?.dueToday.length ?? 0) + (data?.dueThisWeek.length ?? 0)} upcoming',
          icon: Icons.event_busy_rounded,
          color: AppTheme.warning,
          isExpanded: expandedSections.contains('feesDue'),
          onToggle: onToggle,
          onViewAll: appUser.canViewReminders
              ? () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RemindersScreen(
                      initialTab: ReminderTabFilter.feeDue,
                    ),
                  ),
                )
              : null,
          child: _FeeDueList(
            dueToday: data?.dueToday ?? [],
            dueThisWeek: data?.dueThisWeek ?? [],
            loading: isLoading,
          ),
        ),
      if (showFees)
        _DashboardExpandableCard(
          id: 'installments',
          title: 'Pending Installments',
          subtitle: '${data?.pendingInstallments.length ?? 0} pending',
          icon: Icons.receipt_long_rounded,
          color: AppTheme.primary,
          isExpanded: expandedSections.contains('installments'),
          onToggle: onToggle,
          child: _InstallmentList(
            items: data?.pendingInstallments ?? [],
            loading: isLoading,
          ),
        ),
      _DashboardExpandableCard(
        id: 'birthdays',
        title: 'Upcoming Birthdays',
        subtitle: '${data?.birthdays.length ?? 0} this week',
        icon: Icons.cake_rounded,
        color: AppTheme.danger,
        isExpanded: expandedSections.contains('birthdays'),
        onToggle: onToggle,
        onViewAll: appUser.canViewReminders
            ? () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RemindersScreen(
                    initialTab: ReminderTabFilter.birthday,
                  ),
                ),
              )
            : null,
        child: _BirthdayList(items: data?.birthdays ?? [], loading: isLoading),
      ),
      _DashboardExpandableCard(
        id: 'activity',
        title: 'Recent Activity',
        subtitle: '${data?.recentActivities.length ?? 0} updates',
        icon: Icons.history_rounded,
        color: AppTheme.success,
        isExpanded: expandedSections.contains('activity'),
        onToggle: onToggle,
        child: _RecentActivityList(
          items: data?.recentActivities ?? [],
          loading: isLoading,
        ),
      ),
      _DashboardExpandableCard(
        id: 'batches',
        title: "Today's Classes",
        subtitle: '${data?.batches.length ?? 0} batches',
        icon: Icons.school_rounded,
        color: AppTheme.primary,
        isExpanded: expandedSections.contains('batches'),
        onToggle: onToggle,
        onViewAll: appUser.canViewBatches || appUser.canManageBatches
            ? () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BatchScreen()),
              )
            : null,
        child: _BatchList(items: data?.batches ?? [], loading: isLoading),
      ),
    ];

    return Column(
      children: cards
          .expand((card) => [card, const SizedBox(height: 12)])
          .take(cards.length * 2 - 1)
          .toList(),
    );
  }
}

class _DashboardExpandableCard extends StatelessWidget {
  const _DashboardExpandableCard({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isExpanded,
    required this.onToggle,
    required this.child,
    this.onViewAll,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isExpanded;
  final ValueChanged<String> onToggle;
  final Widget child;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => onToggle(id),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.text,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onViewAll != null && isExpanded) ...[
                    TextButton(
                      onPressed: onViewAll,
                      child: const Text('View all'),
                    ),
                    const SizedBox(width: 2),
                  ],
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppTheme.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: child,
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 190),
            sizeCurve: Curves.easeOutCubic,
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({this.title, this.icon, required this.child});

  final String? title;
  final IconData? icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null && icon != null) ...[
            Row(
              children: [
                Icon(icon, color: AppTheme.primary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title!,
                    style: const TextStyle(
                      color: AppTheme.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
          ],
          child,
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(this.data);

  final _StatCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 128,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border.withValues(alpha: 0.78)),
        boxShadow: [
          BoxShadow(
            color: data.color.withValues(alpha: 0.09),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -4,
            bottom: 4,
            child: SizedBox(
              width: 54,
              height: 28,
              child: CustomPaint(painter: _MiniSparklinePainter(data.color)),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: data.color.withValues(alpha: 0.11),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: data.color.withValues(alpha: 0.18),
                          blurRadius: 18,
                          offset: const Offset(0, 9),
                        ),
                      ],
                    ),
                    child: Icon(data.icon, color: data.color, size: 21),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 24,
                          width: double.infinity,
                          child: FittedBox(
                            alignment: Alignment.centerLeft,
                            fit: BoxFit.scaleDown,
                            child: Text(
                              data.value,
                              maxLines: 1,
                              style: const TextStyle(
                                color: AppTheme.text,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          data.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.muted,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                data.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppTheme.muted, fontSize: 10.5),
              ),
              const Spacer(),
              if (data.trendLabel != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: data.color.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_upward_rounded,
                          color: data.color,
                          size: 10,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          data.trendLabel!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: data.color,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.action});

  final _ActionData action;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: action.color.withValues(alpha: 0.055),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: action.onTap,
        child: Container(
          height: 88,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: action.color.withValues(alpha: 0.18)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: action.color.withValues(alpha: 0.14),
                  ),
                ),
                child: Icon(action.icon, color: action.color, size: 18),
              ),
              const Spacer(),
              Text(
                action.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.text,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BirthdayList extends StatelessWidget {
  const _BirthdayList({required this.items, required this.loading});

  final List<_BirthdayItem> items;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (loading) return const _LoadingRows();
    if (items.isEmpty) {
      return const _EmptyState(
        icon: Icons.cake_outlined,
        message: 'No upcoming birthdays.',
      );
    }

    return Column(
      children: items
          .map(
            (item) => _InfoTile(
              icon: Icons.cake_rounded,
              iconColor: item.daysLeft == 0
                  ? AppTheme.success
                  : AppTheme.warning,
              title: item.name,
              subtitle: item.batch?.isNotEmpty == true
                  ? '${item.batch} • ${DateFormat('dd MMM').format(item.birthday)}'
                  : DateFormat('dd MMM').format(item.birthday),
              trailing: item.daysLeft == 0 ? 'Today' : '${item.daysLeft}d',
            ),
          )
          .toList(),
    );
  }
}

class _FeeDueList extends StatelessWidget {
  const _FeeDueList({
    required this.dueToday,
    required this.dueThisWeek,
    required this.loading,
  });

  final List<_FeeDueItem> dueToday;
  final List<_FeeDueItem> dueThisWeek;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (loading) return const _LoadingRows();
    final items = [...dueToday, ...dueThisWeek].take(5).toList();
    if (items.isEmpty) {
      return const _EmptyState(
        icon: Icons.event_available_rounded,
        message: 'No fees due today or this week.',
      );
    }

    return Column(
      children: items
          .map(
            (item) => _InfoTile(
              icon: Icons.currency_rupee_rounded,
              iconColor: item.isDueToday ? AppTheme.danger : AppTheme.warning,
              title: item.studentName,
              subtitle: item.dueDate == null
                  ? 'Due date not set'
                  : 'Due ${DateFormat('dd MMM').format(item.dueDate!)}',
              trailing: _formatCurrency(item.amount),
            ),
          )
          .toList(),
    );
  }
}

class _InstallmentList extends StatelessWidget {
  const _InstallmentList({required this.items, required this.loading});

  final List<_FeeDueItem> items;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (loading) return const _LoadingRows();
    if (items.isEmpty) {
      return const _EmptyState(
        icon: Icons.receipt_long_outlined,
        message: 'No pending installments.',
      );
    }

    return Column(
      children: items
          .take(5)
          .map(
            (item) => _InfoTile(
              icon: Icons.receipt_rounded,
              iconColor: AppTheme.warning,
              title: item.studentName,
              subtitle: item.monthYear.isEmpty ? 'Installment' : item.monthYear,
              trailing: _formatCurrency(item.amount),
            ),
          )
          .toList(),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppTheme.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            Text(
              trailing!,
              style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RecentActivityList extends StatelessWidget {
  const _RecentActivityList({required this.items, required this.loading});

  final List<_ActivityItem> items;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (loading) return const _LoadingRows();
    if (items.isEmpty) {
      return const _EmptyState(
        icon: Icons.timeline_rounded,
        message: 'Recent activity will appear here.',
      );
    }

    return Column(
      children: items
          .map(
            (activity) => _InfoTile(
              icon: activity.icon,
              iconColor: activity.color,
              title: activity.title,
              subtitle: activity.subtitle,
            ),
          )
          .toList(),
    );
  }
}

class _BatchList extends StatelessWidget {
  const _BatchList({required this.items, required this.loading});

  final List<_BatchItem> items;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (loading) return const _LoadingRows();
    if (items.isEmpty) {
      return const _EmptyState(
        icon: Icons.event_available_rounded,
        message: 'No classes scheduled yet.',
      );
    }

    return Column(
      children: items
          .map(
            (batch) => _InfoTile(
              icon: Icons.layers_rounded,
              iconColor: AppTheme.primary,
              title: batch.name,
              subtitle: batch.timeText,
              trailing: batch.daysText,
            ),
          )
          .toList(),
    );
  }
}

class _FeeCircularProgress extends StatelessWidget {
  const _FeeCircularProgress({
    required this.progress,
    required this.percentLabel,
  });

  final double progress;
  final String percentLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      height: 88,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 82,
            height: 82,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 7.5,
              strokeCap: StrokeCap.round,
              color: AppTheme.success,
              backgroundColor: const Color(0xFFE5EAF2),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                percentLabel,
                style: const TextStyle(
                  color: AppTheme.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 1),
              const Text(
                'Collected',
                style: TextStyle(
                  color: AppTheme.muted,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeeklyFeeChart extends StatelessWidget {
  const _WeeklyFeeChart({required this.items});

  final List<_WeeklyFeeBarData> items;

  @override
  Widget build(BuildContext context) {
    var maxAmount = 150000.0;
    for (final item in items) {
      if (item.collected > maxAmount) maxAmount = item.collected;
      if (item.pending > maxAmount) maxAmount = item.pending;
    }

    return SizedBox(
      height: 148,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(
            width: 34,
            height: 118,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ChartScaleLabel('Rs 1.5L'),
                _ChartScaleLabel('Rs 1L'),
                _ChartScaleLabel('Rs 50K'),
                _ChartScaleLabel('Rs 0'),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(top: 2),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppTheme.border),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: items
                          .map(
                            (item) => Expanded(
                              child: _WeeklyBarGroup(
                                item: item,
                                maxAmount: maxAmount,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: items
                      .map(
                        (item) => Expanded(
                          child: Text(
                            item.label,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.muted,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyBarGroup extends StatelessWidget {
  const _WeeklyBarGroup({required this.item, required this.maxAmount});

  final _WeeklyFeeBarData item;
  final double maxAmount;

  @override
  Widget build(BuildContext context) {
    final collectedHeight = _barHeight(item.collected);
    final pendingHeight = _barHeight(item.pending);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _FeeBar(height: collectedHeight, color: AppTheme.success),
          const SizedBox(width: 4),
          _FeeBar(height: pendingHeight, color: const Color(0xFFDDE3EC)),
        ],
      ),
    );
  }

  double _barHeight(double amount) {
    if (maxAmount <= 0) return 8;
    return 8 + ((amount / maxAmount).clamp(0.0, 1.0) * 88);
  }
}

class _FeeBar extends StatelessWidget {
  const _FeeBar({required this.height, required this.color});

  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: 8,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _FeeLegend extends StatelessWidget {
  const _FeeLegend();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _LegendItem(label: 'Collected', color: AppTheme.success),
        SizedBox(width: 18),
        _LegendItem(label: 'Pending', color: Color(0xFFDDE3EC)),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.muted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _FeeTrendStrip extends StatelessWidget {
  const _FeeTrendStrip({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.successSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.success.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.trending_up_rounded,
              color: AppTheme.success,
              size: 17,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.text,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppTheme.success,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _ChartScaleLabel extends StatelessWidget {
  const _ChartScaleLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: AppTheme.muted,
        fontSize: 9,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _FeeMetric extends StatelessWidget {
  const _FeeMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 66),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.muted,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onPressed,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppTheme.border),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
        ),
      ),
    );
  }
}

class _MiniSparklinePainter extends CustomPainter {
  const _MiniSparklinePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, size.height * 0.78)
      ..cubicTo(
        size.width * 0.12,
        size.height * 0.82,
        size.width * 0.16,
        size.height * 0.52,
        size.width * 0.26,
        size.height * 0.56,
      )
      ..cubicTo(
        size.width * 0.38,
        size.height * 0.62,
        size.width * 0.38,
        size.height * 0.22,
        size.width * 0.52,
        size.height * 0.28,
      )
      ..cubicTo(
        size.width * 0.66,
        size.height * 0.34,
        size.width * 0.62,
        size.height * 0.86,
        size.width * 0.78,
        size.height * 0.72,
      )
      ..cubicTo(
        size.width * 0.9,
        size.height * 0.62,
        size.width * 0.84,
        size.height * 0.18,
        size.width,
        size.height * 0.42,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MiniSparklinePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primarySoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.25)),
      ),
      child: Text(
        _roleLabel(role),
        style: const TextStyle(
          color: AppTheme.primary,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.muted, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: AppTheme.muted, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingRows extends StatelessWidget {
  const _LoadingRows();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 14),
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            color: AppTheme.primary,
            strokeWidth: 2.2,
          ),
        ),
      ),
    );
  }
}

class _DashboardData {
  const _DashboardData({
    required this.instituteName,
    required this.totalStudents,
    required this.presentToday,
    required this.pendingFeesTotal,
    required this.collectedThisMonth,
    required this.birthdays,
    required this.dueToday,
    required this.dueThisWeek,
    required this.pendingInstallments,
    required this.batches,
    required this.recentActivities,
  });

  final String instituteName;
  final int totalStudents;
  final int presentToday;
  final double pendingFeesTotal;
  final double collectedThisMonth;
  final List<_BirthdayItem> birthdays;
  final List<_FeeDueItem> dueToday;
  final List<_FeeDueItem> dueThisWeek;
  final List<_FeeDueItem> pendingInstallments;
  final List<_BatchItem> batches;
  final List<_ActivityItem> recentActivities;
}

class _StatCardData {
  const _StatCardData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.trendLabel,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String? trendLabel;
}

class _ActionData {
  const _ActionData({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}

class _WeeklyFeeBarData {
  const _WeeklyFeeBarData({
    required this.label,
    required this.collected,
    required this.pending,
  });

  final String label;
  final double collected;
  final double pending;
}

class _BirthdayItem {
  const _BirthdayItem({
    required this.name,
    required this.batch,
    required this.birthday,
    required this.daysLeft,
  });

  final String name;
  final String? batch;
  final DateTime birthday;
  final int daysLeft;
}

class _FeeDueItem {
  const _FeeDueItem({
    required this.studentName,
    required this.amount,
    required this.dueDate,
    required this.monthYear,
    required this.isDueToday,
    required this.isDueThisWeek,
  });

  final String studentName;
  final double amount;
  final DateTime? dueDate;
  final String monthYear;
  final bool isDueToday;
  final bool isDueThisWeek;
}

class _BatchItem {
  const _BatchItem({
    required this.name,
    required this.timeText,
    required this.daysText,
  });

  factory _BatchItem.fromMap(Map<String, dynamic> data) {
    final days = data['days'];
    return _BatchItem(
      name: data['name']?.toString() ?? 'Unnamed Batch',
      timeText:
          '${data['start_time']?.toString() ?? '--'} - ${data['end_time']?.toString() ?? '--'}',
      daysText: days is List ? days.join(', ') : 'Schedule',
    );
  }

  final String name;
  final String timeText;
  final String daysText;
}

class _ActivityItem {
  const _ActivityItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}

String _greeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good Morning';
  if (hour < 17) return 'Good Afternoon';
  return 'Good Evening';
}

String _dateKey(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

bool _isSameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

double _parseAmount(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}

String _formatCurrency(double value) {
  if (value >= 100000) {
    return 'Rs ${(value / 100000).toStringAsFixed(1)}L';
  }
  return 'Rs ${value.toStringAsFixed(0)}';
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
      return role;
  }
}
