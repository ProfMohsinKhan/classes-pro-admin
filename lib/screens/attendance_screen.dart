import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../core/database/database_provider.dart';
import '../data/repositories/offline_repositories.dart';
import '../data/repositories/offline_repository_contracts.dart';
import '../models/app_user_model.dart';
import '../models/attendance_model.dart';
import '../models/batch_model.dart';
import '../models/student_model.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';
import '../widgets/attendance_card.dart';
import 'access_denied_screen.dart';

enum _AttendanceViewMode { list, grid }

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime _selectedDate = _dateOnly(DateTime.now());
  _BatchFilter? _selectedBatch;
  _AttendanceViewMode _viewMode = _AttendanceViewMode.list;
  late final Stream<AppUserModel?> _profileStream;
  late final StudentsRepository _studentsRepository;
  late final BatchesRepository _batchesRepository;
  late final AttendanceRepository _attendanceRepository;
  StreamSubscription<List<StudentModel>>? _studentsSubscription;
  StreamSubscription<List<BatchModel>>? _batchesSubscription;
  StreamSubscription<AttendanceDayData>? _attendanceSubscription;
  StreamSubscription<OfflineSyncSummary>? _syncSubscription;
  _AttendanceLoadData? _data;
  String? _loadError;
  bool _isLoading = true;
  bool _isAttendanceLoading = false;
  bool _isSaving = false;
  OfflineSyncSummary _syncSummary = OfflineSyncSummary.synced;
  bool _isControlPanelExpanded = false;
  List<_BatchFilter> _batches = const [];
  List<_StudentAttendanceItem> _allStudents = const [];
  List<AttendanceModel> _savedRecords = const [];

  final Map<String, String> _attendanceDraft = {};
  final Map<String, String> _savedAttendance = {};

  @override
  void initState() {
    super.initState();
    _profileStream = UserService.instance.streamCurrentUserProfile();
    final database = OfflineDatabaseProvider.instance;
    _studentsRepository = OfflineStudentsRepository(database);
    _batchesRepository = BatchesRepositoryImpl(database);
    _attendanceRepository = OfflineAttendanceRepository(database);
    _startLocalStreams();
  }

  @override
  void dispose() {
    _studentsSubscription?.cancel();
    _batchesSubscription?.cancel();
    _attendanceSubscription?.cancel();
    _syncSubscription?.cancel();
    super.dispose();
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
        if (appUser == null || !appUser.canViewAttendance) {
          return const AccessDeniedScreen();
        }
        final canEditAttendance =
            appUser.canMarkAttendance &&
            (_isToday(_selectedDate) || appUser.canEditPastAttendance);

        final data = _data;
        final markedCount = data == null
            ? 0
            : data.students
                  .where((student) => _draftStatus(student.key) != null)
                  .length;

        return PopScope(
          canPop: !_isDirty,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop || !_isDirty) return;
            final discard = await _confirmDiscardChanges();
            if (!discard || !context.mounted) return;
            Navigator.pop(context);
          },
          child: Scaffold(
            backgroundColor: AppTheme.background,
            appBar: AppBar(
              title: const Text(
                'Attendance',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              actions: [
                IconButton(
                  tooltip: _syncLabel(_syncSummary),
                  onPressed: _isSaving
                      ? null
                      : () => unawaited(_manualSyncSelectedDate()),
                  icon: Icon(
                    _syncIcon(_syncSummary),
                    color: _syncColor(_syncSummary),
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(child: _buildBody(appUser, canEditAttendance)),
                  _SaveBar(
                    isSaving: _isSaving,
                    markedCount: markedCount,
                    totalCount: data?.students.length ?? 0,
                    onSave:
                        !canEditAttendance ||
                            data == null ||
                            data.students.isEmpty ||
                            _isAttendanceLoading
                        ? null
                        : () => _saveAttendance(appUser, data),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(AppUserModel appUser, bool canEditAttendance) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      );
    }

    final data = _data;
    if (_loadError != null || data == null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(
              selectedDate: _selectedDate,
              selectedBatchName: _selectedBatch?.name,
            ),
            const SizedBox(height: 16),
            const _StateCard(
              icon: Icons.error_outline_rounded,
              title: 'Attendance data could not be loaded.',
              subtitle: 'Please retry sync or check the local database.',
            ),
          ],
        ),
      );
    }

    final summary = _AttendanceSummary.fromDraft(data, _draftStatus);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ControlPanel(
            selectedDate: _selectedDate,
            selectedBatch: _selectedBatch,
            batches: data.batches,
            summary: summary,
            lastSavedAt: data.lastSavedAt,
            isExpanded: _isControlPanelExpanded,
            onToggleExpanded: () {
              HapticFeedback.selectionClick();
              setState(
                () => _isControlPanelExpanded = !_isControlPanelExpanded,
              );
            },
            onPrevious: () => unawaited(
              _changeDate(_selectedDate.subtract(const Duration(days: 1))),
            ),
            onNext: _isToday(_selectedDate)
                ? null
                : () => unawaited(
                    _changeDate(_selectedDate.add(const Duration(days: 1))),
                  ),
            onPick: _pickDate,
            onChanged: (batch) async {
              if (!await _canDiscardDirtyDraft()) return;
              HapticFeedback.selectionClick();
              setState(() => _selectedBatch = batch);
              _switchAttendanceSubscription();
              _requestAttendanceContextSync();
            },
            canEditAttendance: canEditAttendance,
            onPresentAll: () => _markAll(data, AttendanceStatus.present),
            onAbsentAll: () => _markAll(data, AttendanceStatus.absent),
            onLeaveAll: () => _markAll(data, AttendanceStatus.leave),
            onReset: _resetDraftFromSaved,
          ),
          if (!canEditAttendance) ...[
            const SizedBox(height: 12),
            _StateCard(
              icon: Icons.lock_outline_rounded,
              title: appUser.canMarkAttendance
                  ? 'Past attendance is read-only.'
                  : 'Attendance marking is read-only.',
              subtitle: appUser.canMarkAttendance
                  ? 'You do not have permission to edit past attendance.'
                  : 'You do not have permission to mark attendance.',
            ),
          ],
          const SizedBox(height: 18),
          _StudentListHeader(
            count: data.students.length,
            mode: _viewMode,
            onModeChanged: (mode) {
              debugPrint('Attendance: view toggle only');
              HapticFeedback.selectionClick();
              setState(() => _viewMode = mode);
            },
          ),
          const SizedBox(height: 12),
          if (_isAttendanceLoading)
            const _StateCard(
              icon: Icons.hourglass_top_rounded,
              title: 'Loading attendance for selected date...',
              subtitle: 'Student controls will stay ready.',
            )
          else if (data.students.isEmpty)
            const _StateCard(
              icon: Icons.groups_2_rounded,
              title: 'No students found',
              subtitle: 'Choose another batch or add enrollments first.',
            )
          else if (_viewMode == _AttendanceViewMode.list)
            _buildListView(data, canEditAttendance)
          else
            _buildGridView(data, canEditAttendance),
          const SizedBox(height: 10),
          _HistoryCard(lastSavedAt: data.lastSavedAt),
        ],
      ),
    );
  }

  Widget _buildListView(_AttendanceLoadData data, bool canEditAttendance) {
    return Column(
      children: data.students
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AttendanceCard(
                student: item.student,
                status: _draftStatus(item.key),
                onStatusChanged: canEditAttendance
                    ? (status) => _updateDraft(item.key, status)
                    : null,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildGridView(_AttendanceLoadData data, bool canEditAttendance) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 560 ? 2 : 3;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: data.students.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 190,
          ),
          itemBuilder: (context, index) {
            final item = data.students[index];
            return _PhotoAttendanceCard(
              student: item.student,
              status: _draftStatus(item.key),
              onTap: canEditAttendance ? () => _cycleStatus(item.key) : null,
            );
          },
        );
      },
    );
  }

  void _startLocalStreams() {
    debugPrint('OfflineAttendance: loaded date ${_dateKey(_selectedDate)}');
    _studentsSubscription = _studentsRepository.watchActiveStudents().listen(
      (students) {
        final items =
            students
                .map(
                  (student) => _StudentAttendanceItem(
                    key: _studentAttendanceKey(student),
                    student: student,
                  ),
                )
                .toList()
              ..sort(
                (a, b) => a.student.displayName.toLowerCase().compareTo(
                  b.student.displayName.toLowerCase(),
                ),
              );
        if (!mounted) return;
        setState(() {
          _allStudents = items;
          _isLoading = false;
        });
        _rebuildDataFromLocal();
      },
      onError: (Object error) {
        if (!mounted) return;
        setState(() {
          _loadError = error.toString();
          _isLoading = false;
        });
      },
    );
    _batchesSubscription = _batchesRepository.watchActiveBatches().listen((
      batches,
    ) {
      if (!mounted) return;
      setState(() {
        _batches = batches.map(_BatchFilter.fromModel).toList();
        if (_selectedBatch != null &&
            !_batches.any((batch) => batch.id == _selectedBatch!.id)) {
          _selectedBatch = null;
          _switchAttendanceSubscription();
        }
      });
      _rebuildDataFromLocal();
    });
    _syncSubscription = _attendanceRepository.watchSyncSummary().listen((
      summary,
    ) {
      if (!mounted) return;
      setState(() => _syncSummary = summary);
    });
    _switchAttendanceSubscription();
    _requestAttendanceContextSync();
  }

  void _switchAttendanceSubscription() {
    final dateKey = _dateKey(_selectedDate);
    debugPrint('OfflineAttendance: loaded date $dateKey');
    _attendanceSubscription?.cancel();
    if (mounted) {
      setState(() {
        _isAttendanceLoading = true;
        _loadError = null;
      });
    }
    _attendanceSubscription = _attendanceRepository
        .watchAttendance(dateKey, batchId: _selectedBatch?.id)
        .listen(
          (dayData) {
            if (!mounted) return;
            setState(() {
              _savedRecords = dayData.records;
              _isAttendanceLoading = false;
            });
            _rebuildDataFromLocal();
          },
          onError: (Object error) {
            if (!mounted) return;
            setState(() {
              _loadError = error.toString();
              _isAttendanceLoading = false;
            });
          },
        );
  }

  void _rebuildDataFromLocal() {
    final students = _studentsForSelection();
    final savedByStudent = <String, String>{};
    DateTime? lastSavedAt;

    for (final item in students) {
      final record = _savedRecordForStudent(item);
      if (record == null) continue;
      savedByStudent[item.key] = record.status.name;
      final updatedAt = record.updatedAt ?? record.createdAt;
      if (updatedAt != null &&
          (lastSavedAt == null || updatedAt.isAfter(lastSavedAt))) {
        lastSavedAt = updatedAt;
      }
    }

    if (!mounted) return;
    final shouldHydrateDraft = !_isDirty;
    setState(() {
      _data = _AttendanceLoadData(
        batches: _batches,
        students: students,
        savedStatusNames: savedByStudent,
        lastSavedAt: lastSavedAt,
      );
      _savedAttendance
        ..clear()
        ..addAll(savedByStudent);
      if (shouldHydrateDraft) {
        _attendanceDraft
          ..clear()
          ..addAll(savedByStudent);
      }
    });
  }

  Future<void> _manualSyncSelectedDate() async {
    await Future.wait([
      _studentsRepository.requestSync(),
      _batchesRepository.requestSync(),
    ]);
    await _attendanceRepository.syncAttendanceForDate(_selectedDate);
  }

  void _requestAttendanceContextSync() {
    unawaited(_studentsRepository.requestSync());
    unawaited(_batchesRepository.requestSync());
    unawaited(_attendanceRepository.syncAttendanceForDate(_selectedDate));
  }

  List<_StudentAttendanceItem> _studentsForSelection() {
    final allItems = _allStudents;
    final selectedBatch = _selectedBatch;
    if (selectedBatch == null) return allItems;

    final fromStudentFields = allItems.where((item) {
      final data = item.student;
      final batchId = data.batchId?.trim();
      final batchName = data.batchName?.trim().toLowerCase();
      return batchId == selectedBatch.id ||
          batchName == selectedBatch.name.toLowerCase();
    }).toList();
    return fromStudentFields..sort(
      (a, b) => a.student.displayName.toLowerCase().compareTo(
        b.student.displayName.toLowerCase(),
      ),
    );
  }

  bool get _isDirty {
    if (_attendanceDraft.length != _savedAttendance.length) return true;
    for (final entry in _attendanceDraft.entries) {
      if (_savedAttendance[entry.key] != entry.value) return true;
    }
    return false;
  }

  Future<bool> _canDiscardDirtyDraft() async {
    if (!_isDirty) return true;
    return _confirmDiscardChanges();
  }

  Future<bool> _confirmDiscardChanges() async {
    final discard =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppTheme.surface,
            title: const Text('Discard unsaved attendance?'),
            content: const Text('Attendance changes are not saved yet.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Keep Editing'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Discard'),
              ),
            ],
          ),
        ) ??
        false;
    if (discard) {
      setState(() {
        _attendanceDraft
          ..clear()
          ..addAll(_savedAttendance);
      });
    }
    return discard;
  }

  String _studentAttendanceKey(StudentModel student) {
    return student.numericId?.toString() ?? student.id;
  }

  Set<String> _studentAttendanceAliases(StudentModel student) {
    return {
      student.id,
      student.studentId,
      if (student.numericId != null) student.numericId.toString(),
    }.map((value) => value.trim()).where((value) => value.isNotEmpty).toSet();
  }

  AttendanceModel? _savedRecordForStudent(_StudentAttendanceItem item) {
    final aliases = _studentAttendanceAliases(item.student);
    AttendanceModel? newest;
    DateTime? newestAt;
    for (final record in _savedRecords) {
      if (!aliases.contains(record.studentId.trim())) continue;
      final updatedAt =
          record.updatedAt ??
          record.createdAt ??
          DateTime.fromMillisecondsSinceEpoch(0);
      if (newest == null || updatedAt.isAfter(newestAt!)) {
        newest = record;
        newestAt = updatedAt;
      }
    }
    return newest;
  }

  String _studentIdForAttendanceSave(_StudentAttendanceItem item) {
    final existing = _savedRecordForStudent(item);
    final existingStudentId = existing?.studentId.trim();
    if (existingStudentId != null && existingStudentId.isNotEmpty) {
      return existingStudentId;
    }
    return item.key;
  }

  AttendanceStatus? _draftStatus(String studentKey) {
    final value = _attendanceDraft[studentKey];
    return value == null ? null : AttendanceModel.parseStatus(value);
  }

  void _updateDraft(String studentKey, AttendanceStatus status) {
    debugPrint('Attendance: local mark $studentKey -> ${status.name}');
    HapticFeedback.selectionClick();
    setState(() => _attendanceDraft[studentKey] = status.name);
  }

  void _cycleStatus(String studentKey) {
    final current = _draftStatus(studentKey);
    final next = switch (current) {
      null => AttendanceStatus.present,
      AttendanceStatus.present => AttendanceStatus.absent,
      AttendanceStatus.absent => AttendanceStatus.late,
      AttendanceStatus.late => AttendanceStatus.leave,
      AttendanceStatus.leave => AttendanceStatus.present,
    };
    _updateDraft(studentKey, next);
  }

  void _markAll(_AttendanceLoadData data, AttendanceStatus status) {
    debugPrint('Attendance: local mark all -> ${status.name}');
    HapticFeedback.mediumImpact();
    setState(() {
      for (final student in data.students) {
        _attendanceDraft[student.key] = status.name;
      }
    });
  }

  void _resetDraftFromSaved() {
    final data = _data;
    if (data == null) return;
    HapticFeedback.selectionClick();
    setState(() {
      _attendanceDraft
        ..clear()
        ..addAll(_savedAttendance);
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primary,
              onPrimary: Colors.white,
              surface: AppTheme.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) await _changeDate(picked);
  }

  Future<void> _changeDate(DateTime date) async {
    if (!await _canDiscardDirtyDraft()) return;
    debugPrint('Attendance: date changed to ${_dateKey(date)}');
    HapticFeedback.selectionClick();
    setState(() => _selectedDate = _dateOnly(date));
    _switchAttendanceSubscription();
    _requestAttendanceContextSync();
  }

  Future<void> _saveAttendance(
    AppUserModel appUser,
    _AttendanceLoadData data,
  ) async {
    final changedStudents = data.students
        .where(
          (student) =>
              _attendanceDraft[student.key] != _savedAttendance[student.key],
        )
        .toList();

    if (changedStudents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No attendance changes to save.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      debugPrint(
        'OfflineAttendance: saving ${changedStudents.length} changed records',
      );
      final dateKey = _dateKey(_selectedDate);
      final now = DateTime.now();
      final markedByName = appUser.name.trim().isNotEmpty
          ? appUser.name.trim()
          : appUser.email;
      final records = changedStudents.map((item) {
        final status = AttendanceModel.parseStatus(_attendanceDraft[item.key]);
        final studentId = _studentIdForAttendanceSave(item);
        final batchId = _selectedBatch?.id ?? item.student.batchId;
        final batchName = _selectedBatch?.name ?? item.student.batchName;
        final attendanceKey = AttendanceKeys.create(
          dateKey: dateKey,
          studentId: studentId,
          batchId: batchId,
        );
        return AttendanceModel(
          id: attendanceKey,
          studentId: studentId,
          studentName: item.student.displayName,
          date: _selectedDate,
          status: status,
          batchId: batchId,
          batchName: batchName,
          className: item.student.courseName ?? item.student.className,
          markedBy: appUser.uid,
          markedByName: markedByName,
          createdAt: now,
          updatedAt: now,
        );
      }).toList();

      final result = await _attendanceRepository.saveAttendanceDay(records);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${result.changedCount} attendance records saved locally.',
          ),
          backgroundColor: Colors.teal,
          behavior: SnackBarBehavior.floating,
        ),
      );
      final savedCopy = Map<String, String>.from(_attendanceDraft);
      setState(() {
        _savedAttendance
          ..clear()
          ..addAll(savedCopy);
        _data = _AttendanceLoadData(
          batches: data.batches,
          students: data.students,
          savedStatusNames: savedCopy,
          lastSavedAt: now,
        );
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Attendance could not be saved: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static String _dateKey(DateTime date) =>
      DateFormat('yyyy-MM-dd').format(date);

  static bool _isToday(DateTime date) {
    final today = _dateOnly(DateTime.now());
    return _dateOnly(date) == today;
  }

  static String _syncLabel(OfflineSyncSummary summary) {
    return switch (summary) {
      OfflineSyncSummary.synced => 'Synced',
      OfflineSyncSummary.syncing => 'Syncing...',
      OfflineSyncSummary.pending => 'Pending sync',
      OfflineSyncSummary.failed => 'Sync failed',
    };
  }

  static IconData _syncIcon(OfflineSyncSummary summary) {
    return switch (summary) {
      OfflineSyncSummary.synced => Icons.cloud_done_outlined,
      OfflineSyncSummary.syncing => Icons.sync,
      OfflineSyncSummary.pending => Icons.cloud_upload_outlined,
      OfflineSyncSummary.failed => Icons.cloud_off_outlined,
    };
  }

  static Color _syncColor(OfflineSyncSummary summary) {
    return switch (summary) {
      OfflineSyncSummary.synced => AppTheme.success,
      OfflineSyncSummary.syncing => AppTheme.primary,
      OfflineSyncSummary.pending => AppTheme.warning,
      OfflineSyncSummary.failed => AppTheme.danger,
    };
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.selectedDate, required this.selectedBatchName});

  final DateTime selectedDate;
  final String? selectedBatchName;

  @override
  Widget build(BuildContext context) {
    final subtitle =
        '${DateFormat('EEE, dd MMM yyyy').format(selectedDate)} / ${selectedBatchName ?? 'All Students'}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Attendance',
          style: TextStyle(
            color: AppTheme.text,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(color: AppTheme.muted, fontSize: 14),
        ),
      ],
    );
  }
}

class _ControlPanel extends StatelessWidget {
  const _ControlPanel({
    required this.selectedDate,
    required this.selectedBatch,
    required this.batches,
    required this.summary,
    required this.lastSavedAt,
    required this.isExpanded,
    required this.onToggleExpanded,
    required this.onPrevious,
    required this.onNext,
    required this.onPick,
    required this.onChanged,
    required this.canEditAttendance,
    required this.onPresentAll,
    required this.onAbsentAll,
    required this.onLeaveAll,
    required this.onReset,
  });

  final DateTime selectedDate;
  final _BatchFilter? selectedBatch;
  final List<_BatchFilter> batches;
  final _AttendanceSummary summary;
  final DateTime? lastSavedAt;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;
  final VoidCallback onPrevious;
  final VoidCallback? onNext;
  final VoidCallback onPick;
  final ValueChanged<_BatchFilter?> onChanged;
  final bool canEditAttendance;
  final VoidCallback onPresentAll;
  final VoidCallback onAbsentAll;
  final VoidCallback onLeaveAll;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onToggleExpanded,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppTheme.primarySoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.calendar_month_rounded,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEE, dd MMM yyyy').format(selectedDate),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.text,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          selectedBatch?.name ?? 'All Students',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppTheme.muted),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppTheme.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _DateSelector(
            selectedDate: selectedDate,
            onPrevious: onPrevious,
            onNext: onNext,
            onPick: onPick,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniBadge(label: '${summary.total} total', color: AppTheme.text),
              _MiniBadge(
                label: '${summary.present} present',
                color: AppTheme.success,
              ),
              _MiniBadge(
                label: '${summary.unmarked} unmarked',
                color: summary.unmarked == 0
                    ? AppTheme.success
                    : AppTheme.warning,
              ),
            ],
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                children: [
                  _BatchSelector(
                    batches: batches,
                    selectedBatch: selectedBatch,
                    onChanged: onChanged,
                  ),
                  const SizedBox(height: 12),
                  _BulkActions(
                    enabled: canEditAttendance && summary.total > 0,
                    onPresentAll: onPresentAll,
                    onAbsentAll: onAbsentAll,
                    onLeaveAll: onLeaveAll,
                    onReset: onReset,
                  ),
                  const SizedBox(height: 12),
                  _SummaryCard(summary: summary, lastSavedAt: lastSavedAt),
                ],
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
            sizeCurve: Curves.easeOutCubic,
          ),
        ],
      ),
    );
  }
}

class _StudentListHeader extends StatelessWidget {
  const _StudentListHeader({
    required this.count,
    required this.mode,
    required this.onModeChanged,
  });

  final int count;
  final _AttendanceViewMode mode;
  final ValueChanged<_AttendanceViewMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Student List',
            style: TextStyle(
              color: AppTheme.text,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
        ),
        Text(
          '$count student${count == 1 ? '' : 's'}',
          style: const TextStyle(
            color: AppTheme.muted,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 10),
        _ViewIconButton(
          icon: Icons.view_list_rounded,
          selected: mode == _AttendanceViewMode.list,
          onTap: () => onModeChanged(_AttendanceViewMode.list),
        ),
        const SizedBox(width: 8),
        _ViewIconButton(
          icon: Icons.grid_view_rounded,
          selected: mode == _AttendanceViewMode.grid,
          onTap: () => onModeChanged(_AttendanceViewMode.grid),
        ),
      ],
    );
  }
}

class _ViewIconButton extends StatelessWidget {
  const _ViewIconButton({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: selected ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: selected ? AppTheme.primarySoft : AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.border,
          ),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.14),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
          ],
        ),
        child: Icon(
          icon,
          color: selected ? AppTheme.primary : AppTheme.muted,
          size: 21,
        ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
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

class _DateSelector extends StatelessWidget {
  const _DateSelector({
    required this.selectedDate,
    required this.onPrevious,
    required this.onNext,
    required this.onPick,
  });

  final DateTime selectedDate;
  final VoidCallback onPrevious;
  final VoidCallback? onNext;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Row(
        children: [
          _IconTap(icon: Icons.chevron_left_rounded, onTap: onPrevious),
          Expanded(
            child: InkWell(
              onTap: onPick,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.calendar_month_rounded,
                      color: AppTheme.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        DateFormat('dd MMM yyyy').format(selectedDate),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.text,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _IconTap(icon: Icons.chevron_right_rounded, onTap: onNext),
        ],
      ),
    );
  }
}

class _BatchSelector extends StatelessWidget {
  const _BatchSelector({
    required this.batches,
    required this.selectedBatch,
    required this.onChanged,
  });

  final List<_BatchFilter> batches;
  final _BatchFilter? selectedBatch;
  final ValueChanged<_BatchFilter?> onChanged;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<_BatchFilter?>(
          value: selectedBatch,
          isExpanded: true,
          dropdownColor: AppTheme.surface,
          iconEnabledColor: AppTheme.primary,
          style: const TextStyle(color: AppTheme.text),
          items: [
            const DropdownMenuItem<_BatchFilter?>(
              value: null,
              child: Text('All Students'),
            ),
            ...batches.map(
              (batch) => DropdownMenuItem<_BatchFilter?>(
                value: batch,
                child: Text(batch.label, overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary, required this.lastSavedAt});

  final _AttendanceSummary summary;
  final DateTime? lastSavedAt;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Today's Summary",
                  style: TextStyle(
                    color: AppTheme.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _SavedPill(
                isSaved: summary.unmarked == 0 && lastSavedAt != null,
                lastSavedAt: lastSavedAt,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _Metric(label: 'Total', value: summary.total.toString()),
              _Metric(label: 'Present', value: summary.present.toString()),
              _Metric(label: 'Absent', value: summary.absent.toString()),
              _Metric(label: 'Late', value: summary.late.toString()),
              _Metric(label: 'Leave', value: summary.leave.toString()),
            ],
          ),
        ],
      ),
    );
  }
}

class _BulkActions extends StatelessWidget {
  const _BulkActions({
    required this.enabled,
    required this.onPresentAll,
    required this.onAbsentAll,
    required this.onLeaveAll,
    required this.onReset,
  });

  final bool enabled;
  final VoidCallback onPresentAll;
  final VoidCallback onAbsentAll;
  final VoidCallback onLeaveAll;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _ActionButton(
          icon: Icons.done_all_rounded,
          label: 'Present All',
          color: AppTheme.success,
          onTap: enabled ? onPresentAll : null,
        ),
        _ActionButton(
          icon: Icons.cancel_outlined,
          label: 'Absent All',
          color: AppTheme.danger,
          onTap: enabled ? onAbsentAll : null,
        ),
        _ActionButton(
          icon: Icons.event_available_rounded,
          label: 'Leave All',
          color: AppTheme.primary,
          onTap: enabled ? onLeaveAll : null,
        ),
        _ActionButton(
          icon: Icons.restart_alt_rounded,
          label: 'Reset',
          color: AppTheme.warning,
          onTap: onReset,
        ),
      ],
    );
  }
}

class _PhotoAttendanceCard extends StatelessWidget {
  const _PhotoAttendanceCard({
    required this.student,
    required this.status,
    required this.onTap,
  });

  final StudentModel student;
  final AttendanceStatus? status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = status?.color ?? AppTheme.muted;
    final initial = student.displayName.characters.first.toUpperCase();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.32)),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: student.profilePhoto == null
                  ? Container(
                      color: AppTheme.primarySoft,
                      child: Center(
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    )
                  : Image.network(student.profilePhoto!, fit: BoxFit.cover),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: status == null
                      ? AppTheme.surface
                      : color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: color.withValues(alpha: 0.28)),
                ),
                child: Text(
                  status?.label ?? 'Unmarked',
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.72),
                      Colors.black.withValues(alpha: 0.08),
                    ],
                  ),
                ),
                child: Text(
                  student.displayName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({
    required this.isSaving,
    required this.markedCount,
    required this.totalCount,
    required this.onSave,
  });

  final bool isSaving;
  final int markedCount;
  final int totalCount;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$markedCount/$totalCount marked',
              style: const TextStyle(
                color: AppTheme.text,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: isSaving ? null : onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.cloud_done_rounded),
              label: Text(
                isSaving ? 'Saving' : 'Save Attendance',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.lastSavedAt});

  final DateTime? lastSavedAt;

  @override
  Widget build(BuildContext context) {
    final subtitle = lastSavedAt == null
        ? 'Attendance history will appear here.'
        : 'Last saved ${DateFormat('dd MMM yyyy, hh:mm a').format(lastSavedAt!)}';
    return _StateCard(
      icon: Icons.history_rounded,
      title: 'Attendance History',
      subtitle: subtitle,
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
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

class _IconTap extends StatelessWidget {
  const _IconTap({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: onTap == null ? AppTheme.border : AppTheme.primarySoft,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: onTap == null ? AppTheme.muted : AppTheme.primary,
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 94,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.primarySoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.text,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(color: AppTheme.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _SavedPill extends StatelessWidget {
  const _SavedPill({required this.isSaved, required this.lastSavedAt});

  final bool isSaved;
  final DateTime? lastSavedAt;

  @override
  Widget build(BuildContext context) {
    final label = isSaved && lastSavedAt != null ? 'Saved' : 'Unsaved';
    final color = isSaved && lastSavedAt != null
        ? AppTheme.success
        : AppTheme.warning;
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
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          color: color.withValues(alpha: onTap == null ? 0.04 : 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withValues(alpha: onTap == null ? 0.08 : 0.24),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: onTap == null ? AppTheme.muted : color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: onTap == null ? AppTheme.muted : color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
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
    return _Panel(
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

class _AttendanceLoadData {
  const _AttendanceLoadData({
    required this.batches,
    required this.students,
    required this.savedStatusNames,
    required this.lastSavedAt,
  });

  final List<_BatchFilter> batches;
  final List<_StudentAttendanceItem> students;
  final Map<String, String> savedStatusNames;
  final DateTime? lastSavedAt;
}

class _StudentAttendanceItem {
  const _StudentAttendanceItem({required this.key, required this.student});

  final String key;
  final StudentModel student;
}

class _AttendanceSummary {
  const _AttendanceSummary({
    required this.total,
    required this.present,
    required this.absent,
    required this.late,
    required this.leave,
    required this.unmarked,
  });

  final int total;
  final int present;
  final int absent;
  final int late;
  final int leave;
  final int unmarked;

  factory _AttendanceSummary.fromDraft(
    _AttendanceLoadData data,
    AttendanceStatus? Function(String key) statusResolver,
  ) {
    var present = 0;
    var absent = 0;
    var late = 0;
    var leave = 0;
    var unmarked = 0;

    for (final item in data.students) {
      switch (statusResolver(item.key)) {
        case AttendanceStatus.present:
          present++;
        case AttendanceStatus.absent:
          absent++;
        case AttendanceStatus.late:
          late++;
        case AttendanceStatus.leave:
          leave++;
        case null:
          unmarked++;
      }
    }

    return _AttendanceSummary(
      total: data.students.length,
      present: present,
      absent: absent,
      late: late,
      leave: leave,
      unmarked: unmarked,
    );
  }
}

class _BatchFilter {
  const _BatchFilter({
    required this.id,
    required this.name,
    required this.isActive,
    this.time,
  });

  final String id;
  final String name;
  final bool isActive;
  final String? time;

  String get label => time == null ? name : '$name ($time)';

  static _BatchFilter fromModel(BatchModel batch) {
    return _BatchFilter(
      id: batch.id,
      name: batch.name,
      isActive: batch.isActive,
      time: batch.startTime,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is _BatchFilter && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
