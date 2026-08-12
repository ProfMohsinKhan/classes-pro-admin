import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../core/database/app_database.dart';
import '../../core/database/sync_types.dart';
import '../mappers/attendance_mapper.dart';
import '../mappers/batch_mapper.dart';
import '../mappers/course_mapper.dart';
import '../mappers/enquiry_mapper.dart';
import '../mappers/student_mapper.dart';

enum SyncRunState { idle, running, failed }

class SyncEngine {
  SyncEngine(this.database, {FirebaseFirestore? firestore})
    : _firestore = firestore;

  final AppDatabase database;
  final FirebaseFirestore? _firestore;
  final _stateController = StreamController<SyncRunState>.broadcast();
  bool _isRunning = false;

  Stream<SyncRunState> get state => _stateController.stream;
  FirebaseFirestore get _remote => _firestore ?? FirebaseFirestore.instance;

  Future<void> syncAll() async {
    if (_isRunning) return;
    _isRunning = true;
    _stateController.add(SyncRunState.running);
    debugPrint('SyncEngine: started');
    try {
      await pushPendingOperations();
      await pullRemoteChanges();
      _stateController.add(SyncRunState.idle);
      debugPrint('SyncEngine: pull completed');
    } catch (e) {
      _stateController.add(SyncRunState.failed);
      debugPrint('SyncEngine: failed, keeping pending: $e');
    } finally {
      _isRunning = false;
    }
  }

  Future<void> syncStudents() async {
    if (_isRunning) return;
    _isRunning = true;
    _stateController.add(SyncRunState.running);
    try {
      await pushPendingOperations(entityTypes: const {SyncEntityType.student});
      await _pullStudents();
      _stateController.add(SyncRunState.idle);
    } catch (e) {
      _stateController.add(SyncRunState.failed);
      debugPrint('SyncEngine: students failed, keeping pending: $e');
    } finally {
      _isRunning = false;
    }
  }

  Future<void> syncCourses() async {
    if (_isRunning) return;
    _isRunning = true;
    _stateController.add(SyncRunState.running);
    try {
      await pushPendingOperations(entityTypes: const {SyncEntityType.course});
      await _pullCourses();
      _stateController.add(SyncRunState.idle);
    } catch (e) {
      _stateController.add(SyncRunState.failed);
      debugPrint('SyncEngine: courses failed, keeping pending: $e');
    } finally {
      _isRunning = false;
    }
  }

  Future<void> syncBatches() async {
    if (_isRunning) return;
    _isRunning = true;
    _stateController.add(SyncRunState.running);
    try {
      await pushPendingOperations(entityTypes: const {SyncEntityType.batch});
      await _pullBatches();
      _stateController.add(SyncRunState.idle);
    } catch (e) {
      _stateController.add(SyncRunState.failed);
      debugPrint('SyncEngine: batches failed, keeping pending: $e');
    } finally {
      _isRunning = false;
    }
  }

  Future<void> syncEnquiries() async {
    if (_isRunning) return;
    _isRunning = true;
    _stateController.add(SyncRunState.running);
    try {
      await pushPendingOperations(entityTypes: const {SyncEntityType.enquiry});
      await _pullEnquiries();
      _stateController.add(SyncRunState.idle);
    } catch (e) {
      _stateController.add(SyncRunState.failed);
      debugPrint('SyncEngine: enquiry failed $e');
    } finally {
      _isRunning = false;
    }
  }

  Future<void> syncAttendance() async {
    if (_isRunning) return;
    _isRunning = true;
    _stateController.add(SyncRunState.running);
    try {
      await pushPendingOperations(
        entityTypes: const {SyncEntityType.attendance},
      );
      await _pullRecentAttendance();
      _stateController.add(SyncRunState.idle);
    } catch (e) {
      _stateController.add(SyncRunState.failed);
      debugPrint('SyncEngine: attendance push failed $e');
    } finally {
      _isRunning = false;
    }
  }

  Future<void> syncAttendanceForDate(DateTime date) async {
    if (_isRunning) return;
    _isRunning = true;
    _stateController.add(SyncRunState.running);
    try {
      await pushPendingOperations(
        entityTypes: const {SyncEntityType.attendance},
      );
      await _pullAttendanceForDate(date);
      _stateController.add(SyncRunState.idle);
    } catch (e) {
      _stateController.add(SyncRunState.failed);
      debugPrint('SyncEngine: attendance date sync failed $e');
    } finally {
      _isRunning = false;
    }
  }

  Future<void> pushPendingOperations({Set<SyncEntityType>? entityTypes}) async {
    final operations = await database.syncQueueDao.getPendingOperations();
    final filtered = entityTypes == null
        ? operations
        : operations
              .where((op) => entityTypes.contains(op.entityType))
              .toList();
    debugPrint('SyncEngine: pushing ${filtered.length} operations');
    for (final operation in filtered) {
      await database.syncQueueDao.markSyncing(operation.id);
      try {
        await _pushOperation(operation);
        await database.syncQueueDao.markCompleted(operation.id);
      } catch (e) {
        await _markLocalFailed(operation);
        await database.syncQueueDao.markFailed(operation.id, e);
        await database.syncQueueDao.incrementRetry(
          operation.id,
          operation.retryCount,
        );
      }
    }
  }

  Future<void> pullRemoteChanges() async {
    await _pullStudents();
    await _pullCourses();
    await _pullBatches();
    await _pullEnquiries();
    await _pullRecentAttendance();
  }

  Future<void> _pushOperation(SyncQueueData operation) async {
    switch (operation.entityType) {
      case SyncEntityType.course:
        await _pushCourse(operation);
      case SyncEntityType.batch:
        await _pushBatch(operation);
      case SyncEntityType.student:
        await _pushStudent(operation);
      case SyncEntityType.enquiry:
        await _pushEnquiry(operation);
      case SyncEntityType.attendance:
        await _pushAttendance(operation);
    }
  }

  Future<void> _markLocalFailed(SyncQueueData operation) async {
    switch (operation.entityType) {
      case SyncEntityType.course:
        await database.coursesDao.markCourseFailed(operation.entityId);
      case SyncEntityType.batch:
        await database.batchesDao.markBatchFailed(operation.entityId);
      case SyncEntityType.student:
        await database.studentsDao.markStudentFailed(operation.entityId);
      case SyncEntityType.enquiry:
        await database.enquiriesDao.markEnquiryFailed(operation.entityId);
      case SyncEntityType.attendance:
        await database.attendanceDao.markAttendanceFailed(operation.entityId);
    }
  }

  CollectionReference<Map<String, dynamic>> _collectionFor(
    SyncEntityType entityType,
  ) {
    return switch (entityType) {
      SyncEntityType.student => _remote.collection('students'),
      SyncEntityType.attendance => _remote.collection('attendances'),
      SyncEntityType.enquiry => _remote.collection('enquiries'),
      SyncEntityType.course => _remote.collection('courses'),
      SyncEntityType.batch => _remote.collection('batches'),
    };
  }

  Future<void> _pullStudents() async {
    final snapshot = await _remote.collection('students').get();
    await applyRemoteStudents(
      snapshot.docs.map(StudentMapper.fromFirestoreDoc).toList(),
    );
    debugPrint('OfflineStudents: remote pull ${snapshot.docs.length} records');
    await _markMetadata(SyncEntityType.student);
  }

  Future<void> _pullCourses() async {
    debugPrint('SyncEngine: syncing courses');
    final snapshot = await _remote.collection('courses').get();
    await applyRemoteCourses(
      snapshot.docs.map(CourseMapper.fromFirestoreDoc).toList(),
    );
    debugPrint('SyncEngine: pulled ${snapshot.docs.length} courses');
    await _markMetadata(SyncEntityType.course);
  }

  Future<void> _pullBatches() async {
    debugPrint('SyncEngine: syncing batches');
    final snapshot = await _remote.collection('batches').get();
    await applyRemoteBatches(
      snapshot.docs.map(BatchMapper.fromFirestoreDoc).toList(),
    );
    debugPrint('SyncEngine: pulled ${snapshot.docs.length} batches');
    await _markMetadata(SyncEntityType.batch);
  }

  Future<void> _pullEnquiries() async {
    final snapshot = await _remote.collection('enquiries').get();
    await applyRemoteEnquiries(
      snapshot.docs.map(EnquiryMapper.fromFirestoreDoc).toList(),
    );
    debugPrint(
      'OfflineEnquiries: pulled ${snapshot.docs.length} remote records',
    );
    await _markMetadata(SyncEntityType.enquiry);
  }

  Future<void> _pullRecentAttendance() async {
    final now = DateTime.now();
    await _pullAttendanceRange(
      start: DateTime(now.year, now.month, now.day - 14),
      end: DateTime(now.year, now.month, now.day + 1),
    );
  }

  Future<void> _pullAttendanceForDate(DateTime date) async {
    final day = DateTime(date.year, date.month, date.day);
    await _pullAttendanceRange(start: day, end: day);
  }

  Future<void> _pullAttendanceRange({
    required DateTime start,
    required DateTime end,
  }) async {
    final startKey = AttendanceMapper.dateKey(start);
    final endKey = AttendanceMapper.dateKey(end);
    final snapshot = await _remote
        .collection('attendances')
        .where('date', isGreaterThanOrEqualTo: startKey)
        .where('date', isLessThanOrEqualTo: '$endKey\uf8ff')
        .limit(1000)
        .get();
    await applyRemoteAttendance(
      snapshot.docs.map(AttendanceMapper.fromFirestoreDoc),
    );
    debugPrint(
      'OfflineAttendance: pulled ${snapshot.docs.length} records for $startKey..$endKey',
    );
    await _markMetadata(SyncEntityType.attendance);
  }

  Future<void> _markMetadata(SyncEntityType entityType) {
    final now = DateTime.now();
    return database
        .into(database.syncMetadata)
        .insertOnConflictUpdate(
          SyncMetadataCompanion.insert(
            entityType: entityType,
            updatedAt: now,
            lastPullAt: Value(now),
            lastSuccessfulSyncAt: Value(now),
          ),
        );
  }

  Future<void> applyRemoteCourses(
    Iterable<LocalCoursesCompanion> courses,
  ) async {
    await database.transaction(() async {
      for (final course in courses) {
        await database.coursesDao.upsertRemoteCoursePreservingPending(course);
      }
    });
  }

  Future<void> applyRemoteStudents(
    Iterable<LocalStudentsCompanion> students,
  ) async {
    await database.transaction(() async {
      for (final student in students) {
        await database.studentsDao.upsertRemoteStudentPreservingPending(
          student,
        );
      }
    });
  }

  Future<void> applyRemoteBatches(
    Iterable<LocalBatchesCompanion> batches,
  ) async {
    await database.transaction(() async {
      for (final batchRow in batches) {
        await database.batchesDao.upsertRemoteBatchPreservingPending(batchRow);
      }
    });
  }

  Future<void> applyRemoteEnquiries(
    Iterable<LocalEnquiriesCompanion> enquiries,
  ) async {
    await database.transaction(() async {
      for (final enquiry in enquiries) {
        await database.enquiriesDao.upsertRemoteEnquiryPreservingPending(
          enquiry,
        );
      }
    });
  }

  Future<void> applyRemoteAttendance(
    Iterable<LocalAttendancesCompanion> records,
  ) async {
    await database.transaction(() async {
      for (final record in records) {
        await database.attendanceDao.upsertRemoteAttendancePreservingPending(
          record,
        );
      }
    });
  }

  Future<void> _pushCourse(SyncQueueData operation) async {
    final row = await database.coursesDao.getCourseByCloudId(
      operation.entityId,
    );
    if (row == null) {
      throw StateError('Local course ${operation.entityId} not found.');
    }
    final collection = _collectionFor(SyncEntityType.course);
    if (operation.operationType == SyncOperationType.delete ||
        row.deletedAt != null ||
        !row.isActive) {
      final archivedAt = row.deletedAt ?? DateTime.now();
      await collection.doc(operation.entityId).set({
        'deleted_at': archivedAt.toIso8601String(),
        'is_active': false,
        'updated_at': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } else {
      await collection
          .doc(operation.entityId)
          .set(CourseMapper.toFirestorePayload(row), SetOptions(merge: true));
    }
    await database.coursesDao.markCourseSynced(operation.entityId);
    debugPrint('SyncEngine: ${operation.entityId} synced');
  }

  Future<void> _pushStudent(SyncQueueData operation) async {
    final row = await database.studentsDao.getStudentByCloudId(
      operation.entityId,
    );
    if (row == null) {
      throw StateError('Local student ${operation.entityId} not found.');
    }
    debugPrint('SyncEngine: pushing student ${operation.entityId}');
    final collection = _collectionFor(SyncEntityType.student);
    if (operation.operationType == SyncOperationType.delete ||
        row.deletedAt != null) {
      final archivedAt = row.deletedAt ?? DateTime.now();
      await collection.doc(operation.entityId).set({
        'deleted_at': archivedAt.toIso8601String(),
        'status': 'inactive',
        'is_active': false,
        'updated_at': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } else {
      await collection
          .doc(operation.entityId)
          .set(StudentMapper.toFirestorePayload(row), SetOptions(merge: true));
    }
    await database.studentsDao.markStudentSynced(operation.entityId);
    debugPrint('SyncEngine: student synced ${operation.entityId}');
  }

  Future<void> _pushEnquiry(SyncQueueData operation) async {
    final row = await database.enquiriesDao.getEnquiryByCloudId(
      operation.entityId,
    );
    if (row == null) {
      throw StateError('Local enquiry ${operation.entityId} not found.');
    }
    debugPrint('SyncEngine: pushing enquiry ${operation.entityId}');
    final collection = _collectionFor(SyncEntityType.enquiry);
    if (operation.operationType == SyncOperationType.delete ||
        row.deletedAt != null) {
      final archivedAt = row.deletedAt ?? DateTime.now();
      await collection.doc(operation.entityId).set({
        'deleted_at': archivedAt.toIso8601String(),
        'deletedAt': archivedAt.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } else {
      await collection
          .doc(operation.entityId)
          .set(EnquiryMapper.toFirestorePayload(row), SetOptions(merge: true));
    }
    await database.enquiriesDao.markEnquirySynced(operation.entityId);
    debugPrint('SyncEngine: enquiry synced ${operation.entityId}');
  }

  Future<void> _pushAttendance(SyncQueueData operation) async {
    final row = await database.attendanceDao.getAttendanceByKey(
      operation.entityId,
    );
    if (row == null) {
      throw StateError('Local attendance ${operation.entityId} not found.');
    }
    debugPrint('SyncEngine: pushing attendance ${operation.entityId}');
    final collection = _collectionFor(SyncEntityType.attendance);
    final cloudId = row.cloudId?.trim().isNotEmpty == true
        ? row.cloudId!
        : operation.entityId;
    await collection
        .doc(cloudId)
        .set(AttendanceMapper.toFirestorePayload(row), SetOptions(merge: true));
    await database.attendanceDao.markAttendanceSynced(operation.entityId);
    debugPrint('SyncEngine: attendance push success');
  }

  Future<void> _pushBatch(SyncQueueData operation) async {
    final row = await database.batchesDao.getBatchByCloudId(operation.entityId);
    if (row == null) {
      throw StateError('Local batch ${operation.entityId} not found.');
    }
    final collection = _collectionFor(SyncEntityType.batch);
    if (operation.operationType == SyncOperationType.delete ||
        row.deletedAt != null ||
        !row.isActive) {
      final archivedAt = row.deletedAt ?? DateTime.now();
      await collection.doc(operation.entityId).set({
        'deleted_at': archivedAt.toIso8601String(),
        'is_active': false,
        'updated_at': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } else {
      await collection
          .doc(operation.entityId)
          .set(BatchMapper.toFirestorePayload(row), SetOptions(merge: true));
    }
    await database.batchesDao.markBatchSynced(operation.entityId);
    debugPrint('SyncEngine: ${operation.entityId} synced');
  }

  Future<void> dispose() => _stateController.close();
}
