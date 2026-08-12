part of '../app_database.dart';

@DriftAccessor(tables: [LocalAttendances])
class AttendanceDao extends DatabaseAccessor<AppDatabase>
    with _$AttendanceDaoMixin {
  AttendanceDao(super.db);

  Stream<List<LocalAttendance>> watchAllAttendance() {
    return (select(localAttendances)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.attendanceDate)]))
        .watch();
  }

  Stream<List<LocalAttendance>> watchAttendanceForDate(
    String dateKey, {
    String? batchId,
  }) {
    return (select(localAttendances)
          ..where(
            (t) =>
                t.deletedAt.isNull() &
                t.dateKey.equals(dateKey) &
                (batchId == null
                    ? const Constant(true)
                    : t.batchId.equals(batchId)),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.studentName)]))
        .watch();
  }

  Stream<List<LocalAttendance>> watchAttendanceForStudent(String studentId) {
    return (select(localAttendances)
          ..where((t) => t.deletedAt.isNull() & t.studentId.equals(studentId))
          ..orderBy([(t) => OrderingTerm.desc(t.attendanceDate)]))
        .watch();
  }

  Future<List<LocalAttendance>> getAttendanceForStudent(String studentId) {
    return (select(localAttendances)
          ..where((t) => t.deletedAt.isNull() & t.studentId.equals(studentId))
          ..orderBy([(t) => OrderingTerm.desc(t.attendanceDate)]))
        .get();
  }

  Future<List<LocalAttendance>> getAttendanceForDateRows(
    String dateKey, {
    String? batchId,
  }) {
    return (select(localAttendances)
          ..where(
            (t) =>
                t.deletedAt.isNull() &
                t.dateKey.equals(dateKey) &
                (batchId == null
                    ? const Constant(true)
                    : t.batchId.equals(batchId)),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.studentName)]))
        .get();
  }

  Future<List<LocalAttendance>> getAttendanceForDateRange({
    required String startDateKey,
    required String endDateKey,
  }) {
    return (select(localAttendances)
          ..where(
            (t) =>
                t.deletedAt.isNull() &
                t.dateKey.isBiggerOrEqualValue(startDateKey) &
                t.dateKey.isSmallerOrEqualValue(endDateKey),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.dateKey)]))
        .get();
  }

  Future<LocalAttendance?> getAttendanceForDate({
    required String dateKey,
    required String studentId,
    String? batchId,
  }) {
    final key = attendanceKey(
      dateKey: dateKey,
      studentId: studentId,
      batchId: batchId,
    );
    return (select(
      localAttendances,
    )..where((t) => t.attendanceKey.equals(key))).getSingleOrNull();
  }

  Future<void> upsertAttendance(LocalAttendancesCompanion attendance) async {
    final attendanceKey = attendance.attendanceKey.value;
    final updated = await (update(
      localAttendances,
    )..where((t) => t.attendanceKey.equals(attendanceKey))).write(attendance);
    if (updated > 0) return;
    await into(localAttendances).insert(attendance);
  }

  Future<void> upsertAttendanceBatch(
    Iterable<LocalAttendancesCompanion> records,
  ) async {
    for (final record in records) {
      await upsertAttendance(record);
    }
  }

  Future<void> upsertRemoteAttendancePreservingPending(
    LocalAttendancesCompanion attendance,
  ) async {
    final attendanceKey = attendance.attendanceKey.value;
    final existing = await getAttendanceByKey(attendanceKey);
    if (existing != null && existing.syncStatus != LocalSyncStatus.synced) {
      return;
    }
    final remoteUpdatedAt = attendance.updatedAt.present
        ? attendance.updatedAt.value
        : null;
    if (existing != null &&
        existing.updatedAt != null &&
        remoteUpdatedAt == null) {
      return;
    }
    if (existing != null &&
        existing.updatedAt != null &&
        remoteUpdatedAt != null &&
        existing.updatedAt!.isAfter(remoteUpdatedAt)) {
      return;
    }
    await upsertAttendance(attendance);
  }

  Future<List<LocalAttendance>> getPendingAttendance() {
    return (select(
          localAttendances,
        )..where((t) => t.syncStatus.equalsValue(LocalSyncStatus.synced).not()))
        .get();
  }

  Future<LocalAttendance?> getAttendanceByKey(String attendanceKey) {
    return (select(localAttendances)
          ..where((t) => t.attendanceKey.equals(attendanceKey))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<void> markAttendanceSynced(String attendanceKey) {
    final now = DateTime.now();
    return (update(
      localAttendances,
    )..where((t) => t.attendanceKey.equals(attendanceKey))).write(
      LocalAttendancesCompanion(
        syncStatus: const Value(LocalSyncStatus.synced),
        lastSyncedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> markAttendanceFailed(String attendanceKey) {
    return (update(
      localAttendances,
    )..where((t) => t.attendanceKey.equals(attendanceKey))).write(
      LocalAttendancesCompanion(
        syncStatus: const Value(LocalSyncStatus.failed),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<Map<String, int>> countByStatus(
    String dateKey, {
    String? batchId,
  }) async {
    final rows = await customSelect(
      '''
      SELECT status, COUNT(*) AS total
      FROM local_attendances
      WHERE deleted_at IS NULL
        AND date_key = ?
        AND (? = '' OR batch_id = ?)
      GROUP BY status
      ''',
      variables: [
        Variable.withString(dateKey),
        Variable.withString(batchId ?? ''),
        Variable.withString(batchId ?? ''),
      ],
      readsFrom: {localAttendances},
    ).get();
    return {
      for (final row in rows)
        row.read<String>('status'): row.read<int>('total'),
    };
  }

  static String attendanceKey({
    required String dateKey,
    required String studentId,
    String? batchId,
  }) {
    return AttendanceKeys.create(
      dateKey: dateKey,
      studentId: studentId,
      batchId: batchId,
    );
  }
}
