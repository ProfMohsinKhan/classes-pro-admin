import 'package:classes_pro_admin/core/fees/fee_record_values.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FeeRecordValues', () {
    test('receipt rows never change the pending total', () {
      expect(
        FeeRecordValues.outstanding({
          'recordType': 'receipt',
          'status': 'paid',
          'amount_paid': '500',
          'total_amount': '0',
        }),
        0,
      );
    });

    test('uses the remaining balance for a partially paid installment', () {
      expect(
        FeeRecordValues.outstanding({
          'status': 'pending',
          'total_amount': '300',
          'amount_paid': '200',
        }),
        300,
      );
    });

    test('uses the individual installment due date before nextDueDate', () {
      final dueDate = FeeRecordValues.dueDate({
        'due_date': '2026-08-15T00:00:00.000',
        'nextDueDate': '2026-07-31T00:00:00.000',
      });

      expect(dueDate, DateTime(2026, 8, 15));
    });
  });
}
