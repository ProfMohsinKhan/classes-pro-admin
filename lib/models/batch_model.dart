import '../core/database/app_database.dart';
import '../core/database/sync_types.dart';
import '../data/mappers/batch_mapper.dart';

class BatchModel {
  const BatchModel({
    required this.id,
    required this.name,
    this.legacyId,
    this.courseId,
    this.courseName,
    this.days = const [],
    this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
    this.maxStudents,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.syncStatus = LocalSyncStatus.synced,
    this.lastSyncedAt,
  });

  final String id;
  final String? legacyId;
  final String name;
  final String? courseId;
  final String? courseName;
  final List<String> days;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? startTime;
  final String? endTime;
  final int? maxStudents;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final LocalSyncStatus syncStatus;
  final DateTime? lastSyncedAt;

  bool get hasPendingSync => syncStatus != LocalSyncStatus.synced;

  factory BatchModel.fromLocal(LocalBatch row) {
    return BatchModel(
      id: row.cloudId ?? row.localId.toString(),
      legacyId: row.legacyId,
      name: row.name,
      courseId: row.courseId,
      courseName: row.courseName,
      days: BatchMapper.daysFromLocal(row),
      startDate: row.startDate,
      endDate: row.endDate,
      startTime: row.startTime,
      endTime: row.endTime,
      maxStudents: row.maxStudents,
      isActive: row.isActive,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
      syncStatus: row.syncStatus,
      lastSyncedAt: row.lastSyncedAt,
    );
  }

  Map<String, dynamic> toCardMap() {
    return {
      'id': legacyId,
      'cloud_id': id,
      'name': name,
      'course_id': courseId,
      'course_name': courseName,
      'days': days,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'start_time': startTime,
      'end_time': endTime,
      'max_students': maxStudents,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }
}
