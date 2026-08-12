import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../models/app_user_model.dart';
import '../models/reminder_model.dart';

class ReminderService {
  ReminderService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('reminders');

  Future<List<ReminderModel>> loadReminders({
    bool generateDerived = true,
  }) async {
    if (generateDerived) {
      await Future.wait([
        generateBirthdayRemindersFromStudents(),
        generateFeeDueRemindersFromEnrollments(),
      ]);
    }

    final snapshot = await _collection.limit(300).get();
    final reminders = snapshot.docs.map(ReminderModel.fromDoc).toList()
      ..sort((a, b) {
        final statusCompare = a.status.index.compareTo(b.status.index);
        if (statusCompare != 0) return statusCompare;
        return a.dueDate.compareTo(b.dueDate);
      });
    return reminders;
  }

  Future<List<ReminderStudentOption>> loadStudentOptions() async {
    final snapshot = await _firestore
        .collection('students')
        .where('deleted_at', isNull: true)
        .limit(300)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return ReminderStudentOption(
        id: _string(data['id'] ?? data['student_id'] ?? doc.id) ?? doc.id,
        name: _string(data['name'] ?? data['studentName']) ?? 'Unnamed Student',
        studentPhone: _string(data['phone']),
        parentPhone: _string(
          data['parentPhone'] ?? data['parent_phone'] ?? data['guardian_phone'],
        ),
      );
    }).toList()..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<ReminderModel> createReminder({
    required String title,
    required String description,
    required DateTime dueDate,
    required ReminderPriority priority,
    required AppUserModel appUser,
    ReminderStudentOption? student,
  }) async {
    final docRef = _collection.doc();
    final reminder = ReminderModel(
      id: docRef.id,
      type: ReminderType.general,
      title: title,
      description: description,
      dueDate: dueDate,
      status: ReminderStatus.pending,
      priority: priority,
      studentId: student?.id,
      studentName: student?.name,
      studentPhone: student?.studentPhone,
      parentPhone: student?.parentPhone,
      createdBy: appUser.uid,
      createdByName: appUser.name.trim().isEmpty ? appUser.email : appUser.name,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await docRef.set(reminder.toMap());
    return reminder;
  }

  Future<void> updateReminder(ReminderModel reminder) async {
    await _collection
        .doc(reminder.id)
        .set(reminder.toMap(), SetOptions(merge: true));
  }

  Future<void> markDone(String id) async {
    await _collection.doc(id).set({
      'status': ReminderStatus.done.name,
      'completedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> dismissReminder(String id) async {
    await _collection.doc(id).set({
      'status': ReminderStatus.dismissed.name,
      'dismissedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteReminder(String id) async {
    await _collection.doc(id).delete();
  }

  Future<void> generateBirthdayRemindersFromStudents() async {
    final snapshot = await _firestore
        .collection('students')
        .where('deleted_at', isNull: true)
        .limit(300)
        .get();
    final today = _dateOnly(DateTime.now());
    final tasks = <Future<void>>[];

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final dob = _date(
        data['dob'] ?? data['dateOfBirth'] ?? data['birthDate'],
      );
      if (dob == null) continue;
      var birthday = DateTime(today.year, dob.month, dob.day);
      if (birthday.isBefore(today)) {
        birthday = DateTime(today.year + 1, dob.month, dob.day);
      }
      final daysLeft = birthday.difference(today).inDays;
      if (daysLeft < 0 || daysLeft > 30) continue;

      final studentId =
          _string(data['id'] ?? data['student_id'] ?? doc.id) ?? doc.id;
      final docId =
          'birthday_${studentId}_${DateFormat('yyyyMMdd').format(birthday)}';
      tasks.add(
        _createIfMissing(docId, {
          'type': ReminderType.birthday.name,
          'title': daysLeft == 0 ? 'Birthday today' : 'Upcoming birthday',
          'description':
              'Wish ${_string(data['name']) ?? 'student'} from Mak Tutorials.',
          'studentId': studentId,
          'studentName': _string(data['name']),
          'studentPhone': _string(data['phone']),
          'parentPhone': _string(
            data['parentPhone'] ??
                data['parent_phone'] ??
                data['guardian_phone'],
          ),
          'dueDate': Timestamp.fromDate(birthday),
          'status': ReminderStatus.pending.name,
          'priority': daysLeft <= 1
              ? ReminderPriority.high.name
              : ReminderPriority.normal.name,
          'createdBy': 'system',
          'createdByName': 'System',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }),
      );
    }
    await Future.wait(tasks);
  }

  Future<void> generateFeeDueRemindersFromEnrollments() async {
    final results = await Future.wait([
      _firestore
          .collection('fee_payments')
          .where('status', isEqualTo: 'pending')
          .where('deleted_at', isNull: true)
          .limit(300)
          .get(),
      _firestore
          .collection('students')
          .where('deleted_at', isNull: true)
          .limit(300)
          .get(),
    ]);
    final studentsById = {
      for (final doc in results[1].docs)
        (_string(doc.data()['id'] ?? doc.data()['student_id'] ?? doc.id) ??
            doc.id): doc
            .data(),
    };
    final today = _dateOnly(DateTime.now());
    final limit = today.add(const Duration(days: 30));
    final tasks = <Future<void>>[];

    for (final doc in results[0].docs) {
      final data = doc.data();
      final dueDate = _date(
        data['dueDate'] ??
            data['due_date'] ??
            data['nextDueDate'] ??
            data['next_due_date'],
      );
      if (dueDate == null) continue;
      final dueDay = _dateOnly(dueDate);
      if (dueDay.isAfter(limit)) continue;
      final studentId = _string(data['student_id'] ?? data['studentId']) ?? '';
      if (studentId.isEmpty) continue;
      final student = studentsById[studentId];
      final amount = _amount(
        data['pendingAmount'] ??
            data['dueAmount'] ??
            data['balance'] ??
            data['remaining'] ??
            data['total_amount'] ??
            data['amount'],
      );
      if (amount <= 0) continue;
      final docId = 'fee_${studentId}_${DateFormat('yyyyMMdd').format(dueDay)}';
      tasks.add(
        _createIfMissing(docId, {
          'type': ReminderType.feeDue.name,
          'title': dueDay.isBefore(today)
              ? 'Overdue fee reminder'
              : 'Fee due reminder',
          'description':
              'Pending fee reminder for ${_string(data['month_year']) ?? 'installment'}.',
          'studentId': studentId,
          'studentName': _string(
            data['studentName'] ?? data['student_name'] ?? student?['name'],
          ),
          'studentPhone': _string(student?['phone']),
          'parentPhone': _string(
            student?['parentPhone'] ??
                student?['parent_phone'] ??
                student?['guardian_phone'],
          ),
          'dueDate': Timestamp.fromDate(dueDay),
          'amount': amount,
          'status': ReminderStatus.pending.name,
          'priority': dueDay.isBefore(today) || _isSameDay(dueDay, today)
              ? ReminderPriority.high.name
              : ReminderPriority.normal.name,
          'createdBy': 'system',
          'createdByName': 'System',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }),
      );
    }
    await Future.wait(tasks);
  }

  Future<void> _createIfMissing(String docId, Map<String, dynamic> data) async {
    final ref = _collection.doc(docId);
    final existing = await ref.get();
    if (existing.exists) return;
    await ref.set(data);
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);
  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static DateTime? _date(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  static double _amount(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  static String? _string(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}
