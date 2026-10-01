import 'package:classes_pro_admin/screens/auth_gate.dart';
import 'package:classes_pro_admin/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Ye wahi file hai jo abhi generate hui
import 'package:flutter/services.dart'; // NAYA IMPORT
import 'services/attendance_reminder_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🚀 THE FIX: System Bars ki styling aur color set karna
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor:
          Colors.transparent, // Upar ka notification bar transparent rahega
      statusBarIconBrightness:
          Brightness.dark, // Battery/Time ke icons dark dikhenge
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness:
          Brightness.dark, // Niche ke buttons dark honge
    ),
  );

  // App ko edge-to-edge mode se hatakar standard safe mode mein laana
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: SystemUiOverlay.values,
  );
  // Firebase ko initialize karna zaroori hai
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AttendanceReminderService.instance.initialize();
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  runApp(const ClassesAdminApp());
}

class ClassesAdminApp extends StatelessWidget {
  const ClassesAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Classes Management Pro Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      home: const AuthGate(),
    );
  }
}
