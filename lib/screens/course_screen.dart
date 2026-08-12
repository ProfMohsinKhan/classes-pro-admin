import 'dart:async';

import 'package:flutter/material.dart';

import '../core/database/database_provider.dart';
import '../data/repositories/offline_repositories.dart';
import '../data/repositories/offline_repository_contracts.dart';
import '../models/course_model.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';
import '../widgets/course_card.dart';
import 'access_denied_screen.dart';

class CourseScreen extends StatefulWidget {
  const CourseScreen({super.key});

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  late final CoursesRepositoryImpl _repository;
  String searchQuery = '';
  String selectedFilterCategory = 'All';

  final List<String> courseCategories = [
    'Maharashtra board',
    'CBSE Board',
    'ICSE Board',
    'IGCSE Board',
    'Degree',
    'Entrance Test',
  ];

  @override
  void initState() {
    super.initState();
    _repository = CoursesRepositoryImpl(OfflineDatabaseProvider.instance);
    unawaited(_repository.requestSync());
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
            !(appUser.canViewCourses || appUser.canManageCourses)) {
          return const AccessDeniedScreen();
        }
        final canManage = appUser.canManageCourses;

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            title: const Text(
              'Course Management',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            actions: [
              StreamBuilder<OfflineSyncSummary>(
                stream: _repository.watchSyncSummary(),
                initialData: OfflineSyncSummary.synced,
                builder: (context, snapshot) {
                  return _SyncIndicator(
                    status: snapshot.data ?? OfflineSyncSummary.synced,
                    onRefresh: () => unawaited(_repository.requestSync()),
                  );
                },
              ),
            ],
          ),
          floatingActionButton: canManage
              ? FloatingActionButton.extended(
                  onPressed: () => _showCourseForm(context, null),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'New Course',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: TextField(
                  onChanged: (value) =>
                      setState(() => searchQuery = value.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Search courses by name or code...',
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
              ),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: ['All', ...courseCategories].map((cat) {
                    final isSelected = selectedFilterCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        selectedColor: AppTheme.primary,
                        backgroundColor: AppTheme.surface,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.text,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (_) =>
                            setState(() => selectedFilterCategory = cat),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide.none,
                        ),
                        showCheckmark: false,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: StreamBuilder<List<CourseModel>>(
                  stream: _repository.watchActiveCourses(),
                  builder: (context, snapshot) {
                    final courses = snapshot.data ?? const <CourseModel>[];
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        courses.isEmpty) {
                      return const Center(
                        child: Text(
                          'No local courses yet. Tap refresh when online.',
                          style: TextStyle(color: AppTheme.muted),
                        ),
                      );
                    }
                    final filtered = _filterCourses(courses);
                    if (courses.isEmpty) {
                      return const Center(
                        child: Text(
                          'No courses available.',
                          style: TextStyle(color: AppTheme.muted),
                        ),
                      );
                    }
                    if (filtered.isEmpty) {
                      return const Center(
                        child: Text(
                          'No matching courses found.',
                          style: TextStyle(color: AppTheme.muted),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: 80,
                        top: 10,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final course = filtered[index];
                        return Stack(
                          children: [
                            CourseCard(
                              course: course.toCardMap(),
                              onTap: () {},
                              onEdit: canManage
                                  ? () => _showCourseForm(context, course)
                                  : null,
                              onDelete: canManage
                                  ? () => _softDeleteCourse(course.id)
                                  : null,
                            ),
                            if (course.hasPendingSync)
                              const Positioned(
                                right: 10,
                                bottom: 12,
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
            ],
          ),
        );
      },
    );
  }

  List<CourseModel> _filterCourses(List<CourseModel> courses) {
    return courses.where((course) {
      final name = course.name.toLowerCase();
      final code = (course.code ?? '').toLowerCase();
      final category = course.category ?? '';
      final matchesSearch =
          name.contains(searchQuery) || code.contains(searchQuery);
      final matchesCategory =
          selectedFilterCategory == 'All' || category == selectedFilterCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  Future<void> _softDeleteCourse(String id) async {
    final confirm =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Course?'),
            content: const Text(
              'This will hide the course from the app (Soft Delete).',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: AppTheme.danger),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;
    await _repository.archiveCourse(id);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Course moved to trash!')));
  }

  void _showCourseForm(BuildContext context, CourseModel? existingCourse) {
    final isEditing = existingCourse != null;
    final nameCtrl = TextEditingController(text: existingCourse?.name ?? '');
    final subjectsCtrl = TextEditingController(
      text: existingCourse?.subjects ?? '',
    );
    final codeCtrl = TextEditingController(text: existingCourse?.code ?? '');
    final monthlyFeesCtrl = TextEditingController(
      text: _numText(existingCourse?.monthlyFees),
    );
    final yearlyFeesCtrl = TextEditingController(
      text: _numText(existingCourse?.yearlyFees),
    );
    final descCtrl = TextEditingController(
      text: existingCourse?.description ?? '',
    );

    var duration = existingCourse?.durationMonths ?? 12;
    var maxStudents = existingCourse?.maxStudents ?? 50;
    var feesFreq = existingCourse?.feesFrequency ?? 'yearly';
    var isActive = existingCourse?.isActive ?? true;
    var selectedCategory = courseCategories.contains(existingCourse?.category)
        ? existingCourse!.category!
        : courseCategories.first;
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
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 20,
                  right: 20,
                  top: 20,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEditing ? 'Edit Course' : 'Create New Course',
                        style: const TextStyle(
                          color: AppTheme.text,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        nameCtrl,
                        'Course Name (e.g. Class 12 Science)',
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        subjectsCtrl,
                        'Subjects (e.g. All Subjects, PCM)',
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              codeCtrl,
                              'Code (e.g. SCI-12)',
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: selectedCategory,
                              style: const TextStyle(
                                color: AppTheme.text,
                                fontSize: 13,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Category',
                              ),
                              items: courseCategories
                                  .map(
                                    (cat) => DropdownMenuItem(
                                      value: cat,
                                      child: Text(
                                        cat,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) => setModalState(
                                () =>
                                    selectedCategory = val ?? selectedCategory,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(descCtrl, 'Description', maxLines: 3),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              monthlyFeesCtrl,
                              'Monthly Fees',
                              isNumber: true,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildTextField(
                              yearlyFeesCtrl,
                              'Yearly Fees',
                              isNumber: true,
                            ),
                          ),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: feesFreq,
                              style: const TextStyle(color: AppTheme.text),
                              decoration: InputDecoration(
                                labelText: 'Frequency',
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'yearly',
                                  child: Text('Yearly'),
                                ),
                                DropdownMenuItem(
                                  value: 'monthly',
                                  child: Text('Monthly'),
                                ),
                              ],
                              onChanged: (val) => setModalState(
                                () => feesFreq = val ?? feesFreq,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Duration: $duration Months',
                        style: const TextStyle(color: AppTheme.muted),
                      ),
                      Slider(
                        value: duration.toDouble(),
                        min: 1,
                        max: 60,
                        divisions: 60,
                        activeColor: AppTheme.warning,
                        onChanged: (val) =>
                            setModalState(() => duration = val.toInt()),
                      ),
                      Text(
                        'Max Students: $maxStudents',
                        style: const TextStyle(color: AppTheme.muted),
                      ),
                      Slider(
                        value: maxStudents.toDouble(),
                        min: 5,
                        max: 200,
                        divisions: 39,
                        activeColor: AppTheme.primary,
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
                                  setModalState(() => isSaving = true);
                                  final now = DateTime.now();
                                  final course = CourseModel(
                                    id: existingCourse?.id ?? '',
                                    legacyId: existingCourse?.legacyId,
                                    name: nameCtrl.text.trim(),
                                    subjects: subjectsCtrl.text.trim(),
                                    code: codeCtrl.text.trim(),
                                    category: selectedCategory,
                                    description: descCtrl.text.trim(),
                                    monthlyFees: _parseDouble(
                                      monthlyFeesCtrl.text,
                                    ),
                                    yearlyFees: _parseDouble(
                                      yearlyFeesCtrl.text,
                                    ),
                                    feesFrequency: feesFreq,
                                    durationMonths: duration,
                                    maxStudents: maxStudents,
                                    isActive: isActive,
                                    createdAt: existingCourse?.createdAt ?? now,
                                    updatedAt: now,
                                  );
                                  if (isEditing) {
                                    await _repository.updateCourse(course);
                                  } else {
                                    await _repository.createCourse(course);
                                  }
                                  if (!context.mounted) return;
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Course saved locally.'),
                                      backgroundColor: AppTheme.success,
                                    ),
                                  );
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
                                  isEditing ? 'Update Course' : 'Save Course',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
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

  Widget _buildTextField(
    TextEditingController ctrl,
    String hint, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      style: const TextStyle(color: AppTheme.text),
      decoration: InputDecoration(hintText: hint),
    );
  }

  String _numText(double? value) {
    if (value == null) return '';
    if (value % 1 == 0) return value.toInt().toString();
    return value.toString();
  }

  double? _parseDouble(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : double.tryParse(trimmed);
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
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        IconButton(
          tooltip: 'Sync courses',
          onPressed: onRefresh,
          icon: Icon(Icons.sync_rounded, color: color),
        ),
      ],
    );
  }
}
