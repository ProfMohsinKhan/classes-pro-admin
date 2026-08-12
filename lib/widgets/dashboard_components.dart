import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/institute_settings_service.dart';

// --- 1. Section Header ---
class SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const SectionHeader({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueAccent, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// --- 2. Glass Card ---
class GlassCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;

  const GlassCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    double cardWidth = (MediaQuery.of(context).size.width - 55) / 2;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: cardWidth,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 20),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- 3. Recent Activity Feed (LIVE WITH NAMES & WHATSAPP/SMS) ---
class RecentActivityFeed extends StatefulWidget {
  const RecentActivityFeed({super.key});

  @override
  State<RecentActivityFeed> createState() => _RecentActivityFeedState();
}

class _RecentActivityFeedState extends State<RecentActivityFeed> {
  Map<int, Map<String, dynamic>> studentData = {};
  bool isLoadingStudents = true;

  @override
  void initState() {
    super.initState();
    _loadStudentsData();
  }

  // IDs se Naam aur Phone fetch karne ka logic
  Future<void> _loadStudentsData() async {
    var snap = await FirebaseFirestore.instance.collection('students').get();
    Map<int, Map<String, dynamic>> temp = {};
    for (var doc in snap.docs) {
      temp[(doc['id'] as num).toInt()] = {
        'name': doc['name'] ?? 'Unknown',
        'phone': doc['phone'] ?? doc['guardian_phone'] ?? '',
      };
    }
    if (mounted) {
      setState(() {
        studentData = temp;
        isLoadingStudents = false;
      });
    }
  }

  // Messaging Logic
  Future<void> _sendQuickMessage(
    String phone,
    String studentName,
    bool isPaid,
    String amount,
    bool isWhatsApp,
  ) async {
    final settings = InstituteSettingsService.instance.cachedOrDefault;
    final instituteName = settings.instituteName.trim().isEmpty
        ? 'Mak Tutorials'
        : settings.instituteName.trim();
    var defaultCountryCode = settings.defaultCountryCode.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    if (defaultCountryCode.isEmpty) defaultCountryCode = '91';
    String cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.length == 10) cleanPhone = "$defaultCountryCode$cleanPhone";

    if (cleanPhone.isEmpty || cleanPhone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Valid phone number not found!"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    String message = isPaid
        ? "✅ Hello, this is to confirm that we have received the payment of ₹$amount for $studentName. Thank you! - Classes Management Pro"
        : "⚠️ Reminder: A new fee due has been generated for $studentName. Kindly clear it soon. - Classes Management Pro";

    message = isPaid
        ? "Hello, this is to confirm that we have received the payment of ${settings.currencySymbol}$amount for $studentName. Thank you! - $instituteName"
        : "Reminder: A new fee due has been generated for $studentName. Kindly clear it soon. - $instituteName";
    String encodedMsg = Uri.encodeComponent(message);
    Uri url = isWhatsApp
        ? Uri.parse("https://wa.me/$cleanPhone?text=$encodedMsg")
        : Uri.parse("sms:+$cleanPhone?body=$encodedMsg");

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Could not open messaging app."),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingStudents) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white24),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Live Activity Feed",
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('fee_payments')
                .orderBy('updated_at', descending: true)
                .limit(20) // Fetching more to allow for filtering
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.tealAccent),
                );
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Text(
                  "No recent activities found.",
                  style: TextStyle(color: Colors.white38),
                );
              }

              List<Widget> feedItems = [];
              Set<String> seenActivities = {}; // Duplicates rokne ke liye

              for (var doc in snapshot.data!.docs) {
                var data = doc.data() as Map<String, dynamic>;
                bool isPaid = data['status'] == 'paid';
                int sId = (data['student_id'] as num?)?.toInt() ?? 0;

                DateTime updateTime = data['updated_at'] != null
                    ? DateTime.tryParse(data['updated_at']) ?? DateTime.now()
                    : DateTime.now();

                // 🚀 THE SMART FILTER LOGIC 🚀
                // Agar ek hi bachhe ka ek hi time (same minute) par multiple dues generate hue hain, toh unko ek key de do
                String timeKey = DateFormat('yyyyMMddHHmm').format(updateTime);
                String uniqueKey = "${sId}_${isPaid}_$timeKey";

                // Agar ye activity pehle hi feed mein add ho chuki hai (Jaise Laxmi ke baaki 11 dues), toh skip karo
                if (seenActivities.contains(uniqueKey)) {
                  continue;
                }
                seenActivities.add(
                  uniqueKey,
                ); // Pehli baar aayi hai toh record kar lo

                // Extract Name and Phone
                String sName = studentData[sId]?['name'] ?? 'Unknown Student';
                String sPhone = studentData[sId]?['phone'] ?? '';
                String timeStr = DateFormat(
                  'dd MMM, hh:mm a',
                ).format(updateTime);

                String subtitle = isPaid
                    ? "Paid ₹${data['amount_paid']} • $timeStr"
                    : "Fee Schedule Generated • $timeStr"; // Thoda better text

                feedItems.add(
                  _item(
                    title: sName,
                    subtitle: subtitle,
                    icon: isPaid ? Icons.check_circle : Icons.receipt_long,
                    color: isPaid ? Colors.greenAccent : Colors.orangeAccent,
                    phone: sPhone,
                    isPaid: isPaid,
                    amount: isPaid
                        ? data['amount_paid'].toString()
                        : data['total_amount'].toString(),
                  ),
                );

                // Humein sirf top 5 UNIQUE activities dikhani hain
                if (feedItems.length == 5) break;
              }

              return Column(children: feedItems);
            },
          ),
        ],
      ),
    );
  }

  Widget _item({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String phone,
    required bool isPaid,
    required String amount,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 18),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () =>
                  _sendQuickMessage(phone, title, isPaid, amount, false),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sms,
                  color: Colors.blueAccent,
                  size: 16,
                ),
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: () =>
                  _sendQuickMessage(phone, title, isPaid, amount, true),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.wechat,
                  color: Colors.greenAccent,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
