import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/fees/fee_record_values.dart';
import '../models/app_user_model.dart';
import '../models/permission_keys.dart';
import '../models/receipt_model.dart';
import '../models/student_model.dart';
import '../services/auth_service.dart';
import '../services/institute_settings_service.dart';
import '../services/receipt_pdf_service.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';
import 'access_denied_screen.dart';
import 'fee_detail_screen.dart';
import 'receipt_screen.dart';

enum _FeeFilter { all, pending, paid, partial, dueToday, dueThisWeek }

const List<String> _paymentModes = ['Cash', 'UPI', 'Bank', 'Other'];

class FeesScreen extends StatefulWidget {
  const FeesScreen({super.key});

  @override
  State<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends State<FeesScreen> {
  late final Stream<AppUserModel?> _profileStream;

  bool _isLoading = true;
  bool _isInlineLoading = false;
  String? _loadError;
  String _searchQuery = '';
  _FeeFilter _selectedFilter = _FeeFilter.all;

  List<_StudentFeeSummary> _feeSummaries = const [];

  @override
  void initState() {
    super.initState();
    _profileStream = UserService.instance.streamCurrentUserProfile();
    _loadFeesData();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUserModel?>(
      stream: _profileStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppTheme.background,
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            ),
          );
        }

        final appUser = snapshot.data;
        if (appUser == null || !appUser.canViewFees) {
          return const AccessDeniedScreen();
        }

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            title: const Text(
              'Fees',
              style: TextStyle(
                color: AppTheme.text,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppTheme.background,
            elevation: 0,
            iconTheme: const IconThemeData(color: AppTheme.text),
            actions: [
              IconButton(
                tooltip: 'Refresh',
                onPressed: _isInlineLoading ? null : _refreshInline,
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          body: SafeArea(child: _buildBody(appUser)),
        );
      },
    );
  }

  Widget _buildBody(AppUserModel appUser) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      );
    }

    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _StateCard(
            icon: Icons.cloud_off_rounded,
            title: 'Fees data could not be loaded.',
            subtitle: _loadError!,
          ),
        ),
      );
    }

    final visible = _filteredSummaries();
    final totals = _FeeTotals.fromSummaries(_feeSummaries);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Header(),
                const SizedBox(height: 16),
                _SummaryGrid(totals: totals),
                const SizedBox(height: 16),
                _SearchBox(
                  onChanged: (value) {
                    setState(() => _searchQuery = value.trim().toLowerCase());
                  },
                ),
                const SizedBox(height: 12),
                _FilterChips(
                  selected: _selectedFilter,
                  onChanged: (filter) =>
                      setState(() => _selectedFilter = filter),
                ),
                const SizedBox(height: 16),
                if (_isInlineLoading)
                  const _StateCard(
                    icon: Icons.hourglass_top_rounded,
                    title: 'Refreshing fee data...',
                    subtitle: 'The current filters will stay in place.',
                  ),
                if (_isInlineLoading) const SizedBox(height: 12),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Student Fees',
                        style: TextStyle(
                          color: AppTheme.text,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      '${visible.length} students',
                      style: const TextStyle(color: AppTheme.muted),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (visible.isEmpty)
                  const _StateCard(
                    icon: Icons.receipt_long_rounded,
                    title: 'No fee records found',
                    subtitle: 'Try another filter or set a fee plan.',
                  )
                else
                  ...visible.map(
                    (summary) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _FeeStudentCard(
                        summary: summary,
                        onOpenDetail: () => _openFeeDetail(appUser, summary),
                        onCollect:
                            !appUser.canCollectFees || summary.pending <= 0
                            ? null
                            : () => _showCollectPaymentSheet(appUser, summary),
                        onSetPlan: appUser.canEditFeePlan
                            ? () => _showFeePlanSheet(summary)
                            : null,
                        onShareLatest:
                            !appUser.canShareReceipt ||
                                summary.latestPaidRecord == null
                            ? null
                            : () => _shareLatestReceipt(summary),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _loadFeesData() async {
    debugPrint('Fees: loading data from Firestore');
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final data = await _fetchFeesData();
      if (!mounted) return;
      setState(() {
        _feeSummaries = data.summaries;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshInline() async {
    debugPrint('Fees: refreshing inline');
    setState(() => _isInlineLoading = true);
    try {
      final data = await _fetchFeesData();
      if (!mounted) return;
      setState(() {
        _feeSummaries = data.summaries;
        _isInlineLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isInlineLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fees could not be refreshed: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<_FeesLoadData> _fetchFeesData() async {
    final firestore = FirebaseFirestore.instance;
    final results = await Future.wait([
      firestore.collection('students').where('deleted_at', isNull: true).get(),
      firestore.collection('courses').where('deleted_at', isNull: true).get(),
      firestore
          .collection('enrollments')
          .where('deleted_at', isNull: true)
          .get(),
      firestore
          .collection('fee_payments')
          .where('deleted_at', isNull: true)
          .get(),
    ]);

    final studentDocs = results[0].docs;
    final courseDocs = results[1].docs;
    final enrollmentDocs = results[2].docs;
    final feeDocs = results[3].docs;

    final courses = courseDocs.map(_CourseOption.fromDoc).toList();
    final enrollments = enrollmentDocs.map(_EnrollmentInfo.fromDoc).toList();
    final fees = feeDocs.map(_FeeRecord.fromDoc).toList();

    final courseById = {for (final course in courses) course.numericId: course};
    final enrollmentsByStudent = <int, List<_EnrollmentInfo>>{};
    for (final enrollment in enrollments) {
      enrollmentsByStudent
          .putIfAbsent(enrollment.studentId, () => [])
          .add(enrollment);
    }

    final feeByStudent = <int, List<_FeeRecord>>{};
    for (final fee in fees) {
      if (fee.studentId != null) {
        feeByStudent.putIfAbsent(fee.studentId!, () => []).add(fee);
      }
    }

    final summaries = <_StudentFeeSummary>[];
    for (final doc in studentDocs) {
      final student = StudentModel.fromFirestore(doc);
      final studentId = student.numericId;
      if (studentId == null) continue;
      final studentEnrollments = enrollmentsByStudent[studentId] ?? const [];
      final primaryEnrollment = studentEnrollments.isEmpty
          ? null
          : studentEnrollments.last;
      final course = primaryEnrollment == null
          ? null
          : courseById[primaryEnrollment.courseId];
      final records = feeByStudent[studentId] ?? const [];

      summaries.add(
        _StudentFeeSummary.fromData(
          student: student,
          enrollment: primaryEnrollment,
          course: course,
          records: records,
        ),
      );
    }

    summaries.sort(
      (a, b) => a.student.displayName.compareTo(b.student.displayName),
    );
    return _FeesLoadData(
      summaries: summaries,
      courses: courses,
      enrollments: enrollments,
    );
  }

  List<_StudentFeeSummary> _filteredSummaries() {
    final today = _dateOnly(DateTime.now());
    final weekEnd = today.add(const Duration(days: 7));
    return _feeSummaries.where((summary) {
      final haystack = [
        summary.student.displayName,
        summary.student.phone,
        summary.student.parentName,
        summary.student.parentPhone,
        summary.courseName,
        summary.batchName,
      ].whereType<String>().join(' ').toLowerCase();

      final matchesSearch =
          _searchQuery.isEmpty || haystack.contains(_searchQuery);
      final matchesFilter = switch (_selectedFilter) {
        _FeeFilter.all => true,
        _FeeFilter.pending => summary.pending > 0 && summary.paid <= 0,
        _FeeFilter.paid => summary.pending <= 0 && summary.finalFee > 0,
        _FeeFilter.partial => summary.pending > 0 && summary.paid > 0,
        _FeeFilter.dueToday =>
          summary.nextDueDate != null &&
              _dateOnly(summary.nextDueDate!) == today,
        _FeeFilter.dueThisWeek =>
          summary.nextDueDate != null &&
              !summary.nextDueDate!.isBefore(today) &&
              !summary.nextDueDate!.isAfter(weekEnd),
      };
      return matchesSearch && matchesFilter;
    }).toList();
  }

  Future<void> _showCollectPaymentSheet(
    AppUserModel appUser,
    _StudentFeeSummary summary,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return _CollectPaymentSheet(
          summary: summary,
          onSave: (draft) => _savePayment(appUser, summary, draft),
        );
      },
    );
  }

  Future<void> _openFeeDetail(
    AppUserModel appUser,
    _StudentFeeSummary summary,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => FeeDetailScreen(
          initialData: _toFeeDetailData(summary),
          canCollectFees: appUser.canCollectFees,
          canEditFeePlan: appUser.canEditFeePlan,
          canViewHistory: appUser.can(PermissionKeys.feesViewHistory),
          canEditPaymentHistory: appUser.canEditPaymentHistory,
          onCollectFee: () async {
            final current = _summaryForStudent(summary) ?? summary;
            await _showCollectPaymentSheet(appUser, current);
            final updated = _summaryForStudent(summary);
            return updated == null ? null : _toFeeDetailData(updated);
          },
          onEditFeePlan: () async {
            final current = _summaryForStudent(summary) ?? summary;
            await _showFeePlanSheet(current);
            final updated = _summaryForStudent(summary);
            return updated == null ? null : _toFeeDetailData(updated);
          },
          onEditPaymentHistory: (item) async {
            final current = _summaryForStudent(summary) ?? summary;
            await _showEditPaymentHistorySheet(appUser, current, item);
            final updated = _summaryForStudent(summary);
            return updated == null ? null : _toFeeDetailData(updated);
          },
        ),
      ),
    );
  }

  static bool _isSameStudent(StudentModel a, StudentModel b) {
    if (a.numericId != null && b.numericId != null) {
      return a.numericId == b.numericId;
    }
    return a.id.isNotEmpty && a.id == b.id;
  }

  _StudentFeeSummary? _summaryForStudent(_StudentFeeSummary summary) {
    for (final item in _feeSummaries) {
      if (_isSameStudent(item.student, summary.student)) return item;
    }
    return null;
  }

  FeeDetailData _toFeeDetailData(_StudentFeeSummary summary) {
    return FeeDetailData(
      studentName: summary.student.displayName,
      subtitle: summary.subtitle,
      courseName: summary.courseName,
      batchName: summary.batchName,
      totalFee: summary.finalFee,
      paid: summary.paid,
      pending: summary.pending,
      nextDueDate: summary.nextDueDate,
      status: summary.statusLabel,
      installments: _installmentRows(summary),
      history: _historyItems(summary),
      latestReceipt: _receiptPreview(summary),
    );
  }

  List<FeeInstallmentRow> _installmentRows(_StudentFeeSummary summary) {
    final plannedRecords =
        summary.records
            .where(
              (record) => !record.isReceipt && record.installmentNo != null,
            )
            .toList()
          ..sort((a, b) {
            final numberCompare = a.installmentNo!.compareTo(b.installmentNo!);
            if (numberCompare != 0) return numberCompare;
            final aDate = a.dueDate ?? DateTime(2099);
            final bDate = b.dueDate ?? DateTime(2099);
            return aDate.compareTo(bDate);
          });

    if (plannedRecords.isNotEmpty) {
      return plannedRecords.map((record) {
        final paid = record.paidAmount;
        final pending = record.pendingAmount;
        final double plannedAmount;
        if (record.isPaid) {
          plannedAmount = record.totalAmount > paid ? record.totalAmount : paid;
        } else {
          final sum = paid + pending;
          plannedAmount = sum > 0 ? sum : record.totalAmount;
        }
        final status = record.isPaid
            ? 'Paid'
            : paid > 0
            ? 'Partial'
            : 'Pending';
        return FeeInstallmentRow(
          number: record.installmentNo ?? 1,
          amount: plannedAmount > 0 ? plannedAmount : record.totalAmount,
          paidAmount: paid,
          dueDate: record.dueDate ?? DateTime.now(),
          status: status,
        );
      }).toList();
    }

    final count =
        summary.enrollment?.installmentCount ??
        _countForPlan(summary.enrollment?.planType ?? 'oneTime');
    final startDate =
        summary.enrollment?.nextDueDate ??
        summary.nextDueDate ??
        DateTime.now();
    final amount = summary.finalFee / (count <= 0 ? 1 : count);
    var remainingPaid = summary.paid;
    return List.generate(count <= 0 ? 1 : count, (index) {
      final paidForRow = remainingPaid >= amount ? amount : remainingPaid;
      remainingPaid -= paidForRow;
      final status = paidForRow >= amount
          ? 'Paid'
          : paidForRow > 0
          ? 'Partial'
          : 'Pending';
      return FeeInstallmentRow(
        number: index + 1,
        amount: amount,
        paidAmount: paidForRow,
        dueDate: DateTime(
          startDate.year,
          startDate.month + index,
          startDate.day,
        ),
        status: status,
      );
    });
  }

  List<FeeHistoryItem> _historyItems(_StudentFeeSummary summary) {
    final receiptRecordNos = summary.records
        .where((record) => record.isReceipt && record.paidAmount > 0)
        .map((record) => record.receiptNo)
        .toSet();
    final paidRecords =
        summary.records
            .where(
              (record) =>
                  record.hasPayment &&
                  (record.isReceipt ||
                      !receiptRecordNos.contains(record.receiptNo)),
            )
            .toList()
          ..sort((a, b) {
            final aDate = a.paymentDate ?? DateTime(2000);
            final bDate = b.paymentDate ?? DateTime(2000);
            return bDate.compareTo(aDate);
          });
    return paidRecords
        .map(
          (record) => FeeHistoryItem(
            recordId: record.docId,
            receiptNo: record.receiptNo,
            amount: record.paidAmount,
            mode: record.paymentMode,
            date: record.paymentDate,
            receivedBy: record.receivedBy,
            remarks: record.remarks,
            receipt: _receiptFromRecord(summary, record),
          ),
        )
        .toList();
  }

  ReceiptModel? _receiptPreview(_StudentFeeSummary summary) {
    final record = summary.latestPaidRecord;
    if (record == null) return null;
    return _receiptFromRecord(summary, record);
  }

  Future<void> _shareLatestReceipt(_StudentFeeSummary summary) async {
    final record = summary.latestPaidRecord;
    if (record == null) return;
    final receipt = _receiptFromRecord(summary, record);
    final shared = await ReceiptPdfService.shareReceipt(receipt);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          shared
              ? 'Receipt PDF ready to share.'
              : 'Receipt generated, sharing is not supported on this platform.',
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: shared ? AppTheme.success : AppTheme.warning,
      ),
    );
  }

  ReceiptModel _receiptFromRecord(
    _StudentFeeSummary summary,
    _FeeRecord record,
  ) {
    final settings = InstituteSettingsService.instance.cachedOrDefault;
    return ReceiptModel(
      instituteName: settings.instituteName,
      instituteAddress: settings.address,
      institutePhone: settings.phone,
      instituteEmail: settings.email,
      logoUrl: settings.logoUrl,
      signatureUrl: settings.signatureUrl,
      receiptFooter: settings.receiptFooter,
      currencySymbol: settings.currencySymbol,
      receiptNo: record.receiptNo,
      studentName: summary.student.displayName,
      studentPhone: summary.student.primaryPhone.isEmpty
          ? null
          : summary.student.primaryPhone,
      parentName: summary.student.parentName,
      parentPhone: summary.student.parentPhone,
      courseName: summary.courseName,
      batchName: summary.batchName,
      academicYear: settings.academicYear,
      amountPaid: record.paidAmount,
      paymentMode: record.paymentMode,
      paymentDate: record.paymentDate,
      installmentNo: record.installmentNo,
      remarks: record.remarks,
      receivedByName: record.receivedBy,
      pendingAfterPayment: _amount(
        record.data['pendingAfterPayment'] ??
            record.data['pending_after_payment'] ??
            summary.pending,
      ),
      totalFee: _amount(record.data['totalFee'] ?? summary.finalFee),
      totalPaid: _amount(record.data['totalPaid'] ?? summary.paid),
      generatedAt: DateTime.now(),
    );
  }

  Future<void> _savePayment(
    AppUserModel appUser,
    _StudentFeeSummary summary,
    _PaymentDraft draft,
  ) async {
    if (draft.amount <= 0) {
      throw Exception('Enter a valid payment amount.');
    }
    if (draft.amount > summary.pending) {
      throw Exception('Amount cannot be greater than pending fee.');
    }
    if (!_paymentModes.contains(draft.mode)) {
      throw Exception('Select a valid payment mode.');
    }

    debugPrint('Fees: saving payment draft');
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();
    final now = DateTime.now();
    final nowIso = now.toIso8601String();
    final settings = await InstituteSettingsService.instance.loadSettings();
    final receiptNo =
        '${settings.receiptPrefix}-${DateFormat('yyyyMMdd').format(now)}-${now.millisecondsSinceEpoch.toString().substring(7)}';
    final authUser = AuthService.instance.currentUser;
    final receivedByName = appUser.name.trim().isEmpty
        ? appUser.email
        : appUser.name.trim();
    final pendingAfterPayment = (summary.pending - draft.amount) < 0
        ? 0.0
        : summary.pending - draft.amount;
    final totalPaidAfterPayment = summary.paid + draft.amount;
    final receiptModel = ReceiptModel(
      instituteName: settings.instituteName,
      instituteAddress: settings.address,
      institutePhone: settings.phone,
      instituteEmail: settings.email,
      logoUrl: settings.logoUrl,
      signatureUrl: settings.signatureUrl,
      receiptFooter: settings.receiptFooter,
      currencySymbol: settings.currencySymbol,
      receiptNo: receiptNo,
      studentName: summary.student.displayName,
      studentPhone: summary.student.primaryPhone.isEmpty
          ? null
          : summary.student.primaryPhone,
      parentName: summary.student.parentName,
      parentPhone: summary.student.parentPhone,
      courseName: summary.courseName,
      batchName: summary.batchName,
      academicYear: settings.academicYear,
      amountPaid: draft.amount,
      paymentMode: draft.mode,
      paymentDate: draft.paymentDate,
      installmentNo: draft.installmentNo,
      remarks: draft.note,
      receivedByName: receivedByName,
      pendingAfterPayment: pendingAfterPayment,
      totalFee: summary.finalFee,
      totalPaid: totalPaidAfterPayment,
      generatedAt: now,
    );

    var remainingAmount = draft.amount;
    final pendingRecords =
        summary.records
            .where((record) => record.isPending && record.pendingAmount > 0)
            .toList()
          ..sort((a, b) {
            final aDate = a.dueDate ?? DateTime(2099);
            final bDate = b.dueDate ?? DateTime(2099);
            return aDate.compareTo(bDate);
          });

    final changedRecords = <_FeeRecord>[];
    for (final record in pendingRecords) {
      if (remainingAmount <= 0) break;
      final applied = remainingAmount >= record.pendingAmount
          ? record.pendingAmount
          : remainingAmount;
      remainingAmount -= applied;
      final newPending = record.pendingAmount - applied;
      final newPaid = record.paidAmount + applied;
      final updated = record.copyWith(
        data: {
          ...record.data,
          'amount_paid': newPaid.toStringAsFixed(2),
          'total_amount': newPending <= 0
              ? (newPaid > record.totalAmount ? newPaid : record.totalAmount)
                  .toStringAsFixed(2)
              : newPending.toStringAsFixed(2),
          // Keep every legacy balance alias in sync. Some older fee-plan
          // records include `dueAmount`, which takes precedence when the
          // dashboard calculates pending fees. Updating only total_amount
          // made a corrected installment look right in history while the
          // summary still used the old due balance.
          'dueAmount': newPending,
          'pendingAmount': newPending,
          'pending_amount': newPending,
          'balance': newPending,
          'remaining': newPending,
          'status': newPending <= 0 ? 'paid' : 'pending',
          'payment_mode': draft.mode,
          'paymentMode': draft.mode,
          'mode': draft.mode,
          'transaction_id': draft.note,
          'remarks': draft.note,
          'receipt_number': receiptNo,
          'receiptNo': receiptNo,
          'payment_date': draft.paymentDate.toIso8601String(),
          'paymentDate': Timestamp.fromDate(draft.paymentDate),
          'paidDate': draft.paymentDate.toIso8601String(),
          'receivedBy': authUser?.uid ?? appUser.uid,
          'receivedByName': receivedByName,
          'pendingAfterPayment': pendingAfterPayment,
          'pending_after_payment': pendingAfterPayment,
          'totalPaid': totalPaidAfterPayment,
          'updated_at': nowIso,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
      changedRecords.add(updated);
      batch.set(
        firestore.collection('fee_payments').doc(record.docId),
        updated.data,
        SetOptions(merge: true),
      );
    }

    if (pendingRecords.isNotEmpty) {
      final receiptRef = firestore.collection('fee_payments').doc();
      final receiptData = _paymentRecordData(
        docId: receiptRef.id,
        summary: summary,
        draft: draft,
        amount: draft.amount,
        receiptNo: receiptNo,
        receivedBy: authUser?.uid ?? appUser.uid,
        receivedByName: receivedByName,
        pendingAfterPayment: pendingAfterPayment,
        totalPaid: totalPaidAfterPayment,
        nowIso: nowIso,
      );
      receiptData.addAll({
        'recordType': 'receipt',
        'feeType': 'receipt',
        'total_amount': '0.00',
      });
      changedRecords.add(_FeeRecord.fromRaw(receiptRef.id, receiptData));
      batch.set(receiptRef, receiptData);
    }

    if (pendingRecords.isEmpty) {
      final docRef = firestore.collection('fee_payments').doc();
      final paidRecordData = _paymentRecordData(
        docId: docRef.id,
        summary: summary,
        draft: draft,
        amount: draft.amount,
        receiptNo: receiptNo,
        receivedBy: authUser?.uid ?? appUser.uid,
        receivedByName: receivedByName,
        pendingAfterPayment: pendingAfterPayment,
        totalPaid: totalPaidAfterPayment,
        nowIso: nowIso,
      );
      paidRecordData.addAll({
        'recordType': 'receipt',
        'feeType': 'receipt',
        'total_amount': '0.00',
      });
      changedRecords.add(_FeeRecord.fromRaw(docRef.id, paidRecordData));
      batch.set(docRef, paidRecordData);
    }

    final enrollment = summary.enrollment;
    if (enrollment != null) {
      batch.set(
        firestore.collection('enrollments').doc(enrollment.docId),
        {
          'paid_amount': totalPaidAfterPayment,
          'pending_amount': pendingAfterPayment,
          'dueAmount': pendingAfterPayment,
          'balance': pendingAfterPayment,
          'remaining': pendingAfterPayment,
          'updated_at': nowIso,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }

    await batch.commit();

    if (!mounted) return;
    setState(() {
      _feeSummaries = _feeSummaries.map((item) {
        if (!_isSameStudent(item.student, summary.student)) return item;
        final recordsById = {
          for (final record in item.records) record.docId: record,
        };
        for (final record in changedRecords) {
          recordsById[record.docId] = record;
        }
        return _StudentFeeSummary.fromData(
          student: item.student,
          enrollment: item.enrollment,
          course: item.course,
          records: recordsById.values.toList(),
        );
      }).toList();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment saved. Receipt $receiptNo'),
        backgroundColor: Colors.teal,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'View Receipt',
          textColor: Colors.white,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => ReceiptScreen(receipt: receiptModel),
              ),
            );
          },
        ),
      ),
    );
  }

  Map<String, dynamic> _paymentRecordData({
    required String docId,
    required _StudentFeeSummary summary,
    required _PaymentDraft draft,
    required double amount,
    required String receiptNo,
    required String receivedBy,
    required String receivedByName,
    required double pendingAfterPayment,
    required double totalPaid,
    required String nowIso,
  }) {
    return {
      'id': DateTime.now().millisecondsSinceEpoch % 100000,
      'student_id': summary.student.numericId,
      'studentId': summary.student.numericId?.toString(),
      'studentName': summary.student.displayName,
      'student_name': summary.student.displayName,
      'enrollment_id': summary.enrollment?.id,
      'courseId': summary.course?.id,
      'courseName': summary.courseName,
      'batchId':
          summary.enrollment?.batchId?.toString() ?? summary.student.batchId,
      'batchName': summary.batchName,
      'total_amount': amount.toStringAsFixed(2),
      'amount_paid': amount.toStringAsFixed(2),
      'amount': amount,
      'status': 'paid',
      'payment_mode': draft.mode,
      'paymentMode': draft.mode,
      'mode': draft.mode,
      'transaction_id': draft.note,
      'remarks': draft.note,
      'note': draft.note,
      'receipt_number': receiptNo,
      'receiptNo': receiptNo,
      'payment_date': draft.paymentDate.toIso8601String(),
      'paymentDate': Timestamp.fromDate(draft.paymentDate),
      'paidDate': draft.paymentDate.toIso8601String(),
      'receivedBy': receivedBy,
      'receivedByName': receivedByName,
      'pendingAfterPayment': pendingAfterPayment,
      'pending_after_payment': pendingAfterPayment,
      'totalPaid': totalPaid,
      'month_year': draft.installmentLabel ?? 'Fee Payment',
      'installmentNo': draft.installmentNo,
      'created_at': nowIso,
      'updated_at': nowIso,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'deleted_at': null,
    };
  }

  Future<void> _showFeePlanSheet(_StudentFeeSummary summary) async {
    final courseDefaultFee = summary.course?.defaultFee ?? summary.finalFee;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return _FeePlanSheet(
          summary: summary,
          defaultFee: courseDefaultFee,
          onSave: (draft) => _saveFeePlan(summary, draft),
        );
      },
    );
  }

  Future<void> _showEditPaymentHistorySheet(
    AppUserModel appUser,
    _StudentFeeSummary summary,
    FeeHistoryItem item,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _EditPaymentHistorySheet(
        item: item,
        onSave: (draft) =>
            _savePaymentHistoryEdit(appUser, summary, item, draft),
      ),
    );
  }

  Future<void> _savePaymentHistoryEdit(
    AppUserModel appUser,
    _StudentFeeSummary summary,
    FeeHistoryItem item,
    _PaymentHistoryEditDraft draft,
  ) async {
    if (draft.amount <= 0) {
      throw Exception('Enter a valid payment amount.');
    }
    if (!_paymentModes.contains(draft.mode)) {
      throw Exception('Select a valid payment mode.');
    }

    // A receipt can have one receipt record plus one or more installment
    // records. Keep its shared fields in sync so history and generated PDFs
    // always show the same corrected information.
    final linkedRecords = item.receiptNo == 'Receipt'
        ? summary.records.where((record) => record.docId == item.recordId)
        : summary.records.where((record) => record.receiptNo == item.receiptNo);
    final records = linkedRecords.toList();
    if (records.isEmpty) {
      throw Exception(
        'This payment record is no longer available. Refresh and try again.',
      );
    }

    final receiptNumbers = summary.records
        .where((record) => record.isReceipt && record.paidAmount > 0)
        .map((record) => record.receiptNo)
        .toSet();
    final paymentRecords = summary.records
        .where(
          (record) =>
              record.hasPayment &&
              (record.isReceipt || !receiptNumbers.contains(record.receiptNo)),
        )
        .toList();
    final correctedTotalPaid = paymentRecords.fold<double>(0, (total, record) {
      final isEditedPayment =
          record.docId == item.recordId ||
          (record.isReceipt && record.receiptNo == item.receiptNo);
      return total + (isEditedPayment ? draft.amount : record.paidAmount);
    });
    if (correctedTotalPaid > summary.finalFee + 0.009) {
      throw Exception(
        'Total collected amount cannot be greater than the final fee.',
      );
    }

    final now = DateTime.now();
    final nowIso = now.toIso8601String();
    final authUser = AuthService.instance.currentUser;
    final editorName = appUser.name.trim().isEmpty
        ? appUser.email
        : appUser.name.trim();
    final audit = <String, dynamic>{
      'previousAmount': item.amount,
      'previousPaymentDate': item.date?.toIso8601String(),
      'previousPaymentMode': item.mode,
      'previousRemarks': item.remarks,
      'editedAt': Timestamp.fromDate(now),
      'editedBy': authUser?.uid ?? appUser.uid,
      'editedByName': editorName,
    };
    final batch = FirebaseFirestore.instance.batch();
    final updatedById = {
      for (final record in summary.records) record.docId: record,
    };
    final changedRecordIds = <String>{};

    for (final record in records) {
      final isAmountRecord = record.docId == item.recordId || record.isReceipt;
      final data = <String, dynamic>{
        ...record.data,
        if (isAmountRecord) 'amount': draft.amount,
        if (isAmountRecord) 'amount_paid': draft.amount.toStringAsFixed(2),
        'payment_date': draft.paymentDate.toIso8601String(),
        'paymentDate': Timestamp.fromDate(draft.paymentDate),
        'paidDate': draft.paymentDate.toIso8601String(),
        'payment_mode': draft.mode,
        'paymentMode': draft.mode,
        'mode': draft.mode,
        'remarks': draft.remarks,
        'note': draft.remarks,
        'paymentHistoryLastEdit': audit,
        'paymentHistoryLastEditedAt': Timestamp.fromDate(now),
        'paymentHistoryLastEditedBy': authUser?.uid ?? appUser.uid,
        'paymentHistoryLastEditedByName': editorName,
        'paymentHistoryEditCount':
            (_int(record.data['paymentHistoryEditCount']) ?? 0) + 1,
        'updated_at': nowIso,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      updatedById[record.docId] = record.copyWith(data: data);
      changedRecordIds.add(record.docId);
    }

    // Rebuild installment balances from the receipt ledger. A planned
    // installment stores its remaining amount in total_amount, so changing a
    // historical payment must redistribute all payments to keep Paid and
    // Pending totals correct.
    final installments =
        summary.records
            .where(
              (record) => !record.isReceipt && record.installmentNo != null,
            )
            .toList()
          ..sort((a, b) {
            final numberCompare = a.installmentNo!.compareTo(b.installmentNo!);
            if (numberCompare != 0) return numberCompare;
            return (a.dueDate ?? DateTime(2099)).compareTo(
              b.dueDate ?? DateTime(2099),
            );
          });
    final correctedPayments =
        paymentRecords.map((record) {
          final current = updatedById[record.docId] ?? record;
          final isEditedPayment =
              record.docId == item.recordId ||
              (record.isReceipt && record.receiptNo == item.receiptNo);
          return _CorrectedPayment(
            record: current,
            amount: isEditedPayment ? draft.amount : record.paidAmount,
          );
        }).toList()..sort((a, b) {
          final dateCompare = (a.record.paymentDate ?? DateTime(2000))
              .compareTo(b.record.paymentDate ?? DateTime(2000));
          if (dateCompare != 0) return dateCompare;
          return a.record.docId.compareTo(b.record.docId);
        });

    if (installments.isNotEmpty) {
      final plannedAmounts = <String, double>{
        for (final record in installments)
          record.docId: record.isPaid
              ? record.totalAmount
              : record.totalAmount + record.paidAmount,
      };
      final paidByInstallment = <String, double>{
        for (final record in installments) record.docId: 0,
      };
      for (final payment in correctedPayments) {
        var remaining = payment.amount;
        for (final installment in installments) {
          if (remaining <= 0.009) break;
          final planned = plannedAmounts[installment.docId] ?? 0;
          final alreadyPaid = paidByInstallment[installment.docId] ?? 0;
          final available = planned - alreadyPaid;
          if (available <= 0.009) continue;
          final applied = remaining < available ? remaining : available;
          paidByInstallment[installment.docId] = alreadyPaid + applied;
          remaining -= applied;
        }
      }

      for (final installment in installments) {
        final current = updatedById[installment.docId] ?? installment;
        final planned = plannedAmounts[installment.docId] ?? 0;
        final paid = paidByInstallment[installment.docId] ?? 0;
        final remaining = (planned - paid).clamp(0, double.infinity).toDouble();
        final isPaid = remaining <= 0.009;
        final data = <String, dynamic>{
          ...current.data,
          'amount_paid': paid.toStringAsFixed(2),
          'total_amount': (isPaid ? planned : remaining).toStringAsFixed(2),
          // Fee records have used several names for their outstanding
          // balance. They must all reflect the recalculated installment so
          // the detail header, Fees summary, reports and student portal see
          // the same Paid/Pending values immediately after an edit.
          'dueAmount': remaining,
          'pendingAmount': remaining,
          'pending_amount': remaining,
          'balance': remaining,
          'remaining': remaining,
          'status': isPaid ? 'paid' : 'pending',
          'updated_at': nowIso,
          'updatedAt': FieldValue.serverTimestamp(),
        };
        updatedById[installment.docId] = current.copyWith(data: data);
        changedRecordIds.add(installment.docId);
      }
    }

    var runningPaid = 0.0;
    for (final payment in correctedPayments) {
      runningPaid += payment.amount;
      final current = updatedById[payment.record.docId] ?? payment.record;
      final pendingAfter = (summary.finalFee - runningPaid)
          .clamp(0, double.infinity)
          .toDouble();
      final data = <String, dynamic>{
        ...current.data,
        if (current.isReceipt) 'amount': payment.amount,
        if (current.isReceipt) 'amount_paid': payment.amount.toStringAsFixed(2),
        'totalPaid': runningPaid,
        'pendingAfterPayment': pendingAfter,
        'pending_after_payment': pendingAfter,
        'updated_at': nowIso,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      updatedById[current.docId] = current.copyWith(data: data);
      changedRecordIds.add(current.docId);
    }

    for (final recordId in changedRecordIds) {
      final updated = updatedById[recordId];
      if (updated == null) continue;
      batch.set(
        FirebaseFirestore.instance.collection('fee_payments').doc(recordId),
        updated.data,
        SetOptions(merge: true),
      );
    }

    final enrollment = summary.enrollment;
    if (enrollment != null) {
      final pending = (summary.finalFee - correctedTotalPaid)
          .clamp(0, double.infinity)
          .toDouble();
      batch.set(
        FirebaseFirestore.instance
            .collection('enrollments')
            .doc(enrollment.docId),
        {
          'paid_amount': correctedTotalPaid,
          'pending_amount': pending,
          'dueAmount': pending,
          'balance': pending,
          'remaining': pending,
          'updated_at': nowIso,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }
    await batch.commit();

    if (!mounted) return;
    setState(() {
      _feeSummaries = _feeSummaries.map((current) {
        if (!_isSameStudent(current.student, summary.student)) {
          return current;
        }
        return _StudentFeeSummary.fromData(
          student: current.student,
          enrollment: current.enrollment,
          course: current.course,
          records: updatedById.values.toList(),
        );
      }).toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment ${item.receiptNo} and fee totals updated.'),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _saveFeePlan(
    _StudentFeeSummary summary,
    _FeePlanDraft draft,
  ) async {
    if (draft.finalFee <= 0) {
      throw Exception('Enter a valid final fee.');
    }

    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();
    final now = DateTime.now();
    final nowIso = now.toIso8601String();
    final count = draft.installmentCount <= 0 ? 1 : draft.installmentCount;
    final amount = draft.finalFee / count;
    final enrollmentIntId =
        summary.enrollment?.id == null || summary.enrollment!.id == 0
        ? now.millisecondsSinceEpoch % 100000
        : summary.enrollment!.id;
    final enrollmentDocRef = summary.enrollment?.docId == null
        ? firestore.collection('enrollments').doc()
        : firestore.collection('enrollments').doc(summary.enrollment!.docId);
    final courseId =
        summary.course?.numericId ?? _int(summary.student.courseId) ?? 0;
    final batchId =
        summary.enrollment?.batchId ?? _int(summary.student.batchId) ?? 0;
    final enrollmentData = {
      'id': enrollmentIntId,
      'student_id': summary.student.numericId,
      'studentId': summary.student.numericId?.toString(),
      'studentName': summary.student.displayName,
      'course_id': courseId,
      'courseId': summary.course?.id ?? summary.student.courseId,
      'courseName': summary.courseName,
      'batch_id': batchId,
      'batchId': batchId.toString(),
      'batchName': summary.batchName,
      'fees_amount': summary.course?.defaultFee ?? draft.finalFee,
      'totalFee': draft.finalFee,
      'final_fees': draft.finalFee.toStringAsFixed(2),
      'finalFee': draft.finalFee,
      'discount': draft.discount,
      'planType': draft.planType,
      'installmentCount': count,
      'startDate': Timestamp.fromDate(draft.startDate),
      'start_date': draft.startDate.toIso8601String(),
      'nextDueDate': Timestamp.fromDate(draft.nextDueDate),
      'next_due_date': draft.nextDueDate.toIso8601String(),
      'status': 'active',
      'notes': draft.note,
      'paid_amount': summary.paid,
      'pending_amount': draft.finalFee - summary.paid,
      'dueAmount': draft.finalFee - summary.paid,
      'balance': draft.finalFee - summary.paid,
      'remaining': draft.finalFee - summary.paid,
      'updated_at': nowIso,
      'updatedAt': FieldValue.serverTimestamp(),
      'deleted_at': null,
      if (summary.enrollment?.docId == null) 'created_at': nowIso,
      if (summary.enrollment?.docId == null)
        'createdAt': FieldValue.serverTimestamp(),
    };
    batch.set(enrollmentDocRef, enrollmentData, SetOptions(merge: true));

    for (final record in summary.pendingRecords) {
      batch.set(
        firestore.collection('fee_payments').doc(record.docId),
        {
          'status': 'cancelled',
          'deleted_at': nowIso,
          'updated_at': nowIso,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }

    final newRecords = <_FeeRecord>[];

    for (var index = 0; index < count; index++) {
      final docRef = firestore.collection('fee_payments').doc();
      final dueDate = DateTime(
        draft.nextDueDate.year,
        draft.nextDueDate.month + index,
        draft.nextDueDate.day,
      );
      final data = {
        'id': (now.millisecondsSinceEpoch + index) % 100000,
        'student_id': summary.student.numericId,
        'studentId': summary.student.numericId?.toString(),
        'studentName': summary.student.displayName,
        'student_name': summary.student.displayName,
        'enrollment_id': enrollmentIntId,
        'enrollmentId': enrollmentIntId.toString(),
        'courseId': summary.course?.id,
        'course_id': courseId,
        'courseName': summary.courseName,
        'batchId': batchId.toString(),
        'batch_id': batchId,
        'batchName': summary.batchName,
        'totalFee': draft.finalFee,
        'discount': draft.discount,
        'finalFee': draft.finalFee,
        'planType': draft.planType,
        'installmentCount': count,
        'installmentNo': index + 1,
        'total_amount': amount.toStringAsFixed(2),
        'amount_paid': '0.00',
        'status': 'pending',
        'feeType': 'installment',
        'due_date': dueDate.toIso8601String(),
        'dueDate': Timestamp.fromDate(dueDate),
        'nextDueDate': Timestamp.fromDate(draft.nextDueDate),
        'month_year': count == 1
            ? 'Full Course'
            : 'Inst. ${index + 1} of $count',
        'remarks': draft.note,
        'created_at': nowIso,
        'updated_at': nowIso,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'deleted_at': null,
      };
      batch.set(docRef, data);
      newRecords.add(_FeeRecord.fromRaw(docRef.id, data));
    }

    await batch.commit();
    if (!mounted) return;
    final updatedEnrollment = _EnrollmentInfo(
      docId: enrollmentDocRef.id,
      id: enrollmentIntId,
      studentId: summary.student.numericId ?? 0,
      courseId: courseId,
      batchId: batchId,
      finalFees: draft.finalFee,
      batchName: summary.batchName,
      planType: draft.planType,
      installmentCount: count,
      startDate: draft.startDate,
      nextDueDate: draft.nextDueDate,
      discount: draft.discount,
      notes: draft.note,
    );
    setState(() {
      _feeSummaries = _feeSummaries.map((item) {
        if (!_isSameStudent(item.student, summary.student)) return item;
        return _StudentFeeSummary.fromData(
          student: item.student,
          enrollment: updatedEnrollment,
          course: item.course,
          records: [
            ...item.records.where((record) => !record.isPending),
            ...newRecords,
          ],
        );
      }).toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fee plan saved.'),
        backgroundColor: Colors.teal,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fees',
          style: TextStyle(
            color: AppTheme.text,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Mak Tutorials fee collection and payment plans',
          style: TextStyle(color: AppTheme.muted, fontSize: 14),
        ),
      ],
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.totals});

  final _FeeTotals totals;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = constraints.maxWidth < 620
            ? (constraints.maxWidth - 12) / 2
            : (constraints.maxWidth - 36) / 4;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _SummaryTile(
              'Total Fees',
              _money(totals.total),
              Icons.account_balance_wallet_rounded,
              AppTheme.primary,
              itemWidth,
            ),
            _SummaryTile(
              'Collected',
              _money(totals.collected),
              Icons.check_circle_rounded,
              AppTheme.success,
              itemWidth,
            ),
            _SummaryTile(
              'Pending',
              _money(totals.pending),
              Icons.pending_actions_rounded,
              AppTheme.warning,
              itemWidth,
            ),
            _SummaryTile(
              'Due This Week',
              totals.dueThisWeek.toString(),
              Icons.event_busy_rounded,
              AppTheme.danger,
              itemWidth,
            ),
          ],
        );
      },
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile(this.title, this.value, this.icon, this.color, this.width);

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      constraints: const BoxConstraints(minHeight: 116),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 12),
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
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: AppTheme.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      style: const TextStyle(color: AppTheme.text),
      decoration: InputDecoration(
        hintText: 'Search name, phone, parent, batch or course...',
        hintStyle: const TextStyle(color: AppTheme.muted),
        prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primary),
        filled: true,
        fillColor: AppTheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.border),
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selected, required this.onChanged});

  final _FeeFilter selected;
  final ValueChanged<_FeeFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _FeeFilter.values.map((filter) {
        final isSelected = filter == selected;
        return ChoiceChip(
          selected: isSelected,
          label: Text(_filterLabel(filter)),
          onSelected: (_) => onChanged(filter),
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : AppTheme.text,
            fontWeight: FontWeight.w800,
          ),
          selectedColor: AppTheme.primary,
          backgroundColor: AppTheme.surface,
          side: const BorderSide(color: AppTheme.border),
        );
      }).toList(),
    );
  }
}

class _FeeStudentCard extends StatelessWidget {
  const _FeeStudentCard({
    required this.summary,
    required this.onOpenDetail,
    required this.onCollect,
    required this.onSetPlan,
    required this.onShareLatest,
  });

  final _StudentFeeSummary summary;
  final VoidCallback onOpenDetail;
  final VoidCallback? onCollect;
  final VoidCallback? onSetPlan;
  final VoidCallback? onShareLatest;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (summary.statusLabel) {
      'Paid' => AppTheme.success,
      'Partial' => AppTheme.primary,
      _ => AppTheme.warning,
    };
    final initial = summary.student.displayName.characters.first.toUpperCase();

    return InkWell(
      onTap: onOpenDetail,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
                  backgroundImage: summary.student.profilePhoto == null
                      ? null
                      : NetworkImage(summary.student.profilePhoto!),
                  child: summary.student.profilePhoto == null
                      ? Text(
                          initial,
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w900,
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
                        summary.student.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        summary.subtitle,
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
                _Badge(label: summary.statusLabel, color: statusColor),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _MiniMetric('Total', _money(summary.finalFee)),
                _MiniMetric('Paid', _money(summary.paid)),
                _MiniMetric('Pending', _money(summary.pending)),
                _MiniMetric(
                  'Next Due',
                  summary.nextDueDate == null
                      ? '--'
                      : DateFormat('dd MMM').format(summary.nextDueDate!),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                if (onCollect != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onCollect,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                        side: BorderSide(
                          color: AppTheme.primary.withValues(alpha: 0.45),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.payments_rounded, size: 18),
                      label: const Text('Collect Fee'),
                    ),
                  ),
                if (onCollect != null &&
                    (onSetPlan != null || onShareLatest != null))
                  const SizedBox(width: 10),
                if (onSetPlan != null)
                  IconButton(
                    tooltip: 'Set Fee Plan',
                    onPressed: onSetPlan,
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
                      foregroundColor: AppTheme.primary,
                    ),
                    icon: const Icon(Icons.tune_rounded),
                  ),
                if (onShareLatest != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Share Latest Receipt',
                    onPressed: onShareLatest,
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.background,
                      foregroundColor: AppTheme.muted,
                    ),
                    icon: const Icon(Icons.share_rounded),
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

class _MiniMetric extends StatelessWidget {
  const _MiniMetric(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppTheme.muted, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.text,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectPaymentSheet extends StatefulWidget {
  const _CollectPaymentSheet({required this.summary, required this.onSave});

  final _StudentFeeSummary summary;
  final Future<void> Function(_PaymentDraft draft) onSave;

  @override
  State<_CollectPaymentSheet> createState() => _CollectPaymentSheetState();
}

class _CollectPaymentSheetState extends State<_CollectPaymentSheet> {
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  DateTime _paymentDate = DateTime.now();
  String _mode = _paymentModes.first;
  String? _installmentRecordId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.summary.pending.toStringAsFixed(0),
    );
    _noteController = TextEditingController();
    _mode = _normalizedPaymentMode(_mode);
    _installmentRecordId = widget.summary.nextPendingRecord?.docId;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Collect Fee',
                    style: TextStyle(
                      color: AppTheme.text,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: _isSaving ? null : () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: AppTheme.muted),
                ),
              ],
            ),
            Text(
              widget.summary.student.displayName,
              style: const TextStyle(color: AppTheme.primary),
            ),
            const SizedBox(height: 2),
            Text(
              'Contact Admin if this fee plan needs changes.',
              style: const TextStyle(color: AppTheme.muted, fontSize: 12),
            ),
            const SizedBox(height: 18),
            _InfoPanel(
              title: 'Pending Amount',
              value: _money(widget.summary.pending),
              subtitle: widget.summary.subtitle,
            ),
            const SizedBox(height: 14),
            _SheetField(
              controller: _amountController,
              label: 'Amount Paid',
              icon: Icons.currency_rupee_rounded,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _normalizedPaymentMode(_mode),
              dropdownColor: AppTheme.surface,
              style: const TextStyle(color: AppTheme.text),
              decoration: _sheetDecoration(
                'Payment Mode',
                Icons.account_balance_wallet_rounded,
              ),
              items: _paymentModes
                  .map(
                    (mode) => DropdownMenuItem<String>(
                      value: mode,
                      child: Text(mode),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _mode = _normalizedPaymentMode(value));
                }
              },
            ),
            const SizedBox(height: 12),
            if (widget.summary.pendingRecords.isNotEmpty)
              DropdownButtonFormField<String?>(
                initialValue: _validInstallmentRecordId,
                dropdownColor: AppTheme.surface,
                style: const TextStyle(color: AppTheme.text),
                decoration: _sheetDecoration(
                  'Installment',
                  Icons.format_list_numbered_rounded,
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Auto adjust oldest dues'),
                  ),
                  ...widget.summary.pendingRecords.map(
                    (record) => DropdownMenuItem<String?>(
                      value: record.docId,
                      child: Text(record.monthYear),
                    ),
                  ),
                ],
                onChanged: (value) =>
                    setState(() => _installmentRecordId = value),
              ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(14),
              child: InputDecorator(
                decoration: _sheetDecoration(
                  'Payment Date',
                  Icons.calendar_month_rounded,
                ),
                child: Text(
                  DateFormat('dd MMM yyyy').format(_paymentDate),
                  style: const TextStyle(color: AppTheme.text),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _SheetField(
              controller: _noteController,
              label: 'Remarks / Transaction ID',
              icon: Icons.notes_rounded,
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.cloud_done_rounded),
                label: const Text(
                  'Collect & Receipt',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _paymentDate = picked);
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await widget.onSave(
        _PaymentDraft(
          amount: _amount(_amountController.text),
          mode: _mode,
          paymentDate: _paymentDate,
          note: _noteController.text.trim(),
          installmentNo: _selectedInstallment?.installmentNo,
          installmentLabel: _selectedInstallment?.monthYear,
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String? get _validInstallmentRecordId {
    final selected = _installmentRecordId;
    if (selected == null) return null;
    final exists = widget.summary.pendingRecords.any(
      (record) => record.docId == selected,
    );
    return exists ? selected : null;
  }

  _FeeRecord? get _selectedInstallment {
    final id = _validInstallmentRecordId;
    if (id == null) return widget.summary.nextPendingRecord;
    for (final record in widget.summary.pendingRecords) {
      if (record.docId == id) return record;
    }
    return widget.summary.nextPendingRecord;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}

class _EditPaymentHistorySheet extends StatefulWidget {
  const _EditPaymentHistorySheet({required this.item, required this.onSave});

  final FeeHistoryItem item;
  final Future<void> Function(_PaymentHistoryEditDraft draft) onSave;

  @override
  State<_EditPaymentHistorySheet> createState() =>
      _EditPaymentHistorySheetState();
}

class _EditPaymentHistorySheetState extends State<_EditPaymentHistorySheet> {
  late final TextEditingController _amountController;
  late final TextEditingController _remarksController;
  late DateTime _paymentDate;
  late String _mode;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _paymentDate = widget.item.date ?? DateTime.now();
    _mode = _normalizedPaymentMode(widget.item.mode);
    _amountController = TextEditingController(
      text: widget.item.amount.toStringAsFixed(2),
    );
    _remarksController = TextEditingController(text: widget.item.remarks);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Edit Payment Details',
                    style: TextStyle(
                      color: AppTheme.text,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: _isSaving ? null : () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: AppTheme.muted),
                ),
              ],
            ),
            Text(
              widget.item.receiptNo,
              style: const TextStyle(color: AppTheme.primary),
            ),
            const SizedBox(height: 4),
            const Text(
              'Correcting the amount also updates paid, pending, installments, and linked receipt totals.',
              style: TextStyle(color: AppTheme.muted, fontSize: 12),
            ),
            const SizedBox(height: 18),
            _SheetField(
              controller: _amountController,
              label: 'Amount Paid',
              icon: Icons.currency_rupee_rounded,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _isSaving ? null : _pickDate,
              borderRadius: BorderRadius.circular(14),
              child: InputDecorator(
                decoration: _sheetDecoration(
                  'Payment Date',
                  Icons.calendar_month_rounded,
                ),
                child: Text(
                  DateFormat('dd MMM yyyy').format(_paymentDate),
                  style: const TextStyle(color: AppTheme.text),
                ),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _mode,
              dropdownColor: AppTheme.surface,
              style: const TextStyle(color: AppTheme.text),
              decoration: _sheetDecoration(
                'Payment Mode',
                Icons.account_balance_wallet_rounded,
              ),
              items: _paymentModes
                  .map(
                    (mode) => DropdownMenuItem<String>(
                      value: mode,
                      child: Text(mode),
                    ),
                  )
                  .toList(),
              onChanged: _isSaving
                  ? null
                  : (value) {
                      if (value != null) setState(() => _mode = value);
                    },
            ),
            const SizedBox(height: 12),
            _SheetField(
              controller: _remarksController,
              label: 'Remarks',
              icon: Icons.notes_rounded,
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save_rounded),
                label: const Text(
                  'Save Payment Details',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _paymentDate = picked);
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await widget.onSave(
        _PaymentHistoryEditDraft(
          amount: _amount(_amountController.text),
          paymentDate: _paymentDate,
          mode: _mode,
          remarks: _remarksController.text.trim(),
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: AppTheme.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _remarksController.dispose();
    super.dispose();
  }
}

class _FeePlanSheet extends StatefulWidget {
  const _FeePlanSheet({
    required this.summary,
    required this.defaultFee,
    required this.onSave,
  });

  final _StudentFeeSummary summary;
  final double defaultFee;
  final Future<void> Function(_FeePlanDraft draft) onSave;

  @override
  State<_FeePlanSheet> createState() => _FeePlanSheetState();
}

class _FeePlanSheetState extends State<_FeePlanSheet> {
  late final TextEditingController _finalFeeController;
  late final TextEditingController _discountController;
  late final TextEditingController _noteController;
  String _planType = 'oneTime';
  int _installmentCount = 1;
  DateTime _startDate = DateTime.now();
  DateTime _nextDueDate = DateTime.now().add(const Duration(days: 7));
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _finalFeeController = TextEditingController(
      text: widget.summary.finalFee > 0
          ? widget.summary.finalFee.toStringAsFixed(0)
          : widget.defaultFee > 0
          ? widget.defaultFee.toStringAsFixed(0)
          : '',
    );
    _discountController = TextEditingController(
      text: widget.summary.enrollment?.discount.toStringAsFixed(0) ?? '0',
    );
    _noteController = TextEditingController(
      text: widget.summary.enrollment?.notes ?? '',
    );
    _planType = _normalizedPlanType(widget.summary.enrollment?.planType);
    _installmentCount =
        widget.summary.enrollment?.installmentCount ?? _countForPlan(_planType);
    _startDate = widget.summary.enrollment?.startDate ?? DateTime.now();
    _nextDueDate =
        widget.summary.enrollment?.nextDueDate ??
        DateTime.now().add(const Duration(days: 7));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Edit Fee Plan',
                    style: TextStyle(
                      color: AppTheme.text,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: _isSaving ? null : () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: AppTheme.muted),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              widget.summary.student.displayName,
              style: const TextStyle(color: AppTheme.primary),
            ),
            const SizedBox(height: 12),
            _InfoPanel(
              title: 'Course Fee Reference',
              value: _money(widget.defaultFee),
              subtitle: widget.summary.subtitle,
            ),
            const SizedBox(height: 16),
            _SheetField(
              controller: _finalFeeController,
              label: 'Final Fee',
              icon: Icons.currency_rupee_rounded,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            _SheetField(
              controller: _discountController,
              label: 'Discount',
              icon: Icons.percent_rounded,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _planType,
              dropdownColor: AppTheme.surface,
              style: const TextStyle(color: AppTheme.text),
              decoration: _sheetDecoration('Plan Type', Icons.tune_rounded),
              items: const [
                DropdownMenuItem(
                  value: 'oneTime',
                  child: Text('One-time payment'),
                ),
                DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                DropdownMenuItem(
                  value: 'installments3',
                  child: Text('3 installments'),
                ),
                DropdownMenuItem(
                  value: 'installments4',
                  child: Text('4 installments'),
                ),
                DropdownMenuItem(
                  value: 'custom',
                  child: Text('Custom installments'),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _planType = value;
                  _installmentCount = switch (value) {
                    'monthly' => 10,
                    'installments3' => 3,
                    'installments4' => 4,
                    'custom' => _installmentCount,
                    _ => 1,
                  };
                });
              },
            ),
            if (_planType == 'custom') ...[
              const SizedBox(height: 12),
              StepperControl(
                value: _installmentCount,
                onChanged: (value) =>
                    setState(() => _installmentCount = value.clamp(1, 36)),
              ),
            ],
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickStartDate,
              borderRadius: BorderRadius.circular(14),
              child: InputDecorator(
                decoration: _sheetDecoration(
                  'Start Date',
                  Icons.event_available_rounded,
                ),
                child: Text(
                  DateFormat('dd MMM yyyy').format(_startDate),
                  style: const TextStyle(color: AppTheme.text),
                ),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDueDate,
              borderRadius: BorderRadius.circular(14),
              child: InputDecorator(
                decoration: _sheetDecoration(
                  'Next Due Date',
                  Icons.calendar_month_rounded,
                ),
                child: Text(
                  DateFormat('dd MMM yyyy').format(_nextDueDate),
                  style: const TextStyle(color: AppTheme.text),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _SheetField(
              controller: _noteController,
              label: 'Notes',
              icon: Icons.notes_rounded,
            ),
            const SizedBox(height: 14),
            _InstallmentPreview(
              total: _amount(_finalFeeController.text),
              count: _installmentCount,
              startDate: _nextDueDate,
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save_rounded),
                label: const Text(
                  'Save Fee Plan',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextDueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => _nextDueDate = picked);
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await widget.onSave(
        _FeePlanDraft(
          finalFee: _amount(_finalFeeController.text),
          discount: _amount(_discountController.text),
          planType: _planType,
          installmentCount: _installmentCount,
          startDate: _startDate,
          nextDueDate: _nextDueDate,
          note: _noteController.text.trim(),
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _finalFeeController.dispose();
    _discountController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}

class StepperControl extends StatelessWidget {
  const StepperControl({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: value <= 1 ? null : () => onChanged(value - 1),
          icon: const Icon(Icons.remove_circle_outline, color: AppTheme.muted),
        ),
        Text(
          '$value installments',
          style: const TextStyle(
            color: AppTheme.text,
            fontWeight: FontWeight.w800,
          ),
        ),
        IconButton(
          onPressed: () => onChanged(value + 1),
          icon: const Icon(Icons.add_circle_outline, color: AppTheme.primary),
        ),
      ],
    );
  }
}

class _InstallmentPreview extends StatelessWidget {
  const _InstallmentPreview({
    required this.total,
    required this.count,
    required this.startDate,
  });

  final double total;
  final int count;
  final DateTime startDate;

  @override
  Widget build(BuildContext context) {
    final safeCount = count <= 0 ? 1 : count;
    final amount = safeCount == 0 ? total : total / safeCount;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Installment Preview',
            style: TextStyle(color: AppTheme.text, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          ...List.generate(safeCount, (index) {
            final dueDate = DateTime(
              startDate.year,
              startDate.month + index,
              startDate.day,
            );
            return Padding(
              padding: EdgeInsets.only(bottom: index == safeCount - 1 ? 0 : 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Installment ${index + 1}',
                      style: const TextStyle(color: AppTheme.muted),
                    ),
                  ),
                  Text(
                    '${_money(amount)} / ${DateFormat('dd MMM').format(dueDate)}',
                    style: const TextStyle(
                      color: AppTheme.text,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  const _SheetField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(color: AppTheme.text),
      decoration: _sheetDecoration(label, icon),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppTheme.muted)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.primary,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: AppTheme.muted)),
        ],
      ),
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
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 28),
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

class _FeesLoadData {
  const _FeesLoadData({
    required this.summaries,
    required this.courses,
    required this.enrollments,
  });

  final List<_StudentFeeSummary> summaries;
  final List<_CourseOption> courses;
  final List<_EnrollmentInfo> enrollments;
}

class _StudentFeeSummary {
  const _StudentFeeSummary({
    required this.student,
    required this.enrollment,
    required this.course,
    required this.records,
    required this.finalFee,
    required this.paid,
    required this.pending,
    required this.nextDueDate,
  });

  final StudentModel student;
  final _EnrollmentInfo? enrollment;
  final _CourseOption? course;
  final List<_FeeRecord> records;
  final double finalFee;
  final double paid;
  final double pending;
  final DateTime? nextDueDate;

  factory _StudentFeeSummary.fromData({
    required StudentModel student,
    required _EnrollmentInfo? enrollment,
    required _CourseOption? course,
    required List<_FeeRecord> records,
  }) {
    final nonReceiptRecords = records.where((r) => !r.isReceipt).toList();
    final receiptRecords = records.where((r) => r.isReceipt).toList();

    // Distinct payment records matching payment history & latest receipt
    final receiptRecordNos = records
        .where((record) => record.isReceipt && record.paidAmount > 0)
        .map((record) => record.receiptNo)
        .toSet();
    final paidRecords =
        records
            .where(
              (record) =>
                  record.hasPayment &&
                  (record.isReceipt ||
                      !receiptRecordNos.contains(record.receiptNo)),
            )
            .toList()
          ..sort((a, b) {
            final aDate = a.paymentDate ?? DateTime(2000);
            final bDate = b.paymentDate ?? DateTime(2000);
            return bDate.compareTo(aDate);
          });

    final latestPaid = paidRecords.isEmpty ? null : paidRecords.first;

    // Total fee resolution
    final totalFromNonReceipts = nonReceiptRecords.fold<double>(
      0,
      (runningTotal, record) => runningTotal + record.totalAmount,
    );
    final finalFee =
        enrollment?.finalFees ?? course?.defaultFee ?? totalFromNonReceipts;
    final resolvedFinalFee = finalFee > 0 ? finalFee : totalFromNonReceipts;

    // Sum of paid amounts from distinct payment transactions
    final paidFromHistory = paidRecords.fold<double>(
      0,
      (sum, record) => sum + record.paidAmount,
    );
    final paidFromReceipts = receiptRecords.fold<double>(
      0,
      (runningTotal, record) => runningTotal + record.paidAmount,
    );
    final paidFromNonReceipts = nonReceiptRecords
        .where((r) => r.isPaid || r.hasPayment)
        .fold<double>(
          0,
          (runningTotal, record) => runningTotal + record.paidAmount,
        );
    final fallbackPaid = paidFromReceipts > paidFromNonReceipts
        ? paidFromReceipts
        : paidFromNonReceipts;

    final latestTotalPaid = latestPaid != null
        ? _amount(latestPaid.data['totalPaid'])
        : 0.0;

    // Resolve paid:
    // If the latest receipt record explicitly holds totalPaid and it's >= paidFromHistory, use it.
    // Otherwise use paidFromHistory. If none, use receipt/non-receipt fallback or enrollment.paidAmount.
    double resolvedPaid = 0.0;
    if (latestTotalPaid > 0 && latestTotalPaid >= paidFromHistory) {
      resolvedPaid = latestTotalPaid;
    } else if (paidFromHistory > 0) {
      resolvedPaid = paidFromHistory;
    } else if (fallbackPaid > 0) {
      resolvedPaid = fallbackPaid;
    } else if (enrollment != null && enrollment.paidAmount > 0) {
      resolvedPaid = enrollment.paidAmount;
    }

    // Pending installment records
    final pendingRecords =
        records
            .where((record) => record.isPending && record.pendingAmount > 0)
            .toList()
          ..sort((a, b) {
            final aDate = a.dueDate ?? DateTime(2099);
            final bDate = b.dueDate ?? DateTime(2099);
            return aDate.compareTo(bDate);
          });
    final pendingFromRecords = pendingRecords.fold<double>(
      0,
      (runningTotal, record) => runningTotal + record.pendingAmount,
    );

    final latestPendingAfterPayment = latestPaid != null
        ? _amount(
            latestPaid.data['pendingAfterPayment'] ??
                latestPaid.data['pending_after_payment'],
          )
        : null;

    final mathPending = (resolvedFinalFee > resolvedPaid)
        ? (resolvedFinalFee - resolvedPaid)
        : 0.0;

    // Resolve pending:
    double resolvedPending;
    if (pendingRecords.isNotEmpty && pendingFromRecords > 0) {
      resolvedPending = pendingFromRecords;
    } else if (latestPendingAfterPayment != null && latestPendingAfterPayment > 0) {
      resolvedPending = latestPendingAfterPayment;
    } else if (mathPending > 0) {
      resolvedPending = mathPending;
    } else if (enrollment != null && enrollment.pendingAmount > 0) {
      resolvedPending = enrollment.pendingAmount;
    } else {
      resolvedPending = 0.0;
    }

    // Resolve nextDueDate:
    DateTime? resolvedNextDueDate;
    if (pendingRecords.isNotEmpty) {
      resolvedNextDueDate = pendingRecords.first.dueDate;
    }
    if (resolvedNextDueDate == null && resolvedPending > 0) {
      resolvedNextDueDate = enrollment?.nextDueDate ??
          FeeRecordValues.date(
            latestPaid?.data['nextDueDate'] ??
                latestPaid?.data['next_due_date'],
          );
    }

    return _StudentFeeSummary(
      student: student,
      enrollment: enrollment,
      course: course,
      records: records,
      finalFee: resolvedFinalFee,
      paid: resolvedPaid,
      pending: resolvedPending,
      nextDueDate: resolvedNextDueDate,
    );
  }

  String get courseName =>
      course?.name ?? student.courseName ?? 'Course not set';
  String get batchName =>
      enrollment?.batchName ?? student.batchName ?? 'Batch not set';
  String get subtitle => '$courseName / $batchName';
  String get statusLabel {
    if (pending <= 0 && finalFee > 0) return 'Paid';
    if (paid > 0 && pending > 0) return 'Partial';
    return 'Pending';
  }

  List<_FeeRecord> get pendingRecords =>
      records
          .where((record) => record.isPending && record.pendingAmount > 0)
          .toList()
        ..sort((a, b) {
          final aDate = a.dueDate ?? DateTime(2099);
          final bDate = b.dueDate ?? DateTime(2099);
          return aDate.compareTo(bDate);
        });

  _FeeRecord? get nextPendingRecord =>
      pendingRecords.isEmpty ? null : pendingRecords.first;
  _FeeRecord? get latestPaidRecord {
    final receiptRecordNos = records
        .where((record) => record.isReceipt && record.paidAmount > 0)
        .map((record) => record.receiptNo)
        .toSet();
    final paidRecords =
        records
            .where(
              (record) =>
                  record.hasPayment &&
                  (record.isReceipt ||
                      !receiptRecordNos.contains(record.receiptNo)),
            )
            .toList()
          ..sort((a, b) {
            final aDate = a.paymentDate ?? DateTime(2000);
            final bDate = b.paymentDate ?? DateTime(2000);
            return bDate.compareTo(aDate);
          });
    return paidRecords.isEmpty ? null : paidRecords.first;
  }
}

class _FeeRecord {
  const _FeeRecord({required this.docId, required this.data});

  final String docId;
  final Map<String, dynamic> data;

  factory _FeeRecord.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return _FeeRecord(docId: doc.id, data: doc.data());
  }

  factory _FeeRecord.fromRaw(String docId, Map<String, dynamic> data) {
    return _FeeRecord(docId: docId, data: data);
  }

  _FeeRecord copyWith({required Map<String, dynamic> data}) {
    return _FeeRecord(docId: docId, data: data);
  }

  int? get studentId => _int(data['student_id'] ?? data['studentId']);
  int? get enrollmentId => _int(data['enrollment_id']);
  double get totalAmount => _amount(
    data['total_amount'] ??
        data['totalFee'] ??
        data['finalFee'] ??
        data['amount'],
  );
  double get paidAmount {
    if (isReceipt) {
      return _amount(
        data['amount_paid'] ??
            data['amount'] ??
            data['amountPaid'] ??
            data['paid_amount'] ??
            data['totalPaid'],
      );
    }
    final directPaid = _amount(
      data['amount_paid'] ?? data['paid_amount'] ?? data['amountPaid'],
    );
    if (directPaid > 0) return directPaid;
    if (isPaid) {
      return _amount(
        data['amount'] ?? data['total_amount'] ?? data['dueAmount'],
      );
    }
    return 0.0;
  }
  double get pendingAmount => FeeRecordValues.outstanding(data);

  String get status => data['status']?.toString().toLowerCase() ?? 'pending';
  bool get isPending => FeeRecordValues.isOpen(data);
  bool get isPaid => status == 'paid';
  bool get isReceipt => FeeRecordValues.isReceipt(data);
  bool get hasPayment => paidAmount > 0 && (isPaid || receiptNo != 'Receipt');
  String get monthYear => data['month_year']?.toString() ?? 'Fee';
  int? get installmentNo =>
      _int(data['installmentNo'] ?? data['installment_no']);
  DateTime? get dueDate => FeeRecordValues.dueDate(data);
  DateTime? get paymentDate => _date(
    data['paymentDate'] ??
        data['payment_date'] ??
        data['paidDate'] ??
        data['createdAt'] ??
        data['created_at'],
  );
  String get receiptNo =>
      data['receiptNo']?.toString() ??
      data['receipt_number']?.toString() ??
      'Receipt';
  String get paymentMode =>
      data['paymentMode']?.toString() ??
      data['payment_mode']?.toString() ??
      data['mode']?.toString() ??
      'Cash';
  String get receivedBy =>
      data['receivedByName']?.toString() ??
      data['received_by_name']?.toString() ??
      data['receivedBy']?.toString() ??
      '--';
  String get remarks =>
      data['remarks']?.toString() ??
      data['transaction_id']?.toString() ??
      data['note']?.toString() ??
      '';
}

class _EnrollmentInfo {
  const _EnrollmentInfo({
    required this.docId,
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.batchId,
    required this.finalFees,
    this.batchName,
    this.planType,
    this.installmentCount,
    this.startDate,
    this.nextDueDate,
    this.discount = 0,
    this.notes,
    this.paidAmount = 0,
    this.pendingAmount = 0,
  });

  final String docId;
  final int id;
  final int studentId;
  final int courseId;
  final int? batchId;
  final double finalFees;
  final String? batchName;
  final String? planType;
  final int? installmentCount;
  final DateTime? startDate;
  final DateTime? nextDueDate;
  final double discount;
  final String? notes;
  final double paidAmount;
  final double pendingAmount;

  factory _EnrollmentInfo.fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return _EnrollmentInfo(
      docId: doc.id,
      id: _int(data['id']) ?? 0,
      studentId: _int(data['student_id']) ?? 0,
      courseId: _int(data['course_id']) ?? 0,
      batchId: _int(data['batch_id']),
      finalFees: _amount(
        data['final_fees'] ?? data['finalFee'] ?? data['totalFee'],
      ),
      batchName:
          data['batchName']?.toString() ?? data['batch_name']?.toString(),
      planType: data['planType']?.toString(),
      installmentCount: _int(data['installmentCount']),
      startDate: _date(data['startDate'] ?? data['start_date']),
      nextDueDate: _date(data['nextDueDate'] ?? data['next_due_date']),
      discount: _amount(data['discount']),
      notes: data['notes']?.toString(),
      paidAmount: _amount(
        data['paid_amount'] ?? data['paidAmount'] ?? data['totalPaid'],
      ),
      pendingAmount: _amount(
        data['pending_amount'] ??
            data['pendingAmount'] ??
            data['dueAmount'] ??
            data['balance'],
      ),
    );
  }
}

class _CourseOption {
  const _CourseOption({
    required this.id,
    required this.numericId,
    required this.name,
    required this.defaultFee,
  });

  final String id;
  final int? numericId;
  final String name;
  final double defaultFee;

  factory _CourseOption.fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return _CourseOption(
      id: (data['id'] ?? doc.id).toString(),
      numericId: _int(data['id']),
      name: data['name']?.toString() ?? 'Unnamed Course',
      defaultFee: _amount(
        data['fees_amount'] ??
            data['monthly_fees'] ??
            data['yearly_fees'] ??
            data['finalFee'],
      ),
    );
  }
}

class _FeeTotals {
  const _FeeTotals({
    required this.total,
    required this.collected,
    required this.pending,
    required this.dueThisWeek,
  });

  final double total;
  final double collected;
  final double pending;
  final int dueThisWeek;

  factory _FeeTotals.fromSummaries(List<_StudentFeeSummary> summaries) {
    final today = FeesScreenStateHelper.today();
    final weekEnd = today.add(const Duration(days: 7));
    return _FeeTotals(
      total: summaries.fold(
        0,
        (runningTotal, item) => runningTotal + item.finalFee,
      ),
      collected: summaries.fold(
        0,
        (runningTotal, item) => runningTotal + item.paid,
      ),
      pending: summaries.fold(
        0,
        (runningTotal, item) => runningTotal + item.pending,
      ),
      dueThisWeek: summaries.where((item) {
        final due = item.nextDueDate;
        return due != null && !due.isBefore(today) && !due.isAfter(weekEnd);
      }).length,
    );
  }
}

class FeesScreenStateHelper {
  static DateTime today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
}

class _PaymentDraft {
  const _PaymentDraft({
    required this.amount,
    required this.mode,
    required this.paymentDate,
    required this.note,
    this.installmentNo,
    this.installmentLabel,
  });

  final double amount;
  final String mode;
  final DateTime paymentDate;
  final String note;
  final int? installmentNo;
  final String? installmentLabel;
}

class _FeePlanDraft {
  const _FeePlanDraft({
    required this.finalFee,
    required this.discount,
    required this.planType,
    required this.installmentCount,
    required this.startDate,
    required this.nextDueDate,
    required this.note,
  });

  final double finalFee;
  final double discount;
  final String planType;
  final int installmentCount;
  final DateTime startDate;
  final DateTime nextDueDate;
  final String note;
}

class _PaymentHistoryEditDraft {
  const _PaymentHistoryEditDraft({
    required this.amount,
    required this.paymentDate,
    required this.mode,
    required this.remarks,
  });

  final double amount;
  final DateTime paymentDate;
  final String mode;
  final String remarks;
}

class _CorrectedPayment {
  const _CorrectedPayment({required this.record, required this.amount});

  final _FeeRecord record;
  final double amount;
}

InputDecoration _sheetDecoration(String label, IconData icon) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: AppTheme.muted),
    prefixIcon: Icon(icon, color: AppTheme.muted, size: 20),
    filled: true,
    fillColor: AppTheme.background,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppTheme.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppTheme.primary),
    ),
  );
}

String _filterLabel(_FeeFilter filter) {
  return switch (filter) {
    _FeeFilter.all => 'All Students',
    _FeeFilter.pending => 'Pending',
    _FeeFilter.paid => 'Paid',
    _FeeFilter.partial => 'Partial',
    _FeeFilter.dueToday => 'Due Today',
    _FeeFilter.dueThisWeek => 'Due This Week',
  };
}

String _normalizedPaymentMode(String? value) {
  final text = (value ?? '').trim();
  if (_paymentModes.contains(text)) return text;
  for (final mode in _paymentModes) {
    if (mode.toLowerCase() == text.toLowerCase()) return mode;
  }
  return _paymentModes.first;
}

String _normalizedPlanType(String? value) {
  final text = (value ?? '').trim();
  const planTypes = [
    'oneTime',
    'monthly',
    'installments3',
    'installments4',
    'custom',
  ];
  return planTypes.contains(text) ? text : 'oneTime';
}

int _countForPlan(String planType) {
  return switch (_normalizedPlanType(planType)) {
    'monthly' => 10,
    'installments3' => 3,
    'installments4' => 4,
    'custom' => 1,
    _ => 1,
  };
}

String _money(double value) => 'Rs ${value.toStringAsFixed(0)}';

double _amount(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}

int? _int(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

DateTime? _date(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}
