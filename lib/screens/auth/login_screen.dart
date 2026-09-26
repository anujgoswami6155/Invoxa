import 'package:flutter/material.dart';

import 'register_screen.dart';
import 'sign_in_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  // Dark aesthetic minimal color palette (Electric Indigo & Deep Obsidian)
  static const Color _bgDark = Color(0xFF080C15);
  static const Color _cardBg = Color(0xFF101625);
  static const Color _cardBorder = Color(0xFF1E2942);
  static const Color _primaryAccent = Color(0xFF6366F1);
  static const Color _primaryAccentLight = Color(0xFF818CF8);
  static const Color _buttonSecondaryBg = Color(0xFF151C2E);
  static const Color _buttonSecondaryBorder = Color(0xFF243250);
  static const Color _textMuted = Color(0xFF94A3B8);
  static const Color _textSubtle = Color(0xFF64748B);

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
                  colors: const [
                    Color(0x2E6366F1), // Indigo subtle glow
                    Color(0x330F172A),
                    _bgDark,
                  ],
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
                      // Top Branding Header
                      _buildTopBranding(),

                      const SizedBox(height: 28),

                      // Showcase / Hero Card (Exact layout & hierarchy from reference image)
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
        ],
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

  // 2. Showcase / Hero Card (Exact layout & hierarchy from reference image)
  Widget _buildShowcaseCard(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pill Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF161F33),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF283658), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.auto_awesome, size: 13, color: _primaryAccentLight),
                SizedBox(width: 7),
                Text(
                  'Mobile-First Invoicing & Billing',
                  style: TextStyle(
                    color: Color(0xFFC7D2FE),
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
                  style: TextStyle(color: Colors.white),
                ),
                TextSpan(
                  text: 'Smarter business.',
                  style: TextStyle(color: _primaryAccentLight),
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

          // Action Button 1: Login with Email ->
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
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: const Color(0x666366F1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Login with Email',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 18),
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
                foregroundColor: const Color(0xFFF1F5F9),
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
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Action Button 3: Explore Demo Pill
          Center(
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SignInScreen(
                      initialEmail: 'demo@invoxa.com',
                      initialPassword: 'demo123456',
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1424),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF1E2B48), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.auto_awesome_outlined,
                      size: 13,
                      color: _primaryAccentLight,
                    ),
                    SizedBox(width: 7),
                    Text(
                      'Explore Demo (Preloaded with Rahul Enterprises)',
                      style: TextStyle(
                        color: _textMuted,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
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
        Icon(icon, size: 16, color: _primaryAccentLight),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFFCBD5E1),
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
