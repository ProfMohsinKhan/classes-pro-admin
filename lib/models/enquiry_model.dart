import '../core/database/app_database.dart';
import '../core/database/sync_types.dart';

class EnquiryModel {
  const EnquiryModel({
    required this.id,
    required this.studentName,
    this.legacyId,
    this.parentName,
    this.phone,
    this.alternatePhone,
    this.email,
    this.dob,
    this.interestedCourseId,
    this.interestedCourseName,
    this.interestedBatchId,
    this.interestedBatchName,
    this.currentClass,
    this.schoolName,
    this.source,
    this.enquiryStatus = 'new',
    this.followUpDate,
    this.message,
    this.followUpNotes,
    this.notes,
    this.assignedTo,
    this.assignedToName,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.syncStatus = LocalSyncStatus.synced,
  });

  final String id;
  final String? legacyId;
  final String studentName;
  final String? parentName;
  final String? phone;
  final String? alternatePhone;
  final String? email;
  final DateTime? dob;
  final String? interestedCourseId;
  final String? interestedCourseName;
  final String? interestedBatchId;
  final String? interestedBatchName;
  final String? currentClass;
  final String? schoolName;
  final String? source;
  final String enquiryStatus;
  final DateTime? followUpDate;
  final String? message;
  final String? followUpNotes;
  final String? notes;
  final String? assignedTo;
  final String? assignedToName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final LocalSyncStatus syncStatus;

  bool get isArchived => deletedAt != null;

  factory EnquiryModel.fromLocal(LocalEnquiry row) {
    return EnquiryModel(
      id: row.cloudId ?? row.localId.toString(),
      legacyId: row.legacyId,
      studentName: row.studentName,
      parentName: row.parentName,
      phone: row.phone,
      alternatePhone: row.alternatePhone,
      email: row.email,
      dob: row.dob,
      interestedCourseId: row.interestedCourseId,
      interestedCourseName: row.interestedCourseName,
      interestedBatchId: row.interestedBatchId,
      interestedBatchName: row.interestedBatchName,
      currentClass: row.currentClass,
      schoolName: row.schoolName,
      source: row.source,
      enquiryStatus: row.enquiryStatus,
      followUpDate: row.followUpDate,
      message: row.message,
      followUpNotes: row.followUpNotes,
      notes: row.notes,
      assignedTo: row.assignedTo,
      assignedToName: row.assignedToName,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
      syncStatus: row.syncStatus,
    );
  }

  EnquiryModel copyWith({
    String? id,
    String? legacyId,
    String? studentName,
    String? parentName,
    String? phone,
    String? alternatePhone,
    String? email,
    DateTime? dob,
    String? interestedCourseId,
    String? interestedCourseName,
    String? interestedBatchId,
    String? interestedBatchName,
    String? currentClass,
    String? schoolName,
    String? source,
    String? enquiryStatus,
    DateTime? followUpDate,
    String? message,
    String? followUpNotes,
    String? notes,
    String? assignedTo,
    String? assignedToName,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    LocalSyncStatus? syncStatus,
  }) {
    return EnquiryModel(
      id: id ?? this.id,
      legacyId: legacyId ?? this.legacyId,
      studentName: studentName ?? this.studentName,
      parentName: parentName ?? this.parentName,
      phone: phone ?? this.phone,
      alternatePhone: alternatePhone ?? this.alternatePhone,
      email: email ?? this.email,
      dob: dob ?? this.dob,
      interestedCourseId: interestedCourseId ?? this.interestedCourseId,
      interestedCourseName: interestedCourseName ?? this.interestedCourseName,
      interestedBatchId: interestedBatchId ?? this.interestedBatchId,
      interestedBatchName: interestedBatchName ?? this.interestedBatchName,
      currentClass: currentClass ?? this.currentClass,
      schoolName: schoolName ?? this.schoolName,
      source: source ?? this.source,
      enquiryStatus: enquiryStatus ?? this.enquiryStatus,
      followUpDate: followUpDate ?? this.followUpDate,
      message: message ?? this.message,
      followUpNotes: followUpNotes ?? this.followUpNotes,
      notes: notes ?? this.notes,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedToName: assignedToName ?? this.assignedToName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
