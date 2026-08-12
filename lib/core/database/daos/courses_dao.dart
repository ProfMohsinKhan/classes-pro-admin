part of '../app_database.dart';

@DriftAccessor(tables: [LocalCourses])
class CoursesDao extends DatabaseAccessor<AppDatabase> with _$CoursesDaoMixin {
  CoursesDao(super.db);

  Stream<List<LocalCourse>> watchCourses() {
    return (select(
      localCourses,
    )..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();
  }

  Stream<List<LocalCourse>> watchActiveCourses() {
    return (select(localCourses)
          ..where((t) => t.deletedAt.isNull() & t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  Future<LocalCourse?> getCourseByCloudId(String cloudId) {
    return (select(
      localCourses,
    )..where((t) => t.cloudId.equals(cloudId))).getSingleOrNull();
  }

  Future<int> countCourses() async {
    final count = localCourses.localId.count();
    final row = await (selectOnly(
      localCourses,
    )..addColumns([count])).getSingle();
    return row.read(count) ?? 0;
  }

  Future<void> upsertCourse(LocalCoursesCompanion course) async {
    final cloudId = course.cloudId.value;
    if (cloudId != null) {
      final updated = await (update(
        localCourses,
      )..where((t) => t.cloudId.equals(cloudId))).write(course);
      if (updated > 0) return;
    }
    await into(localCourses).insert(course);
  }

  Future<void> upsertCourses(Iterable<LocalCoursesCompanion> courses) async {
    for (final course in courses) {
      await upsertCourse(course);
    }
  }

  Future<List<LocalCourse>> getPendingCourses() {
    return (select(
          localCourses,
        )..where((t) => t.syncStatus.equalsValue(LocalSyncStatus.synced).not()))
        .get();
  }

  Future<void> archiveCourse(String cloudId) {
    return (update(
      localCourses,
    )..where((t) => t.cloudId.equals(cloudId))).write(
      LocalCoursesCompanion(
        isActive: const Value(false),
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value(LocalSyncStatus.pendingDelete),
      ),
    );
  }

  Future<void> restoreCourse(String cloudId) {
    return (update(
      localCourses,
    )..where((t) => t.cloudId.equals(cloudId))).write(
      LocalCoursesCompanion(
        isActive: const Value(true),
        deletedAt: const Value(null),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value(LocalSyncStatus.pendingUpdate),
      ),
    );
  }

  Future<void> markCourseSynced(String cloudId) {
    return (update(
      localCourses,
    )..where((t) => t.cloudId.equals(cloudId))).write(
      LocalCoursesCompanion(
        syncStatus: const Value(LocalSyncStatus.synced),
        lastSyncedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> markCourseFailed(String cloudId) {
    return (update(
      localCourses,
    )..where((t) => t.cloudId.equals(cloudId))).write(
      const LocalCoursesCompanion(syncStatus: Value(LocalSyncStatus.failed)),
    );
  }

  Future<void> upsertRemoteCoursePreservingPending(
    LocalCoursesCompanion course,
  ) async {
    final cloudId = course.cloudId.value;
    if (cloudId != null) {
      final existing = await getCourseByCloudId(cloudId);
      if (existing != null && existing.syncStatus != LocalSyncStatus.synced) {
        return;
      }
    }
    await upsertCourse(course);
  }
}
