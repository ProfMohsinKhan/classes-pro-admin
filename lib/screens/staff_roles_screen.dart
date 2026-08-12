import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/app_user_model.dart';
import '../models/default_permissions.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_ui.dart';
import 'access_denied_screen.dart';
import 'permission_editor_screen.dart';

class StaffRolesScreen extends StatelessWidget {
  const StaffRolesScreen({super.key});

  static const _roles = ['admin', 'coAdmin', 'receptionist', 'studentHelper'];

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Staff & Roles',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: StreamBuilder<AppUserModel?>(
        stream: UserService.instance.streamCurrentUserProfile(),
        builder: (context, profileSnapshot) {
          if (profileSnapshot.connectionState == ConnectionState.waiting) {
            return const _LoadingState();
          }

          final currentUser = profileSnapshot.data;
          if (currentUser == null || !currentUser.canManageStaff) {
            return const AccessDeniedScreen();
          }

          return StreamBuilder<List<AppUserModel>>(
            stream: UserService.instance.streamAllUsers(),
            builder: (context, usersSnapshot) {
              if (usersSnapshot.connectionState == ConnectionState.waiting) {
                return const _LoadingState();
              }

              final users = usersSnapshot.data ?? [];

              return ListView.separated(
                padding: const EdgeInsets.all(18),
                itemCount: users.length + 1,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _StaffToolsCard(currentUser: currentUser);
                  }

                  final user = users[index - 1];
                  final isSelf = user.uid == currentUid;
                  final lockSelfRole = isSelf && user.isAdmin;

                  return _StaffUserCard(
                    currentUser: currentUser,
                    user: user,
                    isSelf: isSelf,
                    lockSelfRole: lockSelfRole,
                    roles: _roles,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _StaffToolsCard extends StatelessWidget {
  const _StaffToolsCard({required this.currentUser});

  final AppUserModel currentUser;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AddStaffCard(currentUser: currentUser),
        const SizedBox(height: 12),
        const _PermissionBackfillCard(),
      ],
    );
  }
}

class _AddStaffCard extends StatelessWidget {
  const _AddStaffCard({required this.currentUser});

  final AppUserModel currentUser;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 560;
          final info = const Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primarySoft,
                child: Icon(Icons.person_add_alt_1, color: AppTheme.primary),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Staff Accounts',
                      style: TextStyle(
                        color: AppTheme.text,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Create login accounts and assign default permissions.',
                      style: TextStyle(color: AppTheme.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          );
          final button = FilledButton.icon(
            onPressed: () => _showAddStaffSheet(context, currentUser),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add Staff'),
          );

          if (narrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [info, const SizedBox(height: 12), button],
            );
          }

          return Row(
            children: [
              Expanded(child: info),
              const SizedBox(width: 10),
              button,
            ],
          );
        },
      ),
    );
  }

  void _showAddStaffSheet(BuildContext context, AppUserModel currentUser) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _AddStaffSheet(currentUser: currentUser),
    );
  }
}

class _PermissionBackfillCard extends StatefulWidget {
  const _PermissionBackfillCard();

  @override
  State<_PermissionBackfillCard> createState() =>
      _PermissionBackfillCardState();
}

class _PermissionBackfillCardState extends State<_PermissionBackfillCard> {
  bool _isRunning = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 560;
        final info = Row(
          children: [
            const CircleAvatar(
              backgroundColor: AppTheme.surface,
              child: Icon(Icons.security_rounded, color: AppTheme.primary),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Permission Safety',
                    style: TextStyle(
                      color: AppTheme.text,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Fill missing permission keys before strict Firestore rules.',
                    style: TextStyle(color: AppTheme.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        );
        final button = OutlinedButton.icon(
          onPressed: _isRunning ? null : _confirmAndRun,
          icon: _isRunning
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.playlist_add_check_rounded, size: 18),
          label: Text(_isRunning ? 'Running' : 'Backfill Missing Permissions'),
        );

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primarySoft,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
          ),
          child: isNarrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [info, const SizedBox(height: 12), button],
                )
              : Row(
                  children: [
                    Expanded(child: info),
                    const SizedBox(width: 10),
                    button,
                  ],
                ),
        );
      },
    );
  }

  Future<void> _confirmAndRun() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Backfill missing permissions?'),
          content: const Text(
            'This will add missing permission keys to existing staff profiles. Existing custom permissions will be preserved.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Run Backfill'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isRunning = true);
    try {
      final result = await UserService.instance
          .backfillMissingPermissionsForAllUsers();
      if (!mounted) return;
      final errorText = result.errors.isEmpty
          ? ''
          : ' Errors: ${result.errors.length}.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Updated ${result.updatedCount} users. Skipped ${result.skippedCount} users.$errorText',
          ),
          backgroundColor: result.errors.isEmpty
              ? AppTheme.success
              : AppTheme.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Permission backfill failed: $error'),
          backgroundColor: AppTheme.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isRunning = false);
    }
  }
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

class _AddStaffSheet extends StatefulWidget {
  const _AddStaffSheet({required this.currentUser});

  final AppUserModel currentUser;

  @override
  State<_AddStaffSheet> createState() => _AddStaffSheetState();
}

class _AddStaffSheetState extends State<_AddStaffSheet> {
  final _formKey = GlobalKey<FormState>();
  final _existingFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _existingUidController = TextEditingController();
  final _existingNameController = TextEditingController();
  final _existingEmailController = TextEditingController();

  String _role = 'receptionist';
  String _existingRole = 'receptionist';
  bool _applyDefaults = true;
  bool _isCreating = false;
  bool _isRepairing = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _existingUidController.dispose();
    _existingNameController.dispose();
    _existingEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final bottomPadding = MediaQuery.viewPaddingOf(context).bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.92,
          ),
          child: ListView(
            padding: EdgeInsets.fromLTRB(18, 18, 18, 18 + bottomPadding),
            shrinkWrap: true,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: AppTheme.primarySoft,
                    child: Icon(
                      Icons.person_add_alt_1,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Staff',
                          style: TextStyle(
                            color: AppTheme.text,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Create login account and assign permissions',
                          style: TextStyle(color: AppTheme.muted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _isCreating || _isRepairing
                        ? null
                        : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Close',
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: _fieldDecoration('Full Name'),
                      textInputAction: TextInputAction.next,
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      decoration: _fieldDecoration('Email'),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: _emailValidator,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      decoration: _fieldDecoration('Temporary Password')
                          .copyWith(
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(
                                  () => _obscurePassword = !_obscurePassword,
                                );
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              tooltip: _obscurePassword ? 'Show' : 'Hide',
                            ),
                          ),
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      validator: _passwordValidator,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: _fieldDecoration('Confirm Password'),
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Passwords must match.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _role,
                      decoration: _fieldDecoration('Role'),
                      items: StaffRolesScreen._roles
                          .map(
                            (role) => DropdownMenuItem(
                              value: role,
                              child: Text(_roleLabel(role)),
                            ),
                          )
                          .toList(),
                      onChanged: _isCreating
                          ? null
                          : (role) {
                              if (role == null) return;
                              setState(() => _role = role);
                            },
                    ),
                    const SizedBox(height: 10),
                    _RoleSummary(role: _role),
                    const SizedBox(height: 10),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _applyDefaults,
                      onChanged: _isCreating
                          ? null
                          : (value) => setState(() => _applyDefaults = value),
                      title: const Text(
                        'Apply default permissions for this role',
                        style: TextStyle(
                          color: AppTheme.text,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      subtitle: const Text(
                        'Permissions can be customized after creation.',
                        style: TextStyle(color: AppTheme.muted, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _isCreating ? null : _createStaff,
                      icon: _isCreating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.person_add_alt_1, size: 18),
                      label: Text(
                        _isCreating ? 'Creating' : 'Create Staff Account',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Divider(),
              const SizedBox(height: 12),
              const Text(
                'Already created in Firebase Console?',
                style: TextStyle(
                  color: AppTheme.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Create the missing Firestore staff profile using the Auth UID.',
                style: TextStyle(color: AppTheme.muted, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Form(
                key: _existingFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _existingUidController,
                      decoration: _fieldDecoration('Auth UID'),
                      textInputAction: TextInputAction.next,
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _existingNameController,
                      decoration: _fieldDecoration('Name'),
                      textInputAction: TextInputAction.next,
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _existingEmailController,
                      decoration: _fieldDecoration('Email'),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: _emailValidator,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _existingRole,
                      decoration: _fieldDecoration('Role'),
                      items: StaffRolesScreen._roles
                          .map(
                            (role) => DropdownMenuItem(
                              value: role,
                              child: Text(_roleLabel(role)),
                            ),
                          )
                          .toList(),
                      onChanged: _isRepairing
                          ? null
                          : (role) {
                              if (role == null) return;
                              setState(() => _existingRole = role);
                            },
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _isRepairing ? null : _createExistingProfile,
                      icon: _isRepairing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.build_circle_outlined, size: 18),
                      label: Text(
                        _isRepairing
                            ? 'Creating Profile'
                            : 'Create Firestore Profile',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createStaff() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() != true) return;

    setState(() => _isCreating = true);
    try {
      await UserService.instance.createStaffAccount(
        CreateStaffInput(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          role: _role,
          applyDefaultPermissions: _applyDefaults,
          createdBy: widget.currentUser,
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Staff account created for ${_emailController.text.trim()}.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      _showError(_friendlyError(error));
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  Future<void> _createExistingProfile() async {
    FocusScope.of(context).unfocus();
    if (_existingFormKey.currentState?.validate() != true) return;

    setState(() => _isRepairing = true);
    try {
      await UserService.instance.createExistingAuthUserProfile(
        ExistingAuthProfileInput(
          uid: _existingUidController.text.trim(),
          name: _existingNameController.text.trim(),
          email: _existingEmailController.text.trim(),
          role: _existingRole,
          createdBy: widget.currentUser,
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Firestore profile created for ${_existingEmailController.text.trim()}.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      _showError(_friendlyError(error));
    } finally {
      if (mounted) setState(() => _isRepairing = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static String? _requiredValidator(String? value) {
    if ((value ?? '').trim().isEmpty) return 'Required.';
    return null;
  }

  static String? _emailValidator(String? value) {
    final email = (value ?? '').trim();
    if (email.isEmpty) return 'Email is required.';
    final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    if (!valid) return 'Enter a valid email address.';
    return null;
  }

  static String? _passwordValidator(String? value) {
    final password = value ?? '';
    if (password.length < 6) return 'Use at least 6 characters.';
    return null;
  }

  static InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: AppTheme.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.danger),
      ),
    );
  }

  static String _friendlyError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'This email already has a login account.';
        case 'invalid-email':
          return 'Enter a valid email address.';
        case 'weak-password':
          return 'Use a stronger temporary password.';
        case 'network-request-failed':
          return 'Network error. Check your internet connection and try again.';
        case 'operation-not-allowed':
          return 'Email/password sign-in is not enabled for this Firebase project.';
        case 'too-many-requests':
          return 'Too many attempts. Please wait and try again.';
        default:
          return error.message ?? 'Firebase Auth failed. Please try again.';
      }
    }

    final message = error.toString().replaceFirst('Bad state: ', '');
    return message.isEmpty
        ? 'Something went wrong. Please try again.'
        : message;
  }
}

class _RoleSummary extends StatelessWidget {
  const _RoleSummary({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    final permissions = DefaultPermissions.forRole(role);
    final enabled = permissions.values.where((value) => value).length;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primarySoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppTheme.primary,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${_roleDescription(role)} Default permissions: $enabled enabled.',
              style: const TextStyle(
                color: AppTheme.text,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _roleDescription(String role) {
    switch (role) {
      case 'admin':
        return 'Full access.';
      case 'coAdmin':
        return 'Daily operations and setup access.';
      case 'receptionist':
        return 'Admissions, fees, reminders, and lookups.';
      case 'studentHelper':
        return 'Attendance-focused access.';
      default:
        return '';
    }
  }
}

class _StaffUserCard extends StatefulWidget {
  const _StaffUserCard({
    required this.currentUser,
    required this.user,
    required this.isSelf,
    required this.lockSelfRole,
    required this.roles,
  });

  final AppUserModel currentUser;
  final AppUserModel user;
  final bool isSelf;
  final bool lockSelfRole;
  final List<String> roles;

  @override
  State<_StaffUserCard> createState() => _StaffUserCardState();
}

class _StaffUserCardState extends State<_StaffUserCard> {
  bool _isSendingReset = false;
  bool _isUpdatingStatus = false;
  bool _isUpdatingRole = false;

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    return Container(
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
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppTheme.primarySoft,
                child: Icon(Icons.person, color: AppTheme.primary),
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
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
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
              _StatusPill(status: user.status),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: widget.roles.contains(user.role)
                      ? user.role
                      : null,
                  decoration: _fieldDecoration('Role'),
                  style: const TextStyle(color: AppTheme.text),
                  items: widget.roles
                      .map(
                        (role) => DropdownMenuItem(
                          value: role,
                          child: Text(_roleLabel(role)),
                        ),
                      )
                      .toList(),
                  onChanged: widget.lockSelfRole || _isUpdatingRole
                      ? null
                      : (role) async {
                          if (role == null || role == user.role) {
                            return;
                          }
                          final messenger = ScaffoldMessenger.of(context);
                          setState(() => _isUpdatingRole = true);
                          try {
                            await UserService.instance.updateRole(
                              user.uid,
                              role,
                            );
                            if (!mounted) return;
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Role updated.'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          } catch (error) {
                            if (!mounted) return;
                            _showCardError(error);
                          } finally {
                            if (mounted) {
                              setState(() => _isUpdatingRole = false);
                            }
                          }
                        },
                ),
              ),
              const SizedBox(width: 12),
              _isUpdatingStatus
                  ? const SizedBox(
                      width: 42,
                      height: 42,
                      child: Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  : Switch(
                      value: user.isActive,
                      activeThumbColor: AppTheme.success,
                      inactiveThumbColor: AppTheme.danger,
                      onChanged: widget.isSelf ? null : _updateStatus,
                    ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PermissionEditorScreen(
                        currentUser: widget.currentUser,
                        staffUser: user,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.tune_rounded, size: 18),
                label: const Text('Permissions'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  side: const BorderSide(color: AppTheme.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _isSendingReset ? null : _sendPasswordReset,
                icon: _isSendingReset
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.mail_outline_rounded, size: 18),
                label: Text(_isSendingReset ? 'Sending' : 'Send Reset Link'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            user.permissions.isEmpty
                ? 'Default role permissions'
                : 'Custom permissions',
            style: const TextStyle(color: AppTheme.muted, fontSize: 12),
          ),
          if (widget.lockSelfRole || widget.isSelf) ...[
            const SizedBox(height: 8),
            Text(
              widget.lockSelfRole
                  ? 'Your own admin role is protected.'
                  : 'You cannot disable your own account.',
              style: const TextStyle(color: AppTheme.muted, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _updateStatus(bool isActive) async {
    setState(() => _isUpdatingStatus = true);
    try {
      await UserService.instance.updateStatus(
        widget.user.uid,
        isActive ? 'active' : 'disabled',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isActive ? 'Staff enabled.' : 'Staff disabled.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      _showCardError(error);
    } finally {
      if (mounted) setState(() => _isUpdatingStatus = false);
    }
  }

  Future<void> _sendPasswordReset() async {
    final email = widget.user.email.trim();
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

    setState(() => _isSendingReset = true);
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
      _showCardError(error);
    } finally {
      if (mounted) setState(() => _isSendingReset = false);
    }
  }

  void _showCardError(Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_friendlyCardError(error)),
        backgroundColor: AppTheme.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static String _friendlyCardError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'Email not available or invalid.';
        case 'network-request-failed':
          return 'Network error. Check your internet connection and try again.';
        case 'too-many-requests':
          return 'Too many attempts. Please wait and try again.';
        default:
          return error.message ?? 'Action failed. Please try again.';
      }
    }

    final message = error.toString().replaceFirst('Bad state: ', '');
    return message.isEmpty ? 'Action failed. Please try again.' : message;
  }

  static String _roleLabel(String role) {
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

  static InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: AppTheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primary),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final isActive = status == 'active';

    return AppStatusBadge(
      label: isActive ? 'Active' : 'Disabled',
      color: isActive ? AppTheme.success : AppTheme.danger,
      softColor: isActive ? AppTheme.successSoft : AppTheme.dangerSoft,
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppTheme.primary),
    );
  }
}
