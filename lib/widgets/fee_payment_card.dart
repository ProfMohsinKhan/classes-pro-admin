import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FeePaymentCard extends StatelessWidget {
  final Map<String, dynamic> feeData;
  final String studentName;
  final VoidCallback? onCollect;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onShare; // 🚀 NAYA: Share PDF Button ke liye

  const FeePaymentCard({
    super.key,
    required this.feeData,
    required this.studentName,
    this.onCollect,
    this.onEdit,
    this.onDelete,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    bool isPending = feeData['status'] == 'pending';
    DateTime dueDate = DateTime.tryParse(feeData['due_date'] ?? '') ?? DateTime.now();
    bool isOverdue = isPending && dueDate.isBefore(DateTime.now());

    Color cardColor = isPending
        ? (isOverdue ? Colors.redAccent : Colors.orangeAccent)
        : Colors.greenAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          if (isPending) BoxShadow(color: cardColor.withOpacity(0.05), blurRadius: 20, spreadRadius: -5)
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Top Row ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const CircleAvatar(backgroundColor: Colors.white10, radius: 14, child: Icon(Icons.person, size: 16, color: Colors.white54)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(studentName, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: cardColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: cardColor.withOpacity(0.5)),
                      ),
                      child: Text(
                        isPending ? (isOverdue ? "OVERDUE" : "PENDING") : "PAID",
                        style: TextStyle(color: cardColor, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (isPending && (onEdit != null || onDelete != null)) ...[
                      const SizedBox(width: 5),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.white54, size: 20),
                        color: const Color(0xFF1E293B),
                        onSelected: (val) {
                          if (val == 'edit' && onEdit != null) onEdit!();
                          if (val == 'delete' && onDelete != null) onDelete!();
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'edit', child: Text("Edit Amount/Date", style: TextStyle(color: Colors.white))),
                          const PopupMenuItem(value: 'delete', child: Text("Delete Entry", style: TextStyle(color: Colors.redAccent))),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const Divider(color: Colors.white10, height: 25),

            // --- Middle Row ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("For: ${feeData['month_year'] ?? 'N/A'}", style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 12, color: isOverdue ? Colors.redAccent : Colors.white38),
                        const SizedBox(width: 5),
                        Text(
                            "Due: ${DateFormat('dd MMM yyyy').format(dueDate)}",
                            style: TextStyle(color: isOverdue ? Colors.redAccent : Colors.white38, fontSize: 12, fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal)
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("Amount", style: TextStyle(color: Colors.white38, fontSize: 12)),
                    Text(
                        "₹${feeData['total_amount']}",
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 15),

            // --- Bottom Row ---
            if (isPending && onCollect != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onCollect,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent.withOpacity(0.1),
                    foregroundColor: Colors.tealAccent,
                    elevation: 0,
                    side: BorderSide(color: Colors.tealAccent.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.payments_outlined, size: 18),
                  label: const Text("Collect Fee"),
                ),
              ),

            // 🚀 NAYA: Payment History UI with Share PDF Button
            if (!isPending && feeData['receipt_number'] != null)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(10)),
                      child: Text(
                        "Receipt: ${feeData['receipt_number']} • ${feeData['payment_mode']?.toString().toUpperCase()}",
                        style: const TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  if (onShare != null) ...[
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: onShare,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
                        ),
                        child: const Icon(Icons.share_rounded, color: Colors.blueAccent, size: 20),
                      ),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}