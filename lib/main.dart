import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/providers/providers.dart';
import 'core/constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file.
  // The .env file is excluded from version control. Copy .env.example to .env
  // and fill in your real API keys to get started.
  await dotenv.load(fileName: '.env');

  // Initialize Hive local storage
  await Hive.initFlutter();
  await Hive.openBox(AppConstants.onboardingBox);
  await Hive.openBox(AppConstants.userPrefsBox);

  // Initialize Firebase
  // NOTE: Requires google-services.json (Android) and GoogleService-Info.plist (iOS).
  // If those files are not yet placed, Firebase.initializeApp() will throw.
  // You can wrap this in a try/catch if you want to test without Firebase.
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // If Firebase config files are missing, the app still runs in degraded mode.
    debugPrint('Firebase init failed: $e — ensure google-services.json is in android/app/');
  }

  runApp(
    const ProviderScope(
      child: CineSphereApp(),
    ),
  );
}

class CineSphereApp extends ConsumerWidget {
  const CineSphereApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final isDarkMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
    );
  }
}
