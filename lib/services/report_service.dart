import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

enum ReportType {
  feeCollection,
  pendingFees,
  attendance,
  students,
  batchSummary,
}

extension ReportTypeLabel on ReportType {
  String get label {
    return switch (this) {
      ReportType.feeCollection => 'Fee Collection',
      ReportType.pendingFees => 'Pending Fees',
      ReportType.attendance => 'Attendance',
      ReportType.students => 'Students',
      ReportType.batchSummary => 'Batch Summary',
    };
  }
}

class ReportFilterOption {
  const ReportFilterOption({required this.id, required this.name});

  final String id;
  final String name;
}

class ReportFilters {
  const ReportFilters({
    required this.startDate,
    required this.endDate,
    this.batchId,
    this.courseId,
  });

  final DateTime startDate;
  final DateTime endDate;
  final String? batchId;
  final String? courseId;
}

class ReportMetric {
  const ReportMetric({
    required this.label,
    required this.value,
    required this.tone,
  });

  final String label;
  final String value;
  final ReportTone tone;
}

enum ReportTone { primary, success, warning, danger }

class ReportResult {
  const ReportResult({
    required this.title,
    required this.subtitle,
    required this.metrics,
    required this.columns,
    required this.rows,
    required this.generatedAt,
  });

  final String title;
  final String subtitle;
  final List<ReportMetric> metrics;
  final List<String> columns;
  final List<List<String>> rows;
  final DateTime generatedAt;
}

class ReportFilterData {
  const ReportFilterData({required this.batches, required this.courses});

  final List<ReportFilterOption> batches;
  final List<ReportFilterOption> courses;
}

class ReportService {
  ReportService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<ReportFilterData> loadFilterData() async {
    final results = await Future.wait([
      _firestore.collection('batches').where('deleted_at', isNull: true).get(),
      _firestore.collection('courses').where('deleted_at', isNull: true).get(),
    ]);

    return ReportFilterData(
      batches: results[0].docs.map((doc) {
        final data = doc.data();
        return ReportFilterOption(
          id: _id(data['id'] ?? doc.id),
          name: _string(data['name'] ?? data['batchName']) ?? 'Unnamed Batch',
        );
      }).toList(),
      courses: results[1].docs.map((doc) {
        final data = doc.data();
        return ReportFilterOption(
          id: _id(data['id'] ?? doc.id),
          name: _string(data['name'] ?? data['courseName']) ?? 'Unnamed Course',
        );
      }).toList(),
    );
  }

  Future<ReportResult> generate({
    required ReportType type,
    required ReportFilters filters,
  }) {
    return switch (type) {
      ReportType.feeCollection => _feeCollection(filters),
      ReportType.pendingFees => _pendingFees(filters),
      ReportType.attendance => _attendance(filters),
      ReportType.students => _students(filters),
      ReportType.batchSummary => _batchSummary(filters),
    };
  }

  Future<ReportResult> _feeCollection(ReportFilters filters) async {
    final snap = await _firestore
        .collection('fee_payments')
        .where('deleted_at', isNull: true)
        .limit(700)
        .get();

    final payments = _uniquePaidPayments(
      snap.docs.map((doc) => doc.data()).where((data) {
        if (_status(data) != 'paid') return false;
        final date = _date(
          data['paymentDate'] ?? data['payment_date'] ?? data['paidDate'],
        );
        if (!_inRange(date, filters)) return false;
        return _matchesFilter(data, filters);
      }).toList(),
    );

    final total = payments.fold<double>(
      0,
      (runningTotal, data) => runningTotal + _paid(data),
    );
    final cash = _sumMode(payments, 'cash');
    final upi = _sumMode(payments, 'upi');
    final bank = payments.fold<double>(0, (runningTotal, data) {
      final mode = _mode(data);
      return mode == 'bank' || mode == 'other'
          ? runningTotal + _paid(data)
          : runningTotal;
    });

    return ReportResult(
      title: 'Fee Collection Report',
      subtitle: _rangeLabel(filters),
      generatedAt: DateTime.now(),
      metrics: [
        ReportMetric(
          label: 'Collected',
          value: _money(total),
          tone: ReportTone.success,
        ),
        ReportMetric(
          label: 'Payments',
          value: payments.length.toString(),
          tone: ReportTone.primary,
        ),
        ReportMetric(
          label: 'Cash',
          value: _money(cash),
          tone: ReportTone.success,
        ),
        ReportMetric(
          label: 'UPI',
          value: _money(upi),
          tone: ReportTone.primary,
        ),
        ReportMetric(
          label: 'Bank/Other',
          value: _money(bank),
          tone: ReportTone.warning,
        ),
      ],
      columns: const [
        'Receipt',
        'Student',
        'Amount',
        'Mode',
        'Date',
        'Received By',
      ],
      rows: payments.map((data) {
        final date = _date(
          data['paymentDate'] ?? data['payment_date'] ?? data['paidDate'],
        );
        return [
          _string(data['receiptNo'] ?? data['receipt_number']) ?? '-',
          _string(data['studentName'] ?? data['student_name']) ?? '-',
          _money(_paid(data)),
          _string(
                data['paymentMode'] ?? data['payment_mode'] ?? data['mode'],
              ) ??
              '-',
          date == null ? '-' : DateFormat('dd MMM yyyy').format(date),
          _string(data['receivedByName'] ?? data['received_by_name']) ?? '-',
        ];
      }).toList(),
    );
  }

  Future<ReportResult> _pendingFees(ReportFilters filters) async {
    final results = await Future.wait([
      _firestore.collection('students').where('deleted_at', isNull: true).get(),
      _firestore
          .collection('enrollments')
          .where('deleted_at', isNull: true)
          .get(),
      _firestore
          .collection('fee_payments')
          .where('deleted_at', isNull: true)
          .limit(1000)
          .get(),
    ]);

    final students = results[0].docs.map((doc) => doc.data()).toList();
    final enrollments = <String, Map<String, dynamic>>{};
    for (final doc in results[1].docs) {
      final data = doc.data();
      final sid = _id(data['student_id'] ?? data['studentId']);
      if (sid.isNotEmpty) enrollments[sid] = data;
    }

    final paymentByStudent = <String, List<Map<String, dynamic>>>{};
    for (final doc in results[2].docs) {
      final data = doc.data();
      final sid = _id(data['student_id'] ?? data['studentId']);
      if (sid.isEmpty) continue;
      paymentByStudent.putIfAbsent(sid, () => []).add(data);
    }

    final rows = <List<String>>[];
    var totalPending = 0.0;
    var pendingStudents = 0;
    for (final student in students) {
      if (!_matchesFilter(student, filters)) continue;
      final sid = _id(
        student['id'] ?? student['student_id'] ?? student['studentId'],
      );
      final enrollment = enrollments[sid];
      if (enrollment != null && !_matchesFilter(enrollment, filters)) continue;
      final records = paymentByStudent[sid] ?? const [];
      final totalFee = _amount(
        enrollment?['finalFee'] ??
            enrollment?['final_fees'] ??
            enrollment?['totalFee'] ??
            student['finalFee'] ??
            student['fees_amount'],
      );
      final paid = _uniquePaidPayments(
        records.where((data) => _status(data) == 'paid').toList(),
      ).fold<double>(0, (runningTotal, data) => runningTotal + _paid(data));
      final explicitPending = _amount(
        enrollment?['pending_amount'] ??
            enrollment?['dueAmount'] ??
            enrollment?['balance'] ??
            enrollment?['remaining'],
      );
      final pendingDues = records.fold<double>(0, (runningTotal, data) {
        return _status(data) == 'pending'
            ? runningTotal + _pending(data)
            : runningTotal;
      });
      final pending = explicitPending > 0
          ? explicitPending
          : pendingDues > 0
          ? pendingDues
          : totalFee > paid
          ? totalFee - paid
          : 0.0;
      if (pending <= 0) continue;
      totalPending += pending;
      pendingStudents++;
      final dueDate = records
          .map(
            (data) => _date(
              data['dueDate'] ??
                  data['due_date'] ??
                  data['nextDueDate'] ??
                  data['next_due_date'],
            ),
          )
          .whereType<DateTime>()
          .fold<DateTime?>(null, (earliest, date) {
            if (earliest == null || date.isBefore(earliest)) return date;
            return earliest;
          });
      rows.add([
        _string(student['name'] ?? student['studentName']) ?? '-',
        _string(
              enrollment?['courseName'] ??
                  student['courseName'] ??
                  student['course'],
            ) ??
            '-',
        _string(
              enrollment?['batchName'] ??
                  student['batchName'] ??
                  student['batch'],
            ) ??
            '-',
        totalFee <= 0 ? '-' : _money(totalFee),
        _money(paid),
        _money(pending),
        dueDate == null ? '-' : DateFormat('dd MMM yyyy').format(dueDate),
        paid > 0 ? 'Partial' : 'Pending',
      ]);
    }
    rows.sort((a, b) => _amount(b[5]).compareTo(_amount(a[5])));

    return ReportResult(
      title: 'Pending Fees Report',
      subtitle: _rangeLabel(filters),
      generatedAt: DateTime.now(),
      metrics: [
        ReportMetric(
          label: 'Total Pending',
          value: _money(totalPending),
          tone: ReportTone.warning,
        ),
        ReportMetric(
          label: 'Students',
          value: pendingStudents.toString(),
          tone: ReportTone.primary,
        ),
      ],
      columns: const [
        'Student',
        'Course',
        'Batch',
        'Total Fee',
        'Paid',
        'Pending',
        'Next Due',
        'Status',
      ],
      rows: rows,
    );
  }

  Future<ReportResult> _attendance(ReportFilters filters) async {
    final results = await Future.wait([
      _firestore.collection('attendances').limit(1000).get(),
      _firestore.collection('students').where('deleted_at', isNull: true).get(),
    ]);
    final studentsById = {
      for (final doc in results[1].docs)
        _id(doc.data()['id'] ?? doc.data()['student_id'] ?? doc.id): doc.data(),
    };
    final records = results[0].docs.map((doc) => doc.data()).where((data) {
      final date = _date(data['date'] ?? data['dateKey'] ?? data['created_at']);
      if (!_inRange(date, filters)) return false;
      final student =
          studentsById[_id(data['student_id'] ?? data['studentId'])];
      return _matchesFilter(data, filters) &&
          (student == null || _matchesFilter(student, filters));
    }).toList();

    var present = 0;
    var absent = 0;
    var late = 0;
    var leave = 0;
    for (final record in records) {
      switch (_status(record)) {
        case 'present':
        case 'p':
          present++;
        case 'late':
        case 'l':
          late++;
        case 'leave':
        case 'holiday':
        case 'lv':
          leave++;
        default:
          absent++;
      }
    }
    final effectivePresent = present + late;
    final percent = records.isEmpty
        ? 0
        : ((effectivePresent / records.length) * 100).round();

    return ReportResult(
      title: 'Attendance Report',
      subtitle: _rangeLabel(filters),
      generatedAt: DateTime.now(),
      metrics: [
        ReportMetric(
          label: 'Marked',
          value: records.length.toString(),
          tone: ReportTone.primary,
        ),
        ReportMetric(
          label: 'Present',
          value: present.toString(),
          tone: ReportTone.success,
        ),
        ReportMetric(
          label: 'Absent',
          value: absent.toString(),
          tone: ReportTone.danger,
        ),
        ReportMetric(
          label: 'Late',
          value: late.toString(),
          tone: ReportTone.warning,
        ),
        ReportMetric(
          label: 'Leave',
          value: leave.toString(),
          tone: ReportTone.primary,
        ),
        ReportMetric(
          label: 'Attendance %',
          value: '$percent%',
          tone: ReportTone.success,
        ),
      ],
      columns: const ['Student', 'Batch/Course', 'Date', 'Status', 'Marked By'],
      rows: records.map((data) {
        final student =
            studentsById[_id(data['student_id'] ?? data['studentId'])];
        final date = _date(
          data['date'] ?? data['dateKey'] ?? data['created_at'],
        );
        return [
          _string(
                data['studentName'] ?? data['student_name'] ?? student?['name'],
              ) ??
              '-',
          _join([
            _string(
              data['batchName'] ?? data['batch_name'] ?? student?['batchName'],
            ),
            _string(data['courseName'] ?? student?['courseName']),
          ]),
          date == null ? '-' : DateFormat('dd MMM yyyy').format(date),
          _status(data).toUpperCase(),
          _string(data['markedByName'] ?? data['marked_by_name']) ?? '-',
        ];
      }).toList(),
    );
  }

  Future<ReportResult> _students(ReportFilters filters) async {
    final snap = await _firestore
        .collection('students')
        .where('deleted_at', isNull: true)
        .get();
    final students = snap.docs
        .map((doc) => doc.data())
        .where((data) => _matchesFilter(data, filters))
        .toList();
    final active = students
        .where(
          (data) =>
              (_string(data['status']) ?? 'active').toLowerCase() == 'active',
        )
        .length;
    final inactive = students.length - active;
    final now = DateTime.now();
    final upcomingBirthdays = students.where((data) {
      final dob = _date(
        data['dob'] ?? data['dateOfBirth'] ?? data['birthDate'],
      );
      if (dob == null) return false;
      var birthday = DateTime(now.year, dob.month, dob.day);
      if (birthday.isBefore(DateTime(now.year, now.month, now.day))) {
        birthday = DateTime(now.year + 1, dob.month, dob.day);
      }
      return birthday
              .difference(DateTime(now.year, now.month, now.day))
              .inDays <=
          30;
    }).length;
    final missingPhone = students.where((data) {
      return (_string(
                data['phone'] ?? data['parentPhone'] ?? data['guardian_phone'],
              ) ??
              '')
          .isEmpty;
    }).length;

    return ReportResult(
      title: 'Student Summary Report',
      subtitle: 'Current student overview',
      generatedAt: DateTime.now(),
      metrics: [
        ReportMetric(
          label: 'Total',
          value: students.length.toString(),
          tone: ReportTone.primary,
        ),
        ReportMetric(
          label: 'Active',
          value: active.toString(),
          tone: ReportTone.success,
        ),
        ReportMetric(
          label: 'Inactive',
          value: inactive.toString(),
          tone: ReportTone.warning,
        ),
        ReportMetric(
          label: 'Birthdays',
          value: upcomingBirthdays.toString(),
          tone: ReportTone.primary,
        ),
        ReportMetric(
          label: 'Missing Phone',
          value: missingPhone.toString(),
          tone: ReportTone.danger,
        ),
      ],
      columns: const [
        'Student',
        'Phone',
        'Parent Phone',
        'Course/Batch',
        'Status',
      ],
      rows: students.map((data) {
        return [
          _string(data['name'] ?? data['studentName']) ?? '-',
          _string(data['phone']) ?? '-',
          _string(
                data['parentPhone'] ??
                    data['parent_phone'] ??
                    data['guardian_phone'],
              ) ??
              '-',
          _join([
            _string(data['courseName'] ?? data['course']),
            _string(data['batchName'] ?? data['batch']),
          ]),
          _string(data['status']) ?? 'active',
        ];
      }).toList(),
    );
  }

  Future<ReportResult> _batchSummary(ReportFilters filters) async {
    final results = await Future.wait([
      _firestore.collection('batches').where('deleted_at', isNull: true).get(),
      _firestore.collection('courses').where('deleted_at', isNull: true).get(),
      _firestore.collection('students').where('deleted_at', isNull: true).get(),
      _firestore
          .collection('fee_payments')
          .where('deleted_at', isNull: true)
          .limit(1000)
          .get(),
    ]);
    final coursesById = {
      for (final doc in results[1].docs)
        _id(doc.data()['id'] ?? doc.id): doc.data(),
    };
    final students = results[2].docs.map((doc) => doc.data()).toList();
    final payments = results[3].docs.map((doc) => doc.data()).toList();
    final rows = <List<String>>[];
    var totalStudents = 0;
    var totalCollected = 0.0;
    var totalPending = 0.0;

    for (final doc in results[0].docs) {
      final batch = doc.data();
      if (!_matchesFilter(batch, filters)) continue;
      final batchId = _id(batch['id'] ?? doc.id);
      final courseId = _id(batch['course_id'] ?? batch['courseId']);
      if (filters.courseId != null && courseId != filters.courseId) continue;
      final batchStudents = students
          .where((data) => _id(data['batch_id'] ?? data['batchId']) == batchId)
          .toList();
      final batchPayments = payments
          .where((data) => _id(data['batch_id'] ?? data['batchId']) == batchId)
          .toList();
      final collected = _uniquePaidPayments(
        batchPayments.where((data) => _status(data) == 'paid').toList(),
      ).fold<double>(0, (runningTotal, data) => runningTotal + _paid(data));
      final pending = batchPayments.fold<double>(0, (runningTotal, data) {
        return _status(data) == 'pending'
            ? runningTotal + _pending(data)
            : runningTotal;
      });
      totalStudents += batchStudents.length;
      totalCollected += collected;
      totalPending += pending;
      rows.add([
        _string(batch['name'] ?? batch['batchName']) ?? 'Unnamed Batch',
        _string(
              coursesById[courseId]?['name'] ??
                  coursesById[courseId]?['courseName'],
            ) ??
            '-',
        batchStudents.length.toString(),
        _money(collected),
        pending <= 0 ? '-' : _money(pending),
        'N/A',
      ]);
    }

    return ReportResult(
      title: 'Batch/Course Summary Report',
      subtitle: 'Batch performance snapshot',
      generatedAt: DateTime.now(),
      metrics: [
        ReportMetric(
          label: 'Batches',
          value: rows.length.toString(),
          tone: ReportTone.primary,
        ),
        ReportMetric(
          label: 'Students',
          value: totalStudents.toString(),
          tone: ReportTone.primary,
        ),
        ReportMetric(
          label: 'Collected',
          value: _money(totalCollected),
          tone: ReportTone.success,
        ),
        ReportMetric(
          label: 'Pending',
          value: _money(totalPending),
          tone: ReportTone.warning,
        ),
      ],
      columns: const [
        'Batch',
        'Course',
        'Students',
        'Collected',
        'Pending',
        'Avg Attendance',
      ],
      rows: rows,
    );
  }

  static double _sumMode(List<Map<String, dynamic>> rows, String expectedMode) {
    return rows.fold<double>(0, (runningTotal, data) {
      return _mode(data) == expectedMode
          ? runningTotal + _paid(data)
          : runningTotal;
    });
  }

  static List<Map<String, dynamic>> _uniquePaidPayments(
    List<Map<String, dynamic>> rows,
  ) {
    final byReceipt = <String, Map<String, dynamic>>{};
    final withoutReceipt = <Map<String, dynamic>>[];
    for (final row in rows) {
      final receiptNo = _string(row['receiptNo'] ?? row['receipt_number']);
      if (receiptNo == null) {
        withoutReceipt.add(row);
        continue;
      }
      final existing = byReceipt[receiptNo];
      if (existing == null || _isReceipt(row)) {
        byReceipt[receiptNo] = row;
      }
    }
    return [...byReceipt.values, ...withoutReceipt];
  }

  static bool _isReceipt(Map<String, dynamic> data) {
    return data['recordType']?.toString() == 'receipt' ||
        data['feeType']?.toString() == 'receipt';
  }

  static bool _matchesFilter(Map<String, dynamic> data, ReportFilters filters) {
    final batchId = _id(data['batch_id'] ?? data['batchId']);
    final courseId = _id(data['course_id'] ?? data['courseId']);
    if (filters.batchId != null &&
        batchId.isNotEmpty &&
        batchId != filters.batchId) {
      return false;
    }
    if (filters.courseId != null &&
        courseId.isNotEmpty &&
        courseId != filters.courseId) {
      return false;
    }
    return true;
  }

  static bool _inRange(DateTime? date, ReportFilters filters) {
    if (date == null) return false;
    final day = DateTime(date.year, date.month, date.day);
    return !day.isBefore(_day(filters.startDate)) &&
        !day.isAfter(_day(filters.endDate));
  }

  static DateTime _day(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static String _rangeLabel(ReportFilters filters) {
    return '${DateFormat('dd MMM yyyy').format(filters.startDate)} - ${DateFormat('dd MMM yyyy').format(filters.endDate)}';
  }

  static String _money(double value) => 'Rs ${value.toStringAsFixed(0)}';

  static String _join(List<String?> parts) {
    final clean = parts
        .where((part) => (part ?? '').trim().isNotEmpty)
        .map((part) => part!.trim())
        .toList();
    return clean.isEmpty ? '-' : clean.join(' / ');
  }

  static String _id(dynamic value) => value?.toString().trim() ?? '';

  static String? _string(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static String _status(Map<String, dynamic> data) {
    return (data['status'] ?? '').toString().trim().toLowerCase();
  }

  static String _mode(Map<String, dynamic> data) {
    return (data['paymentMode'] ?? data['payment_mode'] ?? data['mode'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
  }

  static double _paid(Map<String, dynamic> data) {
    return _amount(
      data['amount'] ??
          data['amount_paid'] ??
          data['paid_amount'] ??
          data['totalPaid'],
    );
  }

  static double _pending(Map<String, dynamic> data) {
    return _amount(
      data['pendingAmount'] ??
          data['dueAmount'] ??
          data['balance'] ??
          data['remaining'] ??
          data['total_amount'],
    );
  }

  static double _amount(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    final clean = value.toString().replaceAll(RegExp(r'[^0-9.-]'), '');
    return double.tryParse(clean) ?? 0;
  }

  static DateTime? _date(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    final text = value.toString().trim();
    if (text.isEmpty) return null;
    return DateTime.tryParse(text);
  }
}
