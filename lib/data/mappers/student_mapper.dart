import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../../core/database/sync_types.dart';
import '../../models/student_model.dart';
import 'firestore_mapper_helpers.dart';

class StudentMapper {
  const StudentMapper._();

  static LocalStudentsCompanion fromFirestoreDoc(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    LocalSyncStatus syncStatus = LocalSyncStatus.synced,
  }) {
    return fromFirestoreMap(doc.id, doc.data() ?? {}, syncStatus: syncStatus);
  }

  static LocalStudentsCompanion fromFirestoreMap(
    String cloudId,
    Map<String, dynamic> data, {
    LocalSyncStatus syncStatus = LocalSyncStatus.synced,
  }) {
    final name = FirestoreMapperHelpers.stringValue(data['name']) ?? '';
    final dob = FirestoreMapperHelpers.dateValue(
      data['dob'] ?? data['dateOfBirth'] ?? data['birthDate'],
    );
    return LocalStudentsCompanion(
      cloudId: Value(cloudId),
      studentIdLegacy: Value(
        FirestoreMapperHelpers.stringValue(data['student_id'] ?? data['id']),
      ),
      name: Value(name),
      normalizedName: Value(FirestoreMapperHelpers.normalized(name)),
      phone: Value(FirestoreMapperHelpers.stringValue(data['phone'])),
      parentName: Value(
        FirestoreMapperHelpers.stringValue(
          data['parentName'] ?? data['parent_name'] ?? data['guardian_name'],
        ),
      ),
      parentPhone: Value(
        FirestoreMapperHelpers.stringValue(
          data['parentPhone'] ?? data['parent_phone'] ?? data['guardian_phone'],
        ),
      ),
      email: Value(FirestoreMapperHelpers.stringValue(data['email'])),
      dob: Value(dob),
      address: Value(FirestoreMapperHelpers.stringValue(data['address'])),
      className: Value(
        FirestoreMapperHelpers.stringValue(
          data['className'] ??
              data['standard'] ??
              data['class'] ??
              data['previous_class'],
        ),
      ),
      courseId: Value(
        FirestoreMapperHelpers.stringValue(
          data['courseId'] ?? data['course_id'],
        ),
      ),
      courseName: Value(
        FirestoreMapperHelpers.stringValue(
          data['courseName'] ?? data['course_name'] ?? data['course'],
        ),
      ),
      batchId: Value(
        FirestoreMapperHelpers.stringValue(data['batchId'] ?? data['batch_id']),
      ),
      batchName: Value(
        FirestoreMapperHelpers.stringValue(
          data['batchName'] ?? data['batch_name'] ?? data['batch'],
        ),
      ),
      status: Value(
        _normalizedStatus(
          FirestoreMapperHelpers.stringValue(data['status']) ??
              (FirestoreMapperHelpers.boolValue(data['is_active'])
                  ? 'active'
                  : 'inactive'),
        ),
      ),
      notes: Value(FirestoreMapperHelpers.stringValue(data['notes'])),
      photoUrl: Value(
        FirestoreMapperHelpers.stringValue(
          data['profile_photo'] ?? data['profilePhoto'],
        ),
      ),
      createdAt: Value(
        FirestoreMapperHelpers.dateValue(
          data['createdAt'] ?? data['created_at'],
        ),
      ),
      updatedAt: Value(
        FirestoreMapperHelpers.dateValue(
          data['updatedAt'] ?? data['updated_at'],
        ),
      ),
      deletedAt: Value(
        FirestoreMapperHelpers.dateValue(
          data['deletedAt'] ?? data['deleted_at'],
        ),
      ),
      syncStatus: Value(syncStatus),
      lastSyncedAt: Value(
        syncStatus == LocalSyncStatus.synced ? DateTime.now() : null,
      ),
    );
  }

  static LocalStudentsCompanion fromDomain(
    StudentModel student, {
    LocalSyncStatus syncStatus = LocalSyncStatus.pendingUpdate,
  }) {
    return LocalStudentsCompanion(
      cloudId: Value(student.id.isEmpty ? null : student.id),
      studentIdLegacy: Value(
        student.studentId.isEmpty ? null : student.studentId,
      ),
      name: Value(student.name),
      normalizedName: Value(FirestoreMapperHelpers.normalized(student.name)),
      phone: Value(student.phone),
      parentName: Value(student.parentName ?? student.guardianName),
      parentPhone: Value(student.parentPhone ?? student.guardianPhone),
      email: Value(student.email),
      dob: Value(student.dob),
      address: Value(student.address),
      className: Value(student.className ?? student.previousClass),
      courseId: Value(student.courseId),
      courseName: Value(student.courseName),
      batchId: Value(student.batchId),
      batchName: Value(student.batchName),
      status: Value(_normalizedStatus(student.status)),
      notes: Value(student.notes),
      photoUrl: Value(student.profilePhoto),
      createdAt: Value(student.createdAt),
      updatedAt: Value(student.updatedAt),
      deletedAt: const Value(null),
      syncStatus: Value(syncStatus),
      lastSyncedAt: Value(
        syncStatus == LocalSyncStatus.synced ? DateTime.now() : null,
      ),
    );
  }

  static StudentModel toDomain(LocalStudent row) {
    return StudentModel(
      id: row.cloudId ?? row.localId.toString(),
      numericId: _numericIdFromStudentId(row.studentIdLegacy),
      studentId: row.studentIdLegacy ?? row.cloudId ?? row.localId.toString(),
      name: row.name,
      email: row.email,
      phone: row.phone,
      parentName: row.parentName,
      parentPhone: row.parentPhone,
      profilePhoto: row.photoUrl,
      dob: row.dob,
      className: row.className,
      batchName: row.batchName,
      batchId: row.batchId,
      courseName: row.courseName,
      courseId: row.courseId,
      address: row.address,
      status: row.status,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      notes: row.notes,
    );
  }

  static Map<String, dynamic> toFirestorePayload(LocalStudent student) {
    final studentId = student.studentIdLegacy ?? student.cloudId ?? '';
    return {
      if (_numericIdFromStudentId(studentId) != null)
        'id': _numericIdFromStudentId(studentId),
      'student_id': studentId,
      'name': student.name,
      'email': student.email,
      'phone': student.phone,
      'parentName': student.parentName,
      'parentPhone': student.parentPhone,
      'guardian_name': student.parentName,
      'guardian_phone': student.parentPhone,
      'profile_photo': student.photoUrl,
      'dob': student.dob == null ? null : Timestamp.fromDate(student.dob!),
      'dateOfBirth': student.dob == null
          ? null
          : Timestamp.fromDate(student.dob!),
      'className': student.className,
      'standard': student.className,
      'previous_class': student.className,
      'batchId': student.batchId,
      'batch_id': _legacyIdValue(student.batchId),
      'batchName': student.batchName,
      'batch': student.batchName,
      'courseId': student.courseId,
      'course_id': _legacyIdValue(student.courseId),
      'courseName': student.courseName,
      'course': student.courseName,
      'address': student.address,
      'notes': student.notes,
      'status': student.status,
      'is_active': student.status.toLowerCase() == 'active',
      'created_at': student.createdAt?.toIso8601String(),
      'updated_at': student.updatedAt?.toIso8601String(),
      'deleted_at': student.deletedAt?.toIso8601String(),
    };
  }

  static Object? _legacyIdValue(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return int.tryParse(value) ?? value;
  }

  static int? _numericIdFromStudentId(String? value) {
    if (value == null) return null;
    final direct = int.tryParse(value);
    if (direct != null) return direct;
    final match = RegExp(r'(\d+)$').firstMatch(value);
    return match == null ? null : int.tryParse(match.group(1)!);
  }

  static String _normalizedStatus(String? value) {
    final status = (value ?? 'active').trim().toLowerCase();
    if (status == 'inactive' ||
        status == 'disabled' ||
        status == 'deleted' ||
        status == 'archived') {
      return 'inactive';
    }
    return 'active';
  }
}
