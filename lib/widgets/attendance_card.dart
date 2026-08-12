import 'package:flutter/material.dart';

import '../models/attendance_model.dart';
import '../models/student_model.dart';
import '../theme/app_theme.dart';

class AttendanceCard extends StatelessWidget {
  const AttendanceCard({
    super.key,
    required this.student,
    required this.status,
    required this.onStatusChanged,
  });

  final StudentModel student;
  final AttendanceStatus? status;
  final ValueChanged<AttendanceStatus>? onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final selectedStatus = status;
    final initial = student.displayName.characters.first.toUpperCase();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: (selectedStatus?.color ?? AppTheme.border).withValues(
            alpha: selectedStatus == null ? 0.08 : 0.28,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppTheme.primarySoft,
                backgroundImage: student.profilePhoto == null
                    ? null
                    : NetworkImage(student.profilePhoto!),
                child: student.profilePhoto == null
                    ? Text(
                        initial,
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.text,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      student.displayClassBatch,
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
              const SizedBox(width: 8),
              _StatusBadge(status: selectedStatus),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AttendanceStatus.values.map((item) {
              final isSelected = item == selectedStatus;
              return _StatusChip(
                status: item,
                selected: isSelected,
                onTap: onStatusChanged == null
                    ? null
                    : () => onStatusChanged!(item),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final AttendanceStatus? status;

  @override
  Widget build(BuildContext context) {
    final color = status?.color ?? AppTheme.muted;
    final label = status?.label ?? 'Unmarked';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: status == null ? 0.08 : 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.status,
    required this.selected,
    required this.onTap,
  });

  final AttendanceStatus status;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: status.color.withValues(
            alpha: onTap == null
                ? 0.03
                : selected
                ? 0.22
                : 0.07,
          ),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: status.color.withValues(alpha: selected ? 0.65 : 0.16),
          ),
        ),
        child: Text(
          status.label,
          style: TextStyle(
            color: onTap == null
                ? AppTheme.mutedLight
                : selected
                ? status.color
                : AppTheme.muted,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
