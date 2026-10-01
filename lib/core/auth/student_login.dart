class StudentLogin {
  const StudentLogin._();

  static const _emailDomain = 'students.classes-management-pro.app';

  /// The contact number is the student-facing login ID.  Firebase Auth uses a
  /// private, deterministic email behind the scenes because it does not offer
  /// a contact-number-and-password sign-in method.
  static String contactId(String value) {
    var digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 13 && digits.startsWith('091')) {
      digits = digits.substring(3);
    } else if (digits.length == 12 && digits.startsWith('91')) {
      digits = digits.substring(2);
    } else if (digits.length == 11 && digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    if (digits.length < 10 || digits.length > 15) {
      throw const FormatException('Enter a valid student contact number.');
    }
    return digits;
  }

  static String emailForContact(String contactNumber) {
    return 'student.${contactId(contactNumber)}@$_emailDomain';
  }

  static bool isContactIdentifier(String value) {
    final clean = value.trim();
    return clean.isNotEmpty && !clean.contains('@');
  }
}
