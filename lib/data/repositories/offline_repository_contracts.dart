import '../../models/attendance_model.dart';
import '../../models/batch_model.dart';
import '../../models/course_model.dart';
import '../../models/enquiry_model.dart';
import '../../models/student_model.dart';

enum OfflineSyncSummary { synced, syncing, pending, failed }

class AttendanceDayData {
  const AttendanceDayData({required this.records});
  final List<AttendanceModel> records;
}

class AttendanceSaveResult {
  const AttendanceSaveResult({required this.changedCount});
  final int changedCount;
}

abstract class StudentsRepository {
  Stream<List<StudentModel>> watchStudents();
  Stream<List<StudentModel>> watchActiveStudents();
  Stream<List<StudentModel>> watchStudentsByBatch(String batchId);
  Stream<List<StudentModel>> watchStudentsByCourse(String courseId);
  Stream<StudentModel?> watchStudentById(String studentId);
  Stream<List<StudentModel>> searchStudents(String query);
  Stream<OfflineSyncSummary> watchSyncSummary();
  Future<StudentModel?> getStudentById(String studentId);
  Future<StudentModel> createStudent(StudentModel student);
  Future<void> updateStudent(StudentModel student);
  Future<void> archiveStudent(String cloudId);
  Future<void> restoreStudent(String cloudId);
  Future<void> requestSync();
}

abstract class AttendanceRepository {
  Stream<AttendanceDayData> watchAttendance(String dateKey, {String? batchId});
  Stream<List<AttendanceModel>> watchAttendanceForDate(String dateKey);
  Stream<List<AttendanceModel>> watchAttendanceForDateAndBatch(
    String dateKey,
    String batchId,
  );
  Stream<List<AttendanceModel>> watchAttendanceForStudent(String studentId);
  Stream<OfflineSyncSummary> watchSyncSummary();
  Future<List<AttendanceModel>> getAttendanceForDate(
    String dateKey, {
    String? batchId,
  });
  Future<AttendanceModel?> getAttendanceRecord(String attendanceKey);
  Future<AttendanceSaveResult> saveAttendanceDay(
    List<AttendanceModel> changedRecords,
  );
  Future<void> requestSync();
  Future<void> syncAttendanceForDate(DateTime date);
}

abstract class CoursesRepository {
  Stream<List<CourseModel>> watchCourses();
  Stream<List<CourseModel>> watchActiveCourses();
  Stream<OfflineSyncSummary> watchSyncSummary();
  Future<CourseModel?> getCourseById(String id);
  Future<void> createCourse(CourseModel course);
  Future<void> updateCourse(CourseModel course);
  Future<void> archiveCourse(String id);
  Future<void> restoreCourse(String id);
  Future<void> requestSync();
}

abstract class BatchesRepository {
  Stream<List<BatchModel>> watchBatches();
  Stream<List<BatchModel>> watchActiveBatches();
  Stream<OfflineSyncSummary> watchSyncSummary();
  Future<BatchModel?> getBatchById(String id);
  Future<void> createBatch(BatchModel batch);
  Future<void> updateBatch(BatchModel batch);
  Future<void> archiveBatch(String id);
  Future<void> restoreBatch(String id);
  Future<void> requestSync();
}

abstract class EnquiriesRepository {
  Stream<List<EnquiryModel>> watchEnquiries();
  Stream<List<EnquiryModel>> watchActiveEnquiries();
  Stream<List<EnquiryModel>> watchEnquiriesByStatus(String status);
  Stream<List<EnquiryModel>> watchUpcomingFollowUps(DateTime before);
  Stream<EnquiryModel?> watchEnquiryById(String enquiryId);
  Stream<List<EnquiryModel>> searchEnquiries(String query);
  Stream<OfflineSyncSummary> watchSyncSummary();
  Future<EnquiryModel?> getEnquiryById(String enquiryId);
  Future<void> createEnquiry(EnquiryModel enquiry);
  Future<void> updateEnquiry(EnquiryModel enquiry);
  Future<void> updateStatus(String enquiryId, String status);
  Future<void> updateFollowUp(
    String enquiryId,
    DateTime? followUpDate, {
    String? notes,
  });
  Future<void> archiveEnquiry(String enquiryId);
  Future<void> restoreEnquiry(String enquiryId);
  Future<void> requestSync();
}
