import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isChecking = false;

  Future<void> _checkVerification() async {
    setState(() {
      _isChecking = true;
    });

    final authProvider = context.read<AuthProvider>();

    final verified = await authProvider.checkEmailVerification();

    if (mounted) {
      setState(() {
        _isChecking = false;
      });

      if (verified) {
        // AuthGate will handle navigation automatically.
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Email is not verified yet. Please check your inbox.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _resendVerification() async {
    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.sendEmailVerification();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Verification email sent.'
              : authProvider.errorMessage ??
                  'Could not send verification email.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 420,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.mark_email_unread_outlined,
                    size: 72,
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Verify Your Email',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'We have sent a verification link to your email address. '
                    'Please verify your email before continuing.',
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isChecking
                          ? null
                          : _checkVerification,
                      child: _isChecking
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('I Have Verified My Email'),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: _resendVerification,
                    child: const Text(
                      'Resend Verification Email',
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: () async {
                      await context.read<AuthProvider>().logout();
                    },
                    child: const Text('Logout'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}