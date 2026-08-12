import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';

import '../../models/attendance_model.dart';
import 'sync_types.dart';

part 'app_database.g.dart';
part 'tables/local_students.dart';
part 'tables/local_courses.dart';
part 'tables/local_batches.dart';
part 'tables/local_enquiries.dart';
part 'tables/local_attendances.dart';
part 'tables/sync_queue.dart';
part 'tables/sync_metadata.dart';
part 'daos/students_dao.dart';
part 'daos/courses_dao.dart';
part 'daos/batches_dao.dart';
part 'daos/enquiries_dao.dart';
part 'daos/attendance_dao.dart';
part 'daos/sync_queue_dao.dart';

@DriftDatabase(
  tables: [
    LocalStudents,
    LocalCourses,
    LocalBatches,
    LocalEnquiries,
    LocalAttendances,
    SyncQueue,
    SyncMetadata,
  ],
  daos: [
    StudentsDao,
    CoursesDao,
    BatchesDao,
    EnquiriesDao,
    AttendanceDao,
    SyncQueueDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.defaults()
    : super(
        driftDatabase(
          name: 'classes_pro_admin_offline',
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.js'),
          ),
        ),
      );

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createIndexes();
      debugPrint('OfflineDB: opened');
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(localEnquiries, localEnquiries.legacyId);
        await m.addColumn(localEnquiries, localEnquiries.dob);
        await m.addColumn(localEnquiries, localEnquiries.message);
        await m.addColumn(localEnquiries, localEnquiries.followUpNotes);
        await m.addColumn(localEnquiries, localEnquiries.assignedToName);
      }
      await _createIndexes();
    },
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
      debugPrint('OfflineDB: opened');
    },
  );

  Future<void> _createIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_local_students_normalized_name '
      'ON local_students(normalized_name)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_local_students_phone '
      'ON local_students(phone)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_local_students_parent_phone '
      'ON local_students(parent_phone)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_local_students_course_id '
      'ON local_students(course_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_local_students_batch_id '
      'ON local_students(batch_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_local_students_status '
      'ON local_students(status)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_local_students_deleted_at '
      'ON local_students(deleted_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_local_attendance_date_batch '
      'ON local_attendances(date_key, batch_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_local_enquiries_deleted_at '
      'ON local_enquiries(deleted_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_local_enquiries_status '
      'ON local_enquiries(enquiry_status)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_local_enquiries_follow_up '
      'ON local_enquiries(follow_up_date)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_local_enquiries_course_batch '
      'ON local_enquiries(interested_course_id, interested_batch_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sync_queue_pending '
      'ON sync_queue(status, next_retry_at, created_at)',
    );
  }
}
