part of '../app_database.dart';

@DataClassName('LocalBatch')
class LocalBatches extends Table {
  IntColumn get localId => integer().autoIncrement()();
  TextColumn get cloudId => text().nullable().unique()();
  TextColumn get legacyId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get courseId => text().nullable()();
  TextColumn get courseName => text().nullable()();
  TextColumn get daysJson => text().nullable()();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  TextColumn get startTime => text().nullable()();
  TextColumn get endTime => text().nullable()();
  IntColumn get maxStudents => integer().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get syncStatus => textEnum<LocalSyncStatus>()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
}
