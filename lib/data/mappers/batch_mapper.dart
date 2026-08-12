import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../../core/database/sync_types.dart';
import '../../models/batch_model.dart';
import 'firestore_mapper_helpers.dart';

class BatchMapper {
  const BatchMapper._();

  static LocalBatchesCompanion fromFirestoreDoc(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    LocalSyncStatus syncStatus = LocalSyncStatus.synced,
  }) {
    final data = doc.data() ?? {};
    return _fromMap(doc.id, data, syncStatus: syncStatus);
  }

  static LocalBatchesCompanion fromFirestoreMap(
    String cloudId,
    Map<String, dynamic> data, {
    LocalSyncStatus syncStatus = LocalSyncStatus.synced,
  }) {
    return _fromMap(cloudId, data, syncStatus: syncStatus);
  }

  static LocalBatchesCompanion fromModel(
    BatchModel batch, {
    required LocalSyncStatus syncStatus,
  }) {
    return LocalBatchesCompanion(
      cloudId: Value(batch.id),
      legacyId: Value(batch.legacyId),
      name: Value(batch.name),
      courseId: Value(batch.courseId),
      courseName: Value(batch.courseName),
      daysJson: Value(jsonEncode(batch.days)),
      startDate: Value(batch.startDate),
      endDate: Value(batch.endDate),
      startTime: Value(batch.startTime),
      endTime: Value(batch.endTime),
      maxStudents: Value(batch.maxStudents),
      isActive: Value(batch.isActive),
      createdAt: Value(batch.createdAt),
      updatedAt: Value(batch.updatedAt),
      deletedAt: Value(batch.deletedAt),
      syncStatus: Value(syncStatus),
      lastSyncedAt: Value(batch.lastSyncedAt),
    );
  }

  static Map<String, dynamic> toFirestorePayload(LocalBatch batch) {
    return {
      if (batch.legacyId != null) 'id': _legacyIdValue(batch.legacyId!),
      'name': batch.name,
      'course_id': _legacyIdValue(batch.courseId ?? ''),
      'course_name': batch.courseName,
      'days': daysFromLocal(batch),
      'start_date': batch.startDate?.toIso8601String(),
      'end_date': batch.endDate?.toIso8601String(),
      'start_time': batch.startTime,
      'end_time': batch.endTime,
      'max_students': batch.maxStudents,
      'is_active': batch.isActive,
      'created_at': batch.createdAt?.toIso8601String(),
      'updated_at': batch.updatedAt?.toIso8601String(),
      'deleted_at': batch.deletedAt?.toIso8601String(),
    };
  }

  static LocalBatchesCompanion _fromMap(
    String cloudId,
    Map<String, dynamic> data, {
    required LocalSyncStatus syncStatus,
  }) {
    final days = FirestoreMapperHelpers.stringList(data['days']);
    return LocalBatchesCompanion(
      cloudId: Value(cloudId),
      legacyId: Value(FirestoreMapperHelpers.stringValue(data['id'])),
      name: Value(FirestoreMapperHelpers.stringValue(data['name']) ?? ''),
      courseId: Value(
        FirestoreMapperHelpers.stringValue(
          data['course_id'] ?? data['courseId'],
        ),
      ),
      courseName: Value(
        FirestoreMapperHelpers.stringValue(
          data['course_name'] ?? data['courseName'],
        ),
      ),
      daysJson: Value(jsonEncode(days)),
      startDate: Value(
        FirestoreMapperHelpers.dateValue(
          data['start_date'] ?? data['startDate'],
        ),
      ),
      endDate: Value(
        FirestoreMapperHelpers.dateValue(data['end_date'] ?? data['endDate']),
      ),
      startTime: Value(
        FirestoreMapperHelpers.stringValue(
          data['start_time'] ?? data['startTime'],
        ),
      ),
      endTime: Value(
        FirestoreMapperHelpers.stringValue(data['end_time'] ?? data['endTime']),
      ),
      maxStudents: Value(
        FirestoreMapperHelpers.intValue(
          data['max_students'] ?? data['maxStudents'],
        ),
      ),
      isActive: Value(
        FirestoreMapperHelpers.boolValue(data['is_active'] ?? data['isActive']),
      ),
      createdAt: Value(
        FirestoreMapperHelpers.dateValue(
          data['created_at'] ?? data['createdAt'],
        ),
      ),
      updatedAt: Value(
        FirestoreMapperHelpers.dateValue(
          data['updated_at'] ?? data['updatedAt'],
        ),
      ),
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

  static List<String> daysFromLocal(LocalBatch batch) {
    final raw = batch.daysJson;
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw);
    return FirestoreMapperHelpers.stringList(decoded);
  }

  static Object? _legacyIdValue(String value) {
    if (value.trim().isEmpty) return null;
    return int.tryParse(value) ?? value;
  }
}
