import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../../core/database/sync_types.dart';
import '../../models/attendance_model.dart';
import 'firestore_mapper_helpers.dart';

class AttendanceMapper {
  const AttendanceMapper._();

  static String dateKey(DateTime date) => AttendanceKeys.dateKey(date);

  static LocalAttendancesCompanion fromFirestoreDoc(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    LocalSyncStatus syncStatus = LocalSyncStatus.synced,
  }) {
    final model = AttendanceModel.fromFirestore(doc);
    final data = doc.data() ?? {};
    final normalizedDateKey =
        FirestoreMapperHelpers.stringValue(data['dateKey']) ??
        FirestoreMapperHelpers.stringValue(data['date']) ??
        dateKey(model.date);
    final key =
        FirestoreMapperHelpers.stringValue(data['attendanceKey']) ??
        AttendanceKeys.create(
          dateKey: normalizedDateKey,
          studentId: model.studentId,
          batchId: model.batchId,
        );

    return LocalAttendancesCompanion(
      cloudId: Value(doc.id),
      attendanceKey: Value(key),
      studentId: Value(model.studentId),
      studentName: Value(model.studentName),
      dateKey: Value(normalizedDateKey),
      attendanceDate: Value(AttendanceKeys.dateOnly(model.date)),
      batchId: Value(model.batchId),
      batchName: Value(model.batchName),
      courseId: Value(
        FirestoreMapperHelpers.stringValue(
          data['courseId'] ?? data['course_id'],
        ),
      ),
      courseName: Value(
        FirestoreMapperHelpers.stringValue(
          data['courseName'] ?? data['course_name'],
        ),
      ),
      status: Value(model.status.name),
      markedBy: Value(model.markedBy),
      markedByName: Value(model.markedByName),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
      deletedAt: Value(
        FirestoreMapperHelpers.dateValue(
          data['deleted_at'] ?? data['deletedAt'],
        ),
      ),
      syncStatus: Value(syncStatus),
      lastSyncedAt: Value(
        syncStatus == LocalSyncStatus.synced ? DateTime.now() : null,
      ),
    );
  }

  static AttendanceModel toDomain(LocalAttendance row) => AttendanceModel(
    id: row.cloudId ?? row.attendanceKey,
    studentId: row.studentId,
    studentName: row.studentName,
    date: row.attendanceDate,
    status: AttendanceModel.parseStatus(row.status),
    batchId: row.batchId,
    batchName: row.batchName,
    className: row.courseName,
    markedBy: row.markedBy,
    markedByName: row.markedByName,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );

  static LocalAttendancesCompanion fromDomain(
    AttendanceModel attendance, {
    required String attendanceKey,
    LocalSyncStatus syncStatus = LocalSyncStatus.synced,
    String? courseId,
    String? courseName,
  }) {
    final normalizedDate = AttendanceKeys.dateOnly(attendance.date);
    return LocalAttendancesCompanion(
      cloudId: Value(attendance.id.isEmpty ? attendanceKey : attendance.id),
      attendanceKey: Value(attendanceKey),
      studentId: Value(attendance.studentId),
      studentName: Value(attendance.studentName),
      dateKey: Value(dateKey(normalizedDate)),
      attendanceDate: Value(normalizedDate),
      batchId: Value(attendance.batchId),
      batchName: Value(attendance.batchName),
      courseId: Value(courseId),
      courseName: Value(courseName ?? attendance.className),
      status: Value(attendance.status.name),
      markedBy: Value(attendance.markedBy),
      markedByName: Value(attendance.markedByName),
      createdAt: Value(attendance.createdAt),
      updatedAt: Value(attendance.updatedAt),
      syncStatus: Value(syncStatus),
      lastSyncedAt: Value(
        syncStatus == LocalSyncStatus.synced ? DateTime.now() : null,
      ),
    );
  }

  static Map<String, dynamic> toFirestorePayload(LocalAttendance row) {
    final numericStudentId = AttendanceModel.parseInt(row.studentId);
    final numericBatchId = AttendanceModel.parseInt(row.batchId);
    final payload = <String, dynamic>{
      'attendanceKey': row.attendanceKey,
      'student_id': numericStudentId ?? row.studentId,
      'studentId': row.studentId,
      'student_name': row.studentName,
      'studentName': row.studentName,
      'batch_id': numericBatchId ?? row.batchId,
      'batchId': row.batchId,
      'batch_name': row.batchName,
      'batchName': row.batchName,
      'courseId': row.courseId,
      'courseName': row.courseName,
      'date': row.dateKey,
      'dateKey': row.dateKey,
      'status': row.status,
      'markedBy': row.markedBy,
      'markedByName': row.markedByName,
      'marked_via': 'Mak Tutorials Admin',
      'created_at': row.createdAt?.toIso8601String(),
      'createdAt': row.createdAt?.toIso8601String(),
      'updated_at': row.updatedAt?.toIso8601String(),
      'updatedAt': row.updatedAt?.toIso8601String(),
      'deleted_at': row.deletedAt?.toIso8601String(),
      'deletedAt': row.deletedAt?.toIso8601String(),
    };
    payload.removeWhere((_, value) => value == null);
    return payload;
  }

  static Map<String, dynamic> toFirestorePayloadFromDomain(
    AttendanceModel attendance, {
    required String attendanceKey,
    String? courseId,
    String? courseName,
  }) {
    final normalizedDate = AttendanceKeys.dateOnly(attendance.date);
    final dateKey = AttendanceMapper.dateKey(normalizedDate);
    final numericStudentId = AttendanceModel.parseInt(attendance.studentId);
    final numericBatchId = AttendanceModel.parseInt(attendance.batchId);
    final payload = <String, dynamic>{
      'attendanceKey': attendanceKey,
      'student_id': numericStudentId ?? attendance.studentId,
      'studentId': attendance.studentId,
      'student_name': attendance.studentName,
      'studentName': attendance.studentName,
      'batch_id': numericBatchId ?? attendance.batchId,
      'batchId': attendance.batchId,
      'batch_name': attendance.batchName,
      'batchName': attendance.batchName,
      'courseId': courseId,
      'courseName': courseName ?? attendance.className,
      'date': dateKey,
      'dateKey': dateKey,
      'status': attendance.status.name,
      'markedBy': attendance.markedBy,
      'markedByName': attendance.markedByName,
      'marked_via': 'Mak Tutorials Admin',
      'created_at': (attendance.createdAt ?? DateTime.now()).toIso8601String(),
      'createdAt': (attendance.createdAt ?? DateTime.now()).toIso8601String(),
      'updated_at': (attendance.updatedAt ?? DateTime.now()).toIso8601String(),
      'updatedAt': (attendance.updatedAt ?? DateTime.now()).toIso8601String(),
    };
    payload.removeWhere((_, value) => value == null);
    return payload;
  }
}
