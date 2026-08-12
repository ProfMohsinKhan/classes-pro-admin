part of '../app_database.dart';

class SyncMetadata extends Table {
  TextColumn get entityType => textEnum<SyncEntityType>()();
  DateTimeColumn get lastPullAt => dateTime().nullable()();
  DateTimeColumn get lastSuccessfulSyncAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {entityType};
}
