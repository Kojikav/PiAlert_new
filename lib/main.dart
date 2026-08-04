import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Prevent Google Fonts from downloading fonts at runtime (use bundled/system fonts)
  GoogleFonts.config.allowRuntimeFetching = false;

  runApp(const PiAlertApp());

  // Initialize notifications asynchronously in the background
  final notificationService = NotificationService();
  notificationService.initialize().catchError((e) {
    debugPrint('Notification initialization failed: $e');
  });
}
