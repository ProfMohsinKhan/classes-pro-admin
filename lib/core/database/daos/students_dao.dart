part of '../app_database.dart';

@DriftAccessor(tables: [LocalStudents])
class StudentsDao extends DatabaseAccessor<AppDatabase>
    with _$StudentsDaoMixin {
  StudentsDao(super.db);

  Stream<List<LocalStudent>> watchStudents() {
    return (select(localStudents)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.normalizedName)]))
        .watch();
  }

  Stream<List<LocalStudent>> watchAllActiveStudents() {
    return (select(localStudents)
          ..where(
            (t) => t.deletedAt.isNull() & t.status.lower().equals('active'),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.normalizedName)]))
        .watch();
  }

  Stream<List<LocalStudent>> watchStudentsByCourse(String courseId) {
    return (select(localStudents)
          ..where(
            (t) =>
                t.deletedAt.isNull() &
                t.status.lower().equals('active') &
                t.courseId.equals(courseId),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.normalizedName)]))
        .watch();
  }

  Stream<List<LocalStudent>> watchStudentsByBatch(String batchId) {
    return (select(localStudents)
          ..where(
            (t) =>
                t.deletedAt.isNull() &
                t.status.lower().equals('active') &
                t.batchId.equals(batchId),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.normalizedName)]))
        .watch();
  }

  Stream<LocalStudent?> watchStudentByCloudId(String cloudId) {
    return (select(
      localStudents,
    )..where((t) => t.cloudId.equals(cloudId))).watchSingleOrNull();
  }

  Future<LocalStudent?> getStudentByCloudId(String cloudId) {
    return (select(
      localStudents,
    )..where((t) => t.cloudId.equals(cloudId))).getSingleOrNull();
  }

  Future<int> countStudents() async {
    final count = localStudents.localId.count();
    final row = await (selectOnly(
      localStudents,
    )..addColumns([count])).getSingle();
    return row.read(count) ?? 0;
  }

  Stream<List<LocalStudent>> searchStudents(String query) {
    final normalized = query.trim().toLowerCase();
    return (select(localStudents)
          ..where(
            (t) =>
                t.deletedAt.isNull() &
                (t.normalizedName.contains(normalized) |
                    t.phone.contains(query) |
                    t.parentPhone.contains(query) |
                    t.parentName.lower().contains(normalized) |
                    t.courseName.lower().contains(normalized) |
                    t.batchName.lower().contains(normalized)),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.normalizedName)]))
        .watch();
  }

  Future<void> upsertStudent(LocalStudentsCompanion student) async {
    final cloudId = student.cloudId.value;
    if (cloudId != null) {
      final updated = await (update(
        localStudents,
      )..where((t) => t.cloudId.equals(cloudId))).write(student);
      if (updated > 0) return;
    }
    await into(localStudents).insert(student);
  }

  Future<void> upsertStudents(Iterable<LocalStudentsCompanion> students) async {
    for (final student in students) {
      await upsertStudent(student);
    }
  }

  Future<void> softDeleteStudent(String cloudId) {
    return (update(
      localStudents,
    )..where((t) => t.cloudId.equals(cloudId))).write(
      LocalStudentsCompanion(
        deletedAt: Value(DateTime.now()),
        status: const Value('inactive'),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value(LocalSyncStatus.pendingDelete),
      ),
    );
  }

  Future<void> restoreStudent(String cloudId) {
    return (update(
      localStudents,
    )..where((t) => t.cloudId.equals(cloudId))).write(
      LocalStudentsCompanion(
        deletedAt: const Value(null),
        status: const Value('active'),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value(LocalSyncStatus.pendingUpdate),
      ),
    );
  }

  Future<List<LocalStudent>> getPendingStudents() {
    return (select(
          localStudents,
        )..where((t) => t.syncStatus.equalsValue(LocalSyncStatus.synced).not()))
        .get();
  }

  Future<void> markStudentSynced(String cloudId) {
    return (update(
      localStudents,
    )..where((t) => t.cloudId.equals(cloudId))).write(
      LocalStudentsCompanion(
        syncStatus: const Value(LocalSyncStatus.synced),
        lastSyncedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> markStudentFailed(String cloudId) {
    return (update(
      localStudents,
    )..where((t) => t.cloudId.equals(cloudId))).write(
      const LocalStudentsCompanion(syncStatus: Value(LocalSyncStatus.failed)),
    );
  }

  Future<void> upsertRemoteStudentPreservingPending(
    LocalStudentsCompanion student,
  ) async {
    final cloudId = student.cloudId.value;
    if (cloudId != null) {
      final existing = await getStudentByCloudId(cloudId);
      if (existing != null && existing.syncStatus != LocalSyncStatus.synced) {
        return;
      }
    }
    await upsertStudent(student);
  }
}
