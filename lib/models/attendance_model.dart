import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum AttendanceStatus { present, absent, late, leave }

class AttendanceKeys {
  const AttendanceKeys._();

  static DateTime dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static String dateKey(DateTime date) {
    final local = dateOnly(date);
    final year = local.year.toString().padLeft(4, '0');
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static String create({
    required String dateKey,
    required String studentId,
    String? batchId,
  }) {
    final batchPart = (batchId == null || batchId.trim().isEmpty)
        ? 'all'
        : batchId.trim();
    return '$dateKey|$batchPart|${studentId.trim()}';
  }
}

extension AttendanceStatusExtension on AttendanceStatus {
  Color get color {
    switch (this) {
      case AttendanceStatus.present:
        return Colors.greenAccent;
      case AttendanceStatus.absent:
        return Colors.redAccent;
      case AttendanceStatus.late:
        return Colors.orangeAccent;
      case AttendanceStatus.leave:
        return Colors.blueAccent;
    }
  }

  String get label {
    switch (this) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.leave:
        return 'Leave';
    }
  }

  String get shortLabel {
    switch (this) {
      case AttendanceStatus.present:
        return 'P';
      case AttendanceStatus.absent:
        return 'A';
      case AttendanceStatus.late:
        return 'L';
      case AttendanceStatus.leave:
        return 'LV';
    }
  }
}

class AttendanceModel {
  const AttendanceModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.date,
    required this.status,
    this.batchId,
    this.batchName,
    this.className,
    this.markedBy,
    this.markedByName,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String studentId;
  final String studentName;
  final DateTime date;
  final AttendanceStatus status;
  final String? batchId;
  final String? batchName;
  final String? className;
  final String? markedBy;
  final String? markedByName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory AttendanceModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return AttendanceModel(
      id: doc.id,
      studentId: parseString(data['studentId'] ?? data['student_id']) ?? '',
      studentName:
          parseString(data['studentName'] ?? data['student_name']) ?? '',
      batchId: parseString(data['batchId'] ?? data['batch_id']),
      batchName: parseString(data['batchName'] ?? data['batch_name']),
      className: parseString(data['className'] ?? data['standard']),
      date: parseDate(data['date'] ?? data['dateKey']) ?? DateTime.now(),
      status: parseStatus(data['status']),
      markedBy: parseString(data['markedBy'] ?? data['marked_by']),
      markedByName: parseString(data['markedByName'] ?? data['marked_by_name']),
      createdAt: parseDate(data['createdAt'] ?? data['created_at']),
      updatedAt: parseDate(data['updatedAt'] ?? data['updated_at']),
    );
  }

  static AttendanceStatus parseStatus(dynamic value) {
    final text = value?.toString().trim().toLowerCase();
    switch (text) {
      case 'present':
      case 'presented':
      case 'p':
      case '1':
        return AttendanceStatus.present;
      case 'late':
      case 'l':
        return AttendanceStatus.late;
      case 'leave':
      case 'holiday':
      case 'lv':
      case 'onleave':
        return AttendanceStatus.leave;
      case 'absent':
      case 'a':
      case '0':
      default:
        return AttendanceStatus.absent;
    }
  }

  static DateTime? parseDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) {
      final clean = value.trim();
      if (clean.isEmpty) return null;
      return DateTime.tryParse(clean);
    }
    return null;
  }

  static int? parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static String? parseString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}
