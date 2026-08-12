import 'package:cloud_firestore/cloud_firestore.dart';

class FeeRecordValues {
  const FeeRecordValues._();

  static String status(Map<String, dynamic> data) =>
      data['status']?.toString().trim().toLowerCase() ?? 'pending';

  static bool isReceipt(Map<String, dynamic> data) =>
      data['recordType']?.toString() == 'receipt' ||
      data['feeType']?.toString() == 'receipt';

  static bool isOpen(Map<String, dynamic> data) {
    final value = status(data);
    return value == 'pending' ||
        value == 'partially_paid' ||
        value == 'partial';
  }

  /// Planned fee records keep their remaining balance in one of these fields.
  /// Receipt rows never contribute to the outstanding balance.
  static double outstanding(Map<String, dynamic> data) {
    if (isReceipt(data) || !isOpen(data)) return 0;
    return amount(
      data['dueAmount'] ??
          data['pendingAmount'] ??
          data['pending_amount'] ??
          data['balance'] ??
          data['remaining'] ??
          data['total_amount'],
    );
  }

  /// A per-installment date must take priority over the enrollment-level date.
  static DateTime? dueDate(Map<String, dynamic> data) => date(
    data['dueDate'] ??
        data['due_date'] ??
        data['nextDueDate'] ??
        data['next_due_date'],
  );

  static double amount(dynamic value) {
    if (value is num) return value.toDouble();
    final clean = value?.toString().replaceAll(RegExp(r'[^0-9.-]'), '') ?? '';
    return double.tryParse(clean) ?? 0;
  }

  static DateTime? date(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString().trim());
  }
}
