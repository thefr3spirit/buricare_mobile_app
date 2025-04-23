import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// A page that lets the user register or sign in using:
///  • Email & password
///  • Google Sign‑In
///
/// Toggling between “Login” and “Register” is handled via [_isLoginMode].
class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  // Form key to validate inputs
  final _formKey = GlobalKey<FormState>();

  // Controllers for our text fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _babyNameController = TextEditingController();

  // Tracks whether we’re in “Login” (true) or “Register” (false) mode
  bool _isLoginMode = true;

  // Show/hide password fields
  bool _obscurePassword = true;

  // Display loading spinner during async operations
  bool _isLoading = false;

  @override
  void dispose() {
    // Clean up controllers to avoid memory leaks
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _babyNameController.dispose();
    super.dispose();
  }

  /// Toggle between Login and Register modes
  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
    });
  }

  /// Display a snack bar with [message]
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// Perform Email/Password registration or login
  Future<void> _submitEmailPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final auth = FirebaseAuth.instance;

    try {
      if (_isLoginMode) {
        // Sign in
        await auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        // Register new user
        final cred = await auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        // Set display name on Firebase user (optional)
        await cred.user?.updateDisplayName(
          '${_firstNameController.text} ${_lastNameController.text}',
        );
        // Send email verification
        await cred.user?.sendEmailVerification();
        _showMessage('Verification email sent. Please check your inbox.');
      }
    } on FirebaseAuthException catch (e) {
      // Handle common errors
      String msg = 'Authentication error';
      if (e.code == 'email-already-in-use') {
        msg = 'This email is already registered.';
      } else if (e.code == 'weak-password') {
        msg = 'Password should be at least 6 characters.';
      } else if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        msg = 'Invalid email or password.';
      }
      _showMessage(msg);
    } catch (e) {
      _showMessage('An unexpected error occurred.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Trigger Google Sign‑In and authenticate with Firebase
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // User canceled the sign‑in
        return;
      }
      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      _showMessage('Google sign‑in failed: ${e.message}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoginMode ? 'BuriCare Login' : 'BuriCare Register'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // If registering, show name & baby fields
                    if (!_isLoginMode) ...[
                      TextFormField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(labelText: 'First Name'),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: _middleNameController,
                        decoration: const InputDecoration(labelText: 'Middle Name (optional)'),
                      ),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(labelText: 'Last Name'),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: _babyNameController,
                        decoration: const InputDecoration(labelText: 'Baby\'s Name'),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Email field
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),

                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () => setState(() {
                            _obscurePassword = !_obscurePassword;
                          }),
                        ),
                      ),
                      obscureText: _obscurePassword,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (v.length < 6) return 'Minimum 6 characters';
                        return null;
                      },
                    ),

                    // Confirm Password (only in register mode)
                    if (!_isLoginMode) ...[
                      TextFormField(
                        controller: _confirmController,
                        decoration:
                            const InputDecoration(labelText: 'Confirm Password'),
                        obscureText: true,
                        validator: (v) {
                          if (v != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Submit button
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _submitEmailPassword,
                            child: Text(_isLoginMode ? 'Login' : 'Register'),
                          ),

                    // Google Sign‑In
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      icon: Image.asset(
                        'assets/google_logo.png',
                        height: 24,
                        width: 24,
                      ),
                      label: const Text('Sign in with Google'),
                      onPressed: _isLoading ? null : _signInWithGoogle,
                    ),

                    // Switch between modes
                    TextButton(
                      onPressed: _toggleMode,
                      child: Text(_isLoginMode
                          ? 'Don’t have an account? Register'
                          : 'Already have an account? Login'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
