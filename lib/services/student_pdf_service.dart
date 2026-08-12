import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../models/attendance_model.dart';
import '../models/student_model.dart';
import 'institute_settings_service.dart';
import 'pdf_browser_service.dart';

class StudentPdfService {
  const StudentPdfService._();

  static const String logoAssetPath = 'assets/icon/logo.png';
  static const String signatureAssetPath = 'assets/signature/signature.png';

  static Future<bool> shareStudentProfile(StudentModel student) async {
    final context = await _loadPdfContext();
    final studentPhoto = await _loadNetworkImage(student.profilePhoto);
    final bytes = await _buildDocument(
      context: context,
      title: 'Student Profile',
      fileTitle: 'Student Profile',
      sections: [_studentProfileSection(student, studentPhoto)],
    );
    return _shareBytes(bytes, _fileName('Student_Profile', student));
  }

  static Future<bool> shareEnrollment(StudentModel student) async {
    final results = await Future.wait([
      _loadPdfContext(),
      _loadEnrollment(student),
      _loadFeeRecords(student),
    ]);
    final context = results[0] as _PdfContext;
    final enrollment = results[1] as _EnrollmentRecord?;
    final feeRecords = results[2] as List<_FeeRecord>;
    final bytes = await _buildDocument(
      context: context,
      title: 'Enrollment Details',
      fileTitle: 'Enrollment Details',
      sections: [
        _studentSummarySection(student, context.settings.academicYear),
        _enrollmentSection(enrollment),
        _installmentSection(feeRecords),
      ],
    );
    return _shareBytes(bytes, _fileName('Enrollment', student));
  }

  static Future<bool> shareFeeStatement(StudentModel student) async {
    final results = await Future.wait([
      _loadPdfContext(),
      _loadFeeRecords(student),
    ]);
    final context = results[0] as _PdfContext;
    final feeRecords = results[1] as List<_FeeRecord>;
    final statement = _FeeStatement.fromRecords(feeRecords);
    final bytes = await _buildDocument(
      context: context,
      title: 'Fee Statement',
      fileTitle: 'Fee Statement',
      sections: [
        _studentSummarySection(student, context.settings.academicYear),
        _feeSummarySection(statement, context.currency),
        _paymentHistorySection(statement.payments, context.currency),
      ],
    );
    return _shareBytes(bytes, _fileName('Fee_Statement', student));
  }

  static Future<bool> shareAttendanceSummary(StudentModel student) async {
    final results = await Future.wait([
      _loadPdfContext(),
      _loadAttendance(student),
    ]);
    final context = results[0] as _PdfContext;
    final attendance = results[1] as List<_AttendanceRecord>;
    final summary = _AttendancePdfSummary.fromRecords(attendance);
    final bytes = await _buildDocument(
      context: context,
      title: 'Attendance Summary',
      fileTitle: 'Attendance Summary',
      sections: [
        _studentSummarySection(student, context.settings.academicYear),
        _attendanceSummarySection(summary),
        _attendanceTableSection(attendance),
      ],
    );
    return _shareBytes(bytes, _fileName('Attendance', student));
  }

  static Future<bool> shareFullReport(StudentModel student) async {
    final results = await Future.wait([
      _loadPdfContext(),
      _loadEnrollment(student),
      _loadFeeRecords(student),
      _loadAttendance(student),
    ]);
    final context = results[0] as _PdfContext;
    final enrollment = results[1] as _EnrollmentRecord?;
    final feeRecords = results[2] as List<_FeeRecord>;
    final attendance = results[3] as List<_AttendanceRecord>;
    final feeStatement = _FeeStatement.fromRecords(feeRecords);
    final attendanceSummary = _AttendancePdfSummary.fromRecords(attendance);

    final bytes = await _buildDocument(
      context: context,
      title: 'Full Student Report',
      fileTitle: 'Full Student Report',
      sections: [
        _studentProfileSection(
          student,
          await _loadNetworkImage(student.profilePhoto),
        ),
        _enrollmentSection(enrollment),
        _installmentSection(feeRecords),
        _feeSummarySection(feeStatement, context.currency),
        _paymentHistorySection(feeStatement.payments, context.currency),
        _attendanceSummarySection(attendanceSummary),
        _attendanceTableSection(attendance),
      ],
    );
    return _shareBytes(bytes, _fileName('Full_Report', student));
  }

  static Future<_PdfContext> _loadPdfContext() async {
    final settings = await InstituteSettingsService.instance.loadSettings();
    final logo = await _loadImage(settings.logoUrl, logoAssetPath);
    final signature = await _loadImage(
      settings.signatureUrl,
      signatureAssetPath,
    );
    return _PdfContext(
      settings: settings,
      logo: logo,
      signature: signature,
      currency: _pdfText(
        settings.currencySymbol.trim().isEmpty ? 'Rs' : settings.currencySymbol,
      ),
    );
  }

  static Future<Uint8List> _buildDocument({
    required _PdfContext context,
    required String title,
    required String fileTitle,
    required List<pw.Widget> sections,
  }) async {
    final pdf = pw.Document();
    final generatedAt = DateFormat(
      'dd MMM yyyy, hh:mm a',
    ).format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        header: (_) => _header(context, title),
        footer: (_) => _footer(context, generatedAt),
        build: (_) => [
          pw.SizedBox(height: 14),
          ...sections.expand((section) => [section, pw.SizedBox(height: 16)]),
          _signatureBlock(context),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _header(_PdfContext context, String title) {
    final settings = context.settings;
    final instituteName = _value(
      settings.instituteName,
      fallback: 'Mak Tutorials',
    );
    final contact = [
      if (settings.address.trim().isNotEmpty) settings.address.trim(),
      if (settings.phone.trim().isNotEmpty) 'Phone: ${settings.phone.trim()}',
      if (settings.email.trim().isNotEmpty) 'Email: ${settings.email.trim()}',
    ].join(' | ');

    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey400)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _logoBox(context.logo),
          pw.SizedBox(width: 12),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  _pdfText(instituteName),
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#0F172A'),
                  ),
                ),
                if (contact.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    _pdfText(contact),
                    style: const pw.TextStyle(
                      fontSize: 8.5,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          pw.SizedBox(width: 14),
          pw.Container(
            width: 150,
            padding: const pw.EdgeInsets.all(10),
            color: PdfColor.fromHex('#EFF6FF'),
            child: pw.Text(
              _pdfText(title),
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                fontSize: 15,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#2563EB'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _studentProfileSection(
    StudentModel student,
    pw.MemoryImage? studentPhoto,
  ) {
    final address = [
      student.address,
      student.city,
      student.state,
      student.pincode,
    ].where((item) => (item ?? '').trim().isNotEmpty).join(', ');

    return _section(
      'Student Details',
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _studentPhotoBox(student, studentPhoto),
          pw.SizedBox(width: 12),
          pw.Expanded(
            child: _grid([
              ('Student Name', student.displayName),
              ('Student Phone', student.primaryPhone),
              ('Parent Name', student.parentName ?? student.guardianName),
              ('Parent Phone', student.parentPhone ?? student.guardianPhone),
              ('DOB', _dateText(student.dob)),
              ('Age', student.age?.toString()),
              ('Status', student.isActive ? 'Active' : 'Inactive'),
              ('Course', student.courseName),
              ('Batch', student.batchName),
              ('Class/Standard', student.className ?? student.previousClass),
              ('Address', address),
              ('Notes', student.notes),
            ], itemWidth: 132),
          ),
        ],
      ),
    );
  }

  static pw.Widget _studentSummarySection(
    StudentModel student,
    String academicYear,
  ) {
    return _section(
      'Student',
      _grid([
        ('Student Name', student.displayName),
        ('Parent Name', student.parentName ?? student.guardianName),
        ('Parent Phone', student.parentPhone ?? student.guardianPhone),
        ('Course', student.courseName),
        ('Batch', student.batchName),
        ('Academic Year', academicYear),
      ]),
    );
  }

  static pw.Widget _enrollmentSection(_EnrollmentRecord? enrollment) {
    if (enrollment == null) {
      return _section(
        'Enrollment / Fee Plan',
        _message('No enrollment record found for this student.'),
      );
    }

    return _section(
      'Enrollment / Fee Plan',
      _grid([
        ('Course Fee Reference', _money(enrollment.courseFeeReference, 'Rs')),
        ('Discount', _money(enrollment.discount, 'Rs')),
        ('Final Fee', _money(enrollment.finalFee, 'Rs')),
        ('Payment Structure', enrollment.planType),
        ('Installment Count', enrollment.installmentCount?.toString()),
        ('Start Date', _dateText(enrollment.startDate)),
        ('Next Due Date', _dateText(enrollment.nextDueDate)),
        ('Status', enrollment.status),
        ('Notes', enrollment.notes),
      ]),
    );
  }

  static pw.Widget _installmentSection(List<_FeeRecord> records) {
    final installments =
        records
            .where(
              (record) => !record.isReceipt && record.installmentNo != null,
            )
            .toList()
          ..sort(
            (a, b) => (a.installmentNo ?? 0).compareTo(b.installmentNo ?? 0),
          );
    if (installments.isEmpty) {
      return _section(
        'Installment Preview',
        _message('No installment records found.'),
      );
    }

    return _section(
      'Installment Preview',
      _table(
        ['No', 'Due Amount', 'Due Date', 'Status'],
        installments
            .take(24)
            .map(
              (record) => [
                record.installmentNo?.toString() ?? '-',
                _money(record.installmentAmount, 'Rs'),
                _dateText(record.dueDate),
                record.displayStatus,
              ],
            )
            .toList(),
      ),
    );
  }

  static pw.Widget _feeSummarySection(
    _FeeStatement statement,
    String currency,
  ) {
    return _section(
      'Fee Summary',
      _grid([
        ('Total Fee', _money(statement.totalFee, currency)),
        ('Total Paid', _money(statement.totalPaid, currency)),
        ('Pending Amount', _money(statement.pending, currency)),
        ('Status', statement.status),
      ]),
    );
  }

  static pw.Widget _paymentHistorySection(
    List<_FeeRecord> payments,
    String currency,
  ) {
    if (payments.isEmpty) {
      return _section('Payment History', _message('No payment records found.'));
    }

    return _section(
      'Payment History',
      _table(
        [
          'Receipt No',
          'Payment Date',
          'Amount',
          'Mode',
          'Received By',
          'Remarks',
        ],
        payments
            .take(40)
            .map(
              (record) => [
                record.receiptNo,
                _dateText(record.paymentDate),
                _money(record.paidAmount, currency),
                record.paymentMode,
                record.receivedBy,
                record.remarks,
              ],
            )
            .toList(),
      ),
    );
  }

  static pw.Widget _attendanceSummarySection(_AttendancePdfSummary summary) {
    return _section(
      'Attendance Summary',
      _grid([
        ('Total Records', summary.total.toString()),
        ('Present', summary.present.toString()),
        ('Absent', summary.absent.toString()),
        ('Late', summary.late.toString()),
        ('Leave', summary.leave.toString()),
        ('Attendance %', '${summary.percentage.toStringAsFixed(1)}%'),
        ('Absent Dates', summary.absentDatesText),
      ]),
    );
  }

  static pw.Widget _attendanceTableSection(List<_AttendanceRecord> records) {
    if (records.isEmpty) {
      return _section(
        'Recent Attendance',
        _message('No attendance records found.'),
      );
    }

    final recent = records.toList()..sort((a, b) => b.date.compareTo(a.date));
    return _section(
      'Recent Attendance',
      _table(
        ['Date', 'Status', 'Marked By'],
        recent
            .take(40)
            .map(
              (record) => [
                _dateText(record.date),
                record.statusLabel,
                record.markedByName,
              ],
            )
            .toList(),
      ),
    );
  }

  static pw.Widget _section(String title, pw.Widget child) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          _pdfText(title),
          style: pw.TextStyle(
            fontSize: 13,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#0F172A'),
          ),
        ),
        pw.SizedBox(height: 8),
        child,
      ],
    );
  }

  static pw.Widget _grid(
    List<(String, String?)> rows, {
    double itemWidth = 157,
  }) {
    return pw.Wrap(
      spacing: 8,
      runSpacing: 8,
      children: rows.map((row) {
        return pw.Container(
          width: itemWidth,
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#F8FAFC'),
            border: pw.Border.all(
              color: PdfColor.fromHex('#CBD5E1'),
              width: 0.6,
            ),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                _pdfText(row.$1),
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                _value(row.$2),
                style: pw.TextStyle(
                  fontSize: 9.5,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  static pw.Widget _table(List<String> headers, List<List<String>> rows) {
    return pw.TableHelper.fromTextArray(
      headers: headers.map(_pdfText).toList(),
      data: rows.map((row) => row.map(_value).toList()).toList(),
      headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#2563EB')),
      headerStyle: pw.TextStyle(
        color: PdfColors.white,
        fontWeight: pw.FontWeight.bold,
        fontSize: 8.5,
      ),
      cellStyle: const pw.TextStyle(fontSize: 8.2, color: PdfColors.grey900),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 6),
      border: pw.TableBorder.all(
        color: PdfColor.fromHex('#CBD5E1'),
        width: 0.5,
      ),
      cellAlignments: {
        for (var i = 0; i < headers.length; i++) i: pw.Alignment.centerLeft,
      },
    );
  }

  static pw.Widget _message(String message) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F8FAFC'),
        border: pw.Border.all(color: PdfColor.fromHex('#CBD5E1'), width: 0.6),
      ),
      child: pw.Text(
        _pdfText(message),
        style: const pw.TextStyle(fontSize: 10),
      ),
    );
  }

  static pw.Widget _signatureBlock(_PdfContext context) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Expanded(
          child: pw.Text(
            'Generated by Mak Tutorials Classes Management App',
            style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
          ),
        ),
        pw.Container(
          width: 170,
          child: pw.Column(
            children: [
              if (context.signature != null)
                pw.Image(
                  context.signature!,
                  width: 120,
                  height: 42,
                  fit: pw.BoxFit.contain,
                )
              else
                pw.SizedBox(height: 42),
              pw.Container(height: 1, width: 150, color: PdfColors.grey500),
              pw.SizedBox(height: 4),
              pw.Text(
                'Authorized Signature',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _footer(_PdfContext context, String generatedAt) {
    final footer = context.settings.reportFooter.trim().isNotEmpty
        ? context.settings.reportFooter
        : 'Generated by Mak Tutorials Classes Management App.';
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey400)),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(
              _pdfText(footer),
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
            ),
          ),
          pw.Text(
            'Generated: ${_pdfText(generatedAt)}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),
        ],
      ),
    );
  }

  static pw.Widget _logoBox(pw.MemoryImage? logo) {
    return pw.Container(
      width: 54,
      height: 54,
      alignment: pw.Alignment.center,
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#EFF6FF'),
        border: pw.Border.all(color: PdfColor.fromHex('#CBD5E1'), width: 0.6),
      ),
      child: logo == null
          ? pw.Text(
              'MT',
              style: pw.TextStyle(
                fontSize: 18,
                color: PdfColor.fromHex('#2563EB'),
                fontWeight: pw.FontWeight.bold,
              ),
            )
          : pw.Image(logo, fit: pw.BoxFit.contain),
    );
  }

  static pw.Widget _studentPhotoBox(
    StudentModel student,
    pw.MemoryImage? studentPhoto,
  ) {
    final initial = student.displayName.trim().isEmpty
        ? 'S'
        : student.displayName.trim().substring(0, 1).toUpperCase();
    return pw.Container(
      width: 88,
      child: pw.Column(
        children: [
          pw.Container(
            width: 82,
            height: 82,
            alignment: pw.Alignment.center,
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#EFF6FF'),
              border: pw.Border.all(color: PdfColor.fromHex('#CBD5E1')),
            ),
            child: studentPhoto == null
                ? pw.Text(
                    initial,
                    style: pw.TextStyle(
                      fontSize: 28,
                      color: PdfColor.fromHex('#2563EB'),
                      fontWeight: pw.FontWeight.bold,
                    ),
                  )
                : pw.Image(studentPhoto, fit: pw.BoxFit.cover),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'Student Photo',
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),
        ],
      ),
    );
  }

  static Future<pw.MemoryImage?> _loadNetworkImage(String? imageUrl) async {
    final cleanUrl = imageUrl?.trim() ?? '';
    if (cleanUrl.isEmpty) return null;
    try {
      final response = await http.get(Uri.parse(cleanUrl));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return pw.MemoryImage(response.bodyBytes);
      }
    } catch (error) {
      debugPrint('Student profile photo not available: $cleanUrl ($error)');
    }
    return null;
  }

  static Future<pw.MemoryImage?> _loadImage(
    String url,
    String assetPath,
  ) async {
    final cleanUrl = url.trim();
    if (cleanUrl.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(cleanUrl));
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return pw.MemoryImage(response.bodyBytes);
        }
      } catch (error) {
        debugPrint('Student PDF image URL not available: $cleanUrl ($error)');
      }
    }

    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      if (!manifest.listAssets().contains(assetPath)) return null;
      final data = await rootBundle.load(assetPath);
      return pw.MemoryImage(data.buffer.asUint8List());
    } catch (error) {
      debugPrint('Student PDF asset not available: $assetPath ($error)');
      return null;
    }
  }

  static Future<_EnrollmentRecord?> _loadEnrollment(
    StudentModel student,
  ) async {
    final query = FirebaseFirestore.instance.collection('enrollments');
    QuerySnapshot<Map<String, dynamic>> snapshot;
    if (student.numericId != null) {
      snapshot = await query
          .where('student_id', isEqualTo: student.numericId)
          .limit(1)
          .get();
    } else {
      snapshot = await query
          .where('studentId', isEqualTo: student.studentId)
          .limit(1)
          .get();
    }
    if (snapshot.docs.isEmpty && student.studentId.isNotEmpty) {
      snapshot = await query
          .where('studentId', isEqualTo: student.studentId)
          .limit(1)
          .get();
    }
    if (snapshot.docs.isEmpty) return null;
    return _EnrollmentRecord(snapshot.docs.first.data());
  }

  static Future<List<_FeeRecord>> _loadFeeRecords(StudentModel student) async {
    if (student.numericId == null) return const [];
    final snapshot = await FirebaseFirestore.instance
        .collection('fee_payments')
        .where('student_id', isEqualTo: student.numericId)
        .where('deleted_at', isNull: true)
        .get();
    final records = snapshot.docs.map((doc) => _FeeRecord(doc.data())).toList();
    records.sort((a, b) {
      final aDate = a.dueDate ?? a.paymentDate ?? DateTime(2099);
      final bDate = b.dueDate ?? b.paymentDate ?? DateTime(2099);
      return aDate.compareTo(bDate);
    });
    return records;
  }

  static Future<List<_AttendanceRecord>> _loadAttendance(
    StudentModel student,
  ) async {
    if (student.numericId == null) return const [];
    final snapshot = await FirebaseFirestore.instance
        .collection('attendances')
        .where('student_id', isEqualTo: student.numericId)
        .get();
    final records = snapshot.docs
        .map((doc) => _AttendanceRecord(doc.data()))
        .toList();
    records.sort((a, b) => a.date.compareTo(b.date));
    return records;
  }

  static Future<bool> _shareBytes(Uint8List bytes, String fileName) async {
    try {
      if (kIsWeb) {
        return openPdfInBrowser(bytes: bytes, fileName: fileName);
      }
      final file = XFile.fromData(
        bytes,
        name: fileName,
        mimeType: 'application/pdf',
      );
      await Share.shareXFiles([file], text: fileName.replaceAll('_', ' '));
      return true;
    } catch (error, stackTrace) {
      debugPrint('Student PDF share failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }

  static String _fileName(String type, StudentModel student) {
    final safeName = _safeFilePart(student.displayName);
    return 'MakTutorials_${type}_$safeName.pdf';
  }

  static String _safeFilePart(String value) {
    final clean = value.trim().isEmpty ? 'Student' : value.trim();
    return clean
        .replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_');
  }

  static String _value(String? value, {String fallback = 'Not available'}) {
    final clean = value?.trim() ?? '';
    return clean.isEmpty ? fallback : _pdfText(clean);
  }

  static String _money(double value, String currency) {
    final cleanCurrency = _pdfText(currency).trim().isEmpty
        ? 'Rs'
        : _pdfText(currency);
    return '$cleanCurrency ${value.toStringAsFixed(2)}';
  }

  static String _dateText(DateTime? date) {
    if (date == null) return 'Not available';
    return DateFormat('dd MMM yyyy').format(date);
  }

  static double _amount(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  static int? _int(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static DateTime? _date(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value.trim());
    return null;
  }

  static String _string(dynamic value) => value?.toString().trim() ?? '';

  static String _pdfText(String value) {
    final normalized = value
        .replaceAll('₹', 'Rs')
        .replaceAll('â‚¹', 'Rs')
        .replaceAll('–', '-')
        .replaceAll('—', '-')
        .replaceAll('‘', "'")
        .replaceAll('’', "'")
        .replaceAll('“', '"')
        .replaceAll('”', '"')
        .replaceAll('•', '-');
    return normalized.replaceAll(RegExp(r'[^\x09\x0A\x0D\x20-\x7E]'), '?');
  }
}

class _PdfContext {
  const _PdfContext({
    required this.settings,
    required this.logo,
    required this.signature,
    required this.currency,
  });

  final dynamic settings;
  final pw.MemoryImage? logo;
  final pw.MemoryImage? signature;
  final String currency;
}

class _EnrollmentRecord {
  const _EnrollmentRecord(this.data);

  final Map<String, dynamic> data;

  double get courseFeeReference => StudentPdfService._amount(
    data['courseFee'] ??
        data['course_fee'] ??
        data['defaultFee'] ??
        data['totalFee'],
  );
  double get discount =>
      StudentPdfService._amount(data['discount'] ?? data['discount_amount']);
  double get finalFee => StudentPdfService._amount(
    data['finalFee'] ??
        data['finalFees'] ??
        data['final_fees'] ??
        data['totalFee'],
  );
  String get planType => StudentPdfService._value(
    data['paymentStructure']?.toString() ??
        data['planType']?.toString() ??
        data['plan_type']?.toString(),
  );
  int? get installmentCount => StudentPdfService._int(
    data['installmentCount'] ?? data['installment_count'],
  );
  DateTime? get startDate =>
      StudentPdfService._date(data['startDate'] ?? data['start_date']);
  DateTime? get nextDueDate =>
      StudentPdfService._date(data['nextDueDate'] ?? data['next_due_date']);
  String get status {
    final value = data['status']?.toString();
    if (value != null && value.trim().isNotEmpty) return value;
    final active = data['isActive'] ?? data['is_active'];
    if (active is bool) return active ? 'Active' : 'Inactive';
    return 'Not available';
  }

  String get notes => StudentPdfService._string(data['notes']);
}

class _FeeRecord {
  const _FeeRecord(this.data);

  final Map<String, dynamic> data;

  int? get installmentNo =>
      StudentPdfService._int(data['installmentNo'] ?? data['installment_no']);
  bool get isReceipt =>
      data['recordType']?.toString() == 'receipt' ||
      data['feeType']?.toString() == 'receipt';
  String get status => data['status']?.toString().toLowerCase() ?? 'pending';
  bool get isPending => status == 'pending';
  bool get isPaid => status == 'paid' || status == 'partially_paid';
  bool get hasPayment => paidAmount > 0 && (isPaid || receiptNo != 'Receipt');
  double get paidAmount => StudentPdfService._amount(
    data['amount_paid'] ??
        data['amount'] ??
        data['amountPaid'] ??
        data['paid_amount'] ??
        data['totalPaid'],
  );
  double get totalAmount => StudentPdfService._amount(
    data['total_amount'] ??
        data['totalFee'] ??
        data['finalFee'] ??
        data['final_fees'],
  );
  double get pendingAmount => StudentPdfService._amount(
    data['dueAmount'] ??
        data['pendingAmount'] ??
        data['balance'] ??
        data['remaining'] ??
        data['total_amount'],
  );
  double get installmentAmount =>
      isPaid ? totalAmount : totalAmount + paidAmount;
  DateTime? get dueDate => StudentPdfService._date(
    data['dueDate'] ??
        data['due_date'] ??
        data['nextDueDate'] ??
        data['next_due_date'],
  );
  DateTime? get paymentDate => StudentPdfService._date(
    data['paymentDate'] ??
        data['payment_date'] ??
        data['paidDate'] ??
        data['createdAt'] ??
        data['created_at'],
  );
  String get receiptNo =>
      StudentPdfService._string(
        data['receiptNo'] ?? data['receipt_number'],
      ).isEmpty
      ? 'Receipt'
      : StudentPdfService._string(data['receiptNo'] ?? data['receipt_number']);
  String get paymentMode => StudentPdfService._value(
    data['paymentMode']?.toString() ??
        data['payment_mode']?.toString() ??
        data['mode']?.toString(),
    fallback: 'Cash',
  );
  String get receivedBy => StudentPdfService._value(
    data['receivedByName']?.toString() ??
        data['received_by_name']?.toString() ??
        data['receivedBy']?.toString(),
  );
  String get remarks => StudentPdfService._string(
    data['remarks'] ?? data['transaction_id'] ?? data['note'],
  );
  String get displayStatus {
    if (isPaid) return 'Paid';
    if (paidAmount > 0 && pendingAmount > 0) return 'Partial';
    return 'Pending';
  }
}

class _FeeStatement {
  const _FeeStatement({
    required this.totalFee,
    required this.totalPaid,
    required this.pending,
    required this.payments,
  });

  final double totalFee;
  final double totalPaid;
  final double pending;
  final List<_FeeRecord> payments;

  String get status {
    if (pending <= 0 && totalFee > 0) return 'Paid';
    if (totalPaid > 0 && pending > 0) return 'Partial';
    return 'Pending';
  }

  factory _FeeStatement.fromRecords(List<_FeeRecord> records) {
    final totalFee = records.fold<double>(
      0,
      (total, record) => record.isReceipt ? total : total + record.totalAmount,
    );
    final totalPaid = records
        .where((record) => !record.isReceipt)
        .fold<double>(0, (total, record) => total + record.paidAmount);
    final pending = records
        .where((record) => record.isPending)
        .fold<double>(0, (total, record) => total + record.pendingAmount);
    final receiptRecordNos = records
        .where((record) => record.isReceipt && record.paidAmount > 0)
        .map((record) => record.receiptNo)
        .toSet();
    final payments =
        records
            .where(
              (record) =>
                  record.hasPayment &&
                  (record.isReceipt ||
                      !receiptRecordNos.contains(record.receiptNo)),
            )
            .toList()
          ..sort((a, b) {
            final aDate = a.paymentDate ?? DateTime(2000);
            final bDate = b.paymentDate ?? DateTime(2000);
            return bDate.compareTo(aDate);
          });
    return _FeeStatement(
      totalFee: totalFee,
      totalPaid: totalPaid,
      pending: pending,
      payments: payments,
    );
  }
}

class _AttendanceRecord {
  const _AttendanceRecord(this.data);

  final Map<String, dynamic> data;

  DateTime get date =>
      StudentPdfService._date(data['date'] ?? data['dateKey']) ??
      DateTime.now();
  AttendanceStatus get status => AttendanceModel.parseStatus(data['status']);
  String get markedByName => StudentPdfService._value(
    data['markedByName']?.toString() ??
        data['marked_by_name']?.toString() ??
        data['markedBy']?.toString(),
  );
  String get statusLabel {
    return switch (status) {
      AttendanceStatus.present => 'Present',
      AttendanceStatus.absent => 'Absent',
      AttendanceStatus.late => 'Late',
      AttendanceStatus.leave => 'Leave',
    };
  }
}

class _AttendancePdfSummary {
  const _AttendancePdfSummary({
    required this.total,
    required this.present,
    required this.absent,
    required this.late,
    required this.leave,
    required this.absentDates,
  });

  final int total;
  final int present;
  final int absent;
  final int late;
  final int leave;
  final List<DateTime> absentDates;

  double get percentage => total == 0 ? 0 : (present / total) * 100;
  String get absentDatesText {
    if (absentDates.isEmpty) return 'Not available';
    return absentDates
        .map((date) => DateFormat('dd MMM yyyy').format(date))
        .join(', ');
  }

  factory _AttendancePdfSummary.fromRecords(List<_AttendanceRecord> records) {
    final absentDates =
        records
            .where((record) => record.status == AttendanceStatus.absent)
            .map((record) => record.date)
            .toList()
          ..sort();
    return _AttendancePdfSummary(
      total: records.length,
      present: records
          .where((record) => record.status == AttendanceStatus.present)
          .length,
      absent: absentDates.length,
      late: records
          .where((record) => record.status == AttendanceStatus.late)
          .length,
      leave: records
          .where((record) => record.status == AttendanceStatus.leave)
          .length,
      absentDates: absentDates,
    );
  }
}
