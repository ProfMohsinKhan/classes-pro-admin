import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/institute_settings_service.dart';

class BirthdayStrip extends StatelessWidget {
  const BirthdayStrip({super.key});

  Future<void> _sendBirthdayWish(
    BuildContext context,
    String name,
    String phone,
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

    String message =
        "🎉 *Happy Birthday $name!* 🎂\n\nWishing you a fantastic day and a successful year ahead!\n\nBest Wishes,\n*Classes Management Pro*";
    message =
        "Happy Birthday $name!\n\nWishing you a fantastic day and a successful year ahead.\n\nBest Wishes,\n$instituteName";
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
    DateTime now = DateTime.now();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('students')
          .where('deleted_at', isNull: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        List<Map<String, dynamic>> todayBirthdays = [];
        List<Map<String, dynamic>> upcomingBirthdays = [];

        for (var doc in snapshot.data!.docs) {
          var data = doc.data() as Map<String, dynamic>;
          if (data['dob'] == null) continue;

          DateTime? dob = DateTime.tryParse(data['dob']);
          if (dob == null) continue;

          // Calculate next birthday date for the current year
          DateTime nextBirthday = DateTime(now.year, dob.month, dob.day);

          // If birthday has passed this year, check for next year
          if (nextBirthday.isBefore(DateTime(now.year, now.month, now.day))) {
            nextBirthday = DateTime(now.year + 1, dob.month, dob.day);
          }

          int diffDays = nextBirthday
              .difference(DateTime(now.year, now.month, now.day))
              .inDays;

          if (diffDays == 0) {
            todayBirthdays.add(data);
          } else if (diffDays > 0 && diffDays <= 30) {
            data['days_left'] = diffDays;
            upcomingBirthdays.add(data);
          }
        }

        // Sort upcoming by days left
        upcomingBirthdays.sort(
          (a, b) => (a['days_left'] as int).compareTo(b['days_left'] as int),
        );

        if (todayBirthdays.isEmpty && upcomingBirthdays.isEmpty)
          return const SizedBox();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- TODAY'S BIRTHDAYS (GREEN HIGHLIGHT) ---
            if (todayBirthdays.isNotEmpty) ...[
              const Text(
                "Today's Birthdays 🎂",
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: todayBirthdays.length,
                  itemBuilder: (context, index) {
                    var student = todayBirthdays[index];
                    return Container(
                      margin: const EdgeInsets.only(right: 15),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.greenAccent.withOpacity(0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Icon(
                              Icons.cake,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                student['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const Text(
                                "Wish them now!",
                                style: TextStyle(
                                  color: Colors.greenAccent,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 15),
                          // Action Buttons
                          InkWell(
                            onTap: () => _sendBirthdayWish(
                              context,
                              student['name'],
                              student['phone'] ?? student['guardian_phone'],
                              false,
                            ),
                            child: const Icon(
                              Icons.sms,
                              color: Colors.blueAccent,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 10),
                          InkWell(
                            onTap: () => _sendBirthdayWish(
                              context,
                              student['name'],
                              student['phone'] ?? student['guardian_phone'],
                              true,
                            ),
                            child: const Icon(
                              Icons.wechat,
                              color: Colors.greenAccent,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],

            // --- UPCOMING BIRTHDAYS (NEXT 30 DAYS) ---
            if (upcomingBirthdays.isNotEmpty) ...[
              const Text(
                "Upcoming Birthdays (Next 30 Days) 🗓️",
                style: TextStyle(
                  color: Colors.orangeAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: upcomingBirthdays.length,
                  itemBuilder: (context, index) {
                    var student = upcomingBirthdays[index];
                    return Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orangeAccent.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.orangeAccent.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.person_outline,
                            color: Colors.orangeAccent,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "${student['name']} ",
                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            "(${student['days_left']} days)",
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
