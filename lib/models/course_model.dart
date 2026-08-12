import '../core/database/app_database.dart';
import '../core/database/sync_types.dart';

class CourseModel {
  const CourseModel({
    required this.id,
    required this.name,
    this.legacyId,
    this.code,
    this.category,
    this.description,
    this.feesAmount,
    this.feesFrequency,
    this.monthlyFees,
    this.yearlyFees,
    this.durationMonths,
    this.subjects,
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
  final String? code;
  final String name;
  final String? category;
  final String? description;
  final double? feesAmount;
  final String? feesFrequency;
  final double? monthlyFees;
  final double? yearlyFees;
  final int? durationMonths;
  final String? subjects;
  final int? maxStudents;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final LocalSyncStatus syncStatus;
  final DateTime? lastSyncedAt;

  bool get hasPendingSync => syncStatus != LocalSyncStatus.synced;

  CourseModel copyWith({
    String? id,
    String? legacyId,
    String? code,
    String? name,
    String? category,
    String? description,
    double? feesAmount,
    String? feesFrequency,
    double? monthlyFees,
    double? yearlyFees,
    int? durationMonths,
    String? subjects,
    int? maxStudents,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    LocalSyncStatus? syncStatus,
    DateTime? lastSyncedAt,
  }) {
    return CourseModel(
      id: id ?? this.id,
      legacyId: legacyId ?? this.legacyId,
      code: code ?? this.code,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      feesAmount: feesAmount ?? this.feesAmount,
      feesFrequency: feesFrequency ?? this.feesFrequency,
      monthlyFees: monthlyFees ?? this.monthlyFees,
      yearlyFees: yearlyFees ?? this.yearlyFees,
      durationMonths: durationMonths ?? this.durationMonths,
      subjects: subjects ?? this.subjects,
      maxStudents: maxStudents ?? this.maxStudents,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  factory CourseModel.fromLocal(LocalCourse row) {
    return CourseModel(
      id: row.cloudId ?? row.localId.toString(),
      legacyId: row.legacyId,
      code: row.code,
      name: row.name,
      category: row.category,
      description: row.description,
      feesAmount: row.feesAmount,
      feesFrequency: row.feesFrequency,
      monthlyFees: row.monthlyFees,
      yearlyFees: row.yearlyFees,
      durationMonths: row.durationMonths,
      subjects: row.subjects,
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
      'code': code,
      'category': category,
      'description': description,
      'fees_amount': feesAmount,
      'fees_frequency': feesFrequency,
      'monthly_fees': monthlyFees,
      'yearly_fees': yearlyFees,
      'duration_months': durationMonths,
      'subjects': subjects,
      'max_students': maxStudents,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }
}
