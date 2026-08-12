import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../../core/database/sync_types.dart';
import '../../models/enquiry_model.dart';
import 'firestore_mapper_helpers.dart';

class EnquiryMapper {
  const EnquiryMapper._();

  static LocalEnquiriesCompanion fromFirestoreDoc(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    LocalSyncStatus syncStatus = LocalSyncStatus.synced,
  }) => fromFirestoreMap(doc.id, doc.data() ?? {}, syncStatus: syncStatus);

  static LocalEnquiriesCompanion fromFirestoreMap(
    String cloudId,
    Map<String, dynamic> data, {
    LocalSyncStatus syncStatus = LocalSyncStatus.synced,
  }) {
    return LocalEnquiriesCompanion(
      cloudId: Value(cloudId),
      legacyId: Value(_string(data, const ['legacyId', 'legacy_id', 'id'])),
      studentName: Value(
        _string(data, const ['studentName', 'student_name', 'name']) ?? '',
      ),
      parentName: Value(
        _string(data, const ['parentName', 'parent_name', 'guardian_name']),
      ),
      phone: Value(
        _string(data, const [
          'phone',
          'mobile',
          'mobileNumber',
          'phone_number',
        ]),
      ),
      alternatePhone: Value(
        _string(data, const ['alternatePhone', 'alternate_phone']),
      ),
      email: Value(FirestoreMapperHelpers.stringValue(data['email'])),
      dob: Value(_date(data, const ['dob', 'dateOfBirth', 'date_of_birth'])),
      interestedCourseId: Value(
        _string(data, const [
          'interestedCourseId',
          'interested_course_id',
          'courseId',
          'course_id',
        ]),
      ),
      interestedCourseName: Value(
        _string(data, const [
          'interestedCourseName',
          'interested_course_name',
          'courseName',
          'course_name',
          'course_interested',
        ]),
      ),
      interestedBatchId: Value(
        _string(data, const [
          'interestedBatchId',
          'interested_batch_id',
          'batchId',
          'batch_id',
        ]),
      ),
      interestedBatchName: Value(
        _string(data, const [
          'interestedBatchName',
          'interested_batch_name',
          'batchName',
          'batch_name',
        ]),
      ),
      currentClass: Value(
        _string(data, const ['currentClass', 'current_class']),
      ),
      schoolName: Value(_string(data, const ['schoolName', 'school_name'])),
      source: Value(FirestoreMapperHelpers.stringValue(data['source'])),
      enquiryStatus: Value(
        normalizeStatus(
          _string(data, const ['enquiryStatus', 'enquiry_status', 'status']),
        ),
      ),
      followUpDate: Value(
        _date(data, const [
          'followUpDate',
          'follow_up_date',
          'nextFollowUpAt',
          'next_follow_up_at',
        ]),
      ),
      message: Value(_string(data, const ['message', 'studentMessage'])),
      followUpNotes: Value(
        _string(data, const ['followUpNotes', 'follow_up_notes']),
      ),
      notes: Value(_string(data, const ['notes', 'remark', 'remarks'])),
      assignedTo: Value(_string(data, const ['assignedTo', 'assigned_to'])),
      assignedToName: Value(
        _string(data, const ['assignedToName', 'assigned_to_name']),
      ),
      createdAt: Value(_date(data, const ['createdAt', 'created_at'])),
      updatedAt: Value(_date(data, const ['updatedAt', 'updated_at'])),
      deletedAt: Value(_date(data, const ['deletedAt', 'deleted_at'])),
      syncStatus: Value(syncStatus),
      lastSyncedAt: Value(
        syncStatus == LocalSyncStatus.synced ? DateTime.now() : null,
      ),
    );
  }

  static EnquiryModel toDomain(LocalEnquiry row) => EnquiryModel.fromLocal(row);

  static LocalEnquiriesCompanion fromDomain(
    EnquiryModel enquiry, {
    LocalSyncStatus? syncStatus,
  }) {
    return LocalEnquiriesCompanion(
      cloudId: Value(enquiry.id),
      legacyId: Value(enquiry.legacyId),
      studentName: Value(enquiry.studentName),
      parentName: Value(enquiry.parentName),
      phone: Value(enquiry.phone),
      alternatePhone: Value(enquiry.alternatePhone),
      email: Value(enquiry.email),
      dob: Value(enquiry.dob),
      interestedCourseId: Value(enquiry.interestedCourseId),
      interestedCourseName: Value(enquiry.interestedCourseName),
      interestedBatchId: Value(enquiry.interestedBatchId),
      interestedBatchName: Value(enquiry.interestedBatchName),
      currentClass: Value(enquiry.currentClass),
      schoolName: Value(enquiry.schoolName),
      source: Value(enquiry.source),
      enquiryStatus: Value(normalizeStatus(enquiry.enquiryStatus)),
      followUpDate: Value(enquiry.followUpDate),
      message: Value(enquiry.message),
      followUpNotes: Value(enquiry.followUpNotes),
      notes: Value(enquiry.notes),
      assignedTo: Value(enquiry.assignedTo),
      assignedToName: Value(enquiry.assignedToName),
      createdAt: Value(enquiry.createdAt),
      updatedAt: Value(enquiry.updatedAt),
      deletedAt: Value(enquiry.deletedAt),
      syncStatus: Value(syncStatus ?? enquiry.syncStatus),
      lastSyncedAt: Value(
        (syncStatus ?? enquiry.syncStatus) == LocalSyncStatus.synced
            ? DateTime.now()
            : null,
      ),
    );
  }

  static Map<String, dynamic> toFirestorePayload(LocalEnquiry row) {
    final payload = <String, dynamic>{
      'studentName': row.studentName,
      'name': row.studentName,
      'parentName': row.parentName,
      'parent_name': row.parentName,
      'phone': row.phone,
      'alternatePhone': row.alternatePhone,
      'alternate_phone': row.alternatePhone,
      'email': row.email,
      'dob': row.dob?.toIso8601String(),
      'interestedCourseId': row.interestedCourseId,
      'interested_course_id': row.interestedCourseId,
      'interestedCourseName': row.interestedCourseName,
      'course_interested': row.interestedCourseName,
      'interestedBatchId': row.interestedBatchId,
      'interestedBatchName': row.interestedBatchName,
      'currentClass': row.currentClass,
      'current_class': row.currentClass,
      'schoolName': row.schoolName,
      'school_name': row.schoolName,
      'source': row.source,
      'enquiryStatus': row.enquiryStatus,
      'status': row.enquiryStatus,
      'followUpDate': row.followUpDate?.toIso8601String(),
      'follow_up_date': row.followUpDate?.toIso8601String(),
      'message': row.message,
      'followUpNotes': row.followUpNotes,
      'follow_up_notes': row.followUpNotes,
      'notes': row.notes,
      'assignedTo': row.assignedTo,
      'assignedToName': row.assignedToName,
      'createdAt': row.createdAt?.toIso8601String(),
      'created_at': row.createdAt?.toIso8601String(),
      'updatedAt': row.updatedAt?.toIso8601String(),
      'updated_at': row.updatedAt?.toIso8601String(),
      'deletedAt': row.deletedAt?.toIso8601String(),
      'deleted_at': row.deletedAt?.toIso8601String(),
    };
    payload.removeWhere((_, value) => value == null);
    return payload;
  }

  static String normalizeStatus(String? rawStatus) {
    final value = (rawStatus ?? 'new').trim().toLowerCase();
    return switch (value.replaceAll(RegExp(r'[\s_-]+'), '')) {
      'contacted' => 'contacted',
      'followup' || 'follow' || 'followedup' => 'followUp',
      'interested' => 'interested',
      'converted' || 'admitted' || 'admissiondone' => 'converted',
      'notinterested' || 'dead' || 'lost' => 'notInterested',
      'closed' || 'close' => 'closed',
      _ => 'new',
    };
  }

  static String? _string(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = FirestoreMapperHelpers.stringValue(data[key]);
      if (value != null) return value;
    }
    return null;
  }

  static DateTime? _date(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = FirestoreMapperHelpers.dateValue(data[key]);
      if (value != null) return value;
    }
    return null;
  }
}
