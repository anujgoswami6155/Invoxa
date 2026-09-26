import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  // Dark aesthetic minimal color palette (Electric Indigo & Deep Obsidian)
  static const Color _bgDark = Color(0xFF080C15);
  static const Color _cardBg = Color(0xFF101625);
  static const Color _cardBorder = Color(0xFF1E2942);
  static const Color _primaryAccent = Color(0xFF6366F1);
  static const Color _primaryAccentLight = Color(0xFF818CF8);
  static const Color _inputFill = Color(0xFF0B101D);
  static const Color _inputBorder = Color(0xFF1D2840);
  static const Color _textMuted = Color(0xFF94A3B8);
  static const Color _textSubtle = Color(0xFF64748B);

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.resetPassword(
      _emailController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF131C31),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: _primaryAccentLight),
          ),
          content: const Row(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                color: _primaryAccentLight,
                size: 20,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Reset email sent! Please check your inbox and click the link.',
                  style: TextStyle(color: Color(0xFFE2E8F0)),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 5),
        ),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF1F1218),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Color(0xFF881337)),
          ),
          content: Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFFB7185),
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  authProvider.errorMessage ??
                      'Could not send password reset email.',
                  style: const TextStyle(color: Color(0xFFFECDD3)),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: Stack(
        children: [
          // Ambient Radial Background Glow
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.0, -0.25),
                  radius: 0.95,
                  colors: const [Color(0x2E6366F1), Color(0x330F172A), _bgDark],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top Branding
                      _buildTopBranding(),

                      const SizedBox(height: 28),

                      // Reset Password Card
                      _buildCard(context),

                      const SizedBox(height: 24),

                      // Bottom Trust Badge
                      _buildFooterBadge(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBranding() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _primaryAccent,
            borderRadius: BorderRadius.circular(13),
            boxShadow: const [
              BoxShadow(
                color: Color(0x666366F1),
                blurRadius: 18,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.receipt_long_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'INVOXA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.2,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'BUSINESS SUITE',
              style: TextStyle(
                color: _primaryAccentLight,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.5,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _cardBorder, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 36,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Navigation row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => Navigator.pop(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 2,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.arrow_back_rounded,
                          size: 16,
                          color: _primaryAccentLight,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Back to Login',
                          style: TextStyle(
                            color: _primaryAccentLight,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161F33),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF283658),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'Recovery',
                    style: TextStyle(
                      color: Color(0xFFC7D2FE),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                ),
                children: [
                  TextSpan(
                    text: 'Reset Password.\n',
                    style: TextStyle(color: Colors.white),
                  ),
                  TextSpan(
                    text: 'Secure Your Account.',
                    style: TextStyle(color: _primaryAccentLight),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter your registered email address and we will send you a secure link to reset your password.',
              style: TextStyle(color: _textMuted, fontSize: 13, height: 1.5),
            ),

            const SizedBox(height: 22),

            // In-Card Error Display
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                if (auth.errorMessage == null) {
                  return const SizedBox.shrink();
                }
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D141E),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF9F1239)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: Color(0xFFFB7185),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          auth.errorMessage!,
                          style: const TextStyle(
                            color: Color(0xFFFECDD3),
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Email Address Input
            const Text(
              'Registered Email Address',
              style: TextStyle(
                color: Color(0xFFCBD5E1),
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                filled: true,
                fillColor: _inputFill,
                hintText: 'name@business.com',
                hintStyle: const TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 13,
                ),
                prefixIcon: const Icon(
                  Icons.mail_outline_rounded,
                  color: _primaryAccentLight,
                  size: 20,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _inputBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _inputBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: _primaryAccent,
                    width: 1.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE11D48)),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFE11D48),
                    width: 1.5,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your email';
                }

                final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

                if (!emailRegex.hasMatch(value.trim())) {
                  return 'Please enter a valid email address';
                }

                return null;
              },
            ),

            const SizedBox(height: 24),

            // Reset Password Submit Button
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _resetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryAccent,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0x806366F1),
                      elevation: 4,
                      shadowColor: const Color(0x666366F1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    child: authProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Send Reset Link',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 18),
                            ],
                          ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Back to Login Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Remember your password? ',
                  style: TextStyle(color: _textMuted, fontSize: 13),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                      color: _primaryAccentLight,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterBadge() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.shield_outlined, size: 14, color: _primaryAccentLight),
          SizedBox(width: 7),
          Text(
            'Secure Local-First Business Architecture',
            style: TextStyle(
              color: _textSubtle,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
