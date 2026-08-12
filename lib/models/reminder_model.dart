import 'package:cloud_firestore/cloud_firestore.dart';

enum ReminderType { birthday, feeDue, general }

enum ReminderStatus { pending, done, dismissed }

enum ReminderPriority { low, normal, high }

class ReminderModel {
  const ReminderModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    required this.priority,
    this.studentId,
    this.studentName,
    this.studentPhone,
    this.parentPhone,
    this.amount,
    this.createdBy,
    this.createdByName,
    this.assignedTo,
    this.completedAt,
    this.dismissedAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final ReminderType type;
  final String title;
  final String description;
  final String? studentId;
  final String? studentName;
  final String? studentPhone;
  final String? parentPhone;
  final DateTime dueDate;
  final double? amount;
  final ReminderStatus status;
  final ReminderPriority priority;
  final String? createdBy;
  final String? createdByName;
  final String? assignedTo;
  final DateTime? completedAt;
  final DateTime? dismissedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ReminderModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ReminderModel(
      id: doc.id,
      type: parseType(data['type']),
      title: parseString(data['title']) ?? 'Reminder',
      description: parseString(data['description']) ?? '',
      studentId: parseString(data['studentId'] ?? data['student_id']),
      studentName: parseString(data['studentName'] ?? data['student_name']),
      studentPhone: parseString(data['studentPhone'] ?? data['student_phone']),
      parentPhone: parseString(data['parentPhone'] ?? data['parent_phone']),
      dueDate: parseDate(data['dueDate'] ?? data['due_date']) ?? DateTime.now(),
      amount: parseDouble(data['amount']),
      status: parseStatus(data['status']),
      priority: parsePriority(data['priority']),
      createdBy: parseString(data['createdBy'] ?? data['created_by']),
      createdByName: parseString(
        data['createdByName'] ?? data['created_by_name'],
      ),
      assignedTo: parseString(data['assignedTo'] ?? data['assigned_to']),
      completedAt: parseDate(data['completedAt'] ?? data['completed_at']),
      dismissedAt: parseDate(data['dismissedAt'] ?? data['dismissed_at']),
      createdAt: parseDate(data['createdAt'] ?? data['created_at']),
      updatedAt: parseDate(data['updatedAt'] ?? data['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'title': title,
      'description': description,
      'studentId': studentId,
      'studentName': studentName,
      'studentPhone': studentPhone,
      'parentPhone': parentPhone,
      'dueDate': Timestamp.fromDate(dueDate),
      'amount': amount,
      'status': status.name,
      'priority': priority.name,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'assignedTo': assignedTo,
      'completedAt': completedAt == null
          ? null
          : Timestamp.fromDate(completedAt!),
      'dismissedAt': dismissedAt == null
          ? null
          : Timestamp.fromDate(dismissedAt!),
      'updatedAt': FieldValue.serverTimestamp(),
      if (createdAt == null) 'createdAt': FieldValue.serverTimestamp(),
    };
  }

  ReminderModel copyWith({
    String? title,
    String? description,
    String? studentId,
    String? studentName,
    String? studentPhone,
    String? parentPhone,
    DateTime? dueDate,
    double? amount,
    ReminderStatus? status,
    ReminderPriority? priority,
    String? assignedTo,
    DateTime? completedAt,
    DateTime? dismissedAt,
  }) {
    return ReminderModel(
      id: id,
      type: type,
      title: title ?? this.title,
      description: description ?? this.description,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      studentPhone: studentPhone ?? this.studentPhone,
      parentPhone: parentPhone ?? this.parentPhone,
      dueDate: dueDate ?? this.dueDate,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdBy: createdBy,
      createdByName: createdByName,
      assignedTo: assignedTo ?? this.assignedTo,
      completedAt: completedAt ?? this.completedAt,
      dismissedAt: dismissedAt ?? this.dismissedAt,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  bool get isPending => status == ReminderStatus.pending;
  bool get isDone => status == ReminderStatus.done;
  bool get isDismissed => status == ReminderStatus.dismissed;

  static ReminderType parseType(dynamic value) {
    return switch (value?.toString()) {
      'birthday' => ReminderType.birthday,
      'feeDue' || 'fee_due' => ReminderType.feeDue,
      _ => ReminderType.general,
    };
  }

  static ReminderStatus parseStatus(dynamic value) {
    return switch (value?.toString()) {
      'done' => ReminderStatus.done,
      'dismissed' => ReminderStatus.dismissed,
      _ => ReminderStatus.pending,
    };
  }

  static ReminderPriority parsePriority(dynamic value) {
    return switch (value?.toString()) {
      'low' => ReminderPriority.low,
      'high' => ReminderPriority.high,
      _ => ReminderPriority.normal,
    };
  }

  static DateTime? parseDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  static double? parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static String? parseString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}

class ReminderStudentOption {
  const ReminderStudentOption({
    required this.id,
    required this.name,
    this.studentPhone,
    this.parentPhone,
  });

  final String id;
  final String name;
  final String? studentPhone;
  final String? parentPhone;
}
