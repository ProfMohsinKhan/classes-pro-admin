import 'dart:async';

import 'package:flutter/material.dart';

import '../core/database/database_provider.dart';
import '../data/repositories/offline_repositories.dart';
import '../data/repositories/offline_repository_contracts.dart';
import '../models/student_model.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';
import '../widgets/student_card.dart';
import 'access_denied_screen.dart';
import 'edit_student_screen.dart';
import 'student_detail_screen.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final OfflineStudentsRepository _studentsRepository;
  String _selectedBatch = 'All Batches';
  String _selectedStatus = 'All Status';

  @override
  void initState() {
    super.initState();
    _studentsRepository = OfflineStudentsRepository(
      OfflineDatabaseProvider.instance,
    );
    unawaited(_studentsRepository.requestSync());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

        if (appUser == null || !appUser.canViewStudents) {
          return const AccessDeniedScreen();
        }

        return Scaffold(
          backgroundColor: AppTheme.background,
          floatingActionButton: appUser.canCreateStudents
              ? FloatingActionButton.extended(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditStudentScreen(),
                    ),
                  ),
                  icon: const Icon(
                    Icons.person_add_alt_1_rounded,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Add Student',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(
                  onBack: () => Navigator.pop(context),
                  repository: _studentsRepository,
                ),
                _SearchBar(
                  controller: _searchController,
                  onClear: () => _searchController.clear(),
                ),
                Expanded(
                  child: StreamBuilder<List<StudentModel>>(
                    stream: _studentsRepository.watchActiveStudents(),
                    builder: (context, snapshot) {
                      final students = snapshot.data ?? const <StudentModel>[];
                      final batches = _batchOptions(students);
                      return ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _searchController,
                        builder: (context, searchValue, _) {
                          final filtered = _filteredStudents(
                            students,
                            _normalize(searchValue.text),
                          );

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FilterRow(
                                total: filtered.length,
                                batches: batches,
                                selectedBatch: _selectedBatch,
                                selectedStatus: _selectedStatus,
                                onBatchChanged: (value) {
                                  if (value != null) {
                                    setState(() => _selectedBatch = value);
                                  }
                                },
                                onStatusChanged: (value) {
                                  if (value != null) {
                                    setState(() => _selectedStatus = value);
                                  }
                                },
                              ),
                              Expanded(
                                child: filtered.isEmpty
                                    ? const _StateMessage(
                                        icon: Icons.group_off_rounded,
                                        message: 'No students found',
                                      )
                                    : ListView.builder(
                                        key: PageStorageKey(
                                          'students-$_selectedBatch-$_selectedStatus-${_normalize(searchValue.text)}',
                                        ),
                                        padding: const EdgeInsets.fromLTRB(
                                          20,
                                          10,
                                          20,
                                          90,
                                        ),
                                        itemCount: filtered.length,
                                        itemBuilder: (context, index) {
                                          final student = filtered[index];
                                          return StudentCard(
                                            student: student,
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute<void>(
                                                  builder: (context) =>
                                                      StudentDetailScreen(
                                                        student: student,
                                                      ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<StudentModel> _filteredStudents(
    List<StudentModel> students,
    String searchQuery,
  ) {
    return students.where((student) {
      final searchableParts = [
        student.name,
        student.displayName,
        student.studentId,
        student.numericId?.toString(),
        student.phone,
        student.primaryPhone,
        student.parentName,
        student.parentPhone,
        student.guardianName,
        student.guardianPhone,
        student.className,
        student.batchName,
        student.courseName,
        student.displayClassBatch,
      ].whereType<String>().toList();
      final haystack = _normalize(searchableParts.join(' '));
      final digitHaystack = searchableParts
          .join(' ')
          .replaceAll(RegExp(r'[^0-9]'), '');
      final queryDigits = searchQuery.replaceAll(RegExp(r'[^0-9]'), '');
      final queryTokens = searchQuery
          .split(' ')
          .where((token) => token.trim().isNotEmpty);

      final matchesSearch =
          searchQuery.isEmpty ||
          queryTokens.every(haystack.contains) ||
          (queryDigits.isNotEmpty && digitHaystack.contains(queryDigits));
      final matchesBatch =
          _selectedBatch == 'All Batches' ||
          student.batchName == _selectedBatch;
      final matchesStatus =
          _selectedStatus == 'All Status' ||
          (student.status ?? 'active').toLowerCase() ==
              _selectedStatus.toLowerCase();
      return matchesSearch && matchesBatch && matchesStatus;
    }).toList()..sort((a, b) => a.displayName.compareTo(b.displayName));
  }

  List<String> _batchOptions(List<StudentModel> students) {
    final batches =
        students
            .map((student) => student.batchName)
            .whereType<String>()
            .where((batch) => batch.trim().isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return ['All Batches', ...batches];
  }
}

String _normalize(String value) {
  return value.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack, required this.repository});

  final VoidCallback onBack;
  final OfflineStudentsRepository repository;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 12, 12, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.text),
          ),
          const SizedBox(width: 4),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Students',
                  style: TextStyle(
                    color: AppTheme.text,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Mak Tutorials student directory',
                  style: TextStyle(color: AppTheme.muted, fontSize: 13),
                ),
              ],
            ),
          ),
          StreamBuilder<OfflineSyncSummary>(
            stream: repository.watchSyncSummary(),
            initialData: OfflineSyncSummary.synced,
            builder: (context, snapshot) {
              return _SyncIndicator(
                status: snapshot.data ?? OfflineSyncSummary.synced,
                onRefresh: () => unawaited(repository.requestSync()),
              );
            },
          ),
        ],
      ),
    );
  }
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
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
        IconButton(
          tooltip: 'Sync students',
          onPressed: onRefresh,
          icon: Icon(Icons.sync_rounded, color: color),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onClear});

  final TextEditingController controller;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) {
          return TextField(
            key: const PageStorageKey('student-search-field'),
            controller: controller,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search name, phone, parent, class or batch...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: value.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      onPressed: onClear,
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          );
        },
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.total,
    required this.batches,
    required this.selectedBatch,
    required this.selectedStatus,
    required this.onBatchChanged,
    required this.onStatusChanged,
  });

  final int total;
  final List<String> batches;
  final String selectedBatch;
  final String selectedStatus;
  final ValueChanged<String?> onBatchChanged;
  final ValueChanged<String?> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$total student${total == 1 ? '' : 's'}',
            style: const TextStyle(
              color: AppTheme.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _DropdownChip(
                  value: selectedBatch,
                  items: batches,
                  icon: Icons.groups_rounded,
                  onChanged: onBatchChanged,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DropdownChip(
                  value: selectedStatus,
                  items: const ['All Status', 'active', 'inactive'],
                  icon: Icons.toggle_on_rounded,
                  onChanged: onStatusChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DropdownChip extends StatelessWidget {
  const _DropdownChip({
    required this.value,
    required this.items,
    required this.icon,
    required this.onChanged,
  });

  final String value;
  final List<String> items;
  final IconData icon;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 210),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : items.first,
          isExpanded: true,
          dropdownColor: AppTheme.surface,
          iconEnabledColor: AppTheme.primary,
          style: const TextStyle(color: AppTheme.text, fontSize: 13),
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Row(
                    children: [
                      Icon(icon, size: 15, color: AppTheme.primary),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          item,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppTheme.muted, size: 42),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.muted, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
