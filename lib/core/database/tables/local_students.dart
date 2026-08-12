part of '../app_database.dart';

class LocalStudents extends Table {
  IntColumn get localId => integer().autoIncrement()();
  TextColumn get cloudId => text().nullable().unique()();
  TextColumn get studentIdLegacy => text().nullable()();
  TextColumn get name => text()();
  TextColumn get normalizedName => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get parentName => text().nullable()();
  TextColumn get parentPhone => text().nullable()();
  TextColumn get email => text().nullable()();
  DateTimeColumn get dob => dateTime().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get className => text().nullable()();
  TextColumn get courseId => text().nullable()();
  TextColumn get courseName => text().nullable()();
  TextColumn get batchId => text().nullable()();
  TextColumn get batchName => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  TextColumn get notes => text().nullable()();
  TextColumn get photoUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get syncStatus => textEnum<LocalSyncStatus>()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
}
