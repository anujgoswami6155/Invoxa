import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'register_screen.dart';
import 'sign_in_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const Color _bg = AppColors.bg;
  static const Color _cardBg = AppColors.cardBg;
  static const Color _cardBorder = AppColors.cardBorder;
  static const Color _primaryAccent = AppColors.primary;
  static const Color _buttonSecondaryBg = AppColors.sand;
  static const Color _buttonSecondaryBorder = AppColors.camel;
  static const Color _textMuted = AppColors.textMuted;
  static const Color _textSubtle = AppColors.textSubtle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
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
                  // Top Branding Header
                  _buildTopBranding(),

                  const SizedBox(height: 28),

                  // Showcase / Hero Card
                  _buildShowcaseCard(context),

                  const SizedBox(height: 24),

                  // Bottom Trust/Security Badge
                  _buildFooterBadge(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 1. Top Logo & Business Suite Header
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
                color: Color(0x330F4C75),
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
                color: AppColors.textDark,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.2,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'BUSINESS SUITE',
              style: TextStyle(
                color: AppColors.iceBlue,
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

  // 2. Showcase / Hero Card
  Widget _buildShowcaseCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _cardBorder, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x180F4C75),
            blurRadius: 28,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pill Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF163245),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF2B5370),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.auto_awesome, size: 13, color: AppColors.iceBlue),
                SizedBox(width: 7),
                Text(
                  'Mobile-First Invoicing & Billing',
                  style: TextStyle(
                    color: AppColors.iceBlue,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Main Headline
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                height: 1.22,
              ),
              children: [
                TextSpan(
                  text: 'Simple invoicing.\n',
                  style: TextStyle(color: AppColors.textDark),
                ),
                TextSpan(
                  text: 'Smarter business.',
                  style: TextStyle(color: AppColors.azureBlue),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Description Paragraph
          const Text(
            'Effortlessly manage customers, create snapshot invoices, track partial & full payments, and monitor your revenue in real-time.',
            style: TextStyle(color: _textMuted, fontSize: 13.5, height: 1.55),
          ),

          const SizedBox(height: 22),

          // 2x2 Feature Bullets Grid
          Row(
            children: [
              Expanded(
                child: _buildFeatureItem(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'Instant Invoicing',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFeatureItem(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'Payment Tracking',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildFeatureItem(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'Snapshot Integrity',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFeatureItem(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'Customer Ledger',
                ),
              ),
            ],
          ),

          const SizedBox(height: 26),

          // Action Button 1: Login with Email
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignInScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryAccent,
                foregroundColor: AppColors.cream,
                elevation: 4,
                shadowColor: const Color(0x33113946),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Login with Email',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.cream,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: AppColors.cream,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Action Button 2: Create New Account
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: _buttonSecondaryBg,
                foregroundColor: AppColors.textDark,
                side: const BorderSide(
                  color: _buttonSecondaryBorder,
                  width: 1.1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: const Text(
                'Create New Account',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Feature Bullet Widget
  Widget _buildFeatureItem({required IconData icon, required String label}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.camelDark),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // 4. Bottom Footer Security Badge
  Widget _buildFooterBadge() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.shield_outlined, size: 14, color: AppColors.camelDark),
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
