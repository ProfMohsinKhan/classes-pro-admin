import 'package:cloud_firestore/cloud_firestore.dart';

class StudentModel {
  final String id;
  final int? numericId;
  final String studentId;
  final String name;
  final String? email;
  final String? phone;
  final String? parentName;
  final String? parentPhone;
  final String? profilePhoto;
  final DateTime? dob;
  final String? gender;
  final String? className;
  final String? batchName;
  final String? batchId;
  final String? courseName;
  final String? courseId;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? guardianName;
  final String? guardianRelation;
  final String? guardianPhone;
  final String? guardianEmail;
  final String? guardianOccupation;
  final String? previousSchool;
  final String? previousClass;
  final String? previousPercentage;
  final String? status;
  final DateTime? admissionDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? referenceSource;
  final String? qrCode;
  final String? notes;

  StudentModel({
    required this.id,
    required this.studentId,
    required this.name,
    this.numericId,
    this.email,
    this.phone,
    this.parentName,
    this.parentPhone,
    this.profilePhoto,
    this.dob,
    this.gender,
    this.className,
    this.batchName,
    this.batchId,
    this.courseName,
    this.courseId,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.guardianName,
    this.guardianRelation,
    this.guardianPhone,
    this.guardianEmail,
    this.guardianOccupation,
    this.previousSchool,
    this.previousClass,
    this.previousPercentage,
    this.status,
    this.admissionDate,
    this.createdAt,
    this.updatedAt,
    this.referenceSource,
    this.qrCode,
    this.notes,
  });

  static DateTime? parseDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static int? parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static String? parseString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  factory StudentModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return StudentModel(
      id: doc.id,
      numericId: parseInt(data['id']),
      studentId:
          parseString(data['student_id']) ?? parseString(data['id']) ?? '',
      name: parseString(data['name']) ?? '',
      email: parseString(data['email']),
      phone: parseString(data['phone']),
      parentName:
          parseString(data['parentName']) ??
          parseString(data['parent_name']) ??
          parseString(data['guardian_name']),
      parentPhone:
          parseString(data['parentPhone']) ??
          parseString(data['parent_phone']) ??
          parseString(data['guardian_phone']),
      profilePhoto:
          parseString(data['profile_photo']) ??
          parseString(data['profilePhoto']),
      dob: parseDate(data['dob'] ?? data['dateOfBirth'] ?? data['birthDate']),
      gender: parseString(data['gender']),
      className:
          parseString(data['className']) ??
          parseString(data['standard']) ??
          parseString(data['class']) ??
          parseString(data['previous_class']),
      batchName:
          parseString(data['batchName']) ??
          parseString(data['batch_name']) ??
          parseString(data['batch']),
      batchId: parseString(data['batchId']) ?? parseString(data['batch_id']),
      courseName:
          parseString(data['courseName']) ??
          parseString(data['course_name']) ??
          parseString(data['course']),
      courseId: parseString(data['courseId']) ?? parseString(data['course_id']),
      address: parseString(data['address']),
      city: parseString(data['city']),
      state: parseString(data['state']),
      pincode: parseString(data['pincode']),
      guardianName: parseString(data['guardian_name']),
      guardianRelation: parseString(data['guardian_relation']),
      guardianPhone: parseString(data['guardian_phone']),
      guardianEmail: parseString(data['guardian_email']),
      guardianOccupation: parseString(data['guardian_occupation']),
      previousSchool: parseString(data['previous_school']),
      previousClass: parseString(data['previous_class']),
      previousPercentage: parseString(data['previous_percentage']),
      status: parseString(data['status']) ?? 'active',
      admissionDate: parseDate(data['admission_date']),
      createdAt: parseDate(data['createdAt'] ?? data['created_at']),
      updatedAt: parseDate(data['updatedAt'] ?? data['updated_at']),
      referenceSource: parseString(data['reference_source']),
      qrCode: parseString(data['qr_code']),
      notes: parseString(data['notes']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (numericId != null) 'id': numericId,
      'student_id': studentId,
      'name': name,
      'email': email,
      'phone': phone,
      'parentName': parentName,
      'parentPhone': parentPhone,
      'profile_photo': profilePhoto,
      'dob': dob == null ? null : Timestamp.fromDate(dob!),
      'dateOfBirth': dob == null ? null : Timestamp.fromDate(dob!),
      'gender': gender,
      'className': className,
      'standard': className,
      'batchName': batchName,
      'batch': batchName,
      'batchId': batchId,
      'courseName': courseName,
      'course': courseName,
      'courseId': courseId,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'guardian_name': guardianName ?? parentName,
      'guardian_relation': guardianRelation,
      'guardian_phone': guardianPhone ?? parentPhone,
      'guardian_email': guardianEmail,
      'guardian_occupation': guardianOccupation,
      'previous_school': previousSchool,
      'previous_class': previousClass ?? className,
      'previous_percentage': previousPercentage,
      'status': status,
      'admission_date': admissionDate?.toIso8601String(),
      'reference_source': referenceSource,
      'qr_code': qrCode,
      'notes': notes,
    };
  }

  String get displayName => name.trim().isEmpty ? 'Unnamed Student' : name;

  String get displayClassBatch {
    final parts = [
      if ((className ?? '').trim().isNotEmpty) className!.trim(),
      if ((batchName ?? '').trim().isNotEmpty) batchName!.trim(),
      if ((courseName ?? '').trim().isNotEmpty) courseName!.trim(),
    ];
    return parts.isEmpty ? 'Class/Batch not set' : parts.join(' • ');
  }

  String get primaryPhone => phone ?? parentPhone ?? guardianPhone ?? '';

  DateTime? get birthdayDate => dob;

  bool get isActive => (status ?? 'active').toLowerCase() == 'active';

  bool isBirthdayInNextDays(int days) {
    if (dob == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var birthday = DateTime(now.year, dob!.month, dob!.day);
    if (birthday.isBefore(today)) {
      birthday = DateTime(now.year + 1, dob!.month, dob!.day);
    }
    final diff = birthday.difference(today).inDays;
    return diff >= 0 && diff <= days;
  }

  int? get age {
    if (dob == null) return null;
    final now = DateTime.now();
    var years = now.year - dob!.year;
    if (now.month < dob!.month ||
        (now.month == dob!.month && now.day < dob!.day)) {
      years--;
    }
    return years;
  }
}
