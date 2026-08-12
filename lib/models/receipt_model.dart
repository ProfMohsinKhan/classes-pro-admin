import 'package:intl/intl.dart';

class ReceiptModel {
  const ReceiptModel({
    required this.instituteName,
    required this.instituteAddress,
    required this.institutePhone,
    required this.instituteEmail,
    required this.logoUrl,
    required this.signatureUrl,
    required this.receiptFooter,
    required this.currencySymbol,
    required this.receiptNo,
    required this.studentName,
    required this.courseName,
    required this.batchName,
    required this.academicYear,
    required this.amountPaid,
    required this.paymentMode,
    required this.paymentDate,
    required this.remarks,
    required this.receivedByName,
    required this.pendingAfterPayment,
    required this.totalFee,
    required this.totalPaid,
    required this.generatedAt,
    this.studentPhone,
    this.parentName,
    this.parentPhone,
    this.installmentNo,
  });

  final String instituteName;
  final String instituteAddress;
  final String institutePhone;
  final String instituteEmail;
  final String logoUrl;
  final String signatureUrl;
  final String receiptFooter;
  final String currencySymbol;
  final String receiptNo;
  final String studentName;
  final String? studentPhone;
  final String? parentName;
  final String? parentPhone;
  final String courseName;
  final String batchName;
  final String academicYear;
  final double amountPaid;
  final String paymentMode;
  final DateTime? paymentDate;
  final int? installmentNo;
  final String remarks;
  final String receivedByName;
  final double pendingAfterPayment;
  final double totalFee;
  final double totalPaid;
  final DateTime generatedAt;

  String get safeFileName {
    final safeReceipt = receiptNo.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    return 'MakTutorials_Receipt_$safeReceipt.pdf';
  }

  String get formattedPaymentDate {
    final date = paymentDate ?? generatedAt;
    return DateFormat('dd MMM yyyy').format(date);
  }

  String get formattedGeneratedAt {
    return DateFormat('dd MMM yyyy, hh:mm a').format(generatedAt);
  }
}
