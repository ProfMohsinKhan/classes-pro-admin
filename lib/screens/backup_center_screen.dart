import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/app_user_model.dart';
import '../services/backup_service.dart';
import '../services/institute_settings_service.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';
import 'access_denied_screen.dart';

enum _BackupAction {
  fullJson,
  studentsCsv,
  feesCsv,
  attendanceCsv,
  remindersCsv,
}

class BackupCenterScreen extends StatefulWidget {
  const BackupCenterScreen({super.key});

  @override
  State<BackupCenterScreen> createState() => _BackupCenterScreenState();
}

class _BackupCenterScreenState extends State<BackupCenterScreen> {
  late final Stream<AppUserModel?> _profileStream;
  late final Future<String> _instituteNameFuture;
  final BackupService _backupService = BackupService();

  _BackupAction? _runningAction;
  DateTime? _lastGeneratedAt;

  @override
  void initState() {
    super.initState();
    _profileStream = UserService.instance.streamCurrentUserProfile();
    _instituteNameFuture = _loadInstituteName();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUserModel?>(
      stream: _profileStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppTheme.background,
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            ),
          );
        }

        final appUser = snapshot.data;
        if (appUser == null ||
            !(appUser.canExportBackups || appUser.canRestoreBackups)) {
          return const AccessDeniedScreen();
        }

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            title: const Text(
              'Backup & Safety',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<String>(
                    future: _instituteNameFuture,
                    builder: (context, snapshot) {
                      return _Header(
                        instituteName: snapshot.data ?? 'Mak Tutorials',
                        lastGeneratedAt: _lastGeneratedAt,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const _WarningCard(),
                  const SizedBox(height: 14),
                  if (appUser.canExportBackups)
                    _Section(
                      title: 'Export',
                      subtitle: 'Generate backups only when you tap an export.',
                      child: Column(
                        children: [
                          _ExportTile(
                            icon: Icons.inventory_2_outlined,
                            title: 'Full JSON Backup',
                            subtitle:
                                'Students, enrollments, fees, attendance, courses, batches, reminders, templates, settings and safe user profiles.',
                            color: AppTheme.primary,
                            isLoading: _runningAction == _BackupAction.fullJson,
                            onTap: () => _runExport(_BackupAction.fullJson),
                          ),
                          _ExportTile(
                            icon: Icons.group_outlined,
                            title: 'Students CSV',
                            subtitle: 'Student contact, course and batch list.',
                            color: AppTheme.success,
                            isLoading:
                                _runningAction == _BackupAction.studentsCsv,
                            onTap: () => _runExport(_BackupAction.studentsCsv),
                          ),
                          _ExportTile(
                            icon: Icons.payments_outlined,
                            title: 'Fees CSV',
                            subtitle:
                                'Receipt, amount, mode and payment details.',
                            color: AppTheme.success,
                            isLoading: _runningAction == _BackupAction.feesCsv,
                            onTap: () => _runExport(_BackupAction.feesCsv),
                          ),
                          _ExportTile(
                            icon: Icons.calendar_month_outlined,
                            title: 'Attendance CSV',
                            subtitle:
                                'Date, student, status, course and batch.',
                            color: AppTheme.success,
                            isLoading:
                                _runningAction == _BackupAction.attendanceCsv,
                            onTap: () =>
                                _runExport(_BackupAction.attendanceCsv),
                          ),
                          _ExportTile(
                            icon: Icons.notifications_outlined,
                            title: 'Reminders CSV',
                            subtitle: 'Due reminders with amount and priority.',
                            color: AppTheme.success,
                            isLoading:
                                _runningAction == _BackupAction.remindersCsv,
                            onTap: () => _runExport(_BackupAction.remindersCsv),
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                  if (appUser.canExportBackups) const SizedBox(height: 14),
                  if (appUser.canRestoreBackups)
                    _Section(
                      title: 'Restore / Import',
                      subtitle: 'Use restore only after backup testing.',
                      child: _RestoreCard(onTap: _showRestoreWarning),
                    ),
                  const SizedBox(height: 14),
                  const _Section(
                    title: 'Backup Checklist',
                    subtitle: 'Simple habits prevent painful data loss.',
                    child: _Checklist(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<String> _loadInstituteName() async {
    try {
      final settings = await InstituteSettingsService.instance.loadSettings();
      return settings.instituteName.trim().isEmpty
          ? 'Mak Tutorials'
          : settings.instituteName.trim();
    } catch (_) {
      return 'Mak Tutorials';
    }
  }

  Future<void> _runExport(_BackupAction action) async {
    if (_runningAction != null) return;
    setState(() => _runningAction = action);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final export = await switch (action) {
        _BackupAction.fullJson => _backupService.exportFullBackup(),
        _BackupAction.studentsCsv => _backupService.exportStudentsCsv(),
        _BackupAction.feesCsv => _backupService.exportFeesCsv(),
        _BackupAction.attendanceCsv => _backupService.exportAttendanceCsv(),
        _BackupAction.remindersCsv => _backupService.exportRemindersCsv(),
      };
      final shared = await _backupService.shareExport(export);
      if (!mounted) return;
      setState(() => _lastGeneratedAt = export.generatedAt);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            shared
                ? '${export.fileName} ready to share.'
                : 'Export generated, but sharing is not supported on this platform.',
          ),
          backgroundColor: shared ? AppTheme.success : AppTheme.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: AppTheme.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _runningAction = null);
    }
  }

  Future<void> _showRestoreWarning() async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Import JSON Backup'),
          content: const Text(
            'Restore can overwrite existing data. Use only after testing on a test Firebase project. Import restore will be added after final backup testing.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.instituteName, required this.lastGeneratedAt});

  final String instituteName;
  final DateTime? lastGeneratedAt;

  @override
  Widget build(BuildContext context) {
    final last = lastGeneratedAt == null
        ? 'No export generated in this session'
        : 'Last generated ${DateFormat('dd MMM yyyy, hh:mm a').format(lastGeneratedAt!)}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Backup & Data Safety',
          style: TextStyle(
            color: AppTheme.text,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Export and protect Mak Tutorials data',
          style: TextStyle(color: AppTheme.muted),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _InfoPill(icon: Icons.school_outlined, label: instituteName),
            _InfoPill(icon: Icons.schedule_rounded, label: last),
          ],
        ),
      ],
    );
  }
}

class _WarningCard extends StatelessWidget {
  const _WarningCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.warning.withValues(alpha: 0.35)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: AppTheme.warning),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Only admins should use this section.',
                  style: TextStyle(
                    color: AppTheme.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Keep backup files private.',
                  style: TextStyle(color: AppTheme.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
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
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.text,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: AppTheme.muted)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _ExportTile extends StatelessWidget {
  const _ExportTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isLoading,
    required this.onTap,
    this.isLast = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isLoading;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 8,
          ),
          leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: AppTheme.text,
              fontWeight: FontWeight.w900,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(color: AppTheme.muted),
          ),
          trailing: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.ios_share_rounded, color: AppTheme.primary),
          onTap: isLoading ? null : onTap,
        ),
      ),
    );
  }
}

class _RestoreCard extends StatelessWidget {
  const _RestoreCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.danger.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Restore can overwrite existing data. Use only after testing.',
            style: TextStyle(color: AppTheme.text, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Import restore will be added after final backup testing.',
            style: TextStyle(color: AppTheme.muted),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.danger,
              side: const BorderSide(color: AppTheme.danger),
            ),
            icon: const Icon(Icons.upload_file_rounded),
            label: const Text('Import JSON Backup'),
          ),
        ],
      ),
    );
  }
}

class _Checklist extends StatelessWidget {
  const _Checklist();

  @override
  Widget build(BuildContext context) {
    const items = [
      'Export backup weekly',
      'Save file in Google Drive/private storage',
      'Do not share backup publicly',
      'Test restore only on test Firebase project',
    ];
    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppTheme.success),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(
                    color: AppTheme.text,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
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
