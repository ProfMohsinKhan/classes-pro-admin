import 'app_database.dart';

class OfflineDatabaseProvider {
  OfflineDatabaseProvider._();

  static AppDatabase? _instance;

  static AppDatabase get instance => _instance ??= AppDatabase.defaults();

  static Future<void> close() async {
    final database = _instance;
    _instance = null;
    await database?.close();
  }
}
