import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart'
    as http; // 🚀 NAYA: Image download karne ke liye
import 'institute_settings_service.dart';

class PdfInvoiceService {
  static Future<void> generateAndShareReceipt({
    required Map<String, dynamic> feeData,
    required String studentName,
  }) async {
    // 1. Fetch Institute Profile (Settings)
    DocumentSnapshot settingsDoc = await FirebaseFirestore.instance
        .collection('settings')
        .doc('institute_profile')
        .get();
    Map<String, dynamic> inst = settingsDoc.exists
        ? settingsDoc.data() as Map<String, dynamic>
        : {};
    final settings = await InstituteSettingsService.instance.loadSettings();

    String instName = settings.instituteName.isNotEmpty
        ? settings.instituteName
        : inst['institute_name'] ?? 'Mak Tutorials';
    String instAddress = settings.address.isNotEmpty
        ? settings.address
        : inst['address'] ?? 'Not Provided';
    String instContact = settings.phone.isNotEmpty
        ? settings.phone
        : inst['contact_number'] ?? 'Not Provided';
    String instEmail = settings.email.isNotEmpty
        ? settings.email
        : inst['email'] ?? 'Not Provided';
    final currency = settings.currencySymbol.isNotEmpty
        ? settings.currencySymbol
        : 'Rs';

    // 🚀 NAYA: Fetch Logo & Signature Images as Bytes
    pw.MemoryImage? logoImage;
    pw.MemoryImage? signatureImage;

    try {
      if (inst['logo_url'] != null && inst['logo_url'].toString().isNotEmpty) {
        var response = await http.get(Uri.parse(inst['logo_url']));
        if (response.statusCode == 200) {
          logoImage = pw.MemoryImage(response.bodyBytes);
        }
      }
      if (inst['signature_url'] != null &&
          inst['signature_url'].toString().isNotEmpty) {
        var response = await http.get(Uri.parse(inst['signature_url']));
        if (response.statusCode == 200) {
          signatureImage = pw.MemoryImage(response.bodyBytes);
        }
      }
    } catch (e) {
      debugPrint("Error loading PDF images: $e");
    }

    // 2. Fetch Enrollment & Calculate Exact Balances
    int enrollmentId = (feeData['enrollment_id'] as num?)?.toInt() ?? 0;
    double totalCourseFee = 0.0;
    double totalPaidTillDate = 0.0;

    if (enrollmentId != 0) {
      var enrollments = await FirebaseFirestore.instance
          .collection('enrollments')
          .where('id', isEqualTo: enrollmentId)
          .limit(1)
          .get();
      if (enrollments.docs.isNotEmpty) {
        totalCourseFee =
            double.tryParse(
              enrollments.docs.first['final_fees']?.toString() ?? '0',
            ) ??
            0.0;
      }

      var allFees = await FirebaseFirestore.instance
          .collection('fee_payments')
          .where('enrollment_id', isEqualTo: enrollmentId)
          .where('status', whereIn: ['paid', 'partially_paid'])
          .get();
      for (var doc in allFees.docs) {
        totalPaidTillDate +=
            double.tryParse(doc['amount_paid']?.toString() ?? '0') ?? 0.0;
      }
    } else {
      totalCourseFee =
          double.tryParse(feeData['total_amount']?.toString() ?? '0') ?? 0.0;
      totalPaidTillDate = totalCourseFee;
    }

    double remainingBalance = totalCourseFee - totalPaidTillDate;
    if (remainingBalance < 0) remainingBalance = 0;

    String paymentDate = feeData['payment_date'] != null
        ? DateFormat(
            'dd MMM yyyy, hh:mm a',
          ).format(DateTime.parse(feeData['payment_date']))
        : DateFormat('dd MMM yyyy').format(DateTime.now());

    // 3. Build The PDF Document
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // --- HEADER SECTION ---
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        // 🚀 NAYA: Logo Rendering
                        if (logoImage != null) ...[
                          pw.Image(logoImage, width: 60, height: 60),
                          pw.SizedBox(width: 15),
                        ],
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                instName.toUpperCase(),
                                style: pw.TextStyle(
                                  fontSize: 22,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.blue900,
                                ),
                              ),
                              pw.SizedBox(height: 5),
                              pw.Text(
                                instAddress,
                                style: const pw.TextStyle(
                                  fontSize: 10,
                                  color: PdfColors.grey800,
                                ),
                              ),
                              pw.Text(
                                "Phone: $instContact | Email: $instEmail",
                                style: const pw.TextStyle(
                                  fontSize: 10,
                                  color: PdfColors.grey800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        "FEE RECEIPT",
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.teal800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        "Receipt No: ${feeData['receipt_number'] ?? 'N/A'}",
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        "Date: $paymentDate",
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(color: PdfColors.grey400, thickness: 1.5),
              pw.SizedBox(height: 20),

              // --- STUDENT PROFILE SECTION ---
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(8),
                  ),
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          "Received From:",
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.Text(
                          studentName.toUpperCase(),
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          "Payment Mode:",
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.Text(
                          feeData['payment_mode']?.toString().toUpperCase() ??
                              'N/A',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        if (feeData['transaction_id'] != null &&
                            feeData['transaction_id'].toString().isNotEmpty)
                          pw.Text(
                            "Txn ID: ${feeData['transaction_id']}",
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),

              // --- PAYMENT TABLE ---
              pw.TableHelper.fromTextArray(
                headers: ['Description / Particulars', 'Amount Paid'],
                data: [
                  [
                    "Fees for ${feeData['month_year'] ?? 'Full Course'}",
                    "$currency ${feeData['amount_paid'] ?? '0.00'}",
                  ],
                ],
                headerStyle: pw.TextStyle(
                  color: PdfColors.white,
                  fontWeight: pw.FontWeight.bold,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.blue900,
                ),
                rowDecoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.grey300),
                  ),
                ),
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerRight,
                },
                cellPadding: const pw.EdgeInsets.all(10),
              ),
              pw.SizedBox(height: 30),

              // --- BALANCE SUMMARY SECTION ---
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 250,
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey400),
                    ),
                    child: pw.Column(
                      children: [
                        _buildSummaryRow(
                          "Total Course Fees:",
                          totalCourseFee,
                          currency,
                        ),
                        pw.SizedBox(height: 5),
                        _buildSummaryRow(
                          "Total Paid Till Date:",
                          totalPaidTillDate,
                          currency,
                        ),
                        pw.Divider(color: PdfColors.grey400),
                        pw.SizedBox(height: 5),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              "Remaining Balance:",
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.red800,
                              ),
                            ),
                            pw.Text(
                              "$currency ${remainingBalance.toStringAsFixed(2)}",
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.red800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.Spacer(),

              // --- FOOTER SECTION ---
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    "Thank you for choosing us!",
                    style: pw.TextStyle(
                      fontStyle: pw.FontStyle.italic,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      // 🚀 NAYA: Signature Rendering
                      if (signatureImage != null)
                        pw.Image(signatureImage, width: 100, height: 40)
                      else
                        pw.Container(
                          width: 120,
                          height: 1,
                          color: PdfColors.black,
                        ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        "Authorized Signatory",
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    // 4. Share without saving to database
    Uint8List bytes = await pdf.save();
    String safeName = studentName.replaceAll(" ", "_").toLowerCase();
    XFile file = XFile.fromData(
      bytes,
      name: 'Receipt_${safeName}_${feeData['receipt_number']}.pdf',
      mimeType: 'application/pdf',
    );

    await Share.shareXFiles([
      file,
    ], text: 'Hello, PFA the fee receipt for $studentName.');
  }

  static pw.Widget _buildSummaryRow(
    String label,
    double amount,
    String currency,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
        pw.Text(
          "$currency ${amount.toStringAsFixed(2)}",
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }
}
