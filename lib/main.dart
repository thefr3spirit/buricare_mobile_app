import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'models/vitals_hive.dart';

import 'pages/sign_in_page.dart';
import 'pages/home_page.dart';
import 'pages/email_verification_page.dart';

import 'services/notification_service.dart';

/// A Riverpod provider that starts the VitalsPipeline for the current user.
import 'services/vitals_pipeline.dart';
final pipelineProvider = Provider<VitalsPipeline>((ref) {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final pipeline = VitalsPipeline(uid);
  ref.onDispose(() => pipeline.dispose());
  return pipeline;
});

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive setup
  await Hive.initFlutter();
  Hive.registerAdapter(VitalsHiveAdapter());
  await Hive.openBox<VitalsHive>('cached_readings');

  // Firebase init
  if (Firebase.apps.isEmpty) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e, st) {
      debugPrint('⚠️ Firebase initialization error: $e\n$st');
    }
  }

  // Initialize local notifications
  await NotificationService.init();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BuriCare',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const AuthGate(),
    );
  }
}

/// Routes the user based on auth & verification state.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        // Not logged in
        if (!snapshot.hasData) {
          return const SignInPage();
        }
        final user = snapshot.data!;
        // Logged in but email not verified
        if (!user.emailVerified) {
          return const EmailVerificationPage();
        }
        // Logged in & verified → go to dashboard
        return const HomePage();
      },
    );
  }
}
