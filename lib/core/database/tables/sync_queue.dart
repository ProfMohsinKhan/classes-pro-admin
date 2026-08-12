part of '../app_database.dart';

class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get operationId => text().unique()();
  TextColumn get entityType => textEnum<SyncEntityType>()();
  TextColumn get entityId => text()();
  TextColumn get operationType => textEnum<SyncOperationType>()();
  TextColumn get payloadJson => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextRetryAt => dateTime().nullable()();
  TextColumn get status => textEnum<SyncOperationStatus>()();
  TextColumn get lastError => text().nullable()();
}
