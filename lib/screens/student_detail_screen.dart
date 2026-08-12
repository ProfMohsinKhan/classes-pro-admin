import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/database/database_provider.dart';
import '../data/repositories/offline_repositories.dart';
import '../models/app_user_model.dart';
import '../models/attendance_model.dart';
import '../models/receipt_model.dart';
import '../models/student_model.dart';
import '../services/institute_settings_service.dart';
import '../services/receipt_pdf_service.dart';
import '../services/student_pdf_service.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';
import 'access_denied_screen.dart';
import 'edit_student_screen.dart';
import 'receipt_screen.dart';

class StudentDetailScreen extends StatelessWidget {
  const StudentDetailScreen({super.key, required this.student});

  final StudentModel student;

  @override
  Widget build(BuildContext context) {
    final studentsRepository = OfflineStudentsRepository(
      OfflineDatabaseProvider.instance,
    );
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Student Profile',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          StreamBuilder<AppUserModel?>(
            stream: UserService.instance.streamCurrentUserProfile(),
            builder: (context, snapshot) {
              final appUser = snapshot.data;
              if (appUser == null ||
                  (!appUser.canGenerateStudentPdf &&
                      !appUser.canGenerateFeeStatementPdf &&
                      !appUser.canGenerateAttendancePdf)) {
                return const SizedBox.shrink();
              }
              return IconButton(
                tooltip: 'Student Documents',
                icon: const Icon(Icons.picture_as_pdf_rounded),
                onPressed: () async {
                  final latestStudent =
                      await studentsRepository.getStudentById(student.id) ??
                      student;
                  if (!context.mounted) return;
                  _showStudentDocumentsSheet(context, latestStudent, appUser);
                },
              );
            },
          ),
          StreamBuilder<AppUserModel?>(
            stream: UserService.instance.streamCurrentUserProfile(),
            builder: (context, snapshot) {
              final appUser = snapshot.data;
              if (appUser == null || !appUser.canCreateStudents) {
                return const SizedBox.shrink();
              }
              return IconButton(
                tooltip: 'Create student portal login',
                icon: const Icon(Icons.person_add_alt_1_rounded),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Create student login?'),
                      content: const Text(
                        'The student contact number will be used as both the login ID and temporary password.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(dialogContext, true),
                          child: const Text('Create login'),
                        ),
                      ],
                    ),
                  );
                  if (confirm != true) return;

                  try {
                    final latestStudent =
                        await studentsRepository.getStudentById(student.id) ??
                        student;
                    final credentials = await UserService.instance
                        .createStudentLogin(
                          CreateStudentLoginInput(
                            student: latestStudent,
                            createdBy: appUser,
                          ),
                        );
                    if (!context.mounted) return;
                    await showDialog<void>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Student portal login created'),
                        content: Text(
                          'Login ID: ${credentials.loginId}\n'
                          'Temporary password: ${credentials.initialPassword}\n\n'
                          'The student will be asked to change this password after the first login.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text('Done'),
                          ),
                        ],
                      ),
                    );
                  } catch (error) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Student login could not be created: $error',
                        ),
                        backgroundColor: AppTheme.danger,
                      ),
                    );
                  }
                },
              );
            },
          ),
          StreamBuilder<AppUserModel?>(
            stream: UserService.instance.streamCurrentUserProfile(),
            builder: (context, snapshot) {
              final appUser = snapshot.data;
              if (appUser == null || !appUser.canEditStudents) {
                return const SizedBox.shrink();
              }
              return IconButton(
                tooltip: 'Edit',
                icon: const Icon(Icons.edit_note_rounded),
                onPressed: () async {
                  final latestStudent =
                      await studentsRepository.getStudentById(student.id) ??
                      student;
                  if (!context.mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) =>
                          EditStudentScreen(student: latestStudent),
                    ),
                  );
                },
              );
            },
          ),
          StreamBuilder<AppUserModel?>(
            stream: UserService.instance.streamCurrentUserProfile(),
            builder: (context, snapshot) {
              final appUser = snapshot.data;
              if (appUser == null || !appUser.canDeleteStudents) {
                return const SizedBox.shrink();
              }
              return IconButton(
                tooltip: 'Archive',
                icon: const Icon(Icons.archive_outlined),
                onPressed: () async {
                  final confirm =
                      await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Archive Student?'),
                          content: const Text(
                            'This will hide the student from active lists.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Archive'),
                            ),
                          ],
                        ),
                      ) ??
                      false;
                  if (!confirm) return;
                  await studentsRepository.archiveStudent(student.id);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                },
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<AppUserModel?>(
        stream: UserService.instance.streamCurrentUserProfile(),
        builder: (context, profileSnapshot) {
          if (profileSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final appUser = profileSnapshot.data;
          if (appUser == null || !appUser.canViewStudents) {
            return const AccessDeniedScreen();
          }

          return StreamBuilder<StudentModel?>(
            stream: studentsRepository.watchStudentById(student.id),
            initialData: student,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data == null) {
                return const _EmptyProfile(message: 'Student not found');
              }

              final liveStudent = snapshot.data!;
              return DefaultTabController(
                length: _ProfileTabs.tabCount(appUser),
                child: SafeArea(
                  top: false,
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ProfileHeader(student: liveStudent),
                        const SizedBox(height: 14),
                        _QuickContactRow(student: liveStudent),
                        const SizedBox(height: 14),
                        Expanded(
                          child: _ProfileTabs(
                            student: liveStudent,
                            appUser: appUser,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.student});

  final StudentModel student;

  @override
  Widget build(BuildContext context) {
    final initial = student.displayName.characters.first.toUpperCase();
    final dob = student.dob == null
        ? 'DOB not set'
        : DateFormat('dd MMM yyyy').format(student.dob!);

    return _Card(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          CircleAvatar(
            radius: 38,
            backgroundColor: AppTheme.primarySoft,
            backgroundImage: student.profilePhoto == null
                ? null
                : NetworkImage(student.profilePhoto!),
            child: student.profilePhoto == null
                ? Text(
                    initial,
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.displayName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.text,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  student.displayClassBatch,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppTheme.muted),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Pill(
                      label: student.isActive ? 'Active' : 'Inactive',
                      color: student.isActive
                          ? AppTheme.success
                          : AppTheme.danger,
                    ),
                    _Pill(label: dob, color: AppTheme.warning),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _StudentDocumentAction {
  profile,
  enrollment,
  fees,
  attendance,
  fullReport,
}

Future<void> _showStudentDocumentsSheet(
  BuildContext context,
  StudentModel student,
  AppUserModel appUser,
) async {
  _StudentDocumentAction? loadingAction;
  final messenger = ScaffoldMessenger.of(context);

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          final bottomSafe = MediaQuery.of(context).viewPadding.bottom;

          Future<void> runAction(_StudentDocumentAction action) async {
            setModalState(() => loadingAction = action);
            try {
              final shared = await _shareStudentDocument(action, student);
              if (!context.mounted) return;
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    shared
                        ? 'PDF ready.'
                        : 'PDF generated, but sharing is not supported on this platform.',
                  ),
                  backgroundColor: shared ? AppTheme.success : AppTheme.warning,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } catch (e) {
              if (!context.mounted) return;
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Could not generate PDF. Please try again.'),
                  backgroundColor: AppTheme.danger,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } finally {
              if (context.mounted) {
                setModalState(() => loadingAction = null);
              }
            }
          }

          final options = [
            if (appUser.canGenerateStudentPdf)
              _StudentDocumentOption(
                action: _StudentDocumentAction.profile,
                icon: Icons.account_circle_rounded,
                title: 'Share Student Profile PDF',
                subtitle: 'Basic profile, contact, course and batch details',
              ),
            if (appUser.canGenerateStudentPdf)
              _StudentDocumentOption(
                action: _StudentDocumentAction.enrollment,
                icon: Icons.assignment_rounded,
                title: 'Share Enrollment PDF',
                subtitle: 'Enrollment, fee plan and installment preview',
              ),
            if (appUser.canGenerateFeeStatementPdf)
              _StudentDocumentOption(
                action: _StudentDocumentAction.fees,
                icon: Icons.receipt_long_rounded,
                title: 'Share Fee Statement PDF',
                subtitle: 'Fee summary and payment history',
              ),
            if (appUser.canGenerateAttendancePdf)
              _StudentDocumentOption(
                action: _StudentDocumentAction.attendance,
                icon: Icons.calendar_month_rounded,
                title: 'Share Attendance Summary PDF',
                subtitle: 'Attendance counts, percentage and recent records',
              ),
            if (appUser.canGenerateStudentPdf &&
                appUser.canGenerateFeeStatementPdf &&
                appUser.canGenerateAttendancePdf)
              _StudentDocumentOption(
                action: _StudentDocumentAction.fullReport,
                icon: Icons.library_books_rounded,
                title: 'Share Full Student Report PDF',
                subtitle: 'Combined profile, enrollment, fees and attendance',
              ),
          ];

          return SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(18, 16, 18, bottomSafe + 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Student Documents',
                          style: TextStyle(
                            color: AppTheme.text,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: loadingAction == null
                            ? () => Navigator.pop(sheetContext)
                            : null,
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          for (final option in options)
                            _StudentDocumentTile(
                              option: option,
                              isLoading: loadingAction == option.action,
                              isDisabled:
                                  loadingAction != null &&
                                  loadingAction != option.action,
                              onTap: () => runAction(option.action),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Future<bool> _shareStudentDocument(
  _StudentDocumentAction action,
  StudentModel student,
) {
  return switch (action) {
    _StudentDocumentAction.profile => StudentPdfService.shareStudentProfile(
      student,
    ),
    _StudentDocumentAction.enrollment => StudentPdfService.shareEnrollment(
      student,
    ),
    _StudentDocumentAction.fees => StudentPdfService.shareFeeStatement(student),
    _StudentDocumentAction.attendance =>
      StudentPdfService.shareAttendanceSummary(student),
    _StudentDocumentAction.fullReport => StudentPdfService.shareFullReport(
      student,
    ),
  };
}

class _StudentDocumentOption {
  const _StudentDocumentOption({
    required this.action,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final _StudentDocumentAction action;
  final IconData icon;
  final String title;
  final String subtitle;
}

class _StudentDocumentTile extends StatelessWidget {
  const _StudentDocumentTile({
    required this.option,
    required this.isLoading,
    required this.isDisabled,
    required this.onTap,
  });

  final _StudentDocumentOption option;
  final bool isLoading;
  final bool isDisabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: isDisabled || isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.border),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                  child: Icon(option.icon, color: AppTheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.title,
                        style: const TextStyle(
                          color: AppTheme.text,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        option.subtitle,
                        style: const TextStyle(
                          color: AppTheme.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                if (isLoading)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  const Icon(Icons.ios_share_rounded, color: AppTheme.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickContactRow extends StatelessWidget {
  const _QuickContactRow({required this.student});

  final StudentModel student;

  @override
  Widget build(BuildContext context) {
    final phone = student.primaryPhone;
    return Row(
      children: [
        Expanded(
          child: _ContactButton(
            label: 'Call',
            icon: Icons.call_rounded,
            color: AppTheme.primary,
            onTap: phone.isEmpty ? null : () => _launchPhone(phone),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ContactButton(
            label: 'WhatsApp',
            icon: Icons.chat_rounded,
            color: AppTheme.success,
            onTap: phone.isEmpty ? null : () => _launchWhatsApp(phone),
          ),
        ),
      ],
    );
  }
}

class _ProfileTabs extends StatelessWidget {
  const _ProfileTabs({required this.student, required this.appUser});

  final StudentModel student;
  final AppUserModel appUser;

  static int tabCount(AppUserModel appUser) {
    return 2 +
        (appUser.canViewFees ? 1 : 0) +
        (appUser.canViewAttendance ? 1 : 0);
  }

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppTheme.primary,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.muted,
            labelStyle: TextStyle(fontWeight: FontWeight.w900),
            labelPadding: EdgeInsets.symmetric(horizontal: 18),
            dividerColor: AppTheme.border,
            tabs: [
              const Tab(text: 'Overview'),
              if (appUser.canViewFees) const Tab(text: 'Fees'),
              if (appUser.canViewAttendance) const Tab(text: 'Attendance'),
              const Tab(text: 'Notes'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _OverviewTab(student: student),
                if (appUser.canViewFees) _FeesTab(student: student),
                if (appUser.canViewAttendance) _AttendanceTab(student: student),
                _NotesTab(student: student),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.student});

  final StudentModel student;

  @override
  Widget build(BuildContext context) {
    final guardian = student.parentName ?? student.guardianName ?? 'Not set';
    final guardianPhone =
        student.parentPhone ?? student.guardianPhone ?? 'Not set';
    final address = [
      student.address,
      student.city,
      student.state,
      student.pincode,
    ].where((item) => (item ?? '').trim().isNotEmpty).join(', ');

    return ListView(
      padding: _tabPadding(context),
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _OverviewMetric(
              icon: Icons.school_rounded,
              label: 'Course',
              value: student.courseName ?? student.className ?? 'Not set',
            ),
            _OverviewMetric(
              icon: Icons.groups_rounded,
              label: 'Batch',
              value: student.batchName ?? 'Not set',
            ),
            _OverviewMetric(
              icon: Icons.cake_rounded,
              label: 'Age',
              value: student.age == null ? 'Not set' : '${student.age} years',
            ),
            _OverviewMetric(
              icon: Icons.event_available_rounded,
              label: 'Admission',
              value: student.admissionDate == null
                  ? 'Not set'
                  : DateFormat('dd MMM yyyy').format(student.admissionDate!),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SectionTitle('Contact Details'),
        const SizedBox(height: 10),
        _InfoRow('Student Phone', student.phone ?? 'Not set', Icons.phone),
        _InfoRow('Parent', guardian, Icons.family_restroom_rounded),
        _InfoRow('Parent Phone', guardianPhone, Icons.phone_in_talk_rounded),
        _InfoRow(
          'Email',
          student.email ?? student.guardianEmail ?? 'Not set',
          Icons.alternate_email_rounded,
        ),
        const SizedBox(height: 8),
        _SectionTitle('Student Address'),
        const SizedBox(height: 10),
        _InfoBlock(
          icon: Icons.location_on_rounded,
          title: 'Address',
          value: address.isEmpty ? 'Not set' : address,
        ),
        const SizedBox(height: 8),
        _SectionTitle('Academic Snapshot'),
        const SizedBox(height: 10),
        _InfoRow(
          'Previous School',
          student.previousSchool ?? 'Not set',
          Icons.apartment_rounded,
        ),
        _InfoRow(
          'Previous Class',
          student.previousClass ?? 'Not set',
          Icons.menu_book_rounded,
        ),
        _InfoRow(
          'Reference',
          student.referenceSource ?? 'Not set',
          Icons.campaign_rounded,
        ),
      ],
    );
  }
}

class _FeesTab extends StatelessWidget {
  const _FeesTab({required this.student});

  final StudentModel student;

  @override
  Widget build(BuildContext context) {
    if (student.numericId == null) {
      return const _TabPlaceholder(message: 'Fee summary will appear here.');
    }

    return FutureBuilder<_FeeProfileData>(
      future: _loadFeeProfile(student),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const _TabPlaceholder(
            message: 'Fee summary will appear here.',
          );
        }

        final data = snapshot.data!;
        if (data.records.isEmpty && data.totalFee <= 0) {
          return const _TabPlaceholder(
            message: 'Fee summary will appear here.',
          );
        }

        return ListView(
          padding: _tabPadding(context, extraBottom: 72),
          children: [
            _FeeHero(data: data),
            const SizedBox(height: 14),
            _SectionTitle('Installment Details'),
            const SizedBox(height: 10),
            if (data.installments.isEmpty)
              const _EmptyStateTile(
                icon: Icons.event_note_rounded,
                title: 'No installment plan',
                subtitle: 'Installment rows will appear after fee plan setup.',
              )
            else
              ...data.installments.map((row) => _InstallmentTile(row: row)),
            const SizedBox(height: 14),
            _SectionTitle('Past Paid Installments'),
            const SizedBox(height: 10),
            if (data.history.isEmpty)
              const _EmptyStateTile(
                icon: Icons.receipt_long_rounded,
                title: 'No receipt generated yet',
                subtitle: 'Paid installments and receipts will appear here.',
              )
            else
              ...data.history.map(
                (item) => _PaidHistoryTile(
                  item: item,
                  onOpen: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) =>
                          ReceiptScreen(receipt: item.receipt),
                    ),
                  ),
                  onShare: () => _shareReceipt(context, item.receipt),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _AttendanceTab extends StatefulWidget {
  const _AttendanceTab({required this.student});

  final StudentModel student;

  @override
  State<_AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends State<_AttendanceTab> {
  final GlobalKey _shareKey = GlobalKey();
  late DateTime _visibleMonth;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.student.numericId == null) {
      return const _TabPlaceholder(
        message: 'Attendance summary will appear here.',
      );
    }

    return FutureBuilder<List<_AttendanceEntry>>(
      future: _loadAttendance(widget.student.numericId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const _TabPlaceholder(
            message: 'Attendance summary will appear here.',
          );
        }

        final records = snapshot.data!;
        final byDay = {
          for (final record in records) _dateKey(record.date): record.status,
        };
        final monthRecords = records
            .where(
              (record) =>
                  record.date.year == _visibleMonth.year &&
                  record.date.month == _visibleMonth.month,
            )
            .toList();
        final summary = _AttendanceSummary.from(monthRecords);

        return ListView(
          padding: _tabPadding(context, extraBottom: 128),
          children: [
            RepaintBoundary(
              key: _shareKey,
              child: ColoredBox(
                color: AppTheme.surface,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _AttendanceMonthHeader(
                        month: _visibleMonth,
                        onPrevious: () => setState(
                          () => _visibleMonth = DateTime(
                            _visibleMonth.year,
                            _visibleMonth.month - 1,
                          ),
                        ),
                        onNext: () => setState(
                          () => _visibleMonth = DateTime(
                            _visibleMonth.year,
                            _visibleMonth.month + 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _AttendanceCalendar(
                        month: _visibleMonth,
                        statusesByDay: byDay,
                      ),
                      const SizedBox(height: 14),
                      _AttendanceSummaryPanel(summary: summary),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _isSharing ? null : _shareAttendanceImage,
              icon: _isSharing
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.ios_share_rounded),
              label: const Text('Share Summary'),
            ),
            SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 32),
          ],
        );
      },
    );
  }

  Future<void> _shareAttendanceImage() async {
    setState(() => _isSharing = true);
    try {
      final boundary =
          _shareKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData?.buffer.asUint8List();
      if (bytes == null) return;
      final safeName = widget.student.displayName.replaceAll(
        RegExp(r'[^A-Za-z0-9_-]+'),
        '_',
      );
      final file = XFile.fromData(
        bytes,
        name:
            'attendance_${safeName}_${DateFormat('yyyy_MM').format(_visibleMonth)}.png',
        mimeType: 'image/png',
      );
      await Share.shareXFiles(
        [file],
        text:
            '${widget.student.displayName} attendance ${DateFormat('MMM yyyy').format(_visibleMonth)}',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Attendance summary could not be shared: $e'),
          backgroundColor: AppTheme.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }
}

class _NotesTab extends StatelessWidget {
  const _NotesTab({required this.student});

  final StudentModel student;

  @override
  Widget build(BuildContext context) {
    final notes = student.notes?.trim();
    return ListView(
      padding: _tabPadding(context),
      children: [
        _InfoBlock(
          icon: Icons.sticky_note_2_rounded,
          title: 'Notes',
          value: notes?.isNotEmpty == true ? notes! : 'Notes will appear here.',
        ),
      ],
    );
  }
}

class _FeeHero extends StatelessWidget {
  const _FeeHero({required this.data});

  final _FeeProfileData data;

  @override
  Widget build(BuildContext context) {
    final progress = data.totalFee <= 0
        ? 0.0
        : (data.paid / data.totalFee).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Fee Summary',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _LightBadge(data.statusLabel),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.22),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _FeeHeroMetric(
                  label: 'Total Paid',
                  value: _money(data.paid),
                  icon: Icons.check_circle_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _FeeHeroMetric(
                  label: 'Total Balance',
                  value: _money(data.pending),
                  icon: Icons.account_balance_wallet_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Total fee ${_money(data.totalFee)}'
            '${data.nextDueDate == null ? '' : ' / Next due ${DateFormat('dd MMM yyyy').format(data.nextDueDate!)}'}',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.82)),
          ),
        ],
      ),
    );
  }
}

class _FeeHeroMetric extends StatelessWidget {
  const _FeeHeroMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
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

class _InstallmentTile extends StatelessWidget {
  const _InstallmentTile({required this.row});

  final _InstallmentRow row;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(row.status);
    return _InlineCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Text(
              row.number.toString(),
              style: TextStyle(color: color, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Due ${row.dueDate == null ? '--' : DateFormat('dd MMM yyyy').format(row.dueDate!)} / Paid ${_money(row.paidAmount)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppTheme.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _money(row.amount),
                style: const TextStyle(
                  color: AppTheme.text,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              _Pill(label: row.status, color: color),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaidHistoryTile extends StatelessWidget {
  const _PaidHistoryTile({
    required this.item,
    required this.onOpen,
    required this.onShare,
  });

  final _FeeHistoryItem item;
  final VoidCallback onOpen;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return _InlineCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: AppTheme.successSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: AppTheme.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.receiptNo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.text,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${item.mode} / ${item.date == null ? '--' : DateFormat('dd MMM yyyy').format(item.date!)}',
                      style: const TextStyle(
                        color: AppTheme.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _money(item.amount),
                style: const TextStyle(
                  color: AppTheme.success,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onOpen,
                  icon: const Icon(Icons.visibility_rounded, size: 18),
                  label: const Text('Receipt'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.outlined(
                tooltip: 'Share receipt',
                onPressed: onShare,
                icon: const Icon(Icons.ios_share_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttendanceMonthHeader extends StatelessWidget {
  const _AttendanceMonthHeader({
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton.outlined(
          tooltip: 'Previous month',
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Expanded(
          child: Text(
            DateFormat('MMMM yyyy').format(month),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.text,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        IconButton.outlined(
          tooltip: 'Next month',
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}

class _AttendanceCalendar extends StatelessWidget {
  const _AttendanceCalendar({required this.month, required this.statusesByDay});

  final DateTime month;
  final Map<String, AttendanceStatus> statusesByDay;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leading = first.weekday % 7;
    final cells = leading + daysInMonth;
    final rows = (cells / 7).ceil();

    return _InlineCard(
      child: Column(
        children: [
          Row(
            children: const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          color: AppTheme.muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          ...List.generate(rows, (row) {
            return Padding(
              padding: EdgeInsets.only(bottom: row == rows - 1 ? 0 : 8),
              child: Row(
                children: List.generate(7, (column) {
                  final index = row * 7 + column;
                  final dayNumber = index - leading + 1;
                  if (dayNumber < 1 || dayNumber > daysInMonth) {
                    return const Expanded(child: SizedBox(height: 42));
                  }
                  final date = DateTime(month.year, month.month, dayNumber);
                  final status = statusesByDay[_dateKey(date)];
                  return Expanded(
                    child: _CalendarDay(number: dayNumber, status: status),
                  );
                }),
              ),
            );
          }),
          const SizedBox(height: 14),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _LegendDot(label: 'Present', color: AppTheme.success),
              _LegendDot(label: 'Absent', color: AppTheme.danger),
              _LegendDot(label: 'Late', color: AppTheme.warning),
              _LegendDot(label: 'Leave', color: Color(0xFFFDE68A)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CalendarDay extends StatelessWidget {
  const _CalendarDay({required this.number, required this.status});

  final int number;
  final AttendanceStatus? status;

  @override
  Widget build(BuildContext context) {
    final color = _attendanceColor(status);
    final isMarked = status != null;
    return Container(
      height: 42,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: isMarked ? color.withValues(alpha: 0.16) : AppTheme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMarked ? color.withValues(alpha: 0.55) : AppTheme.border,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            number.toString(),
            style: TextStyle(
              color: isMarked ? AppTheme.text : AppTheme.muted,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (isMarked)
            Positioned(
              bottom: 5,
              child: Container(
                height: 5,
                width: 18,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AttendanceSummaryPanel extends StatelessWidget {
  const _AttendanceSummaryPanel({required this.summary});

  final _AttendanceSummary summary;

  @override
  Widget build(BuildContext context) {
    return _InlineCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Attendance Summary',
            style: TextStyle(
              color: AppTheme.text,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusCount('Records', summary.total, AppTheme.primary),
              _StatusCount('Present', summary.present, AppTheme.success),
              _StatusCount('Absent', summary.absent, AppTheme.danger),
              _StatusCount('Late', summary.late, AppTheme.warning),
              _StatusCount('Leave', summary.leave, const Color(0xFFEAB308)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            summary.absentDates.isEmpty
                ? 'No absent records in this month.'
                : 'Absent dates: ${summary.absentDates.map((date) => DateFormat('dd MMM').format(date)).join(', ')}',
            style: const TextStyle(color: AppTheme.muted, height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _StatusCount extends StatelessWidget {
  const _StatusCount(this.label, this.value, this.color);

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value.toString(),
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewMetric extends StatelessWidget {
  const _OverviewMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 142,
      child: _InlineCard(
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppTheme.primary, size: 20),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: AppTheme.muted)),
            const SizedBox(height: 3),
            Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.text,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value, this.icon);

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return _InlineCard(
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: const TextStyle(color: AppTheme.muted)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppTheme.text,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return _InlineCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppTheme.muted)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppTheme.text,
                    fontWeight: FontWeight.w800,
                    height: 1.35,
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppTheme.text,
        fontSize: 16,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.padding = const EdgeInsets.all(16)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: AppTheme.text.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _InlineCard extends StatelessWidget {
  const _InlineCard({
    required this.child,
    this.margin = const EdgeInsets.only(bottom: 10),
  });

  final Widget child;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: child,
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _LightBadge extends StatelessWidget {
  const _LightBadge(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 9,
          width: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(color: AppTheme.muted)),
      ],
    );
  }
}

class _EmptyStateTile extends StatelessWidget {
  const _EmptyStateTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return _InlineCard(
      child: Row(
        children: [
          Icon(icon, color: AppTheme.muted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppTheme.muted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  const _ContactButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        backgroundColor: AppTheme.surface,
        side: BorderSide(
          color: color.withValues(alpha: onTap == null ? 0.18 : 0.42),
        ),
        padding: const EdgeInsets.symmetric(vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}

class _TabPlaceholder extends StatelessWidget {
  const _TabPlaceholder({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppTheme.muted),
        ),
      ),
    );
  }
}

class _EmptyProfile extends StatelessWidget {
  const _EmptyProfile({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(message, style: const TextStyle(color: AppTheme.muted)),
    );
  }
}

class _FeeProfileData {
  const _FeeProfileData({
    required this.records,
    required this.totalFee,
    required this.paid,
    required this.pending,
    required this.nextDueDate,
    required this.installments,
    required this.history,
  });

  final List<_FeeRecord> records;
  final double totalFee;
  final double paid;
  final double pending;
  final DateTime? nextDueDate;
  final List<_InstallmentRow> installments;
  final List<_FeeHistoryItem> history;

  String get statusLabel {
    if (pending <= 0 && totalFee > 0) return 'Paid';
    if (paid > 0 && pending > 0) return 'Partial';
    return 'Pending';
  }
}

class _FeeRecord {
  const _FeeRecord({required this.docId, required this.data});

  final String docId;
  final Map<String, dynamic> data;

  int? get installmentNo =>
      _int(data['installmentNo'] ?? data['installment_no']);
  double get totalAmount =>
      _amount(data['total_amount'] ?? data['totalFee'] ?? data['finalFee']);
  double get paidAmount => _amount(
    data['amount_paid'] ??
        data['amount'] ??
        data['amountPaid'] ??
        data['paid_amount'] ??
        data['totalPaid'],
  );
  double get pendingAmount {
    if (!isPending) return 0;
    return _amount(
      data['dueAmount'] ??
          data['pendingAmount'] ??
          data['balance'] ??
          data['remaining'] ??
          data['total_amount'],
    );
  }

  String get status => data['status']?.toString().toLowerCase() ?? 'pending';
  bool get isPending => status == 'pending';
  bool get isPaid => status == 'paid' || status == 'partially_paid';
  bool get isReceipt =>
      data['recordType']?.toString() == 'receipt' ||
      data['feeType']?.toString() == 'receipt';
  bool get hasPayment => paidAmount > 0 && (isPaid || receiptNo != 'Receipt');
  String get monthYear => data['month_year']?.toString() ?? 'Fee';
  DateTime? get dueDate => _date(
    data['dueDate'] ??
        data['due_date'] ??
        data['nextDueDate'] ??
        data['next_due_date'],
  );
  DateTime? get paymentDate => _date(
    data['paymentDate'] ??
        data['payment_date'] ??
        data['paidDate'] ??
        data['createdAt'] ??
        data['created_at'],
  );
  String get receiptNo =>
      data['receiptNo']?.toString() ??
      data['receipt_number']?.toString() ??
      'Receipt';
  String get paymentMode =>
      data['paymentMode']?.toString() ??
      data['payment_mode']?.toString() ??
      data['mode']?.toString() ??
      'Cash';
  String get receivedBy =>
      data['receivedByName']?.toString() ??
      data['received_by_name']?.toString() ??
      data['receivedBy']?.toString() ??
      '--';
  String get remarks =>
      data['remarks']?.toString() ??
      data['transaction_id']?.toString() ??
      data['note']?.toString() ??
      '';
}

class _InstallmentRow {
  const _InstallmentRow({
    required this.number,
    required this.title,
    required this.amount,
    required this.paidAmount,
    required this.status,
    this.dueDate,
  });

  final int number;
  final String title;
  final double amount;
  final double paidAmount;
  final String status;
  final DateTime? dueDate;
}

class _FeeHistoryItem {
  const _FeeHistoryItem({
    required this.receiptNo,
    required this.amount,
    required this.mode,
    required this.date,
    required this.receipt,
  });

  final String receiptNo;
  final double amount;
  final String mode;
  final DateTime? date;
  final ReceiptModel receipt;
}

class _AttendanceEntry {
  const _AttendanceEntry({required this.date, required this.status});

  final DateTime date;
  final AttendanceStatus status;
}

class _AttendanceSummary {
  const _AttendanceSummary({
    required this.total,
    required this.present,
    required this.absent,
    required this.late,
    required this.leave,
    required this.absentDates,
  });

  final int total;
  final int present;
  final int absent;
  final int late;
  final int leave;
  final List<DateTime> absentDates;

  factory _AttendanceSummary.from(List<_AttendanceEntry> records) {
    final absentDates =
        records
            .where((record) => record.status == AttendanceStatus.absent)
            .map((record) => record.date)
            .toList()
          ..sort();
    return _AttendanceSummary(
      total: records.length,
      present: records
          .where((record) => record.status == AttendanceStatus.present)
          .length,
      absent: absentDates.length,
      late: records
          .where((record) => record.status == AttendanceStatus.late)
          .length,
      leave: records
          .where((record) => record.status == AttendanceStatus.leave)
          .length,
      absentDates: absentDates,
    );
  }
}

Future<_FeeProfileData> _loadFeeProfile(StudentModel student) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('fee_payments')
      .where('student_id', isEqualTo: student.numericId)
      .where('deleted_at', isNull: true)
      .get();

  final records = snapshot.docs
      .map((doc) => _FeeRecord(docId: doc.id, data: doc.data()))
      .toList();
  records.sort((a, b) {
    final aDate = a.dueDate ?? a.paymentDate ?? DateTime(2099);
    final bDate = b.dueDate ?? b.paymentDate ?? DateTime(2099);
    return aDate.compareTo(bDate);
  });

  final totalFromRecords = records.fold<double>(
    0,
    (total, record) => record.isReceipt ? total : total + record.totalAmount,
  );
  final paid = records.fold<double>(
    0,
    (total, record) => record.isReceipt ? total : total + record.paidAmount,
  );
  final pendingRecords = records.where(
    (record) => record.isPending && record.pendingAmount > 0,
  );
  final pending = pendingRecords.fold<double>(
    0,
    (total, record) => total + record.pendingAmount,
  );
  final totalFee = _amount(
    records
        .map((record) => record.data['totalFee'] ?? record.data['finalFee'])
        .firstWhere((value) => _amount(value) > 0, orElse: () => null),
  );
  final installments = _installmentRows(records);
  final history = _historyRows(
    student,
    records,
    totalFee > 0 ? totalFee : totalFromRecords,
    paid,
    pending,
  );
  final nextDueDate = pendingRecords
      .map((record) => record.dueDate)
      .whereType<DateTime>()
      .fold<DateTime?>(null, (earliest, date) {
        if (earliest == null || date.isBefore(earliest)) return date;
        return earliest;
      });

  return _FeeProfileData(
    records: records,
    totalFee: totalFee > 0 ? totalFee : totalFromRecords,
    paid: paid,
    pending: pending,
    nextDueDate: nextDueDate,
    installments: installments,
    history: history,
  );
}

List<_InstallmentRow> _installmentRows(List<_FeeRecord> records) {
  final planned =
      records
          .where((record) => !record.isReceipt && record.installmentNo != null)
          .toList()
        ..sort((a, b) {
          final noCompare = a.installmentNo!.compareTo(b.installmentNo!);
          if (noCompare != 0) return noCompare;
          return (a.dueDate ?? DateTime(2099)).compareTo(
            b.dueDate ?? DateTime(2099),
          );
        });

  return planned.map((record) {
    final paid = record.paidAmount;
    final amount = record.isPaid
        ? record.totalAmount
        : record.totalAmount + paid;
    final status = record.isPaid
        ? 'Paid'
        : paid > 0
        ? 'Partial'
        : 'Pending';
    return _InstallmentRow(
      number: record.installmentNo ?? 1,
      title: record.monthYear,
      amount: amount,
      paidAmount: paid,
      status: status,
      dueDate: record.dueDate,
    );
  }).toList();
}

List<_FeeHistoryItem> _historyRows(
  StudentModel student,
  List<_FeeRecord> records,
  double totalFee,
  double paid,
  double pending,
) {
  final receiptRecordNos = records
      .where((record) => record.isReceipt && record.paidAmount > 0)
      .map((record) => record.receiptNo)
      .toSet();
  final paidRecords =
      records
          .where(
            (record) =>
                record.hasPayment &&
                (record.isReceipt ||
                    !receiptRecordNos.contains(record.receiptNo)),
          )
          .toList()
        ..sort((a, b) {
          final aDate = a.paymentDate ?? DateTime(2000);
          final bDate = b.paymentDate ?? DateTime(2000);
          return bDate.compareTo(aDate);
        });

  return paidRecords.map((record) {
    return _FeeHistoryItem(
      receiptNo: record.receiptNo,
      amount: record.paidAmount,
      mode: record.paymentMode,
      date: record.paymentDate,
      receipt: _receiptFromRecord(student, record, totalFee, paid, pending),
    );
  }).toList();
}

ReceiptModel _receiptFromRecord(
  StudentModel student,
  _FeeRecord record,
  double totalFee,
  double paid,
  double pending,
) {
  final settings = InstituteSettingsService.instance.cachedOrDefault;
  return ReceiptModel(
    instituteName: settings.instituteName,
    instituteAddress: settings.address,
    institutePhone: settings.phone,
    instituteEmail: settings.email,
    logoUrl: settings.logoUrl,
    signatureUrl: settings.signatureUrl,
    receiptFooter: settings.receiptFooter,
    currencySymbol: settings.currencySymbol,
    receiptNo: record.receiptNo,
    studentName: student.displayName,
    studentPhone: student.primaryPhone.isEmpty ? null : student.primaryPhone,
    parentName: student.parentName ?? student.guardianName,
    parentPhone: student.parentPhone ?? student.guardianPhone,
    courseName: student.courseName ?? student.className ?? 'Course not set',
    batchName: student.batchName ?? 'Batch not set',
    academicYear: settings.academicYear,
    amountPaid: record.paidAmount,
    paymentMode: record.paymentMode,
    paymentDate: record.paymentDate,
    installmentNo: record.installmentNo,
    remarks: record.remarks,
    receivedByName: record.receivedBy,
    pendingAfterPayment: _amount(
      record.data['pendingAfterPayment'] ??
          record.data['pending_after_payment'] ??
          pending,
    ),
    totalFee: _amount(record.data['totalFee'] ?? totalFee),
    totalPaid: _amount(record.data['totalPaid'] ?? paid),
    generatedAt: DateTime.now(),
  );
}

Future<List<_AttendanceEntry>> _loadAttendance(int studentId) async {
  final attendances = FirebaseFirestore.instance.collection('attendances');
  final stringStudentId = studentId.toString();

  // Current attendance records contain both IDs. Older records used only
  // `student_id`, and its type varied between number and string. Fetch each
  // supported shape and de-duplicate by document ID so current records are
  // still counted exactly once.
  final snapshots = await Future.wait([
    attendances
        .where('studentId', isEqualTo: stringStudentId)
        .get(const GetOptions(source: Source.serverAndCache)),
    attendances
        .where('student_id', isEqualTo: studentId)
        .get(const GetOptions(source: Source.serverAndCache)),
    attendances
        .where('student_id', isEqualTo: stringStudentId)
        .get(const GetOptions(source: Source.serverAndCache)),
  ]);

  final recordsByDocumentId =
      <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};
  for (final snapshot in snapshots) {
    for (final document in snapshot.docs) {
      recordsByDocumentId[document.id] = document;
    }
  }

  final records = recordsByDocumentId.values.map((doc) {
    final attendance = AttendanceModel.fromFirestore(doc);
    return _AttendanceEntry(date: attendance.date, status: attendance.status);
  }).toList();
  records.sort((a, b) => a.date.compareTo(b.date));
  return records;
}

Future<void> _shareReceipt(BuildContext context, ReceiptModel receipt) async {
  final messenger = ScaffoldMessenger.of(context);
  final shared = await ReceiptPdfService.shareReceipt(receipt);
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        shared
            ? 'Receipt PDF ready to share.'
            : 'Receipt generated, sharing is not supported on this platform.',
      ),
      backgroundColor: shared ? AppTheme.success : AppTheme.warning,
    ),
  );
}

Future<void> _launchPhone(String phone) async {
  final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
  if (cleanPhone.isEmpty) return;
  await launchUrl(Uri.parse('tel:$cleanPhone'));
}

Future<void> _launchWhatsApp(String phone) async {
  final settings = InstituteSettingsService.instance.cachedOrDefault;
  var defaultCountryCode = settings.defaultCountryCode.replaceAll(
    RegExp(r'[^0-9]'),
    '',
  );
  if (defaultCountryCode.isEmpty) defaultCountryCode = '91';
  var cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
  if (cleanPhone.length == 10) cleanPhone = '$defaultCountryCode$cleanPhone';
  if (cleanPhone.isEmpty) return;
  await launchUrl(
    Uri.parse('https://wa.me/$cleanPhone'),
    mode: LaunchMode.externalApplication,
  );
}

Color _statusColor(String status) {
  return switch (status) {
    'Paid' => AppTheme.success,
    'Partial' => AppTheme.primary,
    _ => AppTheme.warning,
  };
}

Color _attendanceColor(AttendanceStatus? status) {
  return switch (status) {
    AttendanceStatus.present => AppTheme.success,
    AttendanceStatus.absent => AppTheme.danger,
    AttendanceStatus.late => AppTheme.warning,
    AttendanceStatus.leave => const Color(0xFFFDE68A),
    null => AppTheme.border,
  };
}

String _money(double value) {
  final symbol =
      InstituteSettingsService.instance.cachedOrDefault.currencySymbol;
  return '$symbol ${value.toStringAsFixed(0)}';
}

String _dateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

EdgeInsets _tabPadding(BuildContext context, {double extraBottom = 96}) {
  return EdgeInsets.fromLTRB(
    16,
    16,
    16,
    _bottomSafePadding(context) + extraBottom,
  );
}

double _bottomSafePadding(BuildContext context) {
  final mediaQuery = MediaQuery.of(context);
  return mediaQuery.padding.bottom > mediaQuery.viewPadding.bottom
      ? mediaQuery.padding.bottom
      : mediaQuery.viewPadding.bottom;
}

DateTime? _date(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value.trim());
  return null;
}

int? _int(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double _amount(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
