import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/database/database_provider.dart';
import '../data/mappers/enquiry_mapper.dart';
import '../data/repositories/offline_repositories.dart';
import '../data/repositories/offline_repository_contracts.dart';
import '../models/batch_model.dart';
import '../models/course_model.dart';
import '../models/enquiry_model.dart';
import '../theme/app_theme.dart';
import '../widgets/enquiry_card.dart';

class EnquiriesScreen extends StatefulWidget {
  const EnquiriesScreen({super.key});

  @override
  State<EnquiriesScreen> createState() => _EnquiriesScreenState();
}

class _EnquiriesScreenState extends State<EnquiriesScreen> {
  late final EnquiriesRepository _enquiriesRepository;
  late final CoursesRepository _coursesRepository;
  late final BatchesRepository _batchesRepository;
  late final Stream<List<EnquiryModel>> _enquiriesStream;
  late final Stream<List<CourseModel>> _coursesStream;
  late final Stream<List<BatchModel>> _batchesStream;
  late final Stream<OfflineSyncSummary> _syncSummaryStream;

  String _searchQuery = '';
  String _statusFilter = 'all';
  String _courseFilter = 'all';
  String _batchFilter = 'all';
  bool _followUpsOnly = false;

  @override
  void initState() {
    super.initState();
    final database = OfflineDatabaseProvider.instance;
    _enquiriesRepository = EnquiriesRepositoryImpl(database);
    _coursesRepository = CoursesRepositoryImpl(database);
    _batchesRepository = BatchesRepositoryImpl(database);
    _enquiriesStream = _enquiriesRepository.watchActiveEnquiries();
    _coursesStream = _coursesRepository.watchActiveCourses();
    _batchesStream = _batchesRepository.watchActiveBatches();
    _syncSummaryStream = _enquiriesRepository.watchSyncSummary();
    unawaited(_enquiriesRepository.requestSync());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Lead Management',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          StreamBuilder<OfflineSyncSummary>(
            stream: _syncSummaryStream,
            initialData: OfflineSyncSummary.synced,
            builder: (context, snapshot) {
              final summary = snapshot.data ?? OfflineSyncSummary.synced;
              return IconButton(
                tooltip: _syncLabel(summary),
                icon: Icon(_syncIcon(summary), color: _syncColor(summary)),
                onPressed: () => unawaited(_enquiriesRepository.requestSync()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEnquiryForm(context),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'New Enquiry',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
            child: TextField(
              onChanged: (value) =>
                  setState(() => _searchQuery = value.trim().toLowerCase()),
              style: const TextStyle(color: AppTheme.text),
              decoration: InputDecoration(
                hintText: 'Search by name, phone, parent, course...',
                hintStyle: const TextStyle(color: AppTheme.muted),
                prefixIcon: const Icon(Icons.search, color: AppTheme.primary),
                filled: true,
                fillColor: AppTheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: AppTheme.primary),
                ),
              ),
            ),
          ),
          _FilterBar(
            statusFilter: _statusFilter,
            followUpsOnly: _followUpsOnly,
            onStatusChanged: (value) => setState(() => _statusFilter = value),
            onFollowUpsChanged: (value) =>
                setState(() => _followUpsOnly = value),
          ),
          StreamBuilder<List<CourseModel>>(
            stream: _coursesStream,
            initialData: const [],
            builder: (context, coursesSnapshot) {
              return StreamBuilder<List<BatchModel>>(
                stream: _batchesStream,
                initialData: const [],
                builder: (context, batchesSnapshot) {
                  final courses = coursesSnapshot.data ?? const [];
                  final batches = batchesSnapshot.data ?? const [];
                  return _ReferenceFilterBar(
                    courses: courses,
                    batches: batches,
                    courseFilter: _courseFilter,
                    batchFilter: _batchFilter,
                    onCourseChanged: (value) => setState(() {
                      _courseFilter = value;
                      _batchFilter = 'all';
                    }),
                    onBatchChanged: (value) =>
                        setState(() => _batchFilter = value),
                  );
                },
              );
            },
          ),
          Expanded(
            child: StreamBuilder<List<EnquiryModel>>(
              stream: _enquiriesStream,
              initialData: const [],
              builder: (context, snapshot) {
                final enquiries = _filterEnquiries(snapshot.data ?? const []);
                if (enquiries.isEmpty) {
                  return const Center(
                    child: Text(
                      'No enquiries found.',
                      style: TextStyle(color: AppTheme.muted),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 10,
                    bottom: 80,
                  ),
                  itemCount: enquiries.length,
                  itemBuilder: (context, index) {
                    final enquiry = enquiries[index];
                    return EnquiryCard(
                      enquiry: enquiry,
                      onEdit: () => _showEnquiryForm(context, enquiry: enquiry),
                      onDelete: () => _archiveEnquiry(enquiry),
                      onStatusChanged: (status) => unawaited(
                        _enquiriesRepository.updateStatus(enquiry.id, status),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<EnquiryModel> _filterEnquiries(List<EnquiryModel> enquiries) {
    final now = DateTime.now();
    return enquiries.where((enquiry) {
      if (_statusFilter != 'all' && enquiry.enquiryStatus != _statusFilter) {
        return false;
      }
      if (_courseFilter != 'all' &&
          enquiry.interestedCourseId != _courseFilter) {
        return false;
      }
      if (_batchFilter != 'all' && enquiry.interestedBatchId != _batchFilter) {
        return false;
      }
      if (_followUpsOnly) {
        final followUp = enquiry.followUpDate;
        if (followUp == null ||
            followUp.isAfter(DateTime(now.year, now.month, now.day + 7))) {
          return false;
        }
      }
      if (_searchQuery.isEmpty) return true;
      final haystack = [
        enquiry.studentName,
        enquiry.parentName,
        enquiry.phone,
        enquiry.alternatePhone,
        enquiry.interestedCourseName,
        enquiry.interestedBatchName,
        enquiry.notes,
        enquiry.message,
        enquiry.followUpNotes,
      ].whereType<String>().join(' ').toLowerCase();
      return haystack.contains(_searchQuery);
    }).toList();
  }

  Future<void> _archiveEnquiry(EnquiryModel enquiry) async {
    final confirm =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppTheme.surface,
            title: const Text('Delete Enquiry?'),
            content: const Text('This lead will be moved to trash.'),
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
    await _enquiriesRepository.archiveEnquiry(enquiry.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Enquiry deleted.'),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  void _showEnquiryForm(BuildContext context, {EnquiryModel? enquiry}) {
    final isEditing = enquiry != null;
    final nameCtrl = TextEditingController(text: enquiry?.studentName ?? '');
    final parentCtrl = TextEditingController(text: enquiry?.parentName ?? '');
    final phoneCtrl = TextEditingController(text: enquiry?.phone ?? '');
    final alternatePhoneCtrl = TextEditingController(
      text: enquiry?.alternatePhone ?? '',
    );
    final emailCtrl = TextEditingController(text: enquiry?.email ?? '');
    final currClassCtrl = TextEditingController(
      text: enquiry?.currentClass ?? '',
    );
    final schoolCtrl = TextEditingController(text: enquiry?.schoolName ?? '');
    final msgCtrl = TextEditingController(text: enquiry?.message ?? '');
    final followUpNotesCtrl = TextEditingController(
      text: enquiry?.followUpNotes ?? enquiry?.notes ?? '',
    );
    DateTime? dob = enquiry?.dob;
    DateTime? followUpDate = enquiry?.followUpDate;
    String status = enquiry?.enquiryStatus ?? 'new';
    String source = enquiry?.source ?? 'walk_in';
    String? selectedCourseId = enquiry?.interestedCourseId;
    String? selectedCourseName = enquiry?.interestedCourseName;
    String? selectedBatchId = enquiry?.interestedBatchId;
    String? selectedBatchName = enquiry?.interestedBatchName;

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
            return Container(
              height: MediaQuery.of(context).size.height * 0.88,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                children: [
                  Text(
                    isEditing ? 'Update Lead' : 'New Lead Enquiry',
                    style: const TextStyle(
                      color: AppTheme.text,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionLabel('Lead Details'),
                          _buildField('Full Name', nameCtrl, Icons.person),
                          _buildField(
                            'Parent Name',
                            parentCtrl,
                            Icons.family_restroom,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _buildField(
                                  'Phone',
                                  phoneCtrl,
                                  Icons.phone,
                                  isNumber: true,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildDropdown(
                                  'Source',
                                  source,
                                  const [
                                    'walk_in',
                                    'website',
                                    'referral',
                                    'social_media',
                                  ],
                                  (v) => setModalState(() => source = v!),
                                ),
                              ),
                            ],
                          ),
                          _buildField(
                            'Alternate Phone',
                            alternatePhoneCtrl,
                            Icons.phone_android,
                            isNumber: true,
                          ),
                          _buildField('Email', emailCtrl, Icons.mail_outline),
                          _DateField(
                            label: 'Date of Birth',
                            date: dob,
                            color: AppTheme.primary,
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: dob ?? DateTime(2010),
                                firstDate: DateTime(1980),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setModalState(() => dob = picked);
                              }
                            },
                          ),
                          StreamBuilder<List<CourseModel>>(
                            stream: _coursesStream,
                            initialData: const [],
                            builder: (context, snapshot) {
                              final courses = snapshot.data ?? const [];
                              final courseItems = [
                                const _LookupOption('', 'No Course'),
                                ...courses.map(_LookupOption.fromCourse),
                              ];
                              final courseValue =
                                  courseItems.any(
                                    (item) => item.id == selectedCourseId,
                                  )
                                  ? selectedCourseId ?? ''
                                  : '';
                              return _lookupDropdown(
                                'Course Interested',
                                courseValue,
                                courseItems,
                                (option) {
                                  setModalState(() {
                                    selectedCourseId = option.id.isEmpty
                                        ? null
                                        : option.id;
                                    selectedCourseName = option.id.isEmpty
                                        ? null
                                        : option.name;
                                    selectedBatchId = null;
                                    selectedBatchName = null;
                                  });
                                },
                              );
                            },
                          ),
                          StreamBuilder<List<BatchModel>>(
                            stream: _batchesStream,
                            initialData: const [],
                            builder: (context, snapshot) {
                              final batches = (snapshot.data ?? const [])
                                  .where(
                                    (batch) =>
                                        selectedCourseId == null ||
                                        batch.courseId == selectedCourseId,
                                  )
                                  .toList();
                              final batchItems = [
                                const _LookupOption('', 'No Batch'),
                                ...batches.map(_LookupOption.fromBatch),
                              ];
                              final batchValue =
                                  batchItems.any(
                                    (item) => item.id == selectedBatchId,
                                  )
                                  ? selectedBatchId ?? ''
                                  : '';
                              return _lookupDropdown(
                                'Interested Batch',
                                batchValue,
                                batchItems,
                                (option) {
                                  setModalState(() {
                                    selectedBatchId = option.id.isEmpty
                                        ? null
                                        : option.id;
                                    selectedBatchName = option.id.isEmpty
                                        ? null
                                        : option.name;
                                  });
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          const _SectionLabel(
                            'CRM Status & Follow-up',
                            color: AppTheme.warning,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDropdown(
                                  'Status',
                                  status,
                                  const [
                                    'new',
                                    'contacted',
                                    'followUp',
                                    'interested',
                                    'converted',
                                    'notInterested',
                                    'closed',
                                  ],
                                  (v) => setModalState(
                                    () => status =
                                        EnquiryMapper.normalizeStatus(v),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _DateField(
                                  label: 'Follow-up Date',
                                  date: followUpDate,
                                  color: AppTheme.warning,
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate:
                                          followUpDate ?? DateTime.now(),
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2035),
                                    );
                                    if (picked != null) {
                                      setModalState(
                                        () => followUpDate = picked,
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          _buildField(
                            'Follow-up Notes / Comments',
                            followUpNotesCtrl,
                            Icons.notes,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 20),
                          const _SectionLabel(
                            'Optional Information',
                            color: AppTheme.muted,
                          ),
                          _buildField(
                            'Current Class',
                            currClassCtrl,
                            Icons.class_outlined,
                          ),
                          _buildField('School Name', schoolCtrl, Icons.school),
                          _buildField(
                            'Student Message',
                            msgCtrl,
                            Icons.message,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () async {
                        if (nameCtrl.text.trim().isEmpty ||
                            phoneCtrl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Name and Phone are required!'),
                            ),
                          );
                          return;
                        }

                        final model = EnquiryModel(
                          id: enquiry?.id ?? '',
                          legacyId: enquiry?.legacyId,
                          studentName: nameCtrl.text.trim(),
                          parentName: _emptyToNull(parentCtrl.text),
                          phone: _emptyToNull(phoneCtrl.text),
                          alternatePhone: _emptyToNull(alternatePhoneCtrl.text),
                          email: _emptyToNull(emailCtrl.text),
                          dob: dob,
                          interestedCourseId: selectedCourseId,
                          interestedCourseName: selectedCourseName,
                          interestedBatchId: selectedBatchId,
                          interestedBatchName: selectedBatchName,
                          currentClass: _emptyToNull(currClassCtrl.text),
                          schoolName: _emptyToNull(schoolCtrl.text),
                          source: source,
                          enquiryStatus: status,
                          followUpDate: followUpDate,
                          message: _emptyToNull(msgCtrl.text),
                          followUpNotes: _emptyToNull(followUpNotesCtrl.text),
                          notes: _emptyToNull(followUpNotesCtrl.text),
                          assignedTo: enquiry?.assignedTo,
                          assignedToName: enquiry?.assignedToName,
                          createdAt: enquiry?.createdAt,
                          deletedAt: enquiry?.deletedAt,
                        );

                        if (isEditing) {
                          await _enquiriesRepository.updateEnquiry(model);
                        } else {
                          await _enquiriesRepository.createEnquiry(model);
                        }
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: Text(
                        isEditing ? 'Update Lead' : 'Save Lead',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
        maxLines: maxLines,
        style: const TextStyle(
          color: AppTheme.text,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppTheme.muted),
          floatingLabelStyle: const TextStyle(
            color: AppTheme.primary,
            fontWeight: FontWeight.w800,
          ),
          prefixIcon: Icon(icon, color: AppTheme.muted, size: 20),
          filled: true,
          fillColor: AppTheme.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: AppTheme.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: AppTheme.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: AppTheme.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        initialValue: items.contains(value) ? value : items.first,
        dropdownColor: AppTheme.surface,
        iconEnabledColor: AppTheme.muted,
        style: const TextStyle(
          color: AppTheme.text,
          fontWeight: FontWeight.w700,
        ),
        decoration: _dropdownDecoration(label),
        items: items
            .map(
              (e) => DropdownMenuItem(value: e, child: Text(_labelForValue(e))),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _lookupDropdown(
    String label,
    String value,
    List<_LookupOption> items,
    ValueChanged<_LookupOption> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        dropdownColor: AppTheme.surface,
        iconEnabledColor: AppTheme.muted,
        style: const TextStyle(
          color: AppTheme.text,
          fontWeight: FontWeight.w700,
        ),
        decoration: _dropdownDecoration(label),
        items: items
            .map(
              (option) => DropdownMenuItem(
                value: option.id,
                child: Text(option.name, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
        onChanged: (value) {
          final selected = items.firstWhere(
            (item) => item.id == value,
            orElse: () => items.first,
          );
          onChanged(selected);
        },
      ),
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppTheme.muted),
      filled: true,
      fillColor: AppTheme.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: AppTheme.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: AppTheme.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: AppTheme.primary),
      ),
    );
  }

  static String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
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

  static String _labelForValue(String value) {
    return switch (value) {
      'followUp' => 'FOLLOW-UP',
      'notInterested' => 'NOT INTERESTED',
      _ => value.replaceAll('_', ' ').toUpperCase(),
    };
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.statusFilter,
    required this.followUpsOnly,
    required this.onStatusChanged,
    required this.onFollowUpsChanged,
  });

  final String statusFilter;
  final bool followUpsOnly;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<bool> onFollowUpsChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        children: [
          _FilterChip(
            label: 'All',
            selected: statusFilter == 'all',
            onTap: () => onStatusChanged('all'),
          ),
          for (final status in const [
            'new',
            'contacted',
            'followUp',
            'interested',
            'converted',
            'notInterested',
            'closed',
          ])
            _FilterChip(
              label: _statusLabel(status),
              selected: statusFilter == status,
              onTap: () => onStatusChanged(status),
            ),
          _FilterChip(
            label: 'Follow-ups',
            selected: followUpsOnly,
            onTap: () => onFollowUpsChanged(!followUpsOnly),
          ),
        ],
      ),
    );
  }
}

class _ReferenceFilterBar extends StatelessWidget {
  const _ReferenceFilterBar({
    required this.courses,
    required this.batches,
    required this.courseFilter,
    required this.batchFilter,
    required this.onCourseChanged,
    required this.onBatchChanged,
  });

  final List<CourseModel> courses;
  final List<BatchModel> batches;
  final String courseFilter;
  final String batchFilter;
  final ValueChanged<String> onCourseChanged;
  final ValueChanged<String> onBatchChanged;

  @override
  Widget build(BuildContext context) {
    final visibleBatches = batches
        .where(
          (batch) => courseFilter == 'all' || batch.courseId == courseFilter,
        )
        .toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: courses.any((course) => course.id == courseFilter)
                  ? courseFilter
                  : 'all',
              decoration: _compactDecoration('Course'),
              items: [
                const DropdownMenuItem(
                  value: 'all',
                  child: Text('All Courses'),
                ),
                ...courses.map(
                  (course) => DropdownMenuItem(
                    value: course.id,
                    child: Text(course.name, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
              onChanged: (value) => onCourseChanged(value ?? 'all'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue:
                  visibleBatches.any((batch) => batch.id == batchFilter)
                  ? batchFilter
                  : 'all',
              decoration: _compactDecoration('Batch'),
              items: [
                const DropdownMenuItem(
                  value: 'all',
                  child: Text('All Batches'),
                ),
                ...visibleBatches.map(
                  (batch) => DropdownMenuItem(
                    value: batch.id,
                    child: Text(batch.name, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
              onChanged: (value) => onBatchChanged(value ?? 'all'),
            ),
          ),
        ],
      ),
    );
  }

  static InputDecoration _compactDecoration(String label) {
    return InputDecoration(
      labelText: label,
      isDense: true,
      filled: true,
      fillColor: AppTheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.border),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppTheme.primarySoft,
        backgroundColor: AppTheme.surface,
        labelStyle: TextStyle(
          color: selected ? AppTheme.primary : AppTheme.muted,
          fontWeight: FontWeight.w800,
        ),
        side: BorderSide(color: selected ? AppTheme.primary : AppTheme.border),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, {this.color = AppTheme.primary});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.date,
    required this.color,
    required this.onTap,
  });

  final String label;
  final DateTime? date;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_month, color: color, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  date != null
                      ? DateFormat('dd MMM yyyy').format(date!)
                      : label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: date != null ? AppTheme.text : AppTheme.muted,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LookupOption {
  const _LookupOption(this.id, this.name);

  final String id;
  final String name;

  factory _LookupOption.fromCourse(CourseModel course) {
    return _LookupOption(course.id, course.name);
  }

  factory _LookupOption.fromBatch(BatchModel batch) {
    return _LookupOption(batch.id, batch.name);
  }
}

String _statusLabel(String status) {
  return switch (status) {
    'followUp' => 'Follow-up',
    'notInterested' => 'Not Interested',
    _ => '${status[0].toUpperCase()}${status.substring(1)}',
  };
}
