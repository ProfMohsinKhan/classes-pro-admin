import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/database/sync_types.dart';
import '../models/enquiry_model.dart';
import '../theme/app_theme.dart';

class EnquiryCard extends StatelessWidget {
  const EnquiryCard({
    super.key,
    required this.enquiry,
    required this.onEdit,
    required this.onDelete,
    required this.onStatusChanged,
  });

  final EnquiryModel enquiry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<String> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final status = enquiry.enquiryStatus;
    final statusColor = _statusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.28),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.text.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    enquiry.studentName.isEmpty
                        ? 'Unknown Lead'
                        : enquiry.studentName,
                    style: const TextStyle(
                      color: AppTheme.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (enquiry.syncStatus != LocalSyncStatus.synced)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Icon(
                      enquiry.syncStatus == LocalSyncStatus.failed
                          ? Icons.cloud_off_outlined
                          : Icons.cloud_upload_outlined,
                      size: 18,
                      color: enquiry.syncStatus == LocalSyncStatus.failed
                          ? AppTheme.danger
                          : AppTheme.warning,
                    ),
                  ),
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppTheme.muted,
                    size: 20,
                  ),
                  color: AppTheme.surface,
                  onSelected: (val) {
                    if (val == 'edit') onEdit();
                    if (val == 'delete') onDelete();
                    if (val.startsWith('status:')) {
                      onStatusChanged(val.substring('status:'.length));
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text(
                        'Edit / Follow-up',
                        style: TextStyle(color: AppTheme.text),
                      ),
                    ),
                    const PopupMenuDivider(),
                    for (final status in _statuses)
                      PopupMenuItem(
                        value: 'status:$status',
                        child: Text(
                          _statusLabel(status),
                          style: const TextStyle(color: AppTheme.text),
                        ),
                      ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Delete (Soft)',
                        style: TextStyle(color: AppTheme.danger),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.phone, size: 14, color: AppTheme.muted),
                const SizedBox(width: 5),
                Text(
                  enquiry.phone ?? 'No Phone',
                  style: const TextStyle(color: AppTheme.muted, fontSize: 13),
                ),
                const SizedBox(width: 15),
                const Icon(Icons.menu_book, size: 14, color: AppTheme.muted),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    enquiry.interestedCourseName ?? 'N/A',
                    style: const TextStyle(color: AppTheme.muted, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if ((enquiry.interestedBatchName ?? '').isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.layers, size: 14, color: AppTheme.muted),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      enquiry.interestedBatchName!,
                      style: const TextStyle(
                        color: AppTheme.muted,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 15),
            const Divider(color: AppTheme.border, height: 1),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.34),
                    ),
                  ),
                  child: Text(
                    _statusLabel(status).toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                if (enquiry.followUpDate != null)
                  Flexible(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Icon(
                          Icons.calendar_month,
                          size: 14,
                          color: AppTheme.warning,
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            'Follow up: ${DateFormat('dd MMM yyyy').format(enquiry.followUpDate!)}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.warning,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static const _statuses = [
    'new',
    'contacted',
    'followUp',
    'interested',
    'converted',
    'notInterested',
    'closed',
  ];

  static Color _statusColor(String status) {
    switch (status) {
      case 'new':
        return AppTheme.primary;
      case 'contacted':
      case 'followUp':
        return AppTheme.warning;
      case 'interested':
      case 'converted':
        return AppTheme.success;
      case 'notInterested':
      case 'closed':
        return AppTheme.danger;
      default:
        return AppTheme.muted;
    }
  }

  static String _statusLabel(String status) {
    switch (status) {
      case 'followUp':
        return 'Follow-up';
      case 'notInterested':
        return 'Not Interested';
      default:
        return status.replaceAllMapped(RegExp(r'(^|[A-Z])[a-z]*'), (match) {
          final value = match.group(0) ?? '';
          return value.isEmpty
              ? value
              : '${value[0].toUpperCase()}${value.substring(1)}';
        }).trim();
    }
  }
}
