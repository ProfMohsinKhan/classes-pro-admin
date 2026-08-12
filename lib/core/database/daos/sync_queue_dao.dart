part of '../app_database.dart';

@DriftAccessor(tables: [SyncQueue])
class SyncQueueDao extends DatabaseAccessor<AppDatabase>
    with _$SyncQueueDaoMixin {
  SyncQueueDao(super.db);

  Future<void> enqueue({
    required SyncEntityType entityType,
    required String entityId,
    required SyncOperationType operationType,
    String? payloadJson,
  }) async {
    final now = DateTime.now();
    final operationId = '${enumName(entityType)}:$entityId';
    await transaction(() async {
      final existing =
          await (select(syncQueue)
                ..where((t) => t.operationId.equals(operationId))
                ..limit(1))
              .getSingleOrNull();

      final effectiveOperation =
          existing?.operationType == SyncOperationType.create &&
              operationType == SyncOperationType.update
          ? SyncOperationType.create
          : operationType;

      final companion = SyncQueueCompanion(
        operationId: Value(operationId),
        entityType: Value(entityType),
        entityId: Value(entityId),
        operationType: Value(effectiveOperation),
        payloadJson: Value(payloadJson),
        createdAt: Value(existing?.createdAt ?? now),
        updatedAt: Value(now),
        retryCount: Value(existing?.retryCount ?? 0),
        nextRetryAt: const Value(null),
        status: const Value(SyncOperationStatus.pending),
        lastError: const Value(null),
      );
      if (existing == null) {
        await into(syncQueue).insert(companion);
      } else {
        await (update(
          syncQueue,
        )..where((t) => t.operationId.equals(operationId))).write(companion);
      }
    });
  }

  Future<List<SyncQueueData>> getPendingOperations({int limit = 100}) {
    final now = DateTime.now();
    return (select(syncQueue)
          ..where(
            (t) =>
                (t.status.equalsValue(SyncOperationStatus.pending) |
                    t.status.equalsValue(SyncOperationStatus.failed)) &
                (t.nextRetryAt.isNull() |
                    t.nextRetryAt.isSmallerOrEqualValue(now)),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
          ..limit(limit))
        .get();
  }

  Future<void> markSyncing(int id) {
    return (update(syncQueue)..where((t) => t.id.equals(id))).write(
      SyncQueueCompanion(
        status: const Value(SyncOperationStatus.syncing),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> markFailed(int id, Object error) {
    final now = DateTime.now();
    return (update(syncQueue)..where((t) => t.id.equals(id))).write(
      SyncQueueCompanion(
        status: const Value(SyncOperationStatus.failed),
        updatedAt: Value(now),
        lastError: Value(error.toString()),
      ),
    );
  }

  Future<void> markCompleted(int id) {
    return (delete(syncQueue)..where((t) => t.id.equals(id))).go();
  }

  Future<void> incrementRetry(int id, int retryCount) {
    final now = DateTime.now();
    final delay = Duration(minutes: 1 << retryCount.clamp(0, 6));
    return (update(syncQueue)..where((t) => t.id.equals(id))).write(
      SyncQueueCompanion(
        retryCount: Value(retryCount + 1),
        nextRetryAt: Value(now.add(delay)),
        updatedAt: Value(now),
      ),
    );
  }
}
