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
import 'sync_engine.dart';

class OfflineBootstrapResult {
  const OfflineBootstrapResult({
    required this.students,
    required this.courses,
    required this.batches,
    required this.enquiries,
    required this.attendance,
  });

  final int students;
  final int courses;
  final int batches;
  final int enquiries;
  final int attendance;
}

class CourseBatchBootstrapResult {
  const CourseBatchBootstrapResult({
    required this.courses,
    required this.batches,
    required this.students,
    required this.enquiries,
  });

  final int courses;
  final int batches;
  final int students;
  final int enquiries;
}

class OfflineBootstrapService {
  OfflineBootstrapService(this.database, {FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final AppDatabase database;
  final FirebaseFirestore _firestore;

  Future<OfflineBootstrapResult> bootstrapOfflineData() async {
    debugPrint('OfflineBootstrap: started');
    final now = DateTime.now();
    final attendanceStart = DateTime(now.year, now.month, now.day - 14);
    final attendanceEnd = DateTime(now.year, now.month, now.day + 1);
    final attendanceStartKey = AttendanceMapper.dateKey(attendanceStart);
    final attendanceEndKey = AttendanceMapper.dateKey(attendanceEnd);
    final result = await Future.wait([
      _firestore.collection('students').where('deleted_at', isNull: true).get(),
      _firestore.collection('courses').where('deleted_at', isNull: true).get(),
      _firestore.collection('batches').where('deleted_at', isNull: true).get(),
      _firestore
          .collection('enquiries')
          .where('deleted_at', isNull: true)
          .get(),
      _firestore
          .collection('attendances')
          .where('date', isGreaterThanOrEqualTo: attendanceStartKey)
          .where('date', isLessThanOrEqualTo: '$attendanceEndKey\uf8ff')
          .limit(1000)
          .get(),
    ]);

    final studentDocs = result[0].docs;
    final courseDocs = result[1].docs;
    final batchDocs = result[2].docs;
    final enquiryDocs = result[3].docs;
    final attendanceDocs = result[4].docs;

    await database.transaction(() async {
      await database.studentsDao.upsertStudents(
        studentDocs.map(StudentMapper.fromFirestoreDoc),
      );
      await database.coursesDao.upsertCourses(
        courseDocs.map(CourseMapper.fromFirestoreDoc),
      );
      await database.batchesDao.upsertBatches(
        batchDocs.map(BatchMapper.fromFirestoreDoc),
      );
      for (final doc in enquiryDocs) {
        await database.enquiriesDao.upsertEnquiry(
          EnquiryMapper.fromFirestoreDoc(doc),
        );
      }
      await database.attendanceDao.upsertAttendanceBatch(
        attendanceDocs.map(AttendanceMapper.fromFirestoreDoc),
      );
      await _markMetadata(SyncEntityType.student);
      await _markMetadata(SyncEntityType.course);
      await _markMetadata(SyncEntityType.batch);
      await _markMetadata(SyncEntityType.enquiry);
      await _markMetadata(SyncEntityType.attendance);
    });

    debugPrint(
      'OfflineBootstrap: students ${studentDocs.length}, courses ${courseDocs.length}, '
      'batches ${batchDocs.length}, enquiries ${enquiryDocs.length}, '
      'attendance ${attendanceDocs.length}',
    );
    return OfflineBootstrapResult(
      students: studentDocs.length,
      courses: courseDocs.length,
      batches: batchDocs.length,
      enquiries: enquiryDocs.length,
      attendance: attendanceDocs.length,
    );
  }

  Future<CourseBatchBootstrapResult>
  bootstrapCoursesBatchesAndStudents() async {
    debugPrint('OfflineBootstrap: courses/batches/students/enquiries started');
    final localCourseCount = await database.coursesDao.countCourses();
    final localBatchCount = await database.batchesDao.countBatches();
    final localStudentCount = await database.studentsDao.countStudents();
    final localEnquiryCount = await database.enquiriesDao.countEnquiries();
    final result = await Future.wait([
      _firestore.collection('courses').get(),
      _firestore.collection('batches').get(),
      _firestore.collection('students').get(),
      _firestore.collection('enquiries').get(),
    ]);
    final courseDocs = result[0].docs;
    final batchDocs = result[1].docs;
    final studentDocs = result[2].docs;
    final enquiryDocs = result[3].docs;

    final syncEngine = SyncEngine(database, firestore: _firestore);
    if (localCourseCount == 0) {
      await database.coursesDao.upsertCourses(
        courseDocs.map(CourseMapper.fromFirestoreDoc),
      );
    } else {
      await syncEngine.applyRemoteCourses(
        courseDocs.map(CourseMapper.fromFirestoreDoc),
      );
    }
    if (localBatchCount == 0) {
      await database.batchesDao.upsertBatches(
        batchDocs.map(BatchMapper.fromFirestoreDoc),
      );
    } else {
      await syncEngine.applyRemoteBatches(
        batchDocs.map(BatchMapper.fromFirestoreDoc),
      );
    }
    if (localStudentCount == 0) {
      await database.studentsDao.upsertStudents(
        studentDocs.map(StudentMapper.fromFirestoreDoc),
      );
    } else {
      await syncEngine.applyRemoteStudents(
        studentDocs.map(StudentMapper.fromFirestoreDoc),
      );
    }
    if (localEnquiryCount == 0) {
      for (final doc in enquiryDocs) {
        await database.enquiriesDao.upsertEnquiry(
          EnquiryMapper.fromFirestoreDoc(doc),
        );
      }
    } else {
      await syncEngine.applyRemoteEnquiries(
        enquiryDocs.map(EnquiryMapper.fromFirestoreDoc),
      );
    }
    await database.transaction(() async {
      await _markMetadata(SyncEntityType.course);
      await _markMetadata(SyncEntityType.batch);
      await _markMetadata(SyncEntityType.student);
      await _markMetadata(SyncEntityType.enquiry);
    });
    debugPrint(
      'OfflineBootstrap: courses ${courseDocs.length}, batches ${batchDocs.length}, students ${studentDocs.length}, enquiries ${enquiryDocs.length}',
    );
    await syncEngine.dispose();
    return CourseBatchBootstrapResult(
      courses: courseDocs.length,
      batches: batchDocs.length,
      students: studentDocs.length,
      enquiries: enquiryDocs.length,
    );
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
}
