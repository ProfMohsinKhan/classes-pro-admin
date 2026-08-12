import 'package:cloud_firestore/cloud_firestore.dart';

class StudentsRemoteDataSource {
  StudentsRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get collection =>
      _firestore.collection('students');
  Future<QuerySnapshot<Map<String, dynamic>>> fetchAll() =>
      collection.where('deleted_at', isNull: true).get();
  Future<void> upsert(String cloudId, Map<String, dynamic> payload) =>
      collection.doc(cloudId).set(payload, SetOptions(merge: true));
}

class AttendanceRemoteDataSource {
  AttendanceRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get collection =>
      _firestore.collection('attendances');
  Stream<QuerySnapshot<Map<String, dynamic>>> watchDate(
    String dateKey, {
    String? batchId,
  }) {
    Query<Map<String, dynamic>> query = collection.where(
      'dateKey',
      isEqualTo: dateKey,
    );
    final normalizedBatchId = batchId?.trim();
    if (normalizedBatchId != null && normalizedBatchId.isNotEmpty) {
      query = query.where('batchId', isEqualTo: normalizedBatchId);
    }
    return query.snapshots(includeMetadataChanges: true);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchStudent(String studentId) =>
      collection
          .where('studentId', isEqualTo: studentId)
          .snapshots(includeMetadataChanges: true);

  Future<QuerySnapshot<Map<String, dynamic>>> fetchRecent({int limit = 1000}) =>
      collection.limit(limit).get();
  Future<QuerySnapshot<Map<String, dynamic>>> fetchDate(
    String dateKey, {
    String? batchId,
  }) {
    Query<Map<String, dynamic>> query = collection.where(
      'dateKey',
      isEqualTo: dateKey,
    );
    final normalizedBatchId = batchId?.trim();
    if (normalizedBatchId != null && normalizedBatchId.isNotEmpty) {
      query = query.where('batchId', isEqualTo: normalizedBatchId);
    }
    return query.get(const GetOptions(source: Source.serverAndCache));
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> fetchRecord(String cloudId) =>
      collection
          .doc(cloudId)
          .get(const GetOptions(source: Source.serverAndCache));

  Future<void> upsert(String cloudId, Map<String, dynamic> payload) =>
      collection.doc(cloudId).set(payload, SetOptions(merge: true));

  Future<void> upsertMany(Map<String, Map<String, dynamic>> records) async {
    if (records.isEmpty) return;
    var batch = _firestore.batch();
    var opCount = 0;
    for (final entry in records.entries) {
      batch.set(
        collection.doc(entry.key),
        entry.value,
        SetOptions(merge: true),
      );
      opCount++;
      if (opCount == 450) {
        await batch.commit();
        batch = _firestore.batch();
        opCount = 0;
      }
    }
    if (opCount > 0) await batch.commit();
  }
}

class CoursesRemoteDataSource {
  CoursesRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get collection =>
      _firestore.collection('courses');
  Future<QuerySnapshot<Map<String, dynamic>>> fetchAll() => collection.get();
  Future<void> upsert(String cloudId, Map<String, dynamic> payload) =>
      collection.doc(cloudId).set(payload, SetOptions(merge: true));
  Future<void> archive(String cloudId, DateTime archivedAt) =>
      collection.doc(cloudId).set({
        'deleted_at': archivedAt.toIso8601String(),
        'is_active': false,
        'updated_at': archivedAt.toIso8601String(),
      }, SetOptions(merge: true));
}

class BatchesRemoteDataSource {
  BatchesRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get collection =>
      _firestore.collection('batches');
  Future<QuerySnapshot<Map<String, dynamic>>> fetchAll() => collection.get();
  Future<void> upsert(String cloudId, Map<String, dynamic> payload) =>
      collection.doc(cloudId).set(payload, SetOptions(merge: true));
  Future<void> archive(String cloudId, DateTime archivedAt) =>
      collection.doc(cloudId).set({
        'deleted_at': archivedAt.toIso8601String(),
        'is_active': false,
        'updated_at': archivedAt.toIso8601String(),
      }, SetOptions(merge: true));
}

class EnquiriesRemoteDataSource {
  EnquiriesRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get collection =>
      _firestore.collection('enquiries');
  Future<QuerySnapshot<Map<String, dynamic>>> fetchAll() =>
      collection.where('deleted_at', isNull: true).get();
  Future<void> upsert(String cloudId, Map<String, dynamic> payload) =>
      collection.doc(cloudId).set(payload, SetOptions(merge: true));
}
