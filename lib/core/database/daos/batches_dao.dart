part of '../app_database.dart';

@DriftAccessor(tables: [LocalBatches])
class BatchesDao extends DatabaseAccessor<AppDatabase> with _$BatchesDaoMixin {
  BatchesDao(super.db);

  Stream<List<LocalBatch>> watchBatches() {
    return (select(
      localBatches,
    )..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();
  }

  Stream<List<LocalBatch>> watchActiveBatches() {
    return (select(localBatches)
          ..where((t) => t.deletedAt.isNull() & t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  Future<LocalBatch?> getBatchByCloudId(String cloudId) {
    return (select(
      localBatches,
    )..where((t) => t.cloudId.equals(cloudId))).getSingleOrNull();
  }

  Future<int> countBatches() async {
    final count = localBatches.localId.count();
    final row = await (selectOnly(
      localBatches,
    )..addColumns([count])).getSingle();
    return row.read(count) ?? 0;
  }

  Future<void> upsertBatch(LocalBatchesCompanion batchRow) async {
    final cloudId = batchRow.cloudId.value;
    if (cloudId != null) {
      final updated = await (update(
        localBatches,
      )..where((t) => t.cloudId.equals(cloudId))).write(batchRow);
      if (updated > 0) return;
    }
    await into(localBatches).insert(batchRow);
  }

  Future<void> upsertBatches(Iterable<LocalBatchesCompanion> batches) async {
    for (final batchRow in batches) {
      await upsertBatch(batchRow);
    }
  }

  Future<List<LocalBatch>> getPendingBatches() {
    return (select(
          localBatches,
        )..where((t) => t.syncStatus.equalsValue(LocalSyncStatus.synced).not()))
        .get();
  }

  Future<void> archiveBatch(String cloudId) {
    return (update(
      localBatches,
    )..where((t) => t.cloudId.equals(cloudId))).write(
      LocalBatchesCompanion(
        isActive: const Value(false),
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value(LocalSyncStatus.pendingDelete),
      ),
    );
  }

  Future<void> restoreBatch(String cloudId) {
    return (update(
      localBatches,
    )..where((t) => t.cloudId.equals(cloudId))).write(
      LocalBatchesCompanion(
        isActive: const Value(true),
        deletedAt: const Value(null),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value(LocalSyncStatus.pendingUpdate),
      ),
    );
  }

  Future<void> markBatchSynced(String cloudId) {
    return (update(
      localBatches,
    )..where((t) => t.cloudId.equals(cloudId))).write(
      LocalBatchesCompanion(
        syncStatus: const Value(LocalSyncStatus.synced),
        lastSyncedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> markBatchFailed(String cloudId) {
    return (update(
      localBatches,
    )..where((t) => t.cloudId.equals(cloudId))).write(
      const LocalBatchesCompanion(syncStatus: Value(LocalSyncStatus.failed)),
    );
  }

  Future<void> upsertRemoteBatchPreservingPending(
    LocalBatchesCompanion batchRow,
  ) async {
    final cloudId = batchRow.cloudId.value;
    if (cloudId != null) {
      final existing = await getBatchByCloudId(cloudId);
      if (existing != null && existing.syncStatus != LocalSyncStatus.synced) {
        return;
      }
    }
    await upsertBatch(batchRow);
  }
}
