import '../../core/database/app_database.dart';

class StudentsLocalDataSource {
  StudentsLocalDataSource(this.database);
  final AppDatabase database;

  Stream<List<LocalStudent>> watchAllActiveStudents() =>
      database.studentsDao.watchAllActiveStudents();
  Stream<List<LocalStudent>> watchStudentsByBatch(String batchId) =>
      database.studentsDao.watchStudentsByBatch(batchId);
  Future<void> upsert(LocalStudentsCompanion student) =>
      database.studentsDao.upsertStudent(student);
}

class AttendanceLocalDataSource {
  AttendanceLocalDataSource(this.database);
  final AppDatabase database;

  Stream<List<LocalAttendance>> watchAttendanceForDate(
    String dateKey, {
    String? batchId,
  }) =>
      database.attendanceDao.watchAttendanceForDate(dateKey, batchId: batchId);
  Future<void> upsert(LocalAttendancesCompanion attendance) =>
      database.attendanceDao.upsertAttendance(attendance);
}

class CoursesLocalDataSource {
  CoursesLocalDataSource(this.database);
  final AppDatabase database;

  Stream<List<LocalCourse>> watchActiveCourses() =>
      database.coursesDao.watchActiveCourses();
  Future<void> upsert(LocalCoursesCompanion course) =>
      database.coursesDao.upsertCourse(course);
}

class BatchesLocalDataSource {
  BatchesLocalDataSource(this.database);
  final AppDatabase database;

  Stream<List<LocalBatch>> watchActiveBatches() =>
      database.batchesDao.watchActiveBatches();
  Future<void> upsert(LocalBatchesCompanion batch) =>
      database.batchesDao.upsertBatch(batch);
}

class EnquiriesLocalDataSource {
  EnquiriesLocalDataSource(this.database);
  final AppDatabase database;

  Stream<List<LocalEnquiry>> watchActiveEnquiries() =>
      database.enquiriesDao.watchActiveEnquiries();
  Future<void> upsert(LocalEnquiriesCompanion enquiry) =>
      database.enquiriesDao.upsertEnquiry(enquiry);
}
