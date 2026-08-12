import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';

class EnrollmentCard extends StatelessWidget {
  const EnrollmentCard({
    super.key,
    required this.enrollment,
    required this.studentName,
    required this.courseName,
    required this.batchName,
    required this.onEdit,
    required this.onDelete,
    this.studentPhoto,
  });

  final Map<String, dynamic> enrollment;
  final String studentName;
  final String courseName;
  final String batchName;
  final String? studentPhoto;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final status =
        (enrollment['status']?.toString() ??
                (enrollment['isActive'] == false ||
                        enrollment['is_active'] == false
                    ? 'inactive'
                    : 'active'))
            .toLowerCase();
    final isActive = status == 'active';
    final finalFees = _amount(
      enrollment['final_fees'] ??
          enrollment['finalFees'] ??
          enrollment['finalFee'] ??
          enrollment['totalFee'],
    );
    final discount = _amount(
      enrollment['discount_amount'] ?? enrollment['discount'],
    );
    final nextDue = _date(
      enrollment['nextDueDate'] ??
          enrollment['next_due_date'] ??
          enrollment['valid_until'],
    );
    final paymentStructure = _planLabel(
      enrollment['paymentStructure'] ??
          enrollment['planType'] ??
          enrollment['payment_structure'],
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDDE6F3)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.text.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Avatar(name: studentName, photo: studentPhoto),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        studentName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$courseName / $batchName',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(isActive: isActive, status: status),
                if (onEdit != null || onDelete != null)
                  PopupMenuButton<String>(
                    tooltip: 'Enrollment actions',
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      color: AppTheme.muted,
                    ),
                    color: AppTheme.surface,
                    onSelected: (value) {
                      if (value == 'edit') onEdit?.call();
                      if (value == 'delete') onDelete?.call();
                    },
                    itemBuilder: (context) => [
                      if (onEdit != null)
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      if (onDelete != null)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Delete / Archive',
                            style: TextStyle(color: AppTheme.danger),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: 'Final Fees',
                    value: _money(finalFees),
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricTile(
                    label: 'Discount',
                    value: discount <= 0 ? '--' : '- ${_money(discount)}',
                    color: AppTheme.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoPill(
                  icon: Icons.payments_rounded,
                  label: paymentStructure,
                  color: AppTheme.success,
                ),
                _InfoPill(
                  icon: Icons.event_rounded,
                  label: nextDue == null
                      ? 'Next due not set'
                      : 'Next due ${DateFormat('dd MMM').format(nextDue)}',
                  color: AppTheme.primary,
                ),
                if ((enrollment['discountReason'] ??
                        enrollment['discount_reason'] ??
                        '')
                    .toString()
                    .trim()
                    .isNotEmpty)
                  _InfoPill(
                    icon: Icons.sell_rounded,
                    label:
                        (enrollment['discountReason'] ??
                                enrollment['discount_reason'])
                            .toString(),
                    color: AppTheme.warning,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, this.photo});

  final String name;
  final String? photo;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return CircleAvatar(
      radius: 24,
      backgroundColor: AppTheme.primarySoft,
      backgroundImage: photo == null || photo!.trim().isEmpty
          ? null
          : NetworkImage(photo!),
      child: photo == null || photo!.trim().isEmpty
          ? Text(
              initial,
              style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w900,
              ),
            )
          : null,
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isActive, required this.status});

  final bool isActive;
  final String status;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppTheme.success : AppTheme.danger;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 190),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.muted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _planLabel(dynamic value) {
  return switch (value?.toString()) {
    'monthly' => 'Monthly',
    'installments_3' => '3 Installments',
    'installments_4' => '4 Installments',
    'custom' => 'Custom',
    'installments' => 'Installments',
    _ => 'One Time Payment',
  };
}

double _amount(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime? _date(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

String _money(double value) => 'Rs ${value.toStringAsFixed(0)}';
