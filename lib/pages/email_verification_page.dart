import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Page shown after registration, prompting the user to verify their email.
/// It:
///  • Sends an initial verification email (if not already sent),
///  • Polls Firebase every few seconds to check if the email has been verified,
///  • Allows the user to manually resend the verification email (with a cooldown),
///  • Provides a “Refresh” button to recheck status immediately.
class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final _auth = FirebaseAuth.instance;
  Timer? _pollingTimer;
  Timer? _resendCooldownTimer;

  bool _canResend = false;         // Controls if “Resend email” is enabled
  int _resendCooldown = 60;        // Cooldown seconds before allowing resend

  @override
  void initState() {
    super.initState();
    // Send the first verification email as soon as this page appears
    _sendVerificationEmail();

    // Start polling every 5 seconds to see if the user clicked the link
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _checkEmailVerified(),
    );
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _resendCooldownTimer?.cancel();
    super.dispose();
  }

  /// Sends a verification email to the current user, then starts the cooldown.
  Future<void> _sendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        _startResendCooldown();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification email sent!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending email: $e')),
      );
    }
  }

  /// Starts a 60‑second cooldown during which the “Resend” button is disabled.
  void _startResendCooldown() {
    setState(() {
      _canResend = false;
      _resendCooldown = 60;
    });
    _resendCooldownTimer?.cancel();
    _resendCooldownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (_resendCooldown == 0) {
          timer.cancel();
          setState(() => _canResend = true);
        } else {
          setState(() => _resendCooldown--);
        }
      },
    );
  }

  /// Reloads the user from Firebase and, if verified, navigates to HomePage.
  Future<void> _checkEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await user.reload();
    if (user.emailVerified) {
      _pollingTimer?.cancel();
      // Once verified, FirebaseAuth.authStateChanges() in AuthGate will emit
      // a new snapshot, and AuthGate will automatically show HomePage.
      // We just need to rebuild.
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    // If for some reason the user is null or already verified, skip this page
    if (user == null || user.emailVerified) {
      // Let AuthGate pick up the change and show HomePage
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Verify Your Email')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'A verification link has been sent to your email address.\n'
              'Please check your inbox (and spam folder), then click the link.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),

            // Show the user’s email for clarity
            Row(
              children: [
                const Icon(Icons.email),
                const SizedBox(width: 8),
                Expanded(child: Text(user.email ?? '')),
              ],
            ),
            const SizedBox(height: 24),

            // Resend button with cooldown
            ElevatedButton(
              onPressed: _canResend ? _sendVerificationEmail : null,
              child: Text(
                _canResend
                    ? 'Resend Verification Email'
                    : 'Resend in $_resendCooldown s',
              ),
            ),
            const SizedBox(height: 12),

            // Manual refresh button
            OutlinedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('I have verified, refresh status'),
              onPressed: _checkEmailVerified,
            ),
          ],
        ),
      ),
    );
  }
}
