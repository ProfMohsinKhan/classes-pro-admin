import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../models/receipt_model.dart';
import 'institute_settings_service.dart';
import 'pdf_browser_service.dart';

class ReceiptPdfService {
  const ReceiptPdfService._();

  static Future<Uint8List> generatePdfBytes(ReceiptModel receipt) async {
    final settings = await InstituteSettingsService.instance.loadSettings();
    final logoUrl = _prefer(settings.logoUrl, receipt.logoUrl);
    final signatureUrl = _prefer(settings.signatureUrl, receipt.signatureUrl);
    final logo = await _loadNetworkImage(logoUrl);
    final signature = await _loadNetworkImage(signatureUrl);

    final instituteName = _cleanPdfText(
      _prefer(settings.instituteName, receipt.instituteName),
    );
    final instituteAddress = _cleanPdfText(
      _prefer(settings.address, receipt.instituteAddress),
    );
    final institutePhone = _cleanPdfText(
      _prefer(settings.phone, receipt.institutePhone),
    );
    final instituteEmail = _cleanPdfText(
      _prefer(settings.email, receipt.instituteEmail),
    );
    final footer = _cleanPdfText(
      _prefer(settings.receiptFooter, receipt.receiptFooter),
    );
    final currency = _pdfCurrencySafe(
      _prefer(settings.currencySymbol, receipt.currencySymbol),
    );
    final academicYear = _cleanPdfText(
      _prefer(settings.academicYear, receipt.academicYear),
    );

    final pdf = pw.Document();
    final primary = PdfColor.fromHex('#1D4ED8');
    final primarySoft = PdfColor.fromHex('#EFF6FF');
    final success = PdfColor.fromHex('#047857');
    final successSoft = PdfColor.fromHex('#ECFDF5');
    final text = PdfColor.fromHex('#0F172A');
    final muted = PdfColor.fromHex('#64748B');
    final border = PdfColor.fromHex('#CBD5E1');
    final surface = PdfColor.fromHex('#F8FAFC');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              border: pw.Border.all(color: border, width: 0.8),
            ),
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(22),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _header(
                    logo: logo,
                    instituteName: instituteName,
                    address: instituteAddress,
                    phone: institutePhone,
                    email: instituteEmail,
                    receipt: receipt,
                    primary: primary,
                    primarySoft: primarySoft,
                    text: text,
                    muted: muted,
                    border: border,
                  ),
                  pw.SizedBox(height: 18),
                  _amountBanner(receipt, currency, success, successSoft),
                  pw.SizedBox(height: 18),
                  _sectionTitle('Student Details', text),
                  pw.SizedBox(height: 8),
                  _detailGrid(
                    [
                      ('Student Name', _cleanPdfText(receipt.studentName)),
                      ('Parent Name', _dash(receipt.parentName)),
                      (
                        'Phone',
                        _dash(receipt.studentPhone ?? receipt.parentPhone),
                      ),
                      ('Parent Phone', _dash(receipt.parentPhone)),
                      ('Course', _cleanPdfText(receipt.courseName)),
                      ('Batch', _cleanPdfText(receipt.batchName)),
                      ('Academic Year', _dash(academicYear)),
                    ],
                    border,
                    surface,
                    text,
                    muted,
                  ),
                  pw.SizedBox(height: 18),
                  _sectionTitle('Payment Details', text),
                  pw.SizedBox(height: 8),
                  _paymentTable(
                    receipt,
                    currency,
                    primary,
                    border,
                    text,
                    muted,
                  ),
                  if (receipt.remarks.trim().isNotEmpty) ...[
                    pw.SizedBox(height: 12),
                    _remarkBox(receipt.remarks, border, surface, text, muted),
                  ],
                  pw.Spacer(),
                  _signatureSection(
                    signature: signature,
                    instituteName: instituteName,
                    border: border,
                    text: text,
                    muted: muted,
                  ),
                  pw.SizedBox(height: 12),
                  pw.Divider(color: border, thickness: 0.7),
                  pw.SizedBox(height: 6),
                  _footer(footer, muted),
                ],
              ),
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<bool> shareReceipt(ReceiptModel receipt) async {
    try {
      final settings = await InstituteSettingsService.instance.loadSettings();
      final instituteName = _prefer(
        settings.instituteName,
        receipt.instituteName,
      );
      final bytes = await generatePdfBytes(receipt);
      if (kIsWeb) {
        return openPdfInBrowser(bytes: bytes, fileName: receipt.safeFileName);
      }
      final file = XFile.fromData(
        bytes,
        name: receipt.safeFileName,
        mimeType: 'application/pdf',
      );
      await Share.shareXFiles([
        file,
      ], text: '$instituteName fee receipt ${receipt.receiptNo}');
      return true;
    } catch (error, stackTrace) {
      debugPrint('Receipt sharing failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }

  static pw.Widget _header({
    required pw.MemoryImage? logo,
    required String instituteName,
    required String address,
    required String phone,
    required String email,
    required ReceiptModel receipt,
    required PdfColor primary,
    required PdfColor primarySoft,
    required PdfColor text,
    required PdfColor muted,
    required PdfColor border,
  }) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _logoBox(logo, primary, primarySoft, border),
        pw.SizedBox(width: 12),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                instituteName.isEmpty ? 'Mak Tutorials' : instituteName,
                style: pw.TextStyle(
                  color: text,
                  fontSize: 21,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              if (address.isNotEmpty)
                pw.Text(
                  _cleanPdfText(address),
                  style: pw.TextStyle(color: muted, fontSize: 9),
                ),
              if (phone.isNotEmpty || email.isNotEmpty)
                pw.Text(
                  _cleanPdfText(
                    [
                      if (phone.isNotEmpty) 'Phone: $phone',
                      if (email.isNotEmpty) 'Email: $email',
                    ].join(' | '),
                  ),
                  style: pw.TextStyle(color: muted, fontSize: 9),
                ),
            ],
          ),
        ),
        pw.SizedBox(width: 14),
        pw.Container(
          width: 150,
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: primarySoft,
            border: pw.Border.all(color: primary),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'FEE RECEIPT',
                style: pw.TextStyle(
                  color: primary,
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              _smallMeta(
                'Receipt No',
                _cleanPdfText(receipt.receiptNo),
                text,
                muted,
              ),
              pw.SizedBox(height: 5),
              _smallMeta(
                'Receipt Date',
                receipt.formattedPaymentDate,
                text,
                muted,
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _logoBox(
    pw.MemoryImage? logo,
    PdfColor primary,
    PdfColor primarySoft,
    PdfColor border,
  ) {
    return pw.Container(
      width: 62,
      height: 62,
      alignment: pw.Alignment.center,
      decoration: pw.BoxDecoration(
        color: primarySoft,
        border: pw.Border.all(color: border),
      ),
      child: logo == null
          ? pw.Text(
              'MT',
              style: pw.TextStyle(
                color: primary,
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            )
          : pw.Image(logo, fit: pw.BoxFit.contain),
    );
  }

  static pw.Widget _amountBanner(
    ReceiptModel receipt,
    String currency,
    PdfColor success,
    PdfColor successSoft,
  ) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: pw.BoxDecoration(
        color: successSoft,
        border: pw.Border.all(color: success, width: 0.7),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Amount Received',
            style: pw.TextStyle(
              color: success,
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            _money(receipt.amountPaid, currency),
            style: pw.TextStyle(
              color: success,
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _detailGrid(
    List<(String, String)> rows,
    PdfColor border,
    PdfColor surface,
    PdfColor text,
    PdfColor muted,
  ) {
    return pw.Wrap(
      spacing: 8,
      runSpacing: 8,
      children: rows.map((row) {
        return pw.Container(
          width: 157,
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            color: surface,
            border: pw.Border.all(color: border, width: 0.6),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(row.$1, style: pw.TextStyle(color: muted, fontSize: 8)),
              pw.SizedBox(height: 3),
              pw.Text(
                row.$2,
                style: pw.TextStyle(
                  color: text,
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

  static pw.Widget _paymentTable(
    ReceiptModel receipt,
    String currency,
    PdfColor primary,
    PdfColor border,
    PdfColor text,
    PdfColor muted,
  ) {
    final rows = <(String, String)>[
      ('Total Fee', _money(receipt.totalFee, currency)),
      ('Amount Paid', _money(receipt.amountPaid, currency)),
      ('Payment Mode', _dash(receipt.paymentMode)),
      ('Payment Date', _cleanPdfText(receipt.formattedPaymentDate)),
      ('Installment No', receipt.installmentNo?.toString() ?? '-'),
      (
        'Pending Amount After Payment',
        _money(receipt.pendingAfterPayment, currency),
      ),
      ('Total Paid', _money(receipt.totalPaid, currency)),
      ('Received By', _dash(receipt.receivedByName)),
    ];

    return pw.Table(
      border: pw.TableBorder.all(color: border, width: 0.6),
      columnWidths: const {
        0: pw.FlexColumnWidth(1.15),
        1: pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: primary),
          children: [
            _tableCell('Particular', PdfColors.white, true),
            _tableCell('Details', PdfColors.white, true),
          ],
        ),
        ...rows.map(
          (row) => pw.TableRow(
            children: [
              _tableCell(row.$1, muted, false),
              _tableCell(row.$2, text, true),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _remarkBox(
    String remarks,
    PdfColor border,
    PdfColor surface,
    PdfColor text,
    PdfColor muted,
  ) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: surface,
        border: pw.Border.all(color: border, width: 0.6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Remarks', style: pw.TextStyle(color: muted, fontSize: 8)),
          pw.SizedBox(height: 3),
          pw.Text(
            _cleanPdfText(remarks),
            style: pw.TextStyle(color: text, fontSize: 9.5),
          ),
        ],
      ),
    );
  }

  static pw.Widget _signatureSection({
    required pw.MemoryImage? signature,
    required String instituteName,
    required PdfColor border,
    required PdfColor text,
    required PdfColor muted,
  }) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Expanded(
          child: pw.Text(
            'Student/Parent Copy\nThank you',
            style: pw.TextStyle(color: muted, fontSize: 10),
          ),
        ),
        pw.Container(
          width: 170,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              if (signature != null)
                pw.Image(
                  signature,
                  width: 120,
                  height: 42,
                  fit: pw.BoxFit.contain,
                )
              else
                pw.SizedBox(height: 42),
              pw.Container(height: 1, width: 150, color: border),
              pw.SizedBox(height: 4),
              pw.Text(
                'Authorized Signature',
                style: pw.TextStyle(
                  color: text,
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                instituteName.isEmpty ? 'Mak Tutorials' : instituteName,
                style: pw.TextStyle(color: muted, fontSize: 8.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _footer(String footer, PdfColor muted) {
    final lines = [
      footer.isEmpty ? 'This is a computer-generated receipt.' : footer,
      'Generated by Mak Tutorials Classes Management App',
    ];
    return pw.Center(
      child: pw.Column(
        children: lines
            .map(
              (line) => pw.Text(
                _cleanPdfText(line),
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(color: muted, fontSize: 8.5),
              ),
            )
            .toList(),
      ),
    );
  }

  static pw.Widget _sectionTitle(String title, PdfColor color) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        color: color,
        fontSize: 12.5,
        fontWeight: pw.FontWeight.bold,
      ),
    );
  }

  static pw.Widget _tableCell(String value, PdfColor color, bool bold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      child: pw.Text(
        _cleanPdfText(value),
        style: pw.TextStyle(
          color: color,
          fontSize: 9.5,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static pw.Widget _smallMeta(
    String label,
    String value,
    PdfColor text,
    PdfColor muted,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Text(label, style: pw.TextStyle(color: muted, fontSize: 8)),
        pw.Text(
          _cleanPdfText(value),
          textAlign: pw.TextAlign.right,
          style: pw.TextStyle(
            color: text,
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  static Future<pw.MemoryImage?> _loadNetworkImage(String imageUrl) async {
    final cleanUrl = imageUrl.trim();
    if (cleanUrl.isEmpty) return null;
    try {
      final response = await http.get(Uri.parse(cleanUrl));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }
      return pw.MemoryImage(response.bodyBytes);
    } catch (error) {
      debugPrint('Receipt PDF image not available: $cleanUrl ($error)');
      return null;
    }
  }

  static String _prefer(String primary, String fallback) {
    final cleanPrimary = primary.trim();
    if (cleanPrimary.isNotEmpty) return cleanPrimary;
    final cleanFallback = fallback.trim();
    return cleanFallback;
  }

  static String _dash(String? value) {
    final clean = value?.trim() ?? '';
    return clean.isEmpty ? '-' : _cleanPdfText(clean);
  }

  static String _money(double value, String currency) {
    return '${_pdfCurrencySafe(currency)} ${value.toStringAsFixed(2)}';
  }

  static String _pdfCurrencySafe(String value) {
    final clean = value.trim();
    if (clean.isEmpty || clean == 'Rs') return 'Rs';
    if (clean.contains('₹') || clean.contains('â')) return 'Rs';
    return _cleanPdfText(clean);
  }

  static String _cleanPdfText(String value) {
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

  // ignore: unused_element
  static String _pdfCurrency(String value) {
    final clean = value.trim();
    if (clean.isEmpty || clean == '₹') return 'Rs';
    return clean;
  }
}
