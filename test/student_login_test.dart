import 'package:classes_pro_admin/core/auth/student_login.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StudentLogin', () {
    test('uses a normalized Indian contact number as the student login ID', () {
      expect(StudentLogin.contactId('+91 98765 43210'), '9876543210');
      expect(StudentLogin.contactId('09876543210'), '9876543210');
      expect(
        StudentLogin.emailForContact('98765 43210'),
        'student.9876543210@students.classes-management-pro.app',
      );
    });

    test('rejects an invalid contact number', () {
      expect(() => StudentLogin.contactId('12345'), throwsFormatException);
    });

    test('distinguishes a contact-number login from an email login', () {
      expect(StudentLogin.isContactIdentifier('9876543210'), isTrue);
      expect(StudentLogin.isContactIdentifier('admin@example.com'), isFalse);
    });
  });
}
