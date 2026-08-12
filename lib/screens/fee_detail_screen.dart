import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/receipt_model.dart';
import '../theme/app_theme.dart';
import 'receipt_screen.dart';

class FeeDetailData {
  const FeeDetailData({
    required this.studentName,
    required this.subtitle,
    required this.courseName,
    required this.batchName,
    required this.totalFee,
    required this.paid,
    required this.pending,
    required this.status,
    required this.installments,
    required this.history,
    this.nextDueDate,
    this.latestReceipt,
  });

  final String studentName;
  final String subtitle;
  final String courseName;
  final String batchName;
  final double totalFee;
  final double paid;
  final double pending;
  final DateTime? nextDueDate;
  final String status;
  final List<FeeInstallmentRow> installments;
  final List<FeeHistoryItem> history;
  final ReceiptModel? latestReceipt;
}

class FeeInstallmentRow {
  const FeeInstallmentRow({
    required this.number,
    required this.amount,
    required this.paidAmount,
    required this.dueDate,
    required this.status,
  });

  final int number;
  final double amount;
  final double paidAmount;
  final DateTime dueDate;
  final String status;
}

class FeeHistoryItem {
  const FeeHistoryItem({
    required this.recordId,
    required this.receiptNo,
    required this.amount,
    required this.mode,
    required this.date,
    required this.receivedBy,
    required this.remarks,
    required this.receipt,
  });

  final String recordId;
  final String receiptNo;
  final double amount;
  final String mode;
  final DateTime? date;
  final String receivedBy;
  final String remarks;
  final ReceiptModel receipt;
}

class FeeDetailScreen extends StatefulWidget {
  const FeeDetailScreen({
    super.key,
    required this.initialData,
    required this.canCollectFees,
    required this.canEditFeePlan,
    required this.canViewHistory,
    required this.canEditPaymentHistory,
    required this.onCollectFee,
    required this.onEditFeePlan,
    required this.onEditPaymentHistory,
  });

  final FeeDetailData initialData;
  final bool canCollectFees;
  final bool canEditFeePlan;
  final bool canViewHistory;
  final bool canEditPaymentHistory;
  final Future<FeeDetailData?> Function() onCollectFee;
  final Future<FeeDetailData?> Function() onEditFeePlan;
  final Future<FeeDetailData?> Function(FeeHistoryItem item)
  onEditPaymentHistory;

  @override
  State<FeeDetailScreen> createState() => _FeeDetailScreenState();
}

class _FeeDetailScreenState extends State<FeeDetailScreen> {
  late FeeDetailData _data;
  bool _isCollecting = false;
  bool _isEditingPlan = false;

  @override
  void initState() {
    super.initState();
    _data = widget.initialData;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (_data.status) {
      'Paid' => AppTheme.success,
      'Partial' => AppTheme.primary,
      _ => AppTheme.warning,
    };

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Fee Detail'),
        actions: [
          if (widget.canEditFeePlan)
            IconButton(
              tooltip: 'Edit Fee Plan',
              onPressed: _isEditingPlan ? null : _editPlan,
              icon: const Icon(Icons.tune_rounded),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StudentHeader(data: _data, statusColor: statusColor),
              const SizedBox(height: 14),
              if (_data.latestReceipt != null) ...[
                _ReceiptPreview(
                  data: _data.latestReceipt!,
                  onOpen: () => _openReceipt(_data.latestReceipt!),
                ),
                const SizedBox(height: 14),
              ],
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _MetricTile('Total Fee', _money(_data.totalFee)),
                  _MetricTile('Paid', _money(_data.paid)),
                  _MetricTile('Pending', _money(_data.pending)),
                  _MetricTile(
                    'Next Due',
                    _data.nextDueDate == null
                        ? '--'
                        : DateFormat('dd MMM yyyy').format(_data.nextDueDate!),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (widget.canCollectFees || widget.canEditFeePlan) ...[
                Row(
                  children: [
                    if (widget.canCollectFees)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _data.pending <= 0 || _isCollecting
                              ? null
                              : _collect,
                          icon: _isCollecting
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.payments_rounded),
                          label: const Text('Collect Fee'),
                        ),
                      ),
                    if (widget.canCollectFees && widget.canEditFeePlan)
                      const SizedBox(width: 10),
                    if (widget.canEditFeePlan)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isEditingPlan ? null : _editPlan,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primary,
                            side: const BorderSide(color: AppTheme.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(Icons.edit_calendar_rounded),
                          label: const Text('Edit Fee Plan'),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
              const _SectionTitle('Installment Schedule'),
              const SizedBox(height: 10),
              if (_data.installments.isEmpty)
                const _EmptyCard(
                  icon: Icons.event_note_rounded,
                  title: 'No installment schedule yet',
                  subtitle: 'Set a fee plan to generate installment rows.',
                )
              else
                ..._data.installments.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _InstallmentCard(item: item),
                  ),
                ),
              if (widget.canViewHistory) ...[
                const SizedBox(height: 12),
                const _SectionTitle('Payment History'),
                const SizedBox(height: 10),
                if (_data.history.isEmpty)
                  const _EmptyCard(
                    icon: Icons.receipt_long_rounded,
                    title: 'No payments collected',
                    subtitle: 'Receipts will appear here after collection.',
                  )
                else
                  ..._data.history.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _HistoryCard(
                        item: item,
                        onOpen: () => _openReceipt(item.receipt),
                        onEdit: widget.canEditPaymentHistory
                            ? () => _editPaymentHistory(item)
                            : null,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _collect() async {
    setState(() => _isCollecting = true);
    try {
      final updated = await widget.onCollectFee();
      if (mounted && updated != null) setState(() => _data = updated);
    } finally {
      if (mounted) setState(() => _isCollecting = false);
    }
  }

  Future<void> _editPlan() async {
    setState(() => _isEditingPlan = true);
    try {
      final updated = await widget.onEditFeePlan();
      if (mounted && updated != null) setState(() => _data = updated);
    } finally {
      if (mounted) setState(() => _isEditingPlan = false);
    }
  }

  Future<void> _editPaymentHistory(FeeHistoryItem item) async {
    final updated = await widget.onEditPaymentHistory(item);
    if (mounted && updated != null) setState(() => _data = updated);
  }

  Future<void> _openReceipt(ReceiptModel receipt) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ReceiptScreen(receipt: receipt),
      ),
    );
  }
}

class _StudentHeader extends StatelessWidget {
  const _StudentHeader({required this.data, required this.statusColor});

  final FeeDetailData data;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    final initial = data.studentName.characters.first.toUpperCase();
    return _Card(
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
            child: Text(
              initial,
              style: const TextStyle(
                color: AppTheme.primary,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.studentName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppTheme.muted),
                ),
              ],
            ),
          ),
          _Badge(label: data.status, color: statusColor),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 158,
      child: _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppTheme.muted)),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(
                  color: AppTheme.text,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InstallmentCard extends StatelessWidget {
  const _InstallmentCard({required this.item});

  final FeeInstallmentRow item;

  @override
  Widget build(BuildContext context) {
    final color = switch (item.status) {
      'Paid' => AppTheme.success,
      'Partial' => AppTheme.primary,
      _ => AppTheme.warning,
    };
    return _Card(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.12),
            child: Text(
              item.number.toString(),
              style: TextStyle(color: color, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _money(item.amount),
                  style: const TextStyle(
                    color: AppTheme.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Due ${DateFormat('dd MMM yyyy').format(item.dueDate)}',
                  style: const TextStyle(color: AppTheme.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          _Badge(label: item.status, color: color),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.item, required this.onOpen, this.onEdit});

  final FeeHistoryItem item;
  final VoidCallback onOpen;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(18),
      child: _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_rounded, color: AppTheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.receiptNo,
                    style: const TextStyle(
                      color: AppTheme.text,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  _money(item.amount),
                  style: const TextStyle(
                    color: AppTheme.success,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (onEdit != null)
                  IconButton(
                    tooltip: 'Edit payment details',
                    onPressed: onEdit,
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: AppTheme.primary,
                    ),
                  )
                else ...[
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppTheme.muted,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${item.mode} / ${item.date == null ? '--' : DateFormat('dd MMM yyyy').format(item.date!)} / ${item.receivedBy}',
              style: const TextStyle(color: AppTheme.muted, fontSize: 12),
            ),
            if (item.remarks.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(item.remarks, style: const TextStyle(color: AppTheme.text)),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReceiptPreview extends StatelessWidget {
  const _ReceiptPreview({required this.data, required this.onOpen});

  final ReceiptModel data;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(18),
      child: _Card(
        tint: AppTheme.success.withValues(alpha: 0.08),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Latest Receipt',
                    style: TextStyle(
                      color: AppTheme.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const Icon(Icons.open_in_new_rounded, color: AppTheme.primary),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Receipt ${data.receiptNo}',
              style: const TextStyle(color: AppTheme.muted),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _ReceiptLine('Student', data.studentName),
                _ReceiptLine(
                  'Amount',
                  '${data.currencySymbol} ${data.amountPaid.toStringAsFixed(0)}',
                ),
                _ReceiptLine('Mode', data.paymentMode),
                _ReceiptLine(
                  'Date',
                  data.paymentDate == null
                      ? '--'
                      : DateFormat('dd MMM yyyy').format(data.paymentDate!),
                ),
                _ReceiptLine('Received By', data.receivedByName),
                _ReceiptLine(
                  'Pending',
                  '${data.currencySymbol} ${data.pendingAfterPayment.toStringAsFixed(0)}',
                ),
              ],
            ),
            if (data.remarks.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(data.remarks, style: const TextStyle(color: AppTheme.text)),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReceiptLine extends StatelessWidget {
  const _ReceiptLine(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.muted)),
          const SizedBox(height: 2),
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
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppTheme.text,
        fontSize: 18,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: AppTheme.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.tint});

  final Widget child;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tint ?? AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

String _money(double value) => 'Rs ${value.toStringAsFixed(0)}';
