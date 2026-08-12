import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import 'institute_settings_service.dart';

class BackupExport {
  const BackupExport({
    required this.fileName,
    required this.content,
    required this.mimeType,
    required this.generatedAt,
  });

  final String fileName;
  final String content;
  final String mimeType;
  final DateTime generatedAt;
}

class BackupService {
  BackupService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const _collections = [
    'students',
    'enrollments',
    'fee_payments',
    'attendances',
    'courses',
    'batches',
    'reminders',
    'message_templates',
    'settings',
    'users',
  ];

  Future<BackupExport> exportFullBackup() async {
    final generatedAt = DateTime.now();
    final settings = await InstituteSettingsService.instance.loadSettings();
    final snapshots = await Future.wait(
      _collections.map((collection) => _firestore.collection(collection).get()),
    );

    final collections = <String, dynamic>{};
    for (var i = 0; i < _collections.length; i++) {
      final collection = _collections[i];
      collections[collection] = snapshots[i].docs.map((doc) {
        final data = doc.data();
        return {
          'docId': doc.id,
          'data': collection == 'users'
              ? _safeUserProfile(data)
              : _jsonSafe(data),
        };
      }).toList();
    }

    final backup = {
      'generatedAt': generatedAt.toIso8601String(),
      'appName': 'classes_pro_admin',
      'instituteName': settings.instituteName,
      'backupVersion': 1,
      'collections': collections,
    };

    return BackupExport(
      fileName:
          'MakTutorials_Backup_${DateFormat('yyyyMMdd_HHmm').format(generatedAt)}.json',
      content: const JsonEncoder.withIndent('  ').convert(backup),
      mimeType: 'application/json',
      generatedAt: generatedAt,
    );
  }

  Future<BackupExport> exportStudentsCsv() async {
    final generatedAt = DateTime.now();
    final docs = await _activeDocs('students');
    final rows = docs.map((data) {
      return [
        _string(data['name'] ?? data['studentName']),
        _string(data['phone']),
        _string(
          data['parentName'] ?? data['parent_name'] ?? data['guardian_name'],
        ),
        _string(
          data['parentPhone'] ?? data['parent_phone'] ?? data['guardian_phone'],
        ),
        _string(data['courseName'] ?? data['course_name'] ?? data['course']),
        _string(data['batchName'] ?? data['batch_name'] ?? data['batch']),
        _dateText(data['dob'] ?? data['dateOfBirth'] ?? data['birthDate']),
        _string(data['status']) ?? 'active',
        _dateText(data['createdAt'] ?? data['created_at']),
      ];
    });

    return _csvExport(
      generatedAt: generatedAt,
      fileName:
          'MakTutorials_Students_${DateFormat('yyyyMMdd').format(generatedAt)}.csv',
      columns: const [
        'Student Name',
        'Phone',
        'Parent Name',
        'Parent Phone',
        'Course',
        'Batch',
        'DOB',
        'Status',
        'Created At',
      ],
      rows: rows,
    );
  }

  Future<BackupExport> exportFeesCsv() async {
    final generatedAt = DateTime.now();
    final docs = await _activeDocs('fee_payments');
    final rows = docs.map((data) {
      return [
        _string(data['receiptNo'] ?? data['receipt_number']),
        _string(data['studentName'] ?? data['student_name']),
        _amountText(
          data['amount'] ??
              data['amount_paid'] ??
              data['paid_amount'] ??
              data['totalPaid'],
        ),
        _string(data['paymentMode'] ?? data['payment_mode'] ?? data['mode']),
        _dateText(
          data['paymentDate'] ?? data['payment_date'] ?? data['paidDate'],
        ),
        _string(data['courseName'] ?? data['course_name'] ?? data['course']),
        _string(data['batchName'] ?? data['batch_name'] ?? data['batch']),
        _string(
          data['receivedByName'] ??
              data['received_by_name'] ??
              data['receivedBy'],
        ),
        _string(data['remarks'] ?? data['notes']),
      ];
    });

    return _csvExport(
      generatedAt: generatedAt,
      fileName:
          'MakTutorials_Fees_${DateFormat('yyyyMMdd').format(generatedAt)}.csv',
      columns: const [
        'Receipt No',
        'Student Name',
        'Amount',
        'Payment Mode',
        'Payment Date',
        'Course',
        'Batch',
        'Received By',
        'Remarks',
      ],
      rows: rows,
    );
  }

  Future<BackupExport> exportAttendanceCsv() async {
    final generatedAt = DateTime.now();
    final docs = await _activeDocs('attendances');
    final rows = docs.map((data) {
      return [
        _dateText(data['date'] ?? data['dateKey'] ?? data['created_at']),
        _string(data['studentName'] ?? data['student_name']),
        _string(data['status']),
        _string(data['courseName'] ?? data['course_name'] ?? data['course']),
        _string(data['batchName'] ?? data['batch_name'] ?? data['batch']),
        _string(
          data['markedByName'] ?? data['marked_by_name'] ?? data['markedBy'],
        ),
      ];
    });

    return _csvExport(
      generatedAt: generatedAt,
      fileName:
          'MakTutorials_Attendance_${DateFormat('yyyyMMdd').format(generatedAt)}.csv',
      columns: const [
        'Date',
        'Student Name',
        'Status',
        'Course',
        'Batch',
        'Marked By',
      ],
      rows: rows,
    );
  }

  Future<BackupExport> exportRemindersCsv() async {
    final generatedAt = DateTime.now();
    final docs = await _activeDocs('reminders');
    final rows = docs.map((data) {
      return [
        _string(data['type']),
        _string(data['title']),
        _string(data['studentName'] ?? data['student_name']),
        _dateText(data['dueDate'] ?? data['due_date']),
        _amountText(data['amount']),
        _string(data['status']),
        _string(data['priority']),
      ];
    });

    return _csvExport(
      generatedAt: generatedAt,
      fileName:
          'MakTutorials_Reminders_${DateFormat('yyyyMMdd').format(generatedAt)}.csv',
      columns: const [
        'Type',
        'Title',
        'Student Name',
        'Due Date',
        'Amount',
        'Status',
        'Priority',
      ],
      rows: rows,
    );
  }

  String generateCsv(List<String> columns, Iterable<List<String?>> rows) {
    final buffer = StringBuffer();
    buffer.writeln(columns.map(_escapeCsv).join(','));
    for (final row in rows) {
      buffer.writeln(row.map((value) => _escapeCsv(value ?? '-')).join(','));
    }
    return buffer.toString();
  }

  Future<bool> shareExport(BackupExport export) async {
    try {
      final file = XFile.fromData(
        Uint8List.fromList(utf8.encode(export.content)),
        name: export.fileName,
        mimeType: export.mimeType,
      );
      await Share.shareXFiles([file], text: export.fileName);
      return true;
    } catch (error, stackTrace) {
      debugPrint('Backup file sharing failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      try {
        await Share.share(export.content, subject: export.fileName);
        return true;
      } catch (fallbackError, fallbackStackTrace) {
        debugPrint('Backup text sharing failed: $fallbackError');
        debugPrintStack(stackTrace: fallbackStackTrace);
        return false;
      }
    }
  }

  Future<List<Map<String, dynamic>>> _activeDocs(String collection) async {
    final snapshot = await _firestore.collection(collection).get();
    return snapshot.docs
        .map((doc) => doc.data())
        .where(
          (data) => data['deleted_at'] == null && data['deletedAt'] == null,
        )
        .toList();
  }

  BackupExport _csvExport({
    required DateTime generatedAt,
    required String fileName,
    required List<String> columns,
    required Iterable<List<String?>> rows,
  }) {
    return BackupExport(
      fileName: fileName,
      content: generateCsv(columns, rows),
      mimeType: 'text/csv',
      generatedAt: generatedAt,
    );
  }

  Map<String, dynamic> _safeUserProfile(Map<String, dynamic> data) {
    return _jsonSafe({
      'uid': data['uid'],
      'email': data['email'],
      'name': data['name'],
      'role': data['role'],
      'status': data['status'],
    });
  }

  dynamic _jsonSafe(dynamic value) {
    if (value == null || value is String || value is num || value is bool) {
      return value;
    }
    if (value is Timestamp) return value.toDate().toIso8601String();
    if (value is DateTime) return value.toIso8601String();
    if (value is GeoPoint) {
      return {'latitude': value.latitude, 'longitude': value.longitude};
    }
    if (value is DocumentReference) return value.path;
    if (value is Iterable) return value.map(_jsonSafe).toList();
    if (value is Map) {
      return value.map(
        (key, item) => MapEntry(key.toString(), _jsonSafe(item)),
      );
    }
    return value.toString();
  }

  String _escapeCsv(String value) {
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }

  String? _string(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  String _amountText(dynamic value) {
    if (value == null) return '-';
    if (value is num) {
      return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2);
    }
    return _string(value) ?? '-';
  }

  String _dateText(dynamic value) {
    final date = _date(value);
    if (date == null) return _string(value) ?? '-';
    return DateFormat('dd MMM yyyy').format(date);
  }

  DateTime? _date(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
