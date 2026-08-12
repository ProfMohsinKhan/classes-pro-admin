part of '../app_database.dart';

class LocalEnquiries extends Table {
  IntColumn get localId => integer().autoIncrement()();
  TextColumn get cloudId => text().nullable().unique()();
  TextColumn get legacyId => text().nullable()();
  TextColumn get studentName => text()();
  TextColumn get parentName => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get alternatePhone => text().nullable()();
  TextColumn get email => text().nullable()();
  DateTimeColumn get dob => dateTime().nullable()();
  TextColumn get interestedCourseId => text().nullable()();
  TextColumn get interestedCourseName => text().nullable()();
  TextColumn get interestedBatchId => text().nullable()();
  TextColumn get interestedBatchName => text().nullable()();
  TextColumn get currentClass => text().nullable()();
  TextColumn get schoolName => text().nullable()();
  TextColumn get source => text().nullable()();
  TextColumn get enquiryStatus => text().withDefault(const Constant('new'))();
  DateTimeColumn get followUpDate => dateTime().nullable()();
  TextColumn get message => text().nullable()();
  TextColumn get followUpNotes => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get assignedTo => text().nullable()();
  TextColumn get assignedToName => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get syncStatus => textEnum<LocalSyncStatus>()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
}
