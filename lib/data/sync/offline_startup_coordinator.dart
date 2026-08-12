import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/database/database_provider.dart';
import 'offline_bootstrap.dart';
import 'sync_engine.dart';

class OfflineStartupCoordinator {
  OfflineStartupCoordinator._();

  static String? _startedForUid;

  static void startForActiveUser(String uid) {
    if (_startedForUid == uid) return;
    _startedForUid = uid;
    unawaited(_run());
  }

  static Future<void> _run() async {
    final database = OfflineDatabaseProvider.instance;
    try {
      final bootstrap = OfflineBootstrapService(database);
      await bootstrap.bootstrapCoursesBatchesAndStudents();
      final syncEngine = SyncEngine(database);
      await syncEngine.syncCourses();
      await syncEngine.syncBatches();
      await syncEngine.syncStudents();
      await syncEngine.syncEnquiries();
      await syncEngine.syncAttendance();
      await syncEngine.dispose();
    } catch (e) {
      debugPrint('OfflineBootstrap: failed, keeping local data: $e');
    }
  }
}
