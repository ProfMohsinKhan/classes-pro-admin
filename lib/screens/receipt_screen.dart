import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/receipt_model.dart';
import '../services/receipt_pdf_service.dart';
import '../theme/app_theme.dart';

class ReceiptScreen extends StatefulWidget {
  const ReceiptScreen({super.key, required this.receipt});

  final ReceiptModel receipt;

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  bool _isSharing = false;

  @override
  Widget build(BuildContext context) {
    final receipt = widget.receipt;
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Receipt')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ReceiptCard(receipt: receipt),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSharing ? null : _shareReceipt,
                  icon: _isSharing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.ios_share_rounded),
                  label: const Text(
                    'Share Receipt PDF',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: const BorderSide(color: AppTheme.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Back to Fee Detail'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _shareReceipt() async {
    setState(() => _isSharing = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final shared = await ReceiptPdfService.shareReceipt(widget.receipt);
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            shared
                ? 'Receipt PDF ready to share.'
                : 'Receipt generated, sharing is not supported on this platform.',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: shared ? AppTheme.success : AppTheme.warning,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }
}

class _ReceiptCard extends StatelessWidget {
  const _ReceiptCard({required this.receipt});

  final ReceiptModel receipt;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 58,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.border),
                ),
                child: receipt.logoUrl.trim().isEmpty
                    ? const Center(
                        child: Text(
                          'MT',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      )
                    : Image.network(
                        receipt.logoUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                              child: Text(
                                'MT',
                                style: TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      receipt.instituteName,
                      style: TextStyle(
                        color: AppTheme.text,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Fee Receipt',
                      style: TextStyle(color: AppTheme.muted),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  receipt.receiptNo,
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _ReceiptAmount(
            amount: receipt.amountPaid,
            currencySymbol: receipt.currencySymbol,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InfoTile('Student', receipt.studentName),
              if ((receipt.parentName ?? '').trim().isNotEmpty)
                _InfoTile('Parent', receipt.parentName!),
              if ((receipt.studentPhone ?? '').trim().isNotEmpty)
                _InfoTile('Phone', receipt.studentPhone!),
              if ((receipt.parentPhone ?? '').trim().isNotEmpty)
                _InfoTile('Parent Phone', receipt.parentPhone!),
              _InfoTile('Course', receipt.courseName),
              _InfoTile('Batch', receipt.batchName),
              if (receipt.academicYear.trim().isNotEmpty)
                _InfoTile('Academic Year', receipt.academicYear),
              _InfoTile('Mode', receipt.paymentMode),
              _InfoTile(
                'Date',
                DateFormat(
                  'dd MMM yyyy',
                ).format(receipt.paymentDate ?? receipt.generatedAt),
              ),
              _InfoTile('Received By', receipt.receivedByName),
              _InfoTile(
                'Total Fee',
                _money(receipt.totalFee, receipt.currencySymbol),
              ),
              _InfoTile(
                'Total Paid',
                _money(receipt.totalPaid, receipt.currencySymbol),
              ),
              _InfoTile(
                'Pending',
                _money(receipt.pendingAfterPayment, receipt.currencySymbol),
              ),
              _InfoTile('Receipt No', receipt.receiptNo),
              if (receipt.installmentNo != null)
                _InfoTile('Installment', receipt.installmentNo.toString()),
            ],
          ),
          if (receipt.remarks.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Remarks',
              style: TextStyle(
                color: AppTheme.text,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(receipt.remarks, style: const TextStyle(color: AppTheme.text)),
          ],
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              receipt.receiptFooter,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.muted),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptAmount extends StatelessWidget {
  const _ReceiptAmount({required this.amount, required this.currencySymbol});

  final double amount;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.success.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Amount Paid', style: TextStyle(color: AppTheme.muted)),
          const SizedBox(height: 4),
          Text(
            _money(amount, currencySymbol),
            style: const TextStyle(
              color: AppTheme.success,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 155,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppTheme.muted)),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.text,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _money(double value, String currency) =>
    '$currency ${value.toStringAsFixed(0)}';
