import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/fees/fee_record_values.dart';
import '../models/app_user_model.dart';
import '../models/attendance_model.dart';
import '../models/student_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';

class StudentPortalScreen extends StatelessWidget {
  const StudentPortalScreen({super.key, required this.appUser});

  final AppUserModel appUser;

  @override
  Widget build(BuildContext context) {
    final recordId = appUser.studentRecordId;
    if (recordId == null || recordId.isEmpty) {
      return const _PortalMessage(
        title: 'Account setup pending',
        message:
            'Your student profile is not linked yet. Please contact admin.',
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('students')
          .doc(recordId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const _PortalMessage(
            title: 'Could not load your profile',
            message: 'Please check your connection or contact admin.',
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: AppTheme.background,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final document = snapshot.data!;
        if (!document.exists || document.data() == null) {
          return const _PortalMessage(
            title: 'Student profile not available',
            message: 'Please contact admin for help.',
          );
        }
        return _StudentPortalHome(
          appUser: appUser,
          student: StudentModel.fromFirestore(document),
        );
      },
    );
  }
}

class _StudentPortalHome extends StatelessWidget {
  const _StudentPortalHome({required this.appUser, required this.student});

  final AppUserModel appUser;
  final StudentModel student;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Student Portal'),
        actions: [
          IconButton(
            tooltip: 'Change password',
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => const _ChangePasswordDialog(),
            ),
            icon: const Icon(Icons.lock_reset_rounded),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: () => AuthService.instance.signOut(),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
        children: [
          if (appUser.mustChangePassword) ...[
            _PasswordNotice(
              onChangePassword: () => showDialog<void>(
                context: context,
                builder: (_) => const _ChangePasswordDialog(),
              ),
            ),
            const SizedBox(height: 14),
          ],
          _ProfileCard(student: student, loginId: appUser.loginId),
          const SizedBox(height: 14),
          _AttendanceCard(appUser: appUser),
          const SizedBox(height: 14),
          _FeeCard(appUser: appUser),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.student, required this.loginId});

  final StudentModel student;
  final String? loginId;

  @override
  Widget build(BuildContext context) {
    return _PortalCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: AppTheme.primarySoft,
            backgroundImage: student.profilePhoto == null
                ? null
                : NetworkImage(student.profilePhoto!),
            child: student.profilePhoto == null
                ? Text(
                    student.displayName.characters.first.toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.displayName,
                  style: const TextStyle(
                    color: AppTheme.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  student.displayClassBatch,
                  style: const TextStyle(color: AppTheme.muted),
                ),
                if (loginId != null && loginId!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Login ID: $loginId',
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  const _AttendanceCard({required this.appUser});

  final AppUserModel appUser;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AttendanceModel>>(
      future: _loadAttendance(appUser),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const _PortalCard(
            child: _SectionMessage('Attendance could not be loaded.'),
          );
        }
        if (!snapshot.hasData) {
          return const _PortalCard(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final records = snapshot.data!;
        final present = records
            .where((record) => record.status == AttendanceStatus.present)
            .length;
        final late = records
            .where((record) => record.status == AttendanceStatus.late)
            .length;
        final percentage = records.isEmpty
            ? 0
            : ((present + late) * 100 / records.length).round();
        return _PortalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(
                title: 'Attendance',
                icon: Icons.calendar_month_rounded,
              ),
              const SizedBox(height: 12),
              if (records.isEmpty)
                const _SectionMessage('No attendance has been marked yet.')
              else ...[
                Text(
                  '$percentage% attendance',
                  style: const TextStyle(
                    color: AppTheme.success,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$present present • ${records.length - present - late} absent • $late late',
                  style: const TextStyle(color: AppTheme.muted),
                ),
                const SizedBox(height: 12),
                ...records.reversed
                    .take(5)
                    .map(
                      (record) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          '${DateFormat('dd MMM yyyy').format(record.date)}  •  ${record.status.label}',
                          style: const TextStyle(color: AppTheme.text),
                        ),
                      ),
                    ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _FeeCard extends StatelessWidget {
  const _FeeCard({required this.appUser});

  final AppUserModel appUser;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _loadFees(appUser),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const _PortalCard(
            child: _SectionMessage('Fee details could not be loaded.'),
          );
        }
        if (!snapshot.hasData) {
          return const _PortalCard(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final records = snapshot.data!;
        final plannedRecords = records
            .where((record) => !FeeRecordValues.isReceipt(record))
            .toList();
        final paid = plannedRecords.fold<double>(
          0,
          (total, item) => total + _amount(item['amount_paid']),
        );
        final pending = plannedRecords.fold<double>(
          0,
          (total, item) => total + FeeRecordValues.outstanding(item),
        );
        return _PortalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(
                title: 'Fees',
                icon: Icons.receipt_long_rounded,
              ),
              const SizedBox(height: 12),
              if (records.isEmpty)
                const _SectionMessage('No fee records are available yet.')
              else ...[
                Text(
                  'Paid: ₹${paid.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: AppTheme.success,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pending: ₹${pending.clamp(0, double.infinity).toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: AppTheme.warning,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _isSaving = false;
  String? _error;

  @override
  void dispose() {
    _currentPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_newPassword.text.length < 6) {
      setState(() => _error = 'New password must be at least 6 characters.');
      return;
    }
    if (_newPassword.text != _confirmPassword.text) {
      setState(() => _error = 'New password and confirmation do not match.');
      return;
    }
    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      await AuthService.instance.changePassword(
        currentPassword: _currentPassword.text,
        newPassword: _newPassword.text,
      );
      await UserService.instance.markCurrentPasswordChanged();
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Current password is incorrect. Try again.');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _currentPassword,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Current password'),
          ),
          TextField(
            controller: _newPassword,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'New password'),
          ),
          TextField(
            controller: _confirmPassword,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Confirm new password',
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: AppTheme.danger)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save password'),
        ),
      ],
    );
  }
}

class _PasswordNotice extends StatelessWidget {
  const _PasswordNotice({required this.onChangePassword});

  final VoidCallback onChangePassword;

  @override
  Widget build(BuildContext context) {
    return _PortalCard(
      color: AppTheme.warning.withValues(alpha: 0.1),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppTheme.warning),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'For your security, change the temporary password now.',
              style: TextStyle(
                color: AppTheme.text,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(onPressed: onChangePassword, child: const Text('Change')),
        ],
      ),
    );
  }
}

class _PortalCard extends StatelessWidget {
  const _PortalCard({required this.child, this.color});

  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.text,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _SectionMessage extends StatelessWidget {
  const _SectionMessage(this.message);

  final String message;

  @override
  Widget build(BuildContext context) =>
      Text(message, style: const TextStyle(color: AppTheme.muted));
}

class _PortalMessage extends StatelessWidget {
  const _PortalMessage({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.school_outlined,
                color: AppTheme.primary,
                size: 52,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.text,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => AuthService.instance.signOut(),
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<List<AttendanceModel>> _loadAttendance(AppUserModel appUser) async {
  final collection = FirebaseFirestore.instance.collection('attendances');
  final futures = <Future<QuerySnapshot<Map<String, dynamic>>>>[];
  final studentId = appUser.studentId;
  if (studentId != null && studentId.isNotEmpty) {
    futures.add(collection.where('studentId', isEqualTo: studentId).get());
    futures.add(collection.where('student_id', isEqualTo: studentId).get());
  }
  if (appUser.studentNumericId != null) {
    futures.add(
      collection.where('student_id', isEqualTo: appUser.studentNumericId).get(),
    );
  }
  final snapshots = await Future.wait(futures);
  final byId = <String, AttendanceModel>{};
  for (final snapshot in snapshots) {
    for (final document in snapshot.docs) {
      byId[document.id] = AttendanceModel.fromFirestore(document);
    }
  }
  final records = byId.values.toList()
    ..sort((a, b) => a.date.compareTo(b.date));
  return records;
}

Future<List<Map<String, dynamic>>> _loadFees(AppUserModel appUser) async {
  final collection = FirebaseFirestore.instance.collection('fee_payments');
  final futures = <Future<QuerySnapshot<Map<String, dynamic>>>>[];
  final studentId = appUser.studentId;
  if (studentId != null && studentId.isNotEmpty) {
    futures.add(collection.where('studentId', isEqualTo: studentId).get());
    futures.add(collection.where('student_id', isEqualTo: studentId).get());
  }
  if (appUser.studentNumericId != null) {
    futures.add(
      collection.where('student_id', isEqualTo: appUser.studentNumericId).get(),
    );
  }
  final snapshots = await Future.wait(futures);
  final byId = <String, Map<String, dynamic>>{};
  for (final snapshot in snapshots) {
    for (final document in snapshot.docs) {
      byId[document.id] = document.data();
    }
  }
  return byId.values.toList();
}

double _amount(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
