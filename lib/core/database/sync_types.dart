enum LocalSyncStatus {
  synced,
  pendingCreate,
  pendingUpdate,
  pendingDelete,
  syncing,
  failed,
}

enum SyncEntityType { student, attendance, enquiry, course, batch }

enum SyncOperationType { create, update, delete, upsert }

enum SyncOperationStatus { pending, syncing, failed }

String enumName(Object value) => value.toString().split('.').last;
