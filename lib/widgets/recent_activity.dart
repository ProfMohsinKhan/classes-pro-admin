import 'package:flutter/material.dart';

class RecentActivity extends StatelessWidget {
  const RecentActivity({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Recent Activity", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          _activityItem("New Admission: Rahul Sharma", "2 mins ago", Icons.person_add, Colors.blue),
          _activityItem("Fee Received: ₹2,000 from Sneha", "15 mins ago", Icons.payment, Colors.green),
          _activityItem("Attendance Marked: Batch A", "1 hour ago", Icons.check_circle, Colors.orange),
        ],
      ),
    );
  }

  Widget _activityItem(String title, String time, IconData icon, Color color) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
      subtitle: Text(time, style: const TextStyle(color: Colors.white38, fontSize: 12)),
    );
  }
}