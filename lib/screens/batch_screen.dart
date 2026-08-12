import 'dart:async';

import 'package:flutter/material.dart';

import '../core/database/database_provider.dart';
import '../data/repositories/offline_repositories.dart';
import '../data/repositories/offline_repository_contracts.dart';
import '../models/batch_model.dart';
import '../models/course_model.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';
import '../widgets/batch_card.dart';
import 'access_denied_screen.dart';

class BatchScreen extends StatefulWidget {
  const BatchScreen({super.key});

  @override
  State<BatchScreen> createState() => _BatchScreenState();
}

class _BatchScreenState extends State<BatchScreen> {
  late final BatchesRepositoryImpl _batchesRepository;
  late final CoursesRepositoryImpl _coursesRepository;

  @override
  void initState() {
    super.initState();
    final database = OfflineDatabaseProvider.instance;
    _batchesRepository = BatchesRepositoryImpl(database);
    _coursesRepository = CoursesRepositoryImpl(database);
    unawaited(_coursesRepository.requestSync());
    unawaited(_batchesRepository.requestSync());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: UserService.instance.streamCurrentUserProfile(),
      builder: (context, profileSnapshot) {
        final appUser = profileSnapshot.data;
        if (profileSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppTheme.background,
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            ),
          );
        }
        if (appUser == null ||
            !(appUser.canViewBatches || appUser.canManageBatches)) {
          return const AccessDeniedScreen();
        }
        final canManage = appUser.canManageBatches;

        return StreamBuilder<List<CourseModel>>(
          stream: _coursesRepository.watchActiveCourses(),
          initialData: const [],
          builder: (context, courseSnapshot) {
            final courses = courseSnapshot.data ?? const <CourseModel>[];
            return Scaffold(
              backgroundColor: AppTheme.background,
              appBar: AppBar(
                title: const Text(
                  'Batches Setup',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                actions: [
                  StreamBuilder<OfflineSyncSummary>(
                    stream: _batchesRepository.watchSyncSummary(),
                    initialData: OfflineSyncSummary.synced,
                    builder: (context, snapshot) {
                      return _SyncIndicator(
                        status: snapshot.data ?? OfflineSyncSummary.synced,
                        onRefresh: () =>
                            unawaited(_batchesRepository.requestSync()),
                      );
                    },
                  ),
                ],
              ),
              floatingActionButton: canManage
                  ? FloatingActionButton.extended(
                      onPressed: courses.isEmpty
                          ? null
                          : () => _showBatchForm(context, null, courses),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'New Batch',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null,
              body: SafeArea(
                top: false,
                child: StreamBuilder<List<BatchModel>>(
                  stream: _batchesRepository.watchActiveBatches(),
                  builder: (context, snapshot) {
                    final batches = snapshot.data ?? const <BatchModel>[];
                    if (batches.isEmpty) {
                      return Center(
                        child: Text(
                          courses.isEmpty
                              ? 'Create or sync courses before adding batches.'
                              : 'No active batches found.',
                          style: const TextStyle(color: AppTheme.muted),
                        ),
                      );
                    }

                    final courseNames = _courseNames(courses);
                    final bottomInset = MediaQuery.viewPaddingOf(
                      context,
                    ).bottom;
                    return ListView.builder(
                      padding: EdgeInsets.fromLTRB(
                        20,
                        10,
                        20,
                        bottomInset + 112,
                      ),
                      itemCount: batches.length,
                      itemBuilder: (context, index) {
                        final batch = batches[index];
                        return Stack(
                          children: [
                            BatchCard(
                              batch: batch.toCardMap(),
                              courseName:
                                  courseNames[batch.courseId] ??
                                  batch.courseName ??
                                  'Unknown Course',
                              onEdit: canManage
                                  ? () =>
                                        _showBatchForm(context, batch, courses)
                                  : null,
                              onDelete: canManage
                                  ? () => _confirmDelete(batch.id)
                                  : null,
                            ),
                            if (batch.hasPendingSync)
                              const Positioned(
                                right: 40,
                                top: 16,
                                child: Icon(
                                  Icons.cloud_upload_outlined,
                                  color: AppTheme.warning,
                                  size: 18,
                                ),
                              ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Map<String, String> _courseNames(List<CourseModel> courses) {
    final map = <String, String>{};
    for (final course in courses) {
      final label =
          '${course.name}  (${(course.category ?? 'GENERAL').toUpperCase()})';
      map[course.id] = label;
      if (course.legacyId != null) map[course.legacyId!] = label;
    }
    return map;
  }

  Future<void> _confirmDelete(String id) async {
    final confirm =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: AppTheme.danger),
                SizedBox(width: 10),
                Text('Archive Batch?'),
              ],
            ),
            content: const Text(
              'This batch will be removed from active lists, but past attendances will be safe.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.dangerSoft,
                  foregroundColor: AppTheme.danger,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Archive'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;
    await _batchesRepository.archiveBatch(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Batch Archived Successfully!'),
        backgroundColor: AppTheme.danger,
      ),
    );
  }

  void _showBatchForm(
    BuildContext context,
    BatchModel? existingBatch,
    List<CourseModel> courses,
  ) {
    if (courses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please create a Course first!')),
      );
      return;
    }

    final isEditing = existingBatch != null;
    final nameCtrl = TextEditingController(text: existingBatch?.name ?? '');
    var selectedCourseId =
        existingBatch?.courseId ?? _courseValue(courses.first);
    var maxStudents = existingBatch?.maxStudents ?? 20;
    var isActive = existingBatch?.isActive ?? true;
    var selectedDays = [...?existingBatch?.days];
    const allDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    var startTime = _parseTime(existingBatch?.startTime ?? '10:00:00');
    var endTime = _parseTime(existingBatch?.endTime ?? '11:00:00');
    var startDate = existingBatch?.startDate ?? DateTime.now();
    var endDate =
        existingBatch?.endDate ?? DateTime.now().add(const Duration(days: 365));
    var isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final mediaQuery = MediaQuery.of(context);
            final keyboardInset = mediaQuery.viewInsets.bottom;
            final bottomSafe = mediaQuery.viewPadding.bottom;
            return SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  keyboardInset + bottomSafe + 18,
                ),
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEditing ? 'Edit Batch' : 'Create New Batch',
                        style: const TextStyle(
                          color: AppTheme.text,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Select Course',
                        style: TextStyle(color: AppTheme.muted, fontSize: 12),
                      ),
                      const SizedBox(height: 5),
                      DropdownButtonFormField<String>(
                        initialValue: selectedCourseId,
                        style: const TextStyle(color: AppTheme.text),
                        decoration: InputDecoration(labelText: 'Course'),
                        items: courses
                            .map(
                              (course) => DropdownMenuItem(
                                value: _courseValue(course),
                                child: Text(
                                  _courseLabel(course),
                                  style: const TextStyle(fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) => setModalState(
                          () => selectedCourseId = val ?? selectedCourseId,
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: nameCtrl,
                        style: const TextStyle(color: AppTheme.text),
                        decoration: InputDecoration(
                          hintText: 'Batch Name (e.g. Morning 10AM)',
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Class Days',
                        style: TextStyle(color: AppTheme.muted, fontSize: 12),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: allDays.map((day) {
                          final isSelected = selectedDays.contains(day);
                          return InkWell(
                            onTap: () {
                              setModalState(() {
                                isSelected
                                    ? selectedDays.remove(day)
                                    : selectedDays.add(day);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.warningSoft
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.warning
                                      : AppTheme.border,
                                ),
                              ),
                              child: Text(
                                day,
                                style: TextStyle(
                                  color: isSelected
                                      ? AppTheme.warning
                                      : AppTheme.muted,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTimePicker(
                              context,
                              'Start Time',
                              startTime,
                              (time) => setModalState(() => startTime = time),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildTimePicker(
                              context,
                              'End Time',
                              endTime,
                              (time) => setModalState(() => endTime = time),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDatePicker(
                              context,
                              'Start Date',
                              startDate,
                              (date) => setModalState(() => startDate = date),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildDatePicker(
                              context,
                              'End Date',
                              endDate,
                              (date) => setModalState(() => endDate = date),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Max Students Capacity: $maxStudents',
                        style: const TextStyle(color: AppTheme.muted),
                      ),
                      Slider(
                        value: maxStudents.toDouble(),
                        min: 5,
                        max: 100,
                        divisions: 19,
                        activeColor: AppTheme.warning,
                        onChanged: (val) =>
                            setModalState(() => maxStudents = val.toInt()),
                      ),
                      SwitchListTile(
                        title: const Text(
                          'Is Active',
                          style: TextStyle(color: AppTheme.text),
                        ),
                        activeThumbColor: AppTheme.success,
                        value: isActive,
                        onChanged: (val) => setModalState(() => isActive = val),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isSaving
                              ? null
                              : () async {
                                  if (nameCtrl.text.trim().isEmpty ||
                                      selectedDays.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Name and Days are required!',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  setModalState(() => isSaving = true);
                                  final now = DateTime.now();
                                  final course = _courseByValue(
                                    courses,
                                    selectedCourseId,
                                  );
                                  final batch = BatchModel(
                                    id: existingBatch?.id ?? '',
                                    legacyId: existingBatch?.legacyId,
                                    name: nameCtrl.text.trim(),
                                    courseId: selectedCourseId,
                                    courseName: course?.name,
                                    days: selectedDays,
                                    startDate: startDate,
                                    endDate: endDate,
                                    startTime: _formatTime(startTime),
                                    endTime: _formatTime(endTime),
                                    maxStudents: maxStudents,
                                    isActive: isActive,
                                    createdAt: existingBatch?.createdAt ?? now,
                                    updatedAt: now,
                                  );
                                  if (isEditing) {
                                    await _batchesRepository.updateBatch(batch);
                                  } else {
                                    await _batchesRepository.createBatch(batch);
                                  }
                                  if (!context.mounted) return;
                                  Navigator.pop(context);
                                },
                          child: isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  isEditing ? 'Update Batch' : 'Save Batch',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _courseValue(CourseModel course) => course.legacyId ?? course.id;

  String _courseLabel(CourseModel course) =>
      '${course.name}  (${(course.category ?? 'GENERAL').toUpperCase()})';

  CourseModel? _courseByValue(List<CourseModel> courses, String value) {
    for (final course in courses) {
      if (course.id == value || course.legacyId == value) return course;
    }
    return null;
  }

  Widget _buildTimePicker(
    BuildContext context,
    String label,
    TimeOfDay time,
    ValueChanged<TimeOfDay> onSelected,
  ) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (picked != null) onSelected(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        decoration: BoxDecoration(
          color: AppTheme.primarySoft,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: AppTheme.muted, fontSize: 10),
            ),
            const SizedBox(height: 4),
            Text(
              time.format(context),
              style: const TextStyle(
                color: AppTheme.warning,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(
    BuildContext context,
    String label,
    DateTime date,
    ValueChanged<DateTime> onSelected,
  ) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) onSelected(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        decoration: BoxDecoration(
          color: AppTheme.primarySoft,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: AppTheme.muted, fontSize: 10),
            ),
            const SizedBox(height: 4),
            Text(
              '${date.day}/${date.month}/${date.year}',
              style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  TimeOfDay _parseTime(String timeString) {
    final parts = timeString.split(':');
    final hour = int.tryParse(parts.first) ?? 10;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
}

class _SyncIndicator extends StatelessWidget {
  const _SyncIndicator({required this.status, required this.onRefresh});

  final OfflineSyncSummary status;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      OfflineSyncSummary.synced => 'Synced',
      OfflineSyncSummary.syncing => 'Syncing...',
      OfflineSyncSummary.pending => 'Pending sync',
      OfflineSyncSummary.failed => 'Sync failed',
    };
    final color = switch (status) {
      OfflineSyncSummary.synced => AppTheme.success,
      OfflineSyncSummary.syncing => AppTheme.primary,
      OfflineSyncSummary.pending => AppTheme.warning,
      OfflineSyncSummary.failed => AppTheme.danger,
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        IconButton(
          tooltip: 'Sync batches',
          onPressed: onRefresh,
          icon: Icon(Icons.sync_rounded, color: color),
        ),
      ],
    );
  }
}
