import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/institute_settings_service.dart';
import '../services/pdf_invoice_service.dart'; // 🚀 NAYA: PDF Service Import ki hai

class StudentReportScreen extends StatefulWidget {
  final int studentId;
  final String studentName;

  const StudentReportScreen({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  @override
  State<StudentReportScreen> createState() => _StudentReportScreenState();
}

class _StudentReportScreenState extends State<StudentReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Student Context States
  String studentPhone = "";
  String studentStandard = "N/A";

  // Attendance States
  Map<DateTime, String> attendanceMap = {};
  int totalPresent = 0;
  int totalAbsent = 0;
  int totalLate = 0;
  int totalHoliday = 0;
  DateTime _focusedDay = DateTime.now();
  bool isAttLoading = true;

  // Fees States
  List<Map<String, dynamic>> feeHistory = [];
  double totalCourseFees = 0;
  double totalPaidFees = 0;
  double totalPendingFees = 0;
  bool isFeeLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchStudentDetails(); // 🚀 Phone & Standard laane ke liye
    _fetchAttendanceData();
    _fetchFeeData();
  }

  // --- FETCH STUDENT DETAILS (For WhatsApp Message) ---
  Future<void> _fetchStudentDetails() async {
    try {
      var sSnap = await FirebaseFirestore.instance
          .collection('students')
          .where('id', isEqualTo: widget.studentId)
          .limit(1)
          .get();
      if (sSnap.docs.isNotEmpty) {
        studentPhone =
            sSnap.docs.first['phone']?.toString() ??
            sSnap.docs.first['guardian_phone']?.toString() ??
            "";
      }

      var eSnap = await FirebaseFirestore.instance
          .collection('enrollments')
          .where('student_id', isEqualTo: widget.studentId)
          .limit(1)
          .get();
      if (eSnap.docs.isNotEmpty) {
        int cId = (eSnap.docs.first['course_id'] as num).toInt();
        var cSnap = await FirebaseFirestore.instance
            .collection('courses')
            .where('id', isEqualTo: cId)
            .limit(1)
            .get();
        if (cSnap.docs.isNotEmpty) {
          studentStandard = cSnap.docs.first['name'] ?? "N/A";
        }
      }
    } catch (e) {
      debugPrint("Error fetching student details: $e");
    }
  }

  // --- ATTENDANCE FETCH ENGINE ---
  // --- ATTENDANCE FETCH ENGINE (BUG FIXED) ---
  Future<void> _fetchAttendanceData() async {
    setState(() {
      isAttLoading = true;
      totalPresent = 0;
      totalAbsent = 0;
      totalLate = 0;
      totalHoliday = 0;
      attendanceMap.clear();
    });

    try {
      String currentMonthPrefix = DateFormat('yyyy-MM').format(_focusedDay);

      // 🚀 THE FIX: Sirf Date se query kar rahe hain taaki Composite Index ka error na aaye
      var attSnap = await FirebaseFirestore.instance
          .collection('attendances')
          .where('date', isGreaterThanOrEqualTo: "$currentMonthPrefix-01")
          .where('date', isLessThanOrEqualTo: "$currentMonthPrefix-31")
          .get();

      for (var doc in attSnap.docs) {
        // 🚀 THE FIX: Student ID ko locally filter kar rahe hain (Handles String/Int mismatch)
        if (doc['student_id'].toString() == widget.studentId.toString()) {
          DateTime d = DateTime.parse(doc['date']);
          DateTime normalizedDate = DateTime.utc(d.year, d.month, d.day);
          String status = doc['status'];

          attendanceMap[normalizedDate] = status;

          if (status == 'present')
            totalPresent++;
          else if (status == 'absent')
            totalAbsent++;
          else if (status == 'late')
            totalLate++;
          else if (status == 'holiday')
            totalHoliday++;
        }
      }
    } catch (e) {
      debugPrint("Error fetching attendance: $e");
    } finally {
      // 🚀 THE FIX: Error aaye ya na aaye, loading hamesha band hogi
      if (mounted) setState(() => isAttLoading = false);
    }
  }

  // --- FEES FETCH ENGINE (BUG FIXED) ---
  Future<void> _fetchFeeData() async {
    setState(() {
      isFeeLoading = true;
      feeHistory.clear();
      totalCourseFees = 0;
      totalPaidFees = 0;
      totalPendingFees = 0;
    });

    try {
      // 🚀 THE FIX: Bypassing complex indexes by fetching all and filtering locally
      var feeSnap = await FirebaseFirestore.instance
          .collection('fee_payments')
          .where('deleted_at', isNull: true)
          .get();

      for (var doc in feeSnap.docs) {
        var data = doc.data();
        if (data['student_id'].toString() == widget.studentId.toString()) {
          feeHistory.add(data);
          if (data['status'] == 'pending')
            totalPendingFees +=
                double.tryParse(data['total_amount'].toString()) ?? 0;
          if (data['status'] == 'paid' || data['status'] == 'partially_paid')
            totalPaidFees +=
                double.tryParse(data['amount_paid'].toString()) ?? 0;
        }
      }

      feeHistory.sort(
        (a, b) => (b['created_at'] ?? '').compareTo(a['created_at'] ?? ''),
      );
      totalCourseFees = totalPaidFees + totalPendingFees;
    } catch (e) {
      debugPrint("Error fetching fees: $e");
    } finally {
      if (mounted) setState(() => isFeeLoading = false);
    }
  }

  // 🚀 WHATSAPP SHARE ENGINE (Exactly as your format) 🚀
  Future<void> _shareAttendanceOnWhatsApp() async {
    if (studentPhone.isEmpty || studentPhone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Valid phone number not found!"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    final settings = InstituteSettingsService.instance.cachedOrDefault;
    final instituteName = settings.instituteName.trim().isEmpty
        ? 'Mak Tutorials'
        : settings.instituteName.trim();
    var defaultCountryCode = settings.defaultCountryCode.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    if (defaultCountryCode.isEmpty) defaultCountryCode = '91';
    String phone = studentPhone.replaceAll(RegExp(r'[^0-9]'), '');
    if (phone.length == 10) phone = "$defaultCountryCode$phone";

    String monthStr = DateFormat('MMMM').format(_focusedDay);
    int totalWorkingDays = totalPresent + totalAbsent + totalLate;

    String remark = totalPresent > (totalWorkingDays / 2)
        ? "Keep it up! 👍"
        : "Please improve attendance. ⚠️";

    // 🚀 Exact formatting like your screenshot
    String message =
        """
| *${widget.studentName}*
Institute: $instituteName
Standard: $studentStandard
Month: $monthStr - $totalWorkingDays days
Total Present: $totalPresent
Total absent: $totalAbsent
Remark: $remark
""";

    Uri url = Uri.parse(
      "https://wa.me/$phone?text=${Uri.encodeComponent(message)}",
    );
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw "Could not launch";
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Could not open WhatsApp"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        title: Text(
          widget.studentName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.tealAccent,
          labelColor: Colors.tealAccent,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: "Attendance"),
            Tab(text: "Fees History"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildAttendanceTab(), _buildFeesTab()],
      ),
    );
  }

  // 🗓️ ATTENDANCE TAB UI
  Widget _buildAttendanceTab() {
    return Column(
      children: [
        // The Interactive Calendar
        Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: TableCalendar(
            firstDay: DateTime.utc(2020, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleTextStyle: TextStyle(color: Colors.white, fontSize: 16),
              leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
              rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: Colors.white54),
              weekendStyle: TextStyle(color: Colors.orangeAccent),
            ),
            calendarStyle: const CalendarStyle(
              defaultTextStyle: TextStyle(color: Colors.white),
              weekendTextStyle: TextStyle(color: Colors.white),
            ),
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
              _fetchAttendanceData();
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                DateTime normDay = DateTime.utc(day.year, day.month, day.day);
                if (attendanceMap.containsKey(normDay)) {
                  String status = attendanceMap[normDay]!;
                  Color bg = status == 'present'
                      ? Colors.greenAccent.withOpacity(0.3)
                      : status == 'absent'
                      ? Colors.redAccent.withOpacity(0.3)
                      : status == 'late'
                      ? Colors.orangeAccent.withOpacity(0.3)
                      : Colors.blueAccent.withOpacity(0.3);
                  Color fg = status == 'present'
                      ? Colors.greenAccent
                      : status == 'absent'
                      ? Colors.redAccent
                      : status == 'late'
                      ? Colors.orangeAccent
                      : Colors.blueAccent;

                  return Container(
                    margin: const EdgeInsets.all(6.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: bg,
                      shape: BoxShape.circle,
                      border: Border.all(color: fg),
                    ),
                    child: Text(
                      '${day.day}',
                      style: TextStyle(color: fg, fontWeight: FontWeight.bold),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
        ),

        // 🚀 Stats Grid
        if (isAttLoading)
          const CircularProgressIndicator(color: Colors.tealAccent)
        else
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              childAspectRatio: 2.5,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              children: [
                _statBox(
                  "Total Present",
                  totalPresent.toString(),
                  Colors.greenAccent,
                ),
                _statBox(
                  "Total Absent",
                  totalAbsent.toString(),
                  Colors.redAccent,
                ),
                _statBox(
                  "Total Late",
                  totalLate.toString(),
                  Colors.orangeAccent,
                ),
                _statBox(
                  "Total Holiday",
                  totalHoliday.toString(),
                  Colors.blueAccent,
                ),
              ],
            ),
          ),

        // 🚀 NAYA: WhatsApp Share Button Bottom Par
        if (!isAttLoading)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: 30,
              top: 10,
            ),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              icon: const Icon(
                Icons.wechat_rounded,
                color: Colors.white,
                size: 24,
              ),
              label: const Text(
                "Share Report on WhatsApp",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: _shareAttendanceOnWhatsApp,
            ),
          ),
      ],
    );
  }

  Widget _statBox(String title, String val, Color c) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: c.withOpacity(0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            val,
            style: TextStyle(
              color: c,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // 💰 FEES TAB UI
  Widget _buildFeesTab() {
    if (isFeeLoading)
      return const Center(
        child: CircularProgressIndicator(color: Colors.tealAccent),
      );

    return Column(
      children: [
        // Top Header
        Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.tealAccent.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total Course Fees",
                    style: TextStyle(color: Colors.white54),
                  ),
                  Text(
                    "₹$totalCourseFees",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total Paid",
                    style: TextStyle(color: Colors.white54),
                  ),
                  Text(
                    "₹$totalPaidFees",
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.white10, height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total Pending",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "₹$totalPendingFees",
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: feeHistory.length,
            itemBuilder: (context, index) {
              var f = feeHistory[index];
              bool isPending = f['status'] == 'pending';

              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          f['month_year'] ?? 'N/A',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          isPending
                              ? "Due: ${DateFormat('dd MMM yyyy').format(DateTime.parse(f['due_date']))}"
                              : "Paid: ${f['payment_mode']?.toString().toUpperCase()}",
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "₹${f['total_amount']}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isPending
                                    ? Colors.orangeAccent.withOpacity(0.2)
                                    : Colors.greenAccent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                isPending ? "PENDING" : "PAID",
                                style: TextStyle(
                                  color: isPending
                                      ? Colors.orangeAccent
                                      : Colors.greenAccent,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // 🚀 NAYA: Share Receipt Button if Paid
                        if (!isPending) ...[
                          const SizedBox(width: 15),
                          InkWell(
                            onTap: () async {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Generating PDF Receipt..."),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                              await PdfInvoiceService.generateAndShareReceipt(
                                feeData: f,
                                studentName: widget.studentName,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent.withOpacity(0.15),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.blueAccent.withOpacity(0.5),
                                ),
                              ),
                              child: const Icon(
                                Icons.share_rounded,
                                color: Colors.blueAccent,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
