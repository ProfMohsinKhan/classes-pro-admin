import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/database/app_database.dart';
import '../../core/database/sync_types.dart';
import '../../models/attendance_model.dart';
import '../../models/batch_model.dart';
import '../../models/course_model.dart';
import '../../models/enquiry_model.dart';
import '../../models/student_model.dart';
import '../mappers/attendance_mapper.dart';
import '../mappers/batch_mapper.dart';
import '../mappers/course_mapper.dart';
import '../mappers/enquiry_mapper.dart';
import '../mappers/student_mapper.dart';
import '../sync/sync_engine.dart';
import 'offline_repository_contracts.dart';

class OfflineStudentsRepository implements StudentsRepository {
  OfflineStudentsRepository(this.database, {SyncEngine? syncEngine})
    : _syncEngine = syncEngine ?? SyncEngine(database);

  final AppDatabase database;
  final SyncEngine _syncEngine;

  @override
  Stream<List<StudentModel>> watchStudents() => database.studentsDao
      .watchStudents()
      .map((rows) => rows.map(StudentMapper.toDomain).toList());

  @override
  Stream<List<StudentModel>> watchActiveStudents() => database.studentsDao
      .watchAllActiveStudents()
      .map((rows) => rows.map(StudentMapper.toDomain).toList());

  @override
  Stream<List<StudentModel>> watchStudentsByBatch(String batchId) => database
      .studentsDao
      .watchStudentsByBatch(batchId)
      .map((rows) => rows.map(StudentMapper.toDomain).toList());

  @override
  Stream<List<StudentModel>> watchStudentsByCourse(String courseId) => database
      .studentsDao
      .watchStudentsByCourse(courseId)
      .map((rows) => rows.map(StudentMapper.toDomain).toList());

  @override
  Stream<StudentModel?> watchStudentById(String studentId) => database
      .studentsDao
      .watchStudentByCloudId(studentId)
      .map((row) => row == null ? null : StudentMapper.toDomain(row));

  @override
  Stream<List<StudentModel>> searchStudents(String query) => database
      .studentsDao
      .searchStudents(query)
      .map((rows) => rows.map(StudentMapper.toDomain).toList());

  @override
  Stream<OfflineSyncSummary> watchSyncSummary() {
    return database.studentsDao.watchStudents().map(_studentSummary);
  }

  @override
  Future<StudentModel?> getStudentById(String studentId) async {
    final row = await database.studentsDao.getStudentByCloudId(studentId);
    return row == null ? null : StudentMapper.toDomain(row);
  }

  @override
  Future<StudentModel> createStudent(StudentModel student) async {
    final now = DateTime.now();
    final id = student.id.trim().isEmpty ? _newId('student') : student.id;
    final studentId = student.studentId.trim().isEmpty
        ? 'STU-${_legacyIdFromNow(now).toString().padLeft(4, '0')}'
        : student.studentId;
    final toSave = _copyStudent(
      student,
      id: id,
      studentId: studentId,
      createdAt: student.createdAt ?? now,
      updatedAt: now,
    );
    debugPrint('OfflineStudents: local create $id');
    await database.studentsDao.upsertStudent(
      StudentMapper.fromDomain(
        toSave,
        syncStatus: LocalSyncStatus.pendingCreate,
      ),
    );
    await _enqueue(id, SyncOperationType.upsert);
    return toSave;
  }

  @override
  Future<void> updateStudent(StudentModel student) async {
    debugPrint('OfflineStudents: local update ${student.id}');
    await database.studentsDao.upsertStudent(
      StudentMapper.fromDomain(
        _copyStudent(student, updatedAt: DateTime.now()),
        syncStatus: LocalSyncStatus.pendingUpdate,
      ),
    );
    await _enqueue(student.id, SyncOperationType.upsert);
  }

  @override
  Future<void> archiveStudent(String cloudId) async {
    debugPrint('OfflineStudents: archive $cloudId');
    await database.studentsDao.softDeleteStudent(cloudId);
    await _enqueue(cloudId, SyncOperationType.delete);
  }

  @override
  Future<void> restoreStudent(String cloudId) async {
    await database.studentsDao.restoreStudent(cloudId);
    await _enqueue(cloudId, SyncOperationType.upsert);
  }

  @override
  Future<void> requestSync() => _syncEngine.syncStudents();

  Future<void> _enqueue(String id, SyncOperationType operationType) async {
    await database.syncQueueDao.enqueue(
      entityType: SyncEntityType.student,
      entityId: id,
      operationType: operationType,
    );
    debugPrint('SyncEngine: queued $id');
    unawaited(
      _syncEngine.pushPendingOperations(
        entityTypes: const {SyncEntityType.student},
      ),
    );
  }

  OfflineSyncSummary _studentSummary(List<LocalStudent> rows) {
    if (rows.any((row) => row.syncStatus == LocalSyncStatus.failed)) {
      return OfflineSyncSummary.failed;
    }
    if (rows.any((row) => row.syncStatus != LocalSyncStatus.synced)) {
      return OfflineSyncSummary.pending;
    }
    return OfflineSyncSummary.synced;
  }
}

class OfflineAttendanceRepository implements AttendanceRepository {
  OfflineAttendanceRepository(
    this.database, {
    SyncEngine? syncEngine,
    bool autoSync = true,
  }) : _syncEngine = syncEngine ?? SyncEngine(database),
       _autoSync = autoSync;

  final AppDatabase database;
  final SyncEngine _syncEngine;
  final bool _autoSync;

  @override
  Stream<AttendanceDayData> watchAttendance(String dateKey, {String? batchId}) {
    return database.attendanceDao
        .watchAttendanceForDate(dateKey, batchId: batchId)
        .map(
          (rows) => AttendanceDayData(
            records: rows.map(AttendanceMapper.toDomain).toList(),
          ),
        );
  }

  @override
  Stream<List<AttendanceModel>> watchAttendanceForDate(String dateKey) {
    return database.attendanceDao
        .watchAttendanceForDate(dateKey)
        .map((rows) => rows.map(AttendanceMapper.toDomain).toList());
  }

  @override
  Stream<List<AttendanceModel>> watchAttendanceForDateAndBatch(
    String dateKey,
    String batchId,
  ) {
    return database.attendanceDao
        .watchAttendanceForDate(dateKey, batchId: batchId)
        .map((rows) => rows.map(AttendanceMapper.toDomain).toList());
  }

  @override
  Stream<List<AttendanceModel>> watchAttendanceForStudent(String studentId) {
    return database.attendanceDao
        .watchAttendanceForStudent(studentId)
        .map((rows) => rows.map(AttendanceMapper.toDomain).toList());
  }

  @override
  Stream<OfflineSyncSummary> watchSyncSummary() {
    return database.attendanceDao.watchAllAttendance().map(_attendanceSummary);
  }

  @override
  Future<List<AttendanceModel>> getAttendanceForDate(
    String dateKey, {
    String? batchId,
  }) async {
    final rows = await database.attendanceDao.getAttendanceForDateRows(
      dateKey,
      batchId: batchId,
    );
    return rows.map(AttendanceMapper.toDomain).toList();
  }

  @override
  Future<AttendanceModel?> getAttendanceRecord(String attendanceKey) async {
    final row = await database.attendanceDao.getAttendanceByKey(attendanceKey);
    return row == null ? null : AttendanceMapper.toDomain(row);
  }

  @override
  Future<AttendanceSaveResult> saveAttendanceDay(
    List<AttendanceModel> changedRecords,
  ) async {
    if (changedRecords.isEmpty) {
      return const AttendanceSaveResult(changedCount: 0);
    }
    final now = DateTime.now();
    await database.transaction(() async {
      for (final record in changedRecords) {
        final dateKey = AttendanceKeys.dateKey(record.date);
        final attendanceKey = AttendanceKeys.create(
          dateKey: dateKey,
          studentId: record.studentId,
          batchId: record.batchId,
        );
        final existing = await database.attendanceDao.getAttendanceByKey(
          attendanceKey,
        );
        final persisted = AttendanceModel(
          id: attendanceKey,
          studentId: record.studentId,
          studentName: record.studentName,
          date: record.date,
          status: record.status,
          batchId: record.batchId,
          batchName: record.batchName,
          className: record.className,
          markedBy: record.markedBy,
          markedByName: record.markedByName,
          createdAt: record.createdAt ?? existing?.createdAt ?? now,
          updatedAt: now,
        );
        await database.attendanceDao.upsertAttendance(
          AttendanceMapper.fromDomain(
            persisted,
            attendanceKey: attendanceKey,
            syncStatus: LocalSyncStatus.pendingUpdate,
          ),
        );
        await database.syncQueueDao.enqueue(
          entityType: SyncEntityType.attendance,
          entityId: attendanceKey,
          operationType: SyncOperationType.upsert,
        );
      }
    });
    if (_autoSync) {
      unawaited(
        _syncEngine.pushPendingOperations(
          entityTypes: const {SyncEntityType.attendance},
        ),
      );
    }
    return AttendanceSaveResult(changedCount: changedRecords.length);
  }

  @override
  Future<void> requestSync() async {
    if (!_autoSync) return;
    await _syncEngine.syncAttendance();
  }

  @override
  Future<void> syncAttendanceForDate(DateTime date) async {
    if (!_autoSync) return;
    await _syncEngine.syncAttendanceForDate(date);
  }

  OfflineSyncSummary _attendanceSummary(List<LocalAttendance> rows) {
    if (rows.any((row) => row.syncStatus == LocalSyncStatus.failed)) {
      return OfflineSyncSummary.failed;
    }
    if (rows.any((row) => row.syncStatus != LocalSyncStatus.synced)) {
      return OfflineSyncSummary.pending;
    }
    return OfflineSyncSummary.synced;
  }
}

class EnquiriesRepositoryImpl implements EnquiriesRepository {
  EnquiriesRepositoryImpl(this.database, {SyncEngine? syncEngine})
    : _syncEngine = syncEngine ?? SyncEngine(database);

  final AppDatabase database;
  final SyncEngine _syncEngine;

  @override
  Stream<List<EnquiryModel>> watchEnquiries() => database.enquiriesDao
      .watchEnquiries()
      .map((rows) => rows.map(EnquiryMapper.toDomain).toList());

  @override
  Stream<List<EnquiryModel>> watchActiveEnquiries() => database.enquiriesDao
      .watchActiveEnquiries()
      .map((rows) => rows.map(EnquiryMapper.toDomain).toList());

  @override
  Stream<List<EnquiryModel>> watchEnquiriesByStatus(String status) => database
      .enquiriesDao
      .watchEnquiriesByStatus(EnquiryMapper.normalizeStatus(status))
      .map((rows) => rows.map(EnquiryMapper.toDomain).toList());

  @override
  Stream<List<EnquiryModel>> watchUpcomingFollowUps(DateTime before) => database
      .enquiriesDao
      .watchUpcomingFollowUps(before)
      .map((rows) => rows.map(EnquiryMapper.toDomain).toList());

  @override
  Stream<EnquiryModel?> watchEnquiryById(String enquiryId) => database
      .enquiriesDao
      .watchEnquiryByCloudId(enquiryId)
      .map((row) => row == null ? null : EnquiryMapper.toDomain(row));

  @override
  Stream<List<EnquiryModel>> searchEnquiries(String query) => database
      .enquiriesDao
      .searchEnquiries(query)
      .map((rows) => rows.map(EnquiryMapper.toDomain).toList());

  @override
  Stream<OfflineSyncSummary> watchSyncSummary() {
    return database.enquiriesDao.watchEnquiries().map(_enquirySummary);
  }

  @override
  Future<EnquiryModel?> getEnquiryById(String enquiryId) async {
    final row = await database.enquiriesDao.getEnquiryByCloudId(enquiryId);
    return row == null ? null : EnquiryMapper.toDomain(row);
  }

  @override
  Future<void> createEnquiry(EnquiryModel enquiry) async {
    final now = DateTime.now();
    final id = enquiry.id.trim().isEmpty ? _newId('enquiry') : enquiry.id;
    final toSave = enquiry.copyWith(
      id: id,
      createdAt: enquiry.createdAt ?? now,
      updatedAt: now,
      enquiryStatus: EnquiryMapper.normalizeStatus(enquiry.enquiryStatus),
      syncStatus: LocalSyncStatus.pendingCreate,
    );
    debugPrint('OfflineEnquiries: local create $id');
    await database.enquiriesDao.upsertEnquiry(
      EnquiryMapper.fromDomain(
        toSave,
        syncStatus: LocalSyncStatus.pendingCreate,
      ),
    );
    await _enqueue(id, SyncOperationType.upsert);
  }

  @override
  Future<void> updateEnquiry(EnquiryModel enquiry) async {
    final toSave = enquiry.copyWith(
      updatedAt: DateTime.now(),
      enquiryStatus: EnquiryMapper.normalizeStatus(enquiry.enquiryStatus),
      syncStatus: LocalSyncStatus.pendingUpdate,
    );
    debugPrint('OfflineEnquiries: local update ${enquiry.id}');
    await database.enquiriesDao.upsertEnquiry(
      EnquiryMapper.fromDomain(
        toSave,
        syncStatus: LocalSyncStatus.pendingUpdate,
      ),
    );
    await _enqueue(enquiry.id, SyncOperationType.upsert);
  }

  @override
  Future<void> updateStatus(String enquiryId, String status) async {
    final enquiry = await getEnquiryById(enquiryId);
    if (enquiry == null) return;
    debugPrint('OfflineEnquiries: status changed $enquiryId');
    await updateEnquiry(
      enquiry.copyWith(enquiryStatus: EnquiryMapper.normalizeStatus(status)),
    );
  }

  @override
  Future<void> updateFollowUp(
    String enquiryId,
    DateTime? followUpDate, {
    String? notes,
  }) async {
    final enquiry = await getEnquiryById(enquiryId);
    if (enquiry == null) return;
    debugPrint('OfflineEnquiries: follow-up updated $enquiryId');
    await updateEnquiry(
      EnquiryModel(
        id: enquiry.id,
        legacyId: enquiry.legacyId,
        studentName: enquiry.studentName,
        parentName: enquiry.parentName,
        phone: enquiry.phone,
        alternatePhone: enquiry.alternatePhone,
        email: enquiry.email,
        dob: enquiry.dob,
        interestedCourseId: enquiry.interestedCourseId,
        interestedCourseName: enquiry.interestedCourseName,
        interestedBatchId: enquiry.interestedBatchId,
        interestedBatchName: enquiry.interestedBatchName,
        currentClass: enquiry.currentClass,
        schoolName: enquiry.schoolName,
        source: enquiry.source,
        enquiryStatus: enquiry.enquiryStatus,
        followUpDate: followUpDate,
        message: enquiry.message,
        followUpNotes: notes ?? enquiry.followUpNotes,
        notes: enquiry.notes,
        assignedTo: enquiry.assignedTo,
        assignedToName: enquiry.assignedToName,
        createdAt: enquiry.createdAt,
        updatedAt: enquiry.updatedAt,
        deletedAt: enquiry.deletedAt,
        syncStatus: enquiry.syncStatus,
      ),
    );
  }

  @override
  Future<void> archiveEnquiry(String enquiryId) async {
    debugPrint('OfflineEnquiries: local archive $enquiryId');
    await database.enquiriesDao.archiveEnquiry(enquiryId);
    await _enqueue(enquiryId, SyncOperationType.delete);
  }

  @override
  Future<void> restoreEnquiry(String enquiryId) async {
    await database.enquiriesDao.restoreEnquiry(enquiryId);
    await _enqueue(enquiryId, SyncOperationType.upsert);
  }

  @override
  Future<void> requestSync() => _syncEngine.syncEnquiries();

  Future<void> _enqueue(String id, SyncOperationType operationType) async {
    await database.syncQueueDao.enqueue(
      entityType: SyncEntityType.enquiry,
      entityId: id,
      operationType: operationType,
    );
    unawaited(
      _syncEngine.pushPendingOperations(
        entityTypes: const {SyncEntityType.enquiry},
      ),
    );
  }

  OfflineSyncSummary _enquirySummary(List<LocalEnquiry> rows) {
    if (rows.any((row) => row.syncStatus == LocalSyncStatus.failed)) {
      return OfflineSyncSummary.failed;
    }
    if (rows.any((row) => row.syncStatus != LocalSyncStatus.synced)) {
      return OfflineSyncSummary.pending;
    }
    return OfflineSyncSummary.synced;
  }
}

class CoursesRepositoryImpl implements CoursesRepository {
  CoursesRepositoryImpl(this.database, {SyncEngine? syncEngine})
    : _syncEngine = syncEngine ?? SyncEngine(database);

  final AppDatabase database;
  final SyncEngine _syncEngine;

  @override
  Stream<List<CourseModel>> watchCourses() => database.coursesDao
      .watchCourses()
      .map((rows) => rows.map(CourseModel.fromLocal).toList());

  @override
  Stream<List<CourseModel>> watchActiveCourses() => database.coursesDao
      .watchActiveCourses()
      .map((rows) => rows.map(CourseModel.fromLocal).toList());

  @override
  Stream<OfflineSyncSummary> watchSyncSummary() {
    return database.coursesDao.watchCourses().map(_courseSummary);
  }

  @override
  Future<CourseModel?> getCourseById(String id) async {
    final row = await database.coursesDao.getCourseByCloudId(id);
    return row == null ? null : CourseModel.fromLocal(row);
  }

  @override
  Future<void> createCourse(CourseModel course) async {
    final now = DateTime.now();
    final id = course.id.trim().isEmpty ? _newId('course') : course.id;
    final legacyId = course.legacyId ?? _legacyIdFromNow(now).toString();
    final toSave = course.copyWith(
      id: id,
      legacyId: legacyId,
      createdAt: course.createdAt ?? now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pendingCreate,
    );
    debugPrint('OfflineCourses: local create $id');
    await database.coursesDao.upsertCourse(
      CourseMapper.fromModel(toSave, syncStatus: LocalSyncStatus.pendingCreate),
    );
    await _enqueue(id, SyncOperationType.upsert);
  }

  @override
  Future<void> updateCourse(CourseModel course) async {
    final now = DateTime.now();
    debugPrint('OfflineCourses: local update ${course.id}');
    await database.coursesDao.upsertCourse(
      CourseMapper.fromModel(
        course.copyWith(
          updatedAt: now,
          syncStatus: LocalSyncStatus.pendingUpdate,
        ),
        syncStatus: LocalSyncStatus.pendingUpdate,
      ),
    );
    await _enqueue(course.id, SyncOperationType.upsert);
  }

  @override
  Future<void> archiveCourse(String id) async {
    debugPrint('OfflineCourses: local archive $id');
    await database.coursesDao.archiveCourse(id);
    await _enqueue(id, SyncOperationType.delete);
  }

  @override
  Future<void> restoreCourse(String id) async {
    await database.coursesDao.restoreCourse(id);
    await _enqueue(id, SyncOperationType.upsert);
  }

  @override
  Future<void> requestSync() => _syncEngine.syncCourses();

  Future<void> _enqueue(String id, SyncOperationType operationType) async {
    await database.syncQueueDao.enqueue(
      entityType: SyncEntityType.course,
      entityId: id,
      operationType: operationType,
    );
    debugPrint('SyncEngine: queued $id');
    unawaited(_syncEngine.pushPendingOperations());
  }

  OfflineSyncSummary _courseSummary(List<LocalCourse> rows) {
    if (rows.any((row) => row.syncStatus == LocalSyncStatus.failed)) {
      return OfflineSyncSummary.failed;
    }
    if (rows.any((row) => row.syncStatus != LocalSyncStatus.synced)) {
      return OfflineSyncSummary.pending;
    }
    return OfflineSyncSummary.synced;
  }
}

class BatchesRepositoryImpl implements BatchesRepository {
  BatchesRepositoryImpl(this.database, {SyncEngine? syncEngine})
    : _syncEngine = syncEngine ?? SyncEngine(database);

  final AppDatabase database;
  final SyncEngine _syncEngine;

  @override
  Stream<List<BatchModel>> watchBatches() => database.batchesDao
      .watchBatches()
      .map((rows) => rows.map(BatchModel.fromLocal).toList());

  @override
  Stream<List<BatchModel>> watchActiveBatches() => database.batchesDao
      .watchActiveBatches()
      .map((rows) => rows.map(BatchModel.fromLocal).toList());

  @override
  Stream<OfflineSyncSummary> watchSyncSummary() {
    return database.batchesDao.watchBatches().map(_batchSummary);
  }

  @override
  Future<BatchModel?> getBatchById(String id) async {
    final row = await database.batchesDao.getBatchByCloudId(id);
    return row == null ? null : BatchModel.fromLocal(row);
  }

  @override
  Future<void> createBatch(BatchModel batch) async {
    final now = DateTime.now();
    final id = batch.id.trim().isEmpty ? _newId('batch') : batch.id;
    final legacyId = batch.legacyId ?? _legacyIdFromNow(now).toString();
    final toSave = BatchModel(
      id: id,
      legacyId: legacyId,
      name: batch.name,
      courseId: batch.courseId,
      courseName: batch.courseName,
      days: batch.days,
      startDate: batch.startDate,
      endDate: batch.endDate,
      startTime: batch.startTime,
      endTime: batch.endTime,
      maxStudents: batch.maxStudents,
      isActive: batch.isActive,
      createdAt: batch.createdAt ?? now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pendingCreate,
    );
    debugPrint('OfflineBatches: local create $id');
    await database.batchesDao.upsertBatch(
      BatchMapper.fromModel(toSave, syncStatus: LocalSyncStatus.pendingCreate),
    );
    await _enqueue(id, SyncOperationType.upsert);
  }

  @override
  Future<void> updateBatch(BatchModel batch) async {
    final now = DateTime.now();
    final toSave = BatchModel(
      id: batch.id,
      legacyId: batch.legacyId,
      name: batch.name,
      courseId: batch.courseId,
      courseName: batch.courseName,
      days: batch.days,
      startDate: batch.startDate,
      endDate: batch.endDate,
      startTime: batch.startTime,
      endTime: batch.endTime,
      maxStudents: batch.maxStudents,
      isActive: batch.isActive,
      createdAt: batch.createdAt,
      updatedAt: now,
      deletedAt: batch.deletedAt,
      syncStatus: LocalSyncStatus.pendingUpdate,
    );
    debugPrint('OfflineBatches: local update ${batch.id}');
    await database.batchesDao.upsertBatch(
      BatchMapper.fromModel(toSave, syncStatus: LocalSyncStatus.pendingUpdate),
    );
    await _enqueue(batch.id, SyncOperationType.upsert);
  }

  @override
  Future<void> archiveBatch(String id) async {
    debugPrint('OfflineBatches: local archive $id');
    await database.batchesDao.archiveBatch(id);
    await _enqueue(id, SyncOperationType.delete);
  }

  @override
  Future<void> restoreBatch(String id) async {
    await database.batchesDao.restoreBatch(id);
    await _enqueue(id, SyncOperationType.upsert);
  }

  @override
  Future<void> requestSync() => _syncEngine.syncBatches();

  Future<void> _enqueue(String id, SyncOperationType operationType) async {
    await database.syncQueueDao.enqueue(
      entityType: SyncEntityType.batch,
      entityId: id,
      operationType: operationType,
    );
    debugPrint('SyncEngine: queued $id');
    unawaited(_syncEngine.pushPendingOperations());
  }

  OfflineSyncSummary _batchSummary(List<LocalBatch> rows) {
    if (rows.any((row) => row.syncStatus == LocalSyncStatus.failed)) {
      return OfflineSyncSummary.failed;
    }
    if (rows.any((row) => row.syncStatus != LocalSyncStatus.synced)) {
      return OfflineSyncSummary.pending;
    }
    return OfflineSyncSummary.synced;
  }
}

String _newId(String prefix) =>
    '${prefix}_${DateTime.now().microsecondsSinceEpoch}';

int _legacyIdFromNow(DateTime now) => now.millisecondsSinceEpoch % 100000;

StudentModel _copyStudent(
  StudentModel student, {
  String? id,
  String? studentId,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  return StudentModel(
    id: id ?? student.id,
    numericId: student.numericId,
    studentId: studentId ?? student.studentId,
    name: student.name,
    email: student.email,
    phone: student.phone,
    parentName: student.parentName,
    parentPhone: student.parentPhone,
    profilePhoto: student.profilePhoto,
    dob: student.dob,
    gender: student.gender,
    className: student.className,
    batchName: student.batchName,
    batchId: student.batchId,
    courseName: student.courseName,
    courseId: student.courseId,
    address: student.address,
    city: student.city,
    state: student.state,
    pincode: student.pincode,
    guardianName: student.guardianName,
    guardianRelation: student.guardianRelation,
    guardianPhone: student.guardianPhone,
    guardianEmail: student.guardianEmail,
    guardianOccupation: student.guardianOccupation,
    previousSchool: student.previousSchool,
    previousClass: student.previousClass,
    previousPercentage: student.previousPercentage,
    status: student.status,
    admissionDate: student.admissionDate,
    createdAt: createdAt ?? student.createdAt,
    updatedAt: updatedAt ?? student.updatedAt,
    referenceSource: student.referenceSource,
    qrCode: student.qrCode,
    notes: student.notes,
  );
}
