import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/user_service.dart';
import '../theme/app_theme.dart';
import '../widgets/enrollment_card.dart';
import 'access_denied_screen.dart';

class EnrollmentScreen extends StatefulWidget {
  const EnrollmentScreen({super.key});

  @override
  State<EnrollmentScreen> createState() => _EnrollmentScreenState();
}

class _EnrollmentScreenState extends State<EnrollmentScreen> {
  final _searchController = TextEditingController();
  final _enrollmentsStream = FirebaseFirestore.instance
      .collection('enrollments')
      .where('deleted_at', isNull: true)
      .snapshots();

  List<Map<String, dynamic>> studentsList = [];
  List<Map<String, dynamic>> coursesList = [];
  List<Map<String, dynamic>> batchesList = [];
  String _searchQuery = '';
  String _courseFilter = 'All Courses';
  String _batchFilter = 'All Batches';
  String _statusFilter = 'All Status';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRelationalData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRelationalData() async {
    final db = FirebaseFirestore.instance;
    final results = await Future.wait([
      db.collection('students').where('deleted_at', isNull: true).get(),
      db.collection('courses').where('deleted_at', isNull: true).get(),
      db.collection('batches').where('deleted_at', isNull: true).get(),
    ]);

    if (!mounted) return;
    setState(() {
      studentsList = _dedupeById(results[0].docs.map(_docData).toList());
      coursesList = _dedupeById(
        results[1].docs.map(_docData).where(_isActiveOrLegacy).toList(),
      );
      batchesList = _dedupeById(
        results[2].docs.map(_docData).where(_isActiveOrLegacy).toList(),
      );
      isLoading = false;
    });
  }

  Map<String, dynamic> _docData(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return {...doc.data(), '_docId': doc.id};
  }

  List<Map<String, dynamic>> _dedupeById(List<Map<String, dynamic>> items) {
    final byId = <int, Map<String, dynamic>>{};
    for (final item in items) {
      final id = _int(item['id']);
      if (id != null && !byId.containsKey(id)) byId[id] = item;
    }
    return byId.values.toList()..sort((a, b) => _name(a).compareTo(_name(b)));
  }

  bool _isActiveOrLegacy(Map<String, dynamic> data) {
    final isActive = data['is_active'];
    final status = data['status']?.toString().toLowerCase();
    return (isActive == null || isActive == true) &&
        (status == null || status == 'active');
  }

  String _getStudentName(int? id) => _name(_findById(studentsList, id));
  String _getCourseName(int? id) => _name(_findById(coursesList, id));
  String _getBatchName(int? id) => _name(_findById(batchesList, id));
  Map<String, dynamic>? _studentById(int? id) => _findById(studentsList, id);

  Map<String, dynamic>? _findById(List<Map<String, dynamic>> list, int? id) {
    if (id == null) return null;
    for (final item in list) {
      if (_int(item['id']) == id) return item;
    }
    return null;
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
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (appUser == null ||
            !(appUser.canViewEnrollments || appUser.canManageEnrollments)) {
          return const AccessDeniedScreen();
        }
        final canManage = appUser.canManageEnrollments;

        return Scaffold(
          backgroundColor: const Color(0xFFF6F8FC),
          floatingActionButton: canManage
              ? _NewEnrollmentButton(
                  onPressed: isLoading ? null : () => _showEnrollmentForm(null),
                )
              : null,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(
                  onBack: () => Navigator.pop(context),
                  onRefresh: _loadRelationalData,
                ),
                _SearchAndFilters(
                  controller: _searchController,
                  courseFilter: _courseFilter,
                  batchFilter: _batchFilter,
                  statusFilter: _statusFilter,
                  courseOptions: _filterNames(coursesList, 'All Courses'),
                  batchOptions: _filterNames(batchesList, 'All Batches'),
                  onSearchChanged: (value) {
                    setState(() => _searchQuery = _normalize(value));
                  },
                  onCourseChanged: (value) {
                    if (value != null) setState(() => _courseFilter = value);
                  },
                  onBatchChanged: (value) {
                    if (value != null) setState(() => _batchFilter = value);
                  },
                  onStatusChanged: (value) {
                    if (value != null) setState(() => _statusFilter = value);
                  },
                ),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: _enrollmentsStream,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.waiting &&
                                !snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.hasError) {
                              return const _StateMessage(
                                icon: Icons.cloud_off_rounded,
                                message: 'Enrollments could not be loaded.',
                              );
                            }

                            final docs = snapshot.data?.docs ?? [];
                            final filteredDocs = docs
                                .where(_matchesFilters)
                                .toList();

                            return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 180),
                              child: filteredDocs.isEmpty
                                  ? const _StateMessage(
                                      key: ValueKey('empty-enrollments'),
                                      icon: Icons.assignment_late_rounded,
                                      message: 'No enrollments found.',
                                    )
                                  : ListView.builder(
                                      key: ValueKey(
                                        'enrollments-$_searchQuery-$_courseFilter-$_batchFilter-$_statusFilter',
                                      ),
                                      padding: EdgeInsets.fromLTRB(
                                        20,
                                        8,
                                        20,
                                        MediaQuery.viewPaddingOf(
                                              context,
                                            ).bottom +
                                            104,
                                      ),
                                      itemCount: filteredDocs.length,
                                      itemBuilder: (context, index) {
                                        final doc = filteredDocs[index];
                                        final data = doc.data();
                                        final studentId = _int(
                                          data['student_id'] ??
                                              data['studentId'],
                                        );
                                        final courseId = _int(
                                          data['course_id'] ?? data['courseId'],
                                        );
                                        final batchId = _int(
                                          data['batch_id'] ?? data['batchId'],
                                        );
                                        final enrollmentIntId =
                                            _int(data['id']) ?? 0;

                                        return EnrollmentCard(
                                          enrollment: data,
                                          studentName:
                                              data['studentName']?.toString() ??
                                              _getStudentName(studentId),
                                          courseName:
                                              data['courseName']?.toString() ??
                                              _getCourseName(courseId),
                                          batchName:
                                              data['batchName']?.toString() ??
                                              _getBatchName(batchId),
                                          studentPhoto: _studentById(
                                            studentId,
                                          )?['profile_photo']?.toString(),
                                          onEdit: canManage
                                              ? () => _showEnrollmentForm(doc)
                                              : null,
                                          onDelete: canManage
                                              ? () => _confirmDelete(
                                                  doc.id,
                                                  enrollmentIntId,
                                                )
                                              : null,
                                        );
                                      },
                                    ),
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

  bool _matchesFilters(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final studentId = _int(data['student_id'] ?? data['studentId']);
    final courseId = _int(data['course_id'] ?? data['courseId']);
    final batchId = _int(data['batch_id'] ?? data['batchId']);
    final studentName =
        data['studentName']?.toString() ?? _getStudentName(studentId);
    final courseName =
        data['courseName']?.toString() ?? _getCourseName(courseId);
    final batchName = data['batchName']?.toString() ?? _getBatchName(batchId);
    final status =
        (data['status']?.toString() ??
                (data['isActive'] == false || data['is_active'] == false
                    ? 'inactive'
                    : 'active'))
            .toLowerCase();

    final haystack = _normalize('$studentName $courseName $batchName');
    return (_searchQuery.isEmpty || haystack.contains(_searchQuery)) &&
        (_courseFilter == 'All Courses' || courseName == _courseFilter) &&
        (_batchFilter == 'All Batches' || batchName == _batchFilter) &&
        (_statusFilter == 'All Status' ||
            status == _statusFilter.toLowerCase());
  }

  List<String> _filterNames(List<Map<String, dynamic>> list, String allLabel) {
    final names =
        list.map(_name).where((name) => name != 'Unknown').toSet().toList()
          ..sort();
    return [allLabel, ...names];
  }

  Future<void> _confirmDelete(String docId, int enrollmentIntId) async {
    final confirm =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete enrollment?'),
            content: const Text(
              'Pending fees for this enrollment will be cancelled. Paid fees will remain in history.',
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

    final db = FirebaseFirestore.instance;
    final batch = db.batch();
    final nowIso = DateTime.now().toIso8601String();

    batch.update(db.collection('enrollments').doc(docId), {
      'deleted_at': nowIso,
      'status': 'inactive',
      'isActive': false,
      'is_active': false,
      'updatedAt': FieldValue.serverTimestamp(),
      'updated_at': nowIso,
    });

    final pendingFees = await db
        .collection('fee_payments')
        .where('enrollment_id', isEqualTo: enrollmentIntId)
        .where('status', isEqualTo: 'pending')
        .where('deleted_at', isNull: true)
        .get();

    for (final feeDoc in pendingFees.docs) {
      batch.update(feeDoc.reference, {
        'deleted_at': nowIso,
        'status': 'cancelled',
        'updated_at': nowIso,
      });
    }

    await batch.commit();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Enrollment deleted and pending dues cleared.'),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  void _showEnrollmentForm(
    DocumentSnapshot<Map<String, dynamic>>? existingDoc,
  ) {
    if (studentsList.isEmpty || coursesList.isEmpty || batchesList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ensure you have students, courses, and batches created first.',
          ),
        ),
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return _EnrollmentSheet(
          existingDoc: existingDoc,
          students: studentsList,
          courses: coursesList,
          batches: batchesList,
          onSyncPendingFees: _syncPendingFees,
          onGeneratePendingFees: _generatePendingFees,
        );
      },
    );
  }

  Future<void> _syncPendingFees(int enrollmentId, double newFinalFees) async {
    final db = FirebaseFirestore.instance;
    final feesSnapshot = await db
        .collection('fee_payments')
        .where('enrollment_id', isEqualTo: enrollmentId)
        .where('deleted_at', isNull: true)
        .get();

    double totalPaid = 0.0;
    final pendingDocs = <DocumentSnapshot>[];

    for (final doc in feesSnapshot.docs) {
      final data = doc.data();
      if (data['status'] == 'paid' || data['status'] == 'partially_paid') {
        totalPaid += _amount(data['amount_paid']);
      }
      if (data['status'] == 'pending') pendingDocs.add(doc);
    }

    if (pendingDocs.isEmpty) return;

    final remainingAmount = (newFinalFees - totalPaid).clamp(
      0.0,
      double.infinity,
    );
    final newAmountStr = (remainingAmount / pendingDocs.length).toStringAsFixed(
      2,
    );

    final batch = db.batch();
    for (final doc in pendingDocs) {
      batch.update(doc.reference, {
        'total_amount': newAmountStr,
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
    await batch.commit();
  }

  Future<void> _generatePendingFees({
    required int enrollmentId,
    required int studentId,
    required double finalFees,
    required String structure,
    required int installments,
    required int courseId,
    required DateTime startDate,
    required DateTime nextDueDate,
  }) async {
    final batch = FirebaseFirestore.instance.batch();
    final now = DateTime.now();

    if (structure == 'one_time') {
      final docRef = FirebaseFirestore.instance
          .collection('fee_payments')
          .doc();
      batch.set(docRef, {
        'id': DateTime.now().millisecondsSinceEpoch % 100000,
        'student_id': studentId,
        'studentId': studentId.toString(),
        'enrollment_id': enrollmentId,
        'enrollmentId': enrollmentId.toString(),
        'total_amount': finalFees.toStringAsFixed(2),
        'amount_paid': '0.00',
        'status': 'pending',
        'due_date': nextDueDate.toIso8601String(),
        'dueDate': Timestamp.fromDate(nextDueDate),
        'month_year': 'Full Course',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
        'deleted_at': null,
      });
    } else if (structure == 'monthly') {
      final course = _findById(coursesList, courseId);
      final duration = _int(course?['duration_months']) ?? 12;
      final monthlyAmount = duration <= 0 ? finalFees : finalFees / duration;

      for (var i = 0; i < duration; i++) {
        final targetMonth = DateTime(startDate.year, startDate.month + i);
        final docRef = FirebaseFirestore.instance
            .collection('fee_payments')
            .doc();
        batch.set(docRef, {
          'id': (DateTime.now().millisecondsSinceEpoch + i) % 100000,
          'student_id': studentId,
          'studentId': studentId.toString(),
          'enrollment_id': enrollmentId,
          'enrollmentId': enrollmentId.toString(),
          'total_amount': monthlyAmount.toStringAsFixed(2),
          'amount_paid': '0.00',
          'status': 'pending',
          'installmentNo': i + 1,
          'feeType': 'installment',
          'due_date': DateTime(
            targetMonth.year,
            targetMonth.month,
            nextDueDate.day,
          ).toIso8601String(),
          'dueDate': Timestamp.fromDate(
            DateTime(targetMonth.year, targetMonth.month, nextDueDate.day),
          ),
          'month_year': DateFormat('MMM yyyy').format(targetMonth),
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
          'deleted_at': null,
        });
      }
    } else {
      final count = installments.clamp(1, 24);
      final instAmount = finalFees / count;
      for (var i = 0; i < count; i++) {
        final docRef = FirebaseFirestore.instance
            .collection('fee_payments')
            .doc();
        batch.set(docRef, {
          'id': (DateTime.now().millisecondsSinceEpoch + i) % 100000,
          'student_id': studentId,
          'studentId': studentId.toString(),
          'enrollment_id': enrollmentId,
          'enrollmentId': enrollmentId.toString(),
          'total_amount': instAmount.toStringAsFixed(2),
          'amount_paid': '0.00',
          'status': 'pending',
          'installmentNo': i + 1,
          'feeType': 'installment',
          'due_date': DateTime(
            nextDueDate.year,
            nextDueDate.month + i,
            nextDueDate.day,
          ).toIso8601String(),
          'dueDate': Timestamp.fromDate(
            DateTime(nextDueDate.year, nextDueDate.month + i, nextDueDate.day),
          ),
          'month_year': 'Inst. ${i + 1} of $count',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
          'deleted_at': null,
        });
      }
    }
    await batch.commit();
  }
}

class _EnrollmentSheet extends StatefulWidget {
  const _EnrollmentSheet({
    required this.existingDoc,
    required this.students,
    required this.courses,
    required this.batches,
    required this.onSyncPendingFees,
    required this.onGeneratePendingFees,
  });

  final DocumentSnapshot<Map<String, dynamic>>? existingDoc;
  final List<Map<String, dynamic>> students;
  final List<Map<String, dynamic>> courses;
  final List<Map<String, dynamic>> batches;
  final Future<void> Function(int enrollmentId, double finalFees)
  onSyncPendingFees;
  final Future<void> Function({
    required int enrollmentId,
    required int studentId,
    required double finalFees,
    required String structure,
    required int installments,
    required int courseId,
    required DateTime startDate,
    required DateTime nextDueDate,
  })
  onGeneratePendingFees;

  @override
  State<_EnrollmentSheet> createState() => _EnrollmentSheetState();
}

class _EnrollmentSheetState extends State<_EnrollmentSheet> {
  late final bool _isEditing;
  late final Map<String, dynamic> _data;
  late final TextEditingController _discountCtrl;
  late final TextEditingController _reasonCtrl;
  late final TextEditingController _finalFeesCtrl;
  late final TextEditingController _notesCtrl;
  final Set<String> _activeEnrollmentKeys = {};

  int? _selectedStudentId;
  int? _selectedCourseId;
  int? _selectedBatchId;
  String _status = 'active';
  String _paymentStructure = 'one_time';
  int _installmentCount = 3;
  DateTime _startDate = DateTime.now();
  DateTime _nextDueDate = DateTime.now().add(const Duration(days: 7));
  bool _finalFeesEdited = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.existingDoc != null;
    _data = widget.existingDoc?.data() ?? {};
    _selectedStudentId = _safeSelectedId(
      widget.students,
      _data['student_id'] ?? _data['studentId'],
    );
    _selectedCourseId = _safeSelectedId(
      widget.courses,
      _data['course_id'] ?? _data['courseId'],
    );
    _selectedBatchId = _safeSelectedId(
      widget.batches,
      _data['batch_id'] ?? _data['batchId'],
    );
    _selectedBatchId = _safeSelectedId(_filteredBatches, _selectedBatchId);
    _status = (_data['status']?.toString() ?? 'active').toLowerCase();
    if (!['active', 'inactive', 'suspended'].contains(_status)) {
      _status = 'active';
    }
    _paymentStructure = _normalizePlan(
      _data['paymentStructure'] ??
          _data['planType'] ??
          _data['payment_structure'],
    );
    _installmentCount =
        _int(_data['installmentCount'] ?? _data['installment_count']) ??
        _countForPlan(_paymentStructure);
    _startDate =
        _date(_data['startDate'] ?? _data['start_date']) ?? DateTime.now();
    _nextDueDate =
        _date(
          _data['nextDueDate'] ??
              _data['next_due_date'] ??
              _data['valid_until'],
        ) ??
        DateTime.now().add(const Duration(days: 7));
    _discountCtrl = TextEditingController(
      text: _amount(
        _data['discount_amount'] ?? _data['discount'],
      ).toStringAsFixed(0),
    );
    _reasonCtrl = TextEditingController(
      text:
          _data['discountReason']?.toString() ??
          _data['discount_reason']?.toString() ??
          '',
    );
    _finalFeesCtrl = TextEditingController(
      text: _amount(
        _data['final_fees'] ?? _data['finalFees'] ?? _data['finalFee'],
      ).toStringAsFixed(0),
    );
    _notesCtrl = TextEditingController(text: _data['notes']?.toString() ?? '');
    _finalFeesEdited = _isEditing && _amount(_finalFeesCtrl.text) > 0;
    if (!_isEditing && _selectedCourseId != null) _recalculateFees(force: true);
    _loadActiveEnrollmentKeys();
  }

  @override
  void dispose() {
    _discountCtrl.dispose();
    _reasonCtrl.dispose();
    _finalFeesCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredBatches {
    if (_selectedCourseId == null) return widget.batches;
    final courseBatches = widget.batches
        .where(
          (batch) =>
              _int(batch['course_id'] ?? batch['courseId']) ==
              _selectedCourseId,
        )
        .toList();
    return courseBatches.isEmpty ? widget.batches : courseBatches;
  }

  Map<String, dynamic>? get _selectedCourse =>
      _findById(widget.courses, _selectedCourseId);
  Map<String, dynamic>? get _selectedBatch =>
      _findById(widget.batches, _selectedBatchId);
  Map<String, dynamic>? get _selectedStudent =>
      _findById(widget.students, _selectedStudentId);

  double get _courseFeeReference => _courseFee(_selectedCourse);
  double get _discount => _amount(_discountCtrl.text);
  double get _finalFees => _amount(_finalFeesCtrl.text);

  void _recalculateFees({bool force = false}) {
    if (!force && _finalFeesEdited && _finalFees > 0) return;
    final finalFee = (_courseFeeReference - _discount).clamp(
      0.0,
      double.infinity,
    );
    _finalFeesCtrl.text = finalFee.toStringAsFixed(0);
  }

  Future<void> _loadActiveEnrollmentKeys() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('enrollments')
        .where('deleted_at', isNull: true)
        .get();
    if (!mounted) return;
    setState(() {
      _activeEnrollmentKeys
        ..clear()
        ..addAll(
          snapshot.docs
              .map((doc) {
                final data = doc.data();
                final status = data['status']?.toString().toLowerCase();
                final isActive =
                    data['isActive'] != false && data['is_active'] != false;
                if ((status != null && status != 'active') || !isActive) {
                  return null;
                }
                return _enrollmentKey(
                  studentId: _int(data['student_id'] ?? data['studentId']),
                  courseId: _int(data['course_id'] ?? data['courseId']),
                  batchId: _int(data['batch_id'] ?? data['batchId']),
                );
              })
              .where((key) => key != null)
              .cast<String>(),
        );
    });
  }

  int? _safeStudentAfterContextChange(int? studentId) {
    if (studentId == null) return null;
    final filtered = _prioritizedStudents(
      students: widget.students,
      course: _selectedCourse,
      batch: _selectedBatch,
    );
    return filtered.any((student) => _int(student['id']) == studentId)
        ? studentId
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: FractionallySizedBox(
        heightFactor: 0.92,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
              child: Row(
                children: [
                  Container(
                    height: 5,
                    width: 46,
                    decoration: BoxDecoration(
                      color: AppTheme.border,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  MediaQuery.viewPaddingOf(context).bottom + 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isEditing ? 'Edit Enrollment' : 'New Enrollment',
                      style: const TextStyle(
                        color: AppTheme.text,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Student course and fee setup',
                      style: TextStyle(color: AppTheme.muted),
                    ),
                    const SizedBox(height: 18),
                    _FormSection(
                      title: 'Course, Batch & Student',
                      icon: Icons.school_rounded,
                      children: [
                        _IntDropdown(
                          label: 'Course',
                          value: _selectedCourseId,
                          items: widget.courses,
                          itemLabel: (item) {
                            final category = item?['category']?.toString();
                            final name = _name(item);
                            return category == null || category.isEmpty
                                ? name
                                : '$name (${category.toUpperCase()})';
                          },
                          onChanged: (value) => setState(() {
                            _selectedCourseId = value;
                            _selectedBatchId = _safeSelectedId(
                              _filteredBatches,
                              _selectedBatchId,
                            );
                            _selectedStudentId = _safeStudentAfterContextChange(
                              _selectedStudentId,
                            );
                            _recalculateFees();
                          }),
                        ),
                        const SizedBox(height: 12),
                        _IntDropdown(
                          label: 'Batch',
                          value: _safeSelectedId(
                            _filteredBatches,
                            _selectedBatchId,
                          ),
                          items: _filteredBatches,
                          itemLabel: _name,
                          hint: _filteredBatches.isEmpty
                              ? 'No active batches available'
                              : 'Choose batch',
                          onChanged: _filteredBatches.isEmpty
                              ? null
                              : (value) => setState(() {
                                  _selectedBatchId = value;
                                  _selectedStudentId =
                                      _safeStudentAfterContextChange(
                                        _selectedStudentId,
                                      );
                                }),
                        ),
                        const SizedBox(height: 12),
                        _StudentPickerField(
                          student: _selectedStudent,
                          course: _selectedCourse,
                          batch: _selectedBatch,
                          students: widget.students,
                          activeEnrollmentKeys: _activeEnrollmentKeys,
                          onSelected: (studentId) => setState(() {
                            _selectedStudentId = studentId;
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _FormSection(
                      title: 'Financial Setup',
                      icon: Icons.account_balance_wallet_rounded,
                      tone: AppTheme.success,
                      children: [
                        _ReadOnlyTile(
                          label: 'Course Fee Reference',
                          value: _money(_courseFeeReference),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _TextField(
                                controller: _discountCtrl,
                                label: 'Discount Amount',
                                keyboardType: TextInputType.number,
                                onChanged: (_) => setState(_recalculateFees),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _TextField(
                                controller: _finalFeesCtrl,
                                label: 'Final Fees',
                                keyboardType: TextInputType.number,
                                onChanged: (_) =>
                                    setState(() => _finalFeesEdited = true),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _TextField(
                          controller: _reasonCtrl,
                          label: 'Discount Reason',
                          hint: 'Optional',
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _FormSection(
                      title: 'Payment Schedule / Pending Dues',
                      icon: Icons.event_note_rounded,
                      tone: AppTheme.warning,
                      children: [
                        _StringDropdown(
                          label: 'Payment Structure',
                          value: _paymentStructure,
                          items: _paymentOptions,
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _paymentStructure = value;
                              _installmentCount = _countForPlan(value);
                            });
                          },
                        ),
                        if (_paymentStructure == 'custom') ...[
                          const SizedBox(height: 12),
                          _StepperField(
                            label: 'Installment Count',
                            value: _installmentCount,
                            onChanged: (value) => setState(() {
                              _installmentCount = value.clamp(1, 24);
                            }),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _DateTile(
                                label: 'Start Date',
                                date: _startDate,
                                onTap: () => _pickDate(
                                  initial: _startDate,
                                  onPicked: (date) =>
                                      setState(() => _startDate = date),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _DateTile(
                                label: 'Next Due Date',
                                date: _nextDueDate,
                                onTap: () => _pickDate(
                                  initial: _nextDueDate,
                                  onPicked: (date) =>
                                      setState(() => _nextDueDate = date),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _SchedulePreview(
                          structure: _paymentStructure,
                          count: _installmentCount,
                          finalFees: _finalFees,
                          startDate: _startDate,
                          nextDueDate: _nextDueDate,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _FormSection(
                      title: 'Notes / Status',
                      icon: Icons.notes_rounded,
                      children: [
                        _TextField(
                          controller: _notesCtrl,
                          label: 'Notes',
                          hint: 'Optional',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),
                        _StringDropdown(
                          label: 'Status',
                          value: _status,
                          items: const {
                            'active': 'Active',
                            'inactive': 'Inactive',
                            'suspended': 'Suspended',
                          },
                          onChanged: (value) {
                            if (value != null) setState(() => _status = value);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            _SaveBar(
              isEditing: _isEditing,
              isSaving: _isSaving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate({
    required DateTime initial,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) onPicked(picked);
  }

  Future<void> _save() async {
    final safeBatchId = _safeSelectedId(_filteredBatches, _selectedBatchId);
    if (_selectedStudentId == null ||
        _selectedCourseId == null ||
        safeBatchId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select student, course, and batch.'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final hasDuplicate = await _hasDuplicateEnrollment(
        studentId: _selectedStudentId!,
        courseId: _selectedCourseId!,
        batchId: safeBatchId,
        currentDocId: widget.existingDoc?.id,
      );
      if (hasDuplicate) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'This student is already enrolled in this course/batch.',
            ),
            backgroundColor: AppTheme.warning,
          ),
        );
        return;
      }

      final student = _findById(widget.students, _selectedStudentId);
      final course = _findById(widget.courses, _selectedCourseId);
      final batch = _findById(widget.batches, safeBatchId);
      final now = DateTime.now();
      final nowIso = now.toIso8601String();
      final enrollmentIntId =
          _int(_data['id']) ?? DateTime.now().millisecondsSinceEpoch % 100000;
      final isActive = _status == 'active';
      final payload = {
        ..._data,
        'id': enrollmentIntId,
        'student_id': _selectedStudentId,
        'studentId': _selectedStudentId.toString(),
        'studentName': _name(student),
        'course_id': _selectedCourseId,
        'courseId': _selectedCourseId.toString(),
        'courseName': _name(course),
        'batch_id': safeBatchId,
        'batchId': safeBatchId.toString(),
        'batchName': _name(batch),
        'courseFeeReference': _courseFeeReference,
        'course_fee_reference': _courseFeeReference.toStringAsFixed(2),
        'discount': _discount,
        'discount_amount': _discount.toStringAsFixed(2),
        'discountReason': _reasonCtrl.text.trim(),
        'discount_reason': _reasonCtrl.text.trim(),
        'finalFees': _finalFees,
        'finalFee': _finalFees,
        'final_fees': _finalFees.toStringAsFixed(2),
        'paymentStructure': _paymentStructure,
        'payment_structure': _paymentStructure,
        'planType': _paymentStructure,
        'installmentCount': _installmentCount,
        'installment_count': _installmentCount,
        'startDate': Timestamp.fromDate(_startDate),
        'start_date': _startDate.toIso8601String(),
        'nextDueDate': Timestamp.fromDate(_nextDueDate),
        'next_due_date': _nextDueDate.toIso8601String(),
        'valid_until': _nextDueDate.toIso8601String(),
        'notes': _notesCtrl.text.trim(),
        'status': _status,
        'isActive': isActive,
        'is_active': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
        'updated_at': nowIso,
        'deleted_at': null,
      };

      if (_isEditing) {
        await FirebaseFirestore.instance
            .collection('enrollments')
            .doc(widget.existingDoc!.id)
            .set(payload, SetOptions(merge: true));
        await widget.onSyncPendingFees(enrollmentIntId, _finalFees);
      } else {
        payload['enrolled_at'] = nowIso;
        payload['createdAt'] = FieldValue.serverTimestamp();
        payload['created_at'] = nowIso;
        await FirebaseFirestore.instance.collection('enrollments').add(payload);
        await widget.onGeneratePendingFees(
          enrollmentId: enrollmentIntId,
          studentId: _selectedStudentId!,
          finalFees: _finalFees,
          structure: _paymentStructure,
          installments: _installmentCount,
          courseId: _selectedCourseId!,
          startDate: _startDate,
          nextDueDate: _nextDueDate,
        );
      }

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Enrollment and pending fees synced.'
                : 'Enrollment and pending invoices generated.',
          ),
          backgroundColor: AppTheme.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Enrollment could not be saved: $e'),
          backgroundColor: AppTheme.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<bool> _hasDuplicateEnrollment({
    required int studentId,
    required int courseId,
    required int batchId,
    required String? currentDocId,
  }) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('enrollments')
        .where('student_id', isEqualTo: studentId)
        .where('deleted_at', isNull: true)
        .get();

    for (final doc in snapshot.docs) {
      if (doc.id == currentDocId) continue;
      final data = doc.data();
      if (_int(data['course_id'] ?? data['courseId']) != courseId ||
          _int(data['batch_id'] ?? data['batchId']) != batchId) {
        continue;
      }
      final status = data['status']?.toString().toLowerCase();
      final isActive = data['isActive'] != false && data['is_active'] != false;
      if ((status == null || status == 'active') && isActive) return true;
    }
    return false;
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack, required this.onRefresh});

  final VoidCallback onBack;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 12, 14, 8),
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
                  'Enrollments',
                  style: TextStyle(
                    color: AppTheme.text,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Student course and fee setup',
                  style: TextStyle(color: AppTheme.muted, fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.primary),
          ),
        ],
      ),
    );
  }
}

class _SearchAndFilters extends StatelessWidget {
  const _SearchAndFilters({
    required this.controller,
    required this.courseFilter,
    required this.batchFilter,
    required this.statusFilter,
    required this.courseOptions,
    required this.batchOptions,
    required this.onSearchChanged,
    required this.onCourseChanged,
    required this.onBatchChanged,
    required this.onStatusChanged,
  });

  final TextEditingController controller;
  final String courseFilter;
  final String batchFilter;
  final String statusFilter;
  final List<String> courseOptions;
  final List<String> batchOptions;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onCourseChanged;
  final ValueChanged<String?> onBatchChanged;
  final ValueChanged<String?> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
      child: Column(
        children: [
          TextField(
            controller: controller,
            onChanged: onSearchChanged,
            style: const TextStyle(color: AppTheme.text),
            decoration: InputDecoration(
              hintText: 'Search student, course or batch...',
              hintStyle: const TextStyle(color: AppTheme.muted),
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: controller.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        controller.clear();
                        onSearchChanged('');
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _FilterDropdown(
                  value: courseFilter,
                  items: courseOptions,
                  icon: Icons.menu_book_rounded,
                  onChanged: onCourseChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _FilterDropdown(
                  value: batchFilter,
                  items: batchOptions,
                  icon: Icons.groups_rounded,
                  onChanged: onBatchChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _FilterDropdown(
                  value: statusFilter,
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

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
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
    final safeItems = items.toSet().toList();
    final safeValue = safeItems.contains(value) ? value : safeItems.first;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: safeValue,
          isExpanded: true,
          iconEnabledColor: AppTheme.primary,
          dropdownColor: AppTheme.surface,
          style: const TextStyle(color: AppTheme.text, fontSize: 12),
          items: safeItems
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Row(
                    children: [
                      Icon(icon, size: 14, color: AppTheme.primary),
                      const SizedBox(width: 6),
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

class _NewEnrollmentButton extends StatelessWidget {
  const _NewEnrollmentButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: onPressed,
        icon: const Icon(Icons.assignment_add),
        label: const Text(
          'New Enrollment',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _StudentPickerField extends StatelessWidget {
  const _StudentPickerField({
    required this.student,
    required this.course,
    required this.batch,
    required this.students,
    required this.activeEnrollmentKeys,
    required this.onSelected,
  });

  final Map<String, dynamic>? student;
  final Map<String, dynamic>? course;
  final Map<String, dynamic>? batch;
  final List<Map<String, dynamic>> students;
  final Set<String> activeEnrollmentKeys;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final selectedName = _name(student);
    return InkWell(
      onTap: () => _openPicker(context),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFDDE6F3)),
        ),
        child: Row(
          children: [
            _StudentAvatar(student: student, radius: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student == null ? 'Select Student' : selectedName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: student == null ? AppTheme.muted : AppTheme.text,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (student != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      _studentSummary(student!),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.search_rounded, color: AppTheme.primary),
          ],
        ),
      ),
    );
  }

  Future<void> _openPicker(BuildContext context) async {
    final selectedId = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => _StudentPickerSheet(
        students: students,
        course: course,
        batch: batch,
        activeEnrollmentKeys: activeEnrollmentKeys,
      ),
    );
    if (selectedId != null) onSelected(selectedId);
  }
}

class _StudentPickerSheet extends StatefulWidget {
  const _StudentPickerSheet({
    required this.students,
    required this.course,
    required this.batch,
    required this.activeEnrollmentKeys,
  });

  final List<Map<String, dynamic>> students;
  final Map<String, dynamic>? course;
  final Map<String, dynamic>? batch;
  final Set<String> activeEnrollmentKeys;

  @override
  State<_StudentPickerSheet> createState() => _StudentPickerSheetState();
}

class _StudentPickerSheetState extends State<_StudentPickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = _contextMatchedStudents(
      students: widget.students,
      course: widget.course,
      batch: widget.batch,
    );
    final usingFallback = primary.isEmpty;
    final base = usingFallback ? widget.students : primary;
    final filtered = base.where((student) {
      if (_query.isEmpty) return true;
      return _studentSearchText(student).contains(_query);
    }).toList();

    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.72,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Select Student',
                      style: TextStyle(
                        color: AppTheme.text,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _searchController,
                onChanged: (value) =>
                    setState(() => _query = _normalize(value)),
                style: const TextStyle(color: AppTheme.text),
                decoration: InputDecoration(
                  hintText: 'Search name, phone, parent, course, batch...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
              ),
              if (usingFallback) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.warningSoft,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.warning.withValues(alpha: 0.28),
                    ),
                  ),
                  child: const Text(
                    'No exact course match. Showing all students.',
                    style: TextStyle(
                      color: AppTheme.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 160),
                  child: filtered.isEmpty
                      ? const _StateMessage(
                          key: ValueKey('no-students-found'),
                          icon: Icons.person_search_rounded,
                          message: 'No students found',
                        )
                      : ListView.builder(
                          key: ValueKey('students-$_query-${filtered.length}'),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final student = filtered[index];
                            final studentId = _int(student['id']);
                            final alreadyEnrolled = widget.activeEnrollmentKeys
                                .contains(
                                  _enrollmentKey(
                                    studentId: studentId,
                                    courseId: _int(widget.course?['id']),
                                    batchId: _int(widget.batch?['id']),
                                  ),
                                );
                            return _StudentPickerTile(
                              student: student,
                              alreadyEnrolled: alreadyEnrolled,
                              onTap: studentId == null
                                  ? null
                                  : () => Navigator.pop(context, studentId),
                            );
                          },
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

class _StudentPickerTile extends StatelessWidget {
  const _StudentPickerTile({
    required this.student,
    required this.alreadyEnrolled,
    required this.onTap,
  });

  final Map<String, dynamic> student;
  final bool alreadyEnrolled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final status = student['status']?.toString() ?? 'active';
    final isActive = status.toLowerCase() == 'active';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              _StudentAvatar(student: student, radius: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _name(student),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.text,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _studentContact(student),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.muted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _studentSummary(student),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.mutedLight,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _MiniBadge(
                    label: isActive ? 'Active' : 'Inactive',
                    color: isActive ? AppTheme.success : AppTheme.danger,
                  ),
                  if (alreadyEnrolled) ...[
                    const SizedBox(height: 6),
                    const _MiniBadge(
                      label: 'Enrolled',
                      color: AppTheme.primary,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentAvatar extends StatelessWidget {
  const _StudentAvatar({required this.student, required this.radius});

  final Map<String, dynamic>? student;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final photo =
        student?['profile_photo']?.toString() ??
        student?['profilePhoto']?.toString();
    final initial = _name(student).trim().isEmpty ? '?' : _name(student)[0];
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppTheme.primarySoft,
      backgroundImage: photo == null || photo.trim().isEmpty
          ? null
          : NetworkImage(photo),
      child: photo == null || photo.trim().isEmpty
          ? Text(
              initial.toUpperCase(),
              style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w900,
              ),
            )
          : null,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.title,
    required this.icon,
    required this.children,
    this.tone = AppTheme.primary,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: tone, size: 19),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _IntDropdown extends StatelessWidget {
  const _IntDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.hint,
  });

  final String label;
  final int? value;
  final List<Map<String, dynamic>> items;
  final String Function(Map<String, dynamic>? item) itemLabel;
  final ValueChanged<int?>? onChanged;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final ids = <int>{};
    final safeItems = items.where((item) {
      final id = _int(item['id']);
      if (id == null || ids.contains(id)) return false;
      ids.add(id);
      return true;
    }).toList();
    final safeValue = _safeSelectedId(safeItems, value);

    return DropdownButtonFormField<int>(
      key: ValueKey('$label-$safeValue-${safeItems.length}'),
      initialValue: safeValue,
      isExpanded: true,
      dropdownColor: AppTheme.surface,
      style: const TextStyle(color: AppTheme.text),
      decoration: _fieldDecoration(label, hint: hint),
      hint: Text(hint ?? 'Select $label'),
      items: safeItems
          .map(
            (item) => DropdownMenuItem<int>(
              value: _int(item['id']),
              child: Text(
                itemLabel(item),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppTheme.text),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _StringDropdown extends StatelessWidget {
  const _StringDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final Map<String, String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final safeValue = items.containsKey(value) ? value : items.keys.first;
    return DropdownButtonFormField<String>(
      key: ValueKey('$label-$safeValue'),
      initialValue: safeValue,
      isExpanded: true,
      dropdownColor: AppTheme.surface,
      style: const TextStyle(color: AppTheme.text),
      decoration: _fieldDecoration(label),
      items: items.entries
          .map(
            (entry) => DropdownMenuItem(
              value: entry.key,
              child: Text(
                entry.value,
                style: const TextStyle(color: AppTheme.text),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType,
    this.maxLines = 1,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      style: const TextStyle(color: AppTheme.text),
      decoration: _fieldDecoration(label, hint: hint),
    );
  }
}

class _ReadOnlyTile extends StatelessWidget {
  const _ReadOnlyTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppTheme.muted, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.text,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: AppTheme.muted, fontSize: 12),
            ),
            const SizedBox(height: 5),
            Text(
              DateFormat('dd MMM yyyy').format(date),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.text,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepperField extends StatelessWidget {
  const _StepperField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$label: $value',
              style: const TextStyle(
                color: AppTheme.text,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            onPressed: value <= 1 ? null : () => onChanged(value - 1),
            icon: const Icon(Icons.remove_rounded),
          ),
          IconButton(
            onPressed: value >= 24 ? null : () => onChanged(value + 1),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}

class _SchedulePreview extends StatelessWidget {
  const _SchedulePreview({
    required this.structure,
    required this.count,
    required this.finalFees,
    required this.startDate,
    required this.nextDueDate,
  });

  final String structure;
  final int count;
  final double finalFees;
  final DateTime startDate;
  final DateTime nextDueDate;

  @override
  Widget build(BuildContext context) {
    final rows = _previewRows();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.warningSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.warning.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Schedule Preview',
            style: TextStyle(color: AppTheme.text, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          ...rows.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      row.$1,
                      style: const TextStyle(color: AppTheme.muted),
                    ),
                  ),
                  Text(
                    row.$2,
                    style: const TextStyle(
                      color: AppTheme.text,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<(String, String)> _previewRows() {
    if (structure == 'one_time') {
      return [
        (
          'Full Course / ${DateFormat('dd MMM').format(nextDueDate)}',
          _money(finalFees),
        ),
      ];
    }
    final safeCount = structure == 'monthly' ? 3 : count.clamp(1, 24);
    final label = structure == 'monthly'
        ? 'First 3 months'
        : '$safeCount installments';
    return [
      (label, _money(safeCount == 0 ? 0 : finalFees / safeCount)),
      ('Starts', DateFormat('dd MMM yyyy').format(startDate)),
      ('Next due', DateFormat('dd MMM yyyy').format(nextDueDate)),
    ];
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({
    required this.isEditing,
    required this.isSaving,
    required this.onPressed,
  });

  final bool isEditing;
  final bool isSaving;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.viewPaddingOf(context).bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: isSaving ? null : onPressed,
          icon: isSaving
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.check_rounded),
          label: Text(isEditing ? 'Save Enrollment' : 'Create Enrollment'),
        ),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({super.key, required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.mutedLight, size: 42),
          const SizedBox(height: 10),
          Text(message, style: const TextStyle(color: AppTheme.muted)),
        ],
      ),
    );
  }
}

InputDecoration _fieldDecoration(String label, {String? hint}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    filled: true,
    fillColor: const Color(0xFFF8FAFC),
    labelStyle: const TextStyle(color: AppTheme.muted),
    hintStyle: const TextStyle(color: AppTheme.muted),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFDDE6F3)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFDDE6F3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppTheme.primary, width: 1.4),
    ),
  );
}

const _paymentOptions = {
  'one_time': 'One Time Payment',
  'monthly': 'Monthly',
  'installments_3': '3 Installments',
  'installments_4': '4 Installments',
  'custom': 'Custom',
};

List<Map<String, dynamic>> _prioritizedStudents({
  required List<Map<String, dynamic>> students,
  required Map<String, dynamic>? course,
  required Map<String, dynamic>? batch,
}) {
  final activeStudents = _activeStudents(students);
  final prioritized = _contextMatchedStudents(
    students: students,
    course: course,
    batch: batch,
  );
  return prioritized.isEmpty ? activeStudents : prioritized;
}

List<Map<String, dynamic>> _contextMatchedStudents({
  required List<Map<String, dynamic>> students,
  required Map<String, dynamic>? course,
  required Map<String, dynamic>? batch,
}) {
  final activeStudents = students.where((student) {
    final status = student['status']?.toString().toLowerCase();
    return status == null || status == 'active';
  }).toList();
  return activeStudents.where((student) {
    return _matchesStudentCourse(student, course) &&
        _matchesStudentBatch(student, batch);
  }).toList();
}

List<Map<String, dynamic>> _activeStudents(
  List<Map<String, dynamic>> students,
) {
  return students.where((student) {
    final status = student['status']?.toString().toLowerCase();
    return status == null || status == 'active';
  }).toList();
}

bool _matchesStudentCourse(
  Map<String, dynamic> student,
  Map<String, dynamic>? course,
) {
  if (course == null) return true;
  final studentCourseId = _int(student['course_id'] ?? student['courseId']);
  final courseId = _int(course['id']);
  final studentCourseName = _normalize(
    student['courseName']?.toString() ?? student['course']?.toString() ?? '',
  );
  final courseName = _normalize(_name(course));
  final hasNoCourse =
      studentCourseId == null && studentCourseName.trim().isEmpty;
  return hasNoCourse ||
      (studentCourseId != null && studentCourseId == courseId) ||
      (studentCourseName.isNotEmpty && studentCourseName == courseName);
}

bool _matchesStudentBatch(
  Map<String, dynamic> student,
  Map<String, dynamic>? batch,
) {
  if (batch == null) return true;
  final studentBatchId = _int(student['batch_id'] ?? student['batchId']);
  final batchId = _int(batch['id']);
  final studentBatchName = _normalize(
    student['batchName']?.toString() ?? student['batch']?.toString() ?? '',
  );
  final batchName = _normalize(_name(batch));
  final hasNoBatch = studentBatchId == null && studentBatchName.trim().isEmpty;
  return hasNoBatch ||
      (studentBatchId != null && studentBatchId == batchId) ||
      (studentBatchName.isNotEmpty && studentBatchName == batchName);
}

String _studentContact(Map<String, dynamic> student) {
  final phone =
      student['phone']?.toString() ??
      student['parentPhone']?.toString() ??
      student['parent_phone']?.toString() ??
      student['guardian_phone']?.toString();
  return phone == null || phone.trim().isEmpty ? 'Phone not set' : phone;
}

String _studentSummary(Map<String, dynamic> student) {
  final parts = [
    student['className']?.toString() ??
        student['standard']?.toString() ??
        student['class']?.toString(),
    student['courseName']?.toString() ?? student['course']?.toString(),
    student['batchName']?.toString() ?? student['batch']?.toString(),
  ].where((value) => value != null && value.trim().isNotEmpty).cast<String>();
  return parts.isEmpty ? 'Academic details not set' : parts.join(' / ');
}

String _studentSearchText(Map<String, dynamic> student) {
  return _normalize(
    [
      _name(student),
      student['phone'],
      student['parentPhone'],
      student['parent_phone'],
      student['parentName'],
      student['parent_name'],
      student['guardian_phone'],
      student['guardian_name'],
      student['courseName'],
      student['course'],
      student['batchName'],
      student['batch'],
      student['className'],
      student['standard'],
      student['class'],
    ].whereType<Object>().join(' '),
  );
}

String? _enrollmentKey({int? studentId, int? courseId, int? batchId}) {
  if (studentId == null || courseId == null || batchId == null) return null;
  return '$studentId|$courseId|$batchId';
}

String _normalizePlan(dynamic value) {
  final text = value?.toString() ?? 'one_time';
  return switch (text) {
    'oneTime' || 'one-time' || 'one_time' => 'one_time',
    'monthly' => 'monthly',
    'installments_3' => 'installments_3',
    'installments_4' => 'installments_4',
    'installments' => 'installments_3',
    'custom' => 'custom',
    _ => 'one_time',
  };
}

int _countForPlan(String plan) {
  return switch (plan) {
    'installments_3' => 3,
    'installments_4' => 4,
    'custom' => 3,
    _ => 1,
  };
}

int? _safeSelectedId(List<Map<String, dynamic>> items, dynamic value) {
  final selected = _int(value);
  if (selected == null) return null;
  var count = 0;
  for (final item in items) {
    if (_int(item['id']) == selected) count++;
  }
  return count == 1 ? selected : null;
}

Map<String, dynamic>? _findById(List<Map<String, dynamic>> list, int? id) {
  if (id == null) return null;
  for (final item in list) {
    if (_int(item['id']) == id) return item;
  }
  return null;
}

String _name(Map<String, dynamic>? item) {
  final value = item?['name'] ?? item?['displayName'] ?? item?['title'];
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? 'Unknown' : text;
}

String _normalize(String value) {
  return value.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
}

int? _int(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double _amount(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime? _date(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

double _courseFee(Map<String, dynamic>? course) {
  return _amount(
    course?['fees_amount'] ??
        course?['yearly_fees'] ??
        course?['monthly_fees'] ??
        course?['finalFee'],
  );
}

String _money(double value) => 'Rs ${value.toStringAsFixed(0)}';
