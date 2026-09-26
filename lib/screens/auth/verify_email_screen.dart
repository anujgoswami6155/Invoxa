import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../dashboard/dashboard_screen.dart';
import 'auth_gate.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isChecking = false;
  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;
  Timer? _autoCheckTimer;

  // Emerald Dark Aesthetic Color Palette (as in reference image)
  static const Color _bgDark = Color(0xFF060D0A);
  static const Color _cardBg = Color(0xFF0B1612);
  static const Color _cardBorder = Color(0xFF14291F);
  static const Color _primaryAccent = Color(0xFF00D07E);
  static const Color _primaryAccentLight = Color(0xFF34D399);
  static const Color _buttonSecondaryBg = Color(0xFF102018);
  static const Color _buttonSecondaryBorder = Color(0xFF193828);
  static const Color _textMuted = Color(0xFF98ACA2);
  static const Color _textSubtle = Color(0xFF5A7568);

  @override
  void initState() {
    super.initState();
    // Auto-check periodically in case user verified via email link in browser
    _autoCheckTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      _checkVerification(silent: true);
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _autoCheckTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() {
      _cooldownSeconds = 60;
    });
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownSeconds <= 1) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _cooldownSeconds = 0;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _cooldownSeconds--;
          });
        }
      }
    });
  }

  Future<void> _checkVerification({bool silent = false}) async {
    if (_isChecking) return;

    if (!silent) {
      setState(() {
        _isChecking = true;
      });
    }

    final authProvider = context.read<AuthProvider>();
    final verified = await authProvider.checkEmailVerification();

    if (!mounted) return;

    if (verified) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (route) => false,
      );
      return;
    }

    if (!silent) {
      setState(() {
        _isChecking = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF1F1218),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Color(0xFF881337)),
          ),
          content: const Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: Color(0xFFFB7185),
                size: 20,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Email is not verified yet. Please check your inbox.',
                  style: TextStyle(color: Color(0xFFFECDD3)),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Future<void> _resendVerification() async {
    if (_cooldownSeconds > 0) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.sendEmailVerification();

    if (!mounted) return;

    if (success) {
      _startCooldown();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF0D2519),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: _primaryAccentLight),
          ),
          content: const Row(
            children: [
              Icon(
                Icons.mail_outline_rounded,
                color: _primaryAccentLight,
                size: 20,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'New verification email sent. Please check your latest email.',
                  style: TextStyle(color: Color(0xFFE2E8F0)),
                ),
              ),
            ],
          ),
        ),
      );
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
                      'Could not send verification email.',
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
          // Ambient Radial Background Glow (Emerald aura)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.0, -0.25),
                  radius: 0.95,
                  colors: const [Color(0x3800D07E), Color(0x2805291C), _bgDark],
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
                      _buildTopBranding(),
                      const SizedBox(height: 28),
                      _buildCard(context),
                      const SizedBox(height: 24),
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
                color: Color(0x6600D07E),
                blurRadius: 18,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.receipt_long_rounded,
            color: Color(0xFF042717),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Pill Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E2419),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF18422E), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.mark_email_unread_outlined,
                      size: 13,
                      color: _primaryAccentLight,
                    ),
                    SizedBox(width: 7),
                    Text(
                      'Action Required',
                      style: TextStyle(
                        color: Color(0xFFA7F3D0),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C1F16),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF173827), width: 1),
                ),
                child: const Text(
                  'Step 2 of 2',
                  style: TextStyle(
                    color: Color(0xFF6EE7B7),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                height: 1.25,
              ),
              children: [
                TextSpan(
                  text: 'Verify Your Email.\n',
                  style: TextStyle(color: Colors.white),
                ),
                TextSpan(
                  text: 'Activate Workspace.',
                  style: TextStyle(color: _primaryAccent),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'We have sent a secure verification link to your email address. Please click the link to confirm your ownership and continue.',
            style: TextStyle(color: _textMuted, fontSize: 13, height: 1.5),
          ),

          const SizedBox(height: 22),

          // Tip / Advisory Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: const Color(0xFF07140E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF132B1E)),
            ),
            child: Row(
              children: const [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  color: _primaryAccentLight,
                  size: 18,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tip: Each new request cancels previous links. Open only the newest email received in your inbox.',
                    style: TextStyle(
                      color: Color(0xFFD1FAE5),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Primary Button: I Have Verified My Email
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isChecking ? null : () => _checkVerification(),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryAccent,
                foregroundColor: const Color(0xFF042717),
                disabledBackgroundColor: const Color(0x8000D07E),
                elevation: 4,
                shadowColor: const Color(0x6600D07E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: _isChecking
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF042717),
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'I Have Verified My Email',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF042717),
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: Color(0xFF042717),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 12),

          // Secondary Action: Resend Verification Email with Cooldown
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: _cooldownSeconds > 0 ? null : _resendVerification,
              style: OutlinedButton.styleFrom(
                backgroundColor: _buttonSecondaryBg,
                foregroundColor: const Color(0xFFF1F5F9),
                disabledForegroundColor: _textSubtle,
                side: const BorderSide(
                  color: _buttonSecondaryBorder,
                  width: 1.1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: Text(
                _cooldownSeconds > 0
                    ? 'Resend Verification Email (${_cooldownSeconds}s)'
                    : 'Resend Verification Email',
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Logout Action Link
          Center(
            child: TextButton.icon(
              onPressed: () async {
                await context.read<AuthProvider>().logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const AuthGate()),
                    (route) => false,
                  );
                }
              },
              icon: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFFB7185),
                size: 16,
              ),
              label: const Text(
                'Log out and use different account',
                style: TextStyle(
                  color: Color(0xFFFB7185),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
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
