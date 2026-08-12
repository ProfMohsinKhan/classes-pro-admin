import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../../core/database/sync_types.dart';
import '../../models/course_model.dart';
import 'firestore_mapper_helpers.dart';

class CourseMapper {
  const CourseMapper._();

  static LocalCoursesCompanion fromFirestoreDoc(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    LocalSyncStatus syncStatus = LocalSyncStatus.synced,
  }) {
    final data = doc.data() ?? {};
    return _fromMap(doc.id, data, syncStatus: syncStatus);
  }

  static LocalCoursesCompanion fromFirestoreMap(
    String cloudId,
    Map<String, dynamic> data, {
    LocalSyncStatus syncStatus = LocalSyncStatus.synced,
  }) {
    return _fromMap(cloudId, data, syncStatus: syncStatus);
  }

  static LocalCoursesCompanion fromModel(
    CourseModel course, {
    required LocalSyncStatus syncStatus,
  }) {
    return LocalCoursesCompanion(
      cloudId: Value(course.id),
      legacyId: Value(course.legacyId),
      code: Value(course.code),
      name: Value(course.name),
      category: Value(course.category),
      description: Value(course.description),
      feesAmount: Value(course.feesAmount),
      feesFrequency: Value(course.feesFrequency),
      monthlyFees: Value(course.monthlyFees),
      yearlyFees: Value(course.yearlyFees),
      durationMonths: Value(course.durationMonths),
      subjects: Value(course.subjects),
      maxStudents: Value(course.maxStudents),
      isActive: Value(course.isActive),
      createdAt: Value(course.createdAt),
      updatedAt: Value(course.updatedAt),
      deletedAt: Value(course.deletedAt),
      syncStatus: Value(syncStatus),
      lastSyncedAt: Value(course.lastSyncedAt),
    );
  }

  static Map<String, dynamic> toFirestorePayload(LocalCourse course) {
    return {
      if (course.legacyId != null) 'id': _legacyIdValue(course.legacyId!),
      'code': course.code,
      'name': course.name,
      'category': course.category,
      'description': course.description,
      'fees_amount': course.feesAmount,
      'fees_frequency': course.feesFrequency,
      'monthly_fees': course.monthlyFees,
      'yearly_fees': course.yearlyFees,
      'duration_months': course.durationMonths,
      'subjects': course.subjects,
      'max_students': course.maxStudents,
      'is_active': course.isActive,
      'created_at': course.createdAt?.toIso8601String(),
      'updated_at': course.updatedAt?.toIso8601String(),
      'deleted_at': course.deletedAt?.toIso8601String(),
    };
  }

  static LocalCoursesCompanion _fromMap(
    String cloudId,
    Map<String, dynamic> data, {
    required LocalSyncStatus syncStatus,
  }) {
    return LocalCoursesCompanion(
      cloudId: Value(cloudId),
      legacyId: Value(FirestoreMapperHelpers.stringValue(data['id'])),
      code: Value(FirestoreMapperHelpers.stringValue(data['code'])),
      name: Value(FirestoreMapperHelpers.stringValue(data['name']) ?? ''),
      category: Value(FirestoreMapperHelpers.stringValue(data['category'])),
      description: Value(
        FirestoreMapperHelpers.stringValue(data['description']),
      ),
      feesAmount: Value(
        FirestoreMapperHelpers.doubleValue(
          data['fees_amount'] ?? data['feesAmount'],
        ),
      ),
      feesFrequency: Value(
        FirestoreMapperHelpers.stringValue(
          data['fees_frequency'] ?? data['feesFrequency'],
        ),
      ),
      monthlyFees: Value(
        FirestoreMapperHelpers.doubleValue(
          data['monthly_fees'] ?? data['monthlyFees'],
        ),
      ),
      yearlyFees: Value(
        FirestoreMapperHelpers.doubleValue(
          data['yearly_fees'] ?? data['yearlyFees'],
        ),
      ),
      durationMonths: Value(
        FirestoreMapperHelpers.intValue(
          data['duration_months'] ?? data['durationMonths'],
        ),
      ),
      subjects: Value(FirestoreMapperHelpers.stringValue(data['subjects'])),
      maxStudents: Value(
        FirestoreMapperHelpers.intValue(
          data['max_students'] ?? data['maxStudents'],
        ),
      ),
      isActive: Value(
        FirestoreMapperHelpers.boolValue(data['is_active'] ?? data['isActive']),
      ),
      createdAt: Value(
        FirestoreMapperHelpers.dateValue(
          data['created_at'] ?? data['createdAt'],
        ),
      ),
      updatedAt: Value(
        FirestoreMapperHelpers.dateValue(
          data['updated_at'] ?? data['updatedAt'],
        ),
      ),
      deletedAt: Value(
        FirestoreMapperHelpers.dateValue(
          data['deleted_at'] ?? data['deletedAt'],
        ),
      ),
      syncStatus: Value(syncStatus),
      lastSyncedAt: Value(
        syncStatus == LocalSyncStatus.synced ? DateTime.now() : null,
      ),
    );
  }

  static Object _legacyIdValue(String value) {
    return int.tryParse(value) ?? value;
  }
}
