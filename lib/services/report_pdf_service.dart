import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import 'institute_settings_service.dart';
import 'report_service.dart';

class ReportPdfService {
  const ReportPdfService._();

  static Future<bool> sharePdf(ReportResult report) async {
    try {
      final bytes = await _buildPdf(report);
      final file = XFile.fromData(
        bytes,
        name: _fileName(report, 'pdf'),
        mimeType: 'application/pdf',
      );
      await Share.shareXFiles([
        file,
      ], text: '${report.title} - ${report.subtitle}');
      return true;
    } catch (error, stackTrace) {
      debugPrint('Report PDF sharing failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }

  static Future<bool> shareCsv(ReportResult report) async {
    try {
      final settings = await InstituteSettingsService.instance.loadSettings();
      final csv = _buildCsv(report, settings.instituteName);
      await Share.share(csv, subject: _fileName(report, 'csv'));
      return true;
    } catch (error, stackTrace) {
      debugPrint('Report CSV sharing failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }

  static Future<Uint8List> _buildPdf(ReportResult report) async {
    final settings = await InstituteSettingsService.instance.loadSettings();
    final instituteName = settings.instituteName;
    final footer = settings.reportFooter;
    final pdf = pw.Document();
    final blue = PdfColor.fromHex('#2563EB');
    final navy = PdfColor.fromHex('#0F172A');
    final muted = PdfColor.fromHex('#64748B');
    final border = PdfColor.fromHex('#E2E8F0');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    instituteName,
                    style: pw.TextStyle(
                      color: navy,
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(report.title, style: pw.TextStyle(color: blue)),
                  pw.Text(report.subtitle, style: pw.TextStyle(color: muted)),
                  if (settings.address.isNotEmpty)
                    pw.Text(
                      settings.address,
                      style: pw.TextStyle(color: muted, fontSize: 9),
                    ),
                  if (settings.phone.isNotEmpty)
                    pw.Text(
                      'Phone: ${settings.phone}',
                      style: pw.TextStyle(color: muted, fontSize: 9),
                    ),
                ],
              ),
              pw.Text(
                DateFormat('dd MMM yyyy, hh:mm a').format(report.generatedAt),
                style: pw.TextStyle(color: muted, fontSize: 9),
              ),
            ],
          ),
          pw.SizedBox(height: 18),
          pw.Wrap(
            spacing: 8,
            runSpacing: 8,
            children: report.metrics.map((metric) {
              return pw.Container(
                width: 145,
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: border),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(8),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      metric.label,
                      style: pw.TextStyle(color: muted, fontSize: 9),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      metric.value,
                      style: pw.TextStyle(
                        color: navy,
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          pw.SizedBox(height: 18),
          if (report.rows.isEmpty)
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: border),
              ),
              child: pw.Text(
                'No report data found for this period.',
                style: pw.TextStyle(color: muted),
              ),
            )
          else
            pw.TableHelper.fromTextArray(
              headers: report.columns,
              data: report.rows,
              headerDecoration: pw.BoxDecoration(color: blue),
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
                fontSize: 8,
              ),
              cellStyle: pw.TextStyle(color: navy, fontSize: 7),
              cellPadding: const pw.EdgeInsets.all(5),
              border: pw.TableBorder.all(color: border),
            ),
          pw.SizedBox(height: 18),
          pw.Center(
            child: pw.Text(
              footer,
              style: pw.TextStyle(color: muted, fontSize: 9),
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static String _buildCsv(ReportResult report, String instituteName) {
    final buffer = StringBuffer();
    buffer.writeln(instituteName);
    buffer.writeln(report.title);
    buffer.writeln(report.subtitle);
    buffer.writeln(
      'Generated,${DateFormat('dd MMM yyyy hh:mm a').format(report.generatedAt)}',
    );
    buffer.writeln();
    buffer.writeln(
      report.metrics.map((metric) => _escape(metric.label)).join(','),
    );
    buffer.writeln(
      report.metrics.map((metric) => _escape(metric.value)).join(','),
    );
    buffer.writeln();
    buffer.writeln(report.columns.map(_escape).join(','));
    for (final row in report.rows) {
      buffer.writeln(row.map(_escape).join(','));
    }
    return buffer.toString();
  }

  static String _escape(String value) {
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }

  static String _fileName(ReportResult report, String extension) {
    final date = DateFormat('yyyyMMdd').format(report.generatedAt);
    final type = report.title.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_');
    return 'MakTutorials_Report_${type}_$date.$extension';
  }
}
