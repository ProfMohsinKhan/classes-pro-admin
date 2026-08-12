part of '../app_database.dart';

class LocalAttendances extends Table {
  IntColumn get localId => integer().autoIncrement()();
  TextColumn get cloudId => text().nullable().unique()();
  TextColumn get attendanceKey => text().unique()();
  TextColumn get studentId => text()();
  TextColumn get studentName => text()();
  TextColumn get dateKey => text()();
  DateTimeColumn get attendanceDate => dateTime()();
  TextColumn get batchId => text().nullable()();
  TextColumn get batchName => text().nullable()();
  TextColumn get courseId => text().nullable()();
  TextColumn get courseName => text().nullable()();
  TextColumn get status => text()();
  TextColumn get markedBy => text().nullable()();
  TextColumn get markedByName => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get syncStatus => textEnum<LocalSyncStatus>()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
}
