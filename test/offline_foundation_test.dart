import 'dart:io';

import 'package:classes_pro_admin/core/database/app_database.dart';
import 'package:classes_pro_admin/core/database/sync_types.dart';
import 'package:classes_pro_admin/data/mappers/batch_mapper.dart';
import 'package:classes_pro_admin/data/mappers/course_mapper.dart';
import 'package:classes_pro_admin/data/mappers/enquiry_mapper.dart';
import 'package:classes_pro_admin/data/mappers/student_mapper.dart';
import 'package:classes_pro_admin/data/repositories/offline_repositories.dart';
import 'package:classes_pro_admin/data/sync/sync_engine.dart';
import 'package:classes_pro_admin/models/attendance_model.dart';
import 'package:classes_pro_admin/models/app_user_model.dart';
import 'package:classes_pro_admin/models/permission_keys.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('student mapper preserves legacy aliases and tolerant dates', () {
    final companion = StudentMapper.fromFirestoreMap('cloud-1', {
      'id': '42',
      'name': '  Aisha Khan  ',
      'guardian_name': 'Mrs Khan',
      'guardian_phone': 9998887777,
      'dateOfBirth': Timestamp.fromDate(DateTime(2010, 5, 3)),
      'previous_class': '8',
      'course': 'CBSE 9',
      'batch': 'Morning',
      'created_at': '2026-01-02T03:04:05.000',
    });

    expect(companion.cloudId.value, 'cloud-1');
    expect(companion.studentIdLegacy.value, '42');
    expect(companion.parentName.value, 'Mrs Khan');
    expect(companion.parentPhone.value, '9998887777');
    expect(companion.className.value, '8');
    expect(companion.courseName.value, 'CBSE 9');
    expect(companion.batchName.value, 'Morning');
    expect(companion.createdAt.value, DateTime(2026, 1, 2, 3, 4, 5));
  });

  test('attendance stable key changes only for logical identity', () {
    final keyA = AttendanceKeys.create(
      dateKey: '2026-07-04',
      studentId: 'student-1',
      batchId: 'batch-1',
    );
    final keyB = AttendanceKeys.create(
      dateKey: '2026-07-04',
      studentId: 'student-1',
      batchId: 'batch-1',
    );
    final keyC = AttendanceKeys.create(
      dateKey: '2026-07-05',
      studentId: 'student-1',
      batchId: 'batch-1',
    );

    expect(keyA, keyB);
    expect(keyA, isNot(keyC));
    expect(
      AttendanceKeys.create(dateKey: '2026-07-04', studentId: 'student-1'),
      '2026-07-04|all|student-1',
    );
  });

  test('attendance date and status normalization are stable', () {
    expect(AttendanceKeys.dateKey(DateTime(2026, 7, 4, 23, 59)), '2026-07-04');
    expect(AttendanceModel.parseStatus('PRESENT'), AttendanceStatus.present);
    expect(AttendanceModel.parseStatus('p'), AttendanceStatus.present);
    expect(AttendanceModel.parseStatus('A'), AttendanceStatus.absent);
    expect(AttendanceModel.parseStatus('Late'), AttendanceStatus.late);
    expect(AttendanceModel.parseStatus('holiday'), AttendanceStatus.leave);
  });

  test(
    'drift reactive student query emits inserted and updated rows',
    () async {
      final emissions = <List<LocalStudent>>[];
      final subscription = database.studentsDao.watchAllActiveStudents().listen(
        emissions.add,
      );

      await database.studentsDao.upsertStudent(
        LocalStudentsCompanion.insert(
          cloudId: const Value('student-cloud'),
          name: 'Zara',
          normalizedName: 'zara',
          syncStatus: LocalSyncStatus.synced,
        ),
      );
      await pumpEventQueue();

      await database.studentsDao.upsertStudent(
        LocalStudentsCompanion.insert(
          cloudId: const Value('student-cloud'),
          name: 'Zara Ali',
          normalizedName: 'zara ali',
          syncStatus: LocalSyncStatus.synced,
        ),
      );
      await pumpEventQueue();

      expect(
        emissions.where((rows) => rows.isNotEmpty).first.single.name,
        'Zara',
      );
      expect(emissions.last.single.name, 'Zara Ali');
      await subscription.cancel();
    },
  );

  test('sync queue deduplicates repeated updates for same entity', () async {
    for (var i = 0; i < 5; i++) {
      await database.syncQueueDao.enqueue(
        entityType: SyncEntityType.student,
        entityId: 'student-cloud',
        operationType: SyncOperationType.update,
        payloadJson: '{"name":"Edit $i"}',
      );
    }

    final rows = await database.select(database.syncQueue).get();
    expect(rows, hasLength(1));
    expect(rows.single.payloadJson, '{"name":"Edit 4"}');
  });

  test('permission model behavior remains cloud-first and unchanged', () {
    const inactiveAdmin = AppUserModel(
      uid: '1',
      email: 'admin@example.com',
      name: 'Admin',
      role: 'admin',
      status: 'disabled',
    );
    const receptionist = AppUserModel(
      uid: '2',
      email: 'desk@example.com',
      name: 'Desk',
      role: 'receptionist',
      status: 'active',
      permissions: {PermissionKeys.studentsView: true},
    );

    expect(inactiveAdmin.canViewStudents, isFalse);
    expect(receptionist.canViewStudents, isTrue);
    expect(receptionist.can(PermissionKeys.staffManage), isFalse);
  });

  test(
    'course reactive flow updates and archive hides active stream',
    () async {
      final emissions = <List<LocalCourse>>[];
      final subscription = database.coursesDao.watchActiveCourses().listen(
        emissions.add,
      );

      await database.coursesDao.upsertCourse(
        LocalCoursesCompanion.insert(
          cloudId: const Value('course-1'),
          name: 'Math',
          syncStatus: LocalSyncStatus.synced,
        ),
      );
      await pumpEventQueue();

      await database.coursesDao.upsertCourse(
        LocalCoursesCompanion.insert(
          cloudId: const Value('course-1'),
          name: 'Advanced Math',
          syncStatus: LocalSyncStatus.pendingUpdate,
        ),
      );
      await pumpEventQueue();

      await database.coursesDao.archiveCourse('course-1');
      await pumpEventQueue();

      expect(
        emissions.where((rows) => rows.isNotEmpty).first.single.name,
        'Math',
      );
      expect(
        emissions.where((rows) => rows.isNotEmpty).last.single.name,
        'Advanced Math',
      );
      expect(emissions.last, isEmpty);
      await subscription.cancel();
    },
  );

  test('batch reactive flow updates and archive hides active stream', () async {
    final emissions = <List<LocalBatch>>[];
    final subscription = database.batchesDao.watchActiveBatches().listen(
      emissions.add,
    );

    await database.batchesDao.upsertBatch(
      LocalBatchesCompanion.insert(
        cloudId: const Value('batch-1'),
        name: 'Morning',
        syncStatus: LocalSyncStatus.synced,
      ),
    );
    await pumpEventQueue();

    await database.batchesDao.upsertBatch(
      LocalBatchesCompanion.insert(
        cloudId: const Value('batch-1'),
        name: 'Morning Prime',
        syncStatus: LocalSyncStatus.pendingUpdate,
      ),
    );
    await pumpEventQueue();

    await database.batchesDao.archiveBatch('batch-1');
    await pumpEventQueue();

    expect(
      emissions.where((rows) => rows.isNotEmpty).first.single.name,
      'Morning',
    );
    expect(
      emissions.where((rows) => rows.isNotEmpty).last.single.name,
      'Morning Prime',
    );
    expect(emissions.last, isEmpty);
    await subscription.cancel();
  });

  test('sync queue deduplicates repeated course and batch edits', () async {
    for (var i = 0; i < 3; i++) {
      await database.syncQueueDao.enqueue(
        entityType: SyncEntityType.course,
        entityId: 'course-1',
        operationType: SyncOperationType.upsert,
        payloadJson: '{"edit":$i}',
      );
      await database.syncQueueDao.enqueue(
        entityType: SyncEntityType.batch,
        entityId: 'batch-1',
        operationType: SyncOperationType.upsert,
        payloadJson: '{"edit":$i}',
      );
    }

    final rows = await database.select(database.syncQueue).get();
    expect(rows, hasLength(2));
    expect(
      rows
          .where((row) => row.entityType == SyncEntityType.course)
          .single
          .payloadJson,
      '{"edit":2}',
    );
    expect(
      rows
          .where((row) => row.entityType == SyncEntityType.batch)
          .single
          .payloadJson,
      '{"edit":2}',
    );
  });

  test(
    'remote pull does not overwrite pending local course or batch',
    () async {
      await database.coursesDao.upsertCourse(
        LocalCoursesCompanion.insert(
          cloudId: const Value('course-1'),
          name: 'Local Course',
          syncStatus: LocalSyncStatus.pendingUpdate,
        ),
      );
      await database.batchesDao.upsertBatch(
        LocalBatchesCompanion.insert(
          cloudId: const Value('batch-1'),
          name: 'Local Batch',
          syncStatus: LocalSyncStatus.failed,
        ),
      );

      final syncEngine = SyncEngine(database);
      await syncEngine.applyRemoteCourses([
        CourseMapper.fromFirestoreMap('course-1', {'name': 'Remote Course'}),
      ]);
      await syncEngine.applyRemoteBatches([
        BatchMapper.fromFirestoreMap('batch-1', {'name': 'Remote Batch'}),
      ]);
      await syncEngine.dispose();

      expect(
        (await database.coursesDao.getCourseByCloudId('course-1'))!.name,
        'Local Course',
      );
      expect(
        (await database.batchesDao.getBatchByCloudId('batch-1'))!.name,
        'Local Batch',
      );
    },
  );

  test('course and batch mappers handle legacy fields safely', () {
    final course = CourseMapper.fromFirestoreMap('course-1', {
      'id': 44,
      'name': 'Science',
      'monthly_fees': '1200.50',
      'yearly_fees': 12000,
      'duration_months': '12',
      'max_students': '40',
      'is_active': 'true',
      'created_at': Timestamp.fromDate(DateTime(2026, 1, 1)),
    });
    final batch = BatchMapper.fromFirestoreMap('batch-1', {
      'id': '55',
      'name': 'Evening',
      'course_id': '44',
      'days': 'Mon, Wed, Fri',
      'start_date': '2026-02-01T00:00:00.000',
      'end_date': Timestamp.fromDate(DateTime(2026, 12, 31)),
    });

    expect(course.legacyId.value, '44');
    expect(course.monthlyFees.value, 1200.50);
    expect(course.durationMonths.value, 12);
    expect(course.isActive.value, isTrue);
    expect(batch.legacyId.value, '55');
    expect(batch.courseId.value, '44');
    expect(batch.startDate.value, DateTime(2026, 2, 1));
  });

  test('course/batch bootstrap-style remote apply is idempotent', () async {
    final syncEngine = SyncEngine(database);
    final courses = [
      CourseMapper.fromFirestoreMap('course-1', {'name': 'Science'}),
    ];
    final batches = [
      BatchMapper.fromFirestoreMap('batch-1', {'name': 'Evening'}),
    ];

    await syncEngine.applyRemoteCourses(courses);
    await syncEngine.applyRemoteBatches(batches);
    await syncEngine.applyRemoteCourses(courses);
    await syncEngine.applyRemoteBatches(batches);
    await syncEngine.dispose();

    expect(await database.coursesDao.countCourses(), 1);
    expect(await database.batchesDao.countBatches(), 1);
  });

  test('course and batch manage permissions remain respected', () {
    const viewer = AppUserModel(
      uid: '3',
      email: 'viewer@example.com',
      name: 'Viewer',
      role: 'studentHelper',
      status: 'active',
      permissions: {
        PermissionKeys.coursesView: true,
        PermissionKeys.coursesManage: false,
        PermissionKeys.batchesView: true,
        PermissionKeys.batchesManage: false,
      },
    );

    expect(viewer.canViewCourses, isTrue);
    expect(viewer.canManageCourses, isFalse);
    expect(viewer.canViewBatches, isTrue);
    expect(viewer.canManageBatches, isFalse);
  });

  test(
    'student reactive stream updates and archive hides active stream',
    () async {
      final emissions = <List<LocalStudent>>[];
      final subscription = database.studentsDao.watchAllActiveStudents().listen(
        emissions.add,
      );

      await database.studentsDao.upsertStudent(
        LocalStudentsCompanion.insert(
          cloudId: const Value('student-13c'),
          name: 'Aarav',
          normalizedName: 'aarav',
          phone: const Value('9000011111'),
          syncStatus: LocalSyncStatus.synced,
        ),
      );
      await pumpEventQueue();

      await database.studentsDao.upsertStudent(
        LocalStudentsCompanion.insert(
          cloudId: const Value('student-13c'),
          name: 'Aarav Shah',
          normalizedName: 'aarav shah',
          phone: const Value('9000011111'),
          syncStatus: LocalSyncStatus.pendingUpdate,
        ),
      );
      await pumpEventQueue();

      await database.studentsDao.softDeleteStudent('student-13c');
      await pumpEventQueue();

      expect(
        emissions.where((rows) => rows.isNotEmpty).first.single.name,
        'Aarav',
      );
      expect(
        emissions.where((rows) => rows.isNotEmpty).last.single.name,
        'Aarav Shah',
      );
      expect(emissions.last, isEmpty);
      await subscription.cancel();
    },
  );

  test(
    'student local search covers name phone parent course and batch',
    () async {
      await database.studentsDao.upsertStudent(
        LocalStudentsCompanion.insert(
          cloudId: const Value('student-search'),
          name: 'Meera Patil',
          normalizedName: 'meera patil',
          phone: const Value('7777777777'),
          parentName: const Value('Ravi Patil'),
          parentPhone: const Value('8888888888'),
          courseName: const Value('Science'),
          batchName: const Value('Evening'),
          syncStatus: LocalSyncStatus.synced,
        ),
      );

      expect(
        await database.studentsDao.searchStudents('meera').first,
        hasLength(1),
      );
      expect(
        await database.studentsDao.searchStudents('8888').first,
        hasLength(1),
      );
      expect(
        await database.studentsDao.searchStudents('science').first,
        hasLength(1),
      );
      expect(
        await database.studentsDao.searchStudents('evening').first,
        hasLength(1),
      );
    },
  );

  test('student sync queue repeated edits collapse safely', () async {
    for (var i = 0; i < 4; i++) {
      await database.syncQueueDao.enqueue(
        entityType: SyncEntityType.student,
        entityId: 'student-dedupe',
        operationType: SyncOperationType.upsert,
        payloadJson: '{"edit":$i}',
      );
    }

    final rows = await database.select(database.syncQueue).get();
    expect(rows, hasLength(1));
    expect(rows.single.entityType, SyncEntityType.student);
    expect(rows.single.payloadJson, '{"edit":3}');
  });

  test('remote pull does not overwrite pending local student', () async {
    await database.studentsDao.upsertStudent(
      LocalStudentsCompanion.insert(
        cloudId: const Value('student-pending'),
        name: 'Local Student',
        normalizedName: 'local student',
        syncStatus: LocalSyncStatus.pendingUpdate,
      ),
    );

    final syncEngine = SyncEngine(database);
    await syncEngine.applyRemoteStudents([
      StudentMapper.fromFirestoreMap('student-pending', {
        'name': 'Remote Student',
      }),
    ]);
    await syncEngine.dispose();

    expect(
      (await database.studentsDao.getStudentByCloudId('student-pending'))!.name,
      'Local Student',
    );
  });

  test('student remote apply is idempotent', () async {
    final syncEngine = SyncEngine(database);
    final students = [
      StudentMapper.fromFirestoreMap('student-idem', {'name': 'Idem Student'}),
    ];

    await syncEngine.applyRemoteStudents(students);
    await syncEngine.applyRemoteStudents(students);
    await syncEngine.dispose();

    expect(await database.studentsDao.countStudents(), 1);
  });

  test('student mapper handles aliases and numeric timestamps', () {
    final companion = StudentMapper.fromFirestoreMap('student-map', {
      'id': 7,
      'name': 'Alias Student',
      'guardian_name': 'Alias Parent',
      'guardian_phone': 1234567890,
      'birthDate': 1783168027000,
      'standard': '10',
      'course': 'Math',
      'batch': 'Morning',
      'is_active': false,
    });

    expect(companion.studentIdLegacy.value, '7');
    expect(companion.parentName.value, 'Alias Parent');
    expect(companion.parentPhone.value, '1234567890');
    expect(companion.className.value, '10');
    expect(companion.courseName.value, 'Math');
    expect(companion.batchName.value, 'Morning');
    expect(companion.status.value, 'inactive');
    expect(companion.dob.value == null, isFalse);
  });

  test('student mapper normalizes legacy active status casing', () {
    final active = StudentMapper.fromFirestoreMap('student-active', {
      'name': 'Active Student',
      'status': 'Active',
    });
    final disabled = StudentMapper.fromFirestoreMap('student-disabled', {
      'name': 'Disabled Student',
      'status': 'DISABLED',
    });

    expect(active.status.value, 'active');
    expect(disabled.status.value, 'inactive');
  });

  test('enquiry mapper handles aliases statuses and tolerant dates', () {
    final companion = EnquiryMapper.fromFirestoreMap('enquiry-map', {
      'id': 9,
      'name': '  Lead Name ',
      'guardian_name': 'Lead Parent',
      'mobileNumber': 9998887777,
      'alternate_phone': '8887776666',
      'course_id': 'course-1',
      'course_name': 'Science',
      'batch_id': 'batch-1',
      'batch_name': 'Morning',
      'status': 'follow_up',
      'follow_up_date': Timestamp.fromDate(DateTime(2026, 8, 1)),
      'created_at': '2026-07-01T10:00:00.000',
      'updated_at': 1783168027,
    });

    expect(companion.cloudId.value, 'enquiry-map');
    expect(companion.legacyId.value, '9');
    expect(companion.studentName.value, 'Lead Name');
    expect(companion.parentName.value, 'Lead Parent');
    expect(companion.phone.value, '9998887777');
    expect(companion.alternatePhone.value, '8887776666');
    expect(companion.interestedCourseId.value, 'course-1');
    expect(companion.interestedCourseName.value, 'Science');
    expect(companion.interestedBatchId.value, 'batch-1');
    expect(companion.interestedBatchName.value, 'Morning');
    expect(companion.enquiryStatus.value, 'followUp');
    expect(companion.followUpDate.value, DateTime(2026, 8, 1));
    expect(companion.createdAt.value, DateTime(2026, 7, 1, 10));
    expect(companion.updatedAt.value == null, isFalse);
  });

  test(
    'enquiry reactive stream updates and archive hides active stream',
    () async {
      final emissions = <List<LocalEnquiry>>[];
      final subscription = database.enquiriesDao.watchActiveEnquiries().listen(
        emissions.add,
      );

      await database.enquiriesDao.upsertEnquiry(
        LocalEnquiriesCompanion.insert(
          cloudId: const Value('enquiry-1'),
          studentName: 'Riya',
          phone: const Value('9000011111'),
          interestedCourseName: const Value('Math'),
          syncStatus: LocalSyncStatus.synced,
        ),
      );
      await pumpEventQueue();

      await database.enquiriesDao.upsertEnquiry(
        LocalEnquiriesCompanion.insert(
          cloudId: const Value('enquiry-1'),
          studentName: 'Riya Shah',
          phone: const Value('9000011111'),
          interestedCourseName: const Value('Math'),
          syncStatus: LocalSyncStatus.pendingUpdate,
        ),
      );
      await pumpEventQueue();

      await database.enquiriesDao.archiveEnquiry('enquiry-1');
      await pumpEventQueue();

      expect(
        emissions.where((rows) => rows.isNotEmpty).first.single.studentName,
        'Riya',
      );
      expect(
        emissions.where((rows) => rows.isNotEmpty).last.single.studentName,
        'Riya Shah',
      );
      expect(emissions.last, isEmpty);
      await subscription.cancel();
    },
  );

  test('enquiry local search status and follow-up queries work', () async {
    await database.enquiriesDao.upsertEnquiry(
      LocalEnquiriesCompanion.insert(
        cloudId: const Value('enquiry-search'),
        studentName: 'Kabir Khan',
        parentName: const Value('Salma Khan'),
        phone: const Value('7777777777'),
        alternatePhone: const Value('8888888888'),
        interestedCourseName: const Value('Science'),
        interestedBatchName: const Value('Evening'),
        enquiryStatus: const Value('contacted'),
        followUpDate: Value(DateTime(2026, 7, 6)),
        syncStatus: LocalSyncStatus.synced,
      ),
    );

    expect(
      await database.enquiriesDao.searchEnquiries('kabir').first,
      hasLength(1),
    );
    expect(
      await database.enquiriesDao.searchEnquiries('salma').first,
      hasLength(1),
    );
    expect(
      await database.enquiriesDao.searchEnquiries('8888').first,
      hasLength(1),
    );
    expect(
      await database.enquiriesDao.searchEnquiries('science').first,
      hasLength(1),
    );
    expect(
      await database.enquiriesDao.watchEnquiriesByStatus('contacted').first,
      hasLength(1),
    );
    expect(
      await database.enquiriesDao
          .watchUpcomingFollowUps(DateTime(2026, 7, 7))
          .first,
      hasLength(1),
    );
  });

  test('enquiry sync queue repeated edits collapse safely', () async {
    for (var i = 0; i < 4; i++) {
      await database.syncQueueDao.enqueue(
        entityType: SyncEntityType.enquiry,
        entityId: 'enquiry-dedupe',
        operationType: SyncOperationType.upsert,
        payloadJson: '{"edit":$i}',
      );
    }

    final rows = await database.select(database.syncQueue).get();
    expect(rows, hasLength(1));
    expect(rows.single.entityType, SyncEntityType.enquiry);
    expect(rows.single.payloadJson, '{"edit":3}');
  });

  test('remote pull does not overwrite pending local enquiry', () async {
    await database.enquiriesDao.upsertEnquiry(
      LocalEnquiriesCompanion.insert(
        cloudId: const Value('enquiry-pending'),
        studentName: 'Local Lead',
        syncStatus: LocalSyncStatus.failed,
      ),
    );

    final syncEngine = SyncEngine(database);
    await syncEngine.applyRemoteEnquiries([
      EnquiryMapper.fromFirestoreMap('enquiry-pending', {
        'name': 'Remote Lead',
      }),
    ]);
    await syncEngine.dispose();

    expect(
      (await database.enquiriesDao.getEnquiryByCloudId(
        'enquiry-pending',
      ))!.studentName,
      'Local Lead',
    );
  });

  test('enquiry remote apply is idempotent', () async {
    final syncEngine = SyncEngine(database);
    final enquiries = [
      EnquiryMapper.fromFirestoreMap('enquiry-idem', {'name': 'Idem Lead'}),
    ];

    await syncEngine.applyRemoteEnquiries(enquiries);
    await syncEngine.applyRemoteEnquiries(enquiries);
    await syncEngine.dispose();

    expect(await database.enquiriesDao.countEnquiries(), 1);
  });

  test(
    'attendance DAO reactive update and batch/date filtering work',
    () async {
      final emissions = <List<LocalAttendance>>[];
      final subscription = database.attendanceDao
          .watchAttendanceForDate('2026-07-04', batchId: 'batch-1')
          .listen(emissions.add);

      final key = AttendanceKeys.create(
        dateKey: '2026-07-04',
        studentId: 'student-1',
        batchId: 'batch-1',
      );
      await database.attendanceDao.upsertAttendance(
        LocalAttendancesCompanion.insert(
          cloudId: Value(key),
          attendanceKey: key,
          studentId: 'student-1',
          studentName: 'Student One',
          dateKey: '2026-07-04',
          attendanceDate: DateTime(2026, 7, 4),
          batchId: const Value('batch-1'),
          status: 'present',
          syncStatus: LocalSyncStatus.synced,
        ),
      );
      await pumpEventQueue();

      await database.attendanceDao.upsertAttendance(
        LocalAttendancesCompanion.insert(
          cloudId: Value(key),
          attendanceKey: key,
          studentId: 'student-1',
          studentName: 'Student One',
          dateKey: '2026-07-04',
          attendanceDate: DateTime(2026, 7, 4),
          batchId: const Value('batch-1'),
          status: 'late',
          syncStatus: LocalSyncStatus.pendingUpdate,
        ),
      );
      await pumpEventQueue();

      expect(
        emissions.where((rows) => rows.isNotEmpty).first.single.status,
        'present',
      );
      expect(
        emissions.where((rows) => rows.isNotEmpty).last.single.status,
        'late',
      );
      expect(
        await database.attendanceDao.getAttendanceForDateRows(
          '2026-07-04',
          batchId: 'batch-1',
        ),
        hasLength(1),
      );
      await subscription.cancel();
    },
  );

  test(
    'attendance save persists changed records and queue atomically',
    () async {
      final repository = OfflineAttendanceRepository(database, autoSync: false);
      final result = await repository.saveAttendanceDay([
        AttendanceModel(
          id: '',
          studentId: 'student-atomic',
          studentName: 'Atomic Student',
          date: DateTime(2026, 7, 4),
          status: AttendanceStatus.present,
          batchId: 'batch-atomic',
          batchName: 'Atomic Batch',
        ),
      ]);

      final key = AttendanceKeys.create(
        dateKey: '2026-07-04',
        studentId: 'student-atomic',
        batchId: 'batch-atomic',
      );
      expect(result.changedCount, 1);
      expect(
        (await database.attendanceDao.getAttendanceByKey(key))!.status,
        'present',
      );
      final queueRows = await database.select(database.syncQueue).get();
      expect(queueRows, hasLength(1));
      expect(queueRows.single.entityType, SyncEntityType.attendance);
      expect(queueRows.single.entityId, key);
    },
  );

  test('attendance queue dedupes repeated saves for same key', () async {
    final key = AttendanceKeys.create(
      dateKey: '2026-07-04',
      studentId: 'student-dedupe',
      batchId: 'batch-1',
    );
    for (var i = 0; i < 3; i++) {
      await database.syncQueueDao.enqueue(
        entityType: SyncEntityType.attendance,
        entityId: key,
        operationType: SyncOperationType.upsert,
        payloadJson: '{"edit":$i}',
      );
    }

    final rows = await database.select(database.syncQueue).get();
    expect(rows, hasLength(1));
    expect(rows.single.payloadJson, '{"edit":2}');
  });

  test('remote pull does not overwrite pending local attendance', () async {
    final key = AttendanceKeys.create(
      dateKey: '2026-07-04',
      studentId: 'student-pending-att',
      batchId: 'batch-1',
    );
    await database.attendanceDao.upsertAttendance(
      LocalAttendancesCompanion.insert(
        cloudId: Value(key),
        attendanceKey: key,
        studentId: 'student-pending-att',
        studentName: 'Pending Student',
        dateKey: '2026-07-04',
        attendanceDate: DateTime(2026, 7, 4),
        batchId: const Value('batch-1'),
        status: 'present',
        syncStatus: LocalSyncStatus.pendingUpdate,
      ),
    );

    final syncEngine = SyncEngine(database);
    await syncEngine.applyRemoteAttendance([
      LocalAttendancesCompanion.insert(
        cloudId: Value(key),
        attendanceKey: key,
        studentId: 'student-pending-att',
        studentName: 'Pending Student',
        dateKey: '2026-07-04',
        attendanceDate: DateTime(2026, 7, 4),
        batchId: const Value('batch-1'),
        status: 'absent',
        syncStatus: LocalSyncStatus.synced,
      ),
    ]);
    await syncEngine.dispose();

    expect(
      (await database.attendanceDao.getAttendanceByKey(key))!.status,
      'present',
    );
  });

  test(
    'remote pull does not overwrite newer synced local attendance',
    () async {
      final key = AttendanceKeys.create(
        dateKey: '2026-07-04',
        studentId: 'student-newer-att',
        batchId: 'batch-1',
      );
      await database.attendanceDao.upsertAttendance(
        LocalAttendancesCompanion.insert(
          cloudId: Value(key),
          attendanceKey: key,
          studentId: 'student-newer-att',
          studentName: 'Newer Student',
          dateKey: '2026-07-04',
          attendanceDate: DateTime(2026, 7, 4),
          batchId: const Value('batch-1'),
          status: 'present',
          updatedAt: Value(DateTime(2026, 7, 4, 10)),
          syncStatus: LocalSyncStatus.synced,
        ),
      );

      final syncEngine = SyncEngine(database);
      await syncEngine.applyRemoteAttendance([
        LocalAttendancesCompanion.insert(
          cloudId: Value(key),
          attendanceKey: key,
          studentId: 'student-newer-att',
          studentName: 'Newer Student',
          dateKey: '2026-07-04',
          attendanceDate: DateTime(2026, 7, 4),
          batchId: const Value('batch-1'),
          status: 'absent',
          updatedAt: Value(DateTime(2026, 7, 4, 9)),
          syncStatus: LocalSyncStatus.synced,
        ),
      ]);
      await syncEngine.dispose();

      expect(
        (await database.attendanceDao.getAttendanceByKey(key))!.status,
        'present',
      );
    },
  );

  test(
    'remote pull without timestamp does not overwrite local attendance',
    () async {
      final key = AttendanceKeys.create(
        dateKey: '2026-07-04',
        studentId: 'student-local-timestamp',
        batchId: 'batch-1',
      );
      await database.attendanceDao.upsertAttendance(
        LocalAttendancesCompanion.insert(
          cloudId: Value(key),
          attendanceKey: key,
          studentId: 'student-local-timestamp',
          studentName: 'Timestamp Student',
          dateKey: '2026-07-04',
          attendanceDate: DateTime(2026, 7, 4),
          batchId: const Value('batch-1'),
          status: 'present',
          updatedAt: Value(DateTime(2026, 7, 4, 10)),
          syncStatus: LocalSyncStatus.synced,
        ),
      );

      final syncEngine = SyncEngine(database);
      await syncEngine.applyRemoteAttendance([
        LocalAttendancesCompanion.insert(
          cloudId: Value(key),
          attendanceKey: key,
          studentId: 'student-local-timestamp',
          studentName: 'Timestamp Student',
          dateKey: '2026-07-04',
          attendanceDate: DateTime(2026, 7, 4),
          batchId: const Value('batch-1'),
          status: 'absent',
          syncStatus: LocalSyncStatus.synced,
        ),
      ]);
      await syncEngine.dispose();

      expect(
        (await database.attendanceDao.getAttendanceByKey(key))!.status,
        'present',
      );
    },
  );

  test('attendance local data persists after database reopen', () async {
    final tempDir = await Directory.systemTemp.createTemp('attendance_db_');
    final file = File('${tempDir.path}/offline.sqlite');
    final db1 = AppDatabase(NativeDatabase(file));
    final key = AttendanceKeys.create(
      dateKey: '2026-07-04',
      studentId: 'student-restart',
    );
    await db1.attendanceDao.upsertAttendance(
      LocalAttendancesCompanion.insert(
        cloudId: Value(key),
        attendanceKey: key,
        studentId: 'student-restart',
        studentName: 'Restart Student',
        dateKey: '2026-07-04',
        attendanceDate: DateTime(2026, 7, 4),
        status: 'leave',
        syncStatus: LocalSyncStatus.pendingUpdate,
      ),
    );
    await db1.close();

    final db2 = AppDatabase(NativeDatabase(file));
    expect((await db2.attendanceDao.getAttendanceByKey(key))!.status, 'leave');
    await db2.close();
    await tempDir.delete(recursive: true);
  });
}
