import 'package:flutter/material.dart';

import '../models/app_user_model.dart';
import '../models/default_permissions.dart';
import '../models/permission_keys.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_ui.dart';
import 'access_denied_screen.dart';

class PermissionEditorScreen extends StatefulWidget {
  const PermissionEditorScreen({
    super.key,
    required this.currentUser,
    required this.staffUser,
  });

  final AppUserModel currentUser;
  final AppUserModel staffUser;

  @override
  State<PermissionEditorScreen> createState() => _PermissionEditorScreenState();
}

class _PermissionEditorScreenState extends State<PermissionEditorScreen> {
  late Map<String, bool> _originalPermissions;
  late Map<String, bool> _draftPermissions;
  final Set<String> _expandedSections = {
    'Dashboard',
    'Students',
    'Attendance',
    'Fees',
  };

  bool _isSaving = false;

  bool get _isSelf => widget.currentUser.uid == widget.staffUser.uid;
  bool get _isAdminTarget => widget.staffUser.isAdmin;
  bool get _canEdit => widget.currentUser.canManageStaff;
  bool get _canUseBulkActions => widget.currentUser.isAdmin && !_isAdminTarget;

  bool get _hasUnsavedChanges =>
      !_mapsEqual(_originalPermissions, _draftPermissions);

  @override
  void initState() {
    super.initState();
    _originalPermissions = _initialPermissionsFor(widget.staffUser);
    _draftPermissions = Map<String, bool>.from(_originalPermissions);
  }

  @override
  Widget build(BuildContext context) {
    if (!_canEdit) return const AccessDeniedScreen();

    final bottomPadding = MediaQuery.viewPaddingOf(context).bottom;
    final enabledCount = _draftPermissions.values
        .where((value) => value)
        .length;

    return PopScope(
      canPop: !_hasUnsavedChanges && !_isSaving,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_isSaving) return;

        final shouldDiscard = await _confirmDiscardChanges();
        if (!context.mounted || !shouldDiscard) return;
        Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: const Text(
            'Permissions',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  _hasUnsavedChanges ? 118 + bottomPadding : 28 + bottomPadding,
                ),
                children: [
                  _HeaderCard(
                    user: widget.staffUser,
                    isSelf: _isSelf,
                    enabledCount: enabledCount,
                    totalCount: PermissionKeys.all.length,
                  ),
                  const SizedBox(height: 12),
                  _PresetCard(
                    role: widget.staffUser.role,
                    isAdminTarget: _isAdminTarget,
                    canUseBulkActions: _canUseBulkActions,
                    onApplyRoleDefaults: _applyRoleDefaults,
                    onEnableAll: _enableAll,
                    onDisableAll: _disableAll,
                  ),
                  if (_isAdminTarget) ...[
                    const SizedBox(height: 12),
                    const _NoticeCard(
                      icon: Icons.verified_user_outlined,
                      message: 'Admin has full access by default.',
                    ),
                  ] else if (_isSelf) ...[
                    const SizedBox(height: 12),
                    const _NoticeCard(
                      icon: Icons.lock_outline_rounded,
                      message: 'Your own admin permissions are protected.',
                    ),
                  ],
                  const SizedBox(height: 12),
                  for (final group in _permissionGroups) ...[
                    _PermissionGroupCard(
                      group: group,
                      draftPermissions: _draftPermissions,
                      expanded: _expandedSections.contains(group.title),
                      switchesEnabled: !_isAdminTarget && !_isSaving,
                      protectedKeys: _protectedKeys,
                      onExpansionChanged: (expanded) {
                        setState(() {
                          if (expanded) {
                            _expandedSections.add(group.title);
                          } else {
                            _expandedSections.remove(group.title);
                          }
                        });
                      },
                      onChanged: _setPermission,
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: _hasUnsavedChanges
            ? _SaveBar(
                isSaving: _isSaving,
                onReset: _resetDraft,
                onSave: _savePermissions,
              )
            : null,
      ),
    );
  }

  Set<String> get _protectedKeys {
    if (!_isSelf) return const {};

    return const {
      PermissionKeys.dashboardView,
      PermissionKeys.staffManage,
      PermissionKeys.settingsManage,
    };
  }

  Map<String, bool> _initialPermissionsFor(AppUserModel user) {
    if (user.isAdmin) return DefaultPermissions.admin;
    return user.effectivePermissions;
  }

  Future<void> _applyRoleDefaults() async {
    final confirmed = await _confirmAction(
      title: 'Apply role defaults?',
      message:
          'This will replace custom permissions with default permissions for this role.',
      actionLabel: 'Apply',
    );
    if (!confirmed || !mounted) return;

    setState(() {
      _draftPermissions = _withProtectedKeys(
        DefaultPermissions.forRole(widget.staffUser.role),
      );
    });
  }

  void _enableAll() {
    setState(() {
      _draftPermissions = _withProtectedKeys({
        for (final key in PermissionKeys.all) key: true,
      });
    });
  }

  void _disableAll() {
    setState(() {
      _draftPermissions = _withProtectedKeys({
        for (final key in PermissionKeys.all) key: false,
      });
    });
  }

  void _resetDraft() {
    setState(() {
      _draftPermissions = Map<String, bool>.from(_originalPermissions);
    });
  }

  void _setPermission(String key, bool value) {
    if (_isAdminTarget || _protectedKeys.contains(key)) return;

    setState(() {
      _draftPermissions = {..._draftPermissions, key: value};
    });
  }

  Map<String, bool> _withProtectedKeys(Map<String, bool> permissions) {
    final next = {
      for (final key in PermissionKeys.all) key: permissions[key] ?? false,
    };

    if (_isSelf) {
      next[PermissionKeys.dashboardView] = true;
      next[PermissionKeys.staffManage] = true;
      next[PermissionKeys.settingsManage] = true;
    }

    return next;
  }

  Future<void> _savePermissions() async {
    if (_isSaving || _isAdminTarget) return;

    setState(() => _isSaving = true);
    try {
      final permissionsToSave = _withProtectedKeys(_draftPermissions);
      await UserService.instance.updateUserPermissions(
        widget.staffUser.uid,
        permissionsToSave,
      );
      if (!mounted) return;

      setState(() {
        _originalPermissions = Map<String, bool>.from(permissionsToSave);
        _draftPermissions = Map<String, bool>.from(permissionsToSave);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Permissions updated.')));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<bool> _confirmDiscardChanges() {
    return _confirmAction(
      title: 'Discard changes?',
      message: 'Discard unsaved permission changes?',
      actionLabel: 'Discard',
      isDestructive: true,
    );
  }

  Future<bool> _confirmAction({
    required String title,
    required String message,
    required String actionLabel,
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: isDestructive
                    ? AppTheme.danger
                    : AppTheme.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(actionLabel),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  static bool _mapsEqual(Map<String, bool> a, Map<String, bool> b) {
    for (final key in PermissionKeys.all) {
      if ((a[key] ?? false) != (b[key] ?? false)) return false;
    }
    return true;
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.user,
    required this.isSelf,
    required this.enabledCount,
    required this.totalCount,
  });

  final AppUserModel user;
  final bool isSelf;
  final int enabledCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                backgroundColor: AppTheme.primarySoft,
                child: Icon(
                  Icons.person_outline_rounded,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name.isEmpty ? 'Unnamed Staff' : user.name,
                      style: const TextStyle(
                        color: AppTheme.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      user.email,
                      style: const TextStyle(
                        color: AppTheme.muted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppStatusBadge(
                label: _roleLabel(user.role),
                color: AppTheme.primary,
                softColor: AppTheme.primarySoft,
              ),
              AppStatusBadge(
                label: user.isActive ? 'Active' : 'Disabled',
                color: user.isActive ? AppTheme.success : AppTheme.danger,
                softColor: user.isActive
                    ? AppTheme.successSoft
                    : AppTheme.dangerSoft,
              ),
              if (isSelf)
                const AppStatusBadge(
                  label: 'You',
                  color: AppTheme.warning,
                  softColor: AppTheme.warningSoft,
                ),
              AppStatusBadge(
                label: '$enabledCount / $totalCount enabled',
                color: AppTheme.muted,
                softColor: AppTheme.background,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PresetCard extends StatelessWidget {
  const _PresetCard({
    required this.role,
    required this.isAdminTarget,
    required this.canUseBulkActions,
    required this.onApplyRoleDefaults,
    required this.onEnableAll,
    required this.onDisableAll,
  });

  final String role;
  final bool isAdminTarget;
  final bool canUseBulkActions;
  final VoidCallback onApplyRoleDefaults;
  final VoidCallback onEnableAll;
  final VoidCallback onDisableAll;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      title: 'Role Preset',
      icon: Icons.tune_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _roleLabel(role),
            style: const TextStyle(
              color: AppTheme.text,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: isAdminTarget ? null : onApplyRoleDefaults,
                icon: const Icon(Icons.restart_alt_rounded, size: 18),
                label: const Text('Apply Role Defaults'),
              ),
              if (canUseBulkActions)
                OutlinedButton.icon(
                  onPressed: onEnableAll,
                  icon: const Icon(Icons.done_all_rounded, size: 18),
                  label: const Text('Enable All'),
                ),
              if (canUseBulkActions)
                OutlinedButton.icon(
                  onPressed: onDisableAll,
                  icon: const Icon(Icons.remove_done_rounded, size: 18),
                  label: const Text('Disable All'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primarySoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppTheme.text,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionGroupCard extends StatelessWidget {
  const _PermissionGroupCard({
    required this.group,
    required this.draftPermissions,
    required this.expanded,
    required this.switchesEnabled,
    required this.protectedKeys,
    required this.onExpansionChanged,
    required this.onChanged,
  });

  final _PermissionGroup group;
  final Map<String, bool> draftPermissions;
  final bool expanded;
  final bool switchesEnabled;
  final Set<String> protectedKeys;
  final ValueChanged<bool> onExpansionChanged;
  final void Function(String key, bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: expanded,
          onExpansionChanged: onExpansionChanged,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          iconColor: AppTheme.primary,
          collapsedIconColor: AppTheme.muted,
          title: Text(
            group.title,
            style: const TextStyle(
              color: AppTheme.text,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              group.description,
              style: const TextStyle(color: AppTheme.muted, fontSize: 12),
            ),
          ),
          children: [
            for (var i = 0; i < group.items.length; i++) ...[
              if (i > 0) const Divider(height: 18),
              _PermissionRow(
                item: group.items[i],
                value: draftPermissions[group.items[i].key] ?? false,
                enabled:
                    switchesEnabled &&
                    !protectedKeys.contains(group.items[i].key),
                protected: protectedKeys.contains(group.items[i].key),
                onChanged: (value) => onChanged(group.items[i].key, value),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({
    required this.item,
    required this.value,
    required this.enabled,
    required this.protected,
    required this.onChanged,
  });

  final _PermissionItem item;
  final bool value;
  final bool enabled;
  final bool protected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: const TextStyle(
                    color: AppTheme.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  protected
                      ? '${item.description} Protected for your account.'
                      : item.description,
                  style: const TextStyle(
                    color: AppTheme.muted,
                    fontSize: 12,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            activeThumbColor: AppTheme.success,
            activeTrackColor: AppTheme.successSoft,
            inactiveThumbColor: AppTheme.mutedLight,
            inactiveTrackColor: AppTheme.border,
            onChanged: enabled ? onChanged : null,
          ),
        ],
      ),
    );
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({
    required this.isSaving,
    required this.onReset,
    required this.onSave,
  });

  final bool isSaving;
  final VoidCallback onReset;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 420;
          final veryCompact = constraints.maxWidth < 360;
          final resetButton = TextButton(
            onPressed: isSaving ? null : onReset,
            child: const Text('Reset'),
          );
          final saveButton = ElevatedButton.icon(
            onPressed: isSaving ? null : onSave,
            icon: isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save_outlined, size: 18),
            label: Text(
              isSaving
                  ? 'Saving'
                  : veryCompact
                  ? 'Save'
                  : 'Save Permissions',
            ),
          );

          return Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              border: Border(top: BorderSide(color: AppTheme.border)),
            ),
            child: compact
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Unsaved changes',
                        style: TextStyle(
                          color: AppTheme.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: resetButton),
                          const SizedBox(width: 8),
                          Expanded(child: saveButton),
                        ],
                      ),
                    ],
                  )
                : Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Unsaved changes',
                          style: TextStyle(
                            color: AppTheme.text,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      resetButton,
                      const SizedBox(width: 8),
                      saveButton,
                    ],
                  ),
          );
        },
      ),
    );
  }
}

class _PermissionGroup {
  const _PermissionGroup({
    required this.title,
    required this.description,
    required this.items,
  });

  final String title;
  final String description;
  final List<_PermissionItem> items;
}

class _PermissionItem {
  const _PermissionItem({
    required this.key,
    required this.label,
    required this.description,
  });

  final String key;
  final String label;
  final String description;
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

const _permissionGroups = <_PermissionGroup>[
  _PermissionGroup(
    title: 'Dashboard',
    description: 'Main home screen and summary access.',
    items: [
      _PermissionItem(
        key: PermissionKeys.dashboardView,
        label: 'View Dashboard',
        description: 'Allow user to open the dashboard.',
      ),
    ],
  ),
  _PermissionGroup(
    title: 'Students',
    description: 'Student records and student document access.',
    items: [
      _PermissionItem(
        key: PermissionKeys.studentsView,
        label: 'View Students',
        description: 'Allow user to view student records.',
      ),
      _PermissionItem(
        key: PermissionKeys.studentsCreate,
        label: 'Add Students',
        description: 'Allow user to create new student records.',
      ),
      _PermissionItem(
        key: PermissionKeys.studentsEdit,
        label: 'Edit Students',
        description: 'Allow user to update student details.',
      ),
      _PermissionItem(
        key: PermissionKeys.studentsDelete,
        label: 'Delete Students',
        description: 'Allow user to remove student records.',
      ),
      _PermissionItem(
        key: PermissionKeys.studentsExportPdf,
        label: 'Export Student PDF',
        description: 'Allow user to export student information as PDF.',
      ),
    ],
  ),
  _PermissionGroup(
    title: 'Attendance',
    description: 'Daily attendance and attendance exports.',
    items: [
      _PermissionItem(
        key: PermissionKeys.attendanceView,
        label: 'View Attendance',
        description: 'Allow user to view attendance records.',
      ),
      _PermissionItem(
        key: PermissionKeys.attendanceMark,
        label: 'Mark Attendance',
        description: 'Allow user to mark class attendance.',
      ),
      _PermissionItem(
        key: PermissionKeys.attendanceEditPast,
        label: 'Edit Past Attendance',
        description: 'Allow user to modify older attendance records.',
      ),
      _PermissionItem(
        key: PermissionKeys.attendanceExport,
        label: 'Export Attendance',
        description: 'Allow user to export attendance data.',
      ),
    ],
  ),
  _PermissionGroup(
    title: 'Fees',
    description: 'Fee payments, plans, receipts, and history.',
    items: [
      _PermissionItem(
        key: PermissionKeys.feesView,
        label: 'View Fees',
        description: 'Allow user to view fee records.',
      ),
      _PermissionItem(
        key: PermissionKeys.feesCollect,
        label: 'Collect Fees',
        description: 'Allow user to record fee payments.',
      ),
      _PermissionItem(
        key: PermissionKeys.feesEditPlan,
        label: 'Edit Fee Plans',
        description: 'Allow user to update student fee plans.',
      ),
      _PermissionItem(
        key: PermissionKeys.feesViewHistory,
        label: 'View Fee History',
        description: 'Allow user to inspect payment history.',
      ),
      _PermissionItem(
        key: PermissionKeys.feesEditPaymentHistory,
        label: 'Edit Payment History',
        description:
            'Allow user to correct payment amount, date, mode, or remarks.',
      ),
      _PermissionItem(
        key: PermissionKeys.feesShareReceipt,
        label: 'Share Receipts',
        description: 'Allow user to share fee receipts.',
      ),
      _PermissionItem(
        key: PermissionKeys.feesDeletePayment,
        label: 'Delete Payments',
        description: 'Allow user to delete recorded payments.',
      ),
    ],
  ),
  _PermissionGroup(
    title: 'Reports',
    description: 'Institute reports and report exports.',
    items: [
      _PermissionItem(
        key: PermissionKeys.reportsView,
        label: 'View Reports',
        description: 'Allow user to open reports.',
      ),
      _PermissionItem(
        key: PermissionKeys.reportsExport,
        label: 'Export Reports',
        description: 'Allow user to export report data.',
      ),
    ],
  ),
  _PermissionGroup(
    title: 'Reminders',
    description: 'Reminder list and reminder management.',
    items: [
      _PermissionItem(
        key: PermissionKeys.remindersView,
        label: 'View Reminders',
        description: 'Allow user to view reminders.',
      ),
      _PermissionItem(
        key: PermissionKeys.remindersCreate,
        label: 'Create Reminders',
        description: 'Allow user to create new reminders.',
      ),
      _PermissionItem(
        key: PermissionKeys.remindersEdit,
        label: 'Edit Reminders',
        description: 'Allow user to update existing reminders.',
      ),
      _PermissionItem(
        key: PermissionKeys.remindersDelete,
        label: 'Delete Reminders',
        description: 'Allow user to delete reminders.',
      ),
    ],
  ),
  _PermissionGroup(
    title: 'Message Templates',
    description: 'Saved message templates for communication.',
    items: [
      _PermissionItem(
        key: PermissionKeys.templatesUse,
        label: 'Use Templates',
        description: 'Allow user to use message templates.',
      ),
      _PermissionItem(
        key: PermissionKeys.templatesManage,
        label: 'Manage Templates',
        description: 'Allow user to create and edit templates.',
      ),
    ],
  ),
  _PermissionGroup(
    title: 'Batches, Courses & Enrollments',
    description: 'Academic structure and enrollment setup.',
    items: [
      _PermissionItem(
        key: PermissionKeys.batchesView,
        label: 'View Batches',
        description: 'Allow user to view batches.',
      ),
      _PermissionItem(
        key: PermissionKeys.batchesManage,
        label: 'Manage Batches',
        description: 'Allow user to create and update batches.',
      ),
      _PermissionItem(
        key: PermissionKeys.coursesView,
        label: 'View Courses',
        description: 'Allow user to view courses.',
      ),
      _PermissionItem(
        key: PermissionKeys.coursesManage,
        label: 'Manage Courses',
        description: 'Allow user to create and update courses.',
      ),
      _PermissionItem(
        key: PermissionKeys.enrollmentsView,
        label: 'View Enrollments',
        description: 'Allow user to view enrollments.',
      ),
      _PermissionItem(
        key: PermissionKeys.enrollmentsManage,
        label: 'Manage Enrollments',
        description: 'Allow user to create and update enrollments.',
      ),
    ],
  ),
  _PermissionGroup(
    title: 'Staff, Settings & Backup',
    description: 'Administrative controls and backup access.',
    items: [
      _PermissionItem(
        key: PermissionKeys.staffManage,
        label: 'Manage Staff',
        description: 'Allow user to manage staff roles and permissions.',
      ),
      _PermissionItem(
        key: PermissionKeys.settingsManage,
        label: 'Manage Settings',
        description: 'Allow user to update institute settings.',
      ),
      _PermissionItem(
        key: PermissionKeys.backupExport,
        label: 'Export Backup',
        description: 'Allow user to export backup data.',
      ),
      _PermissionItem(
        key: PermissionKeys.backupRestore,
        label: 'Restore Backup',
        description: 'Allow user to restore backup data.',
      ),
    ],
  ),
  _PermissionGroup(
    title: 'Documents / PDFs',
    description: 'PDF and document generation access.',
    items: [
      _PermissionItem(
        key: PermissionKeys.documentsStudentPdf,
        label: 'Student PDF',
        description: 'Allow user to generate student PDFs.',
      ),
      _PermissionItem(
        key: PermissionKeys.documentsFeeStatementPdf,
        label: 'Fee Statement PDF',
        description: 'Allow user to generate fee statement PDFs.',
      ),
      _PermissionItem(
        key: PermissionKeys.documentsAttendancePdf,
        label: 'Attendance PDF',
        description: 'Allow user to generate attendance PDFs.',
      ),
    ],
  ),
];
