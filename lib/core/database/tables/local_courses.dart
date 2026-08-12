part of '../app_database.dart';

class LocalCourses extends Table {
  IntColumn get localId => integer().autoIncrement()();
  TextColumn get cloudId => text().nullable().unique()();
  TextColumn get legacyId => text().nullable()();
  TextColumn get code => text().nullable()();
  TextColumn get name => text()();
  TextColumn get category => text().nullable()();
  TextColumn get description => text().nullable()();
  RealColumn get feesAmount => real().nullable()();
  TextColumn get feesFrequency => text().nullable()();
  RealColumn get monthlyFees => real().nullable()();
  RealColumn get yearlyFees => real().nullable()();
  IntColumn get durationMonths => integer().nullable()();
  TextColumn get subjects => text().nullable()();
  IntColumn get maxStudents => integer().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get syncStatus => textEnum<LocalSyncStatus>()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
}
