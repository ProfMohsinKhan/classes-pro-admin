part of '../app_database.dart';

@DriftAccessor(tables: [LocalEnquiries])
class EnquiriesDao extends DatabaseAccessor<AppDatabase>
    with _$EnquiriesDaoMixin {
  EnquiriesDao(super.db);

  Stream<List<LocalEnquiry>> watchEnquiries() {
    return (select(
      localEnquiries,
    )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();
  }

  Stream<List<LocalEnquiry>> watchActiveEnquiries() {
    return (select(localEnquiries)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Stream<LocalEnquiry?> watchEnquiryByCloudId(String cloudId) {
    return (select(localEnquiries)
          ..where((t) => t.cloudId.equals(cloudId))
          ..limit(1))
        .watchSingleOrNull();
  }

  Future<LocalEnquiry?> getEnquiryByCloudId(String cloudId) {
    return (select(localEnquiries)
          ..where((t) => t.cloudId.equals(cloudId))
          ..limit(1))
        .getSingleOrNull();
  }

  Stream<List<LocalEnquiry>> watchEnquiriesByStatus(String status) {
    return (select(localEnquiries)
          ..where((t) => t.deletedAt.isNull() & t.enquiryStatus.equals(status))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Stream<List<LocalEnquiry>> watchUpcomingFollowUps(DateTime before) {
    return (select(localEnquiries)
          ..where(
            (t) =>
                t.deletedAt.isNull() &
                t.followUpDate.isNotNull() &
                t.followUpDate.isSmallerOrEqualValue(before),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.followUpDate)]))
        .watch();
  }

  Stream<List<LocalEnquiry>> searchEnquiries(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return watchActiveEnquiries();
    return (select(localEnquiries)..where(
          (t) =>
              t.deletedAt.isNull() &
              (t.studentName.lower().contains(q) |
                  t.parentName.lower().contains(q) |
                  t.phone.contains(q) |
                  t.alternatePhone.contains(q) |
                  t.interestedCourseName.lower().contains(q) |
                  t.interestedBatchName.lower().contains(q) |
                  t.notes.lower().contains(q)),
        ))
        .watch();
  }

  Future<void> upsertEnquiry(LocalEnquiriesCompanion enquiry) async {
    final cloudId = enquiry.cloudId.value;
    if (cloudId != null) {
      final updated = await (update(
        localEnquiries,
      )..where((t) => t.cloudId.equals(cloudId))).write(enquiry);
      if (updated > 0) return;
    }
    await into(localEnquiries).insert(enquiry);
  }

  Future<void> upsertRemoteEnquiryPreservingPending(
    LocalEnquiriesCompanion enquiry,
  ) async {
    final cloudId = enquiry.cloudId.value;
    if (cloudId == null) return;
    final existing = await getEnquiryByCloudId(cloudId);
    if (existing != null && existing.syncStatus != LocalSyncStatus.synced) {
      return;
    }
    await upsertEnquiry(enquiry);
  }

  Future<List<LocalEnquiry>> getPendingEnquiries() {
    return (select(
          localEnquiries,
        )..where((t) => t.syncStatus.equalsValue(LocalSyncStatus.synced).not()))
        .get();
  }

  Future<int> countEnquiries() {
    return (selectOnly(localEnquiries)
          ..addColumns([localEnquiries.localId.count()]))
        .map((row) => row.read(localEnquiries.localId.count()) ?? 0)
        .getSingle();
  }

  Future<void> archiveEnquiry(String cloudId) {
    final now = DateTime.now();
    return (update(
      localEnquiries,
    )..where((t) => t.cloudId.equals(cloudId))).write(
      LocalEnquiriesCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        syncStatus: const Value(LocalSyncStatus.pendingDelete),
      ),
    );
  }

  Future<void> restoreEnquiry(String cloudId) {
    final now = DateTime.now();
    return (update(
      localEnquiries,
    )..where((t) => t.cloudId.equals(cloudId))).write(
      LocalEnquiriesCompanion(
        deletedAt: const Value(null),
        updatedAt: Value(now),
        syncStatus: const Value(LocalSyncStatus.pendingUpdate),
      ),
    );
  }

  Future<void> markEnquirySynced(String cloudId) {
    final now = DateTime.now();
    return (update(
      localEnquiries,
    )..where((t) => t.cloudId.equals(cloudId))).write(
      LocalEnquiriesCompanion(
        syncStatus: const Value(LocalSyncStatus.synced),
        lastSyncedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> markEnquiryFailed(String cloudId) {
    return (update(
      localEnquiries,
    )..where((t) => t.cloudId.equals(cloudId))).write(
      LocalEnquiriesCompanion(
        syncStatus: const Value(LocalSyncStatus.failed),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
