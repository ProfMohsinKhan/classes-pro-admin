import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/institute_settings_model.dart';

class InstituteSettingsService {
  InstituteSettingsService._();

  static final InstituteSettingsService instance = InstituteSettingsService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  InstituteSettingsModel? _cache;

  DocumentReference<Map<String, dynamic>> get _settingsRef =>
      _firestore.collection('settings').doc('institute');

  InstituteSettingsModel getDefaultSettings() {
    return InstituteSettingsModel.defaults();
  }

  InstituteSettingsModel get cachedOrDefault {
    return _cache ?? getDefaultSettings();
  }

  Future<InstituteSettingsModel> loadSettings({
    bool forceRefresh = false,
  }) async {
    if (_cache != null && !forceRefresh) return _cache!;

    final doc = await _settingsRef.get();
    if (doc.exists) {
      _cache = InstituteSettingsModel.fromMap(doc.id, doc.data() ?? {});
      return _cache!;
    }

    final legacyDoc = await _firestore
        .collection('settings')
        .doc('institute_profile')
        .get();
    if (legacyDoc.exists) {
      _cache = InstituteSettingsModel.fromMap(
        'institute',
        legacyDoc.data() ?? {},
      );
      return _cache!;
    }

    _cache = getDefaultSettings();
    return _cache!;
  }

  Stream<InstituteSettingsModel> streamSettings() {
    return _settingsRef.snapshots().map((doc) {
      if (!doc.exists) return _cache ?? getDefaultSettings();
      _cache = InstituteSettingsModel.fromMap(doc.id, doc.data() ?? {});
      return _cache!;
    });
  }

  Future<InstituteSettingsModel> ensureDefaultSettings() async {
    final existing = await _settingsRef.get();
    if (existing.exists) return loadSettings(forceRefresh: true);
    final defaults = getDefaultSettings();
    await _settingsRef.set(defaults.toMap(), SetOptions(merge: true));
    _cache = defaults;
    return defaults;
  }

  Future<void> saveSettings(InstituteSettingsModel settings) async {
    await _settingsRef.set(settings.toMap(), SetOptions(merge: true));
    _cache = settings;
  }
}
