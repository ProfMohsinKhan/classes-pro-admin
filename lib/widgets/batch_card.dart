import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class BatchCard extends StatelessWidget {
  final Map<String, dynamic> batch;
  final String courseName; // Relational data
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BatchCard({
    super.key,
    required this.batch,
    required this.courseName,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    bool isActive = batch['is_active'] ?? true;
    List<dynamic> days = batch['days'] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? AppTheme.warning.withValues(alpha: 0.3)
              : AppTheme.border,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 230),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primarySoft,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.primary.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        courseName.toUpperCase(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 10,
                      color: isActive ? AppTheme.success : AppTheme.danger,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isActive ? "Active" : "Inactive",
                      style: TextStyle(
                        color: isActive ? AppTheme.success : AppTheme.danger,
                        fontSize: 12,
                      ),
                    ),
                    if (onEdit != null || onDelete != null)
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert,
                          color: AppTheme.muted,
                          size: 20,
                        ),
                        color: AppTheme.surface,
                        onSelected: (val) {
                          if (val == 'edit') onEdit?.call();
                          if (val == 'delete') onDelete?.call();
                        },
                        itemBuilder: (context) => [
                          if (onEdit != null)
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text("Edit Batch"),
                            ),
                          if (onDelete != null)
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text(
                                "Delete (Soft)",
                                style: TextStyle(color: AppTheme.danger),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Title & Capacity
            Text(
              batch['name'] ?? 'Unnamed Batch',
              style: const TextStyle(
                color: AppTheme.text,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Capacity: ${batch['max_students']} Students",
              style: const TextStyle(color: AppTheme.muted, fontSize: 12),
            ),
            const SizedBox(height: 15),

            // Days Array (Glowing Pills)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: days
                  .map(
                    (day) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.warningSoft,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.warning.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        day.toString(),
                        style: const TextStyle(
                          color: AppTheme.warning,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 15),

            // Timings Bottom Bar
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
              decoration: BoxDecoration(
                color: AppTheme.primarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _timeWidget(
                      Icons.schedule,
                      "Start: ${batch['start_time'] ?? 'N/A'}",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _timeWidget(
                      Icons.schedule_send,
                      "End: ${batch['end_time'] ?? 'N/A'}",
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeWidget(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppTheme.primary, size: 16),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.muted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
