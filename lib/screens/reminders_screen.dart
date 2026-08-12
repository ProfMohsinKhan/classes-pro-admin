import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/app_user_model.dart';
import '../models/reminder_model.dart';
import '../services/institute_settings_service.dart';
import '../services/reminder_service.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';
import 'access_denied_screen.dart';
import 'fees_screen.dart';

enum ReminderTabFilter { all, birthday, feeDue, general, done }

enum ReminderDateFilter { all, today, thisWeek, upcoming }

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key, this.initialTab = ReminderTabFilter.all});

  final ReminderTabFilter initialTab;

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  late final Stream<AppUserModel?> _profileStream;
  final ReminderService _service = ReminderService();
  ReminderTabFilter _tab = ReminderTabFilter.all;
  ReminderDateFilter _dateFilter = ReminderDateFilter.all;
  bool _isLoading = true;
  String _search = '';
  String? _error;
  String _instituteName = 'Mak Tutorials';
  String _defaultCountryCode = '91';
  List<ReminderModel> _reminders = const [];
  List<ReminderStudentOption> _students = const [];
  final Set<String> _busyIds = {};

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
    _profileStream = UserService.instance.streamCurrentUserProfile();
    _loadData();
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
        if (appUser == null || !appUser.canViewReminders) {
          return const AccessDeniedScreen();
        }

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            title: const Text(
              'Reminders',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            actions: [
              IconButton(
                tooltip: 'Refresh',
                onPressed: _isLoading ? null : _loadData,
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          floatingActionButton: appUser.canCreateReminders
              ? FloatingActionButton.extended(
                  onPressed: () => _showReminderSheet(appUser),
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('New Reminder'),
                )
              : null,
          body: SafeArea(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 92),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Header(),
                        const SizedBox(height: 16),
                        _SummaryCards(reminders: _reminders),
                        const SizedBox(height: 16),
                        _TabChips(
                          selected: _tab,
                          onChanged: (tab) => setState(() => _tab = tab),
                        ),
                        const SizedBox(height: 12),
                        _SearchAndDateFilter(
                          search: _search,
                          selectedDateFilter: _dateFilter,
                          onSearchChanged: (value) => setState(
                            () => _search = value.trim().toLowerCase(),
                          ),
                          onDateFilterChanged: (value) =>
                              setState(() => _dateFilter = value),
                        ),
                        const SizedBox(height: 16),
                        if (_error != null)
                          _StateCard(
                            icon: Icons.cloud_off_rounded,
                            title: 'Reminders could not be loaded.',
                            subtitle: _error!,
                          )
                        else if (_visibleReminders.isEmpty)
                          const _StateCard(
                            icon: Icons.notifications_none_rounded,
                            title: 'No reminders found.',
                            subtitle:
                                'Try another tab or create a general reminder.',
                          )
                        else
                          ..._visibleReminders.map(
                            (reminder) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _ReminderCard(
                                reminder: reminder,
                                isBusy: _busyIds.contains(reminder.id),
                                canDelete: appUser.canDeleteReminders,
                                canEdit:
                                    appUser.canEditReminders &&
                                    reminder.type == ReminderType.general,
                                onCall: () => _call(reminder),
                                onWhatsApp: () => _whatsApp(reminder),
                                onDone: appUser.canEditReminders
                                    ? () => _markDone(reminder)
                                    : null,
                                onDismiss: appUser.canEditReminders
                                    ? () => _dismiss(reminder)
                                    : null,
                                onEdit: () => _showReminderSheet(
                                  appUser,
                                  reminder: reminder,
                                ),
                                onDelete: () => _delete(reminder),
                                onCollectFee:
                                    reminder.type == ReminderType.feeDue
                                    ? () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const FeesScreen(),
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  List<ReminderModel> get _visibleReminders {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final weekEnd = todayOnly.add(const Duration(days: 7));
    return _reminders.where((reminder) {
      final matchesTab = switch (_tab) {
        ReminderTabFilter.all => !reminder.isDone && !reminder.isDismissed,
        ReminderTabFilter.birthday =>
          reminder.type == ReminderType.birthday && !reminder.isDismissed,
        ReminderTabFilter.feeDue =>
          reminder.type == ReminderType.feeDue && !reminder.isDismissed,
        ReminderTabFilter.general =>
          reminder.type == ReminderType.general && !reminder.isDismissed,
        ReminderTabFilter.done => reminder.isDone,
      };
      if (!matchesTab) return false;
      final query = _search;
      if (query.isNotEmpty) {
        final haystack =
            '${reminder.title} ${reminder.description} ${reminder.studentName ?? ''}'
                .toLowerCase();
        if (!haystack.contains(query)) return false;
      }
      final due = DateTime(
        reminder.dueDate.year,
        reminder.dueDate.month,
        reminder.dueDate.day,
      );
      return switch (_dateFilter) {
        ReminderDateFilter.all => true,
        ReminderDateFilter.today => _isSameDay(due, todayOnly),
        ReminderDateFilter.thisWeek =>
          !due.isBefore(todayOnly) && !due.isAfter(weekEnd),
        ReminderDateFilter.upcoming =>
          !due.isBefore(todayOnly) &&
              !due.isAfter(todayOnly.add(const Duration(days: 30))),
      };
    }).toList()..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _service.loadReminders(),
        _service.loadStudentOptions(),
        InstituteSettingsService.instance.loadSettings(),
      ]);
      final settings = InstituteSettingsService.instance.cachedOrDefault;
      if (!mounted) return;
      setState(() {
        _reminders = results[0] as List<ReminderModel>;
        _students = results[1] as List<ReminderStudentOption>;
        _instituteName = settings.instituteName.trim().isEmpty
            ? 'Mak Tutorials'
            : settings.instituteName.trim();
        _defaultCountryCode = settings.defaultCountryCode.replaceAll(
          RegExp(r'[^0-9]'),
          '',
        );
        if (_defaultCountryCode.isEmpty) _defaultCountryCode = '91';
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _markDone(ReminderModel reminder) async {
    final updated = reminder.copyWith(
      status: ReminderStatus.done,
      completedAt: DateTime.now(),
    );
    _replaceLocal(updated);
    await _runCardAction(reminder.id, () => _service.markDone(reminder.id));
  }

  Future<void> _dismiss(ReminderModel reminder) async {
    final updated = reminder.copyWith(
      status: ReminderStatus.dismissed,
      dismissedAt: DateTime.now(),
    );
    _replaceLocal(updated);
    await _runCardAction(
      reminder.id,
      () => _service.dismissReminder(reminder.id),
    );
  }

  Future<void> _delete(ReminderModel reminder) async {
    setState(
      () => _reminders = _reminders
          .where((item) => item.id != reminder.id)
          .toList(),
    );
    await _runCardAction(
      reminder.id,
      () => _service.deleteReminder(reminder.id),
    );
  }

  Future<void> _runCardAction(String id, Future<void> Function() action) async {
    setState(() => _busyIds.add(id));
    try {
      await action();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reminder update failed: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _busyIds.remove(id));
    }
  }

  void _replaceLocal(ReminderModel reminder) {
    setState(() {
      _reminders = _reminders
          .map((item) => item.id == reminder.id ? reminder : item)
          .toList();
    });
  }

  Future<void> _call(ReminderModel reminder) async {
    final phone = _phone(reminder);
    if (phone == null) return _missingPhone();
    final uri = Uri.parse('tel:$phone');
    if (!await launchUrl(uri)) _missingPhone();
  }

  Future<void> _whatsApp(ReminderModel reminder) async {
    final phone = _phone(reminder);
    if (phone == null) return _missingPhone();
    final message = switch (reminder.type) {
      ReminderType.birthday => 'Happy Birthday from $_instituteName!',
      ReminderType.feeDue =>
        'Dear Parent, this is a reminder from $_instituteName regarding pending fees of Rs ${reminder.amount?.toStringAsFixed(0) ?? ''}.',
      ReminderType.general => reminder.description,
    };
    final uri = Uri.parse(
      'https://wa.me/$phone?text=${Uri.encodeComponent(message)}',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _missingPhone();
    }
  }

  String? _phone(ReminderModel reminder) {
    final raw = (reminder.parentPhone ?? reminder.studentPhone ?? '')
        .replaceAll(RegExp(r'[^0-9]'), '');
    if (raw.length < 10) return null;
    return raw.length == 10 ? '$_defaultCountryCode$raw' : raw;
  }

  void _missingPhone() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Phone number not available.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _showReminderSheet(
    AppUserModel appUser, {
    ReminderModel? reminder,
  }) async {
    final saved = await showModalBottomSheet<ReminderModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _ReminderFormSheet(
        appUser: appUser,
        service: _service,
        students: _students,
        reminder: reminder,
      ),
    );
    if (saved == null) return;
    setState(() {
      final exists = _reminders.any((item) => item.id == saved.id);
      _reminders = exists
          ? _reminders
                .map((item) => item.id == saved.id ? saved : item)
                .toList()
          : [saved, ..._reminders];
    });
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reminders',
          style: TextStyle(
            color: AppTheme.text,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Birthdays, fees and follow-ups',
          style: TextStyle(color: AppTheme.muted),
        ),
      ],
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.reminders});

  final List<ReminderModel> reminders;

  @override
  Widget build(BuildContext context) {
    final pending = reminders.where((item) => item.isPending).length;
    final data = [
      (
        'Birthdays',
        reminders
            .where(
              (item) => item.type == ReminderType.birthday && item.isPending,
            )
            .length,
        AppTheme.primary,
      ),
      (
        'Fee Due',
        reminders
            .where((item) => item.type == ReminderType.feeDue && item.isPending)
            .length,
        AppTheme.warning,
      ),
      (
        'General',
        reminders
            .where(
              (item) => item.type == ReminderType.general && item.isPending,
            )
            .length,
        AppTheme.success,
      ),
      ('Pending', pending, AppTheme.danger),
    ];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: data.map((item) {
        return SizedBox(
          width: 150,
          child: _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.notifications_active_rounded, color: item.$3),
                const SizedBox(height: 8),
                Text(
                  '${item.$2}',
                  style: const TextStyle(
                    color: AppTheme.text,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(item.$1, style: const TextStyle(color: AppTheme.muted)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _TabChips extends StatelessWidget {
  const _TabChips({required this.selected, required this.onChanged});

  final ReminderTabFilter selected;
  final ValueChanged<ReminderTabFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final labels = {
      ReminderTabFilter.all: 'All',
      ReminderTabFilter.birthday: 'Birthdays',
      ReminderTabFilter.feeDue: 'Fee Due',
      ReminderTabFilter.general: 'General',
      ReminderTabFilter.done: 'Done',
    };
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: labels.entries.map((entry) {
        final isSelected = selected == entry.key;
        return ChoiceChip(
          label: Text(entry.value),
          selected: isSelected,
          selectedColor: AppTheme.primary,
          backgroundColor: AppTheme.surface,
          side: const BorderSide(color: AppTheme.border),
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : AppTheme.text,
            fontWeight: FontWeight.w800,
          ),
          onSelected: (_) => onChanged(entry.key),
        );
      }).toList(),
    );
  }
}

class _SearchAndDateFilter extends StatelessWidget {
  const _SearchAndDateFilter({
    required this.search,
    required this.selectedDateFilter,
    required this.onSearchChanged,
    required this.onDateFilterChanged,
  });

  final String search;
  final ReminderDateFilter selectedDateFilter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<ReminderDateFilter> onDateFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          onChanged: onSearchChanged,
          decoration: const InputDecoration(
            hintText: 'Search student or reminder',
            prefixIcon: Icon(Icons.search_rounded, color: AppTheme.muted),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              {
                ReminderDateFilter.all: 'All Dates',
                ReminderDateFilter.today: 'Today',
                ReminderDateFilter.thisWeek: 'This Week',
                ReminderDateFilter.upcoming: 'Upcoming',
              }.entries.map((entry) {
                final isSelected = selectedDateFilter == entry.key;
                return FilterChip(
                  label: Text(entry.value),
                  selected: isSelected,
                  selectedColor: AppTheme.primary.withValues(alpha: 0.14),
                  checkmarkColor: AppTheme.primary,
                  onSelected: (_) => onDateFilterChanged(entry.key),
                );
              }).toList(),
        ),
      ],
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({
    required this.reminder,
    required this.isBusy,
    required this.canDelete,
    required this.canEdit,
    required this.onCall,
    required this.onWhatsApp,
    required this.onDone,
    required this.onDismiss,
    required this.onEdit,
    required this.onDelete,
    this.onCollectFee,
  });

  final ReminderModel reminder;
  final bool isBusy;
  final bool canDelete;
  final bool canEdit;
  final VoidCallback onCall;
  final VoidCallback onWhatsApp;
  final VoidCallback? onDone;
  final VoidCallback? onDismiss;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onCollectFee;

  @override
  Widget build(BuildContext context) {
    final typeColor = switch (reminder.type) {
      ReminderType.birthday => AppTheme.primary,
      ReminderType.feeDue => AppTheme.warning,
      ReminderType.general => AppTheme.success,
    };
    final icon = switch (reminder.type) {
      ReminderType.birthday => Icons.cake_rounded,
      ReminderType.feeDue => Icons.currency_rupee_rounded,
      ReminderType.general => Icons.notifications_rounded,
    };

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: typeColor.withValues(alpha: 0.12),
                child: Icon(icon, color: typeColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.title,
                      style: const TextStyle(
                        color: AppTheme.text,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if ((reminder.studentName ?? '').isNotEmpty)
                      Text(
                        reminder.studentName!,
                        style: const TextStyle(color: AppTheme.muted),
                      ),
                  ],
                ),
              ),
              _Badge(
                label: reminder.status.name,
                color: _statusColor(reminder.status),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            reminder.description,
            style: const TextStyle(color: AppTheme.text),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Badge(
                label: DateFormat('dd MMM yyyy').format(reminder.dueDate),
                color: AppTheme.primary,
              ),
              _Badge(
                label: reminder.priority.name,
                color: _priorityColor(reminder.priority),
              ),
              if (reminder.amount != null)
                _Badge(
                  label: 'Rs ${reminder.amount!.toStringAsFixed(0)}',
                  color: AppTheme.warning,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _IconAction(
                icon: Icons.call_rounded,
                label: 'Call',
                onTap: onCall,
              ),
              _IconAction(
                icon: Icons.chat_rounded,
                label: 'WhatsApp',
                onTap: onWhatsApp,
              ),
              if (onCollectFee != null)
                _IconAction(
                  icon: Icons.payments_rounded,
                  label: 'Collect Fee',
                  onTap: onCollectFee!,
                ),
              if (canEdit)
                _IconAction(
                  icon: Icons.edit_rounded,
                  label: 'Edit',
                  onTap: onEdit,
                ),
              if (reminder.isPending && onDone != null)
                _IconAction(
                  icon: Icons.check_rounded,
                  label: 'Done',
                  onTap: isBusy ? null : onDone,
                ),
              if (reminder.isPending && onDismiss != null)
                _IconAction(
                  icon: Icons.close_rounded,
                  label: 'Dismiss',
                  onTap: isBusy ? null : onDismiss,
                ),
              if (canDelete)
                _IconAction(
                  icon: Icons.delete_outline_rounded,
                  label: 'Delete',
                  onTap: isBusy ? null : onDelete,
                ),
              if (isBusy)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        ],
      ),
    );
  }

  static Color _statusColor(ReminderStatus status) {
    return switch (status) {
      ReminderStatus.done => AppTheme.success,
      ReminderStatus.dismissed => AppTheme.muted,
      ReminderStatus.pending => AppTheme.warning,
    };
  }

  static Color _priorityColor(ReminderPriority priority) {
    return switch (priority) {
      ReminderPriority.high => AppTheme.danger,
      ReminderPriority.low => AppTheme.muted,
      ReminderPriority.normal => AppTheme.primary,
    };
  }
}

class _ReminderFormSheet extends StatefulWidget {
  const _ReminderFormSheet({
    required this.appUser,
    required this.service,
    required this.students,
    this.reminder,
  });

  final AppUserModel appUser;
  final ReminderService service;
  final List<ReminderStudentOption> students;
  final ReminderModel? reminder;

  @override
  State<_ReminderFormSheet> createState() => _ReminderFormSheetState();
}

class _ReminderFormSheetState extends State<_ReminderFormSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  DateTime _dueDate = DateTime.now();
  ReminderPriority _priority = ReminderPriority.normal;
  ReminderStudentOption? _student;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final reminder = widget.reminder;
    _titleController = TextEditingController(text: reminder?.title ?? '');
    _descriptionController = TextEditingController(
      text: reminder?.description ?? '',
    );
    _dueDate = reminder?.dueDate ?? DateTime.now();
    _priority = reminder?.priority ?? ReminderPriority.normal;
    if (reminder?.studentId != null) {
      for (final option in widget.students) {
        if (option.id == reminder!.studentId) _student = option;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.reminder == null ? 'New Reminder' : 'Edit Reminder',
              style: const TextStyle(
                color: AppTheme.text,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ReminderStudentOption?>(
              initialValue: _student,
              decoration: const InputDecoration(
                labelText: 'Student (optional)',
              ),
              items: [
                const DropdownMenuItem<ReminderStudentOption?>(
                  value: null,
                  child: Text('No student'),
                ),
                ...widget.students.map(
                  (student) => DropdownMenuItem<ReminderStudentOption?>(
                    value: student,
                    child: Text(student.name),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _student = value),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ReminderPriority>(
              initialValue: _priority,
              decoration: const InputDecoration(labelText: 'Priority'),
              items: ReminderPriority.values
                  .map(
                    (priority) => DropdownMenuItem(
                      value: priority,
                      child: Text(priority.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => _priority = value ?? ReminderPriority.normal),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(14),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Due Date',
                  prefixIcon: Icon(Icons.calendar_month_rounded),
                ),
                child: Text(
                  DateFormat('dd MMM yyyy').format(_dueDate),
                  style: const TextStyle(color: AppTheme.text),
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save_rounded),
                label: const Text('Save Reminder'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Title is required.')));
      return;
    }
    setState(() => _isSaving = true);
    try {
      final existing = widget.reminder;
      if (existing == null) {
        final created = await widget.service.createReminder(
          title: title,
          description: _descriptionController.text.trim(),
          dueDate: _dueDate,
          priority: _priority,
          appUser: widget.appUser,
          student: _student,
        );
        if (mounted) Navigator.pop(context, created);
      } else {
        final updated = existing.copyWith(
          title: title,
          description: _descriptionController.text.trim(),
          dueDate: _dueDate,
          priority: _priority,
          studentId: _student?.id,
          studentName: _student?.name,
          studentPhone: _student?.studentPhone,
          parentPhone: _student?.parentPhone,
        );
        await widget.service.updateReminder(updated);
        if (mounted) Navigator.pop(context, updated);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.primary,
        side: const BorderSide(color: AppTheme.border),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 28),
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
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: AppTheme.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
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
      child: child,
    );
  }
}
